#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-getting-started-linux-wsl")

#chapter-star[Your Linux Toolkit and Environment Setup]

#chapterguide[No Linux experience is required. You need a computer where you can use Linux, WSL, or a Linux virtual machine.][identify the course folder, open a Linux shell, edit source in Vim, compile with GCC, run a program, and prepare Git/SSH for saving course work.]

The practicals use a #strong[command-line workflow]. Linux is the reference environment because the processes, files, permissions, IPC objects, and other OS concepts used in the course are easy to observe there.

#heading(depth: 2, numbering: none)[The course project layout]

Keep the supplied structure unchanged. The lab pages print source directly from `all_experiments/`, so the files in the book and the files you edit are the same files.

```bash
OPERATING SYSTEMS/
|-- Lab01/
|   |-- directory_list.c
|   |-- fork_demo.c
|-- Lab02/
|   |-- file_copy.c
|   |-- file_info.c
|   |-- mini_grep.c
|   |-- sample.txt
|-- Lab03/
|   |-- events.log
|   |-- log_summary.sh
|   |-- process_summary.sh
|   |-- system_report.sh
|-- Lab04/
|   |-- fcfs.c
|   |-- priority.c
|   |-- round_robin.c
|   |-- sjf.c
|-- Lab05/
|   |-- pipe_demo.c
|   |-- producer_consumer_sim.c
|   |-- shm_reader.c
|   |-- shm_writer.c
|-- Lab06/
|   |-- banker.c
|   |-- threads_demo.c
|-- Lab07/
|   |-- best_fit.c
|   |-- first_fit.c
|   |-- worst_fit.c
|-- Lab08/
|   |-- fifo.c
|   |-- lfu.c
|   |-- lru.c
|-- Lab09/
|   |-- directory_walk.c
|   |-- make_demo_tree.c
|-- Lab10/
|   |-- binary_records.c
|   |-- indexed_allocation.c
|   |-- text_records.c
|-- README.md
```

#heading(depth: 2, numbering: none)[Choose the Linux environment]

#utptable[
  #tabularx(
    columns: (14%, 32%, 1fr),
    styles: (navy-bold,),
    header: ([Platform], [Recommended route], [What you use in the labs]),
    [Linux], [Native Linux], [Terminal, Vim, GCC, Bash],
    [Windows], [WSL 2 with Ubuntu], [Ubuntu/WSL terminal],
    [macOS], [macOS Terminal], [Terminal and compiler],
  )
]

#heading(depth: 2, numbering: none)[Windows students: install WSL]

WSL lets Windows run a Linux environment alongside Windows. Your Windows desktop remains unchanged; the #strong[Ubuntu/WSL terminal] becomes the laboratory environment.

Open #strong[PowerShell or Windows Terminal as Administrator]:

```bash
wsl --install
```

Restart if Windows asks. Open #strong[Ubuntu], create a Linux username and password, then verify from PowerShell:

```bash
wsl --status
wsl --list --verbose
```

#utpfig([PowerShell launches the Linux environment; the lab work itself (`gcc`, `vim`, `ps`, `bash`) happens in the Ubuntu/WSL shell.], label: <fig:wsl-shells>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 4.25, min-height: 1.55, inner-sep: 3mm, align: center, font: font("small", fill: navy))
    let linux = (..box-style, draw: teal, fill: pale-teal)
    let a = (line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    node((-4, 0), [#strong[Windows PowerShell] \ #v(1.9925pt)
   install and check WSL \
  `wsl --status`], name: "win", ..box-style)
    node((4, 0), [#strong[Ubuntu / WSL shell] \ #v(1.9925pt)
   run course commands \
  `gcc`, `vim`, `ps`, `bash`], name: "wsl", ..linux)
    connect("win", "wsl", ..a)
    node(along("win", "wsl", t: 50%), [launches the \
  Linux environment], yshift: 2.9888pt, fill: white, inner-sep: 1.4944pt, text-width: 2.6, align: center, font: font("script", fill: muted), anchor: "south")
  })
]

#warning[
  Do not type Linux package, compiler, or lab commands into PowerShell. After WSL is installed, run the practical work inside Ubuntu/WSL unless the guide explicitly says #strong[PowerShell].
]

#heading(depth: 2, numbering: none)[Install the command-line tools]

On Ubuntu, Debian, or WSL:

```bash
sudo apt update
sudo apt install build-essential gdb make vim git openssh-client
```

Verify the core tools:

```bash
gcc --version
vim --version | head -n 1
git --version
uname -a
```

For WSL, keep Linux course work in the Linux home directory rather than under `/mnt/c`:

```bash
mkdir -p ~/operating-systems
cd ~/operating-systems
pwd
```

#heading(depth: 2, numbering: none)[The CLI commands you need first]

#utptable[
  #tabularx(
    columns: (16%, 28%, 1fr),
    styles: (navy-bold,),
    header: ([Command], [Purpose], [Example]),
    [`pwd`], [show the current directory], [`pwd`],
    [`ls`], [list files], [`ls -la`],
    [`cd`], [change directory], [`cd all_experiments/Lab01`],
    [`mkdir`], [create a directory], [`mkdir practice`],
    [`cp` / `mv`], [copy / move or rename], [`cp a.c b.c`, `mv old new`],
    [`rm`], [remove a file], [`rm program`],
    [`man`], [open the manual], [`man ps`],
  )
]

#heading(depth: 2, numbering: none)[Vim: the editor used in this course]

Vim is a terminal editor. You do not need advanced Vim knowledge; the course uses a small, repeatable set of commands.

#utpfig([Vim’s three modes. Normal mode is home: `i` enters Insert mode and `:` enters Command-line mode, and `Esc` or `Enter` returns to Normal mode.], label: <fig:vim-modes>)[
  #canvas({
    let n = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 4.25, min-height: 1.55, inner-sep: 3.5mm, align: center, font: font("small", fill: navy))
    let i = (..n, draw: teal, fill: pale-teal, min-height: 2.05)
    let c = (..n, draw: orange, fill: pale-orange, min-height: 2.05)
    let bileft = (line-width: 1.0461pt, draw: mix(teal, 85%, other: black), shorten-start: 1.9925pt, shorten-end: 1.9925pt, start: arrow-tip("Stealth", length: 2.5mm, width: 2mm, line: 1.0461pt), end: arrow-tip("Stealth", length: 2.5mm, width: 2mm, line: 1.0461pt))
    let biright = (line-width: 1.0461pt, draw: mix(orange, 90%, other: black), shorten-start: 1.9925pt, shorten-end: 1.9925pt, start: arrow-tip("Stealth", length: 2.5mm, width: 2mm, line: 1.0461pt), end: arrow-tip("Stealth", length: 2.5mm, width: 2mm, line: 1.0461pt))
    node((0, 2.65), [#strong[NORMAL MODE] \ #v(2.9888pt)
   navigate, edit, search, and issue commands], name: "normal", ..n)
    node((-4.25, -0.75), [#strong[INSERT MODE] \ #v(2.9888pt)
   type and edit program text \ #v(4.9813pt)
   #fsize("script")[#strong[Enter:] `i`#h(1em)#strong[Return:] `Esc`]], name: "insert", ..i)
    node((4.25, -0.75), [#strong[COMMAND-LINE MODE] \ #v(2.9888pt)
   save, quit, and change settings \ #v(4.9813pt)
   #fsize("script")[#strong[Enter:] `:`#h(1em)#strong[Return:] `Enter/Esc`]], name: "command", ..c)
    connect("normal.south-west", "insert.north-east", out-angle: 235deg, in-angle: 55deg, looseness: 1.08, ..bileft, name: "curve-1")
    connect("normal.south-east", "command.north-west", out-angle: 305deg, in-angle: 125deg, looseness: 1.08, ..biright, name: "curve-2")
  })
]

Open a file from the shell:

```bash
vim hello.c
```

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Vim command], [What it does]),
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
  )
]

For guided practice, run `vimtutor` once before Lab 1.

#heading(depth: 2, numbering: none)[The edit-compile-run cycle]

Create a first program with `vim hello.c`:

```c
#include <stdio.h>

int main(void) {
    printf("My OS lab environment is ready.\n");
    return 0;
}
```

Compile and run:

```bash
gcc -Wall -Wextra -std=c11 hello.c -o hello
./hello
```

#utpfig([The edit-compile-run cycle: edit the source, save, compile, then run and inspect the result. Revise one thing at a time and repeat.], label: <fig:edit-compile-run>)[
  #canvas({
    let flowcard = (draw: mix(blue, 65%), fill: white, rounded: 1.5mm, text-width: 2.45, min-height: 1.35, inner-xsep: 2mm, inner-ysep: 2.5mm, align: center, font: font("small", fill: navy))
    let forward = (line-width: 0.8966pt, draw: teal, shorten-start: 1.9925pt, shorten-end: 1.9925pt, end: arrow-tip("Stealth", length: 2.3mm, width: 1.8mm, line: 0.8966pt))
    let feedback = (line-width: widths.semithick, dash: "dashed", draw: muted, rounded: 3.9851pt, shorten-start: 1.9925pt, shorten-end: 1.9925pt, end: arrow-tip("Stealth", length: 2.2mm, width: 1.7mm, line: widths.semithick))
    let feedbacklabel = (fill: white, inner-xsep: 2mm, inner-ysep: 0.9963pt, font: font("script", fill: muted))
    node((-5.2, 0), [#text(fill: blue)[#strong[01]] \ #v(1.9925pt)
   #strong[EDIT SOURCE] \ #v(2.9888pt)
  `vim file.c`], name: "edit", ..flowcard)
    node((-1.75, 0), [#text(fill: blue)[#strong[02]] \ #v(1.9925pt)
   #strong[SAVE] \ #v(2.9888pt)
  `:wq`], name: "save", ..flowcard)
    node((1.75, 0), [#text(fill: blue)[#strong[03]] \ #v(1.9925pt)
   #strong[COMPILE] \ #v(2.9888pt)
  `gcc ...`], name: "build", ..flowcard)
    node((5.2, 0), [#text(fill: blue)[#strong[04]] \ #v(1.9925pt)
   #strong[RUN AND INSPECT] \ #v(2.9888pt)
  `./program`], name: "run", ..flowcard)
    connect("edit.east", "save.west", ..forward)
    connect("save.east", "build.west", ..forward)
    connect("build.east", "run.west", ..forward)
    connect("run.south", (rel: (0, -1), to: "run.south"), (rel: (-10.4, 0), to: (rel: (0, -1), to: "run.south")), "edit.south", ..feedback)
    node(along((rel: (0, -1), to: "run.south"), (rel: (-10.4, 0), to: (rel: (0, -1), to: "run.south")), t: 50%), [revise one thing, then repeat], ..feedbacklabel, anchor: "north")
  })
]
