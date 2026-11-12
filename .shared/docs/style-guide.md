# Typst style guide

Content files start with `#import "/.shared/typst/utp.typ": *` and a `#unit(...)` line, so publication can find each chapter or lab. Every LaTeX command and environment of the old books has a Typst counterpart of the same name, so a chapter reads as its LaTeX source did:

```typst
#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-cpu-scheduling")

= CPU Scheduling <ch:scheduling>

#chapterguide[What the reader needs first.][What they can do by the end.]

== The decision the scheduler makes

#keyidea[Explain one central idea.]
#workedexample[Work one example through.]
#lstinput("/OPERATING SYSTEMS/all_experiments/fcfs.c", first: 1, last: 20, lang: "c")
```

`=` is a chapter, `==` a section and `===` a subsection; `#part[...]` in `main.typ` opens a stage. Give each reference target one unique label and keep it when renaming a heading. Labs open with `#labsection(4, label: <sec:lab04>)[Title]` and use `labproject`, `labpartopen`, `labcheckpoint`, `verification`, `labquestion` and `labanswer` as the LaTeX labs did.

| LaTeX | Typst |
| --- | --- |
| `\begin{keyidea}`, `pitfall`, `tryit`, ... | `#keyidea[...]`, `#pitfall[...]`, `#tryit[...]` |
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
