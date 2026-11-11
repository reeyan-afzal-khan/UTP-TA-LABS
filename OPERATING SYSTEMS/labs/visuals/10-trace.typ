#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Validate the whole allocation first])[#flow([*Propose*

Select an index block and the data blocks], [*Validate*

Reject duplicates, occupied blocks or invalid numbers], [*Commit*

Only a valid complete request changes the block map])]
