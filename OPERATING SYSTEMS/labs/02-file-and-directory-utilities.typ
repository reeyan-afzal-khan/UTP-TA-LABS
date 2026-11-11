#import "/.shared/typst/utp.typ": *
#unit("labs", "02-file-and-directory-utilities")

#lab("2")[Files, metadata, and reliable CLI utilities] <sec:lab02> #callout("labproject", title: [Read file metadata, copy bytes safely, and report search status])[#strong[Coverage.] Chapter~#ref(label("ch:files-cli"), supplement: none): contents vs. metadata, file descriptors, exit status. \
#strong[Goal.] Run three small utilities and verify them with standard Linux commands. \
#strong[Explain.] Explain what each utility promises to the user and how it reports failure.


#include "/OPERATING SYSTEMS/labs/visuals/02-flow.typ"



#heading(level: 2, numbering: none)[Source code]
 #strong[`file_info.c` --- Read metadata with `stat()`.]

#strong[Inspect.] The program does not read the file's contents; it reads information #emph[about] the file. #strong[Start the file.] `file_info.c`, lines 1--32. 
#include "/OPERATING SYSTEMS/labs/visuals/02-trace.typ"
 #strong[Use the chapter while coding.] Revisit #link(label("ch:files-cli"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Follow the early returns before reading the printed metadata. With no argument, the program shows usage; with a nonexistent path, stat fails; with a valid path, the populated struct is inspected. Inode numbers are machine-specific and should be compared within your own run. Test all three branches and record the exit status immediately after each command. 
#include "/OPERATING SYSTEMS/labs/visuals/02-worked-case.typ"


#source-code("/OPERATING SYSTEMS/all_experiments/Lab02/file_info.c", first: 1, last: 32, lang: "c")

#strong[`file_copy.c` --- Copy bytes using POSIX file descriptors.]

#strong[Inspect.] The outer loop reads chunks; the inner loop handles a write that may complete only part of a chunk. #strong[Start the file.] `file_copy.c`, lines 1--31. #source-code("/OPERATING SYSTEMS/all_experiments/Lab02/file_copy.c", first: 1, last: 31, lang: "c")

#strong[Continue the same file.] `file_copy.c`, lines 32--63. #source-code("/OPERATING SYSTEMS/all_experiments/Lab02/file_copy.c", first: 32, last: 63, lang: "c")

#strong[`mini_grep.c` --- Search a text file and return a useful exit status.]

#strong[Inspect.] `0`=match, `1`=no match, `2`=usage/file error. #strong[Start the file.] `mini_grep.c`, lines 1--30. #source-code("/OPERATING SYSTEMS/all_experiments/Lab02/mini_grep.c", first: 1, last: 30, lang: "c")

#strong[Continue the same file.] `mini_grep.c`, lines 31--39. #source-code("/OPERATING SYSTEMS/all_experiments/Lab02/mini_grep.c", first: 31, last: 39, lang: "c")


#heading(level: 2, numbering: none)[Task 1 --- Build and inspect metadata]
 #code-block("cd all_experiments/Lab02\ngcc -Wall -Wextra -std=c11 file_info.c -o file_info\ngcc -Wall -Wextra -std=c11 file_copy.c -o file_copy\ngcc -Wall -Wextra -std=c11 mini_grep.c -o mini_grep\n./file_info sample.txt\nstat sample.txt", lang: "bash") Match at least three fields between the program and `stat`: size, inode, link count, or permissions.


#heading(level: 2, numbering: none)[Task 2 --- Verify the copy, not just the message]
 #code-block("./file_copy sample.txt copy.txt\ncmp sample.txt copy.txt\necho $?\nls -l sample.txt copy.txt", lang: "bash") A `cmp` status of 0 is independent evidence that the byte contents are equal.


#heading(level: 2, numbering: none)[Task 3 --- Treat exit status as part of the interface]
 #code-block("./mini_grep kernel sample.txt; echo \"status=$?\"\n./mini_grep pineapple sample.txt; echo \"status=$?\"\n./mini_grep kernel missing.txt; echo \"status=$?\"", lang: "bash") Create a three-row table: command, visible output, exit status, meaning.


#heading(level: 2, numbering: none)[Task 4 --- Controlled edit in Vim]
 Open `mini_grep.c`. Change the match output from `FILE:LINE: text` to begin with `MATCH `. Save, recompile, and confirm that the exit status rules did not change.

#callout("keyidea", title: [Key idea])[A professional CLI tool has two audiences: a person reads its output; another program can read its exit status.]

#callout("quickcheck", title: [Check your understanding])[+ Which information belongs to file metadata rather than file contents?

+ Why must a copy program check the return value from `read()` and `write()`?

+ Why is exit status useful even when a command already prints a message?]

#strong[Chapter connection.] Revisit #link(label("ch:files-cli"))[the chapter explanation] and map its states to the steps below. 
#include "/OPERATING SYSTEMS/labs/visuals/02-file-and-directory-utilities-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Use a small scratch input with repeated and blank lines. Predict each pipeline stage, run it and compare the final counts with a manual tally.

- At least three metadata fields from `file_info` match `stat`.

- `cmp` returns status~0 for the original and the copy.

- `mini_grep` returns 0 for a match, 1 for no match, and 2 for a missing file.

- After the Vim edit the output begins with `MATCH` and the exit-status rules are unchanged.]]
