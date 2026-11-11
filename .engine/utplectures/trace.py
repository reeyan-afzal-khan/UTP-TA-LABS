"""Code that runs on screen: execution traces, grouped into beats, with narration.

The code scenes of a lecture are run in order by the small interpreter in
minicpp.py, sharing variables like a reader's mental model of the chapter
(the array declared in one listing is searched in the next). Each run gives
events; events are grouped into *beats* (one visible change: a variable
appears, a field is filled, the loop moves on and compares, a line is
printed). The script builder narrates the beats; the renderer animates them.
"""

from __future__ import annotations

import re

from .codeinfo import _function_sentence, count_word, say_list
from .heapmodel import HeapModel, is_ptr, ref_of
from .typst.inline import code_to_speech
from .minicpp import CppError, Interpreter, format_path, names_used, show, speak
from .script_marks import SHOW

TRACEABLE = {"cpp", "c", "c++"}


# -------------------------------------------------------------------- running

class Tracer:
    """Runs a lecture's listings in order, keeping what earlier listings declared."""

    def __init__(self):
        self.interp = Interpreter()

    def trace(self, lang: str | None, code: str) -> dict | None:
        """{"events", "beats", "initial"} for one listing, or None when it cannot be run."""
        if (lang or "").lower() not in TRACEABLE:
            return None
        interp = self.interp
        used = names_used(code)
        before = {n: (interp.globals[n].type, _snap(interp.globals[n])) for n in used if n in interp.globals}
        heap = _reachable(interp.heap, [v for _, v in before.values()])  # nodes earlier listings made
        try:
            events = interp.run(code)
        except CppError:
            return None
        if not events:
            return None
        declared = {e["name"] for e in events if e["k"] == "decl"}
        initial = [{"name": n, "type": t, "value": v} for n, (t, v) in before.items() if n not in declared]
        events, beats = _cap(events, group_beats(events))
        return {"events": events, "beats": beats, "initial": initial, "heap": heap}


def _snap(v):
    from .minicpp import snap
    return snap(v)


def _reachable(heap: dict, values: list) -> dict:
    """The heap nodes a listing can reach from the variables it uses (not every node ever made)."""
    out: dict = {}
    todo: list = []

    def refs(v):
        if isinstance(v, dict):
            if "ptr" in v:
                if v["ptr"] in heap and v["ptr"] not in out:
                    todo.append(v["ptr"])
            else:
                for x in v.values():
                    refs(x)
        elif isinstance(v, list):
            for x in v:
                refs(x)

    refs(values)
    while todo:
        ref = todo.pop()
        if ref in out:
            continue
        out[ref] = _snap(heap[ref])
        refs(out[ref])
    return out


MAX_BEATS = 90                      # a listing that runs longer is shown up to here (a sentence says so)


def _cap(events: list[dict], beats: list[list[int]]) -> tuple[list[dict], list[list[int]]]:
    """Keep the first MAX_BEATS beats of a long run (whole programs, big loops)."""
    if len(beats) <= MAX_BEATS:
        return events, beats
    beats = beats[:MAX_BEATS]
    last = max(i for b in beats for i in b)
    return events[:last + 1], beats


def group_beats(events: list[dict]) -> list[list[int]]:
    """Group events into beats: each beat is one thing the viewer sees change."""
    beats: list[list[int]] = []
    in_iteration = False            # the current beat is a loop pass that may still take its if-check
    has_if = False
    pending_new = None              # a node just made: joined by the pointer that receives it
    held: list[int] = []            # a node's constructor at work: shown with its new
    for k, e in enumerate(events):
        kind = e["k"]
        if e.get("ctor"):
            held.append(k)
            continue
        if kind == "new" and held:
            beats.append(held + [k])
            held = []
            pending_new = e["id"]
            in_iteration, has_if = False, False
            continue
        if held:                                # (a constructor not followed by its new: keep its beats)
            beats.extend([i] for i in held)
            held = []
        if kind == "leave" and beats:
            beats[-1].append(k)                 # back from a call: nothing new to see
            continue
        if pending_new is not None and kind in ("decl", "assign") and \
                isinstance(e.get("value"), dict) and e["value"].get("ptr") == pending_new:
            beats[-1].append(k)                 # Node* head = new Node{...}: one moment
            pending_new = None
            continue
        pending_new = e["id"] if kind == "new" else None
        if kind == "cond" and e.get("kind") == "loop":
            if beats and e.get("result", True):
                beats[-1].append(k)
                continue
            if beats and not e.get("result", True):
                beats.append([k])               # the loop is over
                in_iteration, has_if = False, False
                continue
        if kind == "loopend" and beats:
            beats[-1].append(k)
            continue
        if kind == "assign" and e.get("step"):
            beats.append([k])                   # ++i: the start of the next pass
            in_iteration, has_if = True, False
            continue
        if kind == "loop":
            if beats and in_iteration and len(beats[-1]) == 1 and events[beats[-1][0]]["k"] == "assign":
                beats[-1].append(k)
            elif beats and events[beats[-1][-1]]["k"] == "decl" and events[beats[-1][-1]]["name"] == e["var"] \
                    and events[beats[-1][-1]].get("scope") == "local":
                beats[-1].append(k)             # for (int i = 0; ...): the declaration and the first pass
            else:
                beats.append([k])
            in_iteration, has_if = True, False
            continue
        if kind == "cond" and e.get("kind") == "if" and in_iteration and not has_if and beats:
            beats[-1].append(k)
            has_if = True
            continue
        if kind == "decl" and e.get("scope") == "local" and k + 1 < len(events) and events[k + 1]["k"] == "loop":
            beats.append([k])                   # joined by the loop event that follows
            in_iteration, has_if = True, False
            continue
        beats.append([k])
        if kind not in ("print",):
            in_iteration = in_iteration and kind == "cond"
    return beats


# ------------------------------------------------------------------ narration

PHRASES = {"==": ("matches", "is not"), "!=": ("differs from", "equals"), "<": ("is less than", "is not less than"),
           "<=": ("is at most", "is more than"), ">": ("is greater than", "is not greater than"),
           ">=": ("is at least", "is less than")}
LHS_ARROW = re.compile(r"^\s*(\w+)\s*->\s*(\w+)\s*[-+*/]?=[^=]")


def _printed(text: str) -> str:
    t = " ".join(text.split())
    if not t:
        return "a blank line"
    return t if len(t) <= 48 else "a line of output"


def _beat_kind(events: list[dict], beat: list[int]) -> str:
    kinds = [events[i]["k"] for i in beat]
    if "new" in kinds:
        return "new"
    if "loop" in kinds or ("assign" in kinds and events[beat[0]].get("step")):
        return "pass"
    return kinds[0]


def _node_label(value) -> str:
    for v in ((value or {}).get("fields") or {}).values():
        if not is_ptr(v):
            return speak(v)
    return "nothing yet"


def _say(name) -> str:
    return code_to_speech(str(name)).strip()


class _Speaker:
    """Says values and places, naming heap nodes the way the picture shows them:
    'head', 'the node holding 25', "node 12's next"."""

    def __init__(self, trace: dict):
        events, beats = trace["events"], trace["beats"]
        m = HeapModel.seed(trace)
        heapy = bool(trace.get("heap")) or any(e["k"] in ("new", "delete") for e in events)
        self.before, self.after = [], []
        for b in beats:
            self.before.append(m.clone() if heapy else m)
            for i in b:
                m.apply(events[i])
            self.after.append(m.clone() if heapy else m)

    def value(self, v, k: int, avoid: str | None = None, when: str = "after") -> str:
        st = (self.after if when == "after" else self.before)[k]
        ref = ref_of(v)
        if ref:
            return st.describe(ref, avoid) if ref in st.nodes else "freed memory"
        if is_ptr(v):
            return "null" if v["ptr"] is None else _say(v["ptr"])
        return speak(v)

    def short(self, v, k: int) -> str:
        ref = ref_of(v)
        st = self.after[k]
        if ref:
            return st.label(ref) if ref in st.nodes else "freed memory"
        return "null" if is_ptr(v) and v["ptr"] is None else speak(v)

    def place(self, e: dict, k: int) -> str:
        """The field an assignment writes: "head's next", "node 25's next"."""
        path = e["path"]
        field = _say(path[-1])
        m = LHS_ARROW.match(e.get("src", ""))
        if m and len(path) == 2 and m.group(2) == str(path[-1]):
            return f"{_say(m.group(1))}'s {field}"
        st = self.before[k]
        owner = st.describe(path[0])
        if owner.startswith("the node holding"):
            return f"node {st.label(path[0])}'s {field}"
        return f"{_say(owner)}'s {field}"


def narrate(trace: dict, code: str, first_line: int = 1) -> list[dict]:
    """Cues for a traced listing: [{"say": ..., "beats": [a, b]}], [show] before every beat after the first."""
    events, beats = trace["events"], trace["beats"]
    sp = _Speaker(trace)
    lines = code.split("\n")
    cues: list[dict] = []
    n = len(beats)

    def ev(b: int) -> dict:
        return events[beats[b][0]]

    def cmp(e: dict, k: int) -> str:
        op = e.get("op")
        if not op:
            return f"{_say(e.get('src', 'the condition'))} is {'true' if e['result'] else 'false'}"
        yes, no = PHRASES[op]
        return f"{sp.value(e['left']['value'], k)} {yes if e['result'] else no} {sp.value(e['right']['value'], k)}"

    def plain_decl(e: dict, k: int) -> bool:
        v = e.get("value")
        return e["k"] == "decl" and len(beats[k]) == 1 and v is not None and \
            (not isinstance(v, dict) or "char" in v) and not e.get("const") and not e.get("dims")

    def decl_sentence(e: dict, k: int) -> str:
        v = e.get("value")
        name = _say(e["name"])
        if is_ptr(v):
            return f"{name} points to {sp.value(v, k, avoid=e['name'])}." if ref_of(v) else f"{name} starts as null."
        if isinstance(v, dict) and "array" in v:
            items = v["items"]
            if items and isinstance(items[0], dict) and "struct" in items[0]:
                return (f"{name} holds {count_word(len(items))} {_say(e['type'])} records, "
                        f"at indices 0 to {len(items) - 1}.")
            if len(items) <= 6:
                return f"{name} holds {say_list([speak(x) for x in items])}."
            return f"{name} holds {count_word(len(items))} values."
        if e.get("const"):
            return f"{name} is a constant, {speak(v)}."
        if v is None:
            return f"Declare {name}."
        return f"Set {name} to {speak(v)}."

    def assign_sentence(e: dict, k: int) -> str:
        p, v = e["path"], e["value"]
        if p and isinstance(p[0], str) and p[0].startswith("#"):
            place = sp.place(e, k)
            if is_ptr(v):
                return f"{place} becomes null." if v["ptr"] is None else f"{place} now points to {sp.value(v, k)}."
            return f"{place} becomes {speak(v)}."
        if len(p) == 1 and is_ptr(v) and (ref_of(v) or p[0] in sp.before[k].vars):
            name = _say(p[0])
            if v["ptr"] is None:
                return f"{name} becomes null."
            target = sp.value(v, k, avoid=p[0])
            return f"{name} moves to {target}." if sp.before[k].vars.get(p[0]) else f"{name} now points to {target}."
        return f"{_say(format_path(p))} becomes {sp.value(v, k)}."

    def new_sentence(be: list[dict], k: int) -> str:
        e_new = next(x for x in be if x["k"] == "new")
        what = f"a new node holding {_node_label(e_new.get('value'))}"
        tgt = next((x for x in be if x["k"] in ("decl", "assign") and isinstance(x.get("value"), dict)
                    and x["value"].get("ptr") == e_new["id"]), None)
        if tgt is None:
            return f"{what[0].upper()}{what[1:]} is made on the heap."
        if tgt["k"] == "decl":
            return f"{_say(tgt['name'])} points to {what}."
        if len(tgt["path"]) == 1:
            return f"{_say(tgt['path'][0])} now points to {what}."
        return f"{sp.place(tgt, k)} points to {what}."

    def single(k: int) -> str:
        be = [events[i] for i in beats[k]]
        e = be[0]
        kind = _beat_kind(events, beats[k])
        if kind == "new":
            return new_sentence(be, k)
        if kind == "delete":
            return f"Delete frees the node holding {sp.before[k].label(e.get('id'))}."
        if kind == "decl":
            return decl_sentence(e, k)
        if kind == "assign":
            return assign_sentence(e, k)
        if kind == "print":
            return f"It prints {_printed(e['text'])}."
        if kind == "cond":
            if e.get("kind") == "loop" and not e["result"]:
                return "The condition fails, so the loop ends."
            return f"Check: {cmp(e, k)}."
        if kind == "break":
            return "Break leaves the loop."
        if kind == "return":
            return f"It returns {sp.value(e.get('value'), k)}."
        if kind == "call":
            return f"Call {_say(e['name'])}."
        return "Run it."

    def ends_next(k: int) -> bool:
        """Is the next beat the loop's condition failing?"""
        if k + 1 >= n:
            return False
        nb = [events[i] for i in beats[k + 1]]
        return nb[0]["k"] == "cond" and nb[0].get("kind") == "loop" and not nb[0]["result"]

    def pass_piece(k: int, passes: int) -> tuple[str, bool]:
        """(words for one pass of a loop, whether they already say the loop ends)."""
        be = [events[i] for i in beats[k]]
        loop_ev = next((x for x in be if x["k"] == "loop"), None)
        var = _say(loop_ev["var"]) if loop_ev else "the index"
        val = loop_ev["value"] if loop_ev else None
        check = next((x for x in be if x["k"] == "cond" and x.get("kind") == "if"), None)
        tail = f": {cmp(check, k)}." if check else "."
        ending = ends_next(k)
        if is_ptr(val):
            where = sp.short(val, k)
            if val["ptr"] is None:
                return f"{var} reaches null, so the loop ends.", ending
            if ending:
                return f"{var} moves to {where}, and the loop ends.", True
            if passes == 0:
                return f"{var} starts at the node holding {where}{tail}", False
            if passes == 1:
                return f"Then {var} moves on to {where}{tail}", False
            if passes < 3 or k >= n - 3:
                return f"Next, {var} moves to {where}{tail}", False
            return "", False
        idx = speak(val) if loop_ev else "the next value"
        if ending:
            return f"{var} reaches {idx}, so the loop ends.", True
        if passes == 0:
            return f"The loop starts with {var} at {idx}{tail}", False
        if passes == 1:
            return f"Next, {var} is {idx}{tail}", False
        if passes < 3 or k >= n - 3:
            return f"Then {var} is {idx}{tail}", False
        return "", False

    k = 0
    while k < n:
        e = ev(k)
        kind = _beat_kind(events, beats[k])
        # struct definition and its fields
        if kind == "struct":
            fields = [events[beats[j][0]] for j in range(k + 1, n) if ev(j)["k"] == "field"
                      and ev(j)["struct"] == e["name"]]
            parts = [f"{SHOW} {_say(f['name'])}" for f in fields]
            if len(parts) > 1:
                listed = ", ".join(parts[:-1]) + ", and " + parts[-1]
            else:
                listed = parts[0] if parts else ""
            say = (f"The struct {_say(e['name'])} groups {count_word(len(fields))} "
                   f"field{'s' if len(fields) != 1 else ''}: {listed}.")
            cues.append({"say": say, "beats": [k, k + len(fields)]})
            k += 1 + len(fields)
            continue
        if kind == "func":
            body = lines[e["line"]:e["end"] - 1] if e.get("end") else []
            params = [_say(p[1]) for p in e.get("params", [])]
            cues.append({"say": _function_sentence(e["name"], params, body, e.get("ret", "")), "beats": [k, k]})
            k += 1
            continue
        # a struct variable declared and then filled in, field by field
        if kind == "decl" and isinstance(e.get("value"), dict) and "struct" in e["value"] and not e.get("dims"):
            j = k + 1
            fills = []
            while j < n and ev(j)["k"] == "assign" and ev(j)["path"][0] == e["name"] and len(ev(j)["path"]) == 2:
                fills.append(ev(j))
                j += 1
            say = f"Declare a {_say(e['type'])} called {e['name']}."
            if fills:
                bits = [f"{SHOW} {_say(f['path'][1])} {speak(f['value'])}" for f in fills]
                listed = ", ".join(bits[:-1]) + (", and " if len(bits) > 1 else "") + bits[-1]
                say += f" Then fill in its fields: {listed}."
            cues.append({"say": say, "beats": [k, j - 1]})
            k = j
            continue
        # a few plain variables in a row: one sentence
        if plain_decl(e, k):
            j = k
            while j < n and j - k < 4 and plain_decl(ev(j), j):
                j += 1
            if j - k > 1:
                bits = [f"{_say(ev(i)['name'])} is {speak(ev(i)['value'])}" for i in range(k, j)]
                bits = [b if i == 0 else f"{SHOW} {b}" for i, b in enumerate(bits)]
                say = ", ".join(bits[:-1]) + ", and " + bits[-1] + "."
                cues.append({"say": say, "beats": [k, j - 1]})
                k = j
                continue
        if kind == "pass":
            # the whole loop as one cue: each pass, its check, then what it does
            start = k
            loop0 = next((events[i] for i in beats[k] if events[i]["k"] == "loop"), None)
            end_line = (loop0 or {}).get("end") or 10 ** 6
            pieces: list[str] = []
            passes = 0
            quiet_pass = False
            skip_end = False
            while k < n:
                kd = _beat_kind(events, beats[k])
                if kd == "pass":
                    lp = next((events[i] for i in beats[k] if events[i]["k"] == "loop"), None)
                    if passes and lp is not None and lp.get("end") and lp["end"] != end_line:
                        break                                 # another loop: its own cue
                    piece, skip_end = pass_piece(k, passes)
                    quiet_pass = not piece
                    passes += 1
                elif skip_end and kd == "cond":
                    piece, skip_end = "", False               # already said: the loop ends
                elif kd == "print" and quiet_pass:
                    piece = ""
                else:
                    piece = single(k)
                pieces.append(piece)
                k += 1
                if kd == "break" or (k < n and ev(k)["line"] > end_line and _beat_kind(events, beats[k]) != "pass"):
                    break
            say = ""
            for j, p in enumerate(pieces):
                if not p:
                    continue
                say += (" " if say else "") + (f"{SHOW} " if j > 0 else "") + p
            # beats without words are spread between their neighbours by the renderer
            cues.append({"say": say, "beats": [start, k - 1],
                         "silent": [start + j for j, p in enumerate(pieces) if not p]})
            continue
        cues.append({"say": single(k), "beats": [k, k]})
        k += 1
    return cues


def _fix_case(text: str) -> str:
    return text[:1].upper() + text[1:] if text else text
