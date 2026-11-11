#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [A successful read need not fit one write])[#flow([*Read*

Fill a buffer; record the number of bytes obtained], [*Write*

Advance the offset until all bytes are written], [*Check*

cmp confirms byte equality independently])]
