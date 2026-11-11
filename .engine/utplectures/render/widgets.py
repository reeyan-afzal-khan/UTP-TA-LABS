"""The visual pieces of a lecture, on black in UTP blue and gold.

Sizes are Manim units on a 14.22 x 8 frame (1920 x 1080 at 135 px per unit).
"""

from __future__ import annotations

import math
import re
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np
from manim import (DOWN, LEFT, ORIGIN, RIGHT, UP, Code, Dot, ImageMobject, Line, Rectangle,
                   RoundedRectangle, SVGMobject, VGroup, VMobject)
from pygments.style import Style
from pygments.token import (Comment, Error, Generic, Keyword, Name, Number, Operator, Punctuation, String,
                            Text, Token)

from .text import line_height, make_text, plain_markup, resolve_font

FRAME_W = 14.222
FRAME_H = 8.0
LEFT_X = -6.6
RIGHT_X = 6.6
CONTENT_W = RIGHT_X - LEFT_X
BODY_TOP = 2.75
BODY_BOTTOM = -3.3
BODY_H = BODY_TOP - BODY_BOTTOM
BODY_CENTER = np.array([0.0, (BODY_TOP + BODY_BOTTOM) / 2, 0.0])


def mix(c1: str, c2: str, t: float) -> str:
    """t of c1 and 1-t of c2."""
    a = [int(c1.lstrip("#")[k:k + 2], 16) for k in (0, 2, 4)]
    b = [int(c2.lstrip("#")[k:k + 2], 16) for k in (0, 2, 4)]
    return "#" + "".join(f"{round(t * x + (1 - t) * y):02X}" for x, y in zip(a, b))


@dataclass
class Theme:
    colors: dict
    font: str
    mono: str
    sizes: dict
    boxes: dict = field(default_factory=dict)

    @classmethod
    def from_settings(cls, theme: dict, boxes: dict) -> "Theme":
        colors = {k: v for k, v in theme.items() if isinstance(v, str) and v.startswith("#")}
        defaults = {"background": "#000000", "ink": "#F2F5F9", "muted": "#8B97A8", "faint": "#2A3342",
                    "panel": "#0A1220", "blue": "#4C9BEA", "gold": "#F0A818", "utp_blue": "#004A8C",
                    "teal": "#3CC4B4", "green": "#6FD08C", "red": "#FF6B6B", "orange": "#FF9F43",
                    "purple": "#B39DFF", "code_bg": "#05080E", "white": "#FFFFFF"}
        for k, v in defaults.items():
            colors.setdefault(k, v)
        colors["line"] = colors["faint"]
        return cls(colors, resolve_font(theme.get("font", "Source Sans 3")), theme.get("mono", "Source Code Pro"),
                   dict(theme.get("sizes", {})), boxes)

    def c(self, key: str) -> str:
        return self.colors.get(key, key)

    def size(self, key: str, default: float = 30) -> float:
        return float(self.sizes.get(key, default))

    def text(self, markup: str, size: str | float = "body", color: str = "ink", width: float | None = None,
             align: str = "left", mono: bool = False, spacing: float | None = None, weight: str = "NORMAL"):
        s = self.size(size) if isinstance(size, str) else size
        return make_text(markup, font=self.mono if mono else self.font, size=s, color=self.c(color), width=width,
                         align=align, spacing=spacing, weight=weight)

    def plain(self, text: str, **kw):
        return self.text(plain_markup(text), **kw)

    def accent(self, box_name: str | None) -> str:
        """The screen colour of a book box (keyidea teal, pitfall red ...)."""
        box = self.boxes.get(box_name or "", {})
        return dark_color(box.get("title_back") or box.get("frame") or "#246B9E")


# ------------------------------------------------------------- dark colours

def _lin(c: float) -> float:
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _gamma(c: float) -> float:
    c = max(0.0, min(1.0, c))
    return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055


def hex_to_oklab(h: str) -> tuple[float, float, float]:
    h = h.lstrip("#")
    r, g, b = (_lin(int(h[k:k + 2], 16) / 255) for k in (0, 2, 4))
    l_ = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m_ = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s_ = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    return (0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
            1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
            0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_)


def oklab_to_hex(L: float, a: float, b: float) -> str:
    l_ = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m_ = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s_ = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = 4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_
    g = -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_
    bl = -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_
    return "#" + "".join(f"{round(_gamma(x) * 255):02X}" for x in (r, g, bl))


def _hue(hex_color: str) -> float:
    _, a, b = hex_to_oklab(hex_color)
    return math.degrees(math.atan2(b, a)) % 360


GOLD_HUE = _hue("#F0A818")
BLUE_HUE = _hue("#4C9BEA")


def dark_color(hex_color: str) -> str:
    """A colour drawn for paper, redrawn for black in the UTP palette: light becomes
    dark and dark light, blues become UTP blue, teals UTP gold, signal colours stay."""
    try:
        L, a, b = hex_to_oklab(hex_color)
    except (ValueError, IndexError):
        return hex_color
    C = math.hypot(a, b)
    h = math.degrees(math.atan2(b, a)) % 360
    L2 = 0.07 + 0.9 * (1 - L)
    if C < 0.035:                                     # greys and pale tints: invert, keep a hint of hue
        return oklab_to_hex(L2, a * 0.8, b * 0.8)
    if L < 0.8:
        L2 = max(L2, 0.68)                            # lines and text in colour must read on black
    if 215 <= h <= 300:
        h2 = BLUE_HUE
    elif 165 <= h < 215:
        h2 = GOLD_HUE
    else:
        h2 = h
    C2 = min(0.19, C * 1.2) if L < 0.8 else C
    return oklab_to_hex(L2, C2 * math.cos(math.radians(h2)), C2 * math.sin(math.radians(h2)))


def recolor_dark(mob) -> None:
    for sub in mob.family_members_with_points():
        try:
            sub.set_fill(color=dark_color(sub.get_fill_color().to_hex()), opacity=sub.get_fill_opacity())
            sub.set_stroke(color=dark_color(sub.get_stroke_color().to_hex()), opacity=sub.get_stroke_opacity())
        except Exception:
            continue


# ------------------------------------------------------------------- chrome

def header(theme: Theme, kicker: str, section: str) -> VGroup:
    k = theme.plain(kicker.upper(), size="kicker", color="gold", weight="SEMIBOLD")
    k.move_to([LEFT_X, 3.68, 0], aligned_edge=LEFT)
    parts = [k]
    if section:
        t = theme.plain(section, size="header", color="muted", width=CONTENT_W - 2.0)
        if t.width > CONTENT_W - 2.0:
            t.scale_to_fit_width(CONTENT_W - 2.0)
        t.next_to(k, DOWN, buff=0.12, aligned_edge=LEFT)
        parts.append(t)
    return VGroup(*parts)


class Progress(VGroup):
    def __init__(self, theme: Theme, marks: list[float]):
        y = -3.78
        self.track = Line([LEFT_X, y, 0], [RIGHT_X, y, 0], stroke_color=theme.c("faint"), stroke_width=3)
        self.fill = Line([LEFT_X, y, 0], [LEFT_X + 0.001, y, 0], stroke_color=theme.c("gold"), stroke_width=3)
        ticks = VGroup(*[Dot([LEFT_X + CONTENT_W * f, y, 0], radius=0.03, color=theme.c("muted"))
                         for f in marks if 0.01 < f < 0.99])
        super().__init__(self.track, ticks, self.fill)

    def at(self, fraction: float) -> Line:
        y = self.track.get_start()[1]
        x = LEFT_X + CONTENT_W * max(0.0005, min(1.0, fraction))
        return Line([LEFT_X, y, 0], [x, y, 0], stroke_color=self.fill.get_stroke_color(), stroke_width=3)


def title_chip(theme: Theme, title_markup: str, color: str) -> VGroup:
    """A box's name as a small coloured label: KEY IDEA, TRY IT YOURSELF ..."""
    from .text import strip_markup
    label = theme.plain(strip_markup(title_markup).upper(), size=20, color=color, weight="SEMIBOLD", width=11.5)
    bar = Rectangle(width=0.08, height=label.height + 0.16, fill_color=color, fill_opacity=1, stroke_width=0)
    bar.next_to(label, LEFT, buff=0.2)
    return VGroup(bar, label)


def frame_tag(theme: Theme, frame: dict) -> VGroup:
    """The box a scene sits inside (e.g. the lab project), top left of the body."""
    tag = title_chip(theme, frame.get("title", ""), theme.accent(frame.get("box")))
    tag.move_to([LEFT_X + 0.1, BODY_TOP - 0.05, 0], aligned_edge=UP + LEFT)
    return tag


# ------------------------------------------------------------- key words

def headline(theme: Theme, markup: str, width: float = CONTENT_W - 1.2):
    words = len(re.sub(r"<[^>]*>", "", markup).split())
    size = theme.size("headline", 46) * (1.0 if words <= 14 else 0.82 if words <= 26 else 0.7)
    return theme.text(markup, size=size, color="ink", width=width, align="center", spacing=1.05)


def chip(theme: Theme, text: str, color: str, size: float | None = None) -> VGroup:
    t = theme.plain(text, size=size or theme.size("chip", 36), color="ink")
    box = RoundedRectangle(width=t.width + 0.6, height=t.height + 0.42, corner_radius=0.2,
                           fill_color=theme.c("panel"), fill_opacity=1, stroke_color=color, stroke_width=2.5)
    t.move_to(box)
    g = VGroup(box, t)
    g.box, g.label = box, t
    return g


def chip_rows(theme: Theme, items: list[str], width: float = CONTENT_W - 0.6) -> VGroup:
    colors = [theme.c("gold"), theme.c("blue")]
    chips = [chip(theme, it, colors[k % 2]) for k, it in enumerate(items)]
    rows, row, w = [], [], 0.0
    for c in chips:
        if row and w + c.width + 0.35 > width:
            rows.append(row)
            row, w = [], 0.0
        row.append(c)
        w += c.width + 0.35
    if row:
        rows.append(row)
    lines = [VGroup(*r).arrange(RIGHT, buff=0.35) for r in rows]
    group = VGroup(*lines).arrange(DOWN, buff=0.35)
    group.chips = chips
    return group


# ---------------------------------------------------------------- lists

def bullet_row(theme: Theme, item: dict, width: float, size: str | float = "body", number: int | None = None):
    """One list item: a marker and wrapped text (or a term and its meaning)."""
    style = item.get("style") or ("number" if number else "dot")
    depth = int(item.get("depth", 0) or 0)
    indent = 0.55 * depth
    s = theme.size(size) if isinstance(size, str) else size
    lh = line_height(theme.font, s)
    if style == "term" and item.get("term"):
        term_w = 3.2
        term = theme.text(item["term"], size=s, color="gold", weight="SEMIBOLD", width=term_w)
        if term.width > term_w:
            term.scale_to_fit_width(term_w)
        text = theme.text(item.get("text", ""), size=s, color="ink", width=width - term_w - 0.5 - indent)
        term.move_to(ORIGIN, aligned_edge=UP + LEFT)
        text.move_to([term_w + 0.45, 0, 0], aligned_edge=UP + LEFT)
        row = VGroup(term, text)
        row.marker, row.body = term, text
        return row
    text = theme.text(item.get("text", ""), size=s, color="ink", width=width - 0.6 - indent)
    if style == "number":
        n = item.get("mark") or str(number or 1)
        marker = theme.plain(str(n).rstrip("."), size=s * 0.8, color="gold", weight="SEMIBOLD")
    elif style == "check":
        marker = check_mark(theme.c("gold"), 0.26)
    else:
        marker = Dot(radius=0.06 if depth == 0 else 0.045, color=theme.c("gold") if depth == 0 else theme.c("muted"))
    text.move_to(ORIGIN, aligned_edge=UP + LEFT).shift(RIGHT * (0.6 + indent))
    marker.move_to([0.22 + indent, text.get_top()[1] - lh / 2 - 0.02, 0])
    row = VGroup(marker, text)
    row.marker, row.body = marker, text
    return row


def check_mark(color: str, size: float = 0.3, width: float = 5) -> VMobject:
    return VMobject(stroke_color=color, stroke_width=width).set_points_as_corners(
        [[-0.5 * size, 0.0, 0], [-0.15 * size, -0.35 * size, 0], [0.5 * size, 0.4 * size, 0]])


def cross_mark(color: str, size: float = 0.28, width: float = 5) -> VGroup:
    a = Line([-size / 2, -size / 2, 0], [size / 2, size / 2, 0], stroke_color=color, stroke_width=width)
    b = Line([-size / 2, size / 2, 0], [size / 2, -size / 2, 0], stroke_color=color, stroke_width=width)
    return VGroup(a, b)


def fit(mob, max_w: float, max_h: float, min_scale: float = 0.55):
    s = min(1.0, max_w / max(mob.width, 1e-6), max_h / max(mob.height, 1e-6))
    if s < 1.0:
        mob.scale(max(s, min_scale))
    return mob


# --------------------------------------------------------------------- code

def dark_code_style(theme: Theme):
    c = theme.colors

    class DarkStyle(Style):
        background_color = c["code_bg"]
        line_number_color = mix(c["muted"], c["code_bg"], 0.55)
        styles = {
            Token: c["ink"], Text: c["ink"], Error: c["red"],
            Keyword: "#6FB3FF", Keyword.Type: c["gold"], Keyword.Constant: c["orange"],
            Name: c["ink"], Name.Function: "#7FE0D0", Name.Class: c["gold"], Name.Builtin: "#6FB3FF",
            Name.Namespace: c["muted"], Name.Decorator: c["purple"],
            Comment: c["muted"], Comment.Preproc: c["purple"], Comment.PreprocFile: "#9BE38E",
            String: "#9BE38E", String.Char: "#9BE38E", Number: c["orange"],
            Operator: "#C9D3DE", Punctuation: "#C9D3DE", Generic: c["ink"],
        }
    return DarkStyle


class CodePanel(VGroup):
    """A listing in a dark editor card, with a moving line highlight."""

    def __init__(self, theme: Theme, code: str, language: str, first_line: int = 1, label: str | None = None,
                 size: float | None = None):
        super().__init__()
        self.theme = theme
        self.first_line = first_line
        lang = language if language not in ("text", "") else "text"
        cfg = {"font": theme.mono, "font_size": size or theme.size("code", 26), "line_spacing": 0.6,
               "warn_missing_font": False}
        bg = {"fill_color": theme.c("code_bg"), "stroke_width": 0, "buff": 0.34, "corner_radius": 0.12}
        try:
            self.code = Code(code_string=code, language=lang, formatter_style=dark_code_style(theme),
                             add_line_numbers=True, line_numbers_from=first_line, background="rectangle",
                             background_config=bg, paragraph_config=cfg)
        except Exception:
            self.code = Code(code_string=code, language="text", formatter_style=dark_code_style(theme),
                             add_line_numbers=True, line_numbers_from=first_line, background="rectangle",
                             background_config=bg, paragraph_config=cfg)
        back = self.code.background
        w = max(back.width, 5.0)
        bar_h = 0.4
        chrome = RoundedRectangle(width=w, height=back.height + bar_h, corner_radius=0.14,
                                  fill_color=theme.c("code_bg"), fill_opacity=1, stroke_color=theme.c("faint"),
                                  stroke_width=2)
        chrome.move_to(back.get_center() + UP * bar_h / 2)
        dots = VGroup(*[Dot(radius=0.05, color=col) for col in (theme.c("red"), theme.c("gold"), theme.c("green"))])
        dots.arrange(RIGHT, buff=0.11).move_to(chrome.get_top() + DOWN * bar_h / 2).align_to(chrome, LEFT)
        dots.shift(RIGHT * 0.28)
        rule = Line(chrome.get_corner(UP + LEFT) + DOWN * bar_h, chrome.get_corner(UP + RIGHT) + DOWN * bar_h,
                    stroke_color=theme.c("faint"), stroke_width=1.5)
        parts = [chrome, rule, dots]
        if label:
            tag = theme.plain(label, size=16, color="muted", weight="SEMIBOLD")
            tag.move_to(dots).align_to(chrome, RIGHT).shift(LEFT * 0.28)
            parts.append(tag)
        self.chrome = VGroup(*parts)
        self.highlight = Rectangle(width=w - 0.1, height=0.1, fill_color=theme.c("gold"), fill_opacity=0.0,
                                   stroke_width=0).move_to(back)
        self.cursor = Rectangle(width=0.07, height=0.1, fill_color=theme.c("gold"), fill_opacity=0.0,
                                stroke_width=0).move_to(back.get_left())
        self.add(self.chrome, self.highlight, self.cursor, self.code)

    def lines(self):
        return list(self.code.code_lines)

    def numbers(self):
        return list(getattr(self.code, "line_numbers", []))

    def line_span(self, a: int, b: int) -> tuple[float, float]:
        nums = self.numbers()
        ia = max(0, min(len(nums) - 1, a - self.first_line))
        ib = max(0, min(len(nums) - 1, b - self.first_line))
        return nums[ia].get_top()[1], nums[ib].get_bottom()[1]

    def highlight_target(self, a: int, b: int) -> tuple[Rectangle, Rectangle]:
        top, bottom = self.line_span(a, b)
        pad = 0.08
        h = (top - bottom) + 2 * pad
        y = (top + bottom) / 2
        band = Rectangle(width=self.highlight.width, height=h, fill_color=self.theme.c("gold"), fill_opacity=0.13,
                         stroke_width=0).move_to([self.code.background.get_center()[0], y, 0])
        cur = Rectangle(width=0.07, height=h, fill_color=self.theme.c("gold"), fill_opacity=1,
                        stroke_width=0).move_to([band.get_left()[0] + 0.035, y, 0])
        return band, cur

    def dim_targets(self, a: int | None, b: int | None, low: float = 0.38) -> list:
        out = []
        nums = self.numbers()
        for k, line in enumerate(self.lines()):
            n = self.first_line + k
            inside = a is None or a <= n <= b
            out.append((line, 1.0 if inside else low))
            if k < len(nums):
                out.append((nums[k], 1.0 if inside else low))
        return out


# -------------------------------------------------------------------- table

class TablePanel(VGroup):
    def __init__(self, theme: Theme, columns: list[dict], header: list[list[str]], rows: list[list[str]],
                 width: float = CONTENT_W - 0.4, size: float | None = None):
        super().__init__()
        size = size or theme.size("table", 26)
        ncols = max([len(columns)] + [len(r) for r in header + rows])
        fixed = [c.get("width") for c in columns] + [None] * (ncols - len(columns))
        used = sum(f for f in fixed if f)
        free = [i for i, f in enumerate(fixed) if not f]
        rest = max(0.12, 1.0 - used)
        widths = [(f if f else rest / max(1, len(free))) for f in fixed]
        scale = 1.0 / sum(widths)
        widths = [w * scale * width for w in widths]
        pad_x, pad_y = 0.24, 0.16
        self.widths = widths

        def cell(markup: str, col: int, head: bool):
            spec = columns[col] if col < len(columns) else {}
            color = "gold" if head else ("ink" if not spec.get("bold") else "blue")
            weight = "SEMIBOLD" if head or spec.get("bold") else "NORMAL"
            return theme.text(markup or " ", size=size, color=color, width=widths[col] - 2 * pad_x, weight=weight)

        def make_row(cells: list[str], head: bool):
            texts = [cell(cells[i] if i < len(cells) else "", i, head) for i in range(ncols)]
            h = max(t.height for t in texts) + 2 * pad_y
            x = 0.0
            bgs, placed = [], []
            for i, t in enumerate(texts):
                bg = Rectangle(width=widths[i], height=h, stroke_width=0, fill_opacity=0)
                bg.move_to([x + widths[i] / 2, -h / 2, 0])
                t.move_to(bg.get_corner(UP + LEFT) + RIGHT * pad_x + DOWN * pad_y, aligned_edge=UP + LEFT)
                bgs.append(bg)
                placed.append(t)
                x += widths[i]
            row = VGroup(VGroup(*bgs), VGroup(*placed))
            row.height_ = h
            return row

        self.header_rows = [make_row(r, True) for r in header]
        self.body_rows = [make_row(r, False) for r in rows]
        y = 0.0
        for r in self.header_rows + self.body_rows:
            r.shift(UP * y)
            y -= r.height_
        total_h = -y
        self.outline = RoundedRectangle(width=width, height=total_h, corner_radius=0.12, fill_opacity=0,
                                        stroke_color=theme.c("faint"), stroke_width=2)
        self.outline.move_to([width / 2, -total_h / 2, 0])
        self.rules = VGroup()
        yy = 0.0
        for k, r in enumerate(self.header_rows + self.body_rows[:-1]):
            yy -= r.height_
            heavy = k == len(self.header_rows) - 1
            self.rules.add(Line([0, yy, 0], [width, yy, 0], stroke_color=theme.c("gold") if heavy else theme.c("faint"),
                                stroke_width=2 if heavy else 1.2))
        self.backing = RoundedRectangle(width=width, height=total_h, corner_radius=0.12,
                                        fill_color=theme.c("panel"), fill_opacity=1,
                                        stroke_width=0).move_to(self.outline)
        self.add(self.backing, *self.header_rows, *self.body_rows, self.rules, self.outline)

    def row_box(self, k: int, theme: Theme) -> RoundedRectangle:
        bg = self.body_rows[k][0]
        box = RoundedRectangle(width=self.outline.width - 0.08, height=bg.height - 0.06, corner_radius=0.08,
                               fill_opacity=0, stroke_color=theme.c("gold"), stroke_width=3)
        box.move_to(bg.get_center()).set_x(self.outline.get_center()[0])
        return box


# ------------------------------------------------------------------- figures

def load_svg(path: str, max_w: float, max_h: float, max_units_per_pt: float = 0.03, dark: bool = True) -> VMobject:
    """A figure from the book, scaled to fit, with print line widths, redrawn for black."""
    text = Path(path).read_text(encoding="utf-8", errors="replace")
    m = re.search(r'viewBox="([\d.\-\s]+)"', text)
    vb_h = float(m.group(1).split()[3]) if m else None
    mob = SVGMobject(path, height=None, width=None, use_svg_cache=True, stroke_width=None)
    mob.scale_to_fit_height(max_h)
    if mob.width > max_w:
        mob.scale_to_fit_width(max_w)
    if vb_h and mob.height / vb_h > max_units_per_pt:
        mob.scale(max_units_per_pt * vb_h / mob.height)
    if vb_h:
        factor = mob.height / vb_h * 100                 # Cairo draws a stroke of width 1 as 0.01 units
        for sub in mob.family_members_with_points():
            w = sub.get_stroke_width()
            if w and w > 0:
                sub.set_stroke(width=w * factor * 1.1)
    if dark:
        recolor_dark(mob)
    return mob


def load_image(path: str, max_w: float, max_h: float) -> ImageMobject:
    img = ImageMobject(path)
    img.scale_to_fit_height(max_h)
    if img.width > max_w:
        img.scale_to_fit_width(max_w)
    return img


def math_typst(theme: Theme, markup: str, size: float = 46, color: str = "ink"):
    try:
        from ..figures import math_svg
        result = SVGMobject(str(math_svg(markup, theme.c(color).to_hex())))
        result.scale_to_fit_height(size / 45)
        return result
    except Exception:
        from ..typst.inline import math_to_markup
        return theme.text(math_to_markup(markup), size=size * 0.75, color=color)
