#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Two names can mean different things])[#flow([*Hard link*

Two directory entries identify the same inode], [*Symbolic link*

The link stores a pathname to another object], [*Traversal*

lstat examines the link itself; do not recurse through it])]
