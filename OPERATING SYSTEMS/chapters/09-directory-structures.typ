#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-directory-structures")

= Directories and the File-System Namespace <ch:directories>

#chapterguide[Chapter 2: files and metadata, especially inode numbers and permissions.][read absolute and relative paths, distinguish directory entries from inodes, compare hard and symbolic links, and follow recursive traversal in Lab 9.]

== Why directories exist

Storage blocks do not naturally come with human-friendly names such as `report.txt`. A file system therefore provides a #term[namespace]: a structured way to associate names with file-system objects.

A directory is part of that namespace. In a Unix-like file system, directory entries associate names with underlying objects identified by metadata such as inode numbers.

== From flat names to a hierarchy

Textbooks often describe several directory organizations:

- #strong[single-level:] every file shares one directory;
- #strong[two-level:] each user receives a separate directory;
- #strong[tree-structured:] directories contain files and subdirectories;
- #strong[graph-like structures:] links allow an object to be reachable through more than one path.

Modern general-purpose systems use hierarchical trees with linking mechanisms.

#utpfig([A tree-structured directory: directories contain files and further directories below a single root.], label: <fig:directory-tree>)[
  #canvas({
    let dir = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 2.6, min-height: 0.75, font: font("small", weight: "bold", fill: navy))
    let file = (draw: teal, fill: pale-teal, rounded: 1mm, min-width: 1.9, min-height: 0.65, font: font("script", fill: navy))
    node((0, 0), [root], name: "tree-1", ..dir)
    node((rel: (-4.2, -1.55), to: "tree-1"), [home], name: "tree-2", ..dir)
    connect("tree-1", "tree-2", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((rel: (-1.175, -1.55), to: "tree-2"), [notes.txt], name: "tree-3", ..file)
    connect("tree-2", "tree-3", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((rel: (1.175, -1.55), to: "tree-2"), [code.c], name: "tree-4", ..file)
    connect("tree-2", "tree-4", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((rel: (0, -1.55), to: "tree-1"), [etc], name: "tree-5", ..dir)
    connect("tree-1", "tree-5", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((rel: (0, -1.55), to: "tree-5"), [config], name: "tree-6", ..file)
    connect("tree-5", "tree-6", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
    node((rel: (4.2, -1.55), to: "tree-1"), [tmp], name: "tree-7", ..dir)
    connect("tree-1", "tree-7", draw: muted, line-width: widths.thick, end: tip("Stealth", length: 1.8mm, line: widths.thick))
  })
]

== Absolute and relative paths

An #term[absolute path] begins at the root directory, for example `/home/student/notes.txt`. A #term[relative path] begins at the process’s current working directory.

Two special names appear frequently:

- `.` means the current directory;
- `..` means the parent directory.

The shell maintains a current working directory for itself, and a child process normally inherits that starting directory.

== Pathname resolution is repeated lookup

To resolve a path such as `/home/student/notes.txt`, the system conceptually starts at the root, finds the entry named `home`, then inside that directory finds `student`, and finally finds `notes.txt`.

This is why permissions on intermediate directories matter: reaching a file requires traversing the path, not merely knowing the final filename.

== Name, metadata, and data are different layers

A filename is not the complete file. Metadata can include object type, owner, permissions, timestamps, size, link count, and pointers or mappings to data blocks.

#keyidea[
  The namespace tells us #emph[how an object is named]. Metadata tells us #emph[what the object is and its properties]. Storage allocation tells us #emph[where its bytes are represented on storage].
]

== Hard links

A hard link gives another directory entry to the same underlying inode. The two names are peers: neither is inherently the “real” name. Removing one name does not remove the file data while another hard link still refers to the inode.

The inode’s link count helps the file system track how many directory entries refer to it.

== Symbolic links

A symbolic link is a separate small file-system object whose content is a pathname. Following the link causes another pathname lookup.

#utptable[
  #tabularx(
    columns: (28%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Hard link], [Symbolic link]),
    [Underlying inode], [same inode as target], [separate inode],
    [Stores a pathname], [no], [yes],
    [Can become dangling], [not in the same way], [yes, if target path disappears],
    [Recursive traversal concern], [ordinary name to same object], [can create path-following cycles],
  )
]

== Recursive traversal

A directory walker opens a directory, reads each entry, and recursively repeats the operation for child directories. Two practical rules matter:

+ do not recurse into `.` and `..`;
+ decide deliberately whether symbolic links will be followed.

Blindly following links can revisit the same locations indefinitely if links form a cycle.

== Directory operations and consistency

Common namespace operations include create, list, rename, link, unlink, and traverse. A real file system must update its metadata consistently even if two processes act at once or a crash interrupts an update.

The lab stays at an observable introductory level: you create a small tree, inspect inode identity and links, and compare the shell’s view with a recursive C walker.

#quickcheck[
  + What is the starting point of an absolute path? A relative path?
  + Why can two different names report the same inode number?
  + Why might a directory walker choose not to follow symbolic links?
]
