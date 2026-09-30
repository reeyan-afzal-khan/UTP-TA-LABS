# Vim Quick Reference for Operating Systems Labs

This course uses Vim as the standard command-line source editor. Advanced Vim skills are not required.

## Basic workflow

```bash
cd all_experiments/Lab01
vim fork_demo.c
# edit and save in Vim
gcc -Wall -Wextra -std=c11 fork_demo.c -o fork_demo
./fork_demo
```

## Three modes you need

- **Normal mode** - press `Esc`; navigate and issue editing commands.
- **Insert mode** - press `i`, `a`, or `o`; type source code.
- **Command-line mode** - from Normal mode press `:`; save, quit, or configure Vim.

When unsure, press `Esc` first.

| Command | Meaning |
|---|---|
| `i` | insert before cursor |
| `a` | append after cursor |
| `o` | open a new line below |
| `Esc` | return to Normal mode |
| `:w` | save |
| `:q` | quit if no unsaved changes |
| `:wq` | save and quit |
| `:q!` | quit and discard unsaved changes |
| `u` | undo |
| `Ctrl+r` | redo |
| `dd` | delete current line |
| `yy` | copy/yank current line |
| `p` | paste after/below cursor |
| `/text` | search forward |
| `n` / `N` | next / previous result |
| `gg` / `G` | first / last line |
| `:42` | jump to line 42 |

## Helpful settings

```text
:set number
:set autoindent
:set tabstop=4 shiftwidth=4 expandtab
```

## Compiler-error workflow

If GCC reports `program.c:27: error: ...`, reopen the file, press `Esc`, type `:27`, correct the **first** reported error, save, and compile again.

Optional from inside Vim:

```text
:w
:!gcc -Wall -Wextra -std=c11 % -o program
:!./program
```

`%` means the current filename. Compiling from the normal shell remains the standard course workflow.
