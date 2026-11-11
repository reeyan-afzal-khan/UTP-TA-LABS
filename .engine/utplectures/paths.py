"""Where things live: the repository, the published lectures, and the build cache."""

from __future__ import annotations

import os
import sys
import tempfile
from pathlib import Path

ENGINE = Path(__file__).resolve().parents[1]
ROOT = ENGINE.parent
LECTURES = ROOT / '.all_lectures'
SHARED = ROOT / ".shared"
CONFIG = ENGINE / "config"
FONTS = ENGINE / "assets" / "fonts"
OVERRIDES = ENGINE / "overrides"

# Everything rebuildable (TTS audio, compiled figures, Manim's partial movies)
# stays outside the repository, as the PDF build does.
CACHE = Path(os.environ.get("UTP_LECTURES_CACHE")
             or Path(os.environ.get("LOCALAPPDATA") or tempfile.gettempdir()) / "utp-lectures")


def cache_dir(*parts: str) -> Path:
    path = CACHE.joinpath(*parts)
    path.mkdir(parents=True, exist_ok=True)
    return path


def python_exe() -> str:
    return sys.executable
