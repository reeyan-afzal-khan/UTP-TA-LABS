# Typst: install, preview, build, publish

Open this repository root in VS Code. Install Anaconda and VS Code on a new machine. Step 01 creates a Conda environment with Python 3.12 and pip at `UTP-TA-LABS/.typst-setup/.venv-typst`, using the actual repository location. No separate Python installation is needed.

## Numbered steps

Run the Windows `.bat` files from `windows/`, or the matching `.sh` files from `unix/`. All scripts locate the repository themselves; folder names containing spaces work.

| Step | Windows | macOS / Linux | Purpose |
| --- | --- | --- | --- |
| 01 | `windows/step01-install.bat --editors --publishing` | `sh unix/step01-install.sh --editors --publishing` | Create the local Conda environment and install the compiler, editor extensions, and optional PDF splitter |
| 02 | `windows/step02-check.bat` | `sh unix/step02-check.sh` | Check the pinned compiler and course entry points; on Windows, also check that the editor preview can start |
| 03 | `windows/step03-build.bat DS` | `sh unix/step03-build.sh DS` | Build one course; add `--watch` for disk-change watching |
| 04 | `windows/step04-build-all.bat` | `sh unix/step04-build-all.sh` | Compile all nine books |
| 05 | `windows/step05-publish.bat DS` | `sh unix/step05-publish.sh DS` | Publish a course and its lab PDFs; use `--all` for every course |
| 06 | `windows/step06-clean.bat` | `sh unix/step06-clean.sh` | Clear `.build`; keep sources, compiler, and published PDFs |

Paths in the table are relative to `.typst-setup`. From the repository root, prefix them with `.typst-setup/`. Course selectors may be `GIT`, `ADS`, `AI`, `DCN`, `DS`, `ERP`, `FI`, `ML`, `OS`, a full course name, or its `main.typ` path. For example:

```bat
.typst-setup\windows\step03-build.bat "MACHINE LEARNING" --watch
```

The scripts discover Conda through `CONDA_EXE`, PATH, or common Anaconda/Miniconda installation locations. For a custom installation, run from Anaconda Prompt (Windows), initialize Conda in your terminal (macOS/Linux), or set `CONDA_EXE` to its executable path. Every step runs through `conda run --prefix` with the repository-local environment, so manual activation is unnecessary. The optional `--editors` flag needs the VS Code `code` command on PATH. Without the flag, use VS Code's workspace extension recommendations instead.

Step 01 reuses an existing Conda environment. It stops if `.typst-setup/.venv-typst` already contains a regular Python virtual environment or an incomplete installation; rename that folder and rerun step 01. Steps 02–06 require step 01 to have completed. On a different machine, recreate the environment with step 01 rather than copying it. An internet connection is required for initial package and compiler downloads.

If you previously installed the environment at the repository root, rerun step 01 to create it at the new location. After checking the new setup, you can remove the old root-level `.venv-typst` environment. Do not simply move the environment folder, because installed tools can retain absolute paths.

To activate it manually from the repository root:

```sh
conda activate ./.typst-setup/.venv-typst
```

The VS Code Typst tasks use these same numbered scripts, including environment creation during installation.

## Live preview

The workspace uses one Typst extension, **Tinymist Typst**. Open the course's `main.typ`, pin it as the main file, and start its editor-tab preview. Pinning keeps the complete book selected while you edit included chapters or labs.

**The preview refreshes when you save (Ctrl+S, Cmd+S on macOS), not on every keystroke.** A book here runs to 500 pages: each refresh of the Machine Learning preview keeps the preview busy for one to seven seconds, so refreshing on every keystroke kept it permanently busy and slow to respond. Errors and warnings in the editor still update as you type. For a short document you can switch to live refresh in your own settings with `"tinymist.preview.refresh": "onType"`.

**If the whole VS Code window flashes blank** (it shows only its background colour for a fraction of a second, over and over, usually once a large preview is open), the cause is VS Code's GPU rendering, not Typst. It is common on computers whose monitors are connected to two different graphics cards. Run **Preferences: Configure Runtime Arguments** from the Command Palette, set `"disable-hardware-acceleration": true`, and quit and reopen VS Code. To keep hardware acceleration instead, use Windows **Settings → System → Display → Graphics** to run VS Code on the graphics card that drives the monitor it is on.

**If the preview does not start on Windows and the Tinymist Typst output panel is empty**, Windows Smart App Control is blocking Tinymist's language server, `tinymist.exe`, because the file is not digitally signed. Smart App Control can turn itself on after an evaluation period, so a preview that worked last week can stop with no change to VS Code or this repository. Step 02 tests this: it starts `tinymist.exe`, reports the Smart App Control state, and says what to do if Windows blocks it. Each block is also recorded in Event Viewer under **Applications and Services Logs → Microsoft → Windows → CodeIntegrity → Operational**. Smart App Control cannot make an exception for one program: turn it off in **Windows Security → App & browser control → Smart App Control settings**, then run **Developer: Reload Window**. If you keep it on, use step 03 with `--watch` and open the PDF it writes under `.all-pdfs/`.

Do not run **Megamist Typst** next to Tinymist. It compiles the open file 100 ms after every keystroke, cannot read the files a book imports (so every compile fails), and flashes its status and error marks each time. Earlier versions of this guide recommended it; disable it for this workspace (Extensions view → Megamist Typst → Disable (Workspace)) or uninstall it.

Tinymist is configured with the repository root, bundled fonts, original preview colours, partial rendering (only the pages on screen are drawn), no compile-status indicator, and no automatic PDF exports. The editor preview is independent of the numbered PDF build scripts. See the [Tinymist preview guide](https://myriad-dreamin.github.io/tinymist/feature/preview.html).

## Portable toolchain

`config/toolchain.json` pins **Typst 0.15.1** from [the official typst/typst repository](https://github.com/typst/typst/releases/tag/v0.15.1). Installation verifies GitHub's SHA-256 release asset digest. Windows, macOS and Linux are supported where an official x86-64 or ARM64 release exists. Installation is local: no administrator rights or persistent PATH changes.

The compiler lives in ignored `.typst-setup/bin/`. Python and optional publishing packages live in ignored `.typst-setup/.venv-typst/` inside the setup folder, created using `conda create --prefix` rather than a named environment in Anaconda’s `envs` directory. Fonts, logos and the pinned CeTZ drawing package are committed under `.shared/`, so normal CLI builds work offline after setup. PDF publication requires the optional splitter installed with `--publishing`; ordinary book builds do not.

```text
.typst-setup/
  README.md     this guide
  windows/      numbered .bat entry points
  unix/         matching .sh entry points
  scripts/      shared cross-platform Python implementations
  config/       compiler pin, course registry, lab coverage, dependencies
  bin/          ignored local compiler installation; created by step 01
  .venv-typst/   ignored local Conda environment; created by step 01
```

`Ctrl+Shift+B` selects and builds a course. Other VS Code tasks expose setup checks, installation, watching, and all-course builds. Builds and watch mode write `.all-pdfs/<course>/<CODE>-Book.pdf`, for example `.all-pdfs/data-science/DS-Book.pdf`. Step 05 adds chapter/lab PDFs and page-range manifests in that same course folder. No PDFs are written beside course sources.

If imports are outside the project root, reopen the repository root. If references are missing in a chapter preview, pin the course's `main.typ`. If the CLI version differs from the pin, rerun step 01. For font warnings, restore `.shared/assets/fonts/`; system fonts are intentionally excluded from CLI builds.
