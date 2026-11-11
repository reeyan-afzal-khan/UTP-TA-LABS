#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-files-metadata-and-cli-utilities")


#heading(level: 1)[Files, Metadata, and Reliable Command-Line Utilities]
<ch:files-cli> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 1: processes, system calls, and the Linux command line.

*By the end, you can:* separate file contents from metadata, interpret file descriptors and exit status, and explain the read/write pattern used by the utilities in Lab 2.]


#heading(level: 2)[Two views of a file]
 A regular file has #strong[contents] and #strong[metadata]. The contents are bytes. Metadata describes the object: size, permissions, timestamps, inode number, and link count.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/OPERATING SYSTEMS/figures/diagrams/5d79b5474c9e8b35.svg")], caption: [Two views of a file: its contents are the bytes read with `read()` or `fread()`; its metadata, such as size, mode, inode, and link count, is read with `stat()`.]) <fig:contents-metadata>


#heading(level: 2)[The file-I/O ladder]
 The C standard library adds buffering and formatting; POSIX uses integer file descriptors closer to the OS interface.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Layer], [Typical functions], [Use in this chapter],),
    table.hline(),
    [C streams], [`fopen`, `fgets`, `fclose`], [line-oriented text search],
    [POSIX file descriptors], [`open`, `read`, `write`, `close`], [explicit file copy loop],
    [Metadata], [`stat`], [inspect size, inode, links, permissions],
  )]
  , kind: table
  )


#heading(level: 2)[The acquire-use-release pattern]
 Reliable systems code repeatedly follows the same shape:

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/OPERATING SYSTEMS/figures/diagrams/094395bcf0b1e5a1.svg")], caption: [The acquire-use-release pattern. A resource is opened, used, and then closed, and each step has its own failure to check.]) <fig:acquire-use-release>

Every acquire step can fail, every loop needs a clear stopping rule, and every successfully acquired resource should eventually be released.


#heading(level: 2)[A correct read/write loop]
 `read()` can return fewer bytes than requested. Similarly, `write()` may write fewer bytes than supplied. A robust copy therefore checks return values rather than assuming one call completes the whole job.

#callout("keyidea", title: [Key idea])[For systems programming, the return value is part of the data. Do not discard it: it tells you whether an operation succeeded, reached end-of-file, or failed.]


#heading(level: 2)[Exit status makes a CLI tool composable]
 A command-line utility should communicate to both humans and other programs. The normal convention is:

- `0`: success or requested condition found;

- non-zero: a different outcome or an error.

The supplied `mini_grep.c` uses 0 for a match, 1 for no match, and 2 for incorrect use or a file error. This is why a shell script can make decisions without parsing sentences.


#heading(level: 2)[Chapter-to-lab bridge]
 #figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Concept], [Source file], [What you will explain],),
    table.hline(),
    [Metadata], [`file_info.c`], [content is different from inode/permissions/links],
    [Low-level file I/O], [`file_copy.c`], [why loops check `read()` and `write()`],
    [CLI contract], [`mini_grep.c`], [output + exit status make a reliable tool],
  )]
  , kind: table
  )
