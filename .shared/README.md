# Shared course resources

Reusable presentation belongs here; course content and course-specific figures stay in each course folder.

```text
.shared/
  README.md
  typst/                 reusable book design
    utp.typ              public import: layout, headings, callouts, labs and flows
    cover.typ            shared cover layout
    palette.typ          shared colour definitions
    diagrams.typ         editable CeTZ flows and cover workflow
    vector-diagrams.typ  CeTZ renderer for preserved geometry
    code.typ             Codly code and terminal listings
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
| Book layout, headings and lab banners | [typst/utp.typ](typst/utp.typ) |
| Cover geometry, author block or cover diagram | [typst/cover.typ](typst/cover.typ) |
| Code and terminal listings | [typst/code.typ](typst/code.typ) |
| CeTZ flows and cover workflow | [typst/diagrams.typ](typst/diagrams.typ) |
| Colours across every book | [typst/palette.typ](typst/palette.typ) |
| A single course's cover title or summary | That course's `main.typ` |
| Starter files for a new course | [templates/course/](templates/course/) |
| Fonts and logos | `assets/` |

Content files import `/.shared/typst/utp.typ`. Each course calls `cover(...)` directly in `main.typ`; the layout is shared in `typst/cover.typ`. Keep third-party code in `packages/` separate from project-owned components; its versions and licenses are documented in [packages/NOTICE.md](packages/NOTICE.md).

## Guides

- [Style and reusable components](docs/style-guide.md)
- [Reference design and fidelity](docs/design-parity.md)
- [Adding a course](docs/adding-a-course.md)
- [Build and preview performance](docs/performance.md)
- [Installation, preview and numbered scripts](../.typst-setup/README.md)

After changing shared components, run step 04 to compile all books and review the affected pages. Step 06 clears temporary build output. Publish with step 05 only when needed.
