"""Linked structures you can watch: nodes made with new, and the pointers between them.

    list      head                       p
               |                         |
               v                         v
             [12 |o]---->[25 |o]---->[18 |/]   nullptr

    tree      root -> [o| 18 |o]
                     /          \\
             [o| 12 |o]          [o| 25 |o]

HeapW replays the whole trace once when it is built, so it knows every node
that will ever exist and the largest area the structure will need: the panel
is sized once and nothing jumps. Each beat applies its events to the model
(heapmodel.py), lays the structure out again and animates the difference:
nodes slide to their new places, links swing to their new targets, a node not
yet linked in waits below the row, a deleted node flashes red and fades, and
the pointer variables (head, p, root ...) follow the nodes they aim at.

Nodes are built once, inside the panel group, so they scale with the panel.
Arrows and pointer labels are made on the fly, in screen coordinates.
"""

from __future__ import annotations

import numpy as np
from manim import (DOWN, LEFT, RIGHT, UP, Create, Dot, FadeIn, FadeOut, Line, Rectangle, RoundedRectangle,
                   Transform, Triangle, VGroup, VMobject, there_and_back)

from ..heapmodel import HEAD_NAMES, HeapModel, Shape, is_ptr, ref_of
from ..minicpp import show
from .widgets import Theme

MONO = 24
NODE_H = 0.62
SLOT_W = 0.46
GAP = 0.75            # between neighbours in a list row
WAIT = 1.5            # list: how far below the row a node waits until it is linked in
LEVEL = 1.4           # tree: one level down
TAG_RISE = 0.66       # a pointer label's distance from the node it aims at
LANE = 0.12           # doubly linked lists: next arrows above, prev arrows below
LINK_W = 3.2


def _val(theme: Theme, value, size: float = MONO):
    text = show(value)
    color = "muted" if value is None else ("green" if isinstance(value, str) else "ink")
    return theme.plain(text, size=size, color=color, mono=True)


def edge_point(center, w: float, h: float, toward) -> np.ndarray:
    """Where the ray from a box's centre toward a point leaves the box."""
    c = np.array(center, dtype=float)
    d = np.array(toward, dtype=float) - c
    if abs(d[0]) < 1e-9 and abs(d[1]) < 1e-9:
        return c
    tx = (w / 2) / abs(d[0]) if abs(d[0]) > 1e-9 else np.inf
    ty = (h / 2) / abs(d[1]) if abs(d[1]) > 1e-9 else np.inf
    return c + d * min(tx, ty)


def arrow(points: list, color: str, s: float, width: float = LINK_W, opacity: float = 1.0) -> VGroup:
    """A link: one cubic (straight when given two points) and a filled tip. Always the same
    structure, so any link can Transform into any other."""
    pts = [np.array(p, dtype=float) for p in points]
    if len(pts) == 2:
        p0, p3 = pts
        c1, c2 = p0 + (p3 - p0) / 3, p0 + 2 * (p3 - p0) / 3
    else:
        p0, c1, c2, p3 = pts
    d = p3 - c2
    if np.linalg.norm(d) < 1e-6:
        d = p3 - p0
    d = d / max(np.linalg.norm(d), 1e-9)
    tip_len = 0.17 * s
    r = tip_len / 1.5                                      # a Triangle's height is 1.5 x its circumradius
    end = p3 - d * tip_len * 0.85
    path = VMobject(stroke_color=color, stroke_width=width, stroke_opacity=opacity)
    path.set_points(np.array([p0, c1 + (end - p3) / 3, c2 + 2 * (end - p3) / 3, end]))
    tip = Triangle(fill_color=color, fill_opacity=opacity, stroke_width=0).scale(r)
    tip.rotate(np.arctan2(d[1], d[0]) - np.pi / 2)
    tip.shift(p3 - d * r - tip.get_center_of_mass())
    return VGroup(path, tip)


# ---------------------------------------------------------------- one node

class NodeW(VGroup):
    """[prev | value ... | next]: data in the middle, pointer slots at the sides."""

    def __init__(self, theme: Theme, order: list[str], ptrs: set, widths: dict, fields: dict, doubly: bool):
        super().__init__()
        self.theme = theme
        segs, x = [], 0.0
        for f in order:
            w = SLOT_W if f in ptrs else widths.get(f, 0.9)
            segs.append((f, x, w))
            x += w
        total = x
        self.w = total
        self.outline = RoundedRectangle(width=total, height=NODE_H, corner_radius=0.1, fill_color=theme.c("panel"),
                                        fill_opacity=1, stroke_color=theme.c("blue"), stroke_width=2.6)
        self.add(self.outline)
        left = -total / 2
        for f, x0, w in segs[1:]:
            self.add(Line([left + x0, -NODE_H / 2, 0], [left + x0, NODE_H / 2, 0], stroke_color=theme.c("blue"),
                          stroke_width=1.6, stroke_opacity=0.55))
        self.vals, self.dots, self.slashes, self.null = {}, {}, {}, {}
        self.slot_off: dict[str, np.ndarray] = {}
        for f, x0, w in segs:
            cx = left + x0 + w / 2
            if f in ptrs:
                dy = (LANE if f == order[-1] else -LANE) if doubly else 0.0
                dot = Dot([cx, dy, 0], radius=0.07, color=theme.c("gold"))
                slash = Line([cx - w * 0.3, -NODE_H * 0.32, 0], [cx + w * 0.3, NODE_H * 0.32, 0],
                             stroke_color=theme.c("muted"), stroke_width=2.4)
                null = ref_of(fields.get(f)) is None
                dot.set_opacity(0.0 if null else 1.0)
                slash.set_stroke(opacity=1.0 if null else 0.0)
                self.dots[f], self.slashes[f], self.null[f] = dot, slash, null
                self.slot_off[f] = np.array([cx, dy, 0.0])
                self.add(dot, slash)
            else:
                t = _val(theme, fields.get(f)).move_to([cx, 0, 0])
                if t.width > w - 0.12:
                    t.scale_to_fit_width(w - 0.14)
                self.vals[f] = t
                self.slot_off[f] = np.array([cx, 0.0, 0.0])
                self.add(t)

    def set_value(self, f: str, value, animate: bool) -> list:
        old = self.vals.get(f)
        if old is None:
            return []
        new = _val(self.theme, value).scale(self.outline.height / NODE_H).move_to(old)
        if new.width > old.width * 1.6 and new.width > self.outline.width * 0.4:
            new.scale_to_fit_width(max(old.width * 1.6, self.outline.width * 0.4))
        self.vals[f] = new
        self.add(new)
        if not animate:
            old.set_opacity(0)
            return []
        # opacity, not FadeIn/FadeOut: the texts stay children of the node, so deleting the node removes them
        lift = UP * 0.16 * self.outline.height / NODE_H
        new.shift(-lift).set_opacity(0)
        return [old.animate.shift(lift).set_opacity(0), new.animate.shift(lift).set_opacity(1),
                self.outline.animate(rate_func=there_and_back).set_stroke(color=self.theme.c("gold"), width=5)]

    def set_null(self, f: str, null: bool, animate: bool) -> list:
        if f not in self.null or self.null[f] == null:
            return []
        self.null[f] = null
        if not animate:
            self.dots[f].set_opacity(0.0 if null else 1.0)
            self.slashes[f].set_stroke(opacity=1.0 if null else 0.0)
            return []
        return [self.dots[f].animate.set_opacity(0.0 if null else 1.0),
                self.slashes[f].animate.set_stroke(opacity=1.0 if null else 0.0)]

    def flash(self, color: str | None = None):
        return self.outline.animate(rate_func=there_and_back).set_stroke(color=color or self.theme.c("gold"), width=5)


# ------------------------------------------------------------- the widget

class HeapW(VGroup):
    @staticmethod
    def wanted(trace: dict) -> bool:
        evs = trace.get("events", [])
        if any(e["k"] in ("new", "delete") for e in evs):
            return True
        return bool(trace.get("heap")) and any(ref_of(v.get("value")) for v in trace.get("initial", [])) or \
            any(e["k"] in ("decl", "assign", "loop") and ref_of(e.get("value")) for e in evs)

    def __init__(self, theme: Theme, trace: dict):
        super().__init__()
        self.theme = theme
        events = trace["events"]
        sh = self.shape = Shape()
        seed = HeapModel.seed(trace)
        type_of = {ref: n["type"] for ref, n in seed.nodes.items()}
        for n in seed.nodes.values():
            sh.see(n["type"], n["fields"])
        for e in events:
            if e["k"] == "new" and isinstance(e.get("value"), dict) and "fields" in e["value"]:
                t = e.get("type") or e["value"].get("struct", "")
                type_of[e["id"]] = t
                sh.see(t, e["value"]["fields"])
            elif e["k"] == "assign" and e["path"] and e["path"][0] in type_of and len(e["path"]) == 2:
                sh.see_field(type_of[e["path"][0]], e["path"][1], e["value"])
        sh.decide()
        seed.types = set(sh.fields)
        self.doubly = sh.kind == "list" and sh.prev_f is not None

        # every value each data field takes: the widths of the node's cells
        seen: dict[tuple, list] = {}
        for ref, n in seed.nodes.items():
            for f, v in n["fields"].items():
                seen.setdefault((n["type"], f), []).append(v)
        for e in events:
            if e["k"] == "new" and e["id"] in type_of and isinstance(e.get("value"), dict):
                for f, v in e["value"].get("fields", {}).items():
                    seen.setdefault((type_of[e["id"]], f), []).append(v)
            elif e["k"] == "assign" and e["path"] and e["path"][0] in type_of and len(e["path"]) == 2:
                seen.setdefault((type_of[e["path"][0]], e["path"][1]), []).append(e["value"])
        self.widths = {}
        for (t, f), vs in seen.items():
            if f not in sh.ptrs.get(t, set()):
                self.widths[(t, f)] = max([0.9] + [_val(theme, v).width + 0.4 for v in vs if not is_ptr(v)])
        self.node_w = {t: sum(SLOT_W if f in sh.ptrs.get(t, set()) else self.widths.get((t, f), 0.9)
                              for f in sh.display_order(t)) for t in sh.fields}
        nw = max(self.node_w.values(), default=1.4)
        self.pitch = nw + (GAP if sh.kind == "list" else 0.4)
        self.label_w: dict[str, float] = {}
        self.null_w = theme.plain("nullptr", size=18, mono=True).width

        # pass 1: the model after every beat
        states = [seed.clone()]
        m = seed.clone()
        for beat in trace["beats"]:
            for i in beat:
                m.apply(events[i])
            states.append(m.clone())
        self.owned = {v for s in states for v in s.var_order}
        for v in self.owned:
            self.label_w[v] = theme.plain(v, size=MONO - 2, mono=True).width
        self.dmax = max((self._depth(s) for s in states), default=0) if sh.kind == "tree" else 0

        # pass 2: the layout of every state, for the area the structure ever needs
        x0 = y0 = np.inf
        x1 = y1 = -np.inf
        first: dict[str, tuple] = {}
        for s in states:
            lay = self.layout(s)
            boxes = [(x, y, self.node_w.get(s.nodes[n]["type"], nw), NODE_H) for n, (x, y) in lay["pos"].items()]
            for n, (x, y) in lay["pos"].items():
                first.setdefault(n, ((x, y), s.nodes[n]))
            for v, g in self.tag_layout(s, lay).items():
                (lx, ly), lw = g["label"], self.label_w.get(v, 0.5)
                boxes.append((lx, ly, lw, 0.36))
            if lay["null"] is not None:
                boxes.append((lay["null"][0], lay["null"][1], self.null_w, 0.3))
            ys = [y for _, (x, y) in lay["pos"].items()]
            if lay["curved"] and ys:                         # links that go round, under the row
                boxes.append((lay["pos"][lay["main"][0]][0] if lay["main"] else 0, min(ys) - NODE_H / 2 - 0.62,
                              0.1, 0.1))
            for (x, y, w, h) in boxes:
                x0, x1 = min(x0, x - w / 2), max(x1, x + w / 2)
                y0, y1 = min(y0, y - h / 2), max(y1, y + h / 2)
        if not np.isfinite(x0):
            x0, y0, x1, y1 = -1, -0.5, 1, 0.5
        self.local_w, self.local_c = x1 - x0, np.array([(x0 + x1) / 2, (y0 + y1) / 2, 0.0])
        self.frame = Rectangle(width=self.local_w, height=y1 - y0, stroke_width=0, fill_opacity=0)
        self.frame.move_to(self.local_c)
        self.add(self.frame)
        self.nodes: dict[str, NodeW] = {}
        for ref, ((x, y), node) in first.items():
            t = node["type"]
            nd = NodeW(theme, sh.display_order(t), sh.ptrs.get(t, set()), {f: self.widths.get((t, f), 0.9)
                                                                            for f in sh.fields.get(t, [])},
                       node["fields"], self.doubly)
            nd.move_to([x, y, 0])
            self.nodes[ref] = nd
            self.add(nd)

        # the running state
        self.model = seed
        self.lay = None
        self.shown: set[str] = set()
        self.links: dict[tuple, str] = {}
        self.arrows: dict[tuple, VGroup] = {}
        self.tags: dict[str, VGroup] = {}
        self.tag_at: dict[str, str | None] = {}
        self.null_mark = None

    # ------------------------------------------------------------- layout

    def _depth(self, m: HeapModel) -> int:
        sh = self.shape
        best = 0
        for root in m.nodes:
            stack, seen = [(root, 0)], set()
            while stack:
                n, d = stack.pop()
                if n in seen:
                    continue
                seen.add(n)
                best = max(best, d)
                for f in (sh.left_f, sh.right_f):
                    c = m.target(n, f) if f else None
                    if c:
                        stack.append((c, d + 1))
        return best

    def layout(self, m: HeapModel) -> dict:
        return self._tree(m) if self.shape.kind == "tree" else self._list(m)

    def _list(self, m: HeapModel) -> dict:
        sh, pitch = self.shape, self.pitch
        nodes = [n for n in m.order if n in m.nodes]
        nxt = {n: (m.target(n, sh.next_f) if sh.next_f else None) for n in nodes}
        incoming: dict[str, list] = {}
        for n, t in nxt.items():
            if t:
                incoming.setdefault(t, []).append(n)

        def walk(s, stop=()):
            seq, seen = [s], {s}
            t = nxt.get(s)
            while t and t not in seen and t not in stop:
                seq.append(t)
                seen.add(t)
                t = nxt.get(t)
            return seq

        avar, start = m.anchor()
        if start is not None and avar.lower() in ("last", "tail", "rear"):
            t = nxt.get(start)
            if t and start in walk(t):
                start = t                                   # circular, kept by its last node
            else:
                seen = {start}
                while len(incoming.get(start, [])) == 1 and incoming[start][0] not in seen:
                    start = incoming[start][0]
                    seen.add(start)
        if start is None and nodes:
            chains = [walk(s) for s in nodes if s not in incoming] or [walk(nodes[0])]
            start = max(chains, key=len)[0]
        main = walk(start) if start else []
        in_main = {n: i for i, n in enumerate(main)}
        # the rest: chains waiting below the row, each placed near the node it leads into
        rest = [n for n in nodes if n not in in_main]
        chains, used = [], set()
        rest_in = {t for n in rest for t in [nxt.get(n)] if t in rest}
        for s in [n for n in rest if n not in rest_in] + rest:
            if s in used:
                continue
            c = walk(s, stop=set(in_main) | used)
            c = [n for n in c if n not in used]
            used.update(c)
            j = in_main.get(nxt.get(c[-1]) or "", None)
            chains.append((c, j))
        off = max([len(c) for c, j in chains if j == 0] + [0])
        pos = {n: ((i + off) * pitch, 0.0) for i, n in enumerate(main)}
        taken: list[list] = [[], []]
        for c, j in chains:
            if j == 0:
                xs = [(off - len(c) + t) * pitch for t in range(len(c))]
            elif j is not None:
                xs = [(j + off - 0.5 - (len(c) - 1 - t)) * pitch for t in range(len(c))]
            else:
                xs = [(len(main) + off + t) * pitch for t in range(len(c))]
            level = 1
            while any(abs(x - y) < pitch * 0.9 for x in xs for y in taken[level - 1]):
                level += 1
                if level > len(taken):
                    taken.append([])
            taken[level - 1] += xs
            for n, x in zip(c, xs):
                pos[n] = (x, -WAIT * level)
        circular = bool(main) and nxt.get(main[-1]) == main[0]
        null = None
        if main and not circular:
            last = pos[main[-1]][0] + self.node_w.get(m.nodes[main[-1]]["type"], 1.4) / 2
            null = (last + 0.45 + self.null_w / 2, 0.0)
        elif any(m.vars.get(v) is None for v in m.var_order):
            null = (off * pitch, 0.0)
        return {"pos": pos, "null": null, "curved": circular or self.doubly, "main": main}

    def _tree(self, m: HeapModel) -> dict:
        sh, pitch = self.shape, self.pitch
        nodes = [n for n in m.order if n in m.nodes]
        kids = {n: (m.target(n, sh.left_f), m.target(n, sh.right_f)) for n in nodes}
        parent = {}
        for n, (l, r) in kids.items():
            for c in (l, r):
                if c and c not in parent:
                    parent[c] = n
        _, root = m.anchor()
        seen = set()
        while root in parent and root not in seen:
            seen.add(root)
            root = parent[root]
        if root is None:
            roots = [n for n in nodes if n not in parent]
            root = roots[0] if roots else (nodes[0] if nodes else None)
        depth_cap = min(self.dmax, 3)
        pos: dict[str, tuple] = {}

        def place(n, d, x):
            if n in pos:
                return
            pos[n] = (x, -d * LEVEL)
            off = pitch * 2 ** (depth_cap - d - 2) if depth_cap - d - 2 >= -1 else pitch / 2
            for c, sgn in zip(kids[n], (-1, 1)):
                if c:
                    place(c, d + 1, x + sgn * off)
        if root:
            place(root, 0, 0.0)
        right = max([x for x, _ in pos.values()] + [0.0])
        k = 0
        for n in nodes:
            if n not in pos:                                 # not linked in yet: waits to the right
                k += 1
                place(n, 0, right + pitch * k)
                right = max([x for x, _ in pos.values()] + [right])
        null = None
        if any(m.vars.get(v) is None for v in m.var_order):
            left = min([x for x, _ in pos.values()] + [0.0])
            null = (left - self.pitch * 0.5 - self.null_w / 2 - 0.4, 0.0)
        return {"pos": pos, "null": null, "curved": False, "main": [root] if root else []}

    def tag_layout(self, m: HeapModel, lay: dict) -> dict:
        """Where each pointer variable's label sits and where its arrow lands, in local units."""
        at: dict = {}
        for v in m.var_order:
            t = m.vars.get(v)
            key = t if t in lay["pos"] else (None if t is None and lay["null"] is not None else "-")
            if key == "-":
                continue                                     # aims at freed memory: no label
            at.setdefault(key, []).append(v)
        out = {}
        for key, names in at.items():
            if key is None:
                (x, y), w = lay["null"], self.null_w
                h = 0.3
            else:
                (x, y), w = lay["pos"][key], self.node_w.get(m.nodes[key]["type"], 1.4)
                h = NODE_H
            # lists: above the row (below a waiting node); trees: under the node, inside the V of its
            # two child links, where nothing else is drawn
            tree = self.shape.kind == "tree"
            below = tree or y < -0.01
            rise = 0.5 if tree else TAG_RISE
            widths = [self.label_w.get(v, 0.5) for v in names]
            total = sum(widths) + 0.3 * (len(names) - 1)
            cx = x - total / 2
            for v, lw in zip(names, widths):
                lx = cx + lw / 2
                cx += lw + 0.3
                ly = y - h / 2 - rise if below else y + h / 2 + rise
                tail = (lx, ly + (0.17 if below else -0.2))
                out[v] = {"label": (lx, ly), "tail": tail, "box": ((x, y), w, h)}
        return out

    # ------------------------------------------------------------ drawing

    @property
    def s(self) -> float:
        return self.frame.width / self.local_w

    def _w(self, p) -> np.ndarray:
        return self.frame.get_center() + (np.array([p[0], p[1], 0.0]) - self.local_c) * self.s

    def _link_points(self, key: tuple, target: str, pos: dict) -> tuple[list, bool]:
        n, f = key
        s = self.s
        src = self.nodes[n]
        start = pos[n] + src.slot_off[f] * s
        dst_c = pos[target]
        dst_w, h = self.nodes[target].w * s, NODE_H * s
        sh = self.shape
        if sh.kind == "list":
            same_row = abs(dst_c[1] - pos[n][1]) < 0.05 * s
            backward = dst_c[0] < pos[n][0] - 0.05 * s
            if same_row and (target == n or (backward and f == sh.next_f) or
                             (f == sh.prev_f and abs(abs(dst_c[0] - pos[n][0]) - self.pitch * s) > 0.1 * s)):
                # around: under the row, back to the target
                down = 0.62 * s
                end = dst_c + np.array([-0.18 * s if f == sh.next_f else 0.18 * s, -h / 2, 0])
                p0 = start
                return [p0, p0 + DOWN * (down + h / 2), end + DOWN * down, end], True
            if f == sh.prev_f or (self.doubly and f == sh.next_f and same_row):
                lane = LANE * s * (1 if f == sh.next_f else -1)
                toward = np.array([start[0], dst_c[1] + lane, 0])
                end = edge_point(dst_c, dst_w, h, toward)
                end[1] = dst_c[1] + lane
                return [start, end], False
        end = edge_point(dst_c, dst_w, h, start)
        return [start, end], False

    def _arrow_for(self, key: tuple, target: str, pos: dict) -> VGroup:
        pts, _ = self._link_points(key, target, pos)
        color = self.theme.c("blue") if key[1] != self.shape.prev_f else self.theme.c("purple")
        return arrow(pts, color, self.s)

    def _tag_mob(self, var: str, g: dict, label=None) -> VGroup:
        s = self.s
        color = self.theme.c("gold" if var.lower() in HEAD_NAMES else "teal")
        if label is None:
            label = self.theme.plain(var, size=MONO - 2, color=color, mono=True).scale(s)
        else:
            label = label.copy()
        label.move_to(self._w(g["label"]))
        tail = self._w(g["tail"])
        (bx, by), bw, bh = g["box"]
        tip = edge_point(self._w((bx, by)), bw * s, bh * s, tail)
        d = tip - tail
        tip = tip - d / max(np.linalg.norm(d), 1e-9) * 0.05 * s
        return VGroup(label, arrow([tail, tip], color, s, width=2.6))

    def _null_mob(self, at) -> VGroup:
        t = self.theme.plain("nullptr", size=18, color="muted", mono=True).scale(self.s)
        return t.move_to(self._w(at))

    # ------------------------------------------------------------- beats

    def initial(self) -> list:
        """What is on the heap when the listing starts (nodes made by earlier listings)."""
        return self._sync(animate=False)

    def beat(self, events: list[dict]) -> list:
        m = self.model
        created, deleted, values = [], [], {}
        for e in events:
            k = e["k"]
            if k == "new" and e["id"] in self.nodes:
                created.append(e["id"])
            elif k == "delete" and e.get("id") in m.nodes:
                deleted.append(e["id"])
            elif k == "assign" and e["path"] and e["path"][0] in m.nodes and len(e["path"]) == 2 \
                    and not is_ptr(e["value"]):
                values.setdefault(e["path"][0], {})[e["path"][1]] = e["value"]
            m.apply(e)
        return self._sync(animate=True, created=created, deleted=deleted, values=values)

    def _sync(self, animate: bool, created=(), deleted=(), values=None) -> list:
        """Bring the screen to the model. Animated: the animations of the change. Not animated
        (the first frame of a listing): the mobjects to show, already in place."""
        m, sh = self.model, self.shape
        values = values or {}
        lay = self.layout(m)
        pos = {n: self._w(p) for n, p in lay["pos"].items()}
        now, late, appear = [], [], []

        def show(mob, anim, after: bool = False):
            if not animate:
                appear.append(mob)
            else:
                (late if after else now).append(anim)

        def change(anim):
            if animate and anim is not None:
                now.append(anim)

        for n in deleted:
            if n in self.shown:
                nd = self.nodes[n]
                nd.outline.set_stroke(self.theme.c("red"), width=4.5)
                change(FadeOut(nd, scale=0.55))
                self.shown.discard(n)
        for n, p in pos.items():
            nd = self.nodes.get(n)
            if nd is None:
                continue
            fields = m.nodes[n]["fields"]
            if n not in self.shown:                          # appears where it belongs
                nd.move_to(p)
                for f in nd.null:
                    nd.set_null(f, ref_of(fields.get(f)) is None, animate=False)
                show(nd, FadeIn(nd, scale=0.7))
                self.shown.add(n)
                continue
            moving = np.linalg.norm(nd.get_center() - p) > 1e-3
            for f, v in values.get(n, {}).items():
                now.extend(nd.set_value(f, v, animate=animate and not moving))
            for f in nd.null:
                now.extend(nd.set_null(f, ref_of(fields.get(f)) is None, animate=animate and not moving))
            if moving:
                if animate:
                    now.append(nd.animate.move_to(p))
                else:
                    nd.move_to(p)
        # links
        links = {}
        for n in pos:
            for f in sh.ptr_fields(m.nodes[n]["type"]):
                t = m.target(n, f)
                if t in pos:
                    links[(n, f)] = t
        for key in list(self.arrows):
            if key not in links:
                change(FadeOut(self.arrows.pop(key)))
        for key, t in links.items():
            new = self._arrow_for(key, t, pos)
            old = self.arrows.get(key)
            if old is None:
                self.arrows[key] = new
                show(new, Create(new), after=True)
            elif self.links.get(key) != t or np.linalg.norm(old[0].get_end() - new[0].get_end()) > 1e-3 or \
                    np.linalg.norm(old[0].get_start() - new[0].get_start()) > 1e-3:
                change(Transform(old, new))
        self.links = links
        # pointer variables
        tags = self.tag_layout(m, lay)
        for v in list(self.tags):
            if v not in tags:
                change(FadeOut(self.tags.pop(v)))
        for v, g in tags.items():
            old = self.tags.get(v)
            new = self._tag_mob(v, g, None if old is None else old[0])
            if old is None:
                self.tags[v] = new
                show(new, FadeIn(new, shift=DOWN * 0.15 * self.s), after=True)
            elif np.linalg.norm(old.get_center() - new.get_center()) > 1e-3 or \
                    np.linalg.norm(old[1][0].get_end() - new[1][0].get_end()) > 1e-3:
                change(Transform(old, new))
        # the nullptr mark
        if lay["null"] is not None:
            mark = self._null_mob(lay["null"])
            if self.null_mark is None:
                self.null_mark = mark
                show(mark, FadeIn(mark))
            elif np.linalg.norm(self.null_mark.get_center() - mark.get_center()) > 1e-3:
                change(self.null_mark.animate.move_to(mark.get_center()))
        elif self.null_mark is not None:
            change(FadeOut(self.null_mark))
            self.null_mark = None
        self.lay = lay
        if not animate:
            return appear
        from .viz import within
        if not late:
            return now
        if not now:
            return late
        # things move first; new links and labels are drawn once their ends have arrived
        return [within(a, 0.0, 0.6) for a in now] + [within(a, 0.5, 1.0) for a in late]

    # ----------------------------------------------------------- queries

    def node(self, ref: str) -> NodeW | None:
        return self.nodes.get(ref) if ref in self.shown else None

    def free_side(self, ref: str):
        """A side of a node with nothing drawn on it, for a tick or a cross."""
        if self.shape.kind == "tree":
            return RIGHT
        y = (self.lay or {}).get("pos", {}).get(ref, (0, 0))[1]
        return UP if y < -0.01 else DOWN                     # labels sit above the row, below the waiting row

    def tag(self, var: str) -> VGroup | None:
        return self.tags.get(var)
