#import "/.shared/typst/utp.typ": *
#unit("labs", "01-linux-processes-and-directories")

#labsection(1, label: <sec:lab01>)[Processes and the Linux namespace]

#labproject[From one executable to observable processes and directory names][
  #strong[Coverage.] Chapter~#ref(<ch:processes>): PID/PPID, `fork()`, directory names. \

  #strong[Goal.] Run the exact supplied source and inspect live OS state. \

  #strong[Explain.] Explain how one executable becomes two processes and how directory names change.

  #include "visuals/01-flow.typ"

  #heading(depth: 2, numbering: none)[Source code: read before you run]

  #labsourcecard[`directory_list.c`][Open a directory stream and print every entry returned by Linux.][The acquire/use/release sequence: `opendir` $arrow.r$ `readdir` loop $arrow.r$ `closedir`.]

  #strong[Start the file.] `directory_list.c`, lines 1--33.

  #include "visuals/01-trace.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab01/directory_list.c", first: 1, last: 33, lang: "c")]

  #strong[Continue the same file.] `directory_list.c`, lines 34--35.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab01/directory_list.c", first: 34, last: 35, lang: "c")]

  #labsourcecard[`fork_demo.c`][Create a child process, print process identity, optionally keep the child alive, then wait for it.][The return value from `fork()`, the child’s PPID, and the parent’s `waitpid`.]

  #strong[Start the file.] `fork_demo.c`, lines 1--34.

  #strong[Use the chapter while coding.] Revisit #link(<ch:processes>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Read the branch condition before attributing a line of output to parent or child. Scheduling can change print order. Use the optional delay for observation, then verify the parent waits rather than inferring behaviour from a single output ordering.

  #include "visuals/01-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab01/fork_demo.c", first: 1, last: 34, lang: "c")]

  #strong[Continue the same file.] `fork_demo.c`, lines 35--51.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab01/fork_demo.c", first: 35, last: 51, lang: "c")]

  #utptable[
    #tabularx(
      columns: (34%, 1fr),
      styles: (navy-bold,),
      header: ([Code region], [What it means]),
      [`opendir` / `readdir` / `closedir`], [Linux exposes directory entries through a stream-like API.],
      [`child_pid = fork()`], [One running process becomes parent + child.],
      [`child_pid == 0`], [This branch is executing in the child.],
      [`waitpid(...)`], [The parent waits and collects the child’s exit status.],
    )
  ]

  #heading(depth: 2, numbering: none)[Task 1 --- Build a clean baseline]

  ```bash
  cd all_experiments/Lab01
  gcc -Wall -Wextra -std=c11 directory_list.c -o directory_list
  gcc -Wall -Wextra -std=c11 fork_demo.c -o fork_demo
  ./directory_list .
  ./fork_demo
  ```

  Do not change the source yet. Record the parent PID, child PID, and child PPID from one run.

  #heading(depth: 2, numbering: none)[Task 2 --- Observe the namespace changing]

  Run `./directory_list .` after each command:

  ```bash
  touch observation.txt
  mv observation.txt renamed.txt
  rm renamed.txt
  ```

  Create a four-row table: initial state, after `touch`, after `mv`, after `rm`. Record only the name that changed.

  #heading(depth: 2, numbering: none)[Task 3 --- Observe the parent and child while alive]

  ```bash
  ./fork_demo 10 &
  ps -C fork_demo -o pid,ppid,state,comm
  wait
  ```

  Match the child’s PPID to the parent’s PID. The state letter can vary because scheduling is real and timing-dependent.

  #heading(depth: 2, numbering: none)[Task 4 --- Controlled edit in Vim]

  Open `fork_demo.c` with Vim. Change the child message so it includes the words `child branch observed`. Save, recompile, and run again.

  Before running, answer: #emph[Will the parent print the new child message too?] Then explain the observed result using the idea of two processes, not only the `if` statement.

  #quickcheck[
    + Why does `fork()` produce two different return-value cases from one call?
    + How can a child process identify its parent?
    + Why can creating or renaming a file change a directory listing without changing the directory program itself?
  ]

  #strong[Chapter connection.] Revisit #link(<ch:processes>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/01-linux-processes-and-directories-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Start a harmless long-running command, record its PID and parent, terminate only that process and confirm its exit. Explain why a second process with the same command name must remain unaffected.

    - Both programs compile with `-Wall -Wextra` and run from the unchanged source first.
    - The child’s PPID matches the parent’s PID in the `ps` output.
    - The namespace table records exactly one changed name after each of `touch`, `mv` and `rm`.
    - Your prediction for the Vim edit is written down before you run it, and the result is explained with two processes.
  ]

  #troubleshoot[
    If `ps -C` shows nothing, rerun `./fork_demo 10 &` and issue `ps` before the child exits. Different PID numbers are expected on every run.
  ]
]
