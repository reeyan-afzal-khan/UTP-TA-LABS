"""Text for the lecture: the book's fonts, wrapped by Pango to an exact width."""

from __future__ import annotations

import hashlib
import html
import os
import re
import xml.etree.ElementTree as ET
from pathlib import Path

import manimpango
from manim import VGroup, config
from manim.mobject.text import text_mobject as tm
from manim.utils.color import ManimColor

_registered = False


def register_fonts(folder: Path) -> None:
    """Make the book's fonts available to Pango, once.

    On Windows, manimpango re-adds every registered font file to Pango's shared
    font map on *every* text it draws, which leaks ~400 MB per text (a lecture
    has hundreds). The shared map keeps the fonts once they are in it, so we
    draw one text to load them and then empty manimpango's list.
    """
    global _registered
    if _registered:
        return
    files = sorted(folder.glob("*.otf")) + sorted(folder.glob("*.ttf"))
    for f in files:
        manimpango.register_font(str(f))
    if files:
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            tm.MarkupUtils.text2svg("<b>Aa</b> <i>Aa</i> Aa", "Source Sans 3", "NORMAL", "NORMAL", 10, 0, True,
                                    str(Path(tmp) / "load.svg"), tm.START_X, tm.START_Y, 200, 100)
        manimpango.registered_fonts.clear()
    _registered = True


def resolve_font(choice) -> str:
    """The first installed face of a preference list ("Adobe Jenson Pro", then the next ...)."""
    names = [choice] if isinstance(choice, str) else [str(n) for n in choice]
    try:
        have = {f.lower() for f in manimpango.list_fonts()}
    except Exception:
        return names[-1]
    for n in names:
        if n.lower() in have:
            return n
    return names[-1]


PX = 1 / tm.TEXT_MOB_SCALE_FACTOR       # Pango pixels per Manim unit (20)


class WrapText(tm.MarkupText):
    """MarkupText that wraps at `width` Manim units (Manim's own wraps at a fixed width)."""

    def __init__(self, markup: str, width: float | None = None, align: str = "left",
                 spacing: float | None = None, **kwargs):
        self._wrap_px = int(width * PX) if width else None
        self._align = align
        self._spacing = spacing
        kwargs.setdefault("disable_ligatures", True)        # one glyph per character, so ranges line up
        kwargs.setdefault("warn_missing_font", False)
        try:
            super().__init__(markup, **kwargs)
        except ET.ParseError:
            # a cached SVG left half-written by an interrupted render: drop it and draw again
            for f in config.get_dir("text_dir").glob("*.svg"):
                try:
                    ET.parse(f)
                except ET.ParseError:
                    f.unlink(missing_ok=True)
            super().__init__(markup, **kwargs)

    def _text2hash(self, color) -> str:
        base = super()._text2hash(color)
        extra = f"{self._wrap_px}|{self._align}|{self._spacing}"
        return hashlib.sha256((base + extra).encode()).hexdigest()[:16]

    def _text2svg(self, color) -> str:
        color = ManimColor(color)
        size = self._font_size / tm.TEXT2SVG_ADJUSTMENT_FACTOR
        folder = config.get_dir("text_dir")
        folder.mkdir(parents=True, exist_ok=True)
        file_name = folder / (self._text2hash(color) + ".svg")
        if not file_name.exists():
            text = f'<span foreground="{color.to_hex()}">{self.text}</span>'
            width = (self._wrap_px or 4000) + 2 * tm.START_X + 40
            align = {"left": manimpango.Alignment.LEFT, "center": manimpango.Alignment.CENTER,
                     "right": manimpango.Alignment.RIGHT}[self._align]
            kwargs = dict(justify=False, pango_width=self._wrap_px, alignment=align)
            if self._spacing:
                kwargs["line_spacing"] = self._spacing
            tmp = file_name.with_name(f"{file_name.stem}.{os.getpid()}.tmp.svg")
            tm.MarkupUtils.text2svg(text, self.font, self.slant, self.weight, size, 0, self.disable_ligatures,
                                    str(tmp.resolve()), tm.START_X, tm.START_Y, width, 6000, **kwargs)
            os.replace(tmp, file_name)                     # never leave a half-written file in the cache
        return str(file_name.resolve())


def plain_markup(text: str) -> str:
    """Escape plain text for markup."""
    return html.escape(text or "", quote=False)


def strip_markup(markup: str) -> str:
    return html.unescape(re.sub(r"<[^>]*>", "", markup or ""))


def make_text(markup: str, *, font: str, size: float, color: str, width: float | None = None,
              align: str = "left", spacing: float | None = None, weight: str = "NORMAL") -> WrapText:
    """Wrapped text; if the markup is broken (say, after a hand edit) fall back to plain text."""
    try:
        return WrapText(markup or " ", width=width, align=align, spacing=spacing, font=font,
                        font_size=size, color=color, weight=weight)
    except Exception:
        return WrapText(plain_markup(strip_markup(markup)) or " ", width=width, align=align, spacing=spacing,
                        font=font, font_size=size, color=color, weight=weight)


def glyph_ranges(markups: list[str], total: int) -> list[tuple[int, int]] | None:
    """Glyph index ranges of consecutive pieces of one text, or None if they do not add up."""
    from ..typst.inline import count_glyphs
    counts = [count_glyphs(m) for m in markups]
    if sum(counts) != total:
        return None
    out, pos = [], 0
    for c in counts:
        out.append((pos, pos + c))
        pos += c
    return out


def line_height(font: str, size: float) -> float:
    ref = WrapText("Mg", font=font, font_size=size)
    return ref.height


def group(*mobs) -> VGroup:
    return VGroup(*[m for m in mobs if m is not None])
