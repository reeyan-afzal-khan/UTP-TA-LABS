"""The UTP ident: the logo drawing itself on black, at the start of every lecture video.

    1  the oval's boundary is drawn, then the blue fades in inside it
    2  the gold flows up through the engraved lines from their feet: the exact artwork is revealed
       up to a flow front (distance along the lines, precomputed in brand.py), so the lines are
       always their final width, both halves flow in step, and a small light rides each front
    3  the wordmark tracks in (letters glide together from wider spacing) while the gold rules
       grow from the centre outwards, and a soft light sweeps across the emblem

Review it on its own in seconds:  python .all_lectures/engine/logo_intro.py
Every timing is a constant below: fractions of a phase, and phase lengths in seconds.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

import numpy as np
from manim import (LEFT, UP, WHITE, Dot, ManimColor, UpdateFromAlphaFunc, VGroup, VMobject,
                   interpolate_color, linear, rate_functions)

from .brand import UTP_GOLD, split_layers

# phase 1+2: the emblem ------------------------------------------------------------------
EMBLEM_SECONDS = 2.0
OUTLINE = (0.00, 0.23)         # the oval's boundary is drawn, from the top, clockwise (fraction of the phase)
OUTLINE_COLOR = "#5B9BE0"      # ... in a lighter UTP blue, so it shows on black, then settles into the fill
OUTLINE_WIDTH = 4.0
FILL = (0.197, 0.362)          # then the blue fades in inside it, and the boundary melts into it
LINES = (0.362, 0.956)         # then the gold flows up the lines, from their feet to the pinnacles
TIP_GLOW = 0.9                 # the light riding each flow front (0 = none)

# phase 3: the wordmark ----------------------------------------------------------------
WORD_SECONDS = 1.1
TRACK = 0.32                   # letters start this much further apart (0.32 = 32% wider)
WORD_LINE = 0.55               # each line of the wordmark takes this fraction of the phase ...
WORD_STAGGER = 0.12            # ... and starts this much after the line above
RULES = (0.10, 0.62)           # the gold rules grow from the centre
SHINE = (0.40, 1.00)           # the light sweeps across the emblem
SHINE_OPACITY = 0.20
SHINE_SLICES = 16              # the band is drawn in slices, brightest in the middle: a soft edge
SHINE_ANGLE = 62               # degrees from horizontal
HOLD_SECONDS = 0.7             # the finished logo, still, before the title arrives

# the standalone intro (logo_intro.py) ends instead on the logo alone, then fades away
OUTRO_HOLD = 1.0               # the finished logo, still
OUTRO_FADE = 1.6               # ... then a slow fade to the background
OUTRO_BLANK = 1.0              # ... and the empty background, held before the video ends

ease_out = rate_functions.ease_out_cubic


def _window(alpha: float, a: float, b: float) -> float:
    return min(1.0, max(0.0, (alpha - a) / max(b - a, 1e-6)))


def _ellipse_points(c, rx: float, ry: float, n: int = 160) -> np.ndarray:
    a = np.linspace(0, 2 * math.pi, n, endpoint=False)
    return np.stack([c[0] + rx * np.cos(a), c[1] + ry * np.sin(a), np.zeros(n)], axis=1)


def _clip(poly: np.ndarray, normal: np.ndarray, offset: float, keep_below: bool) -> np.ndarray:
    """Sutherland-Hodgman: the part of a polygon on one side of the line normal . p = offset."""
    out = []
    n = len(poly)
    for k in range(n):
        p, q = poly[k], poly[(k + 1) % n]
        dp, dq = normal @ p[:2] - offset, normal @ q[:2] - offset
        inside_p, inside_q = (dp <= 0) if keep_below else (dp >= 0), (dq <= 0) if keep_below else (dq >= 0)
        if inside_p:
            out.append(p)
        if inside_p != inside_q:
            out.append(p + (q - p) * (dp / (dp - dq)))
    return np.array(out) if out else np.zeros((0, 3))


def steps(logo, meta_path: str | None, parts: dict | None = None) -> list[tuple[list, float]]:
    """The ident as [(animations, seconds), ...] for a logo already placed where it should be drawn."""
    parts = parts or split_layers(logo)
    meta = json.loads(Path(meta_path).read_text(encoding="utf-8")) if meta_path and Path(meta_path).exists() else None
    if meta is None or not meta.get("lines"):
        from .brand import intro
        return intro(logo, parts)
    k = logo.width / meta["width"]                             # SVG units -> scene units (the frame spans the SVG)
    origin = logo.get_corner(UP + LEFT)

    def P(xy):
        a = np.asarray(xy, dtype=float)
        return np.column_stack([origin[0] + a[:, 0] * k, origin[1] - a[:, 1] * k, np.zeros(len(a))])

    ecx, ecy, erx, ery = meta["ellipse"]
    centre = P([[ecx, ecy]])[0]
    rx, ry = erx * k, ery * k
    flow = meta.get("flow")
    if not flow:
        from .brand import intro
        return intro(logo, parts)

    # ---------------------------------------------------------------- the emblem
    oval = parts["oval"]
    blue = oval[0].get_fill_color() if len(oval) else "#0B4F94"
    edge = oval[0].copy() if len(oval) else VMobject()
    edge.set_fill(opacity=0).set_stroke(color=OUTLINE_COLOR, width=OUTLINE_WIDTH, opacity=1)
    boundary = edge.copy()

    def fill_in(mob, alpha):                                   # the blue, once the boundary is there
        mob.set_fill(opacity=rate_functions.ease_in_out_sine(_window(alpha, *FILL)))

    def outline(mob, alpha):                                   # the boundary, drawn from the top
        u = rate_functions.ease_in_out_sine(_window(alpha, *OUTLINE))
        mob.pointwise_become_partial(edge, 0, max(u, 1e-4))
        v = _window(alpha, *FILL)                              # ... then it takes the blue and melts away
        mob.set_stroke(color=interpolate_color(ManimColor(OUTLINE_COLOR), ManimColor(blue), min(1.0, 2 * v)),
                       width=OUTLINE_WIDTH, opacity=1.0 if u > 0 else 0.0)
        if v > 0.5:
            mob.set_stroke(opacity=max(0.0, 1 - (v - 0.5) / 0.5))

    # the gold, revealed level by level: the exact artwork cut by each level of the flow
    gold = parts["lines"]
    artwork = gold[0] if len(gold) == 1 else VMobject().append_points(
        np.concatenate([m.points for m in gold.family_members_with_points()]))
    from manim.mobject.svg.svg_mobject import VMobjectFromSVGPath
    import svgelements as se

    def to_scene(m):
        pts = m.points.copy()
        m.points = np.column_stack([origin[0] + pts[:, 0] * k, origin[1] - pts[:, 1] * k, np.zeros(len(pts))])
        return m

    levels = flow["levels"]
    cuts: dict[int, VMobject] = {}

    def cut(j: int) -> VMobject:                               # the gold reached so far (traced in brand.py)
        if j not in cuts:
            cuts[j] = to_scene(VMobjectFromSVGPath(se.Path(levels[j])))
        return cuts[j]

    flowing = VMobject(fill_color=artwork.get_fill_color(), fill_opacity=1, stroke_width=0)
    line_w = meta.get("line_width", 80) * k
    tips = VGroup(*[VGroup(Dot(radius=line_w * 1.2, color="#FFD27A", fill_opacity=0),
                           Dot(radius=line_w * 0.5, color="#FFF4D6", fill_opacity=0)) for _ in range(24)])
    drawing = VGroup(flowing, tips)
    fronts = [P(f) if f else np.zeros((0, 3)) for f in flow["fronts"]]

    def pour(mob, alpha):
        t = _window(alpha, *LINES)
        j = int(round(rate_functions.ease_in_out_sine(t) * len(levels))) - 1
        if j < 0 or t >= 1:
            flowing.set_points(np.zeros((0, 3)))
        else:
            flowing.set_points(cut(j).points)
        glow = TIP_GLOW * min(1.0, t / 0.05, max(0.0, (1 - t) / 0.1)) if 0 < t < 1 else 0.0
        here = fronts[j] if 0 <= j < len(fronts) else np.zeros((0, 3))
        for n, tip in enumerate(tips):
            if n < len(here) and glow > 0:
                tip.move_to(here[n])
                tip[0].set_fill(opacity=0.16 * glow)
                tip[1].set_fill(opacity=0.85 * glow)
            else:
                tip[0].set_fill(opacity=0)
                tip[1].set_fill(opacity=0)

    # The finished gold takes the geometry of the flow's last stage, so the moment the flow hands over
    # to it nothing on screen changes (the artwork traced for print differs by a hair: a visible jolt).
    if len(gold):
        gold[0].set_points(cut(len(levels) - 1).points)
        for extra in list(gold)[1:]:
            extra.set_points(np.zeros((0, 3)))

    def finish(mob, alpha):                                    # the finished gold, once the flow is complete
        mob.set_fill(opacity=1.0 if alpha >= LINES[1] else 0.0)

    # (linear: each part eases inside its own window)
    emblem = [UpdateFromAlphaFunc(oval, fill_in, rate_func=linear),
              UpdateFromAlphaFunc(boundary, outline, rate_func=linear, remover=True),
              UpdateFromAlphaFunc(drawing, pour, rate_func=linear, remover=True),
              UpdateFromAlphaFunc(gold, finish, rate_func=linear)]

    # ---------------------------------------------------------------- the wordmark
    letters = list(parts["word"])
    rows: list[list] = []
    for letter in sorted(letters, key=lambda m: -m.get_center()[1]):
        if rows and abs(rows[-1][0].get_center()[1] - letter.get_center()[1]) < letter.height * 0.5:
            rows[-1].append(letter)
        else:
            rows.append([letter])
    plan = []
    for r, row in enumerate(rows):
        cx = sum(m.get_center()[0] for m in row) / len(row)
        a = WORD_STAGGER * r
        for m in row:
            end = m.get_center().copy()
            start = end.copy()
            start[0] = cx + (end[0] - cx) * (1 + TRACK)
            plan.append((m, start, end, a))

    def track(mob, alpha):
        for m, start, end, a in plan:
            u = ease_out(_window(alpha, a, a + WORD_LINE))
            m.move_to(start + (end - start) * u)
            m.set_fill(opacity=u)

    # the layer groups themselves are animated (the title card moves the same groups afterwards)
    word = [UpdateFromAlphaFunc(parts["word"], track, rate_func=linear)] if letters else []
    if len(parts["rules"]):
        word.append(_grow_from_centre(parts["rules"]))

    # the light: a soft band, clipped to the oval, sweeping across the emblem
    ellipse = _ellipse_points(centre, rx, ry)
    th = math.radians(SHINE_ANGLE)
    normal = np.array([math.cos(th), math.sin(th)])
    reach = abs(normal[0]) * rx + abs(normal[1]) * ry
    band = 0.8 * min(rx, ry)
    shine = VGroup(*[VMobject(fill_color=WHITE, fill_opacity=0, stroke_width=0) for _ in range(SHINE_SLICES)])

    def sweep(mob, alpha):
        u = rate_functions.ease_in_out_sine(_window(alpha, *SHINE))
        mid = normal @ centre[:2] - reach - band + (2 * reach + 2 * band) * u
        n = len(shine)
        for j, part in enumerate(shine):
            o0, o1 = mid + band * (j / n - 0.5), mid + band * ((j + 1) / n - 0.5)
            poly = _clip(_clip(ellipse, normal, o0, keep_below=False), normal, o1, keep_below=True)
            if len(poly) < 3 or not 0 < u < 1:
                part.set_points(np.zeros((0, 3)))
                continue
            part.set_points_as_corners(np.vstack([poly, poly[:1]]))
            part.set_fill(WHITE, opacity=SHINE_OPACITY * math.sin(math.pi * (j + 0.5) / n) ** 2)

    word.append(UpdateFromAlphaFunc(shine, sweep, rate_func=linear, remover=True))
    out = [(emblem, EMBLEM_SECONDS)]
    if word:
        out.append((word, WORD_SECONDS))
    out.append(([], HOLD_SECONDS))
    return out


def fade_out(color: str):
    """The whole frame fading to `color`: a full-frame cover whose opacity rises (inside a one-shot play
    it is added after everything else, so it sits on top, and fighting no other animation's opacity)."""
    from manim import Rectangle, config
    cover = Rectangle(width=config.frame_width + 0.2, height=config.frame_height + 0.2, fill_color=color,
                      fill_opacity=0, stroke_width=0)

    def fade(m, alpha):
        m.set_fill(opacity=rate_functions.ease_in_out_sine(alpha))
    return UpdateFromAlphaFunc(cover, fade, rate_func=linear)


def fade_up(mob):
    """A fade-in that keeps its place at the bottom of the drawing order inside a one-shot play
    (FadeIn adds its mobject on top of everything animated with it)."""
    def fade(m, alpha):
        m.set_fill(opacity=rate_functions.smooth(alpha))
    return UpdateFromAlphaFunc(mob, fade, rate_func=linear)


def as_one_shot(parts_list: list[tuple[list, float]]) -> list[tuple[list, float]]:
    """The phases as one continuous animation (one play): Manim writes every play as its own video
    segment, and the encoder restarts at each one, so a seam (a slight jolt in flat colours) would show
    where a phase ends and the still hold begins. Same timing, no seams."""
    from .viz import within
    total = sum(seconds for _, seconds in parts_list)
    if total <= 0:
        return parts_list
    anims, t = [], 0.0
    for group, seconds in parts_list:
        anims += [within(a, t / total, (t + seconds) / total) for a in group]
        t += seconds
    return [(anims, total)]


def _grow_from_centre(rules):
    """The gold rules drawn from their middles outwards (thin bars: their width grows, not their height)."""
    targets = [(r, r.copy(), r.get_center()) for r in rules]

    def grow(mob, alpha):
        u = ease_out(_window(alpha, *RULES))
        for r, target, c in targets:
            r.become(target.copy().stretch(max(u, 1e-3), 0, about_point=c))
            if u <= 0:
                r.set_fill(opacity=0)                          # not yet: not even a speck
    return UpdateFromAlphaFunc(rules, grow, rate_func=linear)
