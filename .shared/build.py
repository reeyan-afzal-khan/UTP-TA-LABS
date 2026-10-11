#!/usr/bin/env python3
"""Build the course books, and optionally publish them to .all_pdfs/.

    python .shared/build.py                 build every course
    python .shared/build.py ML OS           build two courses (code or folder name)
    python .shared/build.py DS --publish    build, then refresh .all_pdfs/data-science/

Building runs pdflatex from inside the course folder, so the relative
paths in main.tex resolve, and writes everything it produces to
.latex-build/<course>/ at the repository root. That folder is ignored by
git, so the course folders never collect .aux, .log or .pdf files.

Publishing copies the book to .all_pdfs/<course>/<CODE>-Book.pdf and
splits it the way a lab session is taught. Each lab gets a folder holding
the chapters read since the previous lab and the lab sheet itself:

    .all_pdfs/<course>/
        <CODE>-Book.pdf
        Lab-01/Chapter-01.pdf, Chapter-02.pdf, Lab-Activity.pdf
        Lab-02/Chapter-03.pdf, Lab-Activity.pdf
        Lab-07-08/Chapter-21.pdf, Lab-Activity-07.pdf, Lab-Activity-08.pdf
        Capstone-Project.pdf

Labs that follow the same chapters with nothing between them share one
folder. Part and stage divider pages are left out of the split files. An
unnumbered chapter before Chapter 1 is named Chapter-00A, Chapter-00B.

The page ranges come from the book's own contents file, and the number of
front-matter pages from the \\utpfrontpages line \\utpfrontmatter writes
to the .aux file, so the split always matches the book that was built.

Requires pdflatex, and for --publish the pdfseparate and pdfunite tools,
which ship with MiKTeX and with TeX Live's poppler utilities.
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
BUILD = ROOT / ".latex-build"
PUBLISH = ROOT / ".all_pdfs"
MAX_PASSES = 4


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


def build(folder: Path) -> BuildResult:
    outdir = BUILD / course_slug(folder)
    outdir.mkdir(parents=True, exist_ok=True)
    cmd = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error", "-file-line-error",
           f"-output-directory={outdir}", "main.tex"]
    log = outdir / "main.log"
    for _ in range(MAX_PASSES):
        run = subprocess.run(cmd, cwd=folder, capture_output=True, text=True, errors="replace")
        text = log.read_text(errors="replace") if log.exists() else run.stdout
        if run.returncode != 0:
            errors = [line for line in text.splitlines() if line.startswith("!") or ":error:" in line.lower()
                      or re.match(r"^.+:\d+: ", line)]
            return BuildResult(folder, outdir, False, errors=errors[:10] or ["pdflatex failed; see " + str(log)])
        if "Rerun to get" not in text and "Label(s) may have changed" not in text:
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
    number: str        # chapter or lab number, "" if unnumbered
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


def contents(outdir: Path) -> list[Entry]:
    aux = (outdir / "main.aux").read_text(errors="replace")
    front = re.search(r"\\gdef\s*\\utpfrontpages\s*\{(\d+)\}", aux)
    total = re.search(r"\\gdef\s*\\@abspage@last\s*\{(\d+)\}", aux)
    if not front or not total:
        sys.exit(f"{outdir / 'main.aux'} has no \\utpfrontpages line; rebuild with the current .shared/utpnotes.tex")
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
            number, title = num.group(1), title[num.end():]
        if kind == "lab":
            number = re.match(r"Lab (\d+)", title).group(1)
        elif kind == "chapter" and re.match(r"Stage \S+ ---", title):
            kind = "divider"              # \substage pages
        title = re.sub(r"\\[a-zA-Z]+\s*(\{[^}]*\})?|[{}~]", " ", title)
        entries.append(Entry(kind, " ".join(title.split()), number, int(page) + front))
    for this, after in zip(entries, entries[1:] + [None]):
        this.end = (after.start - 1) if after else total
    return entries


@dataclass
class Bundle:
    labs: list[Entry] = field(default_factory=list)
    chapters: list[tuple[str, Entry]] = field(default_factory=list)


def plan(entries: list[Entry]) -> tuple[list[Bundle], Entry | None]:
    """Group chapters with the lab they lead to; find the capstone."""
    bundles: list[Bundle] = []
    pending: list[tuple[str, Entry]] = []
    last_number, letter = 0, 0
    capstone = None
    for entry in entries:
        if entry.kind == "chapter":
            if entry.number:
                last_number, letter = int(entry.number), 0
                name = f"Chapter-{last_number:02d}"
            else:
                name = f"Chapter-{last_number:02d}{chr(ord('A') + letter)}"
                letter += 1
            pending.append((name, entry))
        elif entry.kind == "lab":
            if pending or not bundles:
                bundles.append(Bundle(chapters=pending))
                pending = []
            bundles[-1].labs.append(entry)
    for name, entry in pending:           # chapters after the last lab
        if "capstone" in entry.title.lower():
            capstone = entry
    return bundles, capstone


def extract(pages_dir: Path, first: int, last: int, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    parts = [str(pages_dir / f"p-{n}.pdf") for n in range(first, last + 1)]
    if len(parts) == 1:
        shutil.copyfile(parts[0], target)
    else:
        subprocess.run(["pdfunite", *parts, str(target)], check=True, capture_output=True)


def publish(result: BuildResult, root: Path) -> list[Path]:
    for tool in ("pdfseparate", "pdfunite"):
        if not shutil.which(tool):
            sys.exit(f"--publish needs {tool} (MiKTeX ships it; on Linux install poppler-utils).")
    folder, outdir = result.folder, result.outdir
    target = root / course_slug(folder)
    bundles, capstone = plan(contents(outdir))

    # Replace only what this script writes, so nothing else in the folder is touched.
    if target.exists():
        for old in list(target.glob("Lab-*")) + list(target.glob("*-Book.pdf")) + [target / "Capstone-Project.pdf"]:
            if old.is_dir():
                shutil.rmtree(old)
            elif old.exists():
                old.unlink()
    target.mkdir(parents=True, exist_ok=True)

    written = []
    book = target / f"{course_code(folder)}-Book.pdf"
    shutil.copyfile(result.pdf, book)
    written.append(book)
    with tempfile.TemporaryDirectory() as tmp:
        pages_dir = Path(tmp)
        # Both poppler tools warn about hyperref's link dictionaries on
        # every page; the warnings are harmless, so they are not shown.
        subprocess.run(["pdfseparate", str(result.pdf), str(pages_dir / "p-%d.pdf")],
                       check=True, capture_output=True)
        for bundle in bundles:
            numbers = [int(lab.number) for lab in bundle.labs]
            name = f"Lab-{numbers[0]:02d}" + (f"-{numbers[-1]:02d}" if len(numbers) > 1 else "")
            for chapter_name, chapter in bundle.chapters:
                out = target / name / f"{chapter_name}.pdf"
                extract(pages_dir, chapter.start, chapter.end, out)
                written.append(out)
            for lab in bundle.labs:
                sheet = "Lab-Activity.pdf" if len(numbers) == 1 else f"Lab-Activity-{int(lab.number):02d}.pdf"
                out = target / name / sheet
                extract(pages_dir, lab.start, lab.end, out)
                written.append(out)
        if capstone:
            out = target / "Capstone-Project.pdf"
            extract(pages_dir, capstone.start, capstone.end, out)
            written.append(out)
    return written


# ------------------------------------------------------------------------ main

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                     formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog="Courses: " + ", ".join(
                                         f"{course_code(f)}" for f in course_folders()))
    parser.add_argument("courses", nargs="*", help="course codes (ML) or folder names; default: all")
    parser.add_argument("--publish", action="store_true",
                        help="also refresh .all_pdfs/<course>/ with the book and its lab bundles")
    parser.add_argument("--publish-root", type=Path, default=PUBLISH, help=argparse.SUPPRESS)
    args = parser.parse_args()

    if not shutil.which("pdflatex"):
        sys.exit("pdflatex was not found on PATH.")
    failed = False
    for folder in select_courses(args.courses):
        result = build(folder)
        if not result.ok:
            failed = True
            print(f"FAIL  {folder.name}")
            for line in result.errors:
                print(f"      {line}")
            continue
        note = f", {len(result.warnings)} warnings (see {result.outdir / 'main.log'})" if result.warnings else ""
        print(f"ok    {folder.name}: {result.pages} pages -> {result.pdf.relative_to(ROOT)}{note}")
        if args.publish:
            written = publish(result, args.publish_root)
            print(f"      published {len(written)} files to {args.publish_root / course_slug(folder)}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
