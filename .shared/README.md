# Shared course resources

Reusable presentation belongs here; course content and course-specific figures stay in each course folder. The Typst design is a one-to-one port of the LaTeX style files in `.shared/style` at commit `2903f28` (10 Nov 2026, the last LaTeX version): one module per style file. Read one with `git show 2903f28:.shared/style/theme.tex`.

```text
.shared/
  README.md
  typst/                 reusable book design
    utp.typ              the public import: everything below
    palette.typ          colours (theme.tex)
    theme.typ            sizes, baselineskips and line metrics
    state.typ            book settings (configuration.tex)
    layout.typ           pages, headings, contents, parts
    boxes.typ            the learning boxes (boxes.tex)
    figures.typ          figure and table frames, images (figures.tex)
    tables.typ           the tabularx house style
    listings.typ         code and terminal listings (listings.tex)
    listings.tmTheme     listing syntax colours
    labs.typ             lab banners, cards and checklists (labs/*.tex)
    commands.typ         inline commands (commands.tex)
    cover.typ            the cover (cover.tex)
    diagrams.typ         TikZ in CeTZ: node, connect, the house drawing styles
    plots.typ            pgfplots in CeTZ: axis, addplot, groupplot
  templates/
    course/              starter main.typ for a new course
  assets/
    fonts/               bundled typefaces and their licenses
    logos/               university and department artwork
  packages/              pinned third-party dependencies and licenses
  docs/                  authoring and maintenance guides
```

## Where to make changes

| Change | File or folder |
| --- | --- |
| Colours across every book | [typst/palette.typ](typst/palette.typ) |
| Font sizes, line spacing | [typst/theme.typ](typst/theme.typ) |
| Page layout, headings, contents | [typst/layout.typ](typst/layout.typ) |
| A learning box | [typst/boxes.typ](typst/boxes.typ) |
| Figure frames and captions | [typst/figures.typ](typst/figures.typ) |
| Tables | [typst/tables.typ](typst/tables.typ) |
| Code and terminal listings | [typst/listings.typ](typst/listings.typ) |
| Lab banners and lab components | [typst/labs.typ](typst/labs.typ) |
| Drawings: node and path styles | [typst/diagrams.typ](typst/diagrams.typ) |
| Charts | [typst/plots.typ](typst/plots.typ) |
| Cover geometry or the cover diagram | [typst/cover.typ](typst/cover.typ) |
| A single course's title, summary or settings | That course's `main.typ` |
| Starter files for a new course | [templates/course/](templates/course/) |
| Fonts and logos | `assets/` |

Content files import `/.shared/typst/utp.typ`. Drawings and charts are CeTZ code inside the chapter or lab that shows them; a course with drawing macros of its own keeps them in one Typst file beside its chapters. Keep third-party code in `packages/` separate from project-owned components; its versions and licenses are documented in [packages/NOTICE.md](packages/NOTICE.md).

## Guides

- [Style and reusable components](docs/style-guide.md)
- [Reference design and fidelity](docs/design-parity.md)
- [Adding a course](docs/adding-a-course.md)
- [Build and preview performance](docs/performance.md)
- [Installation, preview and numbered scripts](../.typst-setup/README.md)

After changing shared components, run step 04 to compile all books and review the affected pages. Step 06 clears temporary build output. Publish with step 05 only when needed.
