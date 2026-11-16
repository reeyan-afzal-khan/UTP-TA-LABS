#import "/.shared/typst/utp.typ": *
#unit("chapters", "10-file-organization-and-allocation")

= File Organization and Disk-Block Allocation <ch:filesystems>

#chapterguide[Chapter 2: file I/O and Chapter 9: names, inodes, and file-system objects.][separate application record formats from file-system block placement, compare text and binary records, and trace indexed allocation in Lab 10.]

== A file is a byte sequence; applications add meaning

To the operating system, a regular file can be treated as a sequence of bytes plus metadata. Applications decide how those bytes represent records such as students, employees, images, or database pages.

This gives us two layers to keep separate:

- #strong[application organization:] how fields and records are encoded inside the file;
- #strong[file-system allocation:] how logical file blocks are mapped onto storage.

== Text and binary records

Text formats convert values into readable characters. Binary formats can store compact machine-oriented representations.

#utptable[
  #tabularx(
    columns: (19%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Format], [Strength], [Caution]),
    [Text], [readable with ordinary tools, easy to exchange], [parsing and formatting add overhead],
    [Raw C struct], [compact and easy for a controlled exercise], [padding, endianness, and type sizes can reduce portability],
  )
]

#warning[
  “Binary” does not automatically mean “better.” A durable binary format normally defines its byte layout explicitly instead of simply dumping a compiler-dependent in-memory structure.
]

== Sequential access and sequential search

A small record file can be searched by reading one record after another until the key is found. This is easy to implement and understand, but the worst case may inspect every record.

Larger systems introduce indexes so a key can point more directly to the needed location. The idea is similar to a book index: extra structure is maintained so lookup does not require scanning every page.

== Logical blocks and physical placement

A file system commonly views a file as logical blocks numbered 0, 1, 2, and so on. The allocation method determines where those logical blocks are stored physically.

== Contiguous allocation

All file blocks occupy consecutive storage blocks. Sequential and random access are simple, but file growth can be difficult when the following physical blocks are already occupied.

== Linked allocation

Each allocated block identifies the next block in the file. Files can grow without requiring adjacent space, but following a long chain is inefficient for direct/random access and damaged pointers are a concern.

== Indexed allocation

A separate index block stores references to the file’s data blocks. Logical block 0 can be found through the first index entry, logical block 1 through the second, and so on. The data blocks themselves do not need to be adjacent.

#utpfig([Indexed allocation. Index block 7 lists the file’s data blocks in logical order, so the blocks themselves need not be adjacent.], label: <fig:indexed-allocation>)[
  #canvas({
    let b = (draw: blue, fill: pale-blue, rounded: 1mm, min-width: 2.2, min-height: 0.7, font: font("small", weight: "bold", fill: navy))
    let d = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 1.7, min-height: 0.65, font: font("script", fill: navy))
    let arr = (draw: muted, line-width: widths.thick, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((0, 0), [Index block 7], name: "idx", ..b)
    node(right-of("idx", 2.2), [block 12], name: "d1", ..d, yshift: 1cm)
    node(right-of("idx", 2.2), [block 19], name: "d2", ..d)
    node(right-of("idx", 2.2), [block 31], name: "d3", ..d, yshift: -1cm)
    connect("idx", "d1", ..arr)
    connect("idx", "d2", ..arr)
    connect("idx", "d3", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (18%, 40%, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Main advantage], [Main limitation]),
    [Contiguous], [simple, efficient direct access], [growth and external fragmentation],
    [Linked], [easy growth without contiguous space], [poor direct access],
    [Indexed], [direct access without contiguous data blocks], [index-space overhead],
  )
]

== Free-space management

A file system also needs to know which storage blocks are free. A bitmap is one common idea: each bit records whether one block is free or allocated. Other structures can use lists or grouped free blocks.

The Lab 10 simulator uses a simple integer array as an easy-to-see allocation map. It is a model, not a complete disk file system.

== Validate first, commit second

Suppose a request needs one index block and three data blocks. If the program marks the first two blocks as used and only later discovers that the third is unavailable, it has partially changed state.

A safer introductory pattern is:

+ validate the complete request without modifying shared state;
+ if every block is valid and free, commit all allocation changes;
+ otherwise, leave the map unchanged.

This transaction-like reasoning appears throughout systems software.

== Durability and crash consistency

Real file systems must survive interruptions during metadata updates. Techniques such as journaling, copy-on-write, checksums, and careful write ordering help prevent inconsistent states after a crash. These mechanisms are beyond the Lab 10 implementation, but the validate-then-commit habit is an accessible first step toward the same design concern.

== Keep the layers separate

When an application stores a student record, it decides which bytes represent the ID, name, and GPA. When the file system stores the file, it decides how file offsets map to blocks. One file can change its physical allocation without changing its application record format.

#questions[
  + Which layer decides how an employee record is encoded?
  + Which allocation method uses a dedicated block of pointers?
  + Why should a multi-block allocation request be fully checked before state is modified?
]
