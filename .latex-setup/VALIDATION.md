# Local validation: 10 November 2026

Tested on this Windows workspace with MiKTeX 25.12, pdfTeX 1.40.28,
latexmk 4.88 and LaTeX Workshop 10.20.0. These are observations on this
computer, not required version pins or guaranteed timings on another machine.

All nine full builds passed after moving repeated course-map styling into
`.shared/style/course-map.tex`. Existing auxiliary files were retained; each
book required one typesetting pass for this shared source change.

| Course | Pages | Build seconds |
| --- | ---: | ---: |
| Git submission guide | 7 | 3.45 |
| Algorithms & Data Structures | 196 | 16.39 |
| Artificial Intelligence | 147 | 18.95 |
| Data Communication & Networking | 103 | 10.24 |
| Data Science | 113 | 10.18 |
| Enterprise Resource Planning | 97 | 10.93 |
| FinTech Innovation | 107 | 8.74 |
| Machine Learning | 298 | 24.41 |
| Operating Systems | 96 | 8.62 |

An earlier forced ML rebuild through the old verbose command took 32.77 seconds.
Both were single-pass builds, but they were not repeated controlled benchmarks:
OS caches, background load and output handling can affect the difference. Do not
interpret it as a guaranteed percentage improvement. An unchanged ML check with
the new launcher took 0.52 seconds; that is a dependency check, not a fresh build.
The explicit one-pass preview built the Git guide in 2.19 seconds.

## Layout and configuration checks

- 1,164 pages across nine books retain identical decoded PDF page drawing streams
  and page geometry compared with the pre-refactor PDFs.
- All seven refactored course-map pages render pixel-identically at 110 dpi.
  A rendered map was also visually inspected.
- The setup checker finds the toolchain, extension, key fonts/packages and all
  nine course entries.
- The build launcher rejects a non-course TeX target and rejects concurrent
  script builds of the same book.
- PowerShell scripts parse successfully; repository whitespace checks pass.

Re-run builds after further edits. Output and comparison artifacts are under
`.build`, ignored by Git. No timings here measure Prism or an unsaved-keystroke
preview. The default remains a complete, reference-checked book build.
