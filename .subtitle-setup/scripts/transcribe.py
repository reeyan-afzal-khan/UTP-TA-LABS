"""Single-GPU, resumable course transcription. Existing unmanaged subtitles are protected."""
import argparse
import gc
import hashlib
import json
import logging
import sqlite3
import subprocess
import tempfile
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from common import MEDIA, RUNTIME, STATE, atomic_text, config, discover
from subtitles import render


def fingerprint(path, settings, revision):
    stat = path.stat()
    data = {'size': stat.st_size, 'mtime_ns': stat.st_mtime_ns, 'settings': settings,
            'revision': revision, 'pipeline': 1}
    return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--folder', default='', help='Course subfolder or single file, relative to .courses')
    parser.add_argument('--language', help='Whisper language code, e.g. en or de')
    parser.add_argument('--mode', choices=['verbatim', 'intended'])
    parser.add_argument('--limit', type=int, help='Process at most this many pending files')
    parser.add_argument('--sample-seconds', type=int, help='Test a prefix of one file; save only in runtime/samples')
    parser.add_argument('--overwrite', action='store_true', help='Explicitly replace existing subtitles, including manually edited files')
    parser.add_argument('--dry-run', action='store_true', help='List pending work without loading the model')
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1: parser.error('--limit must be positive')
    if args.sample_seconds is not None and args.sample_seconds < 1: parser.error('--sample-seconds must be positive')
    settings = config()
    for key in ('language', 'mode'):
        if getattr(args, key): settings[key] = getattr(args, key)
    print('Scanning media under .courses/' + args.folder + ' ...', flush=True)
    files = discover(args.folder)
    outputs = [str(p.with_suffix('.srt')).casefold() for p in files]
    if len(outputs) != len(set(outputs)):
        raise RuntimeError('Two media files have the same subtitle filename. Select one file at a time or rename the conflicting media.')
    from run_lock import RunLock
    with RunLock(STATE / 'active-run'):
        run(args, settings, files)


def run(args, settings, files):
    log_dir = STATE / 'logs'
    log_dir.mkdir(exist_ok=True)
    log_path = log_dir / (datetime.now().strftime('%Y%m%d-%H%M%S') + '.log')
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s',
                        handlers=[logging.StreamHandler(), logging.FileHandler(log_path, encoding='utf-8')])
    record_path = RUNTIME / 'model.json'
    model_record = json.loads(record_path.read_text()) if record_path.exists() else {}
    db = sqlite3.connect(STATE / 'progress.sqlite3')
    db.execute('CREATE TABLE IF NOT EXISTS jobs (media TEXT PRIMARY KEY, fingerprint TEXT, status TEXT, error TEXT, updated TEXT, srt_hash TEXT)')
    pending = []
    skipped = 0
    for path in files:
        relative = path.relative_to(MEDIA).as_posix()
        signature = fingerprint(path, settings, model_record.get('revision'))
        row = db.execute('SELECT fingerprint,status,srt_hash FROM jobs WHERE media=?', (relative,)).fetchone()
        output = path.with_suffix('.srt')
        if output.exists() and not args.overwrite and not args.sample_seconds:
            current_hash = hashlib.sha256(output.read_bytes()).hexdigest()
            if row and row[0] == signature and row[1] == 'done' and row[2] == current_hash:
                skipped += 1
                continue
            logging.warning('Preserving existing or modified subtitle: %s (use --overwrite to replace)', output)
            skipped += 1
            continue
        pending.append((path, relative, signature))
    if args.sample_seconds: pending = pending[:1]
    elif args.limit: pending = pending[:args.limit]
    logging.info('Discovered=%d skipped=%d selected=%d | log=%s', len(files), skipped, len(pending), log_path)
    if args.dry_run:
        for _, relative, _ in pending: print(relative)
        return
    if not pending: return
    if model_record.get('model') != settings['model'] or not Path(model_record.get('path', '')).is_dir():
        raise RuntimeError('Download the configured model with step 03 first.')
    if settings.get('revision') and model_record.get('revision') != settings['revision']:
        raise RuntimeError('Model revision changed. Run step 03 before transcribing.')
    import imageio_ffmpeg
    from crisperwhisper import CrisperWhisperModel
    if settings['backend'] == 'ct2':
        import ctranslate2
        if ctranslate2.get_cuda_device_count() < 1:
            raise RuntimeError('CTranslate2 cannot see a CUDA GPU.')
        logging.info('Loading %s with CUDA CTranslate2 (%s)', settings['model'], settings['compute_type'])
    else:
        import torch
        if not torch.cuda.is_available(): raise RuntimeError('CUDA unavailable; refusing an accidental CPU batch.')
        logging.info('Loading %s on %s', settings['model'], torch.cuda.get_device_name(0))
    model = CrisperWhisperModel(model_record['path'], backend=settings['backend'],
                               device='cuda', compute_type=settings['compute_type'])
    failures = completed = 0
    started = time.monotonic()
    def update(relative, signature, status, error='', digest=''):
        db.execute('INSERT OR REPLACE INTO jobs VALUES (?,?,?,?,?,?)',
                   (relative, signature, status, error, datetime.now(timezone.utc).isoformat(), digest))
        db.commit()
    for index, (path, relative, signature) in enumerate(pending, 1):
        stop = threading.Event()
        file_start = time.monotonic()
        def heartbeat():
            while not stop.wait(30):
                logging.info('[%d/%d] Still processing: %s (%.1f min elapsed)', index, len(pending), relative, (time.monotonic()-file_start)/60)
        thread = threading.Thread(target=heartbeat, daemon=True)
        thread.start()
        try:
            logging.info('[%d/%d] Starting: %s', index, len(pending), relative)
            if not args.sample_seconds: update(relative, signature, 'running')
            with tempfile.TemporaryDirectory(prefix='audio-', dir=RUNTIME) as scratch:
                wav = Path(scratch) / 'audio.wav'
                command = [imageio_ffmpeg.get_ffmpeg_exe(), '-nostdin', '-hide_banner', '-loglevel', 'error', '-i', str(path)]
                if args.sample_seconds: command += ['-t', str(args.sample_seconds)]
                command += ['-map', '0:a:0', '-vn', '-ac', '1', '-ar', '16000', '-c:a', 'pcm_s16le', '-y', str(wav)]
                subprocess.run(command, check=True, capture_output=True, timeout=7200)
                result = model.transcribe(str(wav), language=settings['language'], mode=settings['mode'], word_timestamps=True)
                text = render(result.words or [], width=settings['line_width'], max_lines=settings['max_lines'], max_seconds=settings['max_cue_seconds'])
                if not text.strip(): raise RuntimeError('No timed words returned; review this file for silence or unsupported speech.')
                if args.sample_seconds:
                    sample_id = hashlib.sha256(relative.encode()).hexdigest()[:12]
                    output = STATE / 'samples' / f'{path.stem}-{sample_id}-{settings["backend"]}.srt'
                else:
                    output = path.with_suffix('.srt')
                # Detect an editor or another program creating a subtitle while inference ran.
                if output.exists() and not args.overwrite and not args.sample_seconds:
                    raise RuntimeError('Subtitle appeared during transcription; preserving it.')
                atomic_text(output, text)
                if not args.sample_seconds:
                    update(relative, signature, 'done', digest=hashlib.sha256(output.read_bytes()).hexdigest())
                completed += 1
                logging.info('Saved %s | audio %.1f min | processing %.1f min', output, result.duration/60, (time.monotonic()-file_start)/60)
                del result
        except KeyboardInterrupt:
            if not args.sample_seconds: update(relative, signature, 'interrupted', 'Rerun to retry this file')
            logging.warning('Stopped. Completed subtitles are safe; the current video will restart next time.')
            raise
        except Exception as error:
            failures += 1
            detail = str(error)
            if isinstance(error, subprocess.CalledProcessError): detail += '\n' + error.stderr.decode(errors='replace')
            if not args.sample_seconds: update(relative, signature, 'failed', detail)
            logging.exception('Failed: %s | %s', relative, detail)
            if 'out of memory' in detail.lower():
                logging.error('GPU memory exhausted; stopping the batch. Close GPU applications before retrying.')
                break
        finally:
            stop.set()
            thread.join()
            gc.collect()
            if settings['backend'] != 'ct2': torch.cuda.empty_cache()
    logging.info('Finished: completed=%d failed=%d elapsed=%.1f min', completed, failures, (time.monotonic()-started)/60)
    db.close()
    if failures: raise SystemExit(1)


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        raise SystemExit(130)
