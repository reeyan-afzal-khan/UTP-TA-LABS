#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the actual cyclic hour encoding])[#flow([*\1. Input / state*

bike\$hr contains hours 0 through 23; the angle is 2 times pi times hr / 24.], [*\2. Operation*

Compute hour\_sin and hour\_cos. Hour 0 maps to (0, 1); hour 6 maps approximately to (1, 0).], [*\3. Check*

unit\_circle\_error checks sin squared plus cos squared is approximately 1 for every row.])]
