#import "/.shared/typst/utp.typ": *
#unit("labs", "01-linux-processes-and-directories")

#lab("1")[Processes and the Linux namespace] <sec:lab01> #callout("labproject", title: [From one executable to observable processes and directory names])[#strong[Coverage.] Chapter~#ref(label("ch:processes"), supplement: none): PID/PPID, `fork()`, directory names. \
#strong[Goal.] Run the exact supplied source and inspect live OS state. \
#strong[Explain.] Explain how one executable becomes two processes and how directory names change.


#include "/OPERATING SYSTEMS/labs/visuals/01-flow.typ"



#heading(level: 2, numbering: none)[Source code: read before you run]
 #strong[`directory_list.c` --- Open a directory stream and print every entry returned by Linux.]

#strong[Inspect.] The acquire/use/release sequence: `opendir` $arrow.r$ `readdir` loop $arrow.r$ `closedir`. #strong[Start the file.] `directory_list.c`, lines 1--33. 
#include "/OPERATING SYSTEMS/labs/visuals/01-trace.typ"
 #source-code("/OPERATING SYSTEMS/all_experiments/Lab01/directory_list.c", first: 1, last: 33, lang: "c")

#strong[Continue the same file.] `directory_list.c`, lines 34--35. #source-code("/OPERATING SYSTEMS/all_experiments/Lab01/directory_list.c", first: 34, last: 35, lang: "c")

#strong[`fork_demo.c` --- Create a child process, print process identity, optionally keep the child alive, then wait for it.]

#strong[Inspect.] The return value from `fork()`, the child's PPID, and the parent's `waitpid`. #strong[Start the file.] `fork_demo.c`, lines 1--34.

#strong[Use the chapter while coding.] Revisit #link(label("ch:processes"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Read the branch condition before attributing a line of output to parent or child. Scheduling can change print order. Use the optional delay for observation, then verify the parent waits rather than inferring behaviour from a single output ordering. 
#include "/OPERATING SYSTEMS/labs/visuals/01-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab01/fork_demo.c", first: 1, last: 34, lang: "c")

#strong[Continue the same file.] `fork_demo.c`, lines 35--51. #source-code("/OPERATING SYSTEMS/all_experiments/Lab01/fork_demo.c", first: 35, last: 51, lang: "c")

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Code region], [What it means],),
    table.hline(),
    [`opendir` / `readdir` / `closedir`], [Linux exposes directory entries through a stream-like API.],
    [`child_pid = fork()`], [One running process becomes parent + child.],
    [`child_pid == 0`], [This branch is executing in the child.],
    [`waitpid(...)`], [The parent waits and collects the child's exit status.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Task 1 --- Build a clean baseline]
 #code-block("cd all_experiments/Lab01\ngcc -Wall -Wextra -std=c11 directory_list.c -o directory_list\ngcc -Wall -Wextra -std=c11 fork_demo.c -o fork_demo\n./directory_list .\n./fork_demo", lang: "bash") Do not change the source yet. Record the parent PID, child PID, and child PPID from one run.


#heading(level: 2, numbering: none)[Task 2 --- Observe the namespace changing]
 Run `./directory_list .` after each command: #code-block("touch observation.txt\nmv observation.txt renamed.txt\nrm renamed.txt", lang: "bash") Create a four-row table: initial state, after `touch`, after `mv`, after `rm`. Record only the name that changed.


#heading(level: 2, numbering: none)[Task 3 --- Observe the parent and child while alive]
 #code-block("./fork_demo 10 &\nps -C fork_demo -o pid,ppid,state,comm\nwait", lang: "bash") Match the child's PPID to the parent's PID. The state letter can vary because scheduling is real and timing-dependent.


#heading(level: 2, numbering: none)[Task 4 --- Controlled edit in Vim]
 Open `fork_demo.c` with Vim. Change the child message so it includes the words `child branch observed`. Save, recompile, and run again.

Before running, answer: #emph[Will the parent print the new child message too?] Then explain the observed result using the idea of two processes, not only the `if` statement.

#callout("quickcheck", title: [Check your understanding])[+ Why does `fork()` produce two different return-value cases from one call?

+ How can a child process identify its parent?

+ Why can creating or renaming a file change a directory listing without changing the directory program itself?]

#strong[Chapter connection.] Revisit #link(label("ch:processes"))[the chapter explanation] and map its states to the steps below. 
#include "/OPERATING SYSTEMS/labs/visuals/01-linux-processes-and-directories-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Start a harmless long-running command, record its PID and parent, terminate only that process and confirm its exit. Explain why a second process with the same command name must remain unaffected.

- Both programs compile with `-Wall -Wextra` and run from the unchanged source first.

- The child's PPID matches the parent's PID in the `ps` output.

- The namespace table records exactly one changed name after each of `touch`, `mv` and `rm`.

- Your prediction for the Vim edit is written down before you run it, and the result is explained with two processes.]

#callout("troubleshoot", title: [Troubleshooting])[If `ps -C` shows nothing, rerun `./fork_demo 10 &` and issue `ps` before the child exits. Different PID numbers are expected on every run.]]
