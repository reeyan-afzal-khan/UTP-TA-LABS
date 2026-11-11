"""Environment diagnostics, pinned model download, and media inventory."""
import argparse
import csv
import json
import subprocess
import sqlite3
import shutil
from collections import Counter
from importlib.metadata import version
from pathlib import Path
from common import MEDIA, RUNTIME, STATE, atomic_text, config, discover


def check():
    import imageio_ffmpeg
    from crisperwhisper import CrisperWhisperModel
    if config()['backend'] == 'ct2':
        import ctranslate2
        print('CTranslate2 fork:', version('ctranslate2-crisperwhisper'))
        print('CUDA GPU count:', ctranslate2.get_cuda_device_count())
        if ctranslate2.get_cuda_device_count() < 1: raise RuntimeError('No CUDA device in CT2')
        print('Supported CUDA compute types:', ctranslate2.get_supported_compute_types('cuda'))
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-version'], check=True, stdout=subprocess.DEVNULL)
        print('FFmpeg: OK | CT2 CUDA inference does not need PyTorch.')
        print('Model prepared:', (RUNTIME / 'model.json').exists())
        return
    import torch
    print('Torch:', torch.__version__, '| CUDA runtime:', torch.version.cuda, flush=True)
    if not torch.cuda.is_available():
        raise RuntimeError('CUDA is unavailable. Check the NVIDIA driver and run step 01 again. CPU fallback is disabled.')
    result = (torch.ones((64, 64), device='cuda') @ torch.ones((64, 64), device='cuda')).sum().item()
    assert result == 262144
    print('GPU:', torch.cuda.get_device_name(0))
    print('VRAM GiB:', round(torch.cuda.get_device_properties(0).total_memory / 2**30, 2))
    print('CrisperWhisper:', version('crisperwhisper'))
    print('Transformers:', version('transformers'))
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-version'], check=True, stdout=subprocess.DEVNULL)
    print('Bundled FFmpeg: OK | GPU tensor operation: OK')
    print('Model downloaded:', (RUNTIME / 'model.json').exists())


def download():
    from huggingface_hub import HfApi, snapshot_download
    from filelock import FileLock
    settings = config()
    if settings['backend'] == 'ct2':
        exported = STATE / 'ct2-export.json'
        if not exported.exists(): raise RuntimeError('Run the Windows WSL step03-prepare-model.bat to convert the model first.')
        metadata = json.loads(exported.read_text())
        if metadata['revision'] != settings['revision'] or metadata['compute_type'] != settings['compute_type']:
            raise RuntimeError('Converted model does not match settings; rerun Windows WSL step03.')
        source = Path(subprocess.check_output(['wslpath', '-u', metadata['path']], text=True).strip())
        destination = RUNTIME / 'ct2' / (metadata['revision'] + '-' + settings['compute_type'])
        with FileLock(str(RUNTIME / 'model-download.lock'), timeout=0):
            current_record = RUNTIME / 'model.json'
            if current_record.exists() and (destination / 'model.bin').is_file():
                current = json.loads(current_record.read_text())
                if current.get('path') == str(destination) and (destination / 'model.bin').stat().st_size == (source / 'model.bin').stat().st_size:
                    print('Reusing prepared CTranslate2 model:', destination)
                    return
            print('Copying converted model into Linux storage...', flush=True)
            shutil.copytree(source, destination, dirs_exist_ok=True)
            atomic_text(RUNTIME / 'model.json', json.dumps({**metadata, 'path': str(destination)}, indent=2)+'\n')
        print('CTranslate2 model ready:', destination)
        return
    with FileLock(str(RUNTIME / 'model-download.lock'), timeout=0):
        record = RUNTIME / 'model.json'
        existing = json.loads(record.read_text()) if record.exists() else {}
        revision = existing.get('revision') if existing.get('model') == settings['model'] else None
        revision = settings.get('revision') or revision or HfApi().model_info(settings['model']).sha
        path = snapshot_download(settings['model'], revision=revision,
                                 allow_patterns=['*.json', '*.safetensors', '*.txt', '*.model', '*.md'])
        atomic_text(record, json.dumps({'model': settings['model'], 'revision': revision,
                                       'path': path}, indent=2) + '\n')
        print('Pinned model snapshot:', path)


def inventory(folder):
    files = discover(folder)
    counts = Counter(str(p.relative_to(MEDIA).parts[0]) if len(p.relative_to(MEDIA).parts)>1 else '(root audio)' for p in files)
    report = STATE / 'inventory.csv'
    with report.open('w', newline='', encoding='utf-8-sig') as stream:
        writer = csv.writer(stream)
        writer.writerow(['media', 'size_bytes', 'subtitle', 'subtitle_exists'])
        for p in files:
            writer.writerow([p.relative_to(MEDIA), p.stat().st_size, p.with_suffix('.srt').relative_to(MEDIA), p.with_suffix('.srt').exists()])
    for name, count in sorted(counts.items()):
        print(f'{name}: {count} files')
    print(f'Total: {len(files)} | Existing subtitles: {sum(p.with_suffix(".srt").exists() for p in files)}')
    print('Inventory:', report)


def status():
    path = STATE / 'progress.sqlite3'
    if not path.exists():
        print('No transcription runs yet. Run step 04 to inventory the media.')
        return
    with sqlite3.connect(path) as db:
        states = list(db.execute('SELECT status,COUNT(*) FROM jobs GROUP BY status'))
        if not states:
            print('No full-video jobs recorded yet. Sample-only and dry runs do not mark videos complete.')
            return
        for state, count in states:
            print(f'{state}: {count}')
        for media, state, error in db.execute("SELECT media,status,error FROM jobs WHERE status != 'done'"):
            print(f'{state}: {media} | {error[:300]}')
    print('A running entry can be a live job or a previously interrupted process. Rerunning retries incomplete files.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['check', 'download', 'inventory', 'status'])
    parser.add_argument('--folder', default='')
    args = parser.parse_args()
    if args.action == 'check': check()
    elif args.action == 'download': download()
    elif args.action == 'status': status()
    else: inventory(args.folder)
