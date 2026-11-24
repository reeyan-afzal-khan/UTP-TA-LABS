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
  Save each one in your `Lab01` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab01`.

  #include "programs/student_records.typ"

  #include "programs/union_review.typ"
]

#element-head([One record, two kinds of grade])

Put the two programs together. Give `Student` a grade that is either a mark out of 100 or a letter: a union of `int mark` and `char letter`, plus a field that records which member was written last. Set that field every time you write the union, and read the union only through it. Give Amina (1001) the mark 78 and Chen (1003) the letter B, then extend `display` so the two rows end in `78` and `B`. Be ready to show your TA the line that stops `display` from reading `mark` out of Chen's record.
