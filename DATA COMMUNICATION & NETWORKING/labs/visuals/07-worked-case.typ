#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the two-member LACP bundle])[#flow([*\1. Input / state*

GE0/0/1 and GE0/0/2 on each switch are assigned to Eth-Trunk 1 in the worked setup.], [*\2. Operation*

Use matching LACP mode and inspect which members are selected; management uses the supplied Vlanif1 addresses.], [*\3. Check*

Ping across the logical link, remove one member and verify the remaining selected member preserves reachability.])]
