# Build and preview performance

Tinymist's preview refreshes on save, without exporting a PDF. Compiling is not the slow part: after one edit the Machine Learning book (about 490 pages) recompiles in 0.4–1 s. Redrawing it is: each preview refresh of that book kept the preview busy for one to seven seconds, so refreshing on every keystroke left it busy all the time. Keep partial rendering on (only the pages on screen are drawn) and use Tinymist alone; Megamist recompiles on every keystroke and cannot resolve the books' imports. A VS Code window that flashes blank is a separate, GPU problem; the setup guide's live-preview section gives the fix.

Official CLI builds are single-pass. The scripts print elapsed time for each course. Drawings and charts are CeTZ code compiled with the book (bundled CeTZ, no images to load); fonts and packages are bundled, so nothing needs the network.

On the development machine a full build takes about 13 seconds for ADS, 23 for AI (the most drawings) and 10 for ML. Other machines and books will differ. Tinymist reuses incremental work between edits, but a change to a shared file can invalidate much of it; prefer editing one course at a time, and use `build.py ADS --watch` for a persistent CLI compiler.

Run step 04 after shared changes. Step 06 removes disposable output from `.build`.
