"""One template per scene type: what a scene looks like and how it builds up.

A template lays out its mobjects and exposes ordered steps. The player reveals
step 0 as the first cue starts, the next step as each later cue starts or at
each [show] inside a cue, and leftover steps at the end. Templates that need
finer timing (code that runs, operations being demonstrated) schedule their
own events inside each cue (manual = True, cue_events).

To add a scene type: subclass Template, register it in TEMPLATES, and have
script.py emit scenes of that type.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

from manim import (DOWN, LEFT, ORIGIN, RIGHT, UP, Create, FadeIn, FadeOut, Group, GrowFromCenter, ImageMobject,
                   LaggedStart, Line, Rectangle, Transform, VGroup, VMobject, Write)

from .opsdemo import ArrayDemo, ValueDemo
from .text import strip_markup
from .viz import MemoryPanel
from .widgets import (BODY_BOTTOM, BODY_TOP, CONTENT_W, FRAME_H, FRAME_W, LEFT_X, RIGHT_X, CodePanel, TablePanel,
                      Theme, bullet_row, chip_rows, fit, headline, load_image, load_svg, math_tex, title_chip)


def grow(mob, max_w: float, max_h: float, max_up: float = 1.3):
    """Scale to fit the space: down as far as needed, up by at most max_up."""
    s = min(max_w / max(mob.width, 1e-6), max_h / max(mob.height, 1e-6), max_up)
    mob.scale(s)
    return mob


def _vstack(mobs: list, buff: float):
    """Stack top to bottom, keeping each one's x position."""
    for k in range(1, len(mobs)):
        mobs[k].shift(UP * (mobs[k - 1].get_bottom()[1] - buff - mobs[k].get_top()[1]))
    return mobs


class Template:
    manual = False            # True: the template times its own reveals (cue_events only)
    full_frame = False        # True: draws over the header and progress bar
    reveal_time = 0.8         # preferred reveal duration

    def __init__(self, ctx, sc: dict):
        self.ctx = ctx
        self.theme: Theme = ctx.theme
        self.sc = sc
        self.steps: list = []
        self.top = BODY_TOP - (0.62 if sc.get("frame") else 0.0)
        self.build()

    def build(self) -> None:
        raise NotImplementedError

    @property
    def n_steps(self) -> int:
        return len(self.steps)

    def step(self, k: int) -> list:
        return self.steps[k]() if 0 <= k < len(self.steps) else []

    def cue_events(self, ci: int, cue: dict) -> list:
        return []

    def preroll(self) -> list:
        """[(animations, seconds)] played before the first cue's voice starts."""
        return []

    def finish(self) -> list:
        return []

    def pref_time(self, k: int) -> float:
        return self.reveal_time

    @property
    def mid_y(self) -> float:
        return (self.top + BODY_BOTTOM) / 2

    def place(self, group, max_w: float = CONTENT_W, min_scale: float = 0.62):
        fit(group, max_w, self.top - BODY_BOTTOM - 0.1, min_scale)
        group.move_to([group.get_center()[0], self.mid_y, 0])
        if group.get_top()[1] > self.top:
            group.shift(DOWN * (group.get_top()[1] - self.top))
        return group


# ------------------------------------------------------------- title, outro

class TitleTemplate(Template):
    full_frame = True
    reveal_time = 2.6

    def build(self):
        th = self.theme
        sc = self.sc
        cover = Rectangle(width=FRAME_W + 0.2, height=FRAME_H + 0.2, fill_color=th.c("background"), fill_opacity=1,
                          stroke_width=0)
        logo = self.ctx.logo("full", 3.4)
        x_text = -2.15
        width = RIGHT_X - x_text + 0.1
        texts = []
        if sc.get("kicker"):
            texts.append(th.plain(sc["kicker"].upper(), size=22, color="gold", weight="SEMIBOLD", width=width))
        if sc.get("label"):
            texts.append(th.plain(sc["label"], size=32, color="muted"))
        title = th.text(sc.get("title") or "", size=th.size("title", 64), color="ink", weight="BOLD",
                        width=width, spacing=1.0)
        texts.append(title)
        for t in texts:
            t.move_to([x_text, 0, 0], aligned_edge=LEFT)
        _vstack(texts, 0.28)
        g = VGroup(*texts)
        g.move_to([g.get_center()[0], 0.1, 0])
        rule = Line(UP, DOWN, stroke_color=th.c("gold"), stroke_width=4)
        rule.set_height(max(g.height + 0.4, 2.6)).move_to([x_text - 0.55, g.get_center()[1], 0])
        if logo is not None:
            logo.move_to([(LEFT_X + x_text - 0.55) / 2, g.get_center()[1], 0])
        self.texts, self.title_mob = texts, title
        self.logo, self.cover = logo, cover
        self.drawn = False                                   # the logo already drew itself (preroll)

        def reveal():
            from .viz import within
            anims = [] if self.drawn else [FadeIn(cover)]
            build = LaggedStart(*[Write(t) if t is title else FadeIn(t, shift=RIGHT * 0.3) for t in texts],
                                lag_ratio=0.35)
            if logo is not None and self.drawn:              # the big logo settles beside the title first,
                k = self.home_h / logo.height                # then the rule grows and the title is written
                c = logo.get_center()
                anims += [within(p.animate.scale(k, about_point=c).shift(self.home - c), 0.0, 0.45)
                          for p in self.layers]
                anims += [within(GrowFromCenter(rule), 0.3, 0.6), within(build, 0.4, 1.0)]
                return anims
            if logo is not None:
                anims.append(FadeIn(logo, scale=0.9))
            anims += [GrowFromCenter(rule), build]
            return anims
        self.steps = [reveal]

    def preroll(self) -> list:
        """The chapter opens on the UTP logo drawing itself at the centre of a black screen."""
        if self.logo is None or not isinstance(self.logo, VMobject):
            return []
        from . import ident
        from .brand import split_layers
        logo = self.logo
        self.home, self.home_h = logo.get_center().copy(), logo.height
        logo.scale_to_fit_height(4.6).move_to([0, 0.15, 0])
        parts = split_layers(logo)
        self.layers = [g for g in parts.values() if len(g)]   # the groups the intro puts on screen
        self.drawn = True
        return ident.as_one_shot([([ident.fade_up(self.cover)], 0.2)] + ident.steps(logo, self.ctx.logos.get("meta"), parts))


class OutroTemplate(TitleTemplate):
    def preroll(self) -> list:
        return []

    def build(self):
        sc = dict(self.sc)
        self.sc = {**sc, "kicker": "End of " + (sc.get("label") or ""), "label": "", "title": sc.get("title")}
        super().build()
        if sc.get("next"):
            th = self.theme
            nxt = th.text("Next  ·  " + sc["next"], size=28, color="blue", weight="SEMIBOLD", width=RIGHT_X + 2.0)
            nxt.next_to(self.texts[-1], DOWN, buff=0.6, aligned_edge=LEFT)
            base = self.steps[0]
            self.steps = [lambda: base() + [FadeIn(nxt, shift=UP * 0.15)]]


# ------------------------------------------------------------------- section

class SectionTemplate(Template):
    reveal_time = 1.2

    def build(self):
        th = self.theme
        sc = self.sc
        big = int(sc.get("level", 1) or 1) <= 1
        title = th.text(sc.get("title") or "", size=th.size("section", 52) if big else 42, color="ink",
                        weight="SEMIBOLD", width=8.8 if big else 9.6)
        line = Line(LEFT, RIGHT, stroke_color=th.c("gold"), stroke_width=4)
        line.set_width(min(title.width, 4.0)).next_to(title, DOWN, buff=0.28, aligned_edge=LEFT)
        block = VGroup(title, line)
        num = None
        if sc.get("number"):
            num = th.plain(sc["number"], size=120 if big else 64, color="gold", weight="SEMIBOLD")
            row = VGroup(num, block).arrange(RIGHT, buff=0.6)
        else:
            row = VGroup(block)
        row.move_to([LEFT_X + 0.8 + row.width / 2, self.mid_y + 0.2, 0])

        def reveal():
            out = [FadeIn(num, shift=RIGHT * 0.5)] if num is not None else []
            out += [Write(title), Create(line)]
            return out
        self.steps = [reveal]


# ---------------------------------------------------------- key-word display

class Keynote:
    """Shows one sentence's worth of words at a time in an area of the screen."""

    def __init__(self, theme: Theme, center, width: float):
        self.theme = theme
        self.center = center
        self.width = width
        self.current = None

    def build(self, entry):
        th = self.theme
        if isinstance(entry, dict):
            chips = chip_rows(th, [str(c) for c in entry.get("chips", [])], self.width)
            if entry.get("label"):
                label = th.plain(strip_markup(entry["label"]).upper(), size=22, color="muted", weight="SEMIBOLD")
                label.next_to(chips, UP, buff=0.4)
                g = VGroup(label, chips)
                g.chips, g.label = chips.chips, label
            else:
                g = chips
                g.label = None
            g.kind = "chips"
        elif isinstance(entry, list):
            g = chip_rows(th, [str(c) for c in entry], self.width)
            g.label = None
            g.kind = "chips"
        else:
            g = headline(th, str(entry), self.width)
            g.kind = "headline"
        fit(g, self.width, 3.6, 0.6)
        g.move_to(self.center)
        return g

    def show(self, entry) -> list:
        if entry in ("", None, [], {}):
            return []
        new = self.build(entry)
        anims = self.leave()
        if new.kind == "chips":
            parts = [FadeIn(new.label, shift=UP * 0.1)] if new.label is not None else []
            parts += [FadeIn(c, scale=0.7) for c in new.chips]
            anims.append(LaggedStart(*parts, lag_ratio=0.28))
        else:
            anims.append(FadeIn(new, shift=UP * 0.15, lag_ratio=0.015))
        self.current = new
        return anims

    def leave(self) -> list:
        cur = self.current
        if cur is None:
            return []
        self.current = None
        if cur.kind == "chips":
            parts = ([cur.label] if cur.label is not None else []) + list(cur.chips)
            return [FadeOut(p, shift=UP * 0.35) for p in parts]
        return [FadeOut(cur, shift=UP * 0.35)]


class ProseTemplate(Template):
    reveal_time = 0.9

    def build(self):
        self.key = Keynote(self.theme, [0, self.mid_y, 0], CONTENT_W - 1.0)
        shows = self.sc.get("show")
        if shows is None:                                   # an older script: whole sentences
            shows = self.sc.get("sentences") or []
        self.steps = [(lambda e=e: self.key.show(e)) for e in (list(shows) or [""])]


# ------------------------------------------------------------------- bullets

class BulletsTemplate(Template):
    reveal_time = 0.6

    def build(self):
        th = self.theme
        sc = self.sc
        style = sc.get("style", "dot")
        number = int(sc.get("start") or 1)
        rows = []
        intro = None
        width = CONTENT_W - 1.0
        if sc.get("intro"):
            intro = th.text(sc["intro"], size=24, color="muted", width=width)
            intro.move_to(ORIGIN, aligned_edge=UP + LEFT)
        for item in sc.get("items", []):
            item = {**item, "style": item.get("style") or style}
            rows.append(bullet_row(th, item, width, 34, number=number))
            if not item.get("depth"):
                number += 1
        mobs = ([intro] if intro else []) + rows
        _vstack(mobs, 0.38)
        if intro and rows:
            for r in rows:
                r.shift(DOWN * 0.15)
        group = VGroup(*mobs)
        group.move_to([LEFT_X + 0.5 + group.width / 2, 0, 0])
        self.place(group)
        self.rows = rows
        steps = []
        if intro:
            steps.append(lambda: [FadeIn(intro, shift=UP * 0.1)])
        for k, row in enumerate(rows):
            def reveal(k=k, row=row):
                anims = [FadeIn(row.marker, scale=0.4), FadeIn(row.body, shift=RIGHT * 0.3, lag_ratio=0.01)]
                anims += [r.body.animate.set_opacity(0.55) for r in rows[:k]]
                return anims
            steps.append(reveal)
        self.steps = steps

    def finish(self):
        return [r.body.animate.set_opacity(1) for r in self.rows]


# ------------------------------------------------------------------ callouts

class CalloutTemplate(Template):
    """A book box: its name as a coloured label, its contents as key words, maths or a list."""
    reveal_time = 0.8

    def build(self):
        th = self.theme
        sc = self.sc
        color = th.accent(sc.get("box"))
        chip = title_chip(th, sc.get("title") or "", color)
        chip.move_to([LEFT_X + 0.1, self.top - 0.05, 0], aligned_edge=UP + LEFT)
        parts = sc.get("parts", [])
        items = [p for p in parts if p.get("kind") == "item"]
        maths = [p for p in parts if p.get("kind") == "math"]
        area_top = chip.get_bottom()[1] - 0.3
        steps = []
        state = {"first": True}

        def with_chip(anims):
            if state["first"]:
                state["first"] = False
                return [FadeIn(chip, shift=RIGHT * 0.2)] + anims
            return anims

        self.rows = []
        if items:
            width = CONTENT_W - 1.0
            rows, row_for, number = [], {}, 1
            for p in items:
                r = bullet_row(th, p, width, 32, number=number)
                number += 1
                rows.append(r)
                row_for[id(p)] = r
            _vstack(rows, 0.3)
            group = VGroup(*rows)
            fit(group, width, area_top - BODY_BOTTOM - 0.2, 0.6)
            group.move_to([LEFT_X + 0.5 + group.width / 2, (area_top + BODY_BOTTOM) / 2, 0])
            key = Keynote(th, [0, (area_top + BODY_BOTTOM) / 2, 0], CONTENT_W - 1.0)
            shown = []
            for p in parts:
                if p.get("kind") == "item":
                    r = row_for[id(p)]

                    def reveal(r=r):
                        anims = [FadeIn(r.marker, scale=0.4), FadeIn(r.body, shift=RIGHT * 0.3, lag_ratio=0.01)]
                        anims += [x.body.animate.set_opacity(0.55) for x in shown]
                        shown.append(r)
                        return with_chip(key.leave() + anims)
                    steps.append(reveal)
                elif p.get("kind") == "text":
                    for e in p.get("show", []) or [""]:
                        steps.append(lambda e=e: with_chip(key.show(e)))
                else:
                    steps.append(lambda: with_chip([]))
            self.rows = rows
        else:
            y_key = (area_top + BODY_BOTTOM) / 2
            math_mob = None
            if maths:
                math_mob = math_tex(th, maths[0].get("tex", ""), size=64, color="ink")
                fit(math_mob, CONTENT_W - 1.0, 2.0)
                math_mob.move_to([0, area_top - 0.9 - math_mob.height / 2, 0])
                y_key = (math_mob.get_bottom()[1] + BODY_BOTTOM) / 2
            key = Keynote(th, [0, y_key, 0], CONTENT_W - 1.0)
            for p in parts:
                if p.get("kind") == "math":
                    m = math_mob if p is maths[0] else None
                    if m is None:
                        m = math_tex(th, p.get("tex", ""), size=52)
                        fit(m, CONTENT_W - 1.0, 1.6)
                        m.move_to([0, y_key, 0])
                    steps.append(lambda m=m: with_chip([Write(m)]))
                else:
                    for e in p.get("show", []) or [""]:
                        steps.append(lambda e=e: with_chip(key.show(e)))
        if not steps:
            steps = [lambda: with_chip([])]
        self.steps = steps

    def pref_time(self, k):
        return 1.2

    def finish(self):
        return [r.body.animate.set_opacity(1) for r in self.rows]


# --------------------------------------------------------------------- guide

class GuideTemplate(Template):
    reveal_time = 0.6

    def build(self):
        th = self.theme
        sc = self.sc
        what = "lab" if "lab" in (self.ctx.lecture.get("kind") or "") else "chapter"
        chip = title_chip(th, f"In this {what}", th.c("gold"))
        chip.move_to([LEFT_X + 0.1, self.top - 0.05, 0], aligned_edge=UP + LEFT)
        before = th.text(sc.get("before", ""), size=24, color="muted", width=CONTENT_W - 1.0)
        before.next_to(chip, DOWN, buff=0.35, aligned_edge=LEFT)
        lab2 = th.plain("BY THE END, YOU CAN", size=20, color="gold", weight="SEMIBOLD")
        rows = [bullet_row(th, {"text": o, "style": "check"}, CONTENT_W - 1.0, 34) for o in sc.get("outcomes", [])]
        _vstack(rows, 0.3)
        if rows:
            lab2.next_to(VGroup(*rows), UP, buff=0.4, aligned_edge=LEFT)
        group = VGroup(lab2, *rows)
        fit(group, CONTENT_W - 0.8, before.get_bottom()[1] - BODY_BOTTOM - 0.3, 0.7)
        group.move_to([LEFT_X + 0.6 + group.width / 2, (before.get_bottom()[1] + BODY_BOTTOM) / 2, 0])
        steps = [lambda: [FadeIn(chip, shift=RIGHT * 0.2), FadeIn(before, lag_ratio=0.01)],
                 lambda: [FadeIn(lab2, shift=RIGHT * 0.2)]]
        for r in rows:
            steps.append(lambda r=r: [Create(r.marker), FadeIn(r.body, shift=RIGHT * 0.3, lag_ratio=0.01)])
        self.steps = steps


# ---------------------------------------------------------------------- code

class CodeTemplate(Template):
    """A listing. When it can be run, it runs: memory on the right, the current line lit."""
    manual = True
    reveal_time = 1.1

    def build(self):
        th = self.theme
        sc = self.sc
        trace = sc.get("trace")
        self.trace = trace
        self.memory = MemoryPanel(th, trace, 5.9) if trace else None
        has_memory = self.memory is not None and len(self.memory.group) > 0
        panel = CodePanel(th, sc.get("code", ""), sc.get("language", "text"), int(sc.get("first_line", 1) or 1),
                          sc.get("label"))
        avail_h = self.top - BODY_BOTTOM - 0.2
        if has_memory:
            mem = self.memory.group
            gap = 0.6
            # The code aims for 1.35x (the narration follows it line by line), memory for its natural
            # size. When both do not fit, memory gets 38-55% of the width (it is what moves), the
            # code the rest.
            code_s = min(1.35, avail_h / max(panel.height, 1e-6))
            mem_s = min(1.0, avail_h / max(mem.height, 1e-6))
            code_w, mem_w = panel.width * code_s, mem.width * mem_s
            room = CONTENT_W - gap
            if code_w + mem_w > room:
                low = 0.45 if self.memory.heap is not None else 0.38      # linked structures need room
                share = min(0.55, max(low, mem_w / (code_w + mem_w)))
                mem_w = min(mem_w, room * share)
                code_w = min(code_w, room - mem_w)
                code_s, mem_s = code_w / panel.width, mem_w / mem.width
            panel.scale(code_s)
            mem.scale(mem_s)
            pair_w = panel.width + gap + mem.width
            left = -pair_w / 2
            panel.move_to([left + panel.width / 2, self.mid_y, 0])
            mem.move_to([left + panel.width + gap + mem.width / 2, self.mid_y, 0])
        else:
            grow(panel, CONTENT_W, avail_h, 1.35)
            panel.move_to([0, self.mid_y, 0])
        self.panel = panel
        self.has_memory = has_memory
        self.lit = False
        self.shown = False
        self.steps = [self.reveal]

    @property
    def n_steps(self) -> int:
        return 1

    def reveal(self):
        if self.shown:
            return []
        self.shown = True
        panel = self.panel
        anims = [FadeIn(panel.chrome, shift=UP * 0.1), FadeIn(panel.highlight), FadeIn(panel.cursor)]
        lines, nums = panel.lines(), panel.numbers()
        anims.append(LaggedStart(*[FadeIn(VGroup(nums[k], lines[k]) if k < len(nums) else lines[k],
                                          shift=RIGHT * 0.12) for k in range(len(lines))], lag_ratio=0.07))
        if self.memory is not None:
            anims += [FadeIn(w, shift=LEFT * 0.2) for w in self.memory.initial()]
        return anims

    def light(self, a: int, b: int, dim: bool = False) -> list:
        band, cur = self.panel.highlight_target(a, b)
        if not self.lit:
            self.panel.highlight.become(band.copy().set_fill(opacity=0))
            self.panel.cursor.become(cur.copy().set_fill(opacity=0))
        anims = [Transform(self.panel.highlight, band), Transform(self.panel.cursor, cur)]
        if dim:
            anims += [m.animate.set_opacity(o) for m, o in self.panel.dim_targets(a, b)]
        self.lit = True
        return anims

    def unlight(self) -> list:
        if not self.lit:
            return []
        self.lit = False
        return [self.panel.highlight.animate.set_fill(opacity=0), self.panel.cursor.animate.set_fill(opacity=0)] + \
               [m.animate.set_opacity(1) for m, _ in self.panel.dim_targets(None, None)]

    def play_beat(self, k: int) -> list:
        beats = self.trace["beats"]
        if not 0 <= k < len(beats):
            return []
        events = [self.trace["events"][i] for i in beats[k]]
        first = int(self.sc.get("first_line", 1) or 1) - 1
        check = next((e for e in events if e["k"] == "cond" and e.get("kind") == "if"), None)
        main = check or next((e for e in events if e["k"] != "cond"), events[0])   # light what is being said
        a = main["line"] + first
        b = (main.get("end") or main["line"]) + first if main["k"] == "func" else a
        anims = self.light(a, b)
        if self.memory is not None:
            anims += self.memory.beat(events)
        return anims

    def cue_events(self, ci: int, cue: dict) -> list:
        ev = []
        if ci == 0:
            ev.append((0.0, self.reveal))
        if cue.get("lines"):
            a, b = (list(cue["lines"]) + list(cue["lines"]))[:2]
            ev.append((0.0, lambda a=a, b=b: self.light(int(a), int(b), dim=not self.has_memory)))
        elif cue.get("beats") and self.trace:
            ev += self._beat_times(cue)
        elif self.lit:
            ev.append((0.0, self.unlight))
        return ev

    def _beat_times(self, cue: dict) -> list:
        a, b = (list(cue["beats"]) + list(cue["beats"]))[:2]
        n = len(self.trace["beats"])
        seq = [k for k in range(int(a), int(b) + 1) if 0 <= k < n]
        if not seq:
            return []
        quiet = set(cue.get("quiet") or [])
        marks = list(cue["audio"].get("marks", []))
        dur = float(cue["audio"]["duration"])
        values: list = [0.0]
        mi = 0
        for k in seq[1:]:
            if k in quiet:
                values.append(None)
            else:
                values.append(marks[mi] if mi < len(marks) else None)
                mi += 1
        known = [(i, t) for i, t in enumerate(values) if t is not None]
        for i, t in enumerate(values):
            if t is None:                                    # spread between the neighbours that have a time
                prev = max([(j, tt) for j, tt in known if j < i], default=(0, 0.0))
                nxt = min([(j, tt) for j, tt in known if j > i],
                          default=(len(seq), max(dur - 0.3, prev[1] + 0.5)))
                values[i] = prev[1] + (nxt[1] - prev[1]) * (i - prev[0]) / max(1, nxt[0] - prev[0])
        return [(values[i], (lambda k=k: self.play_beat(k))) for i, k in enumerate(seq)]

    def finish(self):
        return self.unlight()


# --------------------------------------------------------------------- table

class TableTemplate(Template):
    reveal_time = 0.55

    def build(self):
        th = self.theme
        sc = self.sc
        table = TablePanel(th, sc.get("columns", []), sc.get("header", []), sc.get("rows", []))
        intro = th.text(sc["intro"], size=24, color="muted", width=CONTENT_W - 0.4) if sc.get("intro") else None
        avail = self.top - BODY_BOTTOM - 0.15 - (intro.height + 0.3 if intro else 0)
        fit(table, CONTENT_W, avail, 0.55)
        mobs = [m for m in (intro, table) if m is not None]
        for m in mobs:
            m.move_to(ORIGIN, aligned_edge=UP)
        if intro:
            intro.set_x(table.get_left()[0] + intro.width / 2)
        _vstack(mobs, 0.3)
        self.place(VGroup(*mobs), min_scale=0.9)
        self.marker = None
        frame_parts = [table.backing, *table.header_rows, table.rules, table.outline]

        def reveal_frame():
            anims = [FadeIn(VGroup(*frame_parts), shift=UP * 0.1)]
            if intro:
                anims.insert(0, FadeIn(intro))
            return anims
        steps = [reveal_frame]
        for k, row in enumerate(table.body_rows):
            def reveal_row(k=k, row=row):
                box = table.row_box(k, th)
                anims = [FadeIn(row, shift=UP * 0.12)]
                if self.marker is None:
                    self.marker = box
                    anims.append(Create(box))
                else:
                    anims.append(Transform(self.marker, box))
                return anims
            steps.append(reveal_row)
        self.steps = steps

    def finish(self):
        return [self.marker.animate.set_stroke(opacity=0)] if self.marker is not None else []


# ---------------------------------------------------------------- operations

class OperationsTemplate(Template):
    """Each operation of a list or table, demonstrated on an array (or on one value)."""
    manual = True
    reveal_time = 0.8

    def build(self):
        th = self.theme
        sc = self.sc
        center = [0, self.mid_y - 1.0, 0]
        self.demo = ValueDemo(th, center) if sc.get("subject") == "value" else ArrayDemo(th, center)
        self.items = sc.get("items", [])
        self.has_intro = "intro" in sc and sc.get("intro") is not None
        self.key = Keynote(th, [0, self.top - 1.2, 0], CONTENT_W - 1.0)
        self.title = None
        self.started = False

    @property
    def n_steps(self) -> int:
        return 0

    def _title(self, item: dict) -> list:
        th = self.theme
        from ..ops import ARRAY_CODE, VALUE_CODE
        title = strip_markup(item.get("name", "")).strip().rstrip(".;")
        name = th.plain(title[:1].upper() + title[1:], size=54, color="gold", weight="SEMIBOLD")
        text = item.get("text", "")
        same = strip_markup(text).strip(" .;").lower() == title.lower()
        meaning = None if same or not text else th.text(text, size=28, color="ink", width=10.5, align="center")
        table = VALUE_CODE if self.sc.get("subject") == "value" else ARRAY_CODE
        code_line = table.get(item.get("op", ""), "")
        rest = ([meaning] if meaning is not None else []) + \
            ([th.plain(code_line, size=26, color="muted", mono=True)] if code_line else [])
        g = VGroup(name, *rest).arrange(DOWN, buff=0.22)
        fit(g, CONTENT_W - 1.0, 2.4)
        g.move_to([0, self.top - 0.3 - g.height / 2, 0])
        anims = []
        if self.title is not None:
            anims += [FadeOut(m, shift=UP * 0.3) for m in self.title]
        anims.append(LaggedStart(FadeIn(name, shift=UP * 0.2), *[FadeIn(m, shift=UP * 0.1) for m in rest],
                                 lag_ratio=0.3))
        self.title = [name, *rest]
        return anims

    def cue_events(self, ci: int, cue: dict) -> list:
        k = ci - (1 if self.has_intro else 0)
        dur = float(cue["audio"]["duration"])
        if k < 0:                                            # the intro: its gist, and the array appears
            self.started = True
            intro = self.sc.get("intro")
            return [(0.0, lambda: self.demo.show() + (self.key.show(intro) if isinstance(intro, (str, list, dict))
                                                      and intro else []))]
        if k >= len(self.items):
            return []
        item = self.items[k]
        op = item.get("op") or ""

        def opening():
            anims = self.key.leave()
            if not self.started:
                self.started = True
                anims += self.demo.show()
            anims += self._title(item)
            anims += self.demo.prepare(op) if op else []
            return anims
        ev = [(0.0, opening)]
        if op:
            steps = self.demo.steps(op)
            start, end = min(1.0, dur * 0.25), max(1.2, dur - 0.4)
            for j, fn in enumerate(steps):
                ev.append((start + (end - start) * j / max(1, len(steps)), fn))
        return ev


# -------------------------------------------------------------------- figure

class _Reveal:
    """Bring a drawing in part by part, in reading order, without changing which
    part sits on top of which (a cell's fill must stay under its number)."""

    def __init__(self, fig):
        self.fig = fig
        self.parts = [(m, m.get_fill_opacity(), m.get_stroke_opacity()) for m in fig.family_members_with_points()]
        for m, _, _ in self.parts:
            m.set_fill(opacity=0)
            m.set_stroke(opacity=0)

    def animations(self):
        order = sorted(self.parts, key=lambda t: (-round(t[0].get_center()[1] / 0.35), t[0].get_center()[0]))
        anims = [m.animate.set_fill(opacity=f).set_stroke(opacity=so) for m, f, so in order]
        lag = max(0.004, min(0.2, 2.5 / max(1, len(anims))))
        return [LaggedStart(*anims, lag_ratio=lag, group=self.fig)]


class FigureTemplate(Template):
    reveal_time = 2.2

    def build(self):
        th = self.theme
        sc = self.sc
        info = self.ctx.figure(sc)
        self.override = self.ctx.override(sc)
        label_text = "  ·  ".join(x for x in (sc.get("number"), strip_markup(sc.get("title") or "")) if x)
        label = th.plain(label_text.upper(), size=20, color="muted", weight="SEMIBOLD") if label_text else None
        avail_h = self.top - BODY_BOTTOM - 0.3 - (label.height + 0.35 if label else 0)
        avail_w = CONTENT_W - 0.6
        if self.override is not None and hasattr(self.override, "build"):
            fig = self.override.build(th)
            fit(fig, avail_w, avail_h, 0.3)
        elif info.get("svg"):
            fig = load_svg(info["svg"], avail_w, avail_h, max_units_per_pt=0.036)
        elif info.get("image"):
            fig = load_image(info["image"], avail_w, avail_h)
        else:
            fig = th.plain(f"[{info.get('error') or 'figure missing'}]", size=24, color="red", width=avail_w)
        mobs = [fig] + ([label] if label else [])
        for m in mobs:
            m.move_to(ORIGIN, aligned_edge=UP)
        _vstack(mobs, 0.35)
        Group(*mobs).move_to([0, self.mid_y, 0])
        custom = self.override is not None and hasattr(self.override, "reveal")
        drawing = None if custom or isinstance(fig, ImageMobject) else _Reveal(fig)

        def reveal():
            if custom:
                return list(self.override.reveal(fig))
            if drawing is None:
                return [FadeIn(fig, scale=0.97)]
            return drawing.animations()
        self.steps = [reveal]
        if label:
            self.steps.append(lambda: [FadeIn(label, shift=UP * 0.1)])

    def pref_time(self, k):
        return 2.6 if k == 0 else 0.8


# ---------------------------------------------------------------------- math

class MathTemplate(Template):
    reveal_time = 1.4

    def build(self):
        m = math_tex(self.theme, self.sc.get("tex", ""), size=72)
        fit(m, CONTENT_W - 1, 3.5)
        m.move_to([0, self.mid_y, 0])
        self.steps = [lambda: [Write(m)]]


# ------------------------------------------------------------ plain Manim

class CustomTemplate(Template):
    """A scene written in plain Manim in the video's .py file (@manim_scene): a generator whose every
    `yield` is one step, played as a cue starts or at a [show]. Each step is asked for only when it
    plays, so the code between yields sees the scene as the earlier steps left it."""

    def build(self):
        from ..export import load_video_class
        from ..kit import Stage
        module = (self.ctx.plan.get("module") or {}).get("path")
        if not module:
            raise RuntimeError(f"scene {self.sc.get('id')}: a plain-Manim scene needs its .py file")
        cache = self.ctx.__dict__.setdefault("_videos", {})
        if module not in cache:
            cache[module] = load_video_class(module)()
        made = getattr(cache[module], self.sc["method"])(Stage(self))
        self.gen = made if hasattr(made, "__next__") else iter([made] if made else [])
        n = sum(1 + len(c.get("audio", {}).get("marks", [])) for c in self.sc.get("cues", []))
        self.steps = [self._next] * max(1, n)
        self.seconds = None

    def _next(self) -> list:
        try:
            out = next(self.gen)
        except StopIteration:
            return []
        self.seconds = None
        if isinstance(out, tuple) and len(out) == 2 and isinstance(out[1], (int, float)):
            out, self.seconds = out
        return list(out) if isinstance(out, (list, tuple)) else [out]

    def pref_time(self, k: int) -> float:
        return float(self.seconds) if self.seconds else 1.0

    def finish(self) -> list:
        left = []
        while True:                                           # steps the cues did not reach
            step = self._next()
            if not step:
                return left
            left += step


TEMPLATES = {
    "title": TitleTemplate, "outro": OutroTemplate, "section": SectionTemplate, "prose": ProseTemplate,
    "bullets": BulletsTemplate, "callout": CalloutTemplate, "guide": GuideTemplate, "code": CodeTemplate,
    "table": TableTemplate, "figure": FigureTemplate, "math": MathTemplate, "operations": OperationsTemplate,
    "custom": CustomTemplate,
}


def load_override(path: Path):
    """overrides/<course>/<figure label>.py: build(theme) -> Mobject and/or reveal(mobject) -> animations."""
    if not path.exists():
        return None
    spec = importlib.util.spec_from_file_location(f"utp_override_{abs(hash(str(path)))}", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
