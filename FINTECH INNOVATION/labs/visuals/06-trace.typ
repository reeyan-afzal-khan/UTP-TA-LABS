#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [What one changed transaction affects])[#flow([*Transaction*

A changed value changes its Merkle root], [*Block*

The changed header has a different hash], [*Next block*

Its stored previous hash no longer matches])]
