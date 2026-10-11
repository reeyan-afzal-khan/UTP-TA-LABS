"""Operations, demonstrated: what traversal, insertion, searching ... do to an array.

Each operation is a short list of steps; the scene spreads them across the
narration of that operation, so the array moves while the voice explains it.
A list of operations on a single value (create, access, update, destroy) uses
one variable box instead of an array.
"""

from __future__ import annotations

from manim import (DOWN, LEFT, RIGHT, UP, FadeIn, FadeOut, Indicate, Line, RoundedRectangle, Transform, Triangle,
                   VGroup)

from .widgets import Theme, check_mark, cross_mark

BASE = [12, 25, 18, 30, 22]
CELL = 1.05


class ArrayDemo:
    def __init__(self, theme: Theme, center):
        self.theme = theme
        self.center = center
        self.cells: list[VGroup] = []
        self.indices: list = []
        self.extra: list = []                   # anything an operation added (pointers, labels, copies)
        self.dirty = False
        self.group = self._fresh(BASE)

    # ---------------------------------------------------------------- pieces

    def _cell(self, value, color: str | None = None) -> VGroup:
        th = self.theme
        box = RoundedRectangle(width=CELL, height=CELL * 0.82, corner_radius=0.09, fill_color=th.c("panel"),
                               fill_opacity=1, stroke_color=color or th.c("blue"), stroke_width=3)
        val = th.plain(str(value), size=38, color="ink", mono=True).move_to(box)
        g = VGroup(box, val)
        g.box, g.val, g.value = box, val, value
        return g

    def _slot(self, i: int, n: int):
        return self.center + RIGHT * (i - (n - 1) / 2) * CELL

    def _fresh(self, values: list) -> VGroup:
        self.cells = [self._cell(v).move_to(self._slot(i, len(values))) for i, v in enumerate(values)]
        self.indices = [self.theme.plain(str(i), size=22, color="muted", mono=True)
                        .next_to(c, DOWN, buff=0.14) for i, c in enumerate(self.cells)]
        self.name = self.theme.plain("a", size=30, color="muted", mono=True).next_to(self.cells[0], LEFT, buff=0.35)
        return VGroup(self.name, *self.cells, *self.indices)

    def show(self) -> list:
        return [FadeIn(self.name), *[FadeIn(c, shift=DOWN * 0.2) for c in self.cells], *[FadeIn(i) for i in self.indices]]

    def prepare(self, op: str) -> list:
        return self.reset()

    def reset(self) -> list:
        """Back to the original array before the next operation."""
        anims = [FadeOut(m) for m in self.extra]
        self.extra = []
        if not self.dirty:
            return anims
        old = [*self.cells, *self.indices, self.name]
        anims += [FadeOut(m) for m in old]
        self.group = self._fresh(BASE)
        anims += [FadeIn(m) for m in [*self.cells, *self.indices, self.name]]
        self.dirty = False
        return anims

    def _pointer(self, i: int, label: str = "i"):
        tri = Triangle(fill_color=self.theme.c("gold"), fill_opacity=1, stroke_width=0).scale(0.13).rotate(3.14159)
        lab = self.theme.plain(label, size=24, color="gold", mono=True).next_to(tri, UP, buff=0.06)
        p = VGroup(lab, tri).next_to(self.cells[i], UP, buff=0.15)
        return p

    def _glow(self, cell, color: str):
        return cell.box.animate.set_fill(color, opacity=0.35).set_stroke(color)

    def _unglow(self, cell):
        return cell.box.animate.set_fill(self.theme.c("panel"), opacity=1).set_stroke(self.theme.c("blue"))

    # ------------------------------------------------------------- operations

    def steps(self, op: str) -> list:
        """A list of callables, each returning the animations of one step."""
        th = self.theme
        gold, green, red, blue = th.c("gold"), th.c("green"), th.c("red"), th.c("blue")
        self.dirty = True                      # every operation leaves traces: the next one starts afresh
        if op == "traverse":
            state = {}

            def visit(i):
                def f():
                    anims = [self._glow(self.cells[i], blue)]
                    if i == 0:
                        p = self._pointer(0)
                        state["p"] = p
                        self.extra.append(p)
                        anims.append(FadeIn(p, shift=DOWN * 0.2))
                    else:
                        anims.append(state["p"].animate.next_to(self.cells[i], UP, buff=0.15))
                    if i > 0:
                        anims.append(self._unglow(self.cells[i - 1]))
                    return anims
                return f
            last = len(self.cells) - 1
            return [visit(i) for i in range(len(self.cells))] + [lambda: [self._unglow(self.cells[last])]]
        if op == "insert":
            new = self._cell(15, gold).move_to(self._slot(2, 5) + UP * 1.35)

            def appear():
                self.extra.append(new)
                return [FadeIn(new, shift=DOWN * 0.3)]

            def make_room():
                self.dirty = True
                anims = [c.animate.shift(RIGHT * CELL) for c in self.cells[2:]]
                idx = self.theme.plain("5", size=22, color="muted", mono=True).next_to(
                    self.cells[-1].copy().shift(RIGHT * CELL), DOWN, buff=0.14)
                self.extra.append(idx)
                anims.append(FadeIn(idx))
                return anims

            def drop():
                return [new.animate.move_to(self._slot(2, 5))]
            return [appear, make_room, drop]
        if op == "select":
            def point():
                p = self._pointer(3, "3")
                self.extra.append(p)
                return [FadeIn(p, shift=DOWN * 0.2), self._glow(self.cells[3], gold)]

            def read():
                copy = self.cells[3].val.copy()
                label = th.text(f'<span font_family="{th.mono}">x =</span>', size=34, color="muted")
                target = VGroup(label, copy.copy()).arrange(RIGHT, buff=0.2)
                target.next_to(self.cells[-1], RIGHT, buff=0.9)
                self.extra += [label, copy]
                return [FadeIn(label), copy.animate.move_to(target[1])]
            return [point, read, lambda: [self._unglow(self.cells[3])]]
        if op == "search":
            target = th.text(f'find <span foreground="{gold}" font_family="{th.mono}">18</span>', size=34,
                             color="ink").next_to(self.cells[-1], RIGHT, buff=0.9)
            state = {}

            def start():
                self.extra.append(target)
                p = self._pointer(0)
                state["p"] = p
                self.extra.append(p)
                return [FadeIn(target), FadeIn(p, shift=DOWN * 0.2)]

            def check(i):
                def f():
                    hit = BASE[i] == 18
                    color = green if hit else red
                    mark = (check_mark(color, 0.32) if hit else cross_mark(color, 0.28)).next_to(
                        self.indices[i], DOWN, buff=0.15)
                    self.extra.append(mark)
                    anims = [FadeIn(mark, scale=0.5), self._glow(self.cells[i], color)]
                    if i > 0:
                        anims.append(state["p"].animate.next_to(self.cells[i], UP, buff=0.15))
                    return anims
                return f
            return [start, check(0), check(1), check(2)]
        if op == "sort":
            order = sorted(range(len(BASE)), key=lambda i: BASE[i])

            def lift():
                self.dirty = True
                return [c.animate.shift(UP * 0.5) for c in self.cells]

            def place():
                anims = []
                for new_pos, i in enumerate(order):
                    anims.append(self.cells[i].animate(path_arc=-1.2).move_to(self._slot(new_pos, len(BASE)) + UP * 0.5))
                return anims

            def settle():
                return [c.animate.shift(DOWN * 0.5) for c in self.cells]

            def done():                                   # one animation per box: no tug of war
                return [self._glow(c, green) for c in self.cells]
            return [lift, place, settle, done]
        if op == "merge":
            left, right = [12, 25, 30], [18, 22]
            state = {}

            def split():
                self.dirty = True
                anims = []
                pos = {12: (0, "L"), 25: (1, "L"), 30: (2, "L"), 18: (0, "R"), 22: (1, "R")}
                for c in self.cells:
                    k, side = pos[c.value]
                    x = (-3.3 + k * CELL) if side == "L" else (1.6 + k * CELL)
                    anims.append(c.animate.move_to([x, self.center[1] + 1.25, 0]))
                anims += [FadeOut(i) for i in self.indices]
                self.indices = []
                return anims

            def take(k, value):
                def f():
                    src = next(c for c in self.cells if c.value == value)
                    dup = src.copy()
                    self.extra.append(dup)
                    return [self._glow(src, gold), dup.animate.move_to(self._slot(k, 5) + DOWN * 0.45)]
                return f
            merged = sorted(left + right)
            return [split] + [take(k, v) for k, v in enumerate(merged)]
        if op == "delete":
            def mark():
                return [self._glow(self.cells[1], red)]

            def remove():
                self.dirty = True
                gone = self.cells.pop(1)
                return [FadeOut(gone, shift=DOWN * 0.6)]

            def close():
                anims = [c.animate.shift(LEFT * CELL) for c in self.cells[1:]]
                last = self.indices.pop()
                anims.append(FadeOut(last))
                return anims
            return [mark, remove, close]
        if op == "update":
            def point():
                p = self._pointer(2, "2")
                self.extra.append(p)
                return [FadeIn(p, shift=DOWN * 0.2), self._glow(self.cells[2], gold)]

            def change():
                self.dirty = True
                c = self.cells[2]
                new = th.plain("40", size=38, color="ink", mono=True).move_to(c.box)
                old = c.val
                c.remove(old)
                c.add(new)
                c.val = new
                return [FadeOut(old, shift=UP * 0.3), FadeIn(new, shift=UP * 0.3)]
            return [point, change, lambda: [self._unglow(self.cells[2])]]
        if op == "create":
            def hide():
                self.dirty = True
                return [FadeOut(c) for c in self.cells] + [FadeOut(i) for i in self.indices]

            def make(i):
                def f():
                    return [FadeIn(self.cells[i], scale=0.6), FadeIn(self.indices[i])]
                return f
            return [hide] + [make(i) for i in range(len(self.cells))]
        return [lambda: [Indicate(VGroup(*self.cells), color=gold)]]


class ValueDemo:
    """Operations on a primitive: one variable box."""

    def __init__(self, theme: Theme, center):
        self.theme = theme
        self.center = center
        self.extra: list = []
        self.box = RoundedRectangle(width=2.2, height=1.1, corner_radius=0.12, fill_color=theme.c("panel"),
                                    fill_opacity=1, stroke_color=theme.c("blue"), stroke_width=3).move_to(center)
        self.label = theme.plain("x", size=36, color="muted", mono=True).next_to(self.box, LEFT, buff=0.35)
        self.val = theme.plain("42", size=44, color="ink", mono=True).move_to(self.box)
        self.alive = False
        self.group = VGroup(self.label, self.box, self.val)

    def show(self) -> list:
        return self.prepare("select")

    def _fresh(self) -> None:
        th = self.theme
        self.box = RoundedRectangle(width=2.2, height=1.1, corner_radius=0.12, fill_color=th.c("panel"),
                                    fill_opacity=1, stroke_color=th.c("blue"), stroke_width=3).move_to(self.center)
        self.label = th.plain("x", size=36, color="muted", mono=True).next_to(self.box, LEFT, buff=0.35)
        self.val = th.plain("42", size=44, color="ink", mono=True).move_to(self.box)

    def prepare(self, op: str) -> list:
        """The variable as the operation expects it: absent before create, present otherwise."""
        anims = [FadeOut(m) for m in self.extra]
        self.extra = []
        if op == "create":
            if self.alive:
                anims += [FadeOut(self.box), FadeOut(self.val), FadeOut(self.label)]
                self.alive = False
            self._fresh()
        elif not self.alive:
            self._fresh()
            anims += [FadeIn(self.label), FadeIn(self.box), FadeIn(self.val)]
            self.alive = True
        return anims

    def steps(self, op: str) -> list:
        th = self.theme
        if op == "create":
            def make():
                self.alive = True
                return [FadeIn(self.label), FadeIn(self.box, scale=0.6)]

            def fill():
                return [FadeIn(self.val, shift=DOWN * 0.3)]
            return [make, fill]
        if op == "select":
            def read():
                dup = self.val.copy()
                out = th.text("read", size=26, color="muted").move_to(self.center + RIGHT * 3.0 + UP * 0.75)
                self.extra += [dup, out]
                return [Indicate(self.val, color=th.c("gold")), FadeIn(out),
                        dup.animate.move_to(self.center + RIGHT * 3.0)]
            return [read]
        if op == "update":
            def change():
                new = th.plain("7", size=44, color="ink", mono=True).move_to(self.box)
                old = self.val
                self.val = new
                return [FadeOut(old, shift=DOWN * 0.5), FadeIn(new, shift=DOWN * 0.5),
                        self.box.animate(rate_func=lambda t: 1 - abs(2 * t - 1)).set_stroke(th.c("gold"), width=6)]
            return [change]
        if op == "delete":
            def destroy():
                self.alive = False
                return [FadeOut(self.box, scale=0.4), FadeOut(self.val, scale=0.4), FadeOut(self.label, shift=LEFT * 0.3)]
            return [destroy]
        return [lambda: [Indicate(self.val, color=th.c("gold"))]]
