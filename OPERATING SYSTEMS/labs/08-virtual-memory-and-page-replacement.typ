#import "/.shared/typst/utp.typ": *
#unit("labs", "08-virtual-memory-and-page-replacement")

#lab("8")[Virtual memory and page replacement] <sec:lab08> #callout("labproject", title: [Trace FIFO, LRU, and LFU using the same reference string])[#strong[Coverage.] Chapter~#ref(label("ch:vm"), supplement: none): page hits, page faults, replacement state. \
#strong[Goal.] Run three policies on one reference string so the victim rule is the only major change. \
#strong[Explain.] Justify at least one replacement decision from each policy's stored state.


#include "/OPERATING SYSTEMS/labs/visuals/08-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`fifo.c` --- Replace the page that has been resident the longest.]

#strong[Inspect.] `next` rotates through frame positions; page-use history is ignored. #strong[Start the file.] `fifo.c`, lines 1--32. 
#include "/OPERATING SYSTEMS/labs/visuals/08-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:vm"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] The pointer changes only in the fault branch. Verify hits plus faults equals the number of references. LRU needs different metadata, so do not copy FIFO's hit handling into the recency-based implementation. 
#include "/OPERATING SYSTEMS/labs/visuals/08-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab08/fifo.c", first: 1, last: 32, lang: "c")

#strong[Continue the same file.] `fifo.c`, lines 33--40. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/fifo.c", first: 33, last: 40, lang: "c")

#strong[`lru.c` --- Replace the least recently used resident page.]

#strong[Inspect.] `last_used[]` stores the most recent reference step for each frame. #strong[Start the file.] `lru.c`, lines 1--24. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/lru.c", first: 1, last: 24, lang: "c")

#strong[Continue the same file.] `lru.c`, lines 25--56. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/lru.c", first: 25, last: 56, lang: "c")

#strong[`lfu.c` --- Replace the least frequently used resident page; use recency to break ties.]

#strong[Inspect.] Two pieces of policy state are tracked: `frequency[]` and `last_used[]`. #strong[Start the file.] `lfu.c`, lines 1--25. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/lfu.c", first: 1, last: 25, lang: "c")

#strong[Continue the same file.] `lfu.c`, lines 26--58. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/lfu.c", first: 26, last: 58, lang: "c")

#strong[Continue the same file.] `lfu.c`, lines 59--61. #source-code("/OPERATING SYSTEMS/all_experiments/Lab08/lfu.c", first: 59, last: 61, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Compile and collect traces]
 #code-block("cd all_experiments/Lab08\nfor f in fifo lru lfu; do\n  gcc -Wall -Wextra -std=c11 \"$f.c\" -o \"$f\"\n  ./$f\n  echo\n done", lang: "bash") Fill in the final hit/fault totals.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Policy], [Hits], [Faults],),
    table.hline(),
    [FIFO], [], [],
    [LRU], [], [],
    [LFU], [], [],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Task 2 --- Explain one victim from each policy]
 Choose a step where all three frames are full and a fault occurs. For FIFO identify the oldest frame position; for LRU compare last-use steps; for LFU compare frequencies and then the tie-break rule if needed.


#heading(level: 2, numbering: none)[Task 3 --- Verify the beginning by hand]
 Manually trace the first six references: 7, 0, 1, 2, 0, 3. Compare your frame table with all three programs. The first few decisions should make the policies' state differences visible.


#heading(level: 2, numbering: none)[Task 4 --- Controlled edit]
 Choose one policy. In Vim change the final reference in its array from 2 to 7. Predict whether that final access is a hit or a fault for that policy, recompile, and verify.

#callout("quickcheck", title: [Check your understanding])[+ What event causes a page fault?

+ What state does LRU need that FIFO does not?

+ Why can two replacement policies choose different victims for the same reference?]

#strong[Chapter connection.] Revisit #link(label("ch:vm"))[the chapter explanation] and map its states to the steps below. 
#include "/OPERATING SYSTEMS/labs/visuals/08-virtual-memory-and-page-replacement-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Use the same reference string for all algorithms. Mark hits, faults and victims at every step and independently total faults before comparing the printed summaries.

- The final hit and fault totals are recorded for all three policies on the same reference string.

- One victim decision per policy is justified from that policy's rule.

- The first six references are traced by hand and agree with the program.

- The prediction for the final-reference edit is written down before the rerun.]]
