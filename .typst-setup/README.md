# Typst: install, preview, build, publish

Open this repository root in VS Code. Install Anaconda and VS Code on a new machine. Step 01 creates a Conda environment with Python 3.12 and pip at `UTP-TA-LABS/.typst-setup/.venv-typst`, using the actual repository location. No separate Python installation is needed.

## Numbered steps

Run the Windows `.bat` files from `windows/`, or the matching `.sh` files from `unix/`. All scripts locate the repository themselves; folder names containing spaces work.

| Step | Windows | macOS / Linux | Purpose |
| --- | --- | --- | --- |
| 01 | `windows/step01-install.bat --editors --publishing` | `sh unix/step01-install.sh --editors --publishing` | Create the local Conda environment and install the compiler, editor extensions, and optional PDF splitter |
| 02 | `windows/step02-check.bat` | `sh unix/step02-check.sh` | Check the pinned compiler and course entry points |
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

The workspace recommends **Tinymist Typst** and **Megamist Typst**.

- **Megamist:** open a course's `main.typ`, press **Ctrl+Shift+P** (Cmd+Shift+P on macOS), and choose **Typst: Open Preview**. Automatic refresh is enabled with a 100 ms debounce. This is the Command Palette, not the terminal.
- **Tinymist:** open the course's `main.typ`, pin it as the main file, and start its editor-tab preview. Pinning keeps the complete book selected while you edit included chapters or labs. Preview refreshes on typing, including unsaved edits.

[Megamist's published limitations](https://marketplace.visualstudio.com/items?itemName=robertmorelli.megamist-typst) currently include first-page-only preview and no PDF export. Its browser compiler has embedded fonts; it does not inherit Tinymist's font/root settings. Use Tinymist for checking every book page and the pinned official CLI for publication. This repository does not assume that both extensions use the same embedded compiler version. If diagnostics are duplicated, disable one extension for the workspace.

Tinymist is configured with the repository root, bundled fonts, original preview colours, and no automatic PDF exports. The editor preview is independent of the numbered PDF build scripts. See the [Tinymist preview guide](https://myriad-dreamin.github.io/tinymist/feature/preview.html).

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
