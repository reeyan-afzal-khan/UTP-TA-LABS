#import "/.shared/typst/utp.typ": *
#unit("labs", "07-memory-allocation")

#lab("7")[Contiguous memory allocation and fragmentation] <sec:lab07> #callout("labproject", title: [Compare First Fit, Best Fit, and Worst Fit on the same requests])[#strong[Coverage.] Chapter~#ref(label("ch:allocation"), supplement: none): holes, requests, placement rules, external fragmentation. \
#strong[Goal.] Watch the free-hole list after every allocation. \
#strong[Explain.] Explain how an early placement changes whether later requests can fit.


#include "/OPERATING SYSTEMS/labs/visuals/07-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`first_fit.c` --- Choose the first hole that is large enough.]

#strong[Inspect.] The search stops immediately when a suitable hole is found. #strong[Start the file.] `first_fit.c`, lines 1--28. 
#include "/OPERATING SYSTEMS/labs/visuals/07-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:allocation"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] choice is a zero-based index and starts at -1 for each request. The break selects the first eligible hole. Update only the chosen hole, and compare the unchanged map before and after the failed request. 
#include "/OPERATING SYSTEMS/labs/visuals/07-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab07/first_fit.c", first: 1, last: 28, lang: "c")

#strong[Continue the same file.] `first_fit.c`, lines 29--41. #source-code("/OPERATING SYSTEMS/all_experiments/Lab07/first_fit.c", first: 29, last: 41, lang: "c")

#strong[`best_fit.c` --- Choose the smallest hole that can satisfy the request.]

#strong[Inspect.] The whole hole list must be scanned to find the tightest fit. #strong[Start the file.] `best_fit.c`, lines 1--28. #source-code("/OPERATING SYSTEMS/all_experiments/Lab07/best_fit.c", first: 1, last: 28, lang: "c")

#strong[Continue the same file.] `best_fit.c`, lines 29--41. #source-code("/OPERATING SYSTEMS/all_experiments/Lab07/best_fit.c", first: 29, last: 41, lang: "c")

#strong[`worst_fit.c` --- Choose the largest suitable hole.]

#strong[Inspect.] The policy tries to leave a relatively large remainder, but the future workload still decides whether that helps. #strong[Start the file.] `worst_fit.c`, lines 1--28. #source-code("/OPERATING SYSTEMS/all_experiments/Lab07/worst_fit.c", first: 1, last: 28, lang: "c")

#strong[Continue the same file.] `worst_fit.c`, lines 29--41. #source-code("/OPERATING SYSTEMS/all_experiments/Lab07/worst_fit.c", first: 29, last: 41, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Compile and run]
 #code-block("cd all_experiments/Lab07\nfor f in first_fit best_fit worst_fit; do\n  gcc -Wall -Wextra -std=c11 \"$f.c\" -o \"$f\"\n  ./$f\n  echo\n done", lang: "bash")

For each policy, copy the hole list after every request. Do not compare only the final line; the intermediate state is the algorithm.


#heading(level: 2, numbering: none)[Task 2 --- Visual comparison]
 Use the same starting holes: 100, 500, 200, 300, 600. Shade the selected hole for the first request (212) under each policy.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Policy], [Hole chosen for 212], [Remainder created], [Later consequence],),
    table.hline(),
    [First Fit], [], [], [],
    [Best Fit], [], [], [],
    [Worst Fit], [], [], [],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Task 3 --- Independent verification]
 Before looking at the program's second line of output, manually choose a hole for request 417 using each policy. Then compare your prediction with the code.


#heading(level: 2, numbering: none)[Task 4 --- Controlled edit]
 Pick one of the three programs. Open it in Vim and change the final request from 426 to 250. Predict whether that request will now fit and which hole will be selected. Recompile and check your prediction.

#callout("keyidea", title: [Key idea])["Best Fit" is the name of a rule, not a guarantee of the best final memory layout. Every policy is making a decision without knowing future requests.]

#callout("quickcheck", title: [Check your understanding])[+ What is external fragmentation?

+ Why can two placement policies leave different hole lists after the same request?

+ Why does a request sometimes fail even when the total free memory is large enough?]

#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Trace the first two requests by hand for each policy. Report remaining hole sizes and distinguish failed placement from exhaustion of total free memory.

- The hole list is recorded after every request for each policy, not only the final line.

- The hole chosen for the first request is compared across the three policies.

- Your manual prediction for request 417 matches the program.

- The before/after result of the 426 $arrow.r$ 250 edit is explained.]]
