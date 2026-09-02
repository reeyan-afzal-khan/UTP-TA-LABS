# Adding a course

A course book is a folder at the repository root holding chapters, labs, and
one `main.tex` that binds them together. Everything the eight existing books
have in common lives here in `.shared/`, so a new course is mostly a matter of
filling in a template: now that the shared preamble owns the cover, the front
matter and the boxes, a `main.tex` is configuration plus a list of chapters.

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
reference material in `appendices/`. If you add an image folder, name it
in `\utpextragraphicspath`; the shared folder is already on the path.

Pick a short code for the course — `ads`, `ai`, `dcn`, `ds`, `erp`, `fi`,
`ml`, `os` are taken. It prefixes any course-specific macro, box or listing
style, which is what keeps two books from claiming the same name.

## 2. Copy the template

```bash
cp .shared/TEMPLATE-main.tex "NEW COURSE/main.tex"
```

The template is commented top to bottom, and every decision point is marked
`REQUIRED` or `OPTIONAL`. Do not edit the template itself — it is the
starting point for the next course too.

## 3. Fill in the REQUIRED blocks

In order, as they appear in the file:

1. **Course configuration** — `\utprunninghead` and `\utplabtotal`, then the
   cover text: `\utpcoursetitle` and `\utpcourseoutline`. The title page layout
   itself is in `.shared/cover.tex` and should not be copied.
2. **Chapters** — one `\input` per chapter, in reading order, after the
   `\utpfrontmatter` line that prints the cover, contents and course map.

Then the optional blocks you actually need. Listing styles are one line each
and build on the shared bases, so the frame and colours match the other books
for free:

```latex
\lstdefinestyle{abccode}{style=utpcode,language=Python}
\lstdefinestyle{abcterminal}{style=utpterminal}
```

Delete the `OPTIONAL` blocks you do not use. A short `main.tex` is the goal;
`MACHINE LEARNING/main.tex` is the one to imitate — it is configuration and a
chapter list, nothing else.

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

The boxes available to you are listed in section 8 of `utpnotes.tex`, and a
book declares one of its own with `\utpnewcallout` or `\utpnewquietbox` rather
than by writing out the geometry. The common ones:

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
| `utpfig`         | the same frame, with a numbered, referable caption  |
| `verification`   | the evidence that a lab step actually worked        |
| `troubleshoot`   | what to do when it did not                          |

Prefer a diagram to a paragraph wherever the idea is spatial, sequential, or
comparative. The existing chapters use TikZ directly; the libraries are already
loaded in section 2 of the shared preamble, and one line in `main.tex`
— `\utpdiagramstyles{abc}{1.0cm}{0.8cm}` — gives the book the
node styles the other diagrams are drawn with (`abccell`, `abcnode`,
`abcarrow`, and the rest, listed in section 10 of `utpnotes.tex`).

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
cd "NEW COURSE" && pdflatex main.tex && pdflatex main.tex && pdflatex main.tex
```

Paths in the course file are relative, so building from the repository root
will not find `.shared/`.

Check the log for the things a first build usually gets wrong:

```bash
grep -n "Undefined control sequence\|LaTeX Warning: Reference\|not found" main.log
```

## 7. Register the course

Add a row to the table in the repository `README.md`, linking to
`NEW COURSE/main.tex` with a one-line description of what the notes cover.

---

## Changing something shared

If two courses need the same thing, it belongs in `.shared/`, not in both
books. Before adding to `utpnotes.tex`, check whether the hook you want
already exists:

| You want to                       | Do this                                            |
| --------------------------------- | -------------------------------------------------- |
| rename a box                       | `\def\utptitlepitfall{...}` before the `\input`    |
| restyle a box in one book          | `\renewtcolorbox{pitfall}{...}` after the `\input` |
| break figure frames over a page    | `\utpbreakableframes` after the `\input`           |
| put titles in a solid bar          | `\utpheavycallouts` after the `\input`             |
| recolour the lab banner            | `\utplabprojectcolour{UTPNavy}` after the `\input` |
| call a shared box by a local name  | `\utpaliasenv{abctable}{mltable}`                  |
| add a box only one book needs      | `\utpnewcallout` or `\utpnewquietbox` in that book |
| draw diagrams in the house style   | `\utpdiagramstyles{abc}{1.0cm}{0.8cm}`             |
| colour pseudocode                  | `\utpalgorithmstyle` after loading algorithm2e     |
| add a package only one book needs  | `\usepackage` in that book                         |
| change something for every book    | edit the matching section of `utpnotes.tex`        |

A rule of thumb: when a second book wants what the first one wrote, move it
into `utpnotes.tex` and leave both books calling it by name. That is how
`verification`, `troubleshoot`, `utpfig` and the running-text shorthand
(`\figref`, `\lib`, `\given`, `\coretag`) came to be shared.

Editing `utpnotes.tex` changes all eight books at once, so rebuild them and
compare before and after. Text comparison catches what a page count misses:

```bash
pdftotext -layout main.pdf - > after.txt && diff before.txt after.txt
```
