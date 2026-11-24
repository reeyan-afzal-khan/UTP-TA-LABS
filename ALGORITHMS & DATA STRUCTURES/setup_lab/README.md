# Lab setup: C++ compiler and VS Code

One script gets a computer ready for the Algorithms & Data Structures labs. It installs only what is missing,
sets up Visual Studio Code for C++17, creates your lab project folder, and builds a small test program to prove
that everything works. Chapter 1 of the book, *Your Toolkit and Environment Setup*, walks through the same steps
by hand.

## Run it

| System | How |
| --- | --- |
| Windows 10 or 11 | Double-click `setup.bat`, or run `.\setup.bat` from this folder in PowerShell |
| macOS | In Terminal: `sh setup.sh` from this folder |
| Linux, including WSL | In a terminal: `sh setup.sh` from this folder |

The script first lists what it found and what it is about to install, then waits for you to agree. At the end
it builds and runs `check_setup.cpp`, which must print `result   : ready for the labs`, and opens your project
folder in VS Code. Open any `.cpp` file there and press **Ctrl+Shift+B** (**Cmd+Shift+B** on macOS) to build and
run it, or **F5** to run it in the debugger.

Run the script again whenever you like. Whatever is already installed is left as it is, so a second run only
checks.

## What it installs

| | Windows | macOS | Linux |
| --- | --- | --- | --- |
| Compiler | GCC from MSYS2 (UCRT64), in `C:\msys64` | Apple clang, from the Command Line Tools | `g++` from apt, dnf, pacman or zypper |
| Debugger | GDB from MSYS2 | LLDB, from the Command Line Tools | `gdb` |
| VS Code, if missing | with winget | with Homebrew, if you have it | with snap, if you have it |
| VS Code extension | Microsoft's C/C++ (`ms-vscode.cpptools`) | the same | the same |
| Your `Path` | adds `C:\msys64\ucrt64\bin` to your user `Path` | unchanged | unchanged |

On Windows, the first install downloads a few hundred megabytes, and Windows may ask for permission to install
MSYS2. On Linux, the script asks for your password through `sudo`. Run it as yourself, not with `sudo`.

## Options

| Option | Effect |
| --- | --- |
| *folder* | Create the project there instead of `UTP-ADS` in your home folder, for example `setup.bat "D:\Uni\UTP-ADS"` or `sh setup.sh ~/uni/UTP-ADS` |
| `--check` | Report what is installed and build the test program; change nothing |
| `--no-install` | Install no software (on Windows, still add the compiler to your `Path`); set up the project folder only. Useful on lab computers where the tools are already installed |
| `--no-open` | Do not open VS Code at the end |
| `--yes` | Do not ask before installing |

## Your project folder

```text
UTP-ADS/
  .vscode/          the five files from vscode/ (below)
  Lab01/ ... Lab11/ one folder per lab; add each program as you reach it in the book
  README.md         how to build and run, for anyone who opens the folder
  .gitignore        keeps built programs out of Git
```

The script never overwrites `README.md` or `.gitignore`. If you changed one of the `.vscode` files, it keeps your
version beside the new one as, for example, `tasks.json.bak`.

## The VS Code settings

The files in [`vscode/`](vscode) are copied into the project's `.vscode` folder. They work on Windows, macOS and
Linux without changes; on Windows the script points them at your compiler if it is not in `C:\msys64`.

| File | What it does |
| --- | --- |
| [`tasks.json`](vscode/tasks.json) | **Ctrl+Shift+B** builds the open file with `g++ -std=c++17 -Wall -Wextra -pedantic -g` (clang++ on macOS) and runs it. The task *C++: build* only builds |
| [`launch.json`](vscode/launch.json) | **F5** builds the open file and runs it in GDB (LLDB on macOS), stopping at your breakpoints |
| [`c_cpp_properties.json`](vscode/c_cpp_properties.json) | IntelliSense uses the same compiler and C++17, so the editor underlines the errors the compiler would report |
| [`settings.json`](vscode/settings.json) | Saves files before every build, uses four-space indents, and hides built programs from the Explorer |
| [`extensions.json`](vscode/extensions.json) | VS Code offers the C/C++ extension when the folder opens |

Each program is built next to its source: `Lab03/singly_linked_list.cpp` becomes `Lab03/singly_linked_list.exe`
on Windows and `Lab03/singly_linked_list` on macOS and Linux.

## If something goes wrong

| Problem | Fix |
| --- | --- |
| `'g++' is not recognized` in a terminal | Close every terminal and VS Code window, then open them again so they read the new `Path`. Check with `where.exe g++` (Windows) or `which g++` |
| VS Code builds nothing when you press Ctrl+Shift+B | Open the project *folder* (**File > Open Folder**), not a single file: the settings apply only to an open folder. Then open a `.cpp` file and try again |
| *winget is not available* (Windows) | Install MSYS2 from <https://www.msys2.org> into `C:\msys64` and VS Code from <https://code.visualstudio.com>, then run `setup.bat` again |
| pacman fails partway (Windows) | Check the internet connection and run `setup.bat` again. If it fails twice, open **MSYS2 UCRT64** from the Start menu and run `pacman -S mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb` |
| A program builds but exits at once with no output (Windows) | The program cannot find GCC's runtime files. Make sure `C:\msys64\ucrt64\bin` is on your `Path` and restart VS Code |
| F5 says the debugger cannot be found | Windows: run `setup.bat` again, which installs GDB. Linux: install `gdb`. macOS: run `xcode-select --install` |
| *Command Line Tools* window does not appear (macOS) | Run `xcode-select --install` yourself, finish it, then run `sh setup.sh` again |
| No apt, dnf, pacman or zypper (Linux) | Install `g++` and `gdb` with your distribution's package manager, then run `sh setup.sh` again |

## Tested on

| System | Result |
| --- | --- |
| Windows 11 | `--check` and `--no-install` runs, including a project path containing `&`, spaces and parentheses; settings copy, compiler-folder patching, `.bak` backups and the user `Path` update tested on their own. Not yet run end to end on a computer without MSYS2 |
| Linux, macOS | Every branch exercised with stand-in commands (no real installs) under `dash` and `bash`. Not yet run on a real Linux or Mac |
