# Operating Systems

**Status: ready.** The book, all ten lab sheets, and the C and shell sources for every lab are complete and published.

A step-by-step path from the Linux command line and the process model, through CPU scheduling, concurrency and
memory management, to file systems. Each core chapter is paired with one practical lab, and every lab sheet prints
the complete source files it runs from [`all_experiments/`](all_experiments).

**[Book (PDF, 86 pages)](../.all_pdfs/operating-systems/OS-Book.pdf)** ·
[Lab bundles](../.all_pdfs/operating-systems) ·
[Vim quick reference](all_experiments/VIM-QUICK-REFERENCE.md) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 Orientation and Tools | Linux toolkit, What an OS does | 1 | |
| 2 Processes and the Command Line | 1–3 | 11 | 1, 2, 3 |
| 3 CPU, Concurrency, and Resource Management | 4–6 | 29 | 4, 5, 6 |
| 4 Memory Management | 7–8 | 53 | 7, 8 |
| 5 File Systems and Storage | 9–10 | 68 | 9, 10 |
| Revision map and capstone practice | | 82 | |

## Labs

Each lab folder under [`.all_pdfs/operating-systems/`](../.all_pdfs/operating-systems) holds the chapters to read
before the lab and the lab sheet. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Sources |
| --- | --- | --- | --- | --- |
| 1 | [Processes and the Linux namespace](../.all_pdfs/operating-systems/Lab-01/Lab-Activity.pdf) | Toolkit, What an OS does, Ch. 1 | 14–16 | [Lab01](all_experiments/Lab01): `fork_demo.c`, `directory_list.c` |
| 2 | [Files, metadata, and reliable CLI utilities](../.all_pdfs/operating-systems/Lab-02/Lab-Activity.pdf) | Ch. 2 | 19–22 | [Lab02](all_experiments/Lab02): `file_info.c`, `file_copy.c`, `mini_grep.c` |
| 3 | [Shell scripting for OS observation and automation](../.all_pdfs/operating-systems/Lab-03/Lab-Activity.pdf) | Ch. 3 | 26–28 | [Lab03](all_experiments/Lab03): `system_report.sh`, `process_summary.sh`, `log_summary.sh` |
| 4 | [CPU scheduling: compare policies on one workload](../.all_pdfs/operating-systems/Lab-04/Lab-Activity.pdf) | Ch. 4 | 35–38 | [Lab04](all_experiments/Lab04): `fcfs.c`, `sjf.c`, `priority.c`, `round_robin.c` |
| 5 | [Interprocess communication and synchronization](../.all_pdfs/operating-systems/Lab-05/Lab-Activity.pdf) | Ch. 5 | 42–45 | [Lab05](all_experiments/Lab05): `pipe_demo.c`, `shm_writer.c`, `shm_reader.c`, `producer_consumer_sim.c` |
| 6 | [Threads, mutexes, and resource safety](../.all_pdfs/operating-systems/Lab-06/Lab-Activity.pdf) | Ch. 6 | 49–52 | [Lab06](all_experiments/Lab06): `threads_demo.c`, `banker.c` |
| 7 | [Contiguous memory allocation and fragmentation](../.all_pdfs/operating-systems/Lab-07/Lab-Activity.pdf) | Ch. 7 | 57–60 | [Lab07](all_experiments/Lab07): `first_fit.c`, `best_fit.c`, `worst_fit.c` |
| 8 | [Virtual memory and page replacement](../.all_pdfs/operating-systems/Lab-08/Lab-Activity.pdf) | Ch. 8 | 64–67 | [Lab08](all_experiments/Lab08): `fifo.c`, `lru.c`, `lfu.c` |
| 9 | [File-system namespace, paths, and links](../.all_pdfs/operating-systems/Lab-09/Lab-Activity.pdf) | Ch. 9 | 72–74 | [Lab09](all_experiments/Lab09): `make_demo_tree.sh`, `directory_walk.c` |
| 10 | [File records and indexed block allocation](../.all_pdfs/operating-systems/Lab-10/Lab-Activity.pdf) | Ch. 10 | 78–81 | [Lab10](all_experiments/Lab10): `text_records.c`, `binary_records.c`, `indexed_allocation.c` |
| | [Revision map and capstone practice](../.all_pdfs/operating-systems/Capstone-Project.pdf) | all | 82–83 | |

## Running the labs

The labs run on Linux. On Windows, install WSL as the book's *Your Linux Toolkit and Environment Setup* chapter
explains, then work in the Ubuntu terminal. Each lab sheet gives the exact commands; the pattern is:

```bash
cd all_experiments/Lab04
gcc -Wall -Wextra -std=c11 fcfs.c -o fcfs
./fcfs
```

Lab 6 adds `-pthread` for the threaded programs. Vim is the course's source editor; the
[quick reference](all_experiments/VIM-QUICK-REFERENCE.md) covers everything the labs need.

## Folder map

```text
OPERATING SYSTEMS/
  main.tex            the book: configuration and chapter list
  chapters/           the two orientation chapters, Chapters 1-10, the course map and the revision map
  labs/               10 lab sheets, each input at the end of its chapter
  all_experiments/    Lab01-Lab10, the C and shell sources each lab compiles and runs,
                      and VIM-QUICK-REFERENCE.md
```

## Building the book

From the repository root:

```bash
python .shared/build.py OS            # rebuild the book and its lab PDFs in .all_pdfs/operating-systems/
python .shared/build.py OS --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.

## Refined lab walkthroughs

10 labs now use compact visual routes, operation traces, and diagrams reused from the teaching chapters. The course fonts and shared page template are unchanged.

Full C and Bash files remain the authoritative source. Listings are divided into consecutive chunks, paired with state traces and the existing compile/run checks.

**Validation:** Thirteen portable C programs compiled with GCC -std=c11 -Wall -Wextra and ran successfully. POSIX processes, IPC, pthreads and Bash require the Linux classroom environment; no WSL distribution is installed here.

The PDF was compiled and its lab figure pages rendered for review. Preview builds used an isolated copy of the shared template with its existing unescaped `# For` prose corrected; the repository’s `.shared`, `.engine`, and `.all_pdfs` were not edited.
