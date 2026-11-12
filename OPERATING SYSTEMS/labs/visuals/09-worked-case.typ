#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the actual hard and symbolic links], [1\. Input / state], [notes-hardlink.txt is linked to notes.txt. code-link.c stores the relative path projects/code.c.], [2\. Operation], [Compare inode and link-count output for the two notes names; resolve the code link from its containing directory.], [3\. Check], [The notes names share one inode; the code link has its own inode and resolves to the project file.])
