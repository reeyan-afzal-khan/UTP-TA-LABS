# Add a course

1. Create a top-level course folder with `chapters/`, `labs/`, and a README.
2. Copy `.shared/templates/course/main.typ` to its `main.typ`; set the title, summary and lab count.
3. Create the chapter and lab files, importing `/.shared/typst/utp.typ`. Add `#unit("chapters", "file-stem")` or `#unit("labs", "file-stem")` before the opening heading/banner.
4. Add the includes to `main.typ` in teaching order. Keep code and data in the course's own folders.
5. Register the course code and publication slug in `.typst-setup/config/courses.json`, and add it to the VS Code task selector.
6. If a lab covers non-adjacent chapters, list their labels in `.typst-setup/config/lab-coverage.json` using `COURSE/lab-file-stem` as the key.
7. Build with step 03, review the preview and PDF, then publish with step 05. Add links to the root README.

The repository root must be the compilation root. All courses share the same `cover.typ`, palette, fonts and reusable components.

Set the cover title and summary in the `#cover(...)` call in each course's `main.typ`. The shared layout is exported by `/.shared/typst/utp.typ`.
