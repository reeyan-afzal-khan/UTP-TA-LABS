"""Callout box styles, titles and colours, read from the books' own LaTeX.

Every course box (keyidea, pitfall, labproject, a book's own \\utpnewcallout ...)
gets its colours and title from .shared/utpnotes.tex and the course main.tex,
so a box a course adds tomorrow shows up in its videos with the right look.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from .reader import read_args, read_group, skip_space, strip_comments

BASE_COLORS = {
    "white": "#FFFFFF", "black": "#000000", "gray": "#808080", "lightgray": "#BFBFBF",
    "darkgray": "#404040", "red": "#FF0000", "green": "#00FF00", "blue": "#0000FF",
    "orange": "#FF8000", "yellow": "#FFFF00", "teal": "#008080", "cyan": "#00FFFF",
}


def _hex_to_rgb(h: str) -> tuple[float, float, float]:
    h = h.lstrip("#")
    return tuple(int(h[k:k + 2], 16) / 255 for k in (0, 2, 4))  # type: ignore[return-value]


def _rgb_to_hex(rgb) -> str:
    return "#" + "".join(f"{max(0, min(255, round(c * 255))):02X}" for c in rgb)


class Palette:
    """xcolor names and mixes: UTPOrange!42, UTPMuted!88!UTPNavy, white ..."""

    def __init__(self, colors: dict[str, str]):
        self.colors = dict(BASE_COLORS)
        self.colors.update(colors)

    def resolve(self, expr: str | None, default: str = "#FFFFFF") -> str:
        if not expr:
            return default
        expr = expr.strip()
        if expr.startswith("#"):
            return expr
        parts = [p.strip() for p in expr.split("!")]
        base = self.colors.get(parts[0])
        if base is None:
            return default
        rgb = _hex_to_rgb(base)
        k = 1
        while k < len(parts):
            try:
                pct = float(parts[k]) / 100
            except ValueError:
                break
            other = _hex_to_rgb(self.colors.get(parts[k + 1], "#FFFFFF")) if k + 1 < len(parts) else (1, 1, 1)
            rgb = tuple(pct * a + (1 - pct) * b for a, b in zip(rgb, other))
            k += 2
        return _rgb_to_hex(rgb)


@dataclass
class BoxStyle:
    name: str
    nargs: int = 0
    title: str = ""                 # LaTeX, may contain #1, #2
    back: str = "#FFFFFF"
    frame: str = "#246B9E"
    title_back: str | None = None   # a filled title bar when set
    title_color: str = "#18324A"
    options: dict = field(default_factory=dict)

    @property
    def heavy(self) -> bool:
        return self.title_back is not None


def _parse_options(opts: str) -> dict[str, str]:
    out: dict[str, str] = {}
    depth = 0
    cur = ""
    items = []
    for ch in opts:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        if ch == "," and depth == 0:
            items.append(cur)
            cur = ""
        else:
            cur += ch
    items.append(cur)
    for item in items:
        if "=" in item:
            k, v = item.split("=", 1)
            v = v.strip()
            if v.startswith("{") and v.endswith("}"):
                v = v[1:-1]
            out[k.strip()] = v
        elif item.strip():
            out[item.strip()] = ""
    return out


class StyleBook:
    """All box styles and title macros of one course."""

    NOT_CALLOUTS = {"utpfigure", "utptable", "tcolorbox"}

    def __init__(self, shared_tex: str, main_tex: str):
        shared_tex, main_tex = strip_comments(shared_tex), strip_comments(main_tex)
        self.titles: dict[str, str] = {}
        colors = dict(re.findall(r"\\definecolor\{(\w+)\}\{HTML\}\{([0-9A-Fa-f]{6})\}", shared_tex + main_tex))
        self.palette = Palette({k: "#" + v.upper() for k, v in colors.items()})
        self.boxes: dict[str, BoxStyle] = {}

        preamble = main_tex.split("\\begin{document}")[0]
        # Titles: the book's \def\utptitleX{..} wins over the shared \providecommand.
        for m in re.finditer(r"\\def\\(utptitle\w+)\{", preamble):
            self.titles[m.group(1)], _ = read_group(preamble, m.end() - 1)
        for m in re.finditer(r"\\providecommand\{\\(utptitle\w+)\}\{", shared_tex):
            if m.group(1) not in self.titles:
                self.titles[m.group(1)], _ = read_group(shared_tex, m.end() - 1)

        shared_top = self._without_command_bodies(shared_tex)
        self._read_definitions(shared_top)
        # Variations a book switches on (\utpheavycallouts, \utplabprojectcolour{UTPNavy} ...).
        for name, nargs, body in self._commands_with_boxes(shared_tex):
            for call in re.finditer(r"\\" + name + r"(?![A-Za-z])", preamble):
                args, _ = read_args(preamble, call.end(), "m" * nargs)
                expanded = body.replace("##", "\x01")      # ##1 is the inner box's own argument
                for k, a in enumerate(args, 1):
                    expanded = expanded.replace(f"#{k}", a or "")
                self._read_definitions(expanded.replace("\x01", "#"))
        self._read_definitions(preamble)

    # ----------------------------------------------------------------- reading

    @staticmethod
    def _commands_with_boxes(tex: str):
        for m in re.finditer(r"\\newcommand\{\\(\w+)\}(?:\[(\d)\])?\{", tex):
            body, _ = read_group(tex, m.end() - 1)
            if "tcolorbox" in body and "\\newtcolorbox{#" not in body:
                yield m.group(1), int(m.group(2) or 0), body

    @staticmethod
    def _without_command_bodies(tex: str) -> str:
        out, i = [], 0
        for m in re.finditer(r"\\newcommand\{\\(\w+)\}(?:\[(\d)\])?(?:\[[^\]]*\])?\{", tex):
            if m.start() < i:
                continue
            _, end = read_group(tex, m.end() - 1)
            out.append(tex[i:m.start()])
            i = end
        out.append(tex[i:])
        return "".join(out)

    def _read_definitions(self, tex: str) -> None:
        for m in re.finditer(r"\\(?:re)?newtcolorbox\{(\w+)\}", tex):
            name = m.group(1)
            j = skip_space(tex, m.end())
            nargs = 0
            if tex.startswith("[", j):
                n, j = read_group(tex, j, "[", "]")
                nargs = int(n) if n.strip().isdigit() else 0
                j = skip_space(tex, j)
                if tex.startswith("[", j):              # a default for #1
                    _, j = read_group(tex, j, "[", "]")
                    j = skip_space(tex, j)
            if not tex.startswith("{", j):
                continue
            opts, _ = read_group(tex, j)
            self._add(name, nargs, _parse_options(opts))
        for m in re.finditer(r"\\utpnewcallout(?=[\[{\s])", tex):
            args, _ = read_args(tex, m.end(), "ommmm")
            extra, name, back, frame, title = args
            opts = {"colback": back, "colframe": frame, "colbacktitle": frame,
                    "fonttitle": "\\bfseries\\color{white}", "title": title}
            opts.update(_parse_options(extra or ""))
            self._add(name, 0, opts)
        for m in re.finditer(r"\\utpnewquietbox(?=[\[{\s])", tex):
            args, _ = read_args(tex, m.end(), "ommmm")
            extra, name, frame, titlecolor, title = args
            opts = {"colback": "white", "colframe": frame, "fonttitle": "\\bfseries\\color{" + (titlecolor or "") + "}",
                    "title": title}
            opts.update(_parse_options(extra or ""))
            self._add(name, 0, opts)

    def _add(self, name: str, nargs: int, opts: dict[str, str]) -> None:
        if not name or name.startswith("#") or name in self.NOT_CALLOUTS:
            return
        pal = self.palette
        fonttitle = opts.get("fonttitle", "")
        m = re.search(r"\\color\{([^}]*)\}", fonttitle)
        title_back = opts.get("colbacktitle")
        self.boxes[name] = BoxStyle(
            name=name, nargs=nargs, title=opts.get("title", ""),
            back=pal.resolve(opts.get("colback"), "#FFFFFF"),
            frame=pal.resolve(opts.get("colframe"), "#246B9E"),
            title_back=pal.resolve(title_back) if title_back else None,
            title_color=pal.resolve(m.group(1) if m else None, "#FFFFFF" if title_back else "#18324A"),
            options=opts,
        )

    # ------------------------------------------------------------------ lookup

    def is_callout(self, env: str) -> bool:
        return env in self.boxes

    def title_tex(self, env: str, args: list[str | None]) -> str:
        """The LaTeX of a box's title, with its arguments and title macros filled in."""
        box = self.boxes[env]
        title = box.title
        for k, a in enumerate(args, 1):
            title = title.replace(f"#{k}", a or "")
        for _ in range(3):
            title = re.sub(r"\\(utptitle\w+)", lambda m: self.titles.get(m.group(1), ""), title)
        return title
