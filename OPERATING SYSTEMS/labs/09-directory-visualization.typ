#import "/.shared/typst/utp.typ": *
#unit("labs", "09-directory-visualization")

#labsection(9, label: <sec:lab09>)[File-system namespace, paths, and links]

#labproject[Build a real directory tree, inspect links, and walk it recursively][
  #strong[Coverage.] Chapter~#ref(<ch:directories>): paths, directory entries, inodes, hard links, symbolic links. \

  #strong[Goal.] Create a small namespace containing both link types and inspect it with shell tools. \

  #strong[Explain.] Explain which names share an inode and which link stores another pathname.

  #include "visuals/09-flow.typ"

  #heading(depth: 2, numbering: none)[Source code]

  #labsourcecard[`make_demo_tree.sh`][Create a controlled hierarchy with one hard link and one symbolic link.][`ln` and `ln -s` create different relationships even when both look like extra names.]

  #strong[Start the file.] `make_demo_tree.sh`, lines 1--11.

  #include "visuals/09-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:directories>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Run inside the lab’s scratch tree. Read the ln commands before testing renames. The relative symlink is resolved from demo\_tree/home/student, not from whichever directory the shell currently happens to use.

  #include "visuals/09-worked-case.typ"

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab09/make_demo_tree.sh", first: 1, last: 11, lang: "bash")]

  #labsourcecard[`directory_walk.c`][Recursively traverse subdirectories without following symbolic links as directories.][The walker skips `.` and `..`, builds a child path, then uses `lstat()` before recursing.]

  #strong[Start the file.] `directory_walk.c`, lines 1--32.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab09/directory_walk.c", first: 1, last: 32, lang: "c")]

  #strong[Continue the same file.] `directory_walk.c`, lines 33--47.

  #numbered[#lstinput("/OPERATING SYSTEMS/all_experiments/Lab09/directory_walk.c", first: 33, last: 47, lang: "c")]

  #heading(depth: 2, numbering: none)[Task 1 --- Create and inspect the hierarchy]

  ```bash
  cd all_experiments/Lab09
  bash make_demo_tree.sh
  find demo_tree -maxdepth 5 -print
  ```

  Draw the result as a small tree. Use an arrow for the symbolic link.

  #heading(depth: 2, numbering: none)[Task 2 --- Compare hard and symbolic links]

  ```bash
  ls -li demo_tree/home/student/notes.txt \
         demo_tree/home/student/notes-hardlink.txt \
         demo_tree/home/student/code-link.c
  readlink demo_tree/home/student/code-link.c
  ```

  Record name, inode number, and link count where visible.

  #utptable[
    #tabularx(
      columns: (32%, 25%, 1fr),
      styles: (navy-bold,),
      header: ([Name], [Inode relationship], [Meaning]),
      [`notes.txt`], [], [original hard-linked object],
      [`notes-hardlink.txt`], [], [second name for same inode],
      [`code-link.c`], [], [symlink stores a pathname target],
    )
  ]

  #heading(depth: 2, numbering: none)[Task 3 --- Compare shell traversal with C traversal]

  ```bash
  gcc -Wall -Wextra -std=c11 directory_walk.c -o directory_walk
  ./directory_walk demo_tree
  ```

  Check that the hierarchy agrees with `find`. Explain why the program uses `lstat()` rather than blindly following every link.

  #heading(depth: 2, numbering: none)[Task 4 --- Controlled namespace change]

  Create a new subdirectory and file under `demo_tree/tmp`, rerun both `find` and `directory_walk`, then remove your additions. No source-code change is required for the traversal to discover the new names.

  #questions[
    + What is the difference between a pathname and an inode?
    + Why do two hard-link names show the same inode number?
    + Why can recursively following symbolic links create a traversal problem?
  ]

  #strong[Chapter connection.] Revisit #link(<ch:directories>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/09-directory-visualization-chapter.typ"

  #checklist[
    #strong[Explain and extend your result.] Create both link types to a scratch file. Rename or remove the target name and record which accesses still work, together with inode and link-count evidence.

    - The tree sketch matches what `find` reports.
    - The hard link shares the original’s inode number and raises its link count; the symbolic link has its own inode.
    - The C walker’s hierarchy agrees with `find`, and the use of `lstat()` is explained.
    - Path, directory entry, inode, hard link and symbolic link are each defined in your own words.
  ]
]
