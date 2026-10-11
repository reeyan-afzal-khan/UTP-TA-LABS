"""Low-level LaTeX reading: comments, verbatim, braces, arguments, environments.

This is not a TeX engine. It reads the subset of LaTeX the course books are
written in, the way a careful human would: commands with braced arguments,
environments that nest, and listings whose contents are taken literally.
"""

from __future__ import annotations

import re

VERBATIM_ENVS = ("lstlisting", "verbatim", "Verbatim", "minted")
_VERBATIM_RE = re.compile(
    r"\\begin\{(" + "|".join(VERBATIM_ENVS) + r")\}(\[[^\]\n]*\])?(\{[^}\n]*\})?(.*?)\\end\{\1\}", re.S)
VERB_TOKEN = "\x00VERB{}\x00"
_VERB_TOKEN_RE = re.compile("\x00VERB(\\d+)\x00")


class Source:
    """A LaTeX file with its listings set aside and its comments removed."""

    def __init__(self, text: str):
        self.verbatim: list[str] = []

        def keep(match: re.Match) -> str:
            env, opt, arg, body = match.group(1), match.group(2) or "", match.group(3) or "", match.group(4)
            if env == "minted":                     # \begin{minted}{python}
                opt, arg = (arg and "[language=" + arg[1:-1] + "]") or opt, ""
            self.verbatim.append(body.strip("\n"))
            return "\\begin{lstlisting}" + opt + VERB_TOKEN.format(len(self.verbatim) - 1) + "\\end{lstlisting}"

        text = text.replace("\r\n", "\n")
        text = _VERBATIM_RE.sub(keep, text)
        self.text = strip_comments(text)

    def verbatim_text(self, token_text: str) -> str:
        match = _VERB_TOKEN_RE.search(token_text)
        return self.verbatim[int(match.group(1))] if match else token_text


def _comment_index(line: str) -> int | None:
    i = 0
    while True:
        i = line.find("%", i)
        if i < 0:
            return None
        backslashes = 0
        j = i - 1
        while j >= 0 and line[j] == "\\":
            backslashes += 1
            j -= 1
        if backslashes % 2 == 0:
            return i
        i += 1


def strip_comments(text: str) -> str:
    """Remove % comments the way TeX does: a comment also eats its line end."""
    out: list[str] = []
    eat = False
    for line in text.split("\n"):
        if eat:
            stripped = line.lstrip()
            if not stripped:                       # an empty line after a comment is still a paragraph break
                out.append("\n\n")
                eat = False
                continue
            line = stripped
        idx = _comment_index(line)
        if idx is not None:
            out.append(line[:idx])
            eat = True
        else:
            out.append(line + "\n")
            eat = False
    return "".join(out)


# ------------------------------------------------------------------ groups

def skip_space(s: str, i: int, newlines: bool = True) -> int:
    """Skip spaces (and single line breaks) between a command and its argument."""
    n = len(s)
    while i < n:
        if s[i] in " \t":
            i += 1
        elif newlines and s[i] == "\n" and not s.startswith("\n\n", i):
            i += 1
        else:
            break
    return i


def read_group(s: str, i: int, open_: str = "{", close: str = "}") -> tuple[str, int]:
    """s[i] is the opening delimiter: return (contents, index after the closing one)."""
    assert s[i] == open_, (s[i:i + 30], open_)
    depth = 0
    j = i
    n = len(s)
    while j < n:
        c = s[j]
        if c == "\\":
            j += 2
            continue
        if open_ == "[" and c == "{":                 # braces protect ] inside an optional argument
            _, j = read_group(s, j)
            continue
        if c == open_:
            depth += 1
        elif c == close:
            depth -= 1
            if depth == 0:
                return s[i + 1:j], j + 1
        j += 1
    return s[i + 1:], n                                # unbalanced: take the rest


def read_args(s: str, i: int, spec: str) -> tuple[list[str | None], int]:
    """Read arguments by spec: 'm' mandatory {..}, 'o' optional [..], 's' star."""
    args: list[str | None] = []
    for kind in spec:
        j = skip_space(s, i)
        if kind == "s":
            if j < len(s) and s[j] == "*":
                args.append("*")
                i = j + 1
            else:
                args.append(None)
        elif kind == "o":
            if j < len(s) and s[j] == "[":
                value, i = read_group(s, j, "[", "]")
                args.append(value)
            else:
                args.append(None)
        else:
            if j < len(s) and s[j] == "{":
                value, i = read_group(s, j)
                args.append(value)
            elif j < len(s) and s[j] == "\\":           # \cmd\foo : a single control sequence
                m = re.match(r"\\[A-Za-z@]+|\\.", s[j:])
                args.append(m.group(0))
                i = j + len(m.group(0))
            elif j < len(s):
                args.append(s[j])
                i = j + 1
            else:
                args.append("")
    return args, i


def find_env_end(s: str, name: str, i: int) -> tuple[int, int]:
    """From just after \\begin{name}, return (start of \\end{name}, index after it)."""
    begin = "\\begin{" + name + "}"
    end = "\\end{" + name + "}"
    depth = 1
    j = i
    while True:
        nb = s.find(begin, j)
        ne = s.find(end, j)
        if ne < 0:
            return len(s), len(s)
        if 0 <= nb < ne:
            depth += 1
            j = nb + len(begin)
            continue
        depth -= 1
        if depth == 0:
            return ne, ne + len(end)
        j = ne + len(end)


def split_top_level(s: str, sep: str) -> list[str]:
    """Split at sep where it is not inside braces, math or escaped (\\& is not a column)."""
    parts: list[str] = []
    depth = 0
    start = 0
    i = 0
    n = len(s)
    in_math = False
    while i < n:
        c = s[i]
        if c == "\\":
            if depth == 0 and not in_math and s.startswith(sep, i) and sep.startswith("\\"):
                parts.append(s[start:i])
                i += len(sep)
                start = i
                continue
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        elif c == "$":
            in_math = not in_math
        elif depth == 0 and not in_math and s.startswith(sep, i):
            parts.append(s[start:i])
            i += len(sep)
            start = i
            continue
        i += 1
    parts.append(s[start:])
    return parts


def find_command(s: str, name: str, start: int = 0) -> int:
    """Index of \\name (not \\nameXYZ) or -1."""
    pattern = re.compile(r"\\" + re.escape(name) + r"(?![A-Za-z@])")
    m = pattern.search(s, start)
    return m.start() if m else -1
