#import "/.shared/typst/utp.typ": *
#unit("labs", "10-file-records-and-indexed-allocation")

#labsection(10, label: <sec:lab10>)[File records and indexed block allocation]

#labproject[Separate application record format from file-system block placement][
  #strong[Coverage.] Chapter~#ref(<ch:filesystems>): record encoding vs. file-system allocation. \

  #strong[Goal.] Create text and binary record files, then simulate an index block that points to data blocks. \

  #strong[Explain.] Explain which decisions belong to the application and which belong to the file system.

  #include "visuals/10-flow.typ"

  #heading(depth: 2, numbering: none)[Source code]

  #labsourcecard[`text_records.c`][Write readable employee records, reopen the file, and search by ID.][`fprintf`/`fscanf` define an application-level text format.]

  #strong[Start the file.] `text_records.c`, lines 1--29.

  #include "visuals/10-trace.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/text_records.c", first: 1, last: 29, lang: "c")]

  #strong[Continue the same file.] `text_records.c`, lines 30--55.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/text_records.c", first: 30, last: 55, lang: "c")]

  #labsourcecard[`binary_records.c`][Write fixed C structs as binary data and search them after reopening the file.][The exercise is compact but the raw struct layout is compiler/platform dependent.]

  #strong[Start the file.] `binary_records.c`, lines 1--30.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/binary_records.c", first: 1, last: 30, lang: "c")]

  #strong[Continue the same file.] `binary_records.c`, lines 31--54.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/binary_records.c", first: 31, last: 54, lang: "c")]

  #labsourcecard[`indexed_allocation.c`][Represent a small disk-block map and validate an index block plus data blocks before committing allocation.][The program checks the whole request first, so a rejected file does not partially modify the map.]

  #strong[Start the file.] `indexed_allocation.c`, lines 1--29.

  #strong[Use the chapter while coding.] Revisit #link(<ch:filesystems>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] request\_is\_valid checks the index, bounds, existing allocation and duplicate blocks before allocate\_file writes anything to used. The failed B request must not reserve its otherwise free index 4 or data block 5; C needs both later. Compare the map printed after A with the map after B, then verify that C succeeds. This is allocation validation, separate from the text and binary record encodings above.

  #include "visuals/10-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 1, last: 29, lang: "c")]

  #strong[Continue the same file.] `indexed_allocation.c`, lines 30--62.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 30, last: 62, lang: "c")]

  #strong[Continue the same file.] `indexed_allocation.c`, lines 63--67.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab10/indexed_allocation.c", first: 63, last: 67, lang: "c")]

  #heading(depth: 2, numbering: none)[Task 1 --- Create text and binary record files]

  ```bash
  cd all_experiments/Lab10
  gcc -Wall -Wextra -std=c11 text_records.c -o text_records
  gcc -Wall -Wextra -std=c11 binary_records.c -o binary_records
  ./text_records
  ./binary_records
  ls -l employees.txt students.bin
  cat employees.txt
  od -Ax -tx1z students.bin | head
  ```

  Compare readability, file size, and portability in a short table.

  #heading(depth: 2, numbering: none)[Task 2 --- Identify the layer responsible]

  For each statement, label it #strong[application] or #strong[file system]: “ID is stored before name”, “file offset maps to a disk block”, “salary is printed with two decimals”, “an index block points to data blocks”.

  #heading(depth: 2, numbering: none)[Task 3 --- Indexed allocation]

  ```bash
  gcc -Wall -Wextra -std=c11 indexed_allocation.c -o indexed_allocation
  ./indexed_allocation
  ```

  Explain why File B is rejected and why the block map should remain unchanged after that rejection.

  #heading(depth: 2, numbering: none)[Task 4 --- Controlled edit]

  Open `indexed_allocation.c` in Vim. Change File B so its data-block list no longer overlaps block 8. Predict whether it will now allocate and whether that affects File C. Recompile and verify.

  #utptable[
    #tabularx(
      columns: (42%, 1fr, 1fr),
      styles: (navy-bold,),
      header: ([Question], [Text records], [Binary records]),
      [Human-readable directly?], [], [],
      [Easy to inspect with normal text tools?], [], [],
      [Raw representation portable across systems?], [], [],
    )
  ]

  #quickcheck[
    + Which decisions belong to the application record format rather than the file system?
    + Why is writing a raw C structure not a portable long-term file format?
    + What role does an index block play in indexed allocation?
  ]

  #strong[Chapter connection.] Revisit #link(<ch:filesystems>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/10-file-records-and-indexed-allocation-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Demonstrate a valid access and an out-of-range access. Submit an invalid allocation request and confirm that the allocation bitmap remains unchanged.

    - The text and binary record files are compared on readability, size and portability.
    - Each of the four items is assigned to the layer responsible for it.
    - File B is rejected and the block map is unchanged after the rejection.
    - The before/after block map from your File B edit is explained.
  ]
]
