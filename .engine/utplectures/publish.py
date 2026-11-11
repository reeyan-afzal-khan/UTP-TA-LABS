"""Finish a rendered lecture: normalised audio, subtitles, and the lecture index."""

from __future__ import annotations

import json
import re
import shutil
import subprocess
from pathlib import Path

from .typst.inline import split_sentences_plain
from .paths import LECTURES

MAX_LINE = 42


# ---------------------------------------------------------------- subtitles

def _chunks(sentence: str, limit: int = 2 * MAX_LINE) -> list[str]:
    if len(sentence) <= limit:
        return [sentence]
    words = sentence.split()
    out, cur = [], ""
    for w in words:
        if cur and len(cur) + 1 + len(w) > limit:
            out.append(cur)
            cur = w
        else:
            cur = f"{cur} {w}".strip()
        # prefer to break after a clause once the chunk is reasonably long
        if len(cur) > limit * 0.55 and re.search(r"[,;:]$", cur):
            out.append(cur)
            cur = ""
    if cur:
        out.append(cur)
    return out


def _two_lines(text: str) -> str:
    if len(text) <= MAX_LINE:
        return text
    words = text.split()
    best, best_diff = text, 10 ** 6
    for k in range(1, len(words)):
        a, b = " ".join(words[:k]), " ".join(words[k:])
        diff = abs(len(a) - len(b))
        if len(a) <= MAX_LINE + 6 and diff < best_diff:
            best, best_diff = a + "\n" + b, diff
    return best


def _stamp(t: float) -> str:
    t = max(0.0, t)
    ms = int(round(t * 1000))
    h, ms = divmod(ms, 3600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def write_srt(timeline: list[dict], path: Path) -> None:
    entries = []
    for cue in timeline:
        text = re.sub(r"\s+", " ", cue["say"]).strip()
        start, dur = float(cue["start"]), float(cue["duration"])
        sentences = split_sentences_plain(text) or [text]
        starts = list(cue.get("sentences") or [])
        if len(starts) != len(sentences):                 # fall back to an even pace
            total = max(1, sum(len(s) for s in sentences))
            acc, starts = 0, []
            for s in sentences:
                starts.append(dur * acc / total)
                acc += len(s)
        bounds = starts + [dur]
        for k, sentence in enumerate(sentences):
            s0, s1 = bounds[k], max(bounds[k] + 0.4, bounds[k + 1])
            pieces = _chunks(sentence)
            total = max(1, sum(len(p) for p in pieces))
            acc = 0
            for p in pieces:
                a = s0 + (s1 - s0) * acc / total
                acc += len(p)
                b = s0 + (s1 - s0) * acc / total
                entries.append((start + a, start + b, _two_lines(p)))
    lines = []
    for n, (a, b, text) in enumerate(entries, 1):
        lines += [str(n), f"{_stamp(a)} --> {_stamp(b - 0.02)}", text, ""]
    path.write_text("\n".join(lines), encoding="utf-8")


# --------------------------------------------------------------------- video

def has_audio(path: Path) -> bool:
    out = subprocess.run(["ffprobe", "-v", "error", "-select_streams", "a", "-show_entries", "stream=index",
                          "-of", "csv=p=0", str(path)], capture_output=True, text=True)
    return bool(out.stdout.strip())


def finish_video(raw: Path, dest: Path, loudness: float = -16.0) -> None:
    """Normalise the narration loudness and make the file stream-friendly."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(".part.mp4")
    cmd = ["ffmpeg", "-y", "-v", "error", "-i", str(raw), "-c:v", "copy"]
    if has_audio(raw):
        cmd += ["-af", f"loudnorm=I={loudness}:TP=-1.5:LRA=11", "-c:a", "aac", "-b:a", "160k", "-ar", "48000"]
    cmd += ["-movflags", "+faststart", str(tmp)]
    subprocess.run(cmd, check=True)
    tmp.replace(dest)


def probe_duration(path: Path) -> float:
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True)
    try:
        return float(out.stdout.strip())
    except ValueError:
        return 0.0


# --------------------------------------------------------------------- index

INDEX_START = "<!-- lectures:start -->"
INDEX_END = "<!-- lectures:end -->"


def update_index(courses) -> None:
    """Refresh the table of published lectures in .all_lectures/README.md."""
    readme = LECTURES / "README.md"
    if not readme.exists():
        return
    rows = []
    for course in courses:
        for lec in course.lectures:
            if not lec.video.exists():
                continue
            d = probe_duration(lec.video)
            rel = lec.video.relative_to(LECTURES).as_posix()
            script = lec.script_path.relative_to(LECTURES).as_posix()
            srt = lec.video.with_suffix(".srt")
            subs = f" · [subtitles](<{srt.relative_to(LECTURES).as_posix()}>)" if srt.exists() else ""
            rows.append(f"| {course.code} | {lec.label} | {lec_title(lec)} | [{lec.stem}.mp4](<{rel}>) | "
                        f"{int(d // 60)}:{int(d % 60):02d} | [script](<{script}>){subs} |")
    table = ["| Course | Lecture | Title | Video | Length | Edit |", "| --- | --- | --- | --- | --- | --- |"]
    body = "\n".join(table + rows) if rows else "_No lectures rendered yet._"
    text = readme.read_text(encoding="utf-8")
    if INDEX_START in text and INDEX_END in text:
        head, rest = text.split(INDEX_START, 1)
        _, tail = rest.split(INDEX_END, 1)
        text = head + INDEX_START + "\n" + body + "\n" + INDEX_END + tail
        readme.write_text(text, encoding="utf-8")


def lec_title(lec) -> str:
    from .typst.inline import InlineContext, parse_inline, runs_to_plain
    return runs_to_plain(parse_inline(lec.title, InlineContext())).replace("|", "/")


def clean_dir(path: Path) -> None:
    shutil.rmtree(path, ignore_errors=True)
