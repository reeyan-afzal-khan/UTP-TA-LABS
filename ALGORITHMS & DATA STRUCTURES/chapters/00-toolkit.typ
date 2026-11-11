#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")


#heading(level: 1)[Your Toolkit and Environment Setup]
 <ch:python>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Create folders and run basic #strong[terminal commands].

*By the end, you can:* organize data and notebooks, configure an environment, install dependencies, and run labs reproducibly.]


#heading(level: 2)[The course project layout]


Use `UTP-"COURSE-NAME"/` as the project root, with these folders:

#code-block("Lab01/\n  student_records.cpp\n  union_review.cpp\nLab02/\n  matrix_multiply.cpp\n  matrix_operations.cpp\nLab03/\n  doubly_linked_list.cpp\n  singly_linked_list.cpp\nLab04/\n  circular_linked_list.cpp\n  list_comparison.cpp\nLab05/\n  array_stack.cpp\n  infix_to_postfix.cpp\n  linked_stack.cpp\nLab06/\n  circular_queue.cpp\n  linear_queue.cpp\n  linked_queue.cpp\n  priority_queue.cpp\nLab07/\n  binary_tree.cpp\nLab08/\n  bst.cpp\n  heap.cpp\nLab09/\n  graph_traversal.cpp\n  minimum_spanning_tree.cpp\nLab10/\n  binary_search.cpp\n  heap_sort.cpp\n  merge_three_arrays.cpp\n  quick_sort_descending.cpp\nLab11/\n  hashing_collisions.cpp\nREADME.md\n.gitignore", lang: "text") 
#heading(level: 2)[C++ compiler setup]


Install the compiler for your operating system. The course examples use C++17; an editor or IDE is optional.

#strong[Windows]

Install #link("https://www.msys2.org/")[#strong[MSYS2]], open its #strong[UCRT64] terminal, then install and check GCC:

#code-block("pacman -S mingw-w64-ucrt-x86_64-gcc\ng++ --version", lang: "text")

To run `g++` from PowerShell, Command Prompt, or an IDE terminal, add the UCRT64 compiler folder to your Windows user `Path`:

+ Open the Start menu, search for #strong[Edit environment variables for your account], and open it.

+ Under #strong[User variables], select #strong[Path], choose #strong[Edit], then choose #strong[New]. Do not replace or delete the existing entries.

+ Add `C:\msys64\ucrt64\bin`. If MSYS2 was installed in a different folder, use that installation folder followed by `\ucrt64\bin`.

+ Confirm each dialog with #strong[OK], then close and reopen PowerShell, Command Prompt, or the IDE so it reads the updated path.

Verify that Windows finds the compiler:

#code-block("where.exe g++\ng++ --version", lang: "text")

The first command should print a location under `ucrt64\bin`. If it prints nothing, check that the folder exists and that the new `Path` entry points to its `bin` subfolder. For why UCRT64 uses this compiler directory, see the #link("https://www.msys2.org/docs/environments/")[#strong[MSYS2 environment guide]].

If your course requires Microsoft's compiler, install Visual Studio or Build Tools with the #link("https://learn.microsoft.com/en-us/cpp/build/vscpp-step-0-installation")[#strong[Desktop development with C++ workload]] and use its Developer Command Prompt.

#strong[Linux]

On Ubuntu or Debian, install and check GNU C++. Other distributions provide GCC/G++ through their package manager:

#code-block("sudo apt update\nsudo apt install g++\ng++ --version", lang: "text")

#strong[macOS]

Install Apple's Command Line Tools (the full Xcode application is not required), then check that Clang is available:

#code-block("xcode-select --install\nclang++ --version", lang: "text")
