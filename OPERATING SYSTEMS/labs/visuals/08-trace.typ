#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [FIFO with three frames: 7, 0, 1, 2])[#flow([*Fill*

References 7, 0, 1 create three faults], [*Replace*

Reference 2 evicts 7: frames become \[2, 0, 1\]], [*Check*

The next reference 0 is a hit; next does not move])]
