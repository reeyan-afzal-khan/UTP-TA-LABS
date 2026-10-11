"""Narration audio for every cue, and when each word is spoken.

Two sources, chosen per cue (settings voice.mode):

  tts       a neural TTS voice (edge-tts). Each cue's audio and its word
            timings are cached by text and voice, so a rebuild only
            synthesises cues whose wording changed.
  recorded  your own recording of the cue, a file named after the cue id in
            .all_lectures/<course>/voice/<chapters|labs>/<lecture>/  (001.wav ...).
            Silence at either end is trimmed and the scene is paced to it, so
            the animation follows your timing, not the TTS timing.

Animations never use fixed durations: every reveal is placed at a cue's start
or at a word inside it ([show]), so swapping the voice re-paces the video.
"""

from __future__ import annotations

import asyncio
import json
import re
import subprocess
from bisect import bisect_right
from dataclasses import dataclass, field
from pathlib import Path

from .latex.inline import split_sentences_plain
from .paths import cache_dir
from .script import SHOW, sha1

AUDIO_EXTS = (".wav", ".mp3", ".m4a", ".flac", ".ogg")


@dataclass
class CueAudio:
    id: str
    path: str
    duration: float
    text: str                                          # what the voice says (pronunciations applied)
    words: list[tuple[float, float, int]] = field(default_factory=list)  # (start, end, char offset in text)
    marks: list[float] = field(default_factory=list)   # times of the [show] markers
    sentences: list[float] = field(default_factory=list)  # start time of each spoken sentence
    source: str = "tts"

    def time_at(self, offset: int) -> float:
        """When the word at this character offset of `text` is spoken."""
        if self.words:
            k = bisect_right([w[2] for w in self.words], offset) - 1
            return self.words[k][0] if k >= 0 else 0.0
        # no word timings (a recording): assume an even speaking rate
        return self.duration * offset / max(1, len(self.text))

    def to_json(self) -> dict:
        return {"id": self.id, "path": self.path, "duration": round(self.duration, 3), "text": self.text,
                "marks": [round(t, 3) for t in self.marks], "sentences": [round(t, 3) for t in self.sentences],
                "source": self.source, "words": [[round(a, 3), round(b, 3), c] for a, b, c in self.words]}


# ------------------------------------------------------------------- text

def spoken_text(say: str, rules: list[tuple[str, str]]) -> tuple[str, list[int]]:
    """The text sent to the voice, and the character offsets of its [show] markers."""
    pieces = say.split(SHOW)
    out = ""
    marks: list[int] = []
    for k, piece in enumerate(pieces):
        piece = apply_rules(piece, rules)
        if k > 0:
            if out and not out.endswith(" "):
                out += " "
            marks.append(len(out))
        out += piece.lstrip() if k > 0 else piece
    text = re.sub(r"\s+", " ", out)
    # keep marks aligned after whitespace collapsing
    fixed = []
    for m in marks:
        fixed.append(len(re.sub(r"\s+", " ", out[:m])))
    return text.strip(), [min(f, len(text.strip())) for f in fixed]


def apply_rules(text: str, rules: list[tuple[str, str]]) -> str:
    for pattern, repl in rules:
        try:
            text = re.sub(pattern, repl, text)
        except re.error:
            text = text.replace(pattern, repl)
    return text


def display_text(say: str) -> str:
    """The cue as subtitles show it."""
    return re.sub(r"\s+", " ", say.replace(SHOW, " ")).strip()


# -------------------------------------------------------------------- TTS

def _ffprobe_duration(path: Path) -> float:
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                          str(path)], capture_output=True, text=True)
    try:
        return float(out.stdout.strip())
    except ValueError:
        return 0.0


async def _edge_stream(text: str, voice: str, rate: str, pitch: str) -> tuple[bytes, list]:
    import edge_tts
    comm = edge_tts.Communicate(text, voice, rate=rate, pitch=pitch, boundary="WordBoundary")
    audio = bytearray()
    words = []
    async for chunk in comm.stream():
        if chunk["type"] == "audio":
            audio.extend(chunk["data"])
        elif chunk["type"] == "WordBoundary":
            words.append([chunk["offset"] / 1e7, (chunk["offset"] + chunk["duration"]) / 1e7, chunk["text"]])
    if not audio:
        raise RuntimeError("no audio")
    return bytes(audio), words


async def _edge_retry(text: str, voice: str, rate: str, pitch: str, attempts: int) -> tuple[bytes, list]:
    last = None
    for attempt in range(attempts):
        try:
            return await _edge_stream(text, voice, rate, pitch)
        except Exception as exc:                        # network hiccups and the odd refused sentence
            last = exc
            await asyncio.sleep(1.0 + 1.5 * attempt)
    raise RuntimeError(str(last))


async def _edge_one(text: str, voice: str, rate: str, pitch: str, mp3: Path, meta: Path) -> None:
    try:
        audio, words = await _edge_retry(text, voice, rate, pitch, 4)
    except RuntimeError:
        # The service sometimes refuses one particular sentence. Say the cue a
        # sentence at a time and join the pieces, shifting their word timings.
        pieces = split_sentences_plain(text) or [text]
        if len(pieces) == 1:
            pieces = [p.strip() for p in re.split(r"(?<=[,;:])\s+", text) if p.strip()]
        audio, words, offset = b"", [], 0.0
        for piece in pieces:
            try:
                a, w = await _edge_retry(piece, voice, rate, pitch, 6)
            except RuntimeError as exc:
                raise RuntimeError(f"edge-tts could not say: {piece[:70]}... ({exc}). Reword this cue in the "
                                   f"script or add a pronunciation rule.") from exc
            part = mp3.with_suffix(".piece.mp3")
            part.write_bytes(a)
            dur = _ffprobe_duration(part)
            part.unlink(missing_ok=True)
            words += [[s + offset, e + offset, t] for s, e, t in w]
            audio += a
            offset += dur
    tmp = mp3.with_suffix(".part")
    tmp.write_bytes(audio)
    tmp.replace(mp3)
    meta.write_text(json.dumps({"text": text, "voice": voice, "rate": rate, "words": words}), encoding="utf-8")


def _align_words(text: str, words: list) -> list[tuple[float, float, int]]:
    """Attach each spoken word to its character offset in the text."""
    out = []
    pos = 0
    low = text.lower()
    for start, end, word in words:
        w = str(word).lower().strip()
        k = low.find(w, pos) if w else -1
        if k < 0 or k - pos > 40:
            k = pos
        out.append((float(start), float(end), k))
        pos = k + max(1, len(w))
    return out


def synthesize(jobs: list[tuple[str, str]], tts: dict, log=print) -> dict[str, tuple[Path, dict]]:
    """jobs: [(cue id, text)] -> {cue id: (mp3 path, meta)}; cached by text + voice settings."""
    voice = tts.get("voice", "en-US-AndrewMultilingualNeural")
    rate = str(tts.get("rate", "+0%"))
    pitch = str(tts.get("pitch", "+0Hz"))
    folder = cache_dir("tts", re.sub(r"[^\w-]", "_", voice))
    todo = []
    result: dict[str, tuple[Path, dict]] = {}
    for cid, text in jobs:
        key = sha1(f"{text}|{voice}|{rate}|{pitch}")
        mp3, meta = folder / f"{key}.mp3", folder / f"{key}.json"
        if not (mp3.exists() and meta.exists()):
            todo.append((text, mp3, meta))
        result[cid] = (mp3, meta)
    if todo:
        log(f"  synthesising {len(todo)} cue(s) with {voice}")
        limit = int(tts.get("parallel", 4))

        async def run_all():
            sem = asyncio.Semaphore(limit)

            async def one(t, m, j):
                async with sem:
                    await _edge_one(t, voice, rate, pitch, m, j)
            await asyncio.gather(*(one(t, m, j) for t, m, j in todo))
        asyncio.run(run_all())
    return {cid: (mp3, json.loads(meta.read_text(encoding="utf-8"))) for cid, (mp3, meta) in result.items()}


# -------------------------------------------------------------- recordings

def find_recording(folder: Path, cue_id: str) -> Path | None:
    for ext in AUDIO_EXTS:
        p = folder / f"{cue_id}{ext}"
        if p.exists():
            return p
    return None


def prepare_recording(path: Path, threshold_db: float) -> Path:
    """Trim silence at both ends and convert to 48 kHz mono WAV (cached)."""
    key = sha1(f"{path.resolve()}|{path.stat().st_mtime_ns}|{threshold_db}")
    out = cache_dir("recordings") / f"{key}.wav"
    if out.exists():
        return out
    trim = (f"silenceremove=start_periods=1:start_threshold={threshold_db}dB:start_silence=0.05,"
            f"areverse,silenceremove=start_periods=1:start_threshold={threshold_db}dB:start_silence=0.08,areverse")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(path), "-af", trim, "-ac", "1", "-ar", "48000",
                    str(out)], check=True)
    return out


# ------------------------------------------------------------------- cues

def cue_audio(script: dict, lecture, settings: dict, rules: list[tuple[str, str]],
              log=print) -> dict[str, CueAudio]:
    vcfg = settings.get("voice", {})
    mode = vcfg.get("mode", "auto")
    cues = [c for s in script["scenes"] for c in s["cues"]]
    texts = {c["id"]: spoken_text(c["say"], rules) for c in cues}

    recorded: dict[str, Path] = {}
    if mode in ("auto", "recorded"):
        for c in cues:
            rec = find_recording(lecture.voice_dir, c["id"])
            if rec:
                recorded[c["id"]] = rec
            elif mode == "recorded":
                raise SystemExit(f"no recording for cue {c['id']} in {lecture.voice_dir}")
    tts_jobs = [(cid, texts[cid][0]) for cid in texts if cid not in recorded]
    tts = synthesize(tts_jobs, vcfg.get("tts", {}), log) if tts_jobs else {}
    if recorded:
        log(f"  using {len(recorded)} recording(s) from {lecture.voice_dir}")

    out: dict[str, CueAudio] = {}
    for c in cues:
        cid = c["id"]
        text, mark_offsets = texts[cid]
        if cid in recorded:
            wav = prepare_recording(recorded[cid], float(vcfg.get("trim_silence_db", -45)))
            ca = CueAudio(cid, str(wav), _ffprobe_duration(wav), text, source="recorded")
        else:
            mp3, meta = tts[cid]
            ca = CueAudio(cid, str(mp3), _ffprobe_duration(mp3), text, _align_words(text, meta.get("words", [])))
        ca.marks = [ca.time_at(o) for o in mark_offsets]
        # sentence starts, for scenes that reveal sentence by sentence
        starts, pos = [], 0
        for sentence in split_sentences_plain(text):
            k = text.find(sentence[:12], pos)
            k = pos if k < 0 else k
            starts.append(ca.time_at(k))
            pos = k + len(sentence)
        ca.sentences = starts or [0.0]
        out[cid] = ca
    return out
