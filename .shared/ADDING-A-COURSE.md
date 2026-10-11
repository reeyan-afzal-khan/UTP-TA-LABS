# Adding a course

A course is a folder at the repository root holding a book (`main.tex`, its
chapters and its lab sheets) and the material the labs run on. Everything the
books have in common lives here in `.shared/`, so a new course is mostly a
matter of filling in a template: `main.tex` is configuration plus a list of
chapters, and the chapters use the shared boxes, figures and listing styles by
name.

Work down this list. Each step says what to do and how to check it.

---

## 1. Create the folder

Name it after the course, in capitals, exactly as it appears in the course
outline:

```bash
mkdir -p "NEW COURSE/chapters" "NEW COURSE/labs"
```

Every course uses the same layout. Only `main.tex`, `chapters/` and `labs/`
are required; add the others when the course needs them, under these names:

| Path               | Holds                                                              |
| ------------------ | ------------------------------------------------------------------ |
| `README.md`        | the course guide: labs, what to read first, how to run the code    |
| `main.tex`         | the book: configuration and the chapter list                       |
| `chapters/`        | one `.tex` per chapter, `01-topic-name.tex`, plus `course-map.tex` |
| `labs/`            | one `.tex` per lab sheet, `01-topic-name.tex`                      |
| `appendices/`      | reference material printed after the labs                          |
| `figures/`         | images the book includes; found without a path                     |
| `all_datasets/`    | data the labs read; treat it as read-only                          |
| `all_experiments/` | runnable lab code: notebooks, scripts, C sources, one per lab      |
| `results/`         | evidence the lab code writes, one `labNN/` folder per lab          |
| `models/`          | trained models the labs save                                       |
| `requirements.txt` | Python packages the lab code needs                                 |
| `0.from_lecturer/` | the lecturer's slides, manuals and tutorials the book is built on  |

Build products never go in the course folder: `build.py` writes them to
`.latex-build/` at the repository root.

## 2. Copy the template

```bash
cp .shared/TEMPLATE-main.tex "NEW COURSE/main.tex"
```

The template is commented top to bottom, and every decision point is marked
`REQUIRED` or `OPTIONAL`. Do not edit the template itself; it is the starting
point for the next course too.

## 3. Fill in the REQUIRED blocks

In order, as they appear in the file:

1. **Course configuration**: `\utprunninghead` and `\utplabtotal`, then the
   cover text, `\utpcoursetitle` and `\utpcourseoutline`. The title page
   layout itself is `.shared/cover.tex` and is never copied.
2. **Contents page**: one `\utpcontentspage` line. Adjust its three spaces
   until the Learning Path fills exactly one page.
3. **Chapters**: one `\input` per chapter, in reading order, after the
   `\utpfrontmatter` line that prints the cover, contents and course map.

Then the optional one-liners you actually need: a diagram library
(`\utpusediagrams{network}`), pseudocode (`\utpusealgorithms`), a default
listing language (`\lstset{style=utppython}`). Delete the `OPTIONAL` blocks you
do not use. `MACHINE LEARNING/main.tex` is the one to imitate: configuration
and a chapter list, nothing else.

## 4. Write the first chapter

Start from a chapter of an existing book rather than from nothing; the
structure is the point, and it is easier to see than to describe.
Algorithms & Data Structures is the reference book, and
[`STYLE-GUIDE.md`](STYLE-GUIDE.md) spells out its rules for tables, figures,
the course map, chapters and lab sheets.

A chapter opens with a guide box and closes with a recap:

```latex
\chapter{What a Process Is}
\label{ch:process}

\chapterguide%
  {What the reader should already have: the prior chapters or skills.}
  {What they will be able to do by the end, as concrete verbs.}

\section{Starting point}
...

\begin{chapterrecap}
\begin{itemize}
  \item The three or four things a reader should carry forward.
\end{itemize}
\end{chapterrecap}

\input{labs/01-processes}
```

Use the shared names only. Every box, frame, list, listing style and colour is
listed in [`README.md`](README.md); the ones a chapter reaches for most:

| Name                         | Use it for                                          |
| ---------------------------- | --------------------------------------------------- |
| `keyidea`                    | the single sentence the section is built around     |
| `intuition`                  | the plain-language version, before the formal one   |
| `workedexample`              | a worked calculation or trace                       |
| `pitfall`                    | the mistake this topic reliably produces            |
| `tryit`, `quickcheck`        | a short exercise; a question with the answer nearby |
| `chapterrecap`               | the closing summary                                 |
| `utpfigure`                  | a centred frame around a drawing, optional title    |
| `utptable`                   | a frame around a table                              |
| `utpfig`                     | a frame with a numbered caption `\figref` can cite  |
| `utpsteps`                   | a numbered Step 1 / Step 2 list                     |
| `sourcebasis`, `\sourceimage`| what lecturer material a page is built on           |
| `UTPNavy`, `UTPBlue`, ...    | the palette; never a course-prefixed colour         |

Prefer a diagram to a paragraph wherever the idea is spatial, sequential, or
comparative. The TikZ styles `utpcell`, `utpnode`, `utparrow` and the rest are
always available; the larger vocabularies in `.shared/diagrams/` (networks,
business processes, data objects) load with one line.

## 5. Write the labs

A lab sheet is a `.tex` file in `labs/`, input straight after the chapter it
practises, either at the end of that chapter or in `main.tex`. It opens with
the shared banner, and its body is one `labproject` box:

```latex
\labsection{3}{Scheduling Policies}{sec:lab03}

\begin{labproject}{Compare four policies on one workload}
\labflow{Chapter 4: scheduling metrics.}{Run four policies on the same bursts.}
        {Explain why the order changes a metric.}

\labsourcecard{\texttt{fcfs.c}}{Run processes in arrival order.}{How waiting time accumulates.}
\lstinputlisting[style=utpcnumbered]{all_experiments/Lab03/fcfs.c}

\begin{labquestion}{1}{Compile and run}
...
\end{labquestion}
\begin{labanswer}
...
\expectedoutput
...
\end{labanswer}

\begin{verification} ... \end{verification}
\begin{labdeliverable} ... \end{labdeliverable}
\end{labproject}
```

The `N` in "Lab 3 of N" comes from `\utplabtotal`, which you set once in
step 3. Two rules the finished courses follow:

- **The code in the book is the code that runs.** Keep each lab's code in
  `all_experiments/` and pull it in with `\lstinputlisting`, or paste it
  verbatim from the notebook cell. Never retype it.
- **Every lab runs end to end from a clean checkout** with one command, and
  the lab sheet states that command.

## 6. Build it

From the repository root:

```bash
python .shared/build.py "NEW COURSE"
```

The script runs `pdflatex` from inside the course folder until the
cross-references settle, writes everything to `.latex-build/new-course/`, and
reports the page count, or the first errors if the build failed. A clean
build reports no warnings; if it does, the log it names lists them.

When the book is ready to hand out, publish it:

```bash
python .shared/build.py "NEW COURSE" --publish
```

This copies the book to `.all_pdfs/new-course/` and splits it into one folder
per lab, holding the chapters read since the previous lab and the lab sheet
(`Lab-01/Chapter-01.pdf`, `Lab-01/Lab-Activity.pdf`, ...), plus
`Capstone-Project.pdf` for a chapter titled *Capstone*.

## 7. Register the course

1. Write `NEW COURSE/README.md`, following an existing course README: what
   the course covers, the lab table, how to run the labs, and the folder map.
2. Add a row to the course table in the repository `README.md`, linking the
   course README and, once published, the book PDF.

---

## Changing something shared

If two courses need the same thing, it belongs in `.shared/`, not in both
books. Before adding to `utpnotes.tex`, check whether the hook you want
already exists:

| You want to                         | Do this                                             |
| ----------------------------------- | --------------------------------------------------- |
| rename a box                        | `\def\utptitlepitfall{...}` before the `\input`     |
| tune the contents page              | `\utpcontentspage{...}` after the `\input`          |
| put titles in a solid bar           | `\utpheavycallouts` after the `\input`              |
| let figure and table frames split   | `\utpbreakableframes` after the `\input`            |
| recolour the lab box                | `\utplabprojectcolour{UTPNavy}` after the `\input`  |
| set dense tables compactly          | `\utpcompacttables` after the `\input`              |
| enlarge the diagram cells           | `\utpdiagramsize{1.05cm}{0.85cm}` after the `\input`|
| draw networks, processes, data      | `\utpusediagrams{network}` after the `\input`       |
| set pseudocode                      | `\utpusealgorithms` after the `\input`              |
| add a box only one book needs       | `\utpnewcallout` or `\utpnewquietbox` in that book  |
| change something for every book     | edit the matching section of `utpnotes.tex`         |

A rule of thumb: when a second book wants what the first one wrote, move it
into `.shared/` and leave both books calling it by its shared name. That is
how the figure frames, the lab toolkit, the source-material boxes and the
diagram libraries came to be shared.

Editing `.shared/` changes every book at once, so rebuild them all and compare
before and after. Text comparison catches what a page count misses:

```bash
python .shared/build.py
pdftotext -layout .latex-build/machine-learning/main.pdf after.txt
diff before.txt after.txt
```
