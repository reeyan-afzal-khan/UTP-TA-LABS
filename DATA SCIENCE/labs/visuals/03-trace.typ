#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Why hour needs a circular encoding])[#flow([*23:00*

Near midnight, not far from 00:00], [*Encode*

sin(2 pi hour / 24), cos(2 pi hour / 24)], [*Check*

Both coordinates repeat after 24 hours])]
