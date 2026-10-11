#!/usr/bin/env python3
"""Build the course books and publish them to .all_pdfs/.

    python .shared/build.py                 build and publish every course
    python .shared/build.py ML OS           only these (course code or folder name)
    python .shared/build.py DS --check      build only: report pages and warnings, write nothing

Each book is compiled with pdflatex, from inside its course folder so the
relative paths in main.tex resolve, in a temporary directory outside the
repository. Nothing is written to the course folders, and the only output
is the course's folder under .all_pdfs/, which is replaced as a whole:

    .all_pdfs/<course>/
        <CODE>-Book.pdf               the whole book
        Lab-01/
            Chapter-01A.pdf           each chapter this lab practises
            Chapter-02.pdf
            Lab-Activity.pdf          the lab sheet, the same pages as in the book
        Lab-02/ ...                   one folder for every lab
        Capstone-Project.pdf          a capstone or final-project chapter
        Appendix-A.pdf, ...           appendices and references after the last lab

A lab practises the chapters between the previous lab and itself; a lab
that follows straight after another practises the same chapters. A lab
sheet that practises other chapters names them after its banner with
\\labcovers{ch:crm,ch:accounting}, which writes a \\utplabcovers line to
the .aux file (Enterprise Resource Planning defines it in its main.tex).
Labels are resolved to the printed chapter numbers, so the split follows
any renumbering; plain chapter numbers as printed (2, 1A) also work. Part
and stage divider pages appear only in the book. A chapter file is named
after its printed number (Chapter-03, Chapter-01A); an unnumbered chapter
takes the number before it and a letter (Chapter-00A, Chapter-00B).

Page ranges come from the book's own contents file, and the number of
front-matter pages from the \\utpfrontpages line \\utpfrontmatter writes to
the .aux file, so the split always matches the book that was built. A
failed build keeps its temporary folder and prints where the log is.

Every published PDF is compressed: images printed at more than 200 dpi are
resampled to 200 dpi, and the files are rewritten with shared fonts,
merged duplicates and compressed object streams. Text and drawings are
unchanged.

Requires pdflatex, and for publishing PyMuPDF (pip install pymupdf). Without
PyMuPDF it falls back to poppler's pdfseparate and pdfunite (shipped with
MiKTeX and TeX Live) and does not compress.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBLISH = ROOT / ".all_pdfs"
MAX_PASSES = 5


# --------------------------------------------------------------------- courses

def course_folders() -> list[Path]:
    return sorted(p for p in ROOT.iterdir()
                  if p.is_dir() and not p.name.startswith(".") and (p / "main.tex").exists())


def course_code(folder: Path) -> str:
    """MACHINE LEARNING -> ML, DATA COMMUNICATION & NETWORKING -> DCN."""
    return "".join(word[0] for word in folder.name.split() if word[0].isalpha()).upper()


def course_slug(folder: Path) -> str:
    """MACHINE LEARNING -> machine-learning, ALGORITHMS & DATA STRUCTURES -> algorithms-data-structures."""
    return "-".join(re.findall(r"[a-z0-9]+", folder.name.lower()))


def select_courses(names: list[str]) -> list[Path]:
    folders = course_folders()
    if not names:
        return folders
    chosen = []
    for name in names:
        match = [f for f in folders
                 if name.upper() in (f.name.upper(), course_code(f)) or name.lower() == course_slug(f)]
        if not match:
            known = ", ".join(f"{course_code(f)} ({f.name})" for f in folders)
            sys.exit(f"Unknown course '{name}'. Known courses: {known}")
        chosen.extend(match)
    return chosen


# ----------------------------------------------------------------------- build

@dataclass
class BuildResult:
    folder: Path
    outdir: Path
    ok: bool
    pages: int = 0
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    @property
    def pdf(self) -> Path:
        return self.outdir / "main.pdf"


def build(folder: Path, outdir: Path) -> BuildResult:
    cmd = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error", "-file-line-error",
           f"-output-directory={outdir}", "main.tex"]
    log = outdir / "main.log"
    # LaTeX asks for a rerun when a label moves, but not when only the
    # contents or the list of figures changed, so those files are compared
    # between passes too: the contents page prints the previous pass's.
    lists = [outdir / "main.toc", outdir / "main.lof"]
    text = ""
    for _ in range(MAX_PASSES):
        before = [p.read_bytes() if p.exists() else None for p in lists]
        run = subprocess.run(cmd, cwd=folder, capture_output=True, text=True, errors="replace",
                             stdin=subprocess.DEVNULL)
        text = log.read_text(errors="replace") if log.exists() else run.stdout
        if run.returncode != 0:
            errors = [line for line in text.splitlines()
                      if line.startswith("!") or re.match(r"^.+:\d+: ", line)]
            return BuildResult(folder, outdir, False, errors=errors[:10] or ["pdflatex failed"])
        after = [p.read_bytes() if p.exists() else None for p in lists]
        if ("Rerun to get" not in text and "Label(s) may have changed" not in text
                and before == after):
            break
    warnings = [line for line in text.splitlines()
                if re.search(r"undefined|Overfull|not found|Rerun to get", line)]
    pages = int(m.group(1)) if (m := re.search(r"Output written on .*?\((\d+) pages?", text, re.S)) else 0
    return BuildResult(folder, outdir, True, pages=pages, warnings=warnings)


# ----------------------------------------------------------------------- split

@dataclass
class Entry:
    kind: str          # part, chapter, divider, lab
    title: str
    number: str        # printed chapter number ("3", "1A") or lab number, "" if unnumbered
    start: int         # physical page, 1-based
    end: int = 0


def read_group(text: str, i: int) -> tuple[str, int]:
    """Return the brace group starting at text[i] == '{' and the index after it."""
    depth, j = 0, i
    while True:
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1:j], j + 1
        j += 1


def read_covers(aux: str) -> dict[str, list[str]]:
    """Lab number -> the chapters its \\labcovers names, as printed numbers.

    A \\utplabcovers{<labels or numbers>} line belongs to the lab whose
    contents entry precedes it in the .aux file (both are written when the
    page ships out, in page order). The two-argument form
    \\utplabcovers{<lab>}{<numbers>} names its lab itself.
    """
    labels = {m.group(1): m.group(2) for m in re.finditer(r"\\newlabel\{([^}]+)\}\{\{([^}]*)\}", aux)}
    covers: dict[str, list[str]] = {}
    lab = None
    for m in re.finditer(r"\\contentsline\s*\{lab\}\{Lab (\d+)|\\utplabcovers\{([^}]*)\}(?:\{([^}]*)\})?", aux):
        if m.group(1):
            lab = m.group(1)
            continue
        owner, names = (m.group(2), m.group(3)) if m.group(3) is not None else (lab, m.group(2))
        if owner is None:
            sys.exit(f"\\labcovers{{{names}}} appears before any \\labsection")
        chapters = []
        for name in (n.strip() for n in names.split(",")):
            if not name:
                continue
            if ":" in name:
                if name not in labels:
                    sys.exit(f"Lab {owner}: \\labcovers names {name}, which is not a label in the book")
                name = labels[name]
            chapters.append(name)
        covers[owner] = chapters
    return covers


def contents(outdir: Path) -> tuple[list[Entry], dict[str, list[str]]]:
    """The body entries of the contents with physical page ranges, and any \\labcovers."""
    aux = (outdir / "main.aux").read_text(errors="replace")
    front = re.search(r"\\gdef\s*\\utpfrontpages\s*\{(\d+)\}", aux)
    total = re.search(r"\\gdef\s*\\@abspage@last\s*\{(\d+)\}", aux)
    if not front or not total:
        sys.exit("main.aux has no \\utpfrontpages line; is the book using the current .shared/utpnotes.tex?")
    front, total = int(front.group(1)), int(total.group(1))

    toc = (outdir / "main.toc").read_text(errors="replace")
    entries: list[Entry] = []
    for m in re.finditer(r"\\contentsline\s*\{(part|chapter|lab)\}", toc):
        title, k = read_group(toc, toc.index("{", m.end()))
        page, _ = read_group(toc, toc.index("{", k))
        if not page.isdigit():
            continue                      # front matter, numbered in roman
        kind, number = m.group(1), ""
        if (num := re.match(r"\\numberline\s*\{([^}]*)\}", title)):
            number, title = num.group(1).strip(), title[num.end():]
        if kind == "lab":
            number = re.match(r"Lab (\d+)", title).group(1)
        elif kind == "chapter" and re.match(r"Stage \S+ ---", title):
            kind = "divider"              # \substage pages
        title = re.sub(r"\\[a-zA-Z]+\s*(\{[^}]*\})?|[{}~]", " ", title)
        entries.append(Entry(kind, " ".join(title.split()), number, int(page) + front))
    for this, after in zip(entries, entries[1:] + [None]):
        this.end = (after.start - 1) if after else total
    return entries, read_covers(aux)


def chapter_file(number: str) -> str:
    """'3' -> Chapter-03, '1A' -> Chapter-01A."""
    m = re.fullmatch(r"(\d+)(\w*)", number)
    return f"Chapter-{int(m.group(1)):02d}{m.group(2)}" if m else "Chapter-" + re.sub(r"\W+", "-", number)


def extra_name(title: str, taken: set[str]) -> str:
    """The file name for a chapter after the last lab."""
    if re.search(r"capstone|project", title, re.I) and "Capstone-Project" not in taken:
        return "Capstone-Project"
    if (m := re.match(r"Appendix\s+([A-Z])\b", title)):
        return f"Appendix-{m.group(1)}"
    return "-".join(w[:1].upper() + w[1:] for w in re.findall(r"[A-Za-z0-9]+", title))


def plan(entries: list[Entry], covers: dict[str, list[str]]) -> tuple[list[tuple[Entry, list[tuple[str, Entry]]]], list[tuple[str, Entry]]]:
    """Each lab with the chapters it practises, and the named chapters after the last lab."""
    labs = [i for i, e in enumerate(entries) if e.kind == "lab"]
    if not labs:
        return [], []
    last = labs[-1]

    # Names for the chapters up to the last lab.
    names: dict[int, str] = {}
    unnumbered: dict[int, list[int]] = {}
    base = 0
    for i, e in enumerate(entries[:last]):
        if e.kind != "chapter":
            continue
        if e.number:
            names[i] = chapter_file(e.number)
            base = int(m.group()) if (m := re.match(r"\d+", e.number)) else base
        else:
            unnumbered.setdefault(base, []).append(i)
    for b, group in unnumbered.items():
        for n, i in enumerate(group):
            alone = len(group) == 1 and b == 0
            names[i] = f"Chapter-{b:02d}" + ("" if alone else chr(ord("A") + n))
    by_number = {entries[i].number: (names[i], entries[i]) for i in names if entries[i].number}

    bundles: list[tuple[Entry, list[tuple[str, Entry]]]] = []
    pending: list[tuple[str, Entry]] = []
    previous: list[tuple[str, Entry]] = []
    for i, e in enumerate(entries[:last + 1]):
        if e.kind == "chapter":
            pending.append((names[i], e))
        elif e.kind == "lab":
            chapters = pending or previous
            if e.number in covers:
                missing = [n for n in covers[e.number] if n not in by_number]
                if missing:
                    sys.exit(f"Lab {e.number}: \\labcovers names chapters {missing} that come after the last lab "
                             f"or do not exist")
                chapters = [by_number[n] for n in covers[e.number]]
            bundles.append((e, chapters))
            previous, pending = chapters, []

    extras: list[tuple[str, Entry]] = []
    taken: set[str] = set()
    for e in entries[last + 1:]:
        if e.kind == "chapter":
            name = extra_name(e.title, taken)
            taken.add(name)
            extras.append((name, e))
    return bundles, extras


# Published PDFs are compressed. Photos and screenshots are resampled to
# IMAGE_DPI where they are printed at more than that, as JPEG at
# IMAGE_QUALITY: sharp on screen and in print, and a third of the size for a
# screenshot-heavy book. Everything else (text, fonts, vector drawings) is
# kept exactly; duplicate objects are merged and streams compressed.
IMAGE_DPI = 200
IMAGE_QUALITY = 85


def _pymupdf():
    try:
        import pymupdf
    except ImportError:
        try:
            import fitz as pymupdf
        except ImportError:
            return None
    return pymupdf


def _save(doc, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        doc.save(path, garbage=4, deflate=True, clean=True, use_objstms=1)
    except TypeError:                     # PyMuPDF before 1.24: no object streams
        doc.save(path, garbage=4, deflate=True, clean=True)


def _split_pymupdf(pdf: Path, jobs: list[tuple[Path, int, int]]) -> None:
    """Compress the book, then cut each page range from it; fonts are shared within each file."""
    pymupdf = _pymupdf()
    book = pymupdf.open(pdf)
    if hasattr(book, "rewrite_images"):   # PyMuPDF 1.25.3 and later
        book.rewrite_images(dpi_threshold=IMAGE_DPI + 25, dpi_target=IMAGE_DPI, quality=IMAGE_QUALITY)
    for target, first, last in jobs:
        if first == 0:                    # the whole book
            _save(book, target)
            continue
        part = pymupdf.open()
        part.insert_pdf(book, from_page=first - 1, to_page=last - 1)
        part.set_metadata(book.metadata)
        _save(part, target)
        part.close()
    book.close()


def _split_poppler(pdf: Path, jobs: list[tuple[Path, int, int]]) -> None:
    """Without PyMuPDF: split with poppler's tools, uncompressed."""
    for tool in ("pdfseparate", "pdfunite"):
        if not shutil.which(tool):
            sys.exit(f"Publishing needs PyMuPDF (pip install pymupdf) or {tool} "
                     "(MiKTeX ships it; on Linux install poppler-utils).")
    with tempfile.TemporaryDirectory() as tmp:
        pages_dir = Path(tmp)
        # Both poppler tools warn about hyperref's link dictionaries on
        # every page; the warnings are harmless, so they are not shown.
        subprocess.run(["pdfseparate", str(pdf), str(pages_dir / "p-%d.pdf")], check=True, capture_output=True)
        for target, first, last in jobs:
            target.parent.mkdir(parents=True, exist_ok=True)
            if first == 0:
                shutil.copyfile(pdf, target)
                continue
            parts = [str(pages_dir / f"p-{n}.pdf") for n in range(first, last + 1)]
            if len(parts) == 1:
                shutil.copyfile(parts[0], target)
            else:
                subprocess.run(["pdfunite", *parts, str(target)], check=True, capture_output=True)


def publish(result: BuildResult, root: Path) -> list[Path]:
    folder = result.folder
    target = root / course_slug(folder)
    bundles, extras = plan(*contents(result.outdir))

    # (file, first page, last page); page 0 is the whole book.
    jobs: list[tuple[Path, int, int]] = [(target / f"{course_code(folder)}-Book.pdf", 0, 0)]
    for lab, chapters in bundles:
        lab_dir = target / f"Lab-{int(lab.number):02d}"
        jobs += [(lab_dir / f"{name}.pdf", chapter.start, chapter.end) for name, chapter in chapters]
        jobs.append((lab_dir / "Lab-Activity.pdf", lab.start, lab.end))
    jobs += [(target / f"{name}.pdf", chapter.start, chapter.end) for name, chapter in extras]

    # Everything in a course's folder is generated, so it is replaced whole.
    if target.exists():
        shutil.rmtree(target)
    target.mkdir(parents=True)
    if _pymupdf() is not None:
        _split_pymupdf(result.pdf, jobs)
    else:
        print("      PyMuPDF is not installed, so the PDFs are not compressed (pip install pymupdf)")
        _split_poppler(result.pdf, jobs)
    return [path for path, _, _ in jobs]


# ------------------------------------------------------------------------ main

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog="Courses: " + ", ".join(course_code(f) for f in course_folders()))
    parser.add_argument("courses", nargs="*", help="course codes (ML) or folder names; default: all")
    parser.add_argument("--check", action="store_true",
                        help="build only: report pages and warnings, write nothing to .all_pdfs/")
    parser.add_argument("--publish-root", type=Path, default=PUBLISH, help=argparse.SUPPRESS)
    args = parser.parse_args()

    if not shutil.which("pdflatex"):
        sys.exit("pdflatex was not found on PATH.")
    failed = False
    for folder in select_courses(args.courses):
        outdir = Path(tempfile.mkdtemp(prefix=f"utp-{course_slug(folder)}-"))
        result = build(folder, outdir)
        if not result.ok:
            failed = True
            print(f"FAIL  {folder.name}  (log kept at {outdir / 'main.log'})")
            for line in result.errors:
                print(f"      {line}")
            continue
        note = f", {len(result.warnings)} warnings" if result.warnings else ""
        if args.check:
            print(f"ok    {folder.name}: {result.pages} pages{note}")
            for line in result.warnings[:10]:
                print(f"      {line}")
        else:
            written = publish(result, args.publish_root)
            target = args.publish_root / course_slug(folder)
            print(f"ok    {folder.name}: {result.pages} pages{note} -> "
                  f"{len(written)} files in {target.relative_to(ROOT) if target.is_relative_to(ROOT) else target}")
        shutil.rmtree(outdir, ignore_errors=True)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
