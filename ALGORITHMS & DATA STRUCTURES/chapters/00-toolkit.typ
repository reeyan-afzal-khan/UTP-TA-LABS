#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:python>

#chapterguide[Create folders and run basic #strong[terminal commands].][organize data and notebooks, configure an environment, install dependencies, and run labs reproducibly.]

== The course project layout

Use `UTP-"COURSE-NAME"/` as the project root, with these folders:

```terminal
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

== C++ compiler setup

Install the compiler for your operating system. The course examples use C++17; an editor or IDE is optional.

#v(6pt)
#strong[Windows]

Install #link("https://www.msys2.org/")[#strong[MSYS2]], open its
#strong[UCRT64] terminal, then install and check GCC:

```terminal
pacman -S mingw-w64-ucrt-x86_64-gcc
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

On Ubuntu or Debian, install and check GNU C++. Other distributions
provide GCC/G++ through their package manager:

```terminal
sudo apt update
sudo apt install g++
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
