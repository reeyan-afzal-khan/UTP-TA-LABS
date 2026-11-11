#import "/.shared/typst/utp.typ": *
#unit("labs", "09-directory-visualization")

#lab("9")[File-system namespace, paths, and links] <sec:lab09> #callout("labproject", title: [Build a real directory tree, inspect links, and walk it recursively])[#strong[Coverage.] Chapter~#ref(label("ch:directories"), supplement: none): paths, directory entries, inodes, hard links, symbolic links. \
#strong[Goal.] Create a small namespace containing both link types and inspect it with shell tools. \
#strong[Explain.] Explain which names share an inode and which link stores another pathname.


#include "/OPERATING SYSTEMS/labs/visuals/09-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`make_demo_tree.sh` --- Create a controlled hierarchy with one hard link and one symbolic link.]

#strong[Inspect.] `ln` and `ln -s` create different relationships even when both look like extra names. #strong[Start the file.] `make_demo_tree.sh`, lines 1--11. 
#include "/OPERATING SYSTEMS/labs/visuals/09-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:directories"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Run inside the lab's scratch tree. Read the ln commands before testing renames. The relative symlink is resolved from demo\_tree/home/student, not from whichever directory the shell currently happens to use. 
#include "/OPERATING SYSTEMS/labs/visuals/09-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab09/make_demo_tree.sh", first: 1, last: 11, lang: "bash")

#strong[`directory_walk.c` --- Recursively traverse subdirectories without following symbolic links as directories.]

#strong[Inspect.] The walker skips `.` and `..`, builds a child path, then uses `lstat()` before recursing. #strong[Start the file.] `directory_walk.c`, lines 1--32. #source-code("/OPERATING SYSTEMS/all_experiments/Lab09/directory_walk.c", first: 1, last: 32, lang: "c")

#strong[Continue the same file.] `directory_walk.c`, lines 33--47. #source-code("/OPERATING SYSTEMS/all_experiments/Lab09/directory_walk.c", first: 33, last: 47, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Create and inspect the hierarchy]
 #code-block("cd all_experiments/Lab09\nbash make_demo_tree.sh\nfind demo_tree -maxdepth 5 -print", lang: "bash") Draw the result as a small tree. Use an arrow for the symbolic link.


#heading(level: 2, numbering: none)[Task 2 --- Compare hard and symbolic links]
 #code-block("ls -li demo_tree/home/student/notes.txt \\\n       demo_tree/home/student/notes-hardlink.txt \\\n       demo_tree/home/student/code-link.c\nreadlink demo_tree/home/student/code-link.c", lang: "bash") Record name, inode number, and link count where visible.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Name], [Inode relationship], [Meaning],),
    table.hline(),
    [`notes.txt`], [], [original hard-linked object],
    [`notes-hardlink.txt`], [], [second name for same inode],
    [`code-link.c`], [], [symlink stores a pathname target],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Task 3 --- Compare shell traversal with C traversal]
 #code-block("gcc -Wall -Wextra -std=c11 directory_walk.c -o directory_walk\n./directory_walk demo_tree", lang: "bash") Check that the hierarchy agrees with `find`. Explain why the program uses `lstat()` rather than blindly following every link.


#heading(level: 2, numbering: none)[Task 4 --- Controlled namespace change]
 Create a new subdirectory and file under `demo_tree/tmp`, rerun both `find` and `directory_walk`, then remove your additions. No source-code change is required for the traversal to discover the new names.

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between a pathname and an inode?

+ Why do two hard-link names show the same inode number?

+ Why can recursively following symbolic links create a traversal problem?]

#strong[Chapter connection.] Revisit #link(label("ch:directories"))[the chapter explanation] and map its states to the steps below. 
#include "/OPERATING SYSTEMS/labs/visuals/09-directory-visualization-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Create both link types to a scratch file. Rename or remove the target name and record which accesses still work, together with inode and link-count evidence.

- The tree sketch matches what `find` reports.

- The hard link shares the original's inode number and raises its link count; the symbolic link has its own inode.

- The C walker's hierarchy agrees with `find`, and the use of `lstat()` is explained.

- Path, directory entry, inode, hard link and symbolic link are each defined in your own words.]]
