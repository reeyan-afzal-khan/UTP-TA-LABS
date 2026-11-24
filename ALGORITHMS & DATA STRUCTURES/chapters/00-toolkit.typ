#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:toolkit>

#chapterguide[Open a terminal and move between folders with `cd`.][set up a C++17 compiler and Visual Studio Code with one script, build and run any lab program with one key, stop a program in the debugger to read its variables, and build the same program from a terminal.]

Every lab in this book is a single C++17 file that you build and run on your own computer. That takes three things: a compiler, an editor that knows how to call it, and one project folder that keeps the labs in order. The course's `setup_lab` folder sets up all three in a single step. The later sections show what the script does, for when you would rather work by hand or need to repair one piece.

== The course project layout

Keep every lab program in one project folder, `UTP-ADS/`. The setup script creates it in your home folder, with the VS Code settings and an empty folder for each lab. Add each `.cpp` file when its lab reaches it:

```terminal
UTP-ADS/
  .vscode/                    VS Code settings, copied from setup_lab/vscode
    c_cpp_properties.json
    extensions.json
    launch.json
    settings.json
    tasks.json
  Lab01/
    student_records.cpp
    union_review.cpp
  Lab02/
    matrix_multiply.cpp
    matrix_operations.cpp
  Lab03/
    doubly_linked_list.cpp
    singly_linked_list.cpp
  Lab04/
    circular_linked_list.cpp
    list_comparison.cpp
  Lab05/
    array_stack.cpp
    infix_to_postfix.cpp
    linked_stack.cpp
  Lab06/
    circular_queue.cpp
    linear_queue.cpp
    linked_queue.cpp
    priority_queue.cpp
  Lab07/
    binary_tree.cpp
  Lab08/
    bst.cpp
    heap.cpp
  Lab09/
    graph_traversal.cpp
    minimum_spanning_tree.cpp
  Lab10/
    binary_search.cpp
    heap_sort.cpp
    merge_three_arrays.cpp
    quick_sort_descending.cpp
  Lab11/
    hashing_collisions.cpp
  README.md
  .gitignore
```

#pagebreak()

== One-step setup with `setup_lab` <sec:setup-lab>

The course folder, `ALGORITHMS & DATA STRUCTURES/`, holds a `setup_lab` folder with one script for Windows and one for Linux and macOS. Each script first lists what it found on your computer and what it is about to install. Nothing changes until you agree.

#describe-nextline(1.15in)[
  / Windows: Double-click `setup.bat`. It installs #link("https://www.msys2.org/")[#strong[MSYS2]] into `C:\msys64`, then the GCC compiler and the GDB debugger from it, adds `C:\msys64\ucrt64\bin` to your user `Path`, and installs VS Code if it is missing.
  / macOS: In Terminal, go to the `setup_lab` folder and run `sh setup.sh`. It installs Apple's Command Line Tools, which bring `clang++` and the LLDB debugger, and installs VS Code with Homebrew if you have Homebrew.
  / Linux: Run `sh setup.sh` from the `setup_lab` folder. It installs `g++` and `gdb` with your package manager (apt, dnf, pacman or zypper) and asks for your password to do so.
]

All three then install Microsoft's C/C++ extension for VS Code, create `UTP-ADS/` as shown above, build and run a small test program, `check_setup.cpp`, and open the project in VS Code. A finished run on Windows ends like this; the version numbers depend on when you install:

```terminal
 [4/4] Project folder
       C:\Users\you\UTP-ADS
       Lab01 to Lab11, .vscode settings, README.md and .gitignore

 Check: building and running check_setup.cpp
 C++ toolchain check
   compiler : g++ 15.2.0
   language : C++17 (__cplusplus = 201703)
   result   : ready for the labs

 Ready. In VS Code, open a .cpp file in your project folder, then press
 Ctrl+Shift+B to build and run it, or F5 to run it in the debugger.
```

#tip[Running the script twice is harmless: it skips whatever is already in place. Add `--check` to see what is installed without changing anything, `--no-install` on a lab computer that already has the tools, or a folder name to put the project somewhere else, as in `setup.bat "D:\Uni\UTP-ADS"`. The `README.md` in `setup_lab` lists every option and the fix for each common problem.]

== Setting up the compiler by hand

Skip this section if the script reported `ready for the labs`. The commands below install the same compiler and debugger that the script installs. The course examples use C++17.

#v(6pt)
#strong[Windows]

Install #link("https://www.msys2.org/")[#strong[MSYS2]], open its
#strong[UCRT64] terminal, then install and check GCC and GDB:

```terminal
pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb
g++ --version
```

To run `g++` from PowerShell, Command Prompt, or an IDE
terminal, add the UCRT64 compiler folder to your Windows user `Path`:

#listopts(leftmargin: 1.7em)[
  + Open the Start menu, search for #strong[Edit environment variables for your account], and open it.
  + Under #strong[User variables], select #strong[Path], choose #strong[Edit], then choose #strong[New]. Do not replace or delete the existing entries.
  + Add `C:\msys64\ucrt64\bin`. If MSYS2 was installed in a different folder, use that installation folder followed by `\ucrt64\bin`.
  + Confirm each dialog with #strong[OK], then close and reopen PowerShell, Command Prompt, or the IDE so it reads the updated path.
]

Verify that Windows finds the compiler:

```terminal
where.exe g++
g++ --version
```

The first command should print a location under
`ucrt64\bin`. If it prints nothing, check that the folder
exists and that the new `Path` entry points to its `bin`
subfolder. For why UCRT64 uses this compiler directory, see the
#link("https://www.msys2.org/docs/environments/")[#strong[MSYS2 environment guide]].

If your course requires Microsoft’s compiler, install Visual Studio
or Build Tools with the
#link("https://learn.microsoft.com/en-us/cpp/build/vscpp-step-0-installation")[#strong[Desktop development with C++ workload]] and use its Developer Command Prompt.

#v(6pt)
#text(fill: mix(blue, 45%))[#box(width: 100%, height: 0.4981pt, fill: ink)]

#v(6pt)
#strong[Linux]

On Ubuntu or Debian, install and check GNU C++ and its debugger. Other distributions
provide the same `g++` and `gdb` through their package manager:

```terminal
sudo apt update
sudo apt install g++ gdb
g++ --version
```

#v(6pt)
#text(fill: mix(blue, 45%))[#box(width: 100%, height: 0.4981pt, fill: ink)]

#v(6pt)
#strong[macOS]

Install Apple’s Command Line Tools (the full Xcode application is
not required), then check that Clang is available:

```terminal
xcode-select --install
clang++ --version
```

== Visual Studio Code

VS Code is a free editor. Microsoft's C/C++ extension teaches it C++: errors are underlined as you type, and the five settings files in `setup_lab/vscode` add a one-key build and a debugger. To set it up by hand:

#listopts(leftmargin: 1.7em)[
  + Install VS Code from #link("https://code.visualstudio.com/")[#strong[code.visualstudio.com]]. On Windows, leave #strong[Add to PATH] ticked in the installer.
  + Open the #strong[Extensions] view (#strong[Ctrl+Shift+X]), search for #strong[C/C++], and install the extension published by Microsoft, `ms-vscode.cpptools`.
  + Copy the folder `setup_lab/vscode` into your project and rename the copy `.vscode`.
  + Choose #strong[File > Open Folder] and open `UTP-ADS` itself, not a single file inside it. When VS Code asks whether you trust the authors of the files in the folder, choose #strong[Yes]: VS Code runs no build tasks in a folder it does not trust.
]

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    header: ([File in `.vscode`], [What it does]),
    [`tasks.json`], [#strong[Ctrl+Shift+B] builds the open file with `g++ -std=c++17 -Wall -Wextra -pedantic -g` (`clang++` on macOS), then runs it. The task #strong[C++: build] builds without running.],
    [`launch.json`], [#strong[F5] builds the open file, then runs it under GDB (LLDB on macOS) so that it stops at your breakpoints.],
    [`c_cpp_properties.json`], [IntelliSense uses the same compiler and C++17, so the editor underlines exactly the errors the compiler will report.],
    [`settings.json`], [Saves every file before a build, indents with four spaces, and hides built programs from the Explorer.],
    [`extensions.json`], [Makes VS Code offer the C/C++ extension when the folder opens.],
  )
]

== Build, run and debug a lab program <sec:build-run>

=== In VS Code

Open a lab's `.cpp` file and press #strong[Ctrl+Shift+B] (#strong[Cmd+Shift+B] on macOS). VS Code saves the file, builds it, and runs it in the #strong[Terminal] panel. The program lands next to its source: `Lab03/singly_linked_list.cpp` becomes `Lab03/singly_linked_list.exe` on Windows and `Lab03/singly_linked_list` on Linux and macOS.

When the build fails, nothing runs. Open the #strong[Problems] panel (#strong[Ctrl+Shift+M]) and click a message to jump to its line. Warnings do not stop a build, but read each one as a bug report: every lab program in this book builds without a single warning.

Press #strong[F5] to run the open file in the debugger instead. Set a breakpoint first by clicking to the left of a line number (or pressing #strong[F9] on that line); the program stops there before running the line. The #strong[Variables] view then shows every local variable. Expand a pointer to see the node it points to, which is the quickest way to compare a linked structure with the lab's diagram.

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    header: ([Key], [While the debugger is stopped]),
    [F10], [Run the current line, including any function it calls, and stop at the next line.],
    [F11], [Step into the function called on the current line.],
    [Shift+F11], [Finish the current function and stop in its caller.],
    [F5], [Continue to the next breakpoint, or to the end of the program.],
    [Shift+F5], [Stop the program.],
  )
]

=== From a terminal

Any terminal builds the same program. Go to the lab's folder first:

```terminal
cd Lab03
g++ -std=c++17 -Wall -Wextra singly_linked_list.cpp -o singly_linked_list
./singly_linked_list
```

On Windows, `g++` adds `.exe` to the program's name and PowerShell runs it with the same `./singly_linked_list`. In Command Prompt, type `singly_linked_list` instead.

#note[Most lab programs test themselves while they run. Each test prints one line: `[ok]` when it passed, or `[FAIL]` and the case it was checking. A correct program prints no `[FAIL]` line, and its output matches the run printed with its lab.]

#warning[`'g++' is not recognized` on Windows, or `g++: command not found` elsewhere, means the terminal cannot find the compiler. Close every terminal and VS Code window and open them again so they read the new `Path`, then check with `where.exe g++` (Windows) or `which g++`. If it is still missing, run `setup.bat --check` or `sh setup.sh --check` to see what the script finds.]
