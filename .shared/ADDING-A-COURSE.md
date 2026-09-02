# Adding a course

A course book is a folder at the repository root holding chapters, labs, and
one `main-<code>.tex` that binds them together. Everything the eight existing
books have in common lives here in `.shared/`, so a new course is mostly a
matter of filling in a template.

Work down this list. Each step says what to do and how to check it.

---

## 1. Create the folder

Name it after the course, in capitals, exactly as it appears in the course
outline:

```bash
mkdir -p "NEW COURSE/chapters" "NEW COURSE/labs"
```

Two folders are required, and every existing course has them:

| Folder      | Holds                                                    |
| ----------- | -------------------------------------------------------- |
| `chapters/` | one `.tex` per chapter, named `01-topic-name.tex`         |
| `labs/`     | runnable code, one folder per lab: `Lab01/`, `Lab02/`, …   |

Add more only when the book needs them. Two courses do: Data Communication
keeps screenshots in `assets/`, and Enterprise Resource Planning keeps
reference material in `appendices/`. If you add an image folder, name it in
`\graphicspath` alongside `../.shared/`.

Pick a short code for the course — `ads`, `ai`, `dcn`, `ds`, `erp`, `fi`,
`ml`, `os` are taken. It becomes the filename suffix and the prefix on any
course-specific macro.

## 2. Copy the template

```bash
cp .shared/TEMPLATE-main.tex "NEW COURSE/main-abc.tex"
```

The template is commented top to bottom, and every decision point is marked
`REQUIRED` or `OPTIONAL`. Do not edit the template itself — it is the
starting point for the next course too.

Add the editor entry point every other course has, so an IDE that expects a
`main.tex` finds one:

```bash
printf '%% Canonical editor entry point.\n\\input{main-abc.tex}' > "NEW COURSE/main.tex"
```

## 3. Fill in the REQUIRED blocks

In order, as they appear in the file:

1. **Course configuration** — `\utprunninghead` and `\utplabtotal`.
2. **PDF metadata** — title, subject, keywords.
3. **Listing styles** — rename `abccode` and `abcterminal` to your code, and
   set the language. Both build on the shared bases, so the frame and colours
   match the other books for free.
4. **Cover content** — the course title and a two-line outline. The title page
   layout itself is in `.shared/cover.tex` and should not be copied.
5. **Chapters** — one `\input` per chapter, in reading order.

Delete the `OPTIONAL` blocks you do not use. A short `main-<code>.tex` is the
goal; `MACHINE LEARNING/main-ml.tex` is the one to imitate.

## 4. Write the first chapter

Start from a chapter of an existing book rather than from nothing — the
structure is the point, and it is easier to see than to describe.

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
```

The boxes available to you are listed in section 8 of `utpnotes.tex`. The
common ones:

| Box              | Use it for                                          |
| ---------------- | --------------------------------------------------- |
| `keyidea`        | the single sentence the section is built around     |
| `intuition`      | the plain-language version, before the formal one   |
| `workedexample`  | a worked calculation or trace                       |
| `pitfall`        | the mistake this topic reliably produces            |
| `tryit`          | a short exercise the reader does now                |
| `quickcheck`     | a question with the answer nearby                   |
| `chapterrecap`   | the closing summary                                 |
| `mlfigure`       | a centred frame around a TikZ diagram               |
| `mltable`        | a frame around a table                              |

Prefer a diagram to a paragraph wherever the idea is spatial, sequential, or
comparative. The existing chapters use TikZ directly; the libraries are
already loaded in section 2 of the shared preamble.

## 5. Write the labs

Each lab is a folder under `labs/` holding code that runs, plus whatever data
it needs. Two rules the existing courses follow:

- The code in the book and the code in `labs/` are the same code. Paste from
  the file, do not retype it.
- Every lab runs end to end from a clean checkout with one command, and that
  command is stated in the lab sheet.

A lab sheet in the book opens with the shared banner:

```latex
\labsection{3}{Scheduling Policies}{lab:scheduling}
```

The `N` in "Lab 3 of N" comes from `\utplabtotal`, which you set once in
step 3.

## 6. Build it

From inside the course folder, three passes — once to typeset, once to place
the contents entries, once to settle the page numbers:

```bash
cd "NEW COURSE" && pdflatex main-abc.tex && pdflatex main-abc.tex && pdflatex main-abc.tex
```

Paths in the course file are relative, so building from the repository root
will not find `.shared/`.

Check the log for the things a first build usually gets wrong:

```bash
grep -n "Undefined control sequence\|LaTeX Warning: Reference\|not found" main-abc.log
```

## 7. Register the course

Add a row to the table in the repository `README.md`, linking to
`NEW COURSE/main-abc.tex` with a one-line description of what the notes cover.

---

## Changing something shared

If two courses need the same thing, it belongs in `.shared/`, not in both
books. Before adding to `utpnotes.tex`, check whether the hook you want
already exists:

| You want to                       | Do this                                            |
| --------------------------------- | -------------------------------------------------- |
| rename a box                       | `\def\utptitlepitfall{...}` before the `\input`    |
| restyle a box in one book          | `\renewtcolorbox{pitfall}{...}` after the `\input` |
| add a box only one book needs      | `\newtcolorbox` in that book                       |
| add a package only one book needs  | `\usepackage` in that book                         |
| change something for every book    | edit the matching section of `utpnotes.tex`        |

Editing `utpnotes.tex` changes all eight books at once, so rebuild them and
compare before and after. Text comparison catches what a page count misses:

```bash
pdftotext -layout main-abc.pdf - > after.txt && diff before.txt after.txt
```
