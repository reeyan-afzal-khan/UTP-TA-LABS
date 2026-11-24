#import "/.shared/typst/utp.typ": *
#unit("labs", "11-hashing")

#labsection(11, label: <sec:lab11>)[Hashing and collision resolution]

#labproject[Resolve the same collision three ways][
  #note[
    #strong[Official Lab Manual --- Lab XI.] Linear, quadratic, and double-hash collision resolution.
  ]

  #strong[Goal.] Resolve identical collisions using three probe rules.

  #strong[Recall first.] Review the #link(<ch:hashing>)[Hashing] chapter.

  #strong[Complete source files.] Each program below is a separate C++17 file.
  Copy its code blocks in printed order, including headers, definitions, helpers, and `main()`.
  The line ranges refer to the supplied file; continued blocks preserve its braces and scope.
  Save each one in your `Lab11` folder and build it on its own with #strong[Ctrl+Shift+B] (#secref(<sec:build-run>)); the supplied copies are in `all_experiments/Lab11`.

  #include "programs/hashing_collisions.typ"
]

#element-head([Grow the table before it fills])

With four keys in five slots, the table in this lab is 80% full, and almost every new key will collide. Real hash tables rehash before that point: when the load factor, keys divided by slots, would pass 0.7, they allocate a larger table and insert every key again with the new size. Write `rehash` for the linear-probing table, growing it to 11 slots, and run it on 10 12 14 15. Every key should land in its home slot with a single probe: 10 in slot 10, 12 in 1, 14 in 3 and 15 in 4. Then insert 26. How many probes does it need now, and how many would it have needed in the old table of five?
