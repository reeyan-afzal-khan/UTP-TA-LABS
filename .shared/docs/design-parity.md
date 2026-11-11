# Reference design and fidelity

The archived `.old` sources are the visual reference, not a build dependency. Active books compile with Typst alone. Current course content is newer than that archive, so identical page counts and page breaks are not expected.

The shared design uses A4 pages with 21 mm margins, Source Sans 3 at 10.91 PDF points, Source Code Pro listings at 7.01 points, and Inconsolatazi4 for DCN. Fonts and licenses are bundled. Chapter titles use 24.79 points; section and subsection titles use 14.35 and 11.96 points. Paragraph spacing, heading gaps, tinted callouts, listing frames, cover geometry, and running headers follow reference measurements. Typst and the reference typesetter still differ in line breaking and vertical layout; this is not a pixel-identical reproduction.

## Diagram editing

Reusable flows and the cover workflow are editable CeTZ nodes, text, and paths in `typst/diagrams.typ`. The 410 detailed course drawings preserve existing geometry through native CeTZ paths in `.cetz.json` files. Their labels are vector outlines: changing the document font does not change those labels, and the data is not a semantic node-based rewrite. This preserves the original letter shapes and connector positions.

For substantial diagram changes, replace that drawing with a small, readable course-local CeTZ source using real text and named nodes. For geometry regeneration, edit the source SVG and run `.typst-setup/scripts/import_diagram_vectors.py`. SVG siblings remain available to the optional lecture exporter. They are not embedded by normal book builds.

## Checking changes

Build all nine entry points after shared edits using step 04. PDFs belong in `.all-pdfs/<course-slug>/<CODE>-Book.pdf`. Inspect a cover, chapter opening, long listing, and detailed diagram before publishing with step 05. Temporary reference renders belong under `.build/design-reference` and are disposable.
