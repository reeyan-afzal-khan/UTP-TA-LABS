#import "/.shared/typst/utp.typ": *
#unit("labs", "10-file-records-and-indexed-allocation")

#lab("10")[File records and indexed block allocation] <sec:lab10> #callout("labproject", title: [Separate application record format from file-system block placement])[#strong[Coverage.] Chapter~#ref(label("ch:filesystems"), supplement: none): record encoding vs. file-system allocation. \
#strong[Goal.] Create text and binary record files, then simulate an index block that points to data blocks. \
#strong[Explain.] Explain which decisions belong to the application and which belong to the file system.


#include "/OPERATING SYSTEMS/labs/visuals/10-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`text_records.c` --- Write readable employee records, reopen the file, and search by ID.]

#strong[Inspect.] `fprintf`/`fscanf` define an application-level text format. #strong[Start the file.] `text_records.c`, lines 1--29. 
#include "/OPERATING SYSTEMS/labs/visuals/10-trace.typ"
 #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/text_records.c", first: 1, last: 29, lang: "c")

#strong[Continue the same file.] `text_records.c`, lines 30--55. #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/text_records.c", first: 30, last: 55, lang: "c")

#strong[`binary_records.c` --- Write fixed C structs as binary data and search them after reopening the file.]

#strong[Inspect.] The exercise is compact but the raw struct layout is compiler/platform dependent. #strong[Start the file.] `binary_records.c`, lines 1--30. #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/binary_records.c", first: 1, last: 30, lang: "c")

#strong[Continue the same file.] `binary_records.c`, lines 31--54. #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/binary_records.c", first: 31, last: 54, lang: "c")

#strong[`indexed_allocation.c` --- Represent a small disk-block map and validate an index block plus data blocks before committing allocation.]

#strong[Inspect.] The program checks the whole request first, so a rejected file does not partially modify the map. #strong[Start the file.] `indexed_allocation.c`, lines 1--29.

#strong[Use the chapter while coding.] Revisit #link(label("ch:filesystems"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] request\_is\_valid checks the index, bounds, existing allocation and duplicate blocks before allocate\_file writes anything to used. The failed B request must not reserve its otherwise free index 4 or data block 5; C needs both later. Compare the map printed after A with the map after B, then verify that C succeeds. This is allocation validation, separate from the text and binary record encodings above. 
#include "/OPERATING SYSTEMS/labs/visuals/10-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 1, last: 29, lang: "c")

#strong[Continue the same file.] `indexed_allocation.c`, lines 30--62. #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 30, last: 62, lang: "c")

#strong[Continue the same file.] `indexed_allocation.c`, lines 63--67. #source-code("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 63, last: 67, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Create text and binary record files]
 #code-block("cd all_experiments/Lab10\ngcc -Wall -Wextra -std=c11 text_records.c -o text_records\ngcc -Wall -Wextra -std=c11 binary_records.c -o binary_records\n./text_records\n./binary_records\nls -l employees.txt students.bin\ncat employees.txt\nod -Ax -tx1z students.bin | head", lang: "bash") Compare readability, file size, and portability in a short table.


#heading(level: 2, numbering: none)[Task 2 --- Identify the layer responsible]
 For each statement, label it #strong[application] or #strong[file system]: "ID is stored before name", "file offset maps to a disk block", "salary is printed with two decimals", "an index block points to data blocks".


#heading(level: 2, numbering: none)[Task 3 --- Indexed allocation]
 #code-block("gcc -Wall -Wextra -std=c11 indexed_allocation.c -o indexed_allocation\n./indexed_allocation", lang: "bash") Explain why File B is rejected and why the block map should remain unchanged after that rejection.


#heading(level: 2, numbering: none)[Task 4 --- Controlled edit]
 Open `indexed_allocation.c` in Vim. Change File B so its data-block list no longer overlaps block 8. Predict whether it will now allocate and whether that affects File C. Recompile and verify.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Question], [Text records], [Binary records],),
    table.hline(),
    [Human-readable directly?], [], [],
    [Easy to inspect with normal text tools?], [], [],
    [Raw representation portable across systems?], [], [],
  )]
  , kind: table
  )

#callout("quickcheck", title: [Check your understanding])[+ Which decisions belong to the application record format rather than the file system?

+ Why is writing a raw C structure not a portable long-term file format?

+ What role does an index block play in indexed allocation?]

#strong[Chapter connection.] Revisit #link(label("ch:filesystems"))[the chapter explanation] and map its states to the steps below. 
#include "/OPERATING SYSTEMS/labs/visuals/10-file-records-and-indexed-allocation-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Demonstrate a valid access and an out-of-range access. Submit an invalid allocation request and confirm that the allocation bitmap remains unchanged.

- The text and binary record files are compared on readability, size and portability.

- Each of the four items is assigned to the layer responsible for it.

- File B is rejected and the block map is unchanged after the rejection.

- The before/after block map from your File B edit is explained.]]
