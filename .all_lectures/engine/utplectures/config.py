"""Engine settings: config/engine.yaml, overridden per course by <course>/lectures.yaml."""

from __future__ import annotations

import copy
from pathlib import Path
from typing import Any

import yaml

from .paths import CONFIG, LECTURES


def _merge(base: dict, extra: dict) -> dict:
    out = copy.deepcopy(base)
    for key, value in (extra or {}).items():
        if isinstance(value, dict) and isinstance(out.get(key), dict):
            out[key] = _merge(out[key], value)
        else:
            out[key] = value
    return out


def _load(path: Path) -> dict:
    if not path.exists():
        return {}
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def load_settings(course_slug: str | None = None) -> dict[str, Any]:
    settings = _load(CONFIG / "engine.yaml")
    if course_slug:
        settings = _merge(settings, _load(LECTURES / course_slug / "lectures.yaml"))
    return settings


def load_pronunciations(course_slug: str | None = None) -> list[tuple[str, str]]:
    rules = list(_load(CONFIG / "pronunciations.yaml").get("rules", []))
    if course_slug:
        rules += _load(LECTURES / course_slug / "pronunciations.yaml").get("rules", [])
    return [(str(a), str(b)) for a, b in rules]
