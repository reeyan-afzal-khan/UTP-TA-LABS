#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the first successful Banker completion])[#flow([*\1. Input / state*

work begins \[3, 3, 2\]. need is maximum minus allocation for each process.], [*\2. Operation*

P1 has need \[1, 2, 2\], which fits; releasing its allocation \[2, 0, 0\] gives work \[5, 3, 2\].], [*\3. Check*

Mark P1 finished and append its index to safe\_sequence; continue until all finish or no progress occurs.])]
