#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-directory-structures")


#heading(level: 1)[Directories and the File-System Namespace]
<ch:directories> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 2: files and metadata, especially inode numbers and permissions.

*By the end, you can:* read absolute and relative paths, distinguish directory entries from inodes, compare hard and symbolic links, and follow recursive traversal in Lab 9.]


#heading(level: 2)[Why directories exist]
 Storage blocks do not naturally come with human-friendly names such as `report.txt`. A file system therefore provides a #strong[namespace]: a structured way to associate names with file-system objects.

A directory is part of that namespace. In a Unix-like file system, directory entries associate names with underlying objects identified by metadata such as inode numbers.


#heading(level: 2)[From flat names to a hierarchy]
 Textbooks often describe several directory organizations:

- #strong[single-level:] every file shares one directory;

- #strong[two-level:] each user receives a separate directory;

- #strong[tree-structured:] directories contain files and subdirectories;

- #strong[graph-like structures:] links allow an object to be reachable through more than one path.

Modern general-purpose systems use hierarchical trees with linking mechanisms.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/OPERATING SYSTEMS/figures/diagrams/3c0f2ac884633337.svg")], caption: [A tree-structured directory: directories contain files and further directories below a single root.]) <fig:directory-tree>


#heading(level: 2)[Absolute and relative paths]
 An #strong[absolute path] begins at the root directory, for example `/home/student/notes.txt`. A #strong[relative path] begins at the process's current working directory.

Two special names appear frequently:

- `.` means the current directory;

- `..` means the parent directory.

The shell maintains a current working directory for itself, and a child process normally inherits that starting directory.


#heading(level: 2)[Pathname resolution is repeated lookup]
 To resolve a path such as `/home/student/notes.txt`, the system conceptually starts at the root, finds the entry named `home`, then inside that directory finds `student`, and finally finds `notes.txt`.

This is why permissions on intermediate directories matter: reaching a file requires traversing the path, not merely knowing the final filename.


#heading(level: 2)[Name, metadata, and data are different layers]
 A filename is not the complete file. Metadata can include object type, owner, permissions, timestamps, size, link count, and pointers or mappings to data blocks.

#callout("keyidea", title: [Key idea])[The namespace tells us #emph[how an object is named]. Metadata tells us #emph[what the object is and its properties]. Storage allocation tells us #emph[where its bytes are represented on storage].]


#heading(level: 2)[Hard links]
 A hard link gives another directory entry to the same underlying inode. The two names are peers: neither is inherently the "real" name. Removing one name does not remove the file data while another hard link still refers to the inode.

The inode's link count helps the file system track how many directory entries refer to it.


#heading(level: 2)[Symbolic links]
 A symbolic link is a separate small file-system object whose content is a pathname. Following the link causes another pathname lookup.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [Hard link], [Symbolic link],),
    table.hline(),
    [Underlying inode], [same inode as target], [separate inode],
    [Stores a pathname], [no], [yes],
    [Can become dangling], [not in the same way], [yes, if target path disappears],
    [Recursive traversal concern], [ordinary name to same object], [can create path-following cycles],
  )]
  , kind: table
  )


#heading(level: 2)[Recursive traversal]
 A directory walker opens a directory, reads each entry, and recursively repeats the operation for child directories. Two practical rules matter:

+ do not recurse into `.` and `..`;

+ decide deliberately whether symbolic links will be followed.

Blindly following links can revisit the same locations indefinitely if links form a cycle.


#heading(level: 2)[Directory operations and consistency]
 Common namespace operations include create, list, rename, link, unlink, and traverse. A real file system must update its metadata consistently even if two processes act at once or a crash interrupts an update.

The lab stays at an observable introductory level: you create a small tree, inspect inode identity and links, and compare the shell's view with a recursive C walker.

#callout("quickcheck", title: [Check your understanding])[+ What is the starting point of an absolute path? A relative path?

+ Why can two different names report the same inode number?

+ Why might a directory walker choose not to follow symbolic links?]
