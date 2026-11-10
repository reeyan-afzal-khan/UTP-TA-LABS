# Shared LaTeX presentation

Every course loads one public entry point:

```latex
\input{../.shared/utpnotes}
```

`utpnotes.tex` is a short loader. Its modules own typography, colours, page
layout, reusable teaching components and book assembly. Course folders own
subject matter, reading order, runnable code and course-specific wording.

Local installation, VS Code recipes and build scripts live in
[`.latex-setup/`](../.latex-setup/README.md). Keep machine-specific setup out of
these reusable TeX modules.

## Where to make a change

| File or folder | Responsibility |
| --- | --- |
| `utpnotes.tex` | module loading order; the only shared input used by courses |
| `style/rendering.tex` | equivalent native vector fills for faster shared boxes |
| `style/configuration.tex` | default course metadata and configuration |
| `style/packages.tex` | packages and body/code fonts |
| `style/theme.tex` | palette, page spacing, tables, chart defaults |
| `style/contents.tex` | contents entries and Learning Path spacing |
| `style/headings.tex` | chapter/section headings, running headers, footers |
| `style/boxes.tex` | learning boxes and constructors for new boxes |
| `style/commands.tex` | text helpers, references, lists, heading-space option |
| `style/diagrams.tex` | base TikZ styles and optional library loader |
| `style/course-map.tex` | shared course-map cards and scoped arrow/node styles for seven books |
| `style/figures.tex` | chapter figure/table frames and image helpers |
| `style/frontmatter.tex` | cover/contents assembly, toolkit numbering, stage dividers |
| `style/listings.tex` | code languages, terminal output, pseudocode |
| `style/defaults.tex` | house-style choices applied after definitions |
| `labs/layout.tex` | lab banners, questions, answers, coverage metadata |
| `labs/visuals.tex` | lab frames, scaling, flow/trace diagrams, compact figures |
| `labs/activities.tex` | notebook routine, output, roadmaps, checkpoints |
| `diagrams/` | network, process and data-object diagram libraries |
| `cover.tex`, `logos/` | shared cover design and branding assets |

For a change across courses, edit the owning module above. Do not add the
same override to each course. Internal modules are loaded by `utpnotes` in
dependency order; do not input them directly from a course.

## Standard course entry point

Every `main.tex` has the same five sections:

1. **Course metadata and wording:** title, lab count, outline, box titles.
2. **Shared presentation:** the single `utpnotes` input.
3. **Course options:** optional packages, diagram libraries, listing language,
   contents spacing, and opt-in behavior such as `\utpkeepheadings`.
4. **Course content helpers:** subject-specific figure definitions and, when
   needed, `labs/config.tex` for notebook wording.
5. **Document content:** front matter and chapters/labs in reading order.

No course entry point defines environments, colours, fonts, or reusable
formatting commands. [TEMPLATE-main.tex](TEMPLATE-main.tex) follows this same
structure. See [ADDING-A-COURSE.md](ADDING-A-COURSE.md) and
[STYLE-GUIDE.md](STYLE-GUIDE.md) for authoring conventions.

## Reusing a component

- Shared teaching boxes include `clarification`, `sourcealignment{title}`,
  `conceptmap`, `referencebox`, `projectrequirement`, `recommendedworkflow`
  and `applicationbox`. Set `\utptitleapplication` before loading `utpnotes`
  to label a product walkthrough, such as ERP's Odoo instructions.
- Use `\utpapp{name}` for application names, `\pathmenu{path}` for menu paths,
  and `\ptrnull` for a null-pointer label.
- `utpcompactlabfigure[title]` uses the standard lab frame with compact
  data-structure geometry. Put its drawing in `labgraphic`; this replaces
  ADS-specific figure environments without changing their appearance.
- `\labroutine` owns the Predict / Run / Compare / Explain structure. AI and
  ML override only `\utplabroutineintro` and `\utplabroutinecompare` in their
  local `labs/config.tex`; they do not duplicate its layout.
- `\input{chapters/00-toolkit}` loads the introductory chapter normally.
  `\utptoolkit` remains a compatibility alias with the same numbering behaviour.
  `\labcovers{ch:label,...}` records nonadjacent lab coverage in the auxiliary
  file using the existing metadata format.

All nine documents inherit the same body/code font selection. Font Awesome
in the Git guide supplies icons only. Contents spacing and teaching wording
may differ by course while the presentation remains shared.

## Faster compilation

Shared boxes use direct PGF vector fills, avoiding repeated TikZ geometry-node
construction. TikZ diagrams and syntax-highlighted listings remain editable
source. Builds need no generated cache, Memoize, Python, or shell escape.
See [PERFORMANCE.md](PERFORMANCE.md) for measurements, verification and
maintenance guidance.

## Building and verification

Compile from the course directory, using an existing separate output folder:

```powershell
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="C:/Temp/utp-check" main.tex
```

Repeat until contents and references settle (normally three passes). Install
required TeX packages first; the Git guide uses `fontawesome5`. The former
`.shared/build.py` is absent from this checkout; these commands do not publish
or replace `.all_pdfs/`.

After a shared change, compile all affected books, check logs for new errors,
undefined references and overflow, and compare rendered pages. For a pure
refactor, compare extracted page text and page breaks against the baseline.
Keep temporary build files out of the source directories. No diagram cache
needs to be generated or uploaded.

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
| `\utptitle...`           | the title of any box, e.g. `\utptitlepitfall`     | see `style/boxes.tex`            |

### Book settings, one line each after the `\input`

| Command                                         | Effect                                                        |
| ----------------------------------------------- | ------------------------------------------------------------- |
| `\utpcontentspage{size}{part size}{p}{c}{l}`    | how loosely the one-page contents is set                      |
| `\utpusediagrams{network,process,data-objects}` | load diagram libraries                                        |
| `\utpusealgorithms`                             | load algorithm2e, coloured to match                           |
| `\utpkeepheadings{section space}{subsection space}` | reserve room beneath headings (opt-in) |
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
| source material   | `sourcebasis`, `sourcealignment{title}` |
| reusable extensions | `clarification`, `referencebox`, `conceptmap`, `projectrequirement`, `recommendedworkflow`, `applicationbox` |
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
