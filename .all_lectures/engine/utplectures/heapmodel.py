"""The heap as the viewer sees it: nodes made with new, and the pointer variables aimed at them.

Both the narration (trace.py) and the picture (render/heap.py) replay a trace's
events through one HeapModel, so what is said and what is drawn always agree.
It also decides the shape of the structure from the nodes' pointer fields:

    list    one "next" pointer (plus an optional "prev": a doubly linked list)
    tree    two child pointers ("left"/"right", or any two that are not next/prev)
"""

from __future__ import annotations

import copy
import re

REF = re.compile(r"#\d+")
LEFT_SIDE = ("left", "prev", "previous", "lchild", "leftchild", "l")
PREV_NAMES = ("prev", "previous", "back")
NEXT_NAMES = ("next", "link", "nxt", "forward")
HEAD_NAMES = ("head", "first", "front", "top", "root", "start", "list", "lst", "last", "tail", "rear")
TAIL_NAMES = ("last", "tail", "rear")


def is_ptr(v) -> bool:
    return isinstance(v, dict) and "ptr" in v


def ref_of(v) -> str | None:
    """The node a pointer value names ('#3'); None for nullptr or a pointer to anything else."""
    if is_ptr(v) and v["ptr"] and REF.fullmatch(str(v["ptr"])):
        return v["ptr"]
    return None


class Shape:
    """Field order and pointer roles of the node types in a trace."""

    def __init__(self):
        self.fields: dict[str, list[str]] = {}       # type -> field names, in declaration order
        self.ptrs: dict[str, set] = {}               # type -> pointer fields
        self.kind = "list"
        self.next_f: str | None = None
        self.prev_f: str | None = None
        self.left_f: str | None = None
        self.right_f: str | None = None

    def see(self, ntype: str, fields: dict) -> None:
        names = self.fields.setdefault(ntype, [])
        for k, v in fields.items():
            if k not in names:
                names.append(k)
            if is_ptr(v):
                self.ptrs.setdefault(ntype, set()).add(k)

    def see_field(self, ntype: str, name: str, value) -> None:
        if name not in self.fields.setdefault(ntype, []):
            self.fields[ntype].append(name)
        if is_ptr(value):
            self.ptrs.setdefault(ntype, set()).add(name)

    def decide(self) -> None:
        ptrs = sorted({p for s in self.ptrs.values() for p in s},
                      key=lambda p: min((f.index(p) for f in self.fields.values() if p in f), default=99))
        kids = [p for p in ptrs if p.lower() not in NEXT_NAMES + PREV_NAMES]
        if len(kids) >= 2:
            self.kind = "tree"
            left = next((p for p in kids if p.lower() in LEFT_SIDE), kids[0])
            right = next((p for p in kids if p != left and p.lower() in ("right", "rchild", "rightchild", "r")),
                         next(p for p in kids if p != left))
            self.left_f, self.right_f = left, right
            return
        self.kind = "list"
        self.next_f = next((p for p in ptrs if p.lower() in NEXT_NAMES), None) or \
            next((p for p in ptrs if p.lower() not in PREV_NAMES), None)
        self.prev_f = next((p for p in ptrs if p.lower() in PREV_NAMES), None)

    def ptr_fields(self, ntype: str) -> list[str]:
        return [f for f in self.fields.get(ntype, []) if f in self.ptrs.get(ntype, set())]

    def data_fields(self, ntype: str) -> list[str]:
        return [f for f in self.fields.get(ntype, []) if f not in self.ptrs.get(ntype, set())]

    def display_order(self, ntype: str) -> list[str]:
        """[left pointers] [data] [other pointers]: prev | value | next, left | data | right."""
        ptrs = self.ptr_fields(ntype)
        lefts = [p for p in ptrs if p.lower() in LEFT_SIDE]
        return lefts + self.data_fields(ntype) + [p for p in ptrs if p not in lefts]


class HeapModel:
    def __init__(self):
        self.nodes: dict[str, dict] = {}       # id -> {"type": T, "fields": {name: snapshot}}
        self.order: list[str] = []             # creation order
        self.vars: dict[str, str | None] = {}  # pointer variable -> node id (None: nullptr)
        self.var_order: list[str] = []
        self.stack: list[dict] = []            # the caller's pointer variables, during a call
        self.freed: list[str] = []
        self.types: set[str] = set()           # node types: a null "Node*" is a heap pointer too

    @classmethod
    def seed(cls, trace: dict) -> "HeapModel":
        """The heap as it was when the listing started (nodes from earlier listings)."""
        m = cls()
        for ref, v in (trace.get("heap") or {}).items():
            if isinstance(v, dict) and "fields" in v:
                m.nodes[ref] = {"type": v.get("struct", ""), "fields": copy.deepcopy(v["fields"])}
                m.order.append(ref)
                m.types.add(v.get("struct", ""))
        for e in trace.get("events", []):
            if e["k"] == "new" and isinstance(e.get("value"), dict) and "struct" in e["value"]:
                m.types.add(e.get("type") or e["value"]["struct"])
        for v in trace.get("initial", []):
            if m.node_pointer(v.get("value"), v.get("type", "")):
                m.set_var(v["name"], v["value"])
        return m

    def node_pointer(self, value, vtype: str = "") -> bool:
        """A pointer to a node, or a null pointer of a node type."""
        if ref_of(value):
            return True
        return is_ptr(value) and value["ptr"] is None and str(vtype).replace("*", "").strip() in self.types

    def clone(self) -> "HeapModel":
        return copy.deepcopy(self)

    def set_var(self, name: str, value) -> None:
        if name not in self.vars:
            self.var_order.append(name)
        self.vars[name] = ref_of(value)

    def drop_var(self, name: str) -> None:
        self.vars.pop(name, None)
        if name in self.var_order:
            self.var_order.remove(name)

    def apply(self, e: dict) -> None:
        k = e["k"]
        if k == "new":
            v = e.get("value")
            if isinstance(v, dict) and "fields" in v:
                self.nodes[e["id"]] = {"type": e.get("type", v.get("struct", "")), "fields": copy.deepcopy(v["fields"])}
                self.types.add(self.nodes[e["id"]]["type"])
                if e["id"] not in self.order:
                    self.order.append(e["id"])
        elif k == "delete":
            if e.get("id") in self.nodes:
                del self.nodes[e["id"]]
                self.freed.append(e["id"])
        elif k == "decl":
            if not e.get("dims") and self.node_pointer(e.get("value"), e.get("type", "")):
                self.set_var(e["name"], e["value"])
        elif k == "loop":
            if ref_of(e.get("value")) or (e["var"] in self.vars and is_ptr(e.get("value"))):
                self.set_var(e["var"], e["value"])
        elif k == "assign":
            p = e["path"]
            if p and p[0] in self.nodes and len(p) == 2:
                self.nodes[p[0]]["fields"][p[1]] = copy.deepcopy(e["value"])
            elif len(p) == 1 and (ref_of(e["value"]) or (p[0] in self.vars and is_ptr(e["value"]))):
                self.set_var(p[0], e["value"])
        elif k == "call":
            self.stack.append({"vars": dict(self.vars), "order": list(self.var_order)})
            for name, v in zip(e.get("params") or [], e.get("args") or []):
                if ref_of(v) or (is_ptr(v) and v["ptr"] is None and self.types):
                    self.set_var(name, v)
        elif k == "leave" and self.stack:
            saved = self.stack.pop()
            self.vars, self.var_order = saved["vars"], saved["order"]

    # ----------------------------------------------------------- questions

    def target(self, ref: str, field: str) -> str | None:
        node = self.nodes.get(ref)
        t = ref_of(node["fields"].get(field)) if node else None
        return t if t in self.nodes else None

    def anchor(self) -> tuple[str | None, str | None]:
        """(variable, node) the structure hangs from: head, root, top ... or the first pointer declared."""
        live = [v for v in self.var_order if self.vars.get(v) in self.nodes]
        heads = [v for v in live if v.lower() in HEAD_NAMES and v.lower() not in TAIL_NAMES]
        tails = [v for v in live if v.lower() in TAIL_NAMES]
        var = (heads or tails or live or [None])[0]
        return var, (self.vars.get(var) if var else None)

    def label(self, ref: str | None) -> str:
        """A node named by its first data field: '12'."""
        node = self.nodes.get(ref or "")
        if node:
            for v in node["fields"].values():
                if not is_ptr(v):
                    return _say(v)
        return "a node"

    def describe(self, ref: str | None, avoid: str | None = None) -> str:
        """How narration names a node: 'head' when a head-like variable aims at it, else 'the node holding 12'."""
        if ref is None:
            return "null"
        for v in self.var_order:
            if v != avoid and self.vars.get(v) == ref and v.lower() in HEAD_NAMES:
                return v
        return f"the node holding {self.label(ref)}"


def _say(v) -> str:
    from .minicpp import speak
    return speak(v)
