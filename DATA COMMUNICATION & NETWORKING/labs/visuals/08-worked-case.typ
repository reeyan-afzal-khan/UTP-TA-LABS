#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace VLAN 10 across the supplied trunk])[#flow([*\1. Input / state*

GE0/0/1 is access VLAN 10; GE0/0/2 is access VLAN 20. GE0/0/24 carries both VLANs.], [*\2. Operation*

The VLAN 10 hosts use 192.168.10.11 and .12; frames cross the permitted trunk in VLAN 10.], [*\3. Check*

Same-VLAN peers should communicate. Cross-VLAN traffic has no router in this exercise.])]
