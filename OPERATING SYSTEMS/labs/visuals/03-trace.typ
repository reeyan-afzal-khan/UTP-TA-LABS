#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the process-summary pipeline])[#flow([*ps*

Produce process rows from the running system], [*awk*

Keep rows matching the requested command], [*wc*

Count selected rows; status reports no match])]
