# Build and preview performance

Tinymist previews update on typing without exporting a PDF on each save. Megamist also provides a live preview command; see the setup guide for its documented limitations.

Official CLI builds are single-pass. The scripts print elapsed time for each course. Diagram rendering uses bundled CeTZ; code and terminal blocks use bundled Codly. Font and package discovery does not require network access.

Preserved detailed diagrams contain many vector outlines, including their lettering. Cold compilation is slower than embedding the previous SVGs: ADS takes about 39 seconds on the development machine. Other machines and books will differ. Tinymist can reuse incremental compilation work, but shared design edits may invalidate much of that cache. Prefer editing one course at a time; use `build.py ADS --watch` for a persistent CLI compiler.

The `.cetz.json` files are generated once, not on each build. SVG siblings remain source geometry and support the optional lecture exporter. Regenerate geometry only after changing those sources, using `python .typst-setup/scripts/import_diagram_vectors.py`.

Run step 04 after shared changes. Step 06 removes disposable output from `.build`.
