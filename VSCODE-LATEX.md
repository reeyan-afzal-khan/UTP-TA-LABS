# Editing the books in VS Code

Open **UTP-TA-LABS itself** with File → Open Folder. The root `.vscode` folder
configures all nine books, including the Git submission guide. LaTeX Workshop,
MiKTeX and Git are already installed on this computer.

If VS Code shows Restricted Mode, review and trust this repository yourself to
enable its build tasks and LaTeX extension.

## Edit and preview

1. Open the course's `main.tex` to select the book you want to work on.
2. Press **Ctrl+Alt+B** to build it.
3. Press **Ctrl+Alt+V** to open the PDF beside the source.
4. Edit a chapter, lab or shared style and press **Ctrl+S**. LaTeX Workshop builds
   the active book automatically; the open PDF refreshes when compilation succeeds.
   Automatic saving is disabled for LaTeX files, so typing alone does not start a build.

### Jump between the PDF and source

- **Double-click text in the PDF** to open the corresponding source file and line.
  A plain click still selects text or follows links. If the already-open viewer
  still uses its old setting, close only the PDF tab and reopen with Ctrl+Alt+V.
- **Ctrl+Alt+J in the source editor** moves the PDF to the cursor's location.
- After a successful build, the preview follows the source cursor automatically.

These are SyncTeX mappings: they identify source locations, not a separately
editable PDF. Generated headings, diagrams and shared macros may point to their
definition or calling line rather than an individual displayed word.

### What “live” means here

Pressing Ctrl+S starts the build and refresh cycle; PDF typesetting is not
instantaneous. A saved source change still typesets the active book, and a long
course takes time. If saved LaTeX contains an error, the last successful PDF remains
available until the error is fixed and the next build succeeds.

This setup does not provide page-only incremental typesetting. Compiling only a
chapter would give a separate preview whose page numbers, references and contents
can differ from the full book. It is not enabled automatically. No changes to the
book's styling or content are needed for the automatic preview above.

If a shortcut conflicts with another extension, use the Command Palette commands
**LaTeX Workshop: Build LaTeX project** and **LaTeX Workshop: View LaTeX PDF file**.

When switching courses, open the new course's `main.tex` first. Shared files belong
to several books, so use **Ctrl+Shift+B → choose a course** to explicitly build a
particular book from anywhere in the repository. This task does not change which
root LaTeX Workshop has selected; open that book's `main.tex` before viewing it.

Generated PDFs and auxiliary files live in `.build/<COURSE>/`. They are ignored by
Git. Published files in `.all_pdfs` are separate and are not overwritten.

## How the local build works

`.vscode/build-latex.ps1` runs `latexmk` from the selected course directory, so
relative inputs into `.shared` resolve correctly. It makes MiKTeX and Git's bundled
Perl available to the build process without changing the system PATH. This fixes
the missing-Perl error from MiKTeX's `latexmk` launcher.

The first build can need several passes for contents, references and bookmarks.
Later builds retain their auxiliary files; unchanged books are skipped. Saved
source changes still require LaTeX to typeset the book. Fonts, diagrams and code
listings use the full-quality source rendering, with SyncTeX enabled and shell
escape disabled.

To run the same build in a PowerShell terminal from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .vscode/build-latex.ps1 -MainFile 'MACHINE LEARNING/main.tex'
```

For a compilation failure, open **Output → LaTeX Compiler**, or inspect
`.build/<COURSE>/main.log`. The course-picker task displays its output in the
terminal. Correct the first LaTeX error before retrying; there is no automatic
clean-and-retry loop.

## Configuration files

- `.vscode/settings.json`: build recipe, automatic builds and PDF viewer.
- `.vscode/tasks.json`: explicit course picker for Ctrl+Shift+B.
- `.vscode/build-latex.ps1`: local tool discovery and course-relative compilation.
- `.vscode/extensions.json`: recommended LaTeX Workshop extension.

On another Windows computer, install VS Code, LaTeX Workshop, MiKTeX and Git
(or a separate Perl installation on PATH). The build helper checks the usual
per-user and system installation paths. It does not install missing software.
