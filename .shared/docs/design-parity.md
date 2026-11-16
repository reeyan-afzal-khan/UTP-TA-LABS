# Reference design and fidelity

The LaTeX books at commit `2903f28` (10 Nov 2026, the last LaTeX version) are the reference: the Typst books are a one-to-one port of them, chapter for chapter, and every measurement below was taken from their PDFs. The LaTeX lives only in git history (`git show 2903f28:<path>`); nothing in the build depends on it.

## Page and text

A4 pages with 21 mm margins; Source Sans 3 at 10.91pt with a 13.55pt baselineskip and 6pt between paragraphs; Source Code Pro listings at 7.01pt (Inconsolatazi4 for DCN). A line's box runs from the ascenders (0.712em) to a typical descender (0.2em), so Typst's leading gives LaTeX's fixed baselineskip (`typst/theme.typ`). Headings, boxes, tables, listings, figure frames and captions follow the LaTeX spacing to within a fraction of a point, including:

- a box after text 10.84pt below its baseline, the next baseline 16.26pt below a box, and two boxes back to back 6.8pt apart (12pt next to a numbered figure);
- figure frames, whose caption sits 12.65pt above the frame's bottom;
- tables that never break across pages, since a LaTeX tabular is one box.

## Drawings and charts

Every TikZ picture and pgfplots chart is CeTZ code in the chapter or lab that shows it; no drawing is stored as an image. The vocabulary (`typst/diagrams.typ`, `typst/plots.typ`) reproduces TikZ's node sizes from the glyphs, its anchors, arrow tips and line widths, and pgfplots' axis sizing, tick choice and label positions. Of the 394 numbered figures, 362 have frames within 3pt of LaTeX's height and the rest within about 13pt.

## Known differences

- Page breaks: line breaking differs slightly between the typesetters, so a book can run one to four pages longer or shorter than its LaTeX version.
- TeX measures the depth of the last line before a numbered figure; a figure after a line without descenders sits about 2pt lower in Typst.
- In node text that mixes font sizes, TeX takes each line's spacing from the size in force where the line ends; Typst uses one spacing per paragraph, so such lines can differ by a point or two.
- Maths in a node label is centred on Typst's formula box, which can sit a point or two lower than TeX's.
- A box that breaks across a page is closed with a border on both parts; LaTeX left the edges at the break open.
- `Lab~\ref{...}` printed the chapter number in LaTeX; Typst prints the lab's own number.
- By design, the LaTeX books' many learning boxes are gone. Asides are the three callouts Note, Tip and Warning; examples, exercises, review questions, summaries, lab questions and checklists are ordinary text under a bold label (see [style-guide.md](style-guide.md)). The frame measurements above still hold for figures, tables and device transcripts.

## Checking changes

Build all nine books after a shared edit and compare representative pages: a chapter opening, a figure, a chart, a long listing and a lab. Temporary renders belong under `.build/` and are disposable.
