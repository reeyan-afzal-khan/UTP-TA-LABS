"""Block-level reading: a chapter or lab file -> a list of content blocks."""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from .reader import Source, find_env_end, read_args, read_group, skip_space, split_top_level
from .styles import StyleBook

# ------------------------------------------------------------------ blocks


@dataclass
class Block:
    pass


@dataclass
class Heading(Block):
    level: int                      # 0 chapter, 1 section, 2 subsection, 3 subsubsection/paragraph
    title: str                      # LaTeX
    starred: bool = False
    label: str | None = None


@dataclass
class LabBanner(Block):
    number: str
    title: str
    label: str | None = None


@dataclass
class Guide(Block):
    before: str
    outcomes: str


@dataclass
class Para(Block):
    tex: str


@dataclass
class ListItem:
    tex: str                        # the item's own text
    label: str | None = None        # description term or \item[..]
    children: list[Block] = field(default_factory=list)


@dataclass
class ListBlock(Block):
    kind: str                       # itemize | enumerate | description | steps
    items: list[ListItem]


@dataclass
class Callout(Block):
    env: str
    args: list[str | None]
    blocks: list[Block]


@dataclass
class CodeBlock(Block):
    code: str
    language: str | None = None
    style: str | None = None
    caption: str | None = None


@dataclass
class Column:
    width: float | None = None      # fraction of the line width, None = share the rest
    align: str = "l"
    bold: bool = False
    color: str | None = None


@dataclass
class TableBlock(Block):
    columns: list[Column]
    header: list[list[str]]
    rows: list[list[str]]


@dataclass
class FigureBlock(Block):
    body: str                       # LaTeX drawn by the book's preamble (tikz, pgfplots, tabular ...)
    caption: str | None = None
    short: str | None = None
    label: str | None = None
    title: str | None = None        # utpfigure's title bar
    image: str | None = None        # \includegraphics path when the figure is just an image


@dataclass
class MathBlock(Block):
    tex: str


@dataclass
class InputRef(Block):
    path: str


# ---------------------------------------------------------------- the parser

LIST_ENVS = {"itemize": "itemize", "enumerate": "enumerate", "description": "description",
             "utpsteps": "steps", "compactitem": "itemize", "compactenum": "enumerate"}
MATH_ENVS = {"equation", "equation*", "align", "align*", "gather", "gather*", "multline", "multline*",
             "displaymath", "eqnarray", "eqnarray*", "flalign", "flalign*"}
TABLE_ENVS = {"tabular", "tabularx", "tabular*", "longtable", "tabulary"}
FIGURE_ENVS = {"tikzpicture", "axis"}
TRANSPARENT_ENVS = {"minipage", "center", "flushleft", "flushright", "samepage", "small", "footnotesize",
                    "adjustbox", "multicols", "quote", "quotation", "landscape", "raggedright"}
SKIP_ENVS = {"comment", "figure*"}
HEADINGS = {"chapter": 0, "section": 1, "subsection": 2, "subsubsection": 3, "paragraph": 3}
# Block macros that expand to plain LaTeX before parsing (from utpnotes.tex).
EXPANSIONS: dict[str, tuple[str, str]] = {
    "labflow": ("mmm", "\n\n\\textbf{Chapter connection.} #1\n\n\\textbf{Goal.} #2\n\n\\textbf{Explain.} #3\n\n"),
    "labsourcecard": ("mmm", "\n\n\\textbf{#1 --- #2}\n\n\\textbf{Inspect.} #3\n\n"),
    "expectedoutput": ("", "\n\n\\textbf{Reference output.}\n\n"),
    "fignote": ("m", "\n\n#1\n\n"),
    "kagglesource": ("mm", "\n\n\\textbf{Dataset.} #2\n\n"),
}
# Commands that start a block (and so end a paragraph).
BLOCK_COMMANDS = set(HEADINGS) | {"labsection", "chapterguide", "input", "include", "sourceimage",
                                  "compactsourceimage", "part", "item", "begin"}
# Commands that are layout only.
SILENT = {"medskip": "", "smallskip": "", "bigskip": "", "noindent": "", "par": "", "clearpage": "",
          "newpage": "", "cleardoublepage": "", "phantomsection": "", "centering": "",
          "addcontentsline": "mmm", "markboth": "mm", "vspace": "sm", "labcovers": "m",
          "FloatBarrier": "", "coretag": "", "latertag": "", "pagebreak": "o", "needspace": "m",
          "nopagebreak": "o", "setlength": "mm", "lstset": "m", "captionsetup": "om", "label": "m",
          "thispagestyle": "m", "pagestyle": "m", "vfill": "", "hfill": ""}


class BlockParser:
    def __init__(self, styles: StyleBook):
        self.styles = styles
        self.source: Source | None = None

    def parse_file(self, text: str) -> list[Block]:
        self.source = Source(text)
        body = self._expand(self.source.text)
        return self.parse(body)

    # ------------------------------------------------------------- expansion

    def _expand(self, s: str) -> str:
        for name, (spec, template) in EXPANSIONS.items():
            pattern = re.compile(r"\\" + name + r"(?![A-Za-z])")
            while True:
                m = pattern.search(s)
                if not m:
                    break
                args, end = read_args(s, m.end(), spec)
                out = template
                for k, a in enumerate(args, 1):
                    out = out.replace(f"#{k}", a or "")
                s = s[:m.start()] + out + s[end:]
        return s

    # ----------------------------------------------------------------- blocks

    def parse(self, s: str) -> list[Block]:
        blocks: list[Block] = []
        para: list[str] = []

        def flush() -> None:
            text = "".join(para).strip()
            para.clear()
            if re.sub(r"\\(?:medskip|smallskip|bigskip|noindent|par|centering)\b|\s", "", text):
                blocks.append(Para(text))

        i, n = 0, len(s)
        while i < n:
            if s.startswith("\n\n", i) or (s[i] == "\n" and not "".join(para).strip()):
                flush()
                i += 1
                continue
            if s.startswith("\\[", i):
                flush()
                end = s.find("\\]", i + 2)
                end = n if end < 0 else end
                blocks.append(MathBlock(s[i + 2:end].strip()))
                i = end + 2
                continue
            if s.startswith("$$", i):
                flush()
                end = s.find("$$", i + 2)
                end = n if end < 0 else end
                blocks.append(MathBlock(s[i + 2:end].strip()))
                i = end + 2
                continue
            if s[i] == "\\":
                m = re.match(r"\\([A-Za-z@]+)(\*?)", s[i:])
                if m:
                    name, star = m.group(1), m.group(2)
                    j = i + len(m.group(0))
                    handled = self._block_command(name, star, s, j, blocks, flush)
                    if handled is not None:
                        i = handled
                        continue
                    if name in SILENT:
                        _, i = read_args(s, j, SILENT[name])
                        if name == "par":
                            flush()
                        continue
                # an ordinary inline command: copy it, with any braced group right after it
                para.append(s[i:i + (len(m.group(0)) if m else 2)])
                i += len(m.group(0)) if m else 2
                continue
            if s[i] == "{":
                group, j = read_group(s, i)
                para.append(s[i:j])
                i = j
                continue
            para.append(s[i])
            i += 1
        flush()
        return blocks

    def _block_command(self, name, star, s, j, blocks, flush):
        if name in HEADINGS:
            flush()
            (opt, title), end = read_args(s, j, "om")
            label = None
            k = skip_space(s, end)
            if s.startswith("\\label", k):
                (label,), end = read_args(s, k + 6, "m")
            blocks.append(Heading(HEADINGS[name], title or "", bool(star), label))
            return end
        if name == "labsection":
            flush()
            (num, title, label), end = read_args(s, j, "mmm")
            blocks.append(LabBanner(num or "", title or "", label))
            return end
        if name == "chapterguide":
            flush()
            (a, b), end = read_args(s, j, "mm")
            blocks.append(Guide(a or "", b or ""))
            return end
        if name in ("input", "include"):
            flush()
            (path,), end = read_args(s, j, "m")
            blocks.append(InputRef(path or ""))
            return end
        if name in ("sourceimage", "compactsourceimage"):
            flush()
            (_, title, path), end = read_args(s, j, "omm")
            blocks.append(FigureBlock(body="\\includegraphics[width=0.9\\linewidth]{" + (path or "") + "}",
                                      title=title, image=path))
            return end
        if name == "part":
            flush()
            _, end = read_args(s, j, "om")
            return end
        if name == "begin":
            (env,), end = read_args(s, j, "m")
            body_start = end
            body_end, after = find_env_end(s, env, body_start)
            body = s[body_start:body_end]
            flush()
            self._environment(env, body, blocks)
            return after
        return None

    # ----------------------------------------------------------- environments

    def _environment(self, env: str, body: str, blocks: list[Block]) -> None:
        if env == "lstlisting":
            opts = ""
            b = body.lstrip()
            if b.startswith("["):
                opts, k = read_group(b, 0, "[", "]")
                b = b[k:]
            code = self.source.verbatim_text(b) if self.source else b
            o = dict(re.findall(r"(\w+)\s*=\s*\{?([^,}\]]*)\}?", opts))
            blocks.append(CodeBlock(code, o.get("language"), o.get("style"), o.get("caption")))
            return
        if env in LIST_ENVS:
            if env == "enumerate" and body.lstrip().startswith("["):
                _, k = read_group(body.lstrip(), 0, "[", "]")
                body = body.lstrip()[k:]
            elif env == "description" and body.lstrip().startswith("["):
                _, k = read_group(body.lstrip(), 0, "[", "]")
                body = body.lstrip()[k:]
            blocks.append(ListBlock(LIST_ENVS[env], self._items(body)))
            return
        if env in MATH_ENVS:
            blocks.append(MathBlock(body.strip()))
            return
        if env in ("utpfig", "figure", "utpfigure", "figure*"):
            blocks.append(self._figure(env, body))
            return
        if env in FIGURE_ENVS:
            blocks.append(FigureBlock(body="\\begin{" + env + "}" + body + "\\end{" + env + "}"))
            return
        if env == "utptable" or env == "table":
            table = self._find_table(body)
            if table:
                blocks.append(table)
            else:
                blocks.extend(self.parse(body))
            return
        if env in TABLE_ENVS:
            table = self._table(env, body)
            if table:
                blocks.append(table)
            return
        if env in SKIP_ENVS:
            return
        if self.styles.is_callout(env):
            style = self.styles.boxes[env]
            args, k = read_args(body, 0, "m" * style.nargs)
            blocks.append(Callout(env, args, self.parse(body[k:])))
            return
        if env == "tcolorbox":                                  # an inline styled box: keep its contents
            b = body.lstrip()
            if b.startswith("["):
                _, k = read_group(b, 0, "[", "]")
                b = b[k:]
            blocks.extend(self.parse(b))
            return
        if env == "center" and re.search(r"\\begin\{(tikzpicture|axis)\}|\\includegraphics", body) \
                and not re.sub(r"\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}|\\includegraphics(\[[^\]]*\])?\{[^}]*\}|\s",
                               "", body, flags=re.S):
            blocks.append(FigureBlock(body=body))
            return
        if env == "minipage":                                   # drop the width argument
            b = body.lstrip()
            if b.startswith("["):
                _, k = read_group(b, 0, "[", "]")
                b = b[k:].lstrip()
            if b.startswith("{"):
                _, k = read_group(b, 0)
                b = b[k:]
            blocks.extend(self.parse(b))
            return
        # anything else: read straight through it
        blocks.extend(self.parse(body))

    def _items(self, body: str) -> list[ListItem]:
        items: list[ListItem] = []
        pieces = re.split(r"\\item(?![A-Za-z])", self._top_level_items(body))
        for piece in pieces[1:]:
            piece = piece.replace("\x02", "\\item")
            label = None
            p = piece.lstrip()
            if p.startswith("["):
                label, k = read_group(p, 0, "[", "]")
                p = p[k:]
            sub = self.parse(p)
            tex = ""
            if sub and isinstance(sub[0], Para):
                tex = sub.pop(0).tex
            items.append(ListItem(tex=tex, label=label, children=sub))
        return items

    @staticmethod
    def _top_level_items(body: str) -> str:
        """Hide the \\item of nested lists so only this list's items split."""
        out, i, depth = [], 0, 0
        pattern = re.compile(r"\\begin\{(\w+\*?)\}|\\end\{(\w+\*?)\}|\\item(?![A-Za-z])")
        for m in pattern.finditer(body):
            out.append(body[i:m.start()])
            tok = m.group(0)
            if m.group(1):
                depth += 1
            elif m.group(2):
                depth -= 1
            elif depth > 0:
                tok = "\x02"
            out.append(tok)
            i = m.end()
        out.append(body[i:])
        return "".join(out)

    # ----------------------------------------------------------------- figures

    def _figure(self, env: str, body: str) -> FigureBlock:
        short = caption = label = title = None
        if env == "utpfig":
            (short, caption, label), k = read_args(body, 0, "omm")
            body = body[k:]
        elif env == "utpfigure":
            (title,), k = read_args(body, 0, "o")
            body = body[k:]
        elif body.lstrip().startswith("["):
            _, k = read_group(body.lstrip(), 0, "[", "]")
            body = body.lstrip()[k:]
        for cmd in ("captionof", "caption"):
            m = re.search(r"\\" + cmd + r"(?![A-Za-z])", body)
            if m:
                spec = "mom" if cmd == "captionof" else "om"
                args, end = read_args(body, m.end(), spec)
                short = short or args[-2]
                caption = caption or args[-1]
                body = body[:m.start()] + body[end:]
        m = re.search(r"\\label\{([^}]*)\}", body)
        if m:
            label = label or m.group(1)
            body = body[:m.start()] + body[m.end():]
        body = re.sub(r"\\centering\b", "", body).strip()
        image = None
        if "\\includegraphics" in body and not re.search(r"\\begin\{(tikzpicture|axis|tabular)", body):
            mm = re.search(r"\\includegraphics(?:\[[^\]]*\])?\{([^}]*)\}", body)
            image = mm.group(1) if mm else None
        return FigureBlock(body=body, caption=caption, short=short, label=label, title=title, image=image)

    # ------------------------------------------------------------------ tables

    def _find_table(self, body: str) -> TableBlock | None:
        m = re.search(r"\\begin\{(" + "|".join(re.escape(e) for e in TABLE_ENVS) + r")\}", body)
        if not m:
            return None
        end, _ = find_env_end(body, m.group(1), m.end())
        return self._table(m.group(1), body[m.end():end])

    def _table(self, env: str, body: str) -> TableBlock | None:
        spec_args = {"tabularx": "mm", "tabular*": "mm", "tabulary": "mm"}.get(env, "m")
        b = body
        if b.lstrip().startswith("["):
            _, k = read_group(b.lstrip(), 0, "[", "]")
            b = b.lstrip()[k:]
        args, k = read_args(b, 0, spec_args)
        columns = parse_colspec(args[-1] or "")
        b = b[k:]
        # rows before the first \midrule are the header
        head_part, _, rest = b.partition("\\midrule")
        if not rest:
            head_part, rest = "", b
        header = [self._cells(r) for r in split_top_level(head_part, "\\\\")]
        rows = [self._cells(r) for r in split_top_level(rest, "\\\\")]
        header = [r for r in header if any(c.strip() for c in r)]
        rows = [r for r in rows if any(c.strip() for c in r)]
        if not rows and not header:
            return None
        return TableBlock(columns, header, rows)

    @staticmethod
    def _cells(row: str) -> list[str]:
        row = re.sub(r"^\s*\[[^\]]*\]", "", row)                  # \\[2pt]
        row = re.sub(r"\\(toprule|midrule|bottomrule|hline|endhead|endfirsthead|addlinespace)(\[[^\]]*\])?", "", row)
        row = re.sub(r"\\cmidrule(\([^)]*\))?\{[^}]*\}", "", row)
        row = re.sub(r"\\cline\{[^}]*\}", "", row)
        row = re.sub(r"\\rowcolor(\[[^\]]*\])?\{[^}]*\}", "", row)
        cells = []
        for cell in split_top_level(row, "&"):
            cell = cell.strip()
            m = re.match(r"\\multicolumn\{(\d+)\}\{[^}]*\}\{(.*)\}$", cell, re.S)
            if m:
                cells.append(m.group(2))
                cells.extend([""] * (int(m.group(1)) - 1))
            else:
                cells.append(cell)
        return cells


def parse_colspec(spec: str) -> list[Column]:
    cols: list[Column] = []
    s = spec.replace(" ", "")
    # expand *{n}{spec}
    while "*{" in s:
        m = re.search(r"\*\{(\d+)\}", s)
        inner, end = read_group(s, m.end())
        s = s[:m.start()] + inner * int(m.group(1)) + s[end:]
    i = 0
    pending: str = ""
    while i < len(s):
        c = s[i]
        if c == ">":
            pending, i = read_group(s, i + 1)
            continue
        if c in "<@!":
            _, i = read_group(s, i + 1)
            continue
        if c == "|":
            i += 1
            continue
        if c in "pmb":
            width, i = read_group(s, i + 1)
            m = re.match(r"([\d.]*)\\(linewidth|textwidth|hsize|columnwidth)", width)
            frac = float(m.group(1) or 1) if m else None
            cols.append(_column(frac, "l", pending))
            pending = ""
            continue
        if c in "XLRCJlcrS":
            cols.append(_column(None, {"c": "c", "C": "c", "r": "r", "R": "r"}.get(c, "l"), pending))
            pending = ""
            i += 1
            continue
        i += 1
    return cols


def _column(width, align, pending: str) -> Column:
    color = None
    m = re.search(r"\\color\{([^}]*)\}", pending)
    if m:
        from .inline import _palette_key
        color = _palette_key(m.group(1))
    if "\\centering" in pending:
        align = "c"
    elif "\\raggedleft" in pending:
        align = "r"
    return Column(width, align, "\\bfseries" in pending, color)
