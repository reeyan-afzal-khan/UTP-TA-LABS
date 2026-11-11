#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-getting-started-linux-wsl")


#heading(level: 1, numbering: none)[Your Linux Toolkit and Environment Setup]


#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* No Linux experience is required. You need a computer where you can use Linux, WSL, or a Linux virtual machine.

*By the end, you can:* identify the course folder, open a Linux shell, edit source in Vim, compile with GCC, run a program, and prepare Git/SSH for saving course work.]

The practicals use a #strong[command-line workflow]. Linux is the reference environment because the processes, files, permissions, IPC objects, and other OS concepts used in the course are easy to observe there.


#heading(level: 2, numbering: none)[The course project layout]
 Keep the supplied structure unchanged. The lab pages print source directly from `all_experiments/`, so the files in the book and the files you edit are the same files.

#code-block("OPERATING SYSTEMS/\n|-- Lab01/\n|   |-- directory_list.c\n|   |-- fork_demo.c\n|-- Lab02/\n|   |-- file_copy.c\n|   |-- file_info.c\n|   |-- mini_grep.c\n|   |-- sample.txt\n|-- Lab03/\n|   |-- events.log\n|   |-- log_summary.sh\n|   |-- process_summary.sh\n|   |-- system_report.sh\n|-- Lab04/\n|   |-- fcfs.c\n|   |-- priority.c\n|   |-- round_robin.c\n|   |-- sjf.c\n|-- Lab05/\n|   |-- pipe_demo.c\n|   |-- producer_consumer_sim.c\n|   |-- shm_reader.c\n|   |-- shm_writer.c\n|-- Lab06/\n|   |-- banker.c\n|   |-- threads_demo.c\n|-- Lab07/\n|   |-- best_fit.c\n|   |-- first_fit.c\n|   |-- worst_fit.c\n|-- Lab08/\n|   |-- fifo.c\n|   |-- lfu.c\n|   |-- lru.c\n|-- Lab09/\n|   |-- directory_walk.c\n|   |-- make_demo_tree.c\n|-- Lab10/\n|   |-- binary_records.c\n|   |-- indexed_allocation.c\n|   |-- text_records.c\n|-- README.md", lang: "bash")


#heading(level: 2, numbering: none)[Choose the Linux environment]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Platform], [Recommended route], [What you use in the labs],),
    table.hline(),
    [Linux], [Native Linux], [Terminal, Vim, GCC, Bash],
    [Windows], [WSL 2 with Ubuntu], [Ubuntu/WSL terminal],
    [macOS], [macOS Terminal], [Terminal and compiler],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Windows students: install WSL]
 WSL lets Windows run a Linux environment alongside Windows. Your Windows desktop remains unchanged; the #strong[Ubuntu/WSL terminal] becomes the laboratory environment.

Open #strong[PowerShell or Windows Terminal as Administrator]: #code-block("wsl --install", lang: "bash") Restart if Windows asks. Open #strong[Ubuntu], create a Linux username and password, then verify from PowerShell: #code-block("wsl --status\nwsl --list --verbose", lang: "bash")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/817cb86f377ef656.cetz.json")], caption: [PowerShell launches the Linux environment; the lab work itself (`gcc`, `vim`, `ps`, `bash`) happens in the Ubuntu/WSL shell.]) <fig:wsl-shells>

#callout("pitfall", title: [Common mistake])[Do not type Linux package, compiler, or lab commands into PowerShell. After WSL is installed, run the practical work inside Ubuntu/WSL unless the guide explicitly says #strong[PowerShell].]


#heading(level: 2, numbering: none)[Install the command-line tools]
 On Ubuntu, Debian, or WSL: #code-block("sudo apt update\nsudo apt install build-essential gdb make vim git openssh-client", lang: "bash") Verify the core tools: #code-block("gcc --version\nvim --version | head -n 1\ngit --version\nuname -a", lang: "bash")

For WSL, keep Linux course work in the Linux home directory rather than under `/mnt/c`: #code-block("mkdir -p ~/operating-systems\ncd ~/operating-systems\npwd", lang: "bash")


#heading(level: 2, numbering: none)[The CLI commands you need first]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Command], [Purpose], [Example],),
    table.hline(),
    [`pwd`], [show the current directory], [`pwd`],
    [`ls`], [list files], [`ls -la`],
    [`cd`], [change directory], [`cd all_experiments/Lab01`],
    [`mkdir`], [create a directory], [`mkdir practice`],
    [`cp` / `mv`], [copy / move or rename], [`cp a.c b.c`, `mv old new`],
    [`rm`], [remove a file], [`rm program`],
    [`man`], [open the manual], [`man ps`],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Vim: the editor used in this course]
 Vim is a terminal editor. You do not need advanced Vim knowledge; the course uses a small, repeatable set of commands.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/54dbb08495e31429.cetz.json")], caption: [Vim's three modes. Normal mode is home: `i` enters Insert mode and `:` enters Command-line mode, and `Esc` or `Enter` returns to Normal mode.]) <fig:vim-modes>

Open a file from the shell: #code-block("vim hello.c", lang: "bash")

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Vim command], [What it does],),
    table.hline(),
    [`i`], [enter Insert mode and start typing],
    [`Esc`], [return to Normal mode],
    [`:w`], [save],
    [`:q`], [quit if nothing changed],
    [`:wq`], [save and quit],
    [`:q!`], [quit and discard unsaved changes],
    [`u` / `Ctrl+r`], [undo / redo],
    [`/word`], [search forward for `word`; press `n` for the next match],
    [`:set number`], [show line numbers],
    [`:25`], [jump to line 25, useful for compiler errors],
  )]
  , kind: table
  )

For guided practice, run `vimtutor` once before Lab 1.


#heading(level: 2, numbering: none)[The edit-compile-run cycle]
 Create a first program with `vim hello.c`: #code-block("#include <stdio.h>\n\nint main(void) {\n    printf(\"My OS lab environment is ready.\\n\");\n    return 0;\n}", lang: "c") Compile and run: #code-block("gcc -Wall -Wextra -std=c11 hello.c -o hello\n./hello", lang: "bash")

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/1b5c4517b31a0ac5.cetz.json")], caption: [The edit-compile-run cycle: edit the source, save, compile, then run and inspect the result. Revise one thing at a time and repeat.]) <fig:edit-compile-run>
