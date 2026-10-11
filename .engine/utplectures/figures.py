"""Figures drawn by the book itself: TikZ, pgfplots and tables compiled with the
course's own preamble (same colours, fonts and node styles as the PDF), one
cropped page per figure, converted to SVG for Manim to animate.

All the figures of a lecture are compiled in a single pdflatex run in the cache
(nothing is written to the course folders) and cached by their LaTeX source.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

from .courses import Course
from .latex.blocks import FigureBlock
from .paths import cache_dir
from .script import sha1

DOC_TAIL = r"""
\usepackage{varwidth}
\usepackage[active,tightpage]{preview}
\setlength\PreviewBorder{3pt}
\begin{document}
\pagestyle{empty}
"""


def _preamble(course: Course) -> str:
    return course.main_tex.split("\\begin{document}")[0]


def figure_key(course: Course, fig: FigureBlock) -> str:
    return sha1(_preamble(course) + "\x00" + fig.body)


def _page(body: str) -> str:
    return ("\\begin{preview}\\begin{varwidth}{\\linewidth}\\centering\n" + body.strip() +
            "\n\\end{varwidth}\\end{preview}\n")


def _compile(course: Course, bodies: list[str], workdir: Path) -> Path | None:
    tex = workdir / "figures.tex"
    tex.write_text(_preamble(course) + DOC_TAIL + "\n\\clearpage\n".join(_page(b) for b in bodies) +
                   "\n\\end{document}\n", encoding="utf-8")
    subprocess.run(["pdflatex", "-interaction=nonstopmode", f"-output-directory={workdir}", str(tex)],
                   cwd=course.folder, capture_output=True, text=True, encoding="utf-8", errors="replace")
    pdf = workdir / "figures.pdf"
    return pdf if pdf.exists() else None


def _pages(pdf: Path) -> int:
    out = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True)
    for line in out.stdout.splitlines():
        if line.startswith("Pages:"):
            return int(line.split()[1])
    return 0


def _resolve_image(course: Course, name: str) -> Path | None:
    roots = [course.folder, course.folder / "figures", course.folder.parent / ".shared" / "logos"]
    for root in roots:
        for ext in ("", ".png", ".jpg", ".jpeg", ".pdf", ".PNG", ".JPG"):
            p = root / (name + ext)
            if p.exists() and p.is_file():
                return p
    return None


def prepare_figures(course: Course, figs: list[FigureBlock], log=print) -> dict[str, dict]:
    """Return {figure LaTeX sha: {"svg": path} | {"image": path} | {"error": msg}}."""
    folder = cache_dir("figures", course.slug)
    result: dict[str, dict] = {}
    todo: list[tuple[str, FigureBlock]] = []
    for fig in figs:
        key = figure_key(course, fig)
        if fig.image and not fig.body.count("\\begin{tikzpicture}"):
            img = _resolve_image(course, fig.image)
            if img is None:
                result[key] = {"error": f"image not found: {fig.image}"}
            elif img.suffix.lower() == ".pdf":
                png = folder / f"{key}.png"
                if not png.exists():
                    subprocess.run(["pdftoppm", "-png", "-r", "220", "-singlefile", str(img), str(png.with_suffix(""))],
                                   check=False)
                result[key] = {"image": str(png)} if png.exists() else {"error": f"could not convert {img.name}"}
            else:
                result[key] = {"image": str(img)}
            continue
        svg = folder / f"{key}.svg"
        if svg.exists():
            result[key] = {"svg": str(svg)}
        else:
            todo.append((key, fig))
    if not todo:
        return result

    log(f"  compiling {len(todo)} figure(s) with the {course.code} preamble")
    with tempfile.TemporaryDirectory(prefix="utpfig-") as tmp:
        work = Path(tmp)
        pdf = _compile(course, [f.body for _, f in todo], work)
        batches: list[list[tuple[str, FigureBlock]]]
        if pdf is not None and _pages(pdf) == len(todo):
            batches = [todo]
            pdfs = [pdf]
        else:                                           # find the figure that fails: compile one by one
            batches, pdfs = [], []
            for item in todo:
                sub = work / f"one-{len(pdfs)}"
                sub.mkdir()
                p = _compile(course, [item[1].body], sub)
                if p is not None and _pages(p) == 1:
                    batches.append([item])
                    pdfs.append(p)
                else:
                    log_file = sub / "figures.log"
                    err = ""
                    if log_file.exists():
                        lines = [l for l in log_file.read_text(encoding="utf-8", errors="replace").splitlines()
                                 if l.startswith("!")]
                        err = lines[0] if lines else ""
                    result[item[0]] = {"error": f"LaTeX could not draw this figure {err}".strip()}
                    log(f"  ! figure {item[1].label or item[0]} failed: {err}")
        for batch, p in zip(batches, pdfs):
            for page, (key, _) in enumerate(batch, 1):
                svg = folder / f"{key}.svg"
                subprocess.run(["pdftocairo", "-svg", "-f", str(page), "-l", str(page), str(p), str(svg)], check=False)
                result[key] = {"svg": str(svg)} if svg.exists() else {"error": "pdftocairo failed"}
    return result


def has_tools() -> list[str]:
    return [t for t in ("pdflatex", "pdftocairo", "pdfinfo", "ffmpeg", "ffprobe") if shutil.which(t) is None]
