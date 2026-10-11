#!/usr/bin/env python3
"""UTP lecture engine: narrated Manim videos from the course LaTeX.

    python .all_lectures/engine/lecture.py list [COURSE]
    python .all_lectures/engine/lecture.py build ADS ch1 lab1          render and publish
    python .all_lectures/engine/lecture.py build ADS ch1 --draft       quick 540p30 preview, not published
    python .all_lectures/engine/lecture.py script ADS ch1              (re)write the editable script only
    python .all_lectures/engine/lecture.py voice-sheet ADS ch1         what to record for your own voice
    python .all_lectures/engine/lecture.py doctor                      check the tools are installed

COURSE is a code (ADS, AI, DCN, DS, ERP, FI, ML, OS), a folder name or a slug.
After a course, pick lectures with ch1, lab3, or a file name (01-introduction);
with none, every chapter and lab of the course is built. Several courses can
follow each other: build ADS ch1 lab1 OS lab2.

Videos go to .all_lectures/<course-slug>/<chapters|labs>/<file name>.mp4, with
a .srt and the editable <file name>.script.yaml beside them.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

ENGINE = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE))

try:
    sys.stdout.reconfigure(encoding="utf-8")       # Windows consoles: course titles contain · and —
except Exception:
    pass


def _ensure_environment() -> None:
    """Re-run under the utp_lectures environment if this Python lacks Manim."""
    try:
        import edge_tts  # noqa: F401
        import manim  # noqa: F401
        import yaml  # noqa: F401
        return
    except ImportError:
        pass
    candidates = [os.environ.get("UTP_LECTURES_PYTHON")]
    for base in (Path.home() / ".conda" / "envs", Path(os.environ.get("CONDA_PREFIX", "")).parent / "envs",
                 Path("C:/ProgramData/anaconda3/envs"), Path.home() / "anaconda3" / "envs",
                 Path.home() / "miniconda3" / "envs"):
        candidates += [str(base / "utp_lectures" / "python.exe"), str(base / "utp_lectures" / "bin" / "python")]
    for exe in candidates:
        if exe and Path(exe).exists() and Path(exe).resolve() != Path(sys.executable).resolve():
            sys.exit(subprocess.call([exe, __file__, *sys.argv[1:]]))
    sys.exit("Manim Community is not installed for this Python. See .all_lectures/engine/README.md (Setup).")


def select(tokens: list[str]):
    from utplectures.courses import all_courses, find_course
    chosen = []
    course = None
    picks: dict = {}
    order = []
    for tok in tokens:
        c = find_course(tok)
        if c is not None:
            course = c
            if c.slug not in picks:
                picks[c.slug] = []
                order.append(c)
            continue
        if course is None:
            sys.exit(f"'{tok}': name a course first (one of: {', '.join(x.code for x in all_courses())})")
        picks[course.slug].append(tok)
    if not order:
        order = all_courses()
    for c in order:
        sel = picks.get(c.slug, [])
        lectures = [l for l in c.lectures if not sel or any(l.matches(s) for s in sel)]
        for s in sel:
            if not any(l.matches(s) for l in c.lectures):
                sys.exit(f"{c.code}: no lecture matches '{s}' (try: lecture.py list {c.code})")
        chosen += lectures
    return chosen, order


def cmd_list(args) -> None:
    from utplectures.courses import all_courses, find_course
    courses = [find_course(args.course)] if args.course else all_courses()
    for c in courses:
        if c is None:
            sys.exit(f"unknown course {args.course}")
        print(f"{c.code:4} {c.title}  ->  .all_lectures/{c.slug}/")
        for l in c.lectures:
            mark = "video" if l.video.exists() else ("script" if l.script_path.exists() else "")
            print(f"      {l.label:<11} {l.rel:<45} {mark}")


def cmd_build(args) -> None:
    from utplectures.build import build_lecture
    from utplectures.publish import update_index
    lectures, courses = select(args.targets)
    failed = []
    for lec in lectures:
        try:
            build_lecture(lec, draft=args.draft, stills=args.stills, rescript=args.rescript, voice=args.voice)
        except Exception as exc:                    # keep going with the other lectures
            failed.append((lec, exc))
            print(f"  ! {lec.rel} failed: {exc}")
            if not args.keep_going:
                break
    if not (args.draft or args.stills):
        update_index(courses)
    if failed:
        sys.exit(1)


def cmd_script(args) -> None:
    from utplectures.config import load_settings
    from utplectures.script import prepare_script
    lectures, _ = select(args.targets)
    for lec in lectures:
        print(f"{lec.course.code} {lec.label}: {lec.rel}")
        prepare_script(lec, load_settings(lec.course.slug), rescript=args.rescript)


def cmd_voice_sheet(args) -> None:
    from utplectures.config import load_settings
    from utplectures.script import prepare_script
    from utplectures.voice import display_text
    lectures, _ = select(args.targets)
    for lec in lectures:
        script, _ = prepare_script(lec, load_settings(lec.course.slug), log=lambda *a: None)
        lec.voice_dir.mkdir(parents=True, exist_ok=True)
        lines = [f"# Recording sheet: {lec.course.title}, {lec.label}", "",
                 f"Record each cue as its own file in this folder, named by its number: `001.wav`, `002.wav`, ...",
                 "(.wav, .mp3, .m4a or .flac). Silence at either end is trimmed. Cues you have not recorded",
                 "keep the TTS voice, so you can record a few at a time. Rebuild the lecture to re-pace the",
                 "video to your timing:", "", "```bash",
                 f"python .all_lectures/engine/lecture.py build {lec.course.code} {lec.stem}", "```", ""]
        for sc in script["scenes"]:
            lines.append(f"## {sc['id']} · {sc['type']}" + (f" · {sc['section']}" if sc.get("section") else ""))
            lines.append("")
            for c in sc["cues"]:
                lines.append(f"**{c['id']}**  {display_text(c['say'])}")
                lines.append("")
        sheet = lec.voice_dir / "RECORDING-SHEET.md"
        sheet.write_text("\n".join(lines), encoding="utf-8")
        print(f"{lec.rel}: {sheet}")


def cmd_doctor(args) -> None:
    from utplectures.figures import has_tools
    missing = has_tools()
    import manim
    print(f"python  {sys.executable}")
    print(f"manim   {manim.__version__} (Manim Community)")
    print("tools   " + ("all found" if not missing else "missing: " + ", ".join(missing)))
    from utplectures.paths import CACHE
    print(f"cache   {CACHE}")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("list", help="list courses and lectures")
    s.add_argument("course", nargs="?")
    s.set_defaults(fn=cmd_list)
    s = sub.add_parser("build", help="render and publish lectures")
    s.add_argument("targets", nargs="*")
    s.add_argument("--draft", action="store_true", help="quick low-resolution preview in the cache, not published")
    s.add_argument("--stills", action="store_true",
                   help="layout check: save a full-size still at the end of every cue, render no video")
    s.add_argument("--rescript", action="store_true", help="regenerate the script from the LaTeX, dropping edits")
    s.add_argument("--voice", choices=["auto", "tts", "recorded"], help="override voice.mode")
    s.add_argument("--keep-going", action="store_true", help="continue with the next lecture after a failure")
    s.set_defaults(fn=cmd_build)
    s = sub.add_parser("script", help="write the editable lecture scripts only")
    s.add_argument("targets", nargs="*")
    s.add_argument("--rescript", action="store_true")
    s.set_defaults(fn=cmd_script)
    s = sub.add_parser("voice-sheet", help="write a recording sheet for your own narration")
    s.add_argument("targets", nargs="*")
    s.set_defaults(fn=cmd_voice_sheet)
    s = sub.add_parser("doctor", help="check the environment")
    s.set_defaults(fn=cmd_doctor)
    args = p.parse_args()
    _ensure_environment()
    args.fn(args)


if __name__ == "__main__":
    main()
