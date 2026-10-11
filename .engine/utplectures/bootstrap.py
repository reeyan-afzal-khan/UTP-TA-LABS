"""Run a lecture file under the Python that has Manim (the utp_lectures conda environment).

Imports nothing heavy, so a lecture's .py file can call it first with any Python:
it returns at once when Manim is importable, and otherwise re-runs the same file
with the utp_lectures interpreter and exits with its result.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


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
    try:
        import edge_tts  # noqa: F401
        import manim  # noqa: F401
        import yaml  # noqa: F401
        return
    except ImportError:
        pass
    exe = lecture_python()
    if exe and Path(exe).resolve() != Path(sys.executable).resolve():
        sys.exit(subprocess.call([exe, str(script), *sys.argv[1:]]))
    sys.exit("Manim Community is not installed for this Python. See .all_lectures/engine/README.md (Setup).")
