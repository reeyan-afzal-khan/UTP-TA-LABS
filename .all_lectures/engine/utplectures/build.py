"""Build one lecture: script -> voice -> figures -> Manim render -> published video."""

from __future__ import annotations

import copy
import json
import subprocess
import sys
import time
from pathlib import Path

from .config import load_pronunciations, load_settings
from .courses import Lecture, find_course
from .export import edited_python, load_video_class, write_python
from .figures import figure_key, prepare_figures
from .paths import CACHE, ENGINE, FONTS, OVERRIDES, ROOT, cache_dir
from .publish import finish_video, write_srt
from .render.brand import logos
from .script import prepare_script
from .trace import Tracer
from .voice import cue_audio, display_text

KNOWN_TYPES = {"title", "outro", "section", "prose", "bullets", "callout", "guide", "code", "table", "figure", "math",
               "operations", "custom"}


def check_script(script: dict) -> list[str]:
    problems = []
    seen = set()
    for sc in script.get("scenes", []):
        if sc.get("type") not in KNOWN_TYPES:
            problems.append(f"scene {sc.get('id')}: unknown type {sc.get('type')!r}")
        if not sc.get("cues"):
            problems.append(f"scene {sc.get('id')}: no cues")
        for c in sc.get("cues", []):
            cid = str(c.get("id"))
            if cid in seen:
                problems.append(f"cue {cid}: id used twice")
            seen.add(cid)
            if not str(c.get("say", "")).strip():
                problems.append(f"cue {cid}: nothing to say")
    return problems


def make_plan(lec: Lecture, settings: dict, script: dict, figblocks: dict, voice_mode: str | None,
              draft: bool, stills: bool, log=print) -> dict:
    course = lec.course
    if voice_mode:
        settings = copy.deepcopy(settings)
        settings.setdefault("voice", {})["mode"] = voice_mode
    for sc in script["scenes"]:
        for c in sc["cues"]:
            c["id"] = str(c["id"]).zfill(3) if str(c["id"]).isdigit() else str(c["id"])
    rules = load_pronunciations(course.slug)
    audio = cue_audio(script, lec, settings, rules, log)

    fig_scenes = [s for s in script["scenes"] if s["type"] == "figure"]
    blocks = {}
    for s in fig_scenes:
        fb = figblocks.get(s.get("figure") or "") or figblocks.get(s.get("label") or "")
        if fb is not None:
            blocks[figure_key(course, fb)] = fb
    compiled = prepare_figures(course, list(blocks.values()), log) if blocks else {}
    figures = {}
    for s in fig_scenes:
        fb = figblocks.get(s.get("figure") or "") or figblocks.get(s.get("label") or "")
        info = compiled.get(figure_key(course, fb), {}) if fb is not None else {
            "error": "this figure is no longer in the LaTeX"}
        figures[s.get("figure") or s.get("label") or ""] = info
        if s.get("label"):
            figures[s["label"]] = info

    boxes = {name: {"back": b.back, "frame": b.frame, "title_back": b.title_back, "title_color": b.title_color}
             for name, b in course.styles.boxes.items()}
    scenes = copy.deepcopy(script["scenes"])
    tracer = Tracer()                       # run the listings again, in order, as the script now has them
    for sc in scenes:
        for c in sc["cues"]:
            c["audio"] = audio[c["id"]].to_json()
            c["display"] = display_text(c["say"])
        if sc["type"] == "code":
            sc["trace"] = tracer.trace(sc.get("language"), sc.get("code", ""))

    video = dict(settings["video"])
    if draft:
        video.update(settings["video"].get("draft", {"width": 960, "height": 540, "fps": 30}))
    video.pop("draft", None)
    work = cache_dir("render", course.slug, lec.folder, lec.stem + ("-draft" if draft else ""))
    try:
        logo_paths = logos()
    except (OSError, ValueError):
        logo_paths = {}
    return {
        "lecture": {**script["lecture"], "course": course.slug},
        "theme": settings["theme"],
        "pacing": settings["pacing"],
        "video": video,
        "boxes": boxes,
        "figures": figures,
        "scenes": scenes,
        "paths": {"fonts": str(FONTS), "overrides": str(OVERRIDES), "logos": logo_paths},
        "out": {
            "media_dir": str(work / "media"),
            "text_dir": str(cache_dir("text")),
            "tex_dir": str(cache_dir("tex")),
            "name": lec.stem,
            "timeline": str(work / "timeline.json"),
            "result": str(work / "result.json"),
            "stills": str(work / "stills") if stills else None,
        },
    }


def render(plan: dict, log=print) -> dict:
    work = Path(plan["out"]["result"]).parent
    plan_path = work / "plan.json"
    plan_path.write_text(json.dumps(plan, indent=1), encoding="utf-8")
    Path(plan["out"]["result"]).unlink(missing_ok=True)
    stills = plan["out"].get("stills")
    if stills:
        for f in Path(stills).glob("*.png"):
            f.unlink()
    cmd = [sys.executable, "-u", "-m", "utplectures.render.worker", str(plan_path)]
    proc = subprocess.Popen(cmd, cwd=ENGINE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                            encoding="utf-8", errors="replace")
    tail: list[str] = []
    n_scenes = len(plan["scenes"])
    for line in proc.stdout:
        line = line.rstrip()
        tail = (tail + [line])[-40:]
        if line.startswith("[scene]"):
            done = line.split()[1]
            print(f"\r  rendering scene {done} ", end="", flush=True)
        elif line.startswith("[done]"):
            print()
    proc.wait()
    if proc.returncode != 0 or not Path(plan["out"]["result"]).exists():
        print()
        log("\n".join(tail))
        raise RuntimeError(f"render failed (exit {proc.returncode})")
    return json.loads(Path(plan["out"]["result"]).read_text(encoding="utf-8"))


def build_lecture(lec: Lecture, *, draft: bool = False, stills: bool = False, rescript: bool = False,
                  voice: str | None = None, log=print) -> Path:
    """From the LaTeX (or your edited script). Also writes the video's Manim code, <name>.py; once you
    have edited that file, it is what gets built (until --rescript)."""
    log(f"{lec.course.code} {lec.label}: {lec.rel}")
    settings = load_settings(lec.course.slug)
    script, figblocks = prepare_script(lec, settings, rescript=rescript, log=log)
    py = None if rescript else edited_python(lec)
    if py is not None:
        log(f"  using your edited {py.name}")
        return build_from_python(load_video_class(py), py, draft=draft, stills=stills, voice=voice, log=log,
                                 settings=settings, figblocks=figblocks, meta=script["lecture"])
    if rescript and lec.video.with_suffix(".py").exists():
        lec.video.with_suffix(".py").unlink()
    write_python(script, lec, log)
    return _build(lec, settings, script, figblocks, draft=draft, stills=stills, voice=voice, log=log)


def lecture_of(cls) -> Lecture:
    """The lecture a Lecture subclass (a video's .py) was made from."""
    course = find_course(cls.course)
    if course is None:
        raise SystemExit(f"unknown course {cls.course!r}")
    for lec in course.lectures:
        if lec.source.relative_to(course.folder).as_posix() == cls.source.replace("\\", "/"):
            return lec
    raise SystemExit(f"{cls.source!r} is not a chapter or lab of {course.folder.name}")


def build_from_python(cls, path, *, draft: bool = False, stills: bool = False, only: list[str] | None = None,
                      voice: str | None = None, log=print, settings: dict | None = None,
                      figblocks: dict | None = None, meta: dict | None = None) -> Path:
    """Build a video from its Manim code file (a kit.Lecture subclass): `python <name>.py` lands here."""
    lec = lecture_of(cls)
    if settings is None:
        log(f"{lec.course.code} {lec.label}: {Path(path).name}")
        settings = load_settings(lec.course.slug)
    if figblocks is None or meta is None:                 # figures and titles still come from the LaTeX
        from .script import ScriptBuilder
        builder = ScriptBuilder(lec, settings)
        fresh = builder.build()
        figblocks = dict(builder.figures)
        figblocks.update({f.label: f for f in builder.figures.values() if f.label})
        meta = fresh["lecture"]
    scenes = cls().scenes()
    if only:
        wanted = set(only)
        missing = wanted - {s["id"] for s in scenes}
        if missing:
            raise SystemExit(f"no scene {', '.join(sorted(missing))} in {Path(path).name}")
        scenes = [s for s in scenes if s["id"] in wanted]
    script = {"lecture": meta, "scenes": scenes}
    return _build(lec, settings, script, figblocks, draft=draft, stills=stills, voice=voice, log=log,
                  module=str(Path(path).resolve()), tag="-only" if only else "")


def _build(lec: Lecture, settings: dict, script: dict, figblocks: dict, *, draft: bool, stills: bool,
           voice: str | None, log, module: str | None = None, tag: str = "") -> Path:
    t0 = time.time()
    problems = check_script(script)
    if problems:
        raise SystemExit("the script has problems:\n  " + "\n  ".join(problems))
    plan = make_plan(lec, settings, script, figblocks, voice, draft, stills, log)
    if module:
        plan["module"] = {"path": module}
    if tag:
        plan["out"]["name"] = lec.stem + tag
    n_cues = sum(len(s["cues"]) for s in plan["scenes"])
    speech = sum(c["audio"]["duration"] for s in plan["scenes"] for c in s["cues"])
    log(f"  {len(plan['scenes'])} scenes, {n_cues} cues, {speech / 60:.1f} min of narration; "
        f"rendering {plan['video']['width']}x{plan['video']['height']} at {plan['video']['fps']} fps")
    result = render(plan, log)
    if stills:
        log(f"  stills of every cue: {plan['out']['stills']}")
        return Path(plan["out"]["stills"])
    raw = Path(result["movie"])
    timeline = json.loads(Path(plan["out"]["timeline"]).read_text(encoding="utf-8"))
    if draft:
        dest = cache_dir("drafts", lec.course.slug, lec.folder) / f"{plan['out']['name']}.mp4"
    else:
        dest = lec.video
    loud = float(settings.get("voice", {}).get("loudness_lufs", -16))
    finish_video(raw, dest, loud)
    write_srt(timeline, dest.with_suffix(".srt"))
    log(f"  -> {dest}  ({result['duration'] / 60:.1f} min, built in {(time.time() - t0) / 60:.1f} min)")
    return dest
