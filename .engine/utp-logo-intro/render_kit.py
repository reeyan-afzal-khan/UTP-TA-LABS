"""What the logo intro needs from a renderer: the right Python, the build cache, sharp frames and clean video.

Taken from the lecture engine (.engine/utplectures: bootstrap.py, paths.py, render/player.py,
render/worker.py, render/viz.py) so this folder renders on its own.
"""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent

# Everything rebuildable (the traced logo, Manim's frames) stays outside OneDrive.
CACHE = Path(os.environ.get("UTP_LECTURES_CACHE")
             or Path(os.environ.get("LOCALAPPDATA") or tempfile.gettempdir()) / "utp-lectures") / "logo-intro-white"


def cache_dir(*parts: str) -> Path:
    path = CACHE.joinpath(*parts)
    path.mkdir(parents=True, exist_ok=True)
    return path


# ------------------------------------------------------------------ the Python with Manim

def lecture_python() -> str | None:
    """The utp_lectures interpreter, wherever conda put it (UTP_LECTURES_PYTHON overrides)."""
    candidates = [os.environ.get("UTP_LECTURES_PYTHON")]
    for base in (Path.home() / ".conda" / "envs", Path(os.environ.get("CONDA_PREFIX", "")).parent / "envs",
                 Path("C:/ProgramData/anaconda3/envs"), Path.home() / "anaconda3" / "envs",
                 Path.home() / "miniconda3" / "envs"):
        candidates += [str(base / "utp_lectures" / "python.exe"), str(base / "utp_lectures" / "bin" / "python")]
    for exe in candidates:
        if exe and Path(exe).exists():
            return exe
    return None


def ensure_environment(script: str) -> None:
    """Return at once when Manim (and the tracing libraries) import; otherwise re-run the same file with
    the utp_lectures interpreter and exit with its result."""
    try:
        import fontTools  # noqa: F401
        import manim  # noqa: F401
        import potrace  # noqa: F401
        import scipy  # noqa: F401
        return
    except ImportError:
        pass
    exe = lecture_python()
    if exe and Path(exe).resolve() != Path(sys.executable).resolve():
        sys.exit(subprocess.call([exe, str(script), *sys.argv[1:]]))
    sys.exit("Manim Community is not installed for this Python. See .engine/README.md (Setup).")


# ------------------------------------------------------------------ sharp frames, clean video

def best_antialias() -> None:
    """Draw every shape with Cairo's best antialiasing (16x16 samples per pixel edge) instead of its
    default: thin gold lines and small type stay smooth, also while they move and scale."""
    import cairo
    from manim.camera.camera import Camera
    if getattr(Camera, "_utp_best", False):
        return
    plain = Camera.get_cairo_context

    def get_cairo_context(self, pixel_array):
        ctx = plain(self, pixel_array)
        ctx.set_antialias(cairo.ANTIALIAS_BEST)
        return ctx
    Camera.get_cairo_context = get_cairo_context
    Camera._utp_best = True


def high_quality_encoding(crf: str, extra: dict | None = None) -> None:
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


def within(anim, start: float, end: float):
    """The same animation, played between `start` and `end` (0..1) of its play."""
    from manim.mobject.mobject import _AnimationBuilder
    if start <= 0 and end >= 1:
        return anim
    if isinstance(anim, _AnimationBuilder):              # mob.animate...: make the real animation first
        anim = anim.build()
    rf = anim.rate_func
    anim.rate_func = lambda t, rf=rf, a=start, b=end: rf(min(1.0, max(0.0, (t - a) / (b - a))))
    return anim
