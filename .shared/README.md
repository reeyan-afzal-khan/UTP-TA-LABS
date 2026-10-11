# Shared layer

Everything the course books have in common, and everything needed to build
them, lives in this folder. A course folder holds only its own content; its
`main.tex` reaches all of this through one line:

```latex
\input{../.shared/utpnotes}
```

Change something here and every book changes with it. Back to the
[repository README](../README.md).

## What is here

| Path                                       | What it is                                                         |
| ------------------------------------------ | ------------------------------------------------------------------ |
| [`utpnotes.tex`](utpnotes.tex)             | the shared preamble: packages, palette, boxes, figures, lab toolkit |
| [`cover.tex`](cover.tex)                   | the title page, filled in from each book's configuration           |
| [`logos/`](logos)                          | the UTP and department logos the cover prints                      |
| [`diagrams/network.tex`](diagrams/network.tex)           | TikZ vocabulary for networks and protocols            |
| [`diagrams/process.tex`](diagrams/process.tex)           | TikZ vocabulary for business processes                |
| [`diagrams/data-objects.tex`](diagrams/data-objects.tex) | TikZ vocabulary for in-memory data and flowcharts     |
| [`build.py`](build.py)                     | builds books into `.latex-build/` and publishes them to `.all_pdfs/` |
| [`TEMPLATE-main.tex`](TEMPLATE-main.tex)   | the starting point for a new course's `main.tex`                   |
| [`STYLE-GUIDE.md`](STYLE-GUIDE.md)         | the house style every book follows: tables, figures, chapters, labs |
| [`ADDING-A-COURSE.md`](ADDING-A-COURSE.md) | the checklist for adding a course                                  |

## Building

```bash
python .shared/build.py                  # every book
python .shared/build.py ML OS            # by course code or folder name
python .shared/build.py DS --publish     # build, then refresh .all_pdfs/data-science/
```

The course codes are the initials of the folder name: `ADS`, `AI`, `DCN`,
`DS`, `ERP`, `FI`, `ML`, `OS`. Building needs `pdflatex` (MiKTeX or TeX Live);
publishing also needs `pdfseparate` and `pdfunite`, which MiKTeX ships and
which Linux provides in `poppler-utils`. Output goes to `.latex-build/<course>/`,
which git ignores.

A book can still be built by hand from inside its folder,
`pdflatex main.tex` three times, which is what an online editor does.

## Naming

There is one name for each idea, and every book uses it. A name is either an
unprefixed learning box (`keyidea`, `labproject`) or carries the `utp` prefix
(`utpfigure`, `utppython`, `UTPNavy`, `utpcell`). Course prefixes (`ml`, `ds`,
`erp`, ...) are not used anywhere, so a chapter moved between books compiles
unchanged.

A box only one book needs is declared in that book's `main.tex` with a shared
constructor (`\utpnewcallout`, `\utpnewquietbox`). When a second book wants it,
it moves into `utpnotes.tex`.

## Reference

### Configuration, set before the `\input`

| Macro                    | Sets                                              | Default                  |
| ------------------------ | ------------------------------------------------- | ------------------------ |
| `\utprunninghead`        | left running head                                 | Course Notes             |
| `\utplabtotal`           | the N in "Lab 3 of N"                             | 10                       |
| `\utpcoursetitle`        | cover title and PDF title                         | the running head         |
| `\utpdocumentsubtitle`   | line under the cover title                        | Teaching Assistant Guide |
| `\utpcourseoutline`      | the sentence or two on the cover                  | empty                    |
| `\utpoutlineheading`     | heading above it                                  | COURSE OUTLINE           |
| `\utpauthor`, `\utpauthorrole` | the PREPARED BY block                       | Reeyan Afzal Khan, Graduate Research Assistant |
| `\utpcoursemap`          | overview chapter after the contents               | `chapters/course-map`    |
| `\utpstyleparts`         | 0 for a book without `\part`                      | 1                        |
| `\utpchapterlabel`       | word in the chapter badge                         | CHAPTER                  |
| `\utpchaptertocword`, `\utpchaptertocindent`, `\utpchaptertocnumwidth` | chapter entries in the contents | Chapter~, 1.5em, 6em |
| `\utpmonofont`           | `sourcecodepro` or `inconsolata`                  | sourcecodepro            |
| `\utpextragraphicspath`  | image folders searched before `figures/`          | none                     |
| `\utptitle...`           | the title of any box, e.g. `\utptitlepitfall`     | see section 8            |

### Book settings, one line each after the `\input`

| Command                                         | Effect                                                        |
| ----------------------------------------------- | ------------------------------------------------------------- |
| `\utpcontentspage{size}{part size}{p}{c}{l}`    | how loosely the one-page contents is set                      |
| `\utpusediagrams{network,process,data-objects}` | load diagram libraries                                        |
| `\utpusealgorithms`                             | load algorithm2e, coloured to match                           |
| `\utpdiagramsize{w}{h}`                         | resize `utpcell` and the other array cells                    |
| `\utpheavycallouts`                             | solid title bars on keyidea, workedexample, intuition, firstread |
| `\utpbreakableframes`                           | `utpfigure` and `utptable` may split over a page              |
| `\utplabprojectcolour{colour}`                  | the `labproject` box in another colour                        |
| `\utpcompacttables`                             | `tabularx` tables in footnotesize with centred cells          |
| `\lstset{style=utpcpp}`                         | the default listing style                                     |

### Boxes

| Kind              | Names |
| ----------------- | ----- |
| explaining        | `keyidea`, `intuition`, `workedexample`, `pitfall`, `analogy`, `firstread`, `optionaltopic`, `secondpass`, `libnote` |
| asking            | `tryit`, `quickcheck`, `debugtask`, `decisionmemo`, `coursechoice`, `miniproject` |
| chapter frame     | `\chapterguide{before}{after}` opens a chapter, `chapterrecap` closes it |
| with a title arg  | `modelcard{title}`, `labproject{title}` |
| source material   | `sourcebasis` (what a chapter is built on) |
| lab               | `labmode`, `labquestion{n}{title}`, `labanswer`, `checkanswers`, `verification`, `troubleshoot`, `labdeliverable` |

### Figures and tables

| Name                                   | Use                                                              |
| -------------------------------------- | ---------------------------------------------------------------- |
| `utpfigure`, `utpfigure[Title]`        | centred frame around a drawing, with an optional title bar       |
| `utptable`                             | frame around a `tabular` or `tabularx`                           |
| `\utpth{text}`                         | a table header cell: centred, bold, navy (see `STYLE-GUIDE.md`)  |
| `utpfig[short]{caption}{fig:label}`    | frame with a numbered caption; never separated from its drawing  |
| `\sourceimage[width]{title}{file}`     | a screenshot from lecturer material, in a titled frame           |
| `\compactsourceimage[width]{title}{file}` | the same, kept to a smaller height                            |
| `\fignote{text}`                       | a short muted line under a drawing                               |
| column types `D{width}`, `Y`           | ragged fixed-width and ragged stretching `tabularx` columns      |

### Lab sheets

| Name                                 | Use                                                      |
| ------------------------------------ | -------------------------------------------------------- |
| `\labsection{n}{title}{label}`       | the "Lab n of N" banner, a new page and a contents entry |
| `labproject{title}`                  | the box that holds the whole sheet                       |
| `\labflow{chapter}{goal}{explain}`   | the three-line brief under the title                     |
| `\labsourcecard{file}{does}{inspect}`| the heading over a listed source file                    |
| `labquestion` / `labanswer`          | a task as the student meets it, then the worked answer   |
| `\expectedoutput`                    | the "Reference output." line before printed output       |

### Text and lists

`\term{}` a defined term, `\cmd{}` inline code, `\lib{}` a library name,
`\chapref{}`, `\secref{}`, `\figref{}`, `\chapsref{}{}` cross-references,
`\cxg{}`, `\cxo{}`, `\cxr{}` coloured maths, `\given`, `\argmin`, `\argmax`,
`\coretag`, `\latertag`, `\kagglesource{url}{name}`, `\substage{id}{title}{summary}`,
and the `utpsteps` list (Step 1:, Step 2:, ...).

### Colours

`UTPNavy`, `UTPBlue`, `UTPTeal`, `UTPGreen`, `UTPOrange`, `UTPRed`, `UTPPurple`,
`UTPGold`, `UTPInk`, `UTPMuted`, and the tints `UTPPaleBlue`, `UTPPaleTeal`,
`UTPPaleOrange`, `UTPPaleRed`, `UTPPalePurple`, `UTPPaleGray`.

### Listing styles

| Style                               | For                                       |
| ----------------------------------- | ----------------------------------------- |
| `utpcode`, `utpterminal`            | the two base looks: code, and terminal I/O |
| `utppython`, `utpr`, `utpc`, `utpcpp`, `utpbash` | one per language            |
| `utpcnumbered`, `utpbashnumbered`   | complete source files, with line numbers  |
| `vrp` (network library)             | device transcripts inside a `vrpbox`      |

### Diagrams

Always available: `utpcell`, `utphot`, `utpdone`, `utpdim`, `utpwall`,
`utpnode`, `utpnodehot`, `utpnodedone`, `utpnodedim`, `utparrow`, `utpptr`,
`utpdash`, `utpedge`, `utplabel`, `utptag`, `utpbrace`, `utpstep`, `utpstage`,
`utppanel`, `utpbox`.

| Library        | Load with                        | Provides |
| -------------- | -------------------------------- | -------- |
| `network`      | `\utpusediagrams{network}`       | `router`, `switch`, `host`, `server`, `link`, path styles, `\protorow` header maps, `\seqactor`/`\seqmsg` sequence diagrams, `state` machines, `layer` stacks, `vrpbox` transcripts |
| `process`      | `\utpusediagrams{process}`       | `procstep`, `procdoc`, `procgood`/`procbad`/`procwarn`, `procterm`, `procdec`, `procdb`, swimlanes, `procflow` arrows, status chips |
| `data-objects` | `\utpusediagrams{data-objects}`  | `cell`, `slot`, `dscol`/`dshead` for vectors, lists and data frames; `fcbox`, `fcdiamond`, `fcedge` flowcharts |
