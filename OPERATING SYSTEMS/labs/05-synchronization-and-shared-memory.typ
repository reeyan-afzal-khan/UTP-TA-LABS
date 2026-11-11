#import "/.shared/typst/utp.typ": *
#unit("labs", "05-synchronization-and-shared-memory")

#lab("5")[Interprocess communication and synchronization] <sec:lab05> #callout("labproject", title: [Compare a pipe, shared memory, and producer-consumer state])[#strong[Coverage.] Chapter~#ref(label("ch:ipc"), supplement: none): IPC models, shared state, synchronization conditions. \
#strong[Goal.] Move one message through a pipe and another through a shared-memory segment. \
#strong[Explain.] Explain who owns each communication object and why shared memory needs separate synchronization.


#include "/OPERATING SYSTEMS/labs/visuals/05-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`pipe_demo.c` --- Parent writes bytes; child reads them through a unidirectional pipe.]

#strong[Inspect.] Each process closes the pipe end it does not use. Closing the write end is also how end-of-stream can be signalled. #strong[Start the file.] `pipe_demo.c`, lines 1--33. 
#include "/OPERATING SYSTEMS/labs/visuals/05-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:ipc"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Map each close to its owner. The supplied example sends one short message and performs one read; a general stream reader would handle partial transfers in a loop. Do not interpret a single successful short read as a guarantee for arbitrary message sizes. 
#include "/OPERATING SYSTEMS/labs/visuals/05-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab05/pipe_demo.c", first: 1, last: 33, lang: "c")

#strong[Continue the same file.] `pipe_demo.c`, lines 34--43. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/pipe_demo.c", first: 34, last: 43, lang: "c")

#strong[`producer_consumer_sim.c` --- Make full/empty buffer state visible without threads yet.]

#strong[Inspect.] The invariant is `empty + full = CAPACITY`; blocked operations do not change the counters. #strong[Start the file.] `producer_consumer_sim.c`, lines 1--33. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/producer_consumer_sim.c", first: 1, last: 33, lang: "c")

#strong[Continue the same file.] `producer_consumer_sim.c`, lines 34--39. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/producer_consumer_sim.c", first: 34, last: 39, lang: "c")

#strong[`shm_writer.c` --- Create/attach a System V shared-memory segment and place a message in it.]

#strong[Inspect.] The writer detaches but deliberately leaves the segment available for another process. #strong[Start the file.] `shm_writer.c`, lines 1--32. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/shm_writer.c", first: 1, last: 32, lang: "c")

#strong[Continue the same file.] `shm_writer.c`, lines 33--40. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/shm_writer.c", first: 33, last: 40, lang: "c")

#strong[`shm_reader.c` --- Attach to the existing segment, read the message, then mark the segment for removal.]

#strong[Inspect.] The reader demonstrates cleanup with `shmdt()` and `shmctl(..., IPC_RMID,...)`. #strong[Start the file.] `shm_reader.c`, lines 1--34. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/shm_reader.c", first: 1, last: 34, lang: "c")

#strong[Continue the same file.] `shm_reader.c`, lines 35--42. #source-code("/OPERATING SYSTEMS/all_experiments/Lab05/shm_reader.c", first: 35, last: 42, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Pipe: follow the data path]
 #code-block("cd all_experiments/Lab05\ngcc -Wall -Wextra -std=c11 pipe_demo.c -o pipe_demo\n./pipe_demo", lang: "bash") Draw one arrow from parent to kernel pipe to child. Label which file descriptor end each process closes.


#heading(level: 2, numbering: none)[Task 2 --- Producer/consumer state]
 #code-block("gcc -Wall -Wextra -std=c11 producer_consumer_sim.c -o producer_consumer_sim\n./producer_consumer_sim", lang: "bash") For every row, verify `empty + full = 3`. Circle the first blocked produce and first blocked consume. Explain why the counters do not change on a blocked action.


#heading(level: 2, numbering: none)[Task 3 --- Shared-memory lifecycle]
 #code-block("gcc -Wall -Wextra -std=c11 shm_writer.c -o shm_writer\ngcc -Wall -Wextra -std=c11 shm_reader.c -o shm_reader\n./shm_writer\nipcs -m\n./shm_reader\nipcs -m", lang: "bash") Record the segment ID after the writer and check whether it remains after the reader marks it for removal.


#heading(level: 2, numbering: none)[Task 4 --- Failure case]
 Run `./shm_reader` again after the segment has been removed. The failure is intentional. Explain why a clear error message is better than creating a new empty segment in the reader.

#callout("quickcheck", title: [Check your understanding])[+ How is a pipe different from shared memory?

+ What makes a section of code a critical section?

+ Why can two correct operations still produce an incorrect result when they race?]

#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Annotate ownership of every descriptor after fork. Explain which close allows EOF, then verify that the complete message arrives and the processes exit without leftover IPC resources.

- Each process closes the pipe end it does not use, and the sketch shows which.

- Every producer/consumer row satisfies `empty + full = 3`, and blocked actions leave the counters unchanged.

- The shared-memory segment ID is recorded after the writer, and its removal is confirmed with `ipcs -m`.

- The pipe and shared memory are compared on data movement, lifetime and synchronization.]]
