#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-files-metadata-and-cli-utilities")

= Files, Metadata, and Reliable Command-Line Utilities <ch:files-cli>

#chapterguide[Chapter 1: processes, system calls, and the Linux command line.][separate file contents from metadata, interpret file descriptors and exit status, and explain the read/write pattern used by the utilities in Lab 2.]

== Two views of a file

A regular file has #strong[contents] and #strong[metadata]. The contents are bytes. Metadata describes the object: size, permissions, timestamps, inode number, and link count.

#utpfig([Two views of a file: its contents are the bytes read with `read()` or `fread()`; its metadata, such as size, mode, inode, and link count, is read with `stat()`.], label: <fig:contents-metadata>)[
  #canvas({
    let card = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 5, min-height: 2, align: center, font: font("small", fill: navy))
    let meta = (..card, draw: orange, fill: pale-orange)
    node((-3, 0), [#strong[CONTENTS] \
  bytes read with `read()` or `fread()` \
  e.g. text, source code, records], ..card)
    node((3, 0), [#strong[METADATA] \
  size, mode, inode, links \
  read with `stat()`], ..meta)
  })
]

== The file-I/O ladder

The C standard library adds buffering and formatting; POSIX uses integer file descriptors closer to the OS interface.

#utptable[
  #tabularx(
    columns: (22%, 34%, 1fr),
    styles: (navy-bold,),
    header: ([Layer], [Typical functions], [Use in this chapter]),
    [C streams], [`fopen`, `fgets`, `fclose`], [line-oriented text search],
    [POSIX file descriptors], [`open`, `read`, `write`, `close`], [explicit file copy loop],
    [Metadata], [`stat`], [inspect size, inode, links, permissions],
  )
]

== The acquire-use-release pattern

Reliable systems code repeatedly follows the same shape:

#utpfig([The acquire-use-release pattern. A resource is opened, used, and then closed, and each step has its own failure to check.], label: <fig:acquire-use-release>)[
  #canvas({
    let s = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3, min-height: 0.85, align: center, font: font("small", fill: navy))
    let ar = (line-width: widths.thick, draw: teal, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((-4, 0), [Acquire \
  `open`/`fopen`], name: "a", ..s)
    node((0, 0), [Use \
  `read`/`fgets`], name: "b", ..s)
    node((4, 0), [Release \
  `close`/`fclose`], name: "c", ..s)
    connect("a", "b", ..ar)
    connect("b", "c", ..ar)
  })
]

Every acquire step can fail, every loop needs a clear stopping rule, and every successfully acquired resource should eventually be released.

== A correct read/write loop

`read()` can return fewer bytes than requested. Similarly, `write()` may write fewer bytes than supplied. A robust copy therefore checks return values rather than assuming one call completes the whole job.

#note[
  For systems programming, the return value is part of the data. Do not discard it: it tells you whether an operation succeeded, reached end-of-file, or failed.
]

== Exit status makes a CLI tool composable

A command-line utility should communicate to both humans and other programs. The normal convention is:

- `0`: success or requested condition found;
- non-zero: a different outcome or an error.

The supplied `mini_grep.c` uses 0 for a match, 1 for no match, and 2 for incorrect use or a file error. This is why a shell script can make decisions without parsing sentences.

== Chapter-to-lab bridge

#utptable[
  #tabularx(
    columns: (24%, 22%, 1fr),
    styles: (navy-bold,),
    header: ([Concept], [Source file], [What you will explain]),
    [Metadata], [`file_info.c`], [content is different from inode/permissions/links],
    [Low-level file I/O], [`file_copy.c`], [why loops check `read()` and `write()`],
    [CLI contract], [`mini_grep.c`], [output + exit status make a reliable tool],
  )
]
