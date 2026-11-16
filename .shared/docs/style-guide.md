# Typst style guide

Content files start with `#import "/.shared/typst/utp.typ": *` and a `#unit(...)` line, so publication can find each chapter or lab:

```typst
#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-cpu-scheduling")

= CPU Scheduling <ch:scheduling>

#chapterguide[What the reader needs first.][What they can do by the end.]

== The decision the scheduler makes

#note[The one idea to carry away from this section.]
#example[Work one example through.]
#lstinput("/OPERATING SYSTEMS/all_experiments/fcfs.c", first: 1, last: 20, lang: "c")
```

`=` is a chapter, `==` a section and `===` a subsection; `#part[...]` in `main.typ` opens a stage. Give each reference target one unique label and keep it when renaming a heading.

## Callouts: Note, Tip, Warning

Only three kinds of aside are framed, and every course uses the same three. Each is a tinted panel with a coloured bar down its left side and its label on a tab across the top edge (`typst/callouts.typ`).

| Callout | Colour | Use it for |
| --- | --- | --- |
| `#note[...]` | amber | something important to keep in mind: the idea to carry away from a section, a clarification, background, how the notes relate to the course material |
| `#tip[...]` | green | practical advice: a shortcut, a better way to work, how to fix a problem, the same job in another tool |
| `#warning[...]` | red | a common mistake, or a step that breaks something, loses work or has consequences |

Keep a callout short and give it one job. If a passage is part of the explanation, write it as ordinary text instead; two callouts of the same kind never sit back to back (merge them). A bold lead-in such as `#strong[Before you begin.]` may open a callout when its subject needs naming.

## Teaching elements without a frame

Everything else is ordinary text, under a short bold label (`typst/elements.typ`):

| Element | Label | Use it for |
| --- | --- | --- |
| `#chapterguide[before][after]` | Before you start / By the end, you can | the opening of every chapter |
| `#example[...]` | Example. (run into the first line) | a calculation or trace to follow with a pen |
| `#exercises[...]` | Exercises | tasks for the reader; several tasks are one numbered list |
| `#questions[...]` | Review questions | short questions that check the chapter |
| `#answers[...]` | Answers | answers to the questions or exercises just above |
| `#summary[...]` | Summary | what to carry forward from the chapter |
| `#checklist[...]`, `#checklist(title: [...])[...]` | Checklist, or the title given | points to check finished work against |
| `#submission[...]` | Submission | what to hand in |

A chapter ends in this order: `summary`, `exercises`, `questions`, `answers`.

Labs open with `#labsection(4, label: <sec:lab04>)[Title]`, then `#labproject[Lab title][brief]`. Inside a lab, `#labroadmap(...)` maps the parts, `#labsetup[...]` lists what to run first, `#labpartopen(...)` opens a part, `#labquestion(n)[Title][prompt]` and `#labanswer[...]` give a question and its solution, and `#labcheckpoint[...]` closes a part. None of these is framed.

## Renaming a label

Labels are defined once: `callout-labels` in `typst/callouts.typ` and `element-labels` in `typst/elements.typ`. A course can rename any of them in its `main.typ`, for example `titles: (questions: [Self-check], solution: [Worked answer])`. Callout colours are `callout-colors` in `typst/palette.typ`.

## From the LaTeX books

| LaTeX | Typst |
| --- | --- |
| `\begin{keyidea}`, `intuition`, `clarification`, reference notes | `#note[...]` |
| `\begin{pitfall}` | `#warning[...]` |
| `\begin{troubleshoot}`, `recommendedworkflow` | `#tip[...]` |
| `\begin{workedexample}` | `#example[...]` |
| `\begin{tryit}`, `yourturn`, `debugtask` | `#exercises[...]` |
| `\begin{quickcheck}`, `checkanswers`, `chapterrecap` | `#questions[...]`, `#answers[...]`, `#summary[...]` |
| `\begin{verification}`, `labdeliverable` | `#checklist[...]`, `#submission[...]` |
| `\begin{utpfig}[short]{caption}{label}` | `#utpfig([caption], label: <label>)[...]` |
| `tabularx` / `tabular` | `#tabularx(columns: ..., header: (...), ...)` |
| `\lstinputlisting[firstline=..]{file}` | `#lstinput(path, first: .., last: .., lang: ..)` |
| a `tikzpicture` | `#canvas({ node(...) connect(...) })` |
| a pgfplots `axis` | `#canvas({ axis(..., addplot(...)) })` |

## Drawings

A drawing is CeTZ code in the chapter or lab that shows it, written with the vocabulary of `typst/diagrams.typ`. That file mirrors TikZ: coordinates are centimetres, options take TikZ's names in Typst form, and the house styles are dictionaries spread into a node or path.

```typst
#canvas({
  node((0, 0), [12], name: "a", ..utpcell)
  node(right-of("a", 0.35), [25], name: "b", ..utpcell)
  connect("a", "b", ..utparrow)
})
```

`node(position, body, ..options)` is `\node`; `connect(points.., ..options)` is `\draw` with `--`, `-|` and `|-`, and with `bend:`, `out-angle:` and `in-angle:` for `to` curves; `rectangle`, `circle-at`, `arc-at`, `grid-at`, `curve`, `smooth-path`, `fit`, `brace` and `coordinate` cover the other path operations. A picture's `x`, `y` and `scale` options are `canvas(x:, y:, scale:)`. Nodes keep their size whatever the picture's units, as TikZ nodes do.

Charts use `typst/plots.typ`: `axis(...)` takes pgfplots' axis keys (`width`, `height`, `xmin`, `xtick`, `xlabel`, `legend-style`, `ybar`, `symbolic-x`, ...) and one `addplot(...)` per `\addplot`, with expressions as Typst functions (`x => x * x`). As in pgfplots, `width` and `height` include 45pt for the labels, ticks are chosen automatically, and the book's chart defaults (muted axis lines, scriptsize tick labels, small navy labels) apply.

A course that drew with its own LaTeX macros keeps them as a Typst file beside its chapters: `ARTIFICIAL INTELLIGENCE/chapters/robot-maze-figures.typ` (the robot maze and game boards) and `MACHINE LEARNING/chapters/study-log-figures.typ` (the study log, its chart styles and node styles).

## Code

Fenced blocks and `lstinput` are framed listings in the book's mono face: Source Code Pro, or Inconsolatazi4 for DCN (`mono:` in `book.with`). `#numbered[...]` around a listing numbers its lines, as `utpcnumbered` did. Syntax colours come from `typst/listings.tmTheme`.

## Changing the design

Edit `typst/palette.typ` for colours, `typst/theme.typ` for sizes and spacing, and the module named in [../README.md](../README.md) for anything else. A shared change affects all nine books: build them all and compare with the LaTeX pages (see [design-parity.md](design-parity.md)).
