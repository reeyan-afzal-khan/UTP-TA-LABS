# Build and preview performance

Tinymist previews update on typing without exporting a PDF on each save. Megamist also provides a live preview command; see the setup guide for its documented limitations.

Official CLI builds are single-pass. The scripts print elapsed time for each course. Drawings and charts are CeTZ code compiled with the book (bundled CeTZ, no images to load); fonts and packages are bundled, so nothing needs the network.

On the development machine a full build takes about 13 seconds for ADS, 23 for AI (the most drawings) and 10 for ML. Other machines and books will differ. Tinymist reuses incremental work between edits, but a change to a shared file can invalidate much of it; prefer editing one course at a time, and use `build.py ADS --watch` for a persistent CLI compiler.

Run step 04 after shared changes. Step 06 removes disposable output from `.build`.
