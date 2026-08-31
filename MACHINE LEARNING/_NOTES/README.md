# Machine Learning — LaTeX notes

Self-contained LaTeX source for the Machine Learning course notes. This folder has no
dependencies on anything outside it, so it can be copied, zipped, or version-controlled
on its own.

## Build

```bash
make
```

Produces `machine-learning-notes.pdf`. Intermediate files stay in `build/`.

| Target | Effect |
| --- | --- |
| `make` | Build the PDF |
| `make watch` | Rebuild on every save (`latexmk -pvc`) |
| `make check` | Report undefined references and overfull boxes from the last build |
| `make clean` | Remove intermediate files, keep the PDF |
| `make distclean` | Remove `build/` and the PDF |

Without `make`, run `latexmk` directly — `.latexmkrc` carries the same settings.
Without `latexmk`, the Makefile falls back to three `pdflatex` passes (needed so the
table of contents and cross-references resolve).

## Requirements

A TeX distribution with `pdflatex`: TeX Live (Linux/macOS), MiKTeX (Windows), or MacTeX.
The preamble degrades gracefully if optional packages are missing — `sourcesanspro`
falls back to Helvetica, and `glyphtounicode` is loaded only when present.

## Layout

```
main.tex        preamble, visual system, and document skeleton
chapters/       teaching content, one file per chapter
labs/           practical milestones, one file per lab   (where the course has labs)
appendices/     reference material                        (where the course has them)
assets/         figures                                   (where the course has them)
```

`main.tex` pulls each piece in with `\input`; add a chapter by dropping a file into
`chapters/` and adding one `\input` line.
