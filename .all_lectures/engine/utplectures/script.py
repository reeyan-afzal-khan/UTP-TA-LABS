"""The lecture script: what is shown and what is said, scene by scene.

The script is generated from the LaTeX and saved next to the video as
<name>.script.yaml. It is the place to refine a lecture: change the wording
of the narration ('say'), the text on screen, or the order of scenes, then
rebuild. The engine regenerates the script whenever the LaTeX changes, unless
you have edited it; then it keeps your version and tells you the source moved
on (rebuild with --rescript to start again from the LaTeX).

Scene types: title, guide, section, prose, bullets, callout, code, table,
figure, math, outro. Within a scene, each cue (a stretch of narration)
reveals the next step (the next bullet, table row, part of a box ...) as it
starts; write [show] inside a cue's text to reveal another step at that word.
A code cue with 'lines: [a, b]' highlights those lines while it is spoken.
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import Any

import yaml

from . import ENGINE_VERSION
from .codeinfo import LANGUAGE_NAMES, STYLE_LANGUAGES, code_steps, lexer_name, say_list, split_listing
from .courses import Lecture
from .latex.blocks import (Block, BlockParser, Callout, CodeBlock, FigureBlock, Guide, Heading, InputRef,
                           LabBanner, ListBlock, MathBlock, Para, TableBlock)
from .beats import item_show, paragraph_show
from .latex.inline import InlineContext, convert, math_to_speech, split_sentences_latex
from .latex.reader import split_top_level
from .ops import detect as detect_operations
from .paths import LECTURES
from .trace import Tracer, narrate


def load_demos(lecture: Lecture) -> list[dict]:
    """The demos for one lecture from .all_lectures/<course>/demos.yaml: {<tex stem>: [{after, say, code}]}."""
    path = LECTURES / lecture.course.slug / "demos.yaml"
    if not path.exists():
        return []
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    return [d for d in (data.get(lecture.source.stem) or []) if isinstance(d, dict)]


def strip_markup(markup: str) -> str:
    import html
    return html.unescape(re.sub(r"<[^>]*>", "", markup or ""))

SCRIPT_VERSION = 2
from .script_marks import SHOW  # noqa: E402  (re-exported)


# ------------------------------------------------------------------ helpers

def words(text: str) -> int:
    return len(re.findall(r"\w+", text))


def sha1(data: Any) -> str:
    raw = data if isinstance(data, (bytes, str)) else json.dumps(data, sort_keys=True, ensure_ascii=False)
    if isinstance(raw, str):
        raw = raw.encode("utf-8")
    return hashlib.sha1(raw).hexdigest()[:16]


def balanced(items: list, per: int) -> list[list]:
    """Split into pages of at most `per`, as evenly as possible (7 -> 4 + 3, not 6 + 1)."""
    if not items:
        return []
    pages = -(-len(items) // per)
    size = -(-len(items) // pages)
    return [items[k:k + size] for k in range(0, len(items), size)]


def _cap(s: str) -> str:
    return s[:1].upper() + s[1:] if s else s


def _end(s: str) -> str:
    """Make a spoken fragment end like a sentence."""
    s = s.strip()
    if s and s[-1] not in ".!?:":
        s += "."
    return s


class ScriptBuilder:
    def __init__(self, lecture: Lecture, settings: dict):
        self.lec = lecture
        self.course = lecture.course
        self.settings = settings
        self.cfg = settings.get("script", {})
        theme = settings.get("theme", {})
        # colours inline text may use (\term is navy in the book): theme.markup maps them for the screen
        self.colors = {k: v for k, v in theme.items() if isinstance(v, str) and v.startswith("#")}
        self.colors.update(theme.get("markup", {}))
        self.mono = theme.get("mono", "Source Code Pro")
        self.tracer = Tracer()                            # runs the lecture's listings in order
        self.ctx = InlineContext(self.course.labels, self.course.macros)
        m = re.search(r"\\lstset\{[^}]*style=(\w+)", self.course.main_tex)
        self.default_lexer = STYLE_LANGUAGES.get(m.group(1), "text") if m else "text"
        self.scenes: list[dict] = []
        self.figures: dict[str, FigureBlock] = {}     # figure key -> its LaTeX (kept out of the YAML)
        self.cue_no = 0
        self.section = ""          # header text for the scenes that follow
        self.sec_numbers = [0, 0, 0]
        self.next_lab: Lecture | None = None
        self.skip_boxes = set(self.cfg.get("skip_boxes") or [])
        self.demos = load_demos(lecture) if self.cfg.get("demos", True) else []
        self.waiting: list[dict] = []    # demos to play when the current heading's part ends

    # ------------------------------------------------------------ conversion

    def md(self, tex: str, ctx: InlineContext | None = None) -> str:
        return convert(tex, ctx or self.ctx, self.colors, self.mono)[0]

    def sp(self, tex: str, ctx: InlineContext | None = None) -> str:
        return convert(tex, ctx or self.ctx, self.colors, self.mono)[1]

    def plain(self, tex: str) -> str:
        return convert(tex, self.ctx, self.colors, self.mono)[2]

    def cue(self, say: str, **extra) -> dict:
        self.cue_no += 1
        c = {"id": f"{self.cue_no:03d}", "say": re.sub(r"\s+", " ", say).strip()}
        c.update({k: v for k, v in extra.items() if v is not None})
        return c

    def scene(self, type_: str, cues: list[dict], frame: dict | None = None, **data) -> dict:
        s = {"id": f"s{len(self.scenes) + 1:02d}", "type": type_, "section": self.section}
        if frame:
            s["frame"] = frame
        s.update({k: v for k, v in data.items() if v is not None})
        s["cues"] = cues
        self.scenes.append(s)
        return s

    # ------------------------------------------------------------------ build

    def build(self) -> dict:
        lec = self.lec
        text = lec.source.read_text(encoding="utf-8")
        parser = BlockParser(self.course.styles)
        blocks = parser.parse_file(text)
        order = self.course.lectures
        idx = order.index(lec)
        if lec.kind == "chapter" and lec.labs:
            self.next_lab = lec.labs[0]
        following = order[idx + 1] if idx + 1 < len(order) else None

        self._flow(blocks, frame=None, top=True)
        self._play_demos()
        self._outro(following)
        script = {
            "version": SCRIPT_VERSION,
            "engine": ENGINE_VERSION,
            "lecture": {
                "course": self.course.slug,
                "course_title": self.course.title,
                "source": lec.source.relative_to(self.course.folder).as_posix(),
                "kind": lec.kind,
                "label": lec.label,
                "title": self.plain(lec.title),
            },
            "fingerprint": {"source": sha1([text, self.demos]) if self.demos else sha1(text)},
            "scenes": self.scenes,
        }
        script["fingerprint"]["script"] = sha1(self.scenes)
        return script

    # ------------------------------------------------------------------- flow

    def _flow(self, blocks: list[Block], frame: dict | None, top: bool = False,
              intro_say: str | None = None) -> None:
        """Turn a run of blocks into scenes, attaching lead-in and follow-up paragraphs."""
        lead: dict[int, int] = {}       # block index -> index of the paragraph that introduces it
        trail: dict[int, int] = {}      # block index -> index of the paragraph that follows it up
        for i, b in enumerate(blocks[:-1]):
            nxt = blocks[i + 1]
            if not isinstance(b, Para):
                continue
            p = self.plain(b.tex).rstrip()
            if isinstance(nxt, (ListBlock, TableBlock)) and p.endswith(":"):
                lead[i + 1] = i
            elif isinstance(nxt, CodeBlock) and (p.endswith(":") or words(p) <= 45):
                lead[i + 1] = i
            elif isinstance(nxt, FigureBlock) and nxt.label and nxt.label in b.tex:
                lead[i + 1] = i
        for i, b in enumerate(blocks[:-1]):
            nxt = blocks[i + 1]
            if not isinstance(nxt, Para) or (i + 1) in lead.values():
                continue
            p = self.plain(nxt.tex).rstrip()
            if isinstance(b, FigureBlock) and b.label and b.label in nxt.tex:
                trail[i] = i + 1
            elif isinstance(b, CodeBlock) and words(p) <= 30 and not p.endswith(":"):
                trail[i] = i + 1
        attached = set(lead.values()) | set(trail.values())

        pending_intro = intro_say
        for i, b in enumerate(blocks):
            if i in attached:
                continue
            before = len(self.scenes)
            lp = blocks[lead[i]] if i in lead else None
            tp = blocks[trail[i]] if i in trail else None
            stop = self._block(b, frame, lp, tp, pending_intro)
            if pending_intro and len(self.scenes) > before:
                pending_intro = None
            if stop:
                break

    def _prefix(self, cues: list[dict], intro_say: str | None) -> None:
        if intro_say and cues:
            cues[0]["say"] = _end(intro_say) + " " + cues[0]["say"]

    def _block(self, b: Block, frame, lead_para: Para | None, trail_para: Para | None,
               intro_say: str | None) -> bool:
        if isinstance(b, Heading):
            self._heading(b)
        elif isinstance(b, LabBanner):
            self._lab_banner(b)
        elif isinstance(b, Guide):
            self._guide(b)
        elif isinstance(b, Para):
            self._prose(b.tex, frame, intro_say)
        elif isinstance(b, ListBlock):
            self._bullets(b, frame, lead_para, intro_say)
        elif isinstance(b, Callout):
            if b.env not in self.skip_boxes:             # boxes about the book, not the topic: not in videos
                self._callout(b, frame, intro_say)
        elif isinstance(b, CodeBlock):
            self._code(b, frame, lead_para, trail_para, intro_say)
        elif isinstance(b, TableBlock):
            self._table(b, frame, lead_para, intro_say)
        elif isinstance(b, FigureBlock):
            self._figure(b, frame, lead_para, trail_para, intro_say)
        elif isinstance(b, MathBlock):
            cues = [self.cue(_cap(math_to_speech(b.tex)) + ".")]
            self._prefix(cues, intro_say)
            self.scene("math", cues, frame, tex=b.tex)
        elif isinstance(b, InputRef):
            return b.path.startswith("labs/")              # the lab gets its own video
        return False

    # -------------------------------------------------------------- headings

    def _heading(self, h: Heading) -> None:
        self._play_demos()                               # the part before this heading is over
        title_md, title_say = self.md(h.title), self.sp(h.title)
        if h.level == 0:
            label = self.lec.label
            self.section = ""
            kicker = self.course.title
            self.scene("title", [self.cue(f"{label}: {_end(title_say)}")], kicker=kicker, label=label,
                       title=title_md)
            return
        level = min(h.level, 3)
        number = None
        if not h.starred and self.lec.number:
            if level == 1:
                self.sec_numbers = [self.sec_numbers[0] + 1, 0, 0]
                number = f"{self.lec.number}.{self.sec_numbers[0]}"
            elif level == 2:
                self.sec_numbers[1] += 1
                self.sec_numbers[2] = 0
                number = f"{self.lec.number}.{self.sec_numbers[0]}.{self.sec_numbers[1]}"
        plain = self.plain(h.title)
        if level == 1:
            self.section = f"{number}  {plain}" if number else plain
        self.scene("section", [self.cue(_end(title_say))], number=number, title=title_md, level=level)
        key = " ".join(plain.lower().split())
        self.waiting += [d for d in self.demos if " ".join(str(d.get("after", "")).lower().split()) == key
                         and d.get("code")]

    # ----------------------------------------------------------------- demos

    def _play_demos(self) -> None:
        """Code written for the video (demos.yaml), run and narrated like the book's own listings."""
        waiting, self.waiting = self.waiting, []
        for d in waiting:
            before = len(self.scenes)
            cb = CodeBlock(str(d["code"]).rstrip(), language=d.get("language", "C++"))
            self._code(cb, None, None, None, d.get("say"))
            for sc in self.scenes[before:]:
                sc["demo"] = True

    def _lab_banner(self, b: LabBanner) -> None:
        total = self.course.lab_total
        label = f"Lab {b.number} of {total}" if total else f"Lab {b.number}"
        self.section = self.plain(b.title)
        self.scene("title", [self.cue(f"Lab {b.number}: {_end(self.sp(b.title))}")],
                   kicker="Practical milestone", label=label, title=self.md(b.title))

    def _guide(self, g: Guide) -> None:
        pieces = [p.strip() for p in split_top_level(g.outcomes.strip().rstrip("."), ",")]
        pieces = [re.sub(r"^and\s+", "", p) for p in pieces if p]
        if not (2 <= len(pieces) <= 7 and all(words(self.plain(p)) >= 2 for p in pieces)):
            pieces = [g.outcomes.strip().rstrip(".")]
        outcomes = [_cap(self.md(p)) for p in pieces]
        spoken = [self.sp(p) for p in pieces]
        if len(spoken) > 1:
            body = ", ".join(SHOW + " " + s for s in spoken[:-1]) + ", and " + SHOW + " " + spoken[-1] + "."
        else:
            body = SHOW + " " + _end(spoken[0])
        what = "lab" if self.lec.kind == "lab" else "chapter"
        cues = [self.cue("Before you start: " + _end(self.sp(g.before))),
                self.cue(f"By the end of this {what}, you can " + body)]
        self.scene("guide", cues, before=self.md(g.before), outcomes=outcomes)

    # ------------------------------------------------------------------ prose

    def _prose(self, tex: str, frame, intro_say: str | None) -> None:
        sentences = split_sentences_latex(tex)
        if not sentences:
            return
        limit = int(self.cfg.get("prose_words_per_card", 70))
        cards: list[list[str]] = [[]]
        for s in sentences:
            if cards[-1] and sum(words(self.plain(x)) for x in cards[-1]) + words(self.plain(s)) > limit:
                cards.append([])
            cards[-1].append(s)
        for k, card in enumerate(cards):
            say = f" {SHOW} ".join(self.sp(s) for s in card)        # each sentence brings its own words on screen
            cues = [self.cue(say)]
            if k == 0:
                self._prefix(cues, intro_say)
            self.scene("prose", cues, frame, show=paragraph_show(card, self.ctx, self.colors, self.mono))

    # ----------------------------------------------------------------- lists

    def _list_items(self, lb: ListBlock, depth: int = 0) -> list[dict]:
        out = []
        for n, item in enumerate(lb.items, 1):
            text_tex = item.tex
            entry = {"text": item_show(text_tex, self.ctx, self.colors, self.mono)}
            if lb.kind == "description" and item.label:
                entry["term"] = self.md(item.label)
            elif item.label:
                entry["mark"] = self.plain(item.label)
            if depth:
                entry["depth"] = depth
            spoken = self.sp(text_tex)
            if lb.kind == "description" and item.label:
                spoken = f"{_end(self.sp(item.label))[:-1]}: {spoken}"
            elif lb.kind == "steps":
                spoken = f"Step {n}: {spoken}"
            entry["_say"] = _end(spoken.rstrip(";,").rstrip()) if spoken else ""
            out.append(entry)
            for child in item.children:
                if isinstance(child, ListBlock):
                    out.extend(self._list_items(child, depth + 1))
                elif isinstance(child, Para):
                    out.append({"text": self.md(child.tex), "depth": depth + 1,
                                "_say": _end(self.sp(child.tex))})
        return out

    def _operations(self, names: list[str], texts: list[str], says: list[str], frame, lead_para: Para | None,
                    intro_say: str | None) -> bool:
        """A list or table of data-structure operations becomes a live demonstration."""
        context = self.plain(lead_para.tex) if lead_para is not None else ""
        found = detect_operations(names, context + " " + self.section)
        if found is None:
            return False
        subject, ops = found
        cues = []
        if lead_para is not None:
            cues.append(self.cue(self.sp(lead_para.tex)))
        items = []
        for name, text, say, op in zip(names, texts, says, ops):
            items.append({"op": op or "", "name": name, "text": text})
            cues.append(self.cue(say or name))
        self._prefix(cues, intro_say)
        intro = paragraph_show([lead_para.tex], self.ctx, self.colors, self.mono, longest=20)[0] \
            if lead_para is not None else None
        self.scene("operations", cues, frame, subject=subject, intro=intro if lead_para is not None else None,
                   items=items)
        return True

    def _bullets(self, lb: ListBlock, frame, lead_para: Para | None, intro_say: str | None,
                 style: str | None = None) -> None:
        items = self._list_items(lb)
        if not any(it.get("depth") for it in items):
            names = [strip_markup(it.get("term") or it["text"]).rstrip(".;") for it in items]
            if self._operations(names, [it["text"] for it in items], [it["_say"] for it in items], frame,
                                lead_para, intro_say):
                return
        style = style or {"enumerate": "number", "steps": "number", "description": "term"}.get(lb.kind, "dot")
        pages = balanced(items, int(self.cfg.get("list_items_per_card", 6))) or [[]]
        for p, page in enumerate(pages):
            cues = []
            intro = None
            if p == 0 and lead_para is not None:
                intro = self.md(lead_para.tex)
                cues.append(self.cue(self.sp(lead_para.tex)))
            for it in page:
                cues.append(self.cue(it.pop("_say") or "…"))
            if p == 0:
                self._prefix(cues, intro_say)
            start = sum(len(x) for x in pages[:p]) + 1 if style == "number" and p else None
            self.scene("bullets", cues, frame, intro=intro, style=style, start=start, items=page)

    # --------------------------------------------------------------- callouts

    def _callout(self, c: Callout, frame, intro_say: str | None) -> None:
        styles = self.course.styles
        title_tex = styles.title_tex(c.env, c.args)
        title_md = self.md(title_tex)
        title_say = self.sp(title_tex)
        speak_title = bool(self.cfg.get("speak_box_titles", True)) and title_say
        simple = all(isinstance(b, (Para, ListBlock, MathBlock)) for b in c.blocks)
        total_words = sum(words(self.plain(b.tex)) for b in c.blocks if isinstance(b, Para))
        total_items = sum(len(b.items) for b in c.blocks if isinstance(b, ListBlock))
        too_big = total_words > 120 or total_items > 7 or total_words + 12 * total_items > 150
        think = c.env in self.cfg.get("think_after", [])
        intro = (_end(intro_say) + " " if intro_say else "") + (_end(title_say) + " " if speak_title else "")

        if simple and not too_big and c.blocks:
            parts: list[dict] = []
            cues: list[dict] = []
            k = 0
            blocks = list(c.blocks)
            while k < len(blocks):
                b = blocks[k]
                if isinstance(b, Para):
                    say = self.sp(b.tex)
                    nxt = blocks[k + 1] if k + 1 < len(blocks) else None
                    if isinstance(nxt, MathBlock) and not re.search(r"[.!?]\s*$", self.plain(b.tex)):
                        # "... the relationship as" + equation: one sentence, the equation is what is shown
                        parts.append({"kind": "math", "tex": nxt.tex})
                        say = say.rstrip(":") + " " + _end(math_to_speech(nxt.tex))
                        k += 1
                    else:
                        sentences = split_sentences_latex(b.tex)
                        parts.append({"kind": "text", "show": paragraph_show(sentences, self.ctx, self.colors,
                                                                             self.mono, longest=40)})
                        say = f" {SHOW} ".join(self.sp(x) for x in sentences)
                    cues.append(self.cue(say))
                elif isinstance(b, ListBlock):
                    for it in self._list_items(b):
                        say = it.pop("_say")
                        parts.append({"kind": "item", **it, "style": "number" if b.kind in ("enumerate", "steps") else
                                      ("term" if b.kind == "description" else "dot")})
                        cues.append(self.cue(say or "…"))
                elif isinstance(b, MathBlock):
                    parts.append({"kind": "math", "tex": b.tex})
                    cues.append(self.cue(_cap(_end(math_to_speech(b.tex)))))
                k += 1
            if cues:
                cues[0]["say"] = intro + cues[0]["say"]
            if think:
                cues[-1]["pause"] = float(self.settings.get("pacing", {}).get("think_pause", 4.0))
            self.scene("callout", cues, frame, box=c.env, title=title_md, parts=parts)
            return

        # A box with code, tables or figures inside, or too much for one card:
        # its contents become scenes of their own, framed by the box's title.
        inner = {"box": c.env, "title": title_md}
        self._flow(c.blocks, inner, intro_say=intro.strip() or None)
        if think and self.scenes:
            self.scenes[-1]["cues"][-1]["pause"] = float(self.settings.get("pacing", {}).get("think_pause", 4.0))

    # ------------------------------------------------------------------- code

    def _code(self, cb: CodeBlock, frame, lead_para: Para | None, trail_para: Para | None,
              intro_say: str | None) -> None:
        lexer = lexer_name(cb.language) if cb.language else (
            STYLE_LANGUAGES.get(cb.style or "", None) or self.default_lexer)
        if cb.style in ("utpbash", "utpterminal", "utpbashnumbered"):
            lexer = "bash"
        name = LANGUAGE_NAMES.get(lexer, lexer.upper() if len(lexer) <= 3 else lexer.title())
        max_lines = int(self.cfg.get("code_lines_per_card", 16))
        chunks = split_listing(cb.code.rstrip(), max_lines)
        for n, (first, code) in enumerate(chunks):
            steps = code_steps(code, lexer, first)
            trace = self.tracer.trace(lexer, code)
            cues = []
            lead = None
            if n == 0 and lead_para is not None:
                lead = self.md(lead_para.tex)
                cues.append(self.cue(self.sp(lead_para.tex)))
            elif n == 0 and trace is None:
                cues.append(self.cue("Here are the commands." if lexer == "bash" else
                                     (f"Here it is in {name}." if name else "Here is the code.")))
            if trace is not None:
                # the listing runs on screen: narrate what happens, beat by beat
                for st in steps:
                    if st["say"].startswith("It includes"):
                        cues.append(self.cue(st["say"], lines=st["lines"]))
                for c in narrate(trace, code, first):
                    cues.append(self.cue(c["say"], beats=c["beats"], quiet=c.get("silent") or None))
            elif len(steps) == 1 and n == 0 and len(chunks) == 1 and \
                    steps[0]["lines"][1] - steps[0]["lines"][0] + 1 >= len(code.split("\n")) - 1:
                cues.append(self.cue(steps[0]["say"]))        # one definition: no need to highlight it
            else:
                for st in steps:
                    cues.append(self.cue(st["say"], lines=st["lines"]))
            if n > 0 and not steps and trace is None:
                cues.append(self.cue("The listing continues."))
            note = None
            if n == len(chunks) - 1 and trail_para is not None:
                note = self.md(trail_para.tex)
                cues.append(self.cue(self.sp(trail_para.tex)))
            if n == 0:
                self._prefix(cues, intro_say)
            self.scene("code", cues, frame, language=lexer, label=name or None, first_line=first,
                       lead=lead, note=note, code=code)

    # ------------------------------------------------------------------ table

    def _table(self, t: TableBlock, frame, lead_para: Para | None, intro_say: str | None) -> None:
        header = [[self.md(c) for c in row] for row in t.header]
        head_plain = [self.plain(c) for c in t.header[-1]] if t.header else []
        if t.rows and all(len(r) >= 2 for r in t.rows) and max(len(r) for r in t.rows) == 2:
            names = [self.plain(r[0]) for r in t.rows]
            says = [f"{self.sp(r[0]).rstrip('.')}: {_end(self.sp(r[1]))}" for r in t.rows]
            if self._operations(names, [self.md(r[1]) for r in t.rows], says, frame, lead_para, intro_say):
                return
        cols = t.columns or []
        ncols = max([len(r) for r in t.rows + t.header] or [1])
        while len(cols) < ncols:
            from .latex.blocks import Column
            cols.append(Column())
        columns = [{"width": c.width, "align": c.align, "bold": c.bold, "color": c.color} for c in cols[:ncols]]
        pages = balanced(t.rows, int(self.cfg.get("table_rows_per_card", 7))) or [[]]
        for p, page in enumerate(pages):
            cues = []
            intro = None
            if p == 0 and lead_para is not None:
                intro = self.md(lead_para.tex)
                cues.append(self.cue(self.sp(lead_para.tex)))
            elif p == 0 and ncols > 2 and head_plain:
                cues.append(self.cue(f"This table compares {say_list(head_plain[1:])}, "
                                     f"{head_plain[0].lower()} by {head_plain[0].lower()}."))
            for row in page:
                spoken = [self.sp(c) for c in row]
                if ncols == 2 or not head_plain:
                    say = f"{spoken[0].rstrip('.')}: {_end(' '.join(spoken[1:]))}"
                else:
                    bits = [_end(spoken[0]).rstrip(".") + "."]
                    for h, c in zip(head_plain[1:], spoken[1:]):
                        if c:
                            bits.append(f"{h}: {_end(c)}")
                    say = " ".join(bits)
                cues.append(self.cue(say))
            if p == 0:
                self._prefix(cues, intro_say)
            self.scene("table", cues, frame, intro=intro, columns=columns, header=header,
                       rows=[[self.md(c) for c in r] for r in page])

    # ----------------------------------------------------------------- figure

    def _figure(self, f: FigureBlock, frame, lead_para: Para | None, trail_para: Para | None,
                intro_say: str | None) -> None:
        ctx = self.ctx.with_self(f.label)
        number = self.course.labels.get(f.label or "", None)
        cues = []
        if lead_para is not None:
            cues.append(self.cue(_cap(self.sp(lead_para.tex, ctx))))
        caption_md = self.md(f.caption, ctx) if f.caption else None
        if f.caption:
            cues.append(self.cue(_cap(self.sp(f.caption, ctx))))
        elif f.title:
            cues.append(self.cue(_end(self.sp(f.title))))
        if trail_para is not None:
            cues.append(self.cue(_cap(self.sp(trail_para.tex, ctx))))
        if not cues:
            cues.append(self.cue("Take a look at this figure."))
        self._prefix(cues, intro_say)
        key = sha1(f.body)[:12]
        self.figures[key] = f
        self.scene("figure", cues, frame, figure=key, label=f.label, number=number,
                   title=self.md(f.title or f.short or "") or None, caption=caption_md)

    # ------------------------------------------------------------------ outro

    def _outro(self, following: Lecture | None) -> None:
        lec = self.lec
        title = self.plain(lec.title)
        if lec.kind == "chapter":
            done = f"That brings us to the end of {lec.label}, {_end(title)}"
        else:
            done = f"That's the end of {lec.label}, {_end(title)}"
        nxt_md = None
        say = done
        target = self.next_lab or following
        if target is not None:
            t = self.plain(target.title)
            if lec.kind == "chapter" and target.kind == "lab":
                say += f" Next, {target.label} puts it into practice: {_end(t)}"
            else:
                say += f" Next up: {target.label}, {_end(t)}"
            nxt_md = f"{target.label} · {self.md(target.title)}"
        self.section = ""
        self.scene("outro", [self.cue(say)], label=lec.label, title=self.md(lec.title), next=nxt_md)


# ---------------------------------------------------------------------- I/O

class _Dumper(yaml.SafeDumper):
    def ignore_aliases(self, data):          # write repeated values out, never as &id001 anchors
        return True


def _str_rep(dumper, data: str):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


_Dumper.add_representer(str, _str_rep)


HEADER = """\
# Lecture script for {source} ({label}: {title})
#
# Generated from the LaTeX by the UTP lecture engine (.all_lectures/engine).
# Edit it to refine the video: 'say' is the narration, the other fields are
# what appears on screen ('show' = the few words shown per spoken sentence:
# a headline, [chips], or '' for nothing new). Each cue reveals the next step
# of its scene as it starts; [show] inside 'say' reveals another step at that
# word. On code: 'beats: [a, b]' plays steps of the running code, 'lines: [a, b]'
# highlights lines. See .all_lectures/engine/README.md.
#
# Once you edit this file the engine keeps your version, even when the LaTeX
# changes (it warns you). Rebuild with --rescript to regenerate it.
"""


def dump_script(script: dict, path: Path) -> None:
    lec = script["lecture"]
    head = HEADER.format(source=lec["source"], label=lec["label"], title=lec["title"])
    body = yaml.dump(script, Dumper=_Dumper, sort_keys=False, allow_unicode=True, width=110)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(head + "\n" + body, encoding="utf-8")


def load_script(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def is_edited(script: dict) -> bool:
    return sha1(script.get("scenes", [])) != script.get("fingerprint", {}).get("script")


def prepare_script(lecture: Lecture, settings: dict, rescript: bool = False,
                   log=print) -> tuple[dict, dict[str, FigureBlock]]:
    """The script to render, regenerated from the LaTeX unless you have edited it,
    and the LaTeX of its figures (by figure key and by label)."""
    builder = ScriptBuilder(lecture, settings)
    fresh = builder.build()
    figures = dict(builder.figures)
    figures.update({f.label: f for f in builder.figures.values() if f.label})
    path = lecture.script_path
    if path.exists() and not rescript:
        current = load_script(path)
        if current and is_edited(current):
            if current.get("fingerprint", {}).get("source") != fresh["fingerprint"]["source"]:
                log(f"  ! {path.name}: you edited this script and the LaTeX has changed since; "
                    f"keeping your version (use --rescript to regenerate)")
            else:
                log(f"  using your edited script {path.name}")
            return current, figures
        if current == fresh:
            return current, figures
    dump_script(fresh, path)
    log(f"  wrote {path.relative_to(path.parents[2]).as_posix()}")
    return fresh, figures
