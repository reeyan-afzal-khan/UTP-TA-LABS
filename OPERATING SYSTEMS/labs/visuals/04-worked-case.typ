#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the supplied FCFS accumulators])[#flow([*\1. Input / state*

burst is \[8, 4, 2, 1\] time, total\_wait and total\_turnaround start at zero.], [*\2. Operation*

Each iteration records wait = time, adds burst\[i\] to time, then records turnaround = time.], [*\3. Check*

Waits \[0, 8, 12, 14\] average 8.50; turnarounds \[8, 12, 14, 15\] average 12.25.])]
