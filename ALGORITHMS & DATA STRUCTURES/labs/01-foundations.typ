#import "/.shared/typst/utp.typ": *
#unit("labs", "01-foundations")

#labsection(1, label: <sec:lab01>)[Programming foundations and structured records]

#labproject[Build a small record-based application][
  #note[
    #strong[Official Lab Manual --- Lab I.] Structures, unions, pointers, and 1D arrays; build a small record application.
  ]

  #strong[Goal.] Store, search, and update five student records.

  #strong[Recall first.] Review the #link(<ch:introduction>)[Introduction to Data Structures] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Build one program at a time from its `all_experiments/Lab01` folder.

  #include "programs/student_records.typ"

  #colbreak()

  #include "programs/union_review.typ"
]

#checklist[
  $square$ Every listed program compiles independently with its own `main()`. \

  $square$ Recorded outputs match the traces; no built-in check prints `[FAIL]`. \

  $square$ Explain one code-to-diagram state change and demonstrate one additional test.
]
