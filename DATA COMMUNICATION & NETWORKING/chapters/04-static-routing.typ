#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-static-routing")


#heading(level: 1)[Static Routing]
<ch:static-routing> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Interface addressing, VRP navigation, and direct-link verification from Lab 2.

*By the end, you can:* Read a routing table, explain why remote networks initially fail, configure next-hop static routes, use route preference for a backup path, and verify reachability.]


#heading(level: 2)[The topology: three routers and three transit networks]
 Three routers form a triangle, and each has a loopback network. Routers learn directly connected networks automatically; remote networks require a route.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/4a1b64646d3bf31d.cetz.json")], caption: [The triangle: every router has two ways to reach the third. The third octet of each transit network names its two routers, so `10.0.12.0` joins R1 and R2; a router's own address ends in its number, so R2 is `10.0.12.2` and `10.0.23.2`.]) <fig:static-triangle>

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Link or loopback], [Network], [Example addresses in source],),
    table.hline(),
    [R1--R2], [`10.0.12.0/24`], [R1 .1, R2 .2],
    [R1--R3], [`10.0.13.0/24`], [R1 .1, R3 .3],
    [R2--R3], [`10.0.23.0/24`], [R2 .2, R3 .3],
    [R1 Loopback0], [`10.0.1.0/24`], [`10.0.1.1`],
    [R2 Loopback0], [`10.0.2.0/24`], [`10.0.2.2`],
    [R3 Loopback0], [`10.0.3.0/24`], [`10.0.3.3`],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/static-routing-topology.png", width: 90%)], caption: [The static-routing topology from the supplied Lab~3 slide, with the links and loopbacks listed in the table above.]) <fig:static-routing-topology>


#heading(level: 2)[Why the first remote ping fails]
 After addressing, each router can reach its direct neighbors. R2 cannot reach R3's loopback `10.0.3.0/24` until its routing table identifies a path.

#callout("vrpbox", title: [])[\<R2\> display ip routing-table #code-block("Route Flags: R - relay, D - download to fib\n------------------------------------------------------------------------------\nRouting Tables: Public\n         Destinations : 13        Routes : 13\n\nDestination/Mask    Proto   Pre  Cost  Flags NextHop         Interface\n      10.0.2.0/24   Direct  0    0       D   10.0.2.2        LoopBack0\n      10.0.2.2/32   Direct  0    0       D   127.0.0.1       LoopBack0\n    10.0.2.255/32   Direct  0    0       D   127.0.0.1       LoopBack0\n     10.0.12.0/24   Direct  0    0       D   10.0.12.2       GigabitEthernet0/0/0\n     10.0.12.2/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/0\n   10.0.12.255/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/0\n     10.0.23.0/24   Direct  0    0       D   10.0.23.2       GigabitEthernet0/0/1\n     10.0.23.2/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/1\n   10.0.23.255/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/1\n      127.0.0.0/8   Direct  0    0       D   127.0.0.1       InLoopBack0\n      127.0.0.1/32  Direct  0    0       D   127.0.0.1       InLoopBack0\n127.255.255.255/32  Direct  0    0       D   127.0.0.1       InLoopBack0\n255.255.255.255/32  Direct  0    0       D   127.0.0.1       InLoopBack0", lang: "text")] every `Proto` is `Direct`. R2 knows only the networks attached to its own interfaces. `10.0.3.0/24` and `10.0.13.0/24` appear nowhere, so a ping to R3's loopback has nothing to match.

#callout("pitfall", title: [Common mistake])[Three entries appear per connected network, not one: the network itself (`/24`), the router's own address as a host route (`/32`), and the broadcast address. Only the first is a forwarding path. Reading `Destinations : 13` as "thirteen reachable networks" is what makes a correct table look wrong.]

#callout("keyidea", title: [Key idea])[A router matches the destination IP against its routing table. Without a matching route, it cannot forward the packet.]


#heading(level: 3)[How the match is chosen]
 Several entries can match one destination. The router does not take the first, or the cheapest: it takes the one with the longest prefix, which means the most specific. Preference only breaks ties between routes of #emph[equal] prefix length.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/60d34c63eb143e8e.cetz.json")], caption: [Forwarding `10.0.3.3`. Three entries match; the `/24` wins because it is the most specific. The default route is the fallback that matches everything and therefore always loses.]) <fig:lpm>


#heading(level: 2)[Static-route syntax in this lab]
 The source demonstrates next-hop static routes in the form:

#block[
`ip route-static <destination-network> <mask/prefix> <next-hop> [preference <value>]`

]
A static route says: #emph[send this destination network to this next hop].


#heading(level: 2)[Primary routes on R2]
 The lab directs R2 toward R3 by using next hop `10.0.23.3`. #code-block("[R2] ip route-static 10.0.13.0 24 10.0.23.3\n[R2] ip route-static 10.0.3.0 24 10.0.23.3\n<R2> display ip routing-table", lang: "text") On the lab's VRP image, a static route has default preference 60, so the primary route needs no explicit value.

#callout("workedexample", title: [Worked configuration])[R2 matches `10.0.3.3` to `10.0.3.0/24` and forwards it to `10.0.23.3`. R3 delivers it locally; the reply still needs a return route.]


#heading(level: 2)[Backup static routes and route preference]
 The alternate path through R1 uses a higher, less-preferred value, so it remains a backup. #code-block("[R2] ip route-static 10.0.13.0 255.255.255.0 10.0.12.1 preference 80\n[R2] ip route-static 10.0.3.0 24 10.0.12.1 preference 80", lang: "text") The route through R3 (preference 60) wins over the backup through R1 (80) until the primary path fails.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/71316cae21f53f4b.cetz.json")], caption: [Huawei default route preferences. Lower wins. The lab's backup route sits at 80 purely because it is above the static default of 60 --- any value above 60 would work.]) <fig:preference>

#callout("keyidea", title: [Key idea])[Preference decides which #emph[protocol] to believe when two of them offer a route to the same prefix. It is compared only after longest-prefix match has already narrowed the field, which is why a `/24` static route still beats a `/8` OSPF route despite the worse preference.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/b57bffbd2e08c69a.cetz.json")], caption: [Only one route is installed at a time; the other waits. Lower preference wins: both routes stay configured, but the routing table shows only the better one. The backup is not a second path carrying traffic --- it is a replacement that appears when the first is withdrawn.]) <fig:static-backup>

#callout("pitfall", title: [Common mistake])[Failover is not instant. The router must first decide the next hop is unreachable, and only then install the backup. Expect to lose several pings during the switch --- that gap is the cost of detection, and it is why fast-converging protocols like OSPF (Chapter~#ref(label("ch:ospf"), supplement: none)) exist.]

#callout("pitfall", title: [Common mistake])[One supplied slide shows `255.255.25.0` while explaining a /24 mask. Elsewhere the same lab consistently uses /24, whose decimal form is `255.255.255.0`. The notes follow the lab's /24 objective and flag the source typo rather than treating it as a new subnet mask.]


#heading(level: 2)[Verification sequence]


+ Use `display ip interface brief` to confirm all expected interfaces and addresses.

+ Ping directly connected neighbors first; a remote-routing test is meaningless if the local link is broken.

+ Use `display ip routing-table` and confirm that the intended static destination networks are present.

+ Ping the remote interface or loopback address.

+ For the backup-route portion, make the primary path unavailable as directed in the lab and confirm the alternate route becomes effective.

#callout("verification", title: [Verification checklist])[Use both routing-table and ping evidence: one proves the route is installed; the other proves forwarding works.]

#callout("quickcheck", title: [Check your understanding])[+ Why can R2 reach a directly connected network without a static route?

+ What information does the next-hop address provide?

+ Why is the backup route configured with a preference value of 80 rather than 60?

+ Which command proves that the route exists before you test it with ping?]
