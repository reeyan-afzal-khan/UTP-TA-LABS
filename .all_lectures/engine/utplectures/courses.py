"""Courses and their lectures: one lecture per chapter file and per lab file.

A course is a folder with a main.tex (the same rule as .shared/build.py).
Chapters are the files main.tex \\inputs from chapters/, in book order; labs
are the files \\input from labs/, by a chapter or by main.tex itself.
Each lecture's video takes its source file's name:

    ALGORITHMS & DATA STRUCTURES/chapters/01-introduction.tex
        -> .all_lectures/algorithms-data-structures/chapters/01-introduction.mp4
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from functools import cached_property
from pathlib import Path

from .latex.reader import Source, read_args
from .latex.styles import StyleBook
from .paths import LECTURES, ROOT, SHARED


@dataclass
class Lecture:
    course: "Course"
    kind: str                       # "chapter" | "lab"
    source: Path
    number: str | None = None       # "1" for Chapter 1 / Lab 1; None for unnumbered chapters
    title: str = ""
    labs: list["Lecture"] = field(default_factory=list)   # labs a chapter leads into

    @property
    def stem(self) -> str:
        return self.source.stem

    @property
    def folder(self) -> str:
        return "chapters" if self.kind == "chapter" else "labs"

    @property
    def rel(self) -> str:
        return f"{self.folder}/{self.stem}"

    @property
    def key(self) -> str:
        return f"{self.course.slug}/{self.rel}"

    @property
    def out_dir(self) -> Path:
        return LECTURES / self.course.slug / self.folder

    @property
    def video(self) -> Path:
        return self.out_dir / f"{self.stem}.mp4"

    @property
    def script_path(self) -> Path:
        return self.out_dir / f"{self.stem}.script.yaml"

    @property
    def voice_dir(self) -> Path:
        return LECTURES / self.course.slug / "voice" / self.folder / self.stem

    @property
    def label(self) -> str:
        if self.kind == "lab":
            return f"Lab {self.number}" if self.number else "Lab"
        return f"Chapter {self.number}" if self.number else "Overview"

    def matches(self, selector: str) -> bool:
        sel = selector.lower().strip()
        m = re.fullmatch(r"(ch|chapter|lab|l)[-_ ]?0*(\d+)", sel)
        if m:
            kind = "lab" if m.group(1) in ("lab", "l") else "chapter"
            return self.kind == kind and (self.number or "").lstrip("0") == m.group(2)
        return sel in (self.stem.lower(), self.rel.lower(), self.source.name.lower())


class Course:
    def __init__(self, folder: Path):
        self.folder = folder
        self.code = "".join(w[0] for w in folder.name.split() if w[0].isalpha()).upper()
        self.slug = "-".join(re.findall(r"[a-z0-9]+", folder.name.lower()))
        self.main_tex = (folder / "main.tex").read_text(encoding="utf-8")
        m = re.search(r"\\def\\utpcoursetitle\{", self.main_tex)
        title = read_args(self.main_tex, m.end() - 1, "m")[0][0] if m else folder.name.title()
        self.title = (title or "").replace("\\&", "&").strip()
        m = re.search(r"\\def\\utplabtotal\{(\d+)\}", self.main_tex)
        self.lab_total = m.group(1) if m else None

    def __repr__(self) -> str:
        return f"Course({self.code}, {self.slug})"

    @cached_property
    def styles(self) -> StyleBook:
        shared = (SHARED / "utpnotes.tex").read_text(encoding="utf-8")
        return StyleBook(shared, self.main_tex)

    @cached_property
    def macros(self) -> dict[str, tuple[int, str]]:
        """The book's own one-line \\newcommand definitions, expanded inline."""
        pre = self.main_tex.split("\\begin{document}")[0]
        out: dict[str, tuple[int, str]] = {}
        for m in re.finditer(r"\\newcommand\{\\(\w+)\}(?:\[(\d)\])?\{", pre):
            body, _ = _group(pre, m.end() - 1)
            out[m.group(1)] = (int(m.group(2) or 0), body)
        return out

    @cached_property
    def lectures(self) -> list[Lecture]:
        lectures: list[Lecture] = []
        main = Source(self.main_tex).text.split("\\begin{document}", 1)[-1]
        chapter_no = 0
        seen: set[Path] = set()

        def add_lab(path: Path, parent: Lecture | None) -> None:
            if path in seen or not path.exists():
                return
            seen.add(path)
            text = Source(path.read_text(encoding="utf-8")).text
            m = re.search(r"\\labsection\{", text)
            number, title = None, path.stem
            if m:
                (number, title), _ = read_args(text, m.end() - 1, "mm")
            lab = Lecture(self, "lab", path, (number or "").strip() or None, title or path.stem)
            lectures.append(lab)
            if parent:
                parent.labs.append(lab)

        for m in re.finditer(r"\\(?:input|include)\{([^}]*)\}", main):
            rel = m.group(1).strip()
            path = (self.folder / rel).with_suffix(".tex") if not rel.endswith(".tex") else self.folder / rel
            if rel.startswith("labs/"):
                add_lab(path, None)
                continue
            if not rel.startswith("chapters/") or not path.exists() or path in seen:
                continue
            seen.add(path)
            text = Source(path.read_text(encoding="utf-8")).text
            h = re.search(r"\\chapter(\*?)\{", text)
            number, title = None, path.stem
            if h:
                title = _group(text, h.end() - 1)[0]
                if not h.group(1):
                    chapter_no += 1
                    number = str(chapter_no)
            chapter = Lecture(self, "chapter", path, number, title)
            lectures.append(chapter)
            for lm in re.finditer(r"\\(?:input|include)\{(labs/[^}]*)\}", text):
                lrel = lm.group(1)
                add_lab((self.folder / lrel).with_suffix(".tex") if not lrel.endswith(".tex")
                        else self.folder / lrel, chapter)
        return lectures

    @cached_property
    def labels(self) -> dict[str, str]:
        """label -> how the book refers to it: Figure 1.2, Chapter 3, Section 2.1, Lab 4."""
        labels: dict[str, str] = {}
        for lec in self.lectures:
            text = Source(lec.source.read_text(encoding="utf-8")).text
            if lec.kind == "lab":
                m = re.search(r"\\labsection\{[^}]*\}\{", text)
                if m:
                    args, _ = read_args(text, m.start() + len("\\labsection"), "mmm")
                    if args[2]:
                        labels[args[2]] = f"Lab {lec.number}"
                continue
            ch = lec.number or "0"
            sec = fig = tab = 0
            last = f"Chapter {ch}"                 # what a \label right here refers to
            for m in re.finditer(r"\\(chapter|section)(\*?)\{|\\begin\{(utpfig|figure)\}"
                                 r"|\\captionof\{(table)\}|\\label\{([^}]*)\}", text):
                if m.group(1) == "chapter":
                    last = f"Chapter {ch}"
                elif m.group(1) == "section":
                    if not m.group(2):
                        sec += 1
                        last = f"Section {ch}.{sec}"
                elif m.group(3):
                    fig += 1
                    last = f"Figure {ch}.{fig}"
                    if m.group(3) == "utpfig":     # its label is an argument, not a \label
                        args, _ = read_args(text[m.end():m.end() + 4000], 0, "omm")
                        if args[2]:
                            labels[args[2]] = last
                elif m.group(4):
                    tab += 1
                    last = f"Table {ch}.{tab}"
                elif m.group(5):
                    labels.setdefault(m.group(5), last)
        return labels


def _group(s: str, i: int) -> tuple[str, int]:
    from .latex.reader import read_group
    return read_group(s, i)


def all_courses() -> list[Course]:
    return [Course(p) for p in sorted(ROOT.iterdir())
            if p.is_dir() and not p.name.startswith(".") and (p / "main.tex").exists()]


def find_course(name: str) -> Course | None:
    for c in all_courses():
        if name.upper() in (c.code, c.folder.name.upper()) or name.lower() == c.slug:
            return c
    return None
