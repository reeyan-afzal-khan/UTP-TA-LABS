#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Two different correctness questions])[#flow([*Mutual exclusion*

Only one thread changes the counter at a time], [*Resource safety*

Need = Maximum - Allocation], [*Safe sequence*

Need must fit Work before resources are released])]
