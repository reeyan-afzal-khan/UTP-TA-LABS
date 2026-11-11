#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Shared memory has a lifecycle])[#flow([*Writer*

Create segment, attach, write, then detach], [*Reader*

Attach to the same segment and read the message], [*Cleanup*

Detach and mark the segment for removal])]
