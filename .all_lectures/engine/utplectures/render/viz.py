"""Memory you can watch: the variables of a running listing, drawn next to the code.

    scalar          target  [ 1003 ]
    record          s : Student      id [1001]  name ["Amina"] ...
    array           a   [12][25][18][30][22]      with index labels and pointers
    array of records students : Student[5]   one row per element, one column per field
    struct type     struct Student { int id; string name; ... }   built field by field
    console         OUTPUT  Found: Chen

The panel is built in its final shape when the scene starts (so nothing jumps),
and each trace event animates it: a widget appears at its declaration, a cell
changes and flashes when assigned, the loop index slides along its array, a
comparison ticks or crosses, printed text appears in the console.
"""

from __future__ import annotations

from manim import (DOWN, LEFT, ORIGIN, RIGHT, UP, AnimationGroup, FadeIn, FadeOut, Indicate, LaggedStart, Line,
                   RoundedRectangle, Transform, Triangle, VGroup, there_and_back)

from ..minicpp import show
from .heap import HeapW
from .widgets import Theme, check_mark, cross_mark

MONO = 24
CELL_H = 0.52


def _val_text(theme: Theme, value, size: float = MONO):
    text = show(value)
    color = "muted" if value is None else ("green" if isinstance(value, str) else "ink")
    return theme.plain(text, size=size, color=color, mono=True)


def _box(theme: Theme, w: float, h: float = CELL_H, color: str | None = None) -> RoundedRectangle:
    return RoundedRectangle(width=w, height=h, corner_radius=0.07, fill_color=theme.c("panel"), fill_opacity=1,
                            stroke_color=color or theme.c("blue"), stroke_width=2)


class Cell(VGroup):
    """A box holding one value; set() animates a change."""

    def __init__(self, theme: Theme, value, width: float, size: float = MONO):
        self.theme = theme
        self.size = size
        self.box = _box(theme, width)
        self.val = _val_text(theme, value, size)
        self.val.move_to(self.box)
        super().__init__(self.box, self.val)

    def set(self, value) -> list:
        new = _val_text(self.theme, value, self.size).move_to(self.box)
        if new.width > self.box.width - 0.1:
            new.scale_to_fit_width(self.box.width - 0.12)
        old = self.val
        self.remove(old)
        self.val = new
        self.add(new)
        return [FadeOut(old, shift=UP * 0.18), FadeIn(new, shift=UP * 0.18), self.flash()]

    def flash(self, color: str | None = None):
        return self.box.animate(rate_func=there_and_back).set_stroke(color=color or self.theme.c("gold"), width=5)


def _width_for(theme: Theme, values: list, minimum: float = 0.9) -> float:
    w = minimum
    for v in values:
        w = max(w, theme.plain(show(v), size=MONO, mono=True).width + 0.36)
    return w


# ------------------------------------------------------------------ widgets

class ScalarW(VGroup):
    def __init__(self, theme: Theme, name: str, value, values: list):
        super().__init__()
        self.label = theme.plain(name, size=MONO, color="muted", mono=True)
        self.cell = Cell(theme, value, _width_for(theme, values + [value], 1.2))
        self.label.next_to(self.cell, LEFT, buff=0.25)
        self.add(self.label, self.cell)

    def cell_at(self, path: list):
        return self.cell


class StructW(VGroup):
    def __init__(self, theme: Theme, name: str, stype: str, value: dict, values: dict):
        super().__init__()
        fields = list((value or {}).get("fields", {}).keys())
        title = theme.text(f'<span font_family="{theme.mono}">{name}</span>  '
                           f'<span foreground="{theme.c("muted")}">:</span>  '
                           f'<span foreground="{theme.c("gold")}">{stype}</span>', size=MONO)
        labels = [theme.plain(f, size=MONO - 2, color="muted", mono=True) for f in fields]
        lab_w = max([l.width for l in labels] + [0.5])
        self.cells = {}
        rows = []
        for f, lab in zip(fields, labels):
            cell = Cell(theme, value["fields"][f], _width_for(theme, values.get(f, []) + [value["fields"][f]], 1.6))
            lab.move_to(ORIGIN, aligned_edge=RIGHT)
            cell.next_to(lab, RIGHT, buff=0.25)
            cell.align_to([lab_w + 0.25, 0, 0], LEFT)
            lab.align_to([lab_w, 0, 0], RIGHT)
            row = VGroup(lab, cell)
            rows.append(row)
            self.cells[f] = cell
        body = VGroup(*rows).arrange(DOWN, buff=0.14, aligned_edge=LEFT)
        title.next_to(body, UP, buff=0.22, aligned_edge=LEFT)
        self.title = title
        self.add(title, body)

    def cell_at(self, path: list):
        return self.cells.get(path[1]) if len(path) > 1 else None


class ArrayW(VGroup):
    def __init__(self, theme: Theme, name: str, value: dict, values: list):
        super().__init__()
        items = value.get("items", [])
        w = _width_for(theme, values + items, 0.85)
        self.cells = [Cell(theme, v, w) for v in items]
        row = VGroup(*self.cells).arrange(RIGHT, buff=0)
        self.indices = VGroup(*[theme.plain(str(k), size=18, color="muted", mono=True).next_to(c, DOWN, buff=0.1)
                                for k, c in enumerate(self.cells)])
        self.title = theme.plain(name, size=MONO, color="muted", mono=True).next_to(row, LEFT, buff=0.3)
        self.add(self.title, row, self.indices)
        self.theme = theme
        self.pointers = {}
        self.base_h = self.height

    def cell_at(self, path: list):
        if len(path) > 1 and isinstance(path[1], int) and 0 <= path[1] < len(self.cells):
            return self.cells[path[1]]
        return None

    def pointer_at(self, idx: int):
        idx = max(0, min(len(self.cells) - 1, idx))
        return self.indices[idx].get_bottom() + DOWN * 0.12, "up"


class StructArrayW(VGroup):
    """An array of records as a small table: one row per element."""

    def __init__(self, theme: Theme, name: str, stype: str, value: dict, values: dict):
        super().__init__()
        items = value.get("items", [])
        fields = list(items[0]["fields"].keys()) if items and isinstance(items[0], dict) else []
        widths = {f: _width_for(theme, values.get(f, []) + [it["fields"][f] for it in items], 0.9) for f in fields}
        heads = VGroup(*[theme.plain(f, size=18, color="muted", mono=True) for f in fields])
        self.rows = []
        self.cells: dict[tuple, Cell] = {}
        self.index_labels = []
        for k, it in enumerate(items):
            cells = [Cell(theme, it["fields"][f], widths[f]) for f in fields]
            for f, c in zip(fields, cells):
                self.cells[(k, f)] = c
            row = VGroup(*cells).arrange(RIGHT, buff=0)
            lab = theme.plain(f"[{k}]", size=20, color="muted", mono=True).next_to(row, LEFT, buff=0.18)
            self.index_labels.append(lab)
            self.rows.append(VGroup(lab, row))
        body = VGroup(*self.rows).arrange(DOWN, buff=0)
        for lab in self.index_labels:
            lab.align_to(body, LEFT)
        first_cells = [self.cells[(0, f)] for f in fields] if items else []
        for h, c in zip(heads, first_cells):
            h.next_to(c, UP, buff=0.12)
        title = theme.text(f'<span font_family="{theme.mono}">{name}</span>  '
                           f'<span foreground="{theme.c("muted")}">:</span>  '
                           f'<span foreground="{theme.c("gold")}">{stype}[{len(items)}]</span>', size=MONO)
        title.next_to(VGroup(heads, body), UP, buff=0.2, aligned_edge=LEFT)
        self.title, self.heads, self.body = title, heads, body
        self.add(title, heads, body)
        self.theme = theme
        self.base_h = self.height

    def cell_at(self, path: list):
        if len(path) >= 3 and isinstance(path[1], int):
            return self.cells.get((path[1], path[2]))
        if len(path) == 2 and isinstance(path[1], int) and path[1] < len(self.rows):
            return None
        return None

    def row(self, idx: int):
        return self.rows[max(0, min(len(self.rows) - 1, idx))]

    def pointer_at(self, idx: int):
        lab = self.index_labels[max(0, min(len(self.index_labels) - 1, idx))]
        return lab.get_left() + LEFT * 0.14, "right"


class TypeCardW(VGroup):
    """struct Student { int id; ... } drawn as a record template, field by field."""

    def __init__(self, theme: Theme, name: str, fields: list):
        super().__init__()
        self.title = theme.text(f'<span foreground="#6FB3FF">struct</span>  '
                                f'<span foreground="{theme.c("gold")}" weight="semibold">{name}</span>', size=MONO + 4,
                                mono=True)
        rows = []
        types = [theme.plain(ftype, size=MONO, color="gold", mono=True) for ftype, _ in fields]
        names = [theme.plain(fname, size=MONO, color="ink", mono=True) for _, fname in fields]
        type_w = max([t.width for t in types] + [0.8])
        name_w = max([n.width for n in names] + [0.8])
        width = max(3.3, 0.25 + type_w + 0.4 + name_w + 0.3)
        for t, n in zip(types, names):
            box = _box(theme, width, 0.6, theme.c("faint"))
            t.move_to(box).align_to(box, LEFT).shift(RIGHT * 0.25)
            n.move_to(box).align_to(box, LEFT).shift(RIGHT * (0.25 + type_w + 0.4))
            rows.append(VGroup(box, t, n))
        self.rows = rows
        body = VGroup(*rows).arrange(DOWN, buff=0.1)
        frame = RoundedRectangle(width=body.width + 0.4, height=body.height + 0.4, corner_radius=0.14,
                                 fill_opacity=0, stroke_color=theme.c("gold"), stroke_width=2.5)
        frame.move_to(body)
        self.title.next_to(frame, UP, buff=0.2, aligned_edge=LEFT)
        self.frame = frame
        self.add(self.title, frame, body)


class ConsoleW(VGroup):
    def __init__(self, theme: Theme, width: float, lines: int = 3):
        super().__init__()
        self.theme = theme
        self.max_lines = lines
        self.box = RoundedRectangle(width=width, height=0.46 * lines + 0.62, corner_radius=0.12,
                                    fill_color="#020407", fill_opacity=1, stroke_color=theme.c("faint"),
                                    stroke_width=2)
        self.head = theme.plain("OUTPUT", size=16, color="muted", weight="SEMIBOLD")
        self.head.move_to(self.box.get_corner(UP + LEFT) + RIGHT * 0.25 + DOWN * 0.22, aligned_edge=UP + LEFT)
        self.add(self.box, self.head)
        self.lines: list = []
        self.base_w = self.box.width
        self.open_text: str | None = None                   # the last line, while it has no newline yet

    def _line(self, raw: str, s: float):
        t = self.theme.plain(raw or " ", size=MONO - 1, color="green", mono=True).scale(s)
        if t.width > self.box.width - 0.5 * s:
            t.scale_to_fit_width(self.box.width - 0.5 * s)
        return t

    def print(self, text: str) -> list:
        """cout << 12 << " "; prints on the same line until a newline: the console does the same."""
        anims = []
        s = self.box.width / self.base_w                    # the panel may have been scaled to fit
        step = 0.46 * s
        parts = text.split("\n")
        closed = text.endswith("\n")
        if closed:
            parts = parts[:-1]
        for i, raw in enumerate(parts or [""]):
            if i == 0 and self.open_text is not None and self.lines:
                full = self.open_text + raw                 # continue the open line: its new letters type in
                if raw.strip():
                    old = self.lines[-1]
                    new = self._line(full.rstrip(), s).move_to(old.get_left(), aligned_edge=LEFT)
                    anims.append(Transform(old, new))
                self.open_text = full
                continue
            t = self._line(raw.rstrip(), s)
            y0 = self.head.get_bottom()[1] - 0.12 * s
            if len(self.lines) >= self.max_lines:
                old = self.lines.pop(0)
                anims.append(FadeOut(old, shift=UP * 0.3 * s))
                for ln in self.lines:
                    anims.append(ln.animate.shift(UP * step))
            slot = len(self.lines)
            t.move_to([self.box.get_left()[0] + 0.25 * s, y0 - step / 2 - step * slot, 0], aligned_edge=LEFT)
            self.lines.append(t)
            anims.append(FadeIn(t, shift=RIGHT * 0.15, lag_ratio=0.04))
            self.open_text = raw
        if closed:
            self.open_text = None
        return anims


# -------------------------------------------------------------------- panel

def _values_by_path(events: list[dict]) -> dict:
    """Every value each variable (or field) takes during the trace, to size its cells."""
    out: dict = {}
    for e in events:
        if e["k"] == "assign":
            p = e["path"]
            key = (p[0], p[-1]) if len(p) > 1 and not isinstance(p[-1], int) else (p[0],)
            out.setdefault(key, []).append(e["value"])
    return out


class MemoryPanel:
    def __init__(self, theme: Theme, trace: dict, width: float):
        self.theme = theme
        self.width = width
        events = trace["events"]
        values = _values_by_path(events)
        self.widgets: dict[str, VGroup] = {}
        self.types: dict[str, VGroup] = {}
        order: list = []
        self.hidden: set[str] = set()
        self.heap = HeapW(theme, trace) if HeapW.wanted(trace) else None
        owned = self.heap.owned if self.heap is not None else set()
        if self.heap is not None:
            order.append(self.heap)

        def make(name: str, vtype: str, value) -> VGroup | None:
            if name in owned:                               # drawn as a label on the heap
                return None
            if isinstance(value, dict) and "array" in value:
                items = value["items"]
                if items and isinstance(items[0], dict) and "struct" in items[0]:
                    per = {}
                    for (root, *rest), vs in values.items():
                        if root == name and rest:
                            per.setdefault(rest[-1], []).extend(vs)
                    return StructArrayW(theme, name, vtype.split("[")[0], value, per)
                return ArrayW(theme, name, value, values.get((name,), []))
            if isinstance(value, dict) and "struct" in value:
                per = {}
                for (root, *rest), vs in values.items():
                    if root == name and rest:
                        per.setdefault(rest[-1], []).extend(vs)
                return StructW(theme, name, value["struct"], value, per)
            return ScalarW(theme, name, value, values.get((name,), []))

        for v in trace.get("initial", []):
            w = make(v["name"], v.get("type", ""), v["value"])
            if w is not None:
                self.widgets[v["name"]] = w
                order.append(w)
        for e in events:
            if e["k"] == "struct":
                card = TypeCardW(theme, e["name"], e["fields"])
                self.types[e["name"]] = card
                order.append(card)
            elif e["k"] == "decl" and e["name"] not in self.widgets:
                w = make(e["name"], e.get("type", ""), e["value"])
                if w is not None:
                    self.widgets[e["name"]] = w
                    self.hidden.add(e["name"])
                    order.append(w)
        self.console = None
        if any(e["k"] == "print" for e in events):
            n_lines = "".join(e["text"] for e in events if e["k"] == "print").rstrip("\n").count("\n") + 1
            self.console = ConsoleW(theme, width - 0.2, max(1, min(4, n_lines)))
            order.append(self.console)
        # arrays first and largest at the top, scalars after, the console last
        def rank(w):
            if w is self.console:
                return 3
            if isinstance(w, (TypeCardW,)):
                return 0
            if isinstance(w, (StructArrayW, ArrayW, StructW, HeapW)):
                return 1
            return 2
        order.sort(key=rank)
        if self.heap is not None:                          # the nodes are the picture: the type card steps back
            for card in self.types.values():
                card.scale(0.75)
        scalars = [w for w in order if isinstance(w, ScalarW)]
        others = [w for w in order if not isinstance(w, ScalarW)]
        if len(scalars) > 1:                                # small variables side by side
            line = VGroup(*scalars).arrange(RIGHT, buff=0.6)
            if line.width > width:
                line = VGroup(*scalars).arrange(DOWN, buff=0.22, aligned_edge=LEFT)
            blocks = [w for w in others if rank(w) < 2] + [line] + [w for w in others if rank(w) == 3]
        else:
            blocks = [w for w in others if rank(w) < 2] + scalars + [w for w in others if rank(w) == 3]
        self.group = VGroup(*blocks).arrange(DOWN, buff=0.42, aligned_edge=LEFT)
        self.pointers: dict[str, VGroup] = {}
        self.loop_target: dict[str, str] = {}
        self.marks: list = []
        self._map_loops(events)

    def _map_loops(self, events: list[dict]) -> None:
        """Which array does each loop variable index? Look at what each pass touches."""
        current = {}
        for e in events:
            if e["k"] == "loop":
                current[e["var"]] = e["value"]
            for side in ("left", "right"):
                p = (e.get(side) or {}).get("path") if e["k"] == "cond" else None
                if p and len(p) > 1 and isinstance(p[1], int) and p[0] in self.widgets:
                    for var, val in current.items():
                        if val == p[1] and var not in self.loop_target:
                            self.loop_target[var] = p[0]
            if e["k"] == "assign":
                p = e["path"]
                if len(p) > 1 and isinstance(p[1], int) and p[0] in self.widgets:
                    for var, val in current.items():
                        if val == p[1] and var not in self.loop_target and var != p[0]:
                            self.loop_target[var] = p[0]
        arrays = [n for n, w in self.widgets.items() if isinstance(w, (ArrayW, StructArrayW))]
        for var in current:
            if var not in self.loop_target and len(arrays) == 1:
                self.loop_target[var] = arrays[0]

    # ---------------------------------------------------------------- pieces

    def mobject(self) -> VGroup:
        return self.group

    def initial(self) -> list:
        """Widgets shown when the code appears (variables from earlier listings)."""
        shown = [w for n, w in self.widgets.items() if n not in self.hidden]
        if self.heap is not None:
            shown += self.heap.initial()
        if self.console is not None:
            shown.append(self.console)
        return shown

    def cell(self, path: list):
        w = self.widgets.get(path[0]) if path else None
        return w.cell_at(path) if w is not None else None

    def _pointer(self, var: str, idx) -> list:
        arr = self.widgets.get(self.loop_target.get(var, ""))
        if arr is None or not isinstance(idx, int):
            return []
        pos, direction = arr.pointer_at(idx)
        if var not in self.pointers:
            s = arr.height / max(1e-6, arr.base_h) if hasattr(arr, "base_h") else 1.0
            tri = Triangle(fill_color=self.theme.c("gold"), fill_opacity=1, stroke_width=0).scale(0.11 * s)
            lab = self.theme.plain(var, size=MONO - 2, color="gold", mono=True).scale(s)
            if direction == "right":
                tri.rotate(-1.5708)
                lab.next_to(tri, LEFT, buff=0.1)
                ptr = VGroup(lab, tri)
                ptr.move_to(pos, aligned_edge=RIGHT)
            else:
                lab.next_to(tri, DOWN, buff=0.08)
                ptr = VGroup(tri, lab)
                ptr.move_to(pos, aligned_edge=UP)
            self.pointers[var] = ptr
            ptr.direction = direction
            return [FadeIn(ptr, scale=0.6)]
        ptr = self.pointers[var]
        target = ptr.copy()
        if ptr.direction == "right":
            target.move_to(pos, aligned_edge=RIGHT)
        else:
            target.move_to(pos, aligned_edge=UP)
        return [ptr.animate.move_to(target.get_center())]

    def _clear_marks(self) -> list:
        out = [FadeOut(m) for m in self.marks]
        self.marks = []
        return out

    def _verdict(self, e: dict) -> list:
        anims = []
        cells = []
        color = self.theme.c("green") if e["result"] else self.theme.c("red")
        for side in ("left", "right"):
            p = (e.get(side) or {}).get("path")
            node = self.heap.node(p[0]) if p and self.heap is not None and str(p[0]).startswith("#") else None
            if node is not None:                            # a node's field: tick or cross above the node
                s = node.outline.height / 0.62
                mark = check_mark(color, 0.3 * s) if e["result"] else cross_mark(color, 0.26 * s)
                mark.next_to(node, self.heap.free_side(p[0]), buff=0.12 * s)
                self.marks.append(mark)
                return [node.flash(color), FadeIn(mark, scale=0.5)]
            c = self.cell(p) if p else None
            if c is not None:
                cells.append(c)
        for c in cells:
            anims.append(c.flash(color))
        if cells:
            anchor = cells[0]
            s = anchor.height / 0.52
            mark = check_mark(color, 0.3 * s) if e["result"] else cross_mark(color, 0.26 * s)
            mark.next_to(anchor, RIGHT, buff=0.18)
            owner = self.widgets.get((e.get("left") or {}).get("path", [None])[0])
            if isinstance(owner, StructArrayW):
                mark.next_to(owner.body, RIGHT, buff=0.2).set_y(anchor.get_y())
            elif isinstance(owner, ArrayW):                 # beside a cell is the next cell: above it
                mark.next_to(anchor, UP, buff=0.1 * s)
            self.marks.append(mark)
            anims.append(FadeIn(mark, scale=0.5))
        return anims

    # ------------------------------------------------------------- the beats

    def beat(self, events: list[dict]) -> list:
        """Animations for one beat (a group of events)."""
        groups: list[list] = []
        first = self._clear_marks()
        if self.heap is not None:
            g = self.heap.beat(events)
            if g:
                groups.append(g)
        for e in events:
            k = e["k"]
            g: list = []
            if k == "struct":
                card = self.types.get(e["name"])
                if card is not None:
                    g = [FadeIn(card.title, shift=RIGHT * 0.2), FadeIn(card.frame)]
            elif k == "field":
                card = self.types.get(e["struct"])
                if card is not None and e["index"] < len(card.rows):
                    g = [FadeIn(card.rows[e["index"]], shift=RIGHT * 0.3)]
            elif k == "decl":
                w = self.widgets.get(e["name"])
                if w is not None and e["name"] in self.hidden:
                    self.hidden.discard(e["name"])
                    if isinstance(w, StructArrayW):
                        g = [FadeIn(w.title), FadeIn(w.heads),
                             LaggedStart(*[FadeIn(r, shift=RIGHT * 0.3) for r in w.rows], lag_ratio=0.25)]
                    elif isinstance(w, ArrayW):
                        g = [FadeIn(w.title), LaggedStart(*[FadeIn(c, shift=DOWN * 0.2) for c in w.cells],
                                                          lag_ratio=0.15), FadeIn(w.indices)]
                    else:
                        g = [FadeIn(w, shift=UP * 0.2)]
            elif k == "assign":
                path = e["path"]
                c = self.cell(path)
                if c is not None:
                    g = c.set(e["value"])
            elif k == "loop":
                g = self._pointer(e["var"], e["value"])        # the index variable's box changes with its ++
            elif k == "cond":
                if e.get("kind") == "if":
                    g = self._verdict(e)
                elif not e["result"]:
                    ptrs = [self.pointers[v] for v in self.pointers]
                    g = [p.animate.set_opacity(0.3) for p in ptrs]
            elif k == "print" and self.console is not None:
                g = self.console.print(e["text"])
            elif k == "break":
                ptrs = list(self.pointers.values())
                g = [Indicate(p, color=self.theme.c("gold")) for p in ptrs]
            if g:
                groups.append(g)
        if not groups:
            return first
        if len(groups) == 1:
            return first + groups[0]
        # One after another, but played together: grouping them (LaggedStart) would re-stack
        # each box above its value, so later parts simply start later in the same play.
        out = list(first)
        n = len(groups)
        for i, g in enumerate(groups):
            start = 0.5 * i / (n - 1)
            out += [delayed(a, start) for a in g]
        return out


def delayed(anim, start: float):
    """The same animation, starting `start` (0..1) of the way into its play."""
    return within(anim, start, 1.0)


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
