# Adding a course

## 1. Create the course folder

Use the course name at the repository root. Create `main.tex`, `chapters/`
and `labs/`; add other folders only when needed.

| Path | Content |
| --- | --- |
| `README.md` | course overview, lab sequence and run instructions |
| `main.tex` | metadata, options and document reading order |
| `chapters/` | chapter files and `course-map.tex` |
| `labs/` | numbered lab sheets and optional `config.tex` for wording |
| `labs/visuals/` | course-specific diagrams |
| `figures/` | course-specific images |
| `appendices/` | reference material |
| `all_experiments/` | runnable notebooks and source code |
| `all_datasets/` | input data |
| `results/`, `models/` | generated lab evidence and models, when applicable |
| `requirements.txt` | runtime dependencies, when applicable |
| `0.from_lecturer/` | supplied source material, when applicable |

Keep build output outside course source folders.

## 2. Copy and configure the entry point

Copy [TEMPLATE-main.tex](TEMPLATE-main.tex) into the new course as `main.tex`.
Keep its five-section structure:

1. Set course metadata and any box-title overrides.
2. Load `../.shared/utpnotes` once.
3. Select only needed options: libraries, language, contents spacing.
4. Input course-specific content helpers, if any.
5. List chapters and labs in reading order after `\utpfrontmatter`.

Use `\input{chapters/00-toolkit}` for an introductory toolkit. Its chapter
command advances numbering normally, like every other chapter. The older
`\utptoolkit` spelling is an alias for the same input behaviour.

## 3. Write chapters and labs

Follow [STYLE-GUIDE.md](STYLE-GUIDE.md). Reuse the existing shared vocabulary
before adding new formatting. A chapter can start with `\chapterguide` and
end with `chapterrecap`. A lab starts with the common banner:

```latex
\labsection{1}{Lab title}{sec:lab01}
\begin{labproject}{Practical goal}
\labflow{Chapter connection.}{What to achieve.}{What to explain.}
% Activities, code, and diagrams.
\begin{verification}
% Evidence that the work is correct.
\end{verification}
\begin{labdeliverable}
% What to submit, when applicable.
\end{labdeliverable}
\end{labproject}
```

Keep runnable code in `all_experiments/`. Prefer `\lstinputlisting` so the
printed code matches the runnable source. State how to run each lab.
Use `\labcovers{ch:label,...}` for labs covering nonadjacent chapters.

## 4. Reuse or extend the shared style

See the [module map](README.md#where-to-make-a-change) before adding code.
Shared boxes, text helpers, diagram frames, and notebook routines already
cover common needs. Add a reusable component to its owning module, using
existing constructors and the UTP palette. Keep course-specific wording in
metadata or `labs/config.tex`; keep subject-specific figures in the course.

Do not put `\newcommand`, `\newenvironment`, colour definitions or typography
overrides in `main.tex`. It should remain a readable configuration and
reading-order file. Optional package imports and shared option calls are fine.

## 5. Validate and document

Follow [Building and verification](README.md#building-and-verification).
Check the cover, contents, representative lab pages, references and overflow.
Changes to shared modules require rebuilding every affected course.

Write the course README, then add it to the repository's course index.
Published PDFs are separate outputs; do not edit their contents by hand.
