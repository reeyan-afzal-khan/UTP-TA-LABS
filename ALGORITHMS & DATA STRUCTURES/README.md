# Algorithms & Data Structures

**Status: in development.** The book, all eleven lab sheets, runnable C++ programs for every lab, and the PDFs
are in place; the course is still being reviewed before it is marked ready.

Arrays through hashing in C++: how each structure is stored, what its operations cost, how to argue that an
implementation is correct, and how to compare two choices with tests and reproducible benchmarks. Twelve chapters
in six stages, each core chapter followed by its lab, and a final algorithm-comparison project.

**[Book (PDF, 98 pages)](../.all_pdfs/algorithms-data-structures/ADS-Book.pdf)** ·
[Lab bundles](../.all_pdfs/algorithms-data-structures) ·
[LaTeX source](main.tex) ·
[Lecturer materials](0.from_lecturer) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 Foundations | 1–2 | 1 | 1, 2 |
| 2 Linear Dynamic Structures | 3–6 | 17 | 3, 4, 5, 6 |
| 3 Trees and Hierarchies | 7–8 | 46 | 7, 8 |
| 4 Graphs and Traversal | 9 | 62 | 9 |
| 5 Core Algorithms and Fast Access | 10–11 | 70 | 10, 11 |
| 6 Course Project and Synthesis | 12 | 88 | |

## Labs

Lab *N* practises Chapter *N* and opens with how it aligns with the official lab manual. Each lab's folder under
[`.all_pdfs/algorithms-data-structures/`](../.all_pdfs/algorithms-data-structures) holds that chapter and the lab
sheet. Every lab also has its own folder under [`all_experiments/`](all_experiments) holding only that lab's
programs. Each program runs the
sheet's tasks, including its *Try it yourself*, and prints an `[ok]` line for every item of the sheet's
verification list it can check. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Programs |
| --- | --- | --- | --- | --- |
| 1 | [Programming foundations and structured records](../.all_pdfs/algorithms-data-structures/Lab-01/Lab-Activity.pdf) | Ch. 1 | 8–9 | [Lab01](all_experiments/Lab01): `student_records`, `union_review` |
| 2 | [Arrays, multidimensional storage, and matrices](../.all_pdfs/algorithms-data-structures/Lab-02/Lab-Activity.pdf) | Ch. 2 | 15–16 | [Lab02](all_experiments/Lab02): `matrix_multiply`, `matrix_operations` |
| 3 | [Singly and doubly linked lists](../.all_pdfs/algorithms-data-structures/Lab-03/Lab-Activity.pdf) | Ch. 3 | 23–24 | [Lab03](all_experiments/Lab03): `singly_linked_list`, `doubly_linked_list` |
| 4 | [Circular linked-list operations](../.all_pdfs/algorithms-data-structures/Lab-04/Lab-Activity.pdf) | Ch. 4 | 30–31 | [Lab04](all_experiments/Lab04): `circular_linked_list`, `list_comparison` |
| 5 | [Stack ADT and expression processing](../.all_pdfs/algorithms-data-structures/Lab-05/Lab-Activity.pdf) | Ch. 5 | 37–38 | [Lab05](all_experiments/Lab05): `array_stack`, `linked_stack`, `infix_to_postfix` |
| 6 | [Linear, linked, circular, and priority queues](../.all_pdfs/algorithms-data-structures/Lab-06/Lab-Activity.pdf) | Ch. 6 | 44–45 | [Lab06](all_experiments/Lab06): `linear_queue`, `linked_queue`, `circular_queue`, `priority_queue` |
| 7 | [Tree representation and traversal](../.all_pdfs/algorithms-data-structures/Lab-07/Lab-Activity.pdf) | Ch. 7 | 52–53 | [Lab07](all_experiments/Lab07): `binary_tree` |
| 8 | [BSTs, heaps, and balancing structures](../.all_pdfs/algorithms-data-structures/Lab-08/Lab-Activity.pdf) | Ch. 8 | 60–61 | [Lab08](all_experiments/Lab08): `bst`, `heap` |
| 9 | [Graph representation, traversal, and spanning trees](../.all_pdfs/algorithms-data-structures/Lab-09/Lab-Activity.pdf) | Ch. 9 | 68–69 | [Lab09](all_experiments/Lab09): `graph_traversal`, `minimum_spanning_tree` |
| 10 | [Searching and sorting experiments](../.all_pdfs/algorithms-data-structures/Lab-10/Lab-Activity.pdf) | Ch. 10 | 79–80 | [Lab10](all_experiments/Lab10): `quick_sort_descending`, `binary_search`, `merge_three_arrays`, `heap_sort` |
| 11 | [Hashing and collision resolution](../.all_pdfs/algorithms-data-structures/Lab-11/Lab-Activity.pdf) | Ch. 11 | 86–87 | [Lab11](all_experiments/Lab11): `hashing_collisions` |
| | [Final project: algorithm comparison](../.all_pdfs/algorithms-data-structures/Capstone-Project.pdf) | Ch. 12 | 89–94 | |

Where a sheet leaves a choice to the instructor, the program states the one it makes in its opening comment:
the priority convention in Lab 6 (a larger number is a higher priority), a simple path for Lab 9's path-length
test, Kruskal's algorithm for the Lab 9 minimum spanning tree, and the middle-index pivot for Lab 10's quick
sort. Lab 8's B-tree exercises are left to the instructor's order and minimum-degree rules, as its sheet directs,
so no B-tree program is included.

The final-project brief from the lecturer is
[`0.from_lecturer/Lab_Final_Project_Guidelines.docx`](0.from_lecturer/Lab_Final_Project_Guidelines.docx).

## Running the labs

The programs are standard C++17, one self-contained `.cpp` file each, and need only a C++ compiler: g++ (MinGW
or WinLibs on Windows, the system compiler on Linux and macOS) or the compiler of your IDE. Build and run one
from its lab folder:

```bash
cd all_experiments/Lab03
g++ -std=c++17 -Wall -Wextra singly_linked_list.cpp -o singly_linked_list
./singly_linked_list
```

On Windows the program is `singly_linked_list.exe`; run it as `.\singly_linked_list` in PowerShell. Every
program builds without a warning under `-Wall -Wextra -pedantic`, runs without input, and prints the same output
on every run.

## Folder map

```text
ALGORITHMS & DATA STRUCTURES/
  main.tex            the book: configuration and chapter list
  chapters/           12 chapters and the course map
  labs/               11 lab sheets, each input at the end of its chapter
  all_experiments/    Lab01-Lab11, the C++ programs for each lab
  0.from_lecturer/    the lecturer's final-project guidelines
```

## Building the book

From the repository root:

```bash
python .shared/build.py ADS            # rebuild the book and its lab PDFs in .all_pdfs/algorithms-data-structures/
python .shared/build.py ADS --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
