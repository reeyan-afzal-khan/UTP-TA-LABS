# Local LaTeX workspace

This repository is designed to open as **one VS Code folder**, with a separate
`main.tex` for each course and one shared presentation layer. These Windows scripts
work with Windows PowerShell 5.1 or PowerShell 7 and the existing MiKTeX installation.
They discover the repository from their own location; no username is hard-coded.

## 1. Install the tools on a new Windows computer

1. Install [Visual Studio Code](https://code.visualstudio.com/Download).
2. Install [MiKTeX](https://miktex.org/howto/install-miktex), preferably for your
   user account. Open MiKTeX Console, check for updates and apply them. Select
   your preferred missing-package installation policy; the first book build may
   need downloads. Complete that first build before relying on offline editing.
3. Install [Git for Windows](https://gitforwindows.org/). The build scripts can use
   its bundled Perl, which `latexmk` needs. A separate Perl on PATH also works.
4. Install **LaTeX Workshop**, publisher **James Yu**, in VS Code Extensions,
   or run `code --install-extension James-Yu.latex-workshop` in a terminal.
5. Restart VS Code after installing tools. Open the **UTP-TA-LABS root folder**,
   not just a course folder. Review VS Code's workspace-trust prompt yourself:
   build scripts and the extension need a trusted workspace.

No Python, Node, Docker, WSL, shell escape or online editor is required to compile
the books. Python and Poppler are optional tools for layout regression checking.
Scripts only extend PATH for their own process, not your system settings.

Run these commands in a PowerShell terminal from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Check.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Build.ps1 -MainFile '0.GIT-REPO-SUBMISSION/main.tex'
```

`Check.ps1` reports tool paths, tests the Perl-backed `latexmk` launcher, checks
key fonts/packages, and checks the VS Code course list. A successful full build
is the final check for all transitive LaTeX dependencies. An exit code of 1 means
something needs attention; read the printed messages. `-ExecutionPolicy Bypass`
applies only to that invocation and does not change the machine's execution policy.

## 2. Daily editing

1. Open the desired course's `main.tex` to select its build root.
2. Run **LaTeX Workshop: Build LaTeX project**, or press **Ctrl+Alt+B**.
3. Run **LaTeX Workshop: View LaTeX PDF file**, or press **Ctrl+Alt+V**.
4. Edit a chapter or lab, then press **Ctrl+S**. After successful compilation,
   the PDF refreshes and follows the source cursor.

**Double-click PDF text** to jump to its source. **Ctrl+Alt+J** jumps from the
source cursor to the PDF. Close and reopen the PDF tab if it was already open
when its navigation settings changed. SyncTeX maps text to source lines;
macro-generated material may point to a definition or calling line.

The workspace retains `onFileChange`, with LaTeX auto-save off:

| Setting | What it actually does |
| --- | --- |
| `onFileChange` | Builds when a known dependency changes on disk, including Ctrl+S or an external edit |
| `onSave` | Builds when a TeX file is saved inside VS Code |
| `never` | Builds only when you explicitly request it |
| LaTeX `files.autoSave: off` | Unsaved typing does not start a build |

Neither auto-build option makes PDF typesetting instantaneous. The 1500 ms
auto-build interval limits how frequently automatic builds can start; it is not
the full compilation duration. The open preview shows the last successful build
until the next one is ready. If a save happens during a build, allow the queued
build to finish; if the result still looks stale, save again or run Build.

When switching books, open the new `main.tex` first. While editing `.shared`,
check which book is active: only that book's preview is rebuilt. Use
**Ctrl+Shift+B** to explicitly choose a course. This task does not change the
LaTeX Workshop root selection. Use **Tasks: Run Task** for the setup check or
all-course build.

## 3. Build commands

```powershell
# Accurate book: repeat passes only when references/contents need them.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Build.ps1 -MainFile 'MACHINE LEARNING/main.tex'

# Force typesetting for a benchmark or suspected stale output; preserve aux files.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Build.ps1 -MainFile 'MACHINE LEARNING/main.tex' -Rebuild

# Optional one-pass preview, with the limitations described below.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Build.ps1 -MainFile 'MACHINE LEARNING/main.tex' -Mode Preview

# Check every discovered course after a shared style change.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .latex-setup/Build-All.ps1
```

Quote paths containing spaces or `&`. Relative main-file arguments are resolved
against the repository root even if you invoke the script from another directory.
Only top-level course `main.tex` files are accepted. All-course builds run
sequentially to avoid competing for CPU and memory. Failures are reported at the end.

The same modes are available through **LaTeX Workshop: Build with recipe**:

- **UTP: full build (references checked)** is the default, including auto-builds.
- **UTP: one-pass preview (references may be stale)** is an explicit editing tool.
  It keeps fonts, diagrams, tables and listings at full quality, but does not
  repeat a pass to settle contents, references or page numbers. Its first run
  initializes missing auxiliary files using a full build. Run the full recipe
  before sharing/exporting. Choosing this recipe once does not change the
  default automatic recipe.

A one-pass preview still typesets the entire active course. It helps only when
the full build would otherwise need extra passes; it cannot make a long single
pass instantaneous. Chapter-only previews are not enabled: their pagination and
cross-references would differ from the complete book.

## 4. Output and performance

See [the validation report](VALIDATION.md) for measured timings and layout checks.

Each course writes to `.build/<COURSE>/main.pdf`, alongside its `.synctex.gz`,
`.aux`, `.toc`, `.fls`, `.fdb_latexmk` and `.log` files. These outputs are ignored
by Git. Preserve the auxiliary files between edits: deleting them makes the next
build repeat more work. Published `.all_pdfs` files are separate.

The launcher uses quiet compiler output, retains dependency state, reports elapsed
time and prevents simultaneous script builds of the same course. A failed build
prints the end of the compiler log. `build.lock` can remain on disk after a build;
the open file handle, not the file's existence, determines whether a build is active.

Most time in a large book is spent typesetting pages, drawing TikZ and laying out
listings/boxes. Shared PGF box rendering already avoids redundant TikZ work.
This setup neither drops figures nor lowers image quality. There is no diagram
cache or automatic clean-and-retry loop. Watch/search exclusions keep datasets
and generated output out of routine editor scans; LaTeX Workshop tracks its own
build dependencies.

Keep the workspace on a local SSD when possible. Build one course while editing,
and reserve Build-All for shared changes. Compare timings on the same saved
sources and distinguish a cold build, forced rebuild and unchanged incremental
check. We do not have a comparable measured Prism server build, so differences in
its hardware or compilation pipeline should not be assumed.

## 5. Troubleshooting

| Symptom | Action |
| --- | --- |
| `perl` or script engine missing | Run Check.ps1. Install Git for Windows or Perl, then reopen VS Code. |
| Missing `.sty` or font/map | Install/update the named package in MiKTeX Console, then rerun the full build. |
| Build works in terminal but not editor | Open the repository root, select the course main.tex, check workspace trust and the Output panel. |
| Preview stays old | Check **Output → LaTeX Compiler** and `.build/<COURSE>/main.log` for the first error. |
| References show `??` | Use the full recipe; also check that the referenced label exists. |
| Double-click does not navigate | Open the `.build` PDF through LaTeX Workshop, not an old published PDF, and ensure `.synctex.gz` exists. |
| Another build is running | Wait for it to finish. Do not launch the course picker and auto-build for the same course simultaneously. |
| No build on typing | Expected: press Ctrl+S. Auto-save is deliberately disabled for LaTeX. |
| Ctrl+Alt+B opens another panel | Use the named command from the Command Palette; another extension may own the shortcut. |

For source errors, correct the first error before rebuilding. Do not remove
course input files simply because a helper macro is undefined: check that the
shared loader and current modules are available. No cleanup command deletes files
automatically in this toolkit.

## 6. Maintenance and ownership

| Location | Responsibility |
| --- | --- |
| `.latex-setup/` | Local build implementation, environment diagnostics and this guide |
| `.vscode/` | Editor recipes, recommended extension and task menu |
| `.shared/` | Reusable LaTeX presentation, fonts, boxes, diagrams and lab components |
| `<COURSE>/main.tex` | Metadata, course options, helpers and reading order |
| `<COURSE>/chapters`, `labs` | Course-specific content |
| `.build/` | Disposable local outputs; never commit |

All nine books use the same launcher and the shared `utpnotes.tex` entry point.
See [the shared module map](../.shared/README.md) and
[adding a course](../.shared/ADDING-A-COURSE.md). New top-level `main.tex` files
are discovered by Build-All automatically; update the VS Code course picker too.
Check.ps1 detects a mismatch. `.vscode/build-latex.ps1` is only a compatibility
wrapper for older commands; edit Build.ps1 when changing compilation behavior.

This automated setup targets Windows. On Linux/macOS use an installed TeX
distribution and `latexmk` from each course directory; the PowerShell recipes
and executable discovery supplied here are not a tested Unix setup.

Official references: [MiKTeX installation](https://miktex.org/howto/install-miktex),
[VS Code extension installation](https://code.visualstudio.com/docs/configure/command-line),
[LaTeX Workshop compilation](https://github.com/James-Yu/LaTeX-Workshop/wiki/Compile),
[PDF navigation](https://github.com/James-Yu/LaTeX-Workshop/wiki/View).
