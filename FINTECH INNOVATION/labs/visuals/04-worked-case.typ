#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the actual cohort intersections])[#flow([*\1. Input / state*

cohort is the set of users at app\_open; previous initially points to that set.], [*\2. Operation*

For each step, reached intersects users at that step with previous; counts records its size.], [*\3. Check*

overall divides by the initial cohort; step\_conversion divides by the preceding count.])]
