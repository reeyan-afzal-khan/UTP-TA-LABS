"""Render one lecture plan with Manim Community (run as a subprocess by build.py).

    python -m utplectures.render.worker <plan.json>

Runs in its own process so each lecture starts from a clean Manim config, and
a crash in one lecture cannot take the others down.
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path


def _high_quality_encoding(crf: str, extra: dict | None = None) -> None:
    """Manim encodes its partial movies at x264 CRF 23, which bands flat colours and
    blurs small text. Ask for near-lossless frames tuned for animation instead
    (extra: more x264 options, e.g. {"x264-params": "..."})."""
    import av
    import manim.scene.scene_file_writer as sfw

    class _Container:
        def __init__(self, inner):
            self._inner = inner

        def add_stream(self, codec_name=None, rate=None, options=None, **kw):
            if codec_name == "libx264" and options is not None:
                options = {**options, "crf": crf, "preset": "medium", "tune": "animation", **(extra or {})}
            return self._inner.add_stream(codec_name, rate=rate, options=options, **kw)

        def __getattr__(self, name):
            return getattr(self._inner, name)

        def __enter__(self):
            return self

        def __exit__(self, *exc):
            return self._inner.__exit__(*exc)

    class _AV:
        def __getattr__(self, name):
            return getattr(av, name)

        def open(self, *args, **kwargs):
            container = av.open(*args, **kwargs)
            return _Container(container) if kwargs.get("mode", args[1] if len(args) > 1 else "r") == "w" else container

    sfw.av = _AV()


def main(plan_path: str) -> int:
    plan = json.loads(Path(plan_path).read_text(encoding="utf-8"))
    _high_quality_encoding(str(plan["video"].get("crf", 16)))
    from manim import config, tempconfig

    from .player import LectureScene
    from .text import register_fonts

    register_fonts(Path(plan["paths"]["fonts"]))
    out = plan["out"]
    video = plan["video"]
    media = Path(out["media_dir"])
    settings = {
        "pixel_width": int(video["width"]),
        "pixel_height": int(video["height"]),
        "frame_rate": int(video["fps"]),
        "media_dir": str(media),
        "video_dir": str(media / "video"),
        "partial_movie_dir": str(media / "partial"),
        "text_dir": str(Path(out["text_dir"])),
        "tex_dir": str(Path(out["tex_dir"])),
        "output_file": out["name"],
        "disable_caching": True,
        "write_to_movie": True,
        "format": "mp4",
        "verbosity": "WARNING",
        "progress_bar": "none",
        "background_color": plan["theme"].get("background", "#F7F9FA"),
    }
    if out.get("stills"):                       # layout check only: skip the animations, write no video
        settings.update({"write_to_movie": False, "save_last_frame": True})   # the Cairo renderer skips on this
    start = time.time()
    with tempconfig(settings):
        LectureScene.plan = plan
        scene = LectureScene()
        scene.render()
        movie = None if out.get("stills") else str(scene.renderer.file_writer.movie_file_path)
        duration = scene.renderer.time
    Path(out["result"]).write_text(json.dumps({"movie": movie, "duration": duration,
                                               "seconds": time.time() - start}), encoding="utf-8")
    print(f"[done] {movie} ({duration:.1f}s of video in {time.time() - start:.0f}s)", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
