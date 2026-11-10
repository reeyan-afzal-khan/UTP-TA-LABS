# Course and lab layout

Load `../.shared/utpnotes` once from each course's `main.tex`. It owns fonts,
colours, margins, headings, cover, callouts, listings and lab presentation.
Follow the five-section entry-point template. Configure metadata before the
input and select shared options afterwards. Course-specific wording belongs
in `labs/config.tex`; reusable formatting belongs in the owning `.shared/style/`
or `.shared/labs/` module. Do not copy shared environment definitions.

## Lab sheets

All 72 existing lab sheets use `\labsection` and `labproject`. Preserve the
subject-specific tasks and their order while using this common presentation:

1. `\labsection{number}{title}{label}` opens a new page with the shared banner.
2. State the goal, prerequisites or chapter connection, and required inputs.
   Use `\labflow{connection}{goal}{explanation}` when those three fields fit.
3. Group the main activity in `labproject`; use the shared code-listing style
   for its language. Notebook labs can use `labquestion` and `labanswer`.
4. Put diagrams in `labs/visuals/`. Use `labvisual` around `labgraphic`, or
   `\courselabflow` / `\courselabtrace` for standard sequences. The frame is
   94% of the text width; graphics shrink only, to the available width and
   at most 6 cm high. Split dense diagrams rather than shrinking text further.
5. Use `verification` and, when applicable, `labdeliverable` for closing
   evidence and submission requirements. Their position inside or after the
   activity may follow the teaching sequence; their styling is shared.

Notebook activity helpers (`refoutput`, `yourturn`, `expectedfindings`,
`labroadmap`, `labpartopen`, `labcheckpoint`, `labsubhead`, `labchecklists`)
are available to every course. Notebook-specific wording stays local through `\utplabroutineintro` and
`\utplabroutinecompare`; the routine itself is shared.
Use `\labcovers{ch:label,...}` when a lab covers nonadjacent chapters.

## Chapters, tables, and assets

Start chapters with `\chapterguide` and close with `chapterrecap` where
appropriate. Use `utptable` with `tabularx`, booktabs rules and `\utpth` header
cells; use `utpfigure` or `utpfig` for chapter figures. Use the `UTP*` palette
and `utp*` listing styles rather than defining course-specific equivalents.
Keep subject-specific diagrams and images in their course. Promote an asset
or helper to `.shared/` when it is reusable; reference it rather than copy it.

After a shared change, compile each course, check references and overflow,
and inspect representative lab pages. Keep outputs outside source folders.

Shared flat boxes use the `utpplain` rendering style from `style/rendering.tex`.
Keep `enhanced` for decorations such as the cover accent, overlays or shadows.
See [PERFORMANCE.md](PERFORMANCE.md) for the original-renderer switch and
full-document visual verification.

Course overrides loaded after `utpnotes` must use `\renewcommand` for existing
wording hooks, including `\utplabroutinecompare`. The box constructors
`\utpnewcallout` and `\utpnewquietbox` declare or update a named environment,
so a course can intentionally restyle a shared default. Omit redundant
declarations when the shared style already matches. Lab visuals and activities
are loaded centrally; do not input the removed `labs/visual-guide.tex`.
