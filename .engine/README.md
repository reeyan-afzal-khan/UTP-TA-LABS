# Typst lecture-video engine

The optional lecture engine reads the same `.typ` chapters and labs as the books. It asks the official Typst compiler for evaluated content, then converts headings, prose, callouts, tables, code and figures into editable lecture scripts.

```sh
python .engine/lecture.py list DS
python .engine/lecture.py script DS ch2
python .engine/lecture.py build DS ch2 --draft
```

Install the compiler using `.typst-setup` first. For videos, install `.engine/requirements.txt` in a dedicated Python environment and provide FFmpeg/ffprobe on PATH. `UTP_LECTURES_PYTHON` can identify that environment. Voice generation may require network access.

Course SVG/raster assets are reused directly. Equations are rendered to SVG with Typst. The adapter is under `utplectures/typst/`; the book's semantic export mode lives in `.shared/typst/utp.typ`. Video outputs go to `.all_lectures/`. Typst evaluation and equation intermediates go to `.build/` and can be cleared with step 06.

The document adapter and sample script generation are checked separately from full voice/video rendering. A successful book build does not certify a complete video render.
