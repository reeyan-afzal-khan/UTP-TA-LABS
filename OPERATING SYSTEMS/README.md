# Operating Systems - Student Course and Laboratory Guide

This course is designed to be built with the shared UTP teaching-note framework supplied separately in `.shared/`.

## Required folder layout

Place the folders side by side:

```text
parent-folder/
|-- .shared/
|   |-- utpnotes.tex
|   |-- cover.tex
|   `-- ...
`-- OPERATING SYSTEMS/
    |-- main.tex
    |-- chapters/
    |-- labs/
    `-- all_experiments/
```

The course files **do not modify `.shared/`**. `main.tex` loads the shared framework with:

```tex
\input{../.shared/utpnotes}
```

## Course structure

The book follows a chapter-to-lab sequence:

- Chapter 1 -> Lab 1: processes and the Linux namespace
- Chapter 2 -> Lab 2: files, metadata, and CLI utilities
- Chapter 3 -> Lab 3: shell scripting and automation
- Chapter 4 -> Lab 4: CPU scheduling
- Chapter 5 -> Lab 5: IPC and synchronization
- Chapter 6 -> Lab 6: threads, mutexes, and deadlock safety
- Chapter 7 -> Lab 7: contiguous memory allocation
- Chapter 8 -> Lab 8: virtual memory and page replacement
- Chapter 9 -> Lab 9: paths, inodes, and links
- Chapter 10 -> Lab 10: file records and indexed allocation

The orientation material before Chapter 1 introduces Linux/WSL, the CLI, Vim, GCC, Git, and SSH.

## Experiments

`all_experiments/` contains the exact C and Bash source files printed in the lab pages. Students should edit those files with Vim and compile/run them from the command line.

## Recommended environment

- Linux, or Ubuntu under WSL 2 on Windows
- GCC / `build-essential`
- Vim
- Bash and standard Linux utilities
- Git and OpenSSH

macOS is suitable for the general CLI, Vim, Git, and many C exercises. Linux/WSL remains the reference environment for Linux-specific process and IPC behaviour.

## Build the PDF

From inside `OPERATING SYSTEMS/`:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

If `latexmk` is unavailable, run `pdflatex main.tex` three times so the contents and references settle.
