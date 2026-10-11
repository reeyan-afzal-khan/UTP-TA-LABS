"""Inline LaTeX -> styled runs -> on-screen markup, spoken text, or plain text.

A paragraph like ``A \\term{tree} costs \\cxg{O(\\log n)} per \\texttt{find()}`` becomes

    markup   A <b>tree</b> costs <b>O(log <i>n</i>)</b> per <tt>find()</tt>   (Pango, for Manim)
    speech   A tree costs O of log n per find                                 (for the voice)
    plain    A tree costs O(log n) per find()                                 (for subtitles)
"""

from __future__ import annotations

import html
import re
from dataclasses import dataclass, field, replace
from typing import Callable

from .reader import read_args, read_group, skip_space

# ---------------------------------------------------------------- the runs


@dataclass(frozen=True)
class Style:
    bold: bool = False
    italic: bool = False
    mono: bool = False
    color: str | None = None        # a theme key ('navy', 'green', ...) or '#rrggbb'
    small: bool = False


@dataclass
class Run:
    text: str = ""
    style: Style = field(default_factory=Style)
    math: str | None = None         # LaTeX math source when this run is math
    newline: bool = False           # a forced line break (\\)


# Colour names in the book's palette that inline text can use.
PALETTE_KEYS = {
    "UTPNavy": "navy", "UTPBlue": "blue", "UTPTeal": "teal", "UTPGreen": "green",
    "UTPOrange": "orange", "UTPRed": "red", "UTPMuted": "muted", "UTPInk": "ink",
    "UTPGold": "gold", "UTPPurple": "purple",
}


def _palette_key(color_expr: str) -> str | None:
    base = color_expr.split("!")[0].strip()
    return PALETTE_KEYS.get(base)


# Commands that wrap one argument in a style.
WRAP_STYLES: dict[str, dict] = {
    "textbf": {"bold": True}, "emph": {"italic": True}, "textit": {"italic": True},
    "textsl": {"italic": True}, "texttt": {"mono": True}, "cmd": {"mono": True},
    "path": {"mono": True}, "code": {"mono": True}, "filename": {"mono": True},
    "term": {"bold": True, "color": "navy"}, "lib": {"bold": True, "mono": True, "color": "blue"},
    "textsc": {}, "underline": {}, "textup": {}, "textrm": {}, "textsf": {}, "textnormal": {},
    "mbox": {}, "hbox": {}, "fbox": {}, "text": {}, "textmd": {}, "strong": {"bold": True},
}
# Complexity badges: \cxg{O(1)} etc. are bold coloured math.
COMPLEXITY = {"cxg": "green", "cxo": "orange", "cxr": "red"}
# Declarations that change the style until the end of the group.
DECLARATIONS = {"bfseries": {"bold": True}, "itshape": {"italic": True}, "em": {"italic": True},
                "ttfamily": {"mono": True}, "slshape": {"italic": True}, "bf": {"bold": True},
                "it": {"italic": True}, "tt": {"mono": True}, "mdseries": {"bold": False},
                "upshape": {"italic": False}, "normalfont": {"bold": False, "italic": False, "mono": False}}
SIZE_DECLARATIONS = {"tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large",
                     "LARGE", "huge", "Huge"}
# Commands whose arguments are dropped entirely.
DROP: dict[str, str] = {
    "label": "m", "index": "m", "cite": "om", "nocite": "m", "footnote": "om", "footnotemark": "o",
    "footnotetext": "m", "vspace": "sm", "hspace": "sm", "addcontentsline": "mmm", "markboth": "mm",
    "phantomsection": "", "setlength": "mm", "addtolength": "mm", "rule": "omm", "pagebreak": "o",
    "nopagebreak": "o", "linebreak": "o", "labcovers": "m", "coretag": "", "latertag": "",
    "centering": "", "raggedright": "", "raggedleft": "", "noindent": "", "indent": "",
    "medskip": "", "smallskip": "", "bigskip": "", "clearpage": "", "newpage": "", "strut": "",
    "nointerlineskip": "", "leavevmode": "", "protect": "", "relax": "", "hfill": "", "vfill": "",
    "allowbreak": "", "par": "", "FloatBarrier": "", "pagestyle": "m", "thispagestyle": "m",
    "includegraphics": "om", "captionsetup": "om", "lstset": "m", "arraybackslash": "",
    "rowcolor": "om", "cellcolor": "om", "toprule": "o", "midrule": "o", "bottomrule": "o",
    "hline": "", "cline": "m", "cmidrule": "om", "addlinespace": "o", "endhead": "", "endfirsthead": "",
    "kern": "", "ignorespaces": "", "unskip": "",
}
SYMBOLS = {
    "ldots": "…", "dots": "…", "textellipsis": "…", "LaTeX": "LaTeX", "TeX": "TeX",
    "textbackslash": "\\", "textasciitilde": "~", "textasciicircum": "^", "textless": "<",
    "textgreater": ">", "textbar": "|", "textquotesingle": "'", "textendash": "–", "textemdash": "—",
    "quad": "  ", "qquad": "    ", "enspace": " ", "thinspace": " ", "checkmark": "✓",
    "texttimes": "×", "textregistered": "®", "copyright": "©", "textdegree": "°", "S": "§",
    "newline": "\n", "slash": "/", "textbullet": "•", "pounds": "£", "euro": "€", "times": "×",
    "rightarrow": "→", "to": "→", "leftarrow": "←", "Rightarrow": "⇒", "ptrnull": "NULL",
}
ESCAPES = {"%": "%", "&": "&", "_": "_", "#": "#", "$": "$", "{": "{", "}": "}", " ": " ",
           ",": " ", ";": " ", ":": " ", "!": "", "@": "", "/": "", "-": "", "'": "’", "`": "‘"}


class InlineContext:
    """What inline conversion needs to know about the book."""

    def __init__(self, labels: dict[str, str] | None = None, macros: dict[str, tuple[int, str]] | None = None,
                 self_label: str | None = None):
        self.labels = labels or {}          # label -> "Figure 1.2", "Chapter 3", "Lab 4", "Section 2.1"
        self.macros = macros or {}          # \newcommand{\name}[n]{body} from the book's main.tex
        self.self_label = self_label        # the figure on screen: \figref to it reads "this figure"

    def with_self(self, label: str | None) -> "InlineContext":
        return InlineContext(self.labels, self.macros, label)

    def ref(self, label: str, kind: str) -> str:
        if self.self_label and label == self.self_label:
            return "this figure"
        found = self.labels.get(label)
        if found:
            return found
        return {"fig": "the figure", "chap": "the chapter", "sec": "the section", "tab": "the table"}.get(kind, "")


def parse_inline(s: str, ctx: InlineContext | None = None, style: Style = Style()) -> list[Run]:
    return _Parser(ctx or InlineContext()).parse(s, style)


class _Parser:
    def __init__(self, ctx: InlineContext):
        self.ctx = ctx

    def parse(self, s: str, style: Style) -> list[Run]:
        runs: list[Run] = []
        buf: list[str] = []

        def flush() -> None:
            if buf:
                runs.append(Run("".join(buf), style))
                buf.clear()

        i, n = 0, len(s)
        while i < n:
            c = s[i]
            if c == "\\":
                m = re.match(r"\\([A-Za-z@]+)(\*?)|\\(.)", s[i:], re.S)
                if m.group(3) is not None:                 # \% \& \\ \, ...
                    ch = m.group(3)
                    i += 2
                    if ch == "\\":                          # forced line break, maybe \\[2pt]
                        j = skip_space(s, i, newlines=False)
                        if j < n and s[j] == "[":
                            _, i = read_group(s, j, "[", "]")
                        flush()
                        runs.append(Run("", style, newline=True))
                    elif ch == "(":                         # \( math \)
                        end = s.find("\\)", i)
                        end = n if end < 0 else end
                        flush()
                        runs.append(Run("", style, math=s[i:end]))
                        i = end + 2
                    elif ch == "[":                         # display math inside inline text
                        end = s.find("\\]", i)
                        end = n if end < 0 else end
                        flush()
                        runs.append(Run("", style, math=s[i:end]))
                        i = end + 2
                    else:
                        buf.append(ESCAPES.get(ch, ch))
                    continue
                name = m.group(1)
                i += len(m.group(0))
                consumed = self._command(name, s, i, style, runs, buf, flush)
                if isinstance(consumed, tuple):            # a declaration changed the style
                    i, style = consumed
                else:
                    i = consumed
                continue
            if c == "{":
                inner, i = read_group(s, i)
                flush()
                runs.extend(self.parse(inner, style))
                continue
            if c == "}":
                i += 1
                continue
            if c == "$":
                flush()
                if s.startswith("$$", i):
                    end = s.find("$$", i + 2)
                    end = n if end < 0 else end
                    runs.append(Run("", style, math=s[i + 2:end]))
                    i = end + 2
                else:
                    j = i + 1
                    while j < n and not (s[j] == "$" and s[j - 1] != "\\"):
                        j += 1
                    runs.append(Run("", style, math=s[i + 1:j]))
                    i = j + 1
                continue
            if c == "~":
                buf.append(" ")
            elif c == "-":
                if s.startswith("---", i):
                    buf.append("—")
                    i += 3
                    continue
                if s.startswith("--", i):
                    buf.append("–")
                    i += 2
                    continue
                buf.append("-")
            elif c == "`":
                if s.startswith("``", i):
                    buf.append("“")
                    i += 2
                    continue
                buf.append("‘")
            elif c == "'":
                if s.startswith("''", i):
                    buf.append("”")
                    i += 2
                    continue
                buf.append("’")
            elif c in "\n\t":
                buf.append(" ")
            elif c == "&":
                buf.append(" ")
            else:
                buf.append(c)
            i += 1
        flush()
        return runs

    # --------------------------------------------------------------- commands

    def _command(self, name, s, i, style, runs, buf, flush):
        ctx = self.ctx
        if name in WRAP_STYLES:
            (arg,), j = read_args(s, i, "m")
            flush()
            runs.extend(self.parse(arg, replace(style, **WRAP_STYLES[name])))
            return j
        if name == "textcolor":
            (col, arg), j = read_args(s, i, "mm")
            flush()
            runs.extend(self.parse(arg, replace(style, color=_palette_key(col) or style.color)))
            return j
        if name in ("colorbox", "fcolorbox"):
            args, j = read_args(s, i, "mm" if name == "colorbox" else "mmm")
            flush()
            runs.extend(self.parse(args[-1], style))
            return j
        if name in COMPLEXITY:
            (arg,), j = read_args(s, i, "m")
            flush()
            runs.append(Run("", replace(style, bold=True, color=COMPLEXITY[name]), math=arg))
            return j
        if name in ("figref", "chapref", "secref", "ref", "autoref", "cref", "Cref", "tabref", "labref"):
            (label,), j = read_args(s, i, "m")
            kind = {"figref": "fig", "chapref": "chap", "secref": "sec"}.get(name, "")
            text = ctx.ref(label, kind)
            if name == "ref" and text:
                text = text.split(" ", 1)[-1]               # \ref gives just the number
            buf.append(text)
            return j
        if name == "chapsref":
            (a, b), j = read_args(s, i, "mm")
            na, nb = ctx.labels.get(a, ""), ctx.labels.get(b, "")
            buf.append(f"Chapters {na.split(' ')[-1]}–{nb.split(' ')[-1]}" if na and nb else "these chapters")
            return j
        if name == "pageref":
            _, j = read_args(s, i, "m")
            return j
        if name == "href":
            (_, text), j = read_args(s, i, "mm")
            flush()
            runs.extend(self.parse(text, style))
            return j
        if name == "url":
            (u,), j = read_args(s, i, "m")
            flush()
            runs.append(Run(u, replace(style, mono=True)))
            return j
        if name in ("lstinline", "verb", "mintinline"):
            if name == "mintinline":
                _, i = read_args(s, i, "m")
            j = skip_space(s, i)
            if j < len(s) and s[j] == "{":
                code, j = read_group(s, j)
            else:
                delim = s[j]
                end = s.find(delim, j + 1)
                code, j = s[j + 1:end], end + 1
            flush()
            runs.append(Run(code, replace(style, mono=True)))
            return j
        if name in ("textsuperscript", "textsubscript"):
            (arg,), j = read_args(s, i, "m")
            buf.append(arg)
            return j
        if name in DECLARATIONS:
            flush()
            return i, replace(style, **DECLARATIONS[name])
        if name in SIZE_DECLARATIONS:
            flush()
            return i, replace(style, small=name in ("tiny", "scriptsize", "footnotesize", "small"))
        if name == "color":
            (col,), j = read_args(s, i, "m")
            flush()
            return j, replace(style, color=_palette_key(col) or style.color)
        if name in SYMBOLS:
            if name == "ptrnull":
                flush()
                runs.append(Run("NULL", replace(style, mono=True, color="muted")))
            else:
                buf.append(SYMBOLS[name])
            return i
        if name in DROP:
            _, j = read_args(s, i, DROP[name])
            return j
        if name in ctx.macros:                               # the book's own \newcommand
            nargs, body = ctx.macros[name]
            args, j = read_args(s, i, "m" * nargs)
            for k, a in enumerate(args, 1):
                body = body.replace(f"#{k}", a or "")
            flush()
            runs.extend(self.parse(body, style))
            return j
        # Unknown command: drop the name, keep what follows (its {groups} read as text).
        return i


# ------------------------------------------------------------------ markup

def _esc(text: str) -> str:
    return html.escape(text, quote=False)


def runs_to_markup(runs: list[Run], colors: dict[str, str], mono_font: str) -> str:
    """Pango markup for Manim's MarkupText."""
    out: list[str] = []
    for r in runs:
        if r.newline:
            out.append("\n")
            continue
        if r.math is not None:
            body = math_to_markup(r.math)
        else:
            body = _esc(r.text)
        if not body:
            continue
        st = r.style
        attrs = []
        if st.mono:
            attrs.append(f'font_family="{mono_font}"')
            attrs.append('size="92%"' if not st.small else 'size="85%"')
        elif st.small:
            attrs.append('size="88%"')
        if st.color:
            attrs.append(f'foreground="{colors.get(st.color, st.color)}"')
        if st.bold:
            attrs.append('weight="semibold"')
        if st.italic:
            attrs.append('style="italic"')
        out.append(f"<span {' '.join(attrs)}>{body}</span>" if attrs else body)
    text = "".join(out)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r" *\n *", "\n", text)
    return text.strip()


def runs_to_plain(runs: list[Run]) -> str:
    out = []
    for r in runs:
        if r.newline:
            out.append(" ")
        elif r.math is not None:
            out.append(math_to_plain(r.math))
        else:
            out.append(r.text)
    return re.sub(r"\s+", " ", "".join(out)).strip()


def runs_to_speech(runs: list[Run]) -> str:
    out = []
    for k, r in enumerate(runs):
        if r.newline:
            prev = "".join(out).rstrip()
            out.append(" " if not prev or prev[-1] in ".:;,!?" else ". ")
        elif r.math is not None:
            out.append(" " + math_to_speech(r.math) + " ")
        elif r.style.mono:
            out.append(code_to_speech(r.text))
        else:
            out.append(r.text)
    text = "".join(out)
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([,.;:!?)])", r"\1", text)
    text = re.sub(r"\(\s+", "(", text)
    text = re.sub(r"\s*\(\)", "", text)
    return text.strip()


# -------------------------------------------------------------------- math

GREEK = ["alpha", "beta", "gamma", "delta", "epsilon", "varepsilon", "zeta", "eta", "theta", "iota",
         "kappa", "lambda", "mu", "nu", "xi", "pi", "rho", "sigma", "tau", "upsilon", "phi", "varphi",
         "chi", "psi", "omega", "Gamma", "Delta", "Theta", "Lambda", "Xi", "Pi", "Sigma", "Phi", "Psi", "Omega"]
GREEK_CHARS = dict(zip(GREEK, "αβγδεεζηθικλμνξπρστυφφχψωΓΔΘΛΞΠΣΦΨΩ"))
MATH_SYMBOLS = {
    "to": "→", "rightarrow": "→", "leftarrow": "←", "Rightarrow": "⇒", "Leftarrow": "⇐", "iff": "⇔",
    "leftrightarrow": "↔", "mapsto": "↦", "leq": "≤", "le": "≤", "geq": "≥", "ge": "≥", "neq": "≠",
    "ne": "≠", "times": "×", "cdot": "·", "approx": "≈", "in": "∈", "notin": "∉", "infty": "∞",
    "pm": "±", "ldots": "…", "cdots": "⋯", "dots": "…", "sum": "Σ", "prod": "Π", "mid": "|",
    "given": "|", "subseteq": "⊆", "subset": "⊂", "cup": "∪", "cap": "∩", "emptyset": "∅",
    "forall": "∀", "exists": "∃", "neg": "¬", "land": "∧", "lor": "∨", "partial": "∂", "nabla": "∇",
    "sim": "~", "propto": "∝", "equiv": "≡", "lceil": "⌈", "rceil": "⌉", "lfloor": "⌊", "rfloor": "⌋",
    "langle": "⟨", "rangle": "⟩", "circ": "∘", "ast": "*", "star": "*", "prime": "′", "lvert": "|",
    "rvert": "|", "vert": "|", "Vert": "‖", "{": "{", "}": "}", "%": "%", "#": "#", "_": "_", "&": "&",
}
MATH_FUNCS = ["log", "ln", "exp", "max", "min", "sin", "cos", "tan", "arg", "lim", "det", "Pr", "deg", "gcd"]
SUPERSCRIPT = str.maketrans("0123456789+-=()nik", "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿⁱᵏ")
SUBSCRIPT = str.maketrans("0123456789+-=()aeiojkmnrstx", "₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑᵢₒⱼₖₘₙᵣₛₜₓ")
_TEXTLIKE = re.compile(r"\\(?:text|mathrm|textrm|mathit|mathbf|textbf|operatorname|mathsf|texttt|mathtt|boldsymbol|bm|mathcal|mathbb)\s*\{([^{}]*)\}")


def _script(arg: str, table: dict, mark: str) -> str:
    plain = arg.strip()
    if plain and all(ch in table for ch in plain):
        return plain.translate(table)
    return mark + (plain if len(plain) == 1 else "(" + plain + ")")


def math_to_plain(src: str) -> str:
    """Unicode approximation of inline math: O(\\log n) -> O(log n)."""
    s = src
    s = _TEXTLIKE.sub(lambda m: m.group(1), s)
    s = re.sub(r"\\frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}", r"(\1)/(\2)", s)
    s = re.sub(r"\\sqrt\s*\{([^{}]*)\}", r"√(\1)", s)
    s = re.sub(r"\\(left|right|big|Big|bigg|Bigg)(?![A-Za-z])", "", s)
    for f in MATH_FUNCS:
        s = re.sub(r"\\" + f + r"(?![A-Za-z])", f + " ", s)
    s = re.sub(r"\\([A-Za-z]+)", lambda m: GREEK_CHARS.get(m.group(1), MATH_SYMBOLS.get(m.group(1), m.group(1))), s)
    s = re.sub(r"\\([{}%#_&])", r"\1", s)
    s = re.sub(r"\\[,;:! ]", " ", s)
    s = re.sub(r"\^\{([^{}]*)\}|\^(\S)", lambda m: _script(m.group(1) or m.group(2), SUPERSCRIPT, "^"), s)
    s = re.sub(r"_\{([^{}]*)\}|_(\S)", lambda m: _script(m.group(1) or m.group(2), SUBSCRIPT, "_"), s)
    s = s.replace("{", "").replace("}", "").replace("~", " ")
    s = re.sub(r"\s+", " ", s).strip()
    s = re.sub(r"\s+([)\],])", r"\1", s)
    s = re.sub(r"([(\[])\s+", r"\1", s)
    return s


def math_to_markup(src: str) -> str:
    """Like math_to_plain, with single-letter variables in italics."""
    plain = math_to_plain(src)
    words = set(MATH_FUNCS)
    out = []
    for token in re.split(r"([A-Za-z]+)", plain):
        if re.fullmatch(r"[A-Za-z]", token) and token not in words and token != "O":
            out.append("<i>" + _esc(token) + "</i>")
        else:
            out.append(_esc(token))
    return "".join(out)


SPOKEN_MATH = {
    "to": " to ", "rightarrow": " to ", "leftarrow": " from ", "Rightarrow": " implies ", "iff": " if and only if ",
    "leftrightarrow": " both ways ", "mapsto": " maps to ", "leq": " is at most ", "le": " is at most ",
    "geq": " is at least ", "ge": " is at least ", "neq": " is not equal to ", "ne": " is not equal to ",
    "times": " times ", "cdot": " times ", "approx": " is approximately ", "in": " in ", "notin": " not in ",
    "infty": " infinity ", "pm": " plus or minus ", "ldots": " and so on ", "cdots": " and so on ",
    "dots": " and so on ", "sum": " the sum of ", "prod": " the product of ", "mid": " given ",
    "given": " given ", "cup": " union ", "cap": " intersect ", "emptyset": " the empty set ",
    "subseteq": " is a subset of ", "subset": " is a subset of ", "forall": " for all ", "exists": " there exists ",
    "equiv": " is equivalent to ", "sim": " is distributed as ", "propto": " is proportional to ",
    "lceil": " ceiling of ", "rceil": " ", "lfloor": " floor of ", "rfloor": " ", "circ": " composed with ",
    "partial": " partial ", "prime": " prime ",
}


def math_to_speech(src: str) -> str:
    s = src
    s = _TEXTLIKE.sub(lambda m: " " + m.group(1) + " ", s)
    s = re.sub(r"\\(left|right|big|Big|bigg|Bigg)(?![A-Za-z])", "", s)
    for _ in range(3):
        s = re.sub(r"\\frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}", r" \1 over \2 ", s)
        s = re.sub(r"\\sqrt\s*\{([^{}]*)\}", r" the square root of \1 ", s)
    s = re.sub(r"\bO\s*\(", " O of (", s)                       # big-O
    s = re.sub(r"\^\{?2\}?", " squared ", s)
    s = re.sub(r"\^\{?3\}?", " cubed ", s)
    s = re.sub(r"\^\{([^{}]*)\}|\^(\S)", lambda m: " to the power " + (m.group(1) or m.group(2)) + " ", s)
    s = re.sub(r"_\{([^{}]*)\}|_(\S)", lambda m: " sub " + (m.group(1) or m.group(2)) + " ", s)
    for f in MATH_FUNCS:
        s = re.sub(r"\\" + f + r"(?![A-Za-z])", " " + f + " ", s)
    s = re.sub(r"\\([A-Za-z]+)", lambda m: " " + (m.group(1) if m.group(1) in GREEK
                                                   else SPOKEN_MATH.get(m.group(1), " ")) + " ", s)
    s = re.sub(r"\\[,;:! ]", " ", s)
    s = re.sub(r"\\([{}%#_&])", r" \1 ", s)
    replacements = [("<=", " is at most "), (">=", " is at least "), ("!=", " is not equal to "),
                    ("=", " equals "), ("+", " plus "), ("<", " is less than "), (">", " is greater than "),
                    ("*", " times "), ("/", " over "), ("!", " factorial ")]
    for a, b in replacements:
        s = s.replace(a, b)
    s = re.sub(r"(?<=[\s(])-(?=\s*\w)", " minus ", s)
    s = s.replace(" - ", " minus ")
    s = s.replace("{", " ").replace("}", " ").replace("(", " ").replace(")", " ").replace("|", " ")
    s = s.replace("~", " ").replace("&", " ")
    s = re.sub(r"\s+", " ", s).strip()
    return re.sub(r"\s+([,.;:!?])", r"\1", s)


# -------------------------------------------------------------------- code

def code_to_speech(code: str) -> str:
    """How an identifier or a short path in running text is read aloud."""
    s = code.strip()
    s = s.replace("::", " ")
    s = re.sub(r"\(\s*\)", "", s)                                # find() -> find
    s = re.sub(r"\[ok\]", "ok", s)
    s = re.sub(r"/+$", "", s)
    s = re.sub(r"(?<=\w)/(?=\w)", ", ", s)                       # all_experiments/Lab01 -> all experiments, Lab01
    s = re.sub(r"(?<=[a-z])(?=[A-Z])", " ", s)                   # findById -> find By Id
    s = re.sub(r"\bId\b", "ID", s)
    s = re.sub(r"(?<=[A-Za-z])(?=\d)", " ", s)                   # Lab01 -> Lab 01
    s = re.sub(r"\b0(\d)\b", r"\1", s)                           # Lab 01 -> Lab 1
    s = s.replace("_", " ")
    s = re.sub(r"\s+", " ", s)
    return " " + s.strip() + " "


# --------------------------------------------------------------- sentences

_ABBREV = re.compile(r"(?:\b(?:e\.g|i\.e|etc|vs|cf|Fig|Figs|Eq|Dr|Mr|Ms|Mrs|No|approx|al|ca|Ch|Sec|resp))$")


def split_sentences_latex(tex: str) -> list[str]:
    """Split a LaTeX paragraph into sentences without breaking braces or math."""
    out: list[str] = []
    depth = 0
    in_math = False
    start = 0
    i, n = 0, len(tex)
    while i < n:
        c = tex[i]
        if c == "\\":
            if tex.startswith("\\\\", i) and depth == 0 and not in_math and tex[start:i].strip():
                out.append(tex[start:i].strip())        # a forced line break ends a sentence
                i += 2
                while i < n and tex[i] in " \t\n":
                    i += 1
                start = i
                continue
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth = max(0, depth - 1)
        elif c == "$":
            in_math = not in_math
        elif c in ".?!" and depth == 0 and not in_math:
            j = i + 1
            while j < n and tex[j] in "'\")}":
                j += 1
            k = j
            while k < n and tex[k] in " \t\n~":
                k += 1
            if k > j and k < n and (tex[k].isupper() or tex[k] in "\\`\"(" or tex[k].isdigit()):
                before = tex[start:i]
                if c == "." and (_ABBREV.search(before) or re.search(r"(?:^|\s)[A-Z]$", before)):
                    i += 1
                    continue
                out.append(tex[start:j].strip())
                start = k
                i = k
                continue
        i += 1
    tail = tex[start:].strip()
    if tail:
        out.append(tail)
    return [s for s in out if s]


_PLAIN_SPLIT = re.compile(r"(?<=[.!?])[\"”’)]*\s+(?=[A-Z0-9“\"(])")


def split_sentences_plain(text: str) -> list[str]:
    """Split spoken text into sentences (used to time sentence reveals)."""
    parts = []
    buf = ""
    for piece in _PLAIN_SPLIT.split(text.strip()):
        candidate = (buf + " " + piece).strip() if buf else piece
        if re.search(r"(?:\b(?:e\.g|i\.e|etc|vs|cf|Dr|Mr|Ms|No)\.|\s[A-Z]\.)$", candidate):
            buf = candidate
            continue
        parts.append(candidate)
        buf = ""
    if buf:
        parts.append(buf)
    return [p for p in parts if p]


def count_glyphs(markup: str) -> int:
    """Visible characters Pango will draw for this markup (spaces excluded)."""
    text = re.sub(r"<[^>]*>", "", markup)
    text = html.unescape(text)
    return sum(1 for ch in text if not ch.isspace())


def convert(tex: str, ctx: InlineContext, colors: dict[str, str], mono_font: str) -> tuple[str, str, str]:
    """(markup, speech, plain) for a piece of inline LaTeX."""
    runs = parse_inline(tex, ctx)
    return runs_to_markup(runs, colors, mono_font), runs_to_speech(runs), runs_to_plain(runs)
