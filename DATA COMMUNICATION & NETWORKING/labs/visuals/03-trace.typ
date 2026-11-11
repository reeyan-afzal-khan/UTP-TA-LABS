#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Routing needs a round trip])[#flow([*Forward*

R1 needs a route to the destination LAN], [*Return*

R3 needs a route to the source LAN], [*Failover*

A worse-preference route activates after primary withdrawal])]
