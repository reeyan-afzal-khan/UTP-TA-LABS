#import "/.shared/typst/utp.typ": *
#unit("chapters", "04-static-routing")

= Static Routing <ch:static-routing>

#chapterguide[Interface addressing, VRP navigation, and direct-link verification from Lab 2.][Read a routing table, explain why remote networks initially fail, configure next-hop static routes, use route preference for a backup path, and verify reachability.]

== The topology: three routers and three transit networks

Three routers form a triangle, and each has a loopback network. Routers learn directly connected networks automatically; remote networks require a route.

#utpfig([The triangle: every router has two ways to reach the third. The third octet of each transit network names its two routers, so `10.0.12.0` joins R1 and R2; a router’s own address ends in its number, so R2 is `10.0.12.2` and `10.0.23.2`.], label: <fig:static-triangle>)[
  #canvas({
    node((0, 0), [R1], name: "r1", ..router)
    node(right-of("r1", 3), [R2], name: "r2", ..router)
    node(below-of(("r1", 50%, "r2"), 1.7), [R3], name: "r3", ..router)
    connect("r1", "r2", ..netlink)
    node(along("r1", "r2", t: 50%), [10.0.12.0/24], ..netlabel, anchor: "south")
    connect("r1", "r3", ..netlink)
    node(along("r1", "r3", t: 50%), [10.0.13.0/24], ..netlabel, xshift: -1mm, anchor: "east")
    connect("r2", "r3", ..netlink)
    node(along("r2", "r3", t: 50%), [10.0.23.0/24], ..netlabel, xshift: 1mm, anchor: "west")
    node(above-of("r1", 0.1), [Lo0 10.0.1.1], ..netlabel)
    node(above-of("r2", 0.1), [Lo0 10.0.2.2], ..netlabel)
    node(below-of("r3", 0.1), [Lo0 10.0.3.3], ..netlabel)
  })
]

#utptable[
  #tabularx(
    columns: (auto, auto, auto),
    header: ([Link or loopback], [Network], [Example addresses in source]),
    [R1--R2], [`10.0.12.0/24`], [R1 .1, R2 .2],
    [R1--R3], [`10.0.13.0/24`], [R1 .1, R3 .3],
    [R2--R3], [`10.0.23.0/24`], [R2 .2, R3 .3],
    [R1 Loopback0], [`10.0.1.0/24`], [`10.0.1.1`],
    [R2 Loopback0], [`10.0.2.0/24`], [`10.0.2.2`],
    [R3 Loopback0], [`10.0.3.0/24`], [`10.0.3.3`],
  )
]

#utpfig([The static-routing topology from the supplied Lab~3 slide, with the links and loopbacks listed in the table above.], label: <fig:static-routing-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/static-routing-topology.png", width: 87%, height: 404.7848pt)
]

== Why the first remote ping fails

After addressing, each router can reach its direct neighbors. R2 cannot reach R3’s loopback `10.0.3.0/24` until its routing table identifies a path.

#vrpbox[\<R2\> display ip routing-table][
  #vrp(
    (raw("Route Flags: R - relay, D - download to fib"),),
    (raw("------------------------------------------------------------------------------"),),
    (raw("Routing Tables: Public"),),
    (raw("         Destinations : 13        Routes : 13"),),
    (),
    (raw("Destination/Mask    Proto   Pre  Cost  Flags NextHop         Interface"),),
    (raw("      10.0.2.0/24   Direct  0    0       D   10.0.2.2        LoopBack0"),),
    (raw("      10.0.2.2/32   Direct  0    0       D   127.0.0.1       LoopBack0"),),
    (raw("    10.0.2.255/32   Direct  0    0       D   127.0.0.1       LoopBack0"),),
    (raw("     10.0.12.0/24   Direct  0    0       D   10.0.12.2       GigabitEthernet0/0/0"),),
    (raw("     10.0.12.2/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/0"),),
    (raw("   10.0.12.255/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/0"),),
    (raw("     10.0.23.0/24   Direct  0    0       D   10.0.23.2       GigabitEthernet0/0/1"),),
    (raw("     10.0.23.2/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/1"),),
    (raw("   10.0.23.255/32   Direct  0    0       D   127.0.0.1       GigabitEthernet0/0/1"),),
    (raw("      127.0.0.0/8   Direct  0    0       D   127.0.0.1       InLoopBack0"),),
    (raw("      127.0.0.1/32  Direct  0    0       D   127.0.0.1       InLoopBack0"),),
    (raw("127.255.255.255/32  Direct  0    0       D   127.0.0.1       InLoopBack0"),),
    (raw("255.255.255.255/32  Direct  0    0       D   127.0.0.1       InLoopBack0"),),
  )
]

#vrpread[every `Proto` is `Direct`. R2 knows only the networks attached to its own interfaces. `10.0.3.0/24` and `10.0.13.0/24` appear nowhere, so a ping to R3’s loopback has nothing to match.]

#warning[
  Three entries appear per connected network, not one: the network itself
  (`/24`), the router’s own address as a host route (`/32`), and the
  broadcast address. Only the first is a forwarding path. Reading
  `Destinations : 13` as “thirteen reachable networks” is what makes a
  correct table look wrong.
]

#note[
  A router matches the destination IP against its routing table. Without a matching route, it cannot forward the packet.
]

=== How the match is chosen

Several entries can match one destination. The router does not take the
first, or the cheapest: it takes the one with the longest prefix, which
means the most specific. Preference only breaks ties between routes of
#emph[equal] prefix length.

#utpfig([Forwarding `10.0.3.3`. Three entries match; the `/24` wins because it is the most specific. The default route is the fallback that matches everything and therefore always loses.], label: <fig:lpm>)[
  #canvas({
    node((0.1, 0.95), [destination 10.0.3.3], font: font("small", fill: navy, family: "mono"))
    connect((-2.6, 0.6), (9.4, 0.6), draw: mix(muted, 50%))
    node((-2.6, 0), [0.0.0.0/0], ..hdrm, min-width: 2.3, anchor: "west", font: font("script", family: "mono"))
    node((-0.25, 0), [10.0.23.3], ..hdrm, min-width: 2.1, anchor: "west", font: font("script", family: "mono"))
    node((2, 0), [matches everything, least specific], anchor: "west", font: font("script", fill: muted))
    node((-2.6, -0.75), [10.0.0.0/8], ..hdrm, min-width: 2.3, anchor: "west", font: font("script", family: "mono"))
    node((-0.25, -0.75), [10.0.23.3], ..hdrm, min-width: 2.1, anchor: "west", font: font("script", family: "mono"))
    node((2, -0.75), [matches, 8 bits agree], anchor: "west", font: font("script", fill: muted))
    node((-2.6, -1.5), [10.0.3.0/24], ..hdrg, min-width: 2.3, anchor: "west", font: font("script", family: "mono"))
    node((-0.25, -1.5), [10.0.23.3], ..hdrg, min-width: 2.1, anchor: "west", font: font("script", family: "mono"))
    node((2, -1.5), [matches, 24 bits agree], anchor: "west", font: font("script", fill: muted))
    node((-2.6, -2.25), [10.0.13.0/24], ..hdrm, min-width: 2.3, anchor: "west", font: font("script", family: "mono"))
    node((-0.25, -2.25), [10.0.23.3], ..hdrm, min-width: 2.1, anchor: "west", font: font("script", family: "mono"))
    node((2, -2.25), [does not match], anchor: "west", font: font("script", fill: muted))
    node((6.3, -1.5), [$arrow.l$ installed, packet sent to 10.0.23.3], anchor: "west", font: font("script", weight: "bold", fill: green))
    node((-2.6, -2.95), [Read the mask as “how many leading bits must agree”. A /24 pins three octets; a /0 pins none.], anchor: "west", font: font("tiny", fill: muted))
  })
]

== Static-route syntax in this lab

The source demonstrates next-hop static routes in the form:

#align(center)[
  `ip route-static <destination-network> <mask/prefix> <next-hop> [preference <value>]`
]

A static route says: #emph[send this destination network to this next hop].

== Primary routes on R2

The lab directs R2 toward R3 by using next hop `10.0.23.3`.

```terminal
[R2] ip route-static 10.0.13.0 24 10.0.23.3
[R2] ip route-static 10.0.3.0 24 10.0.23.3
<R2> display ip routing-table
```

On the lab’s VRP image, a static route has default preference 60, so the primary route needs no explicit value.

#example[
  R2 matches `10.0.3.3` to `10.0.3.0/24` and forwards it to `10.0.23.3`. R3 delivers it locally; the reply still needs a return route.
]

== Backup static routes and route preference

The alternate path through R1 uses a higher, less-preferred value, so it remains a backup.

```terminal
[R2] ip route-static 10.0.13.0 255.255.255.0 10.0.12.1 preference 80
[R2] ip route-static 10.0.3.0 24 10.0.12.1 preference 80
```

The route through R3 (preference 60) wins over the backup through R1 (80) until the primary path fails.

#utpfig([Huawei default route preferences. Lower wins. The lab’s backup route sits at 80 purely because it is above the static default of 60 --- any value above 60 would work.], label: <fig:preference>)[
  #canvas({
    for (x, p, name, st) in ((0, 0, "Direct", hdrg), (2.15, 10, "OSPF", hdrb), (4.3, 60, "Static", hdro), (6.45, 80, "Static backup", hdrm), (8.6, 100, "RIP", hdrm)) {
      node((x, 0), [#strong[#p] \
   #name], ..st, min-width: 2, min-height: 1.05, align: center, font: font("script", fill: navy))
    }
    connect((-1.15, -0.85), (9.75, -0.85), line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 2.5mm, line: widths.thick))
    node((-1.1, -1.2), [preferred], font: font("script", fill: green), anchor: "west")
    node((9.7, -1.2), [ignored while a better route exists], font: font("script", fill: muted), anchor: "east")
  })
]

#note[
  Preference decides which #emph[protocol] to believe when two of them
  offer a route to the same prefix. It is compared only after longest-prefix
  match has already narrowed the field, which is why a `/24` static
  route still beats a `/8` OSPF route despite the worse preference.
]

#utpfig([Only one route is installed at a time; the other waits. Lower preference wins: both routes stay configured, but the routing table shows only the better one. The backup is not a second path carrying traffic --- it is a replacement that appears when the first is withdrawn.], label: <fig:static-backup>)[
  #canvas({
    node((0, 0), [Primary up], name: "t1", font: font("script", weight: "bold", fill: navy))
    node(below-of("t1", 0.4), [R2], name: "a2", ..router)
    node(above-right-of("a2", 0.9, 2.1), [R1], name: "a1", ..router)
    node(below-right-of("a2", 0.9, 2.1), [R3], name: "a3", ..router)
    connect("a2", "a3", ..activepath)
    node(along("a2", "a3", t: 50%), [pref 60], ..netlabel, anchor: "north")
    connect("a2", "a1", ..backuppath)
    node(along("a2", "a1", t: 50%), [pref 80], ..netlabel, anchor: "south")
    node(right-of("a3", 0.2), [#text(fill: green)[#strong[installed]]], ..netlabel, text-width: 2.3)
    node(right-of("a1", 0.2), [#text(fill: orange)[#strong[held in reserve]]], ..netlabel, text-width: 2.3)
    draw.scope({
      draw.translate((7.6, 0))
      node((0, 0), [Primary down], name: "t2", font: font("script", weight: "bold", fill: navy))
      node(below-of("t2", 0.4), [R2], name: "b2", ..router)
      node(above-right-of("b2", 0.9, 2.1), [R1], name: "b1", ..router)
      node(below-right-of("b2", 0.9, 2.1), [R3], name: "b3", ..router)
      connect("b2", "b3", ..deadpath)
      node(along("b2", "b3", t: 50%), [link fails], ..netlabel, anchor: "north")
      connect("b2", "b1", ..activepath)
      node(along("b2", "b1", t: 50%), [pref 80], ..netlabel, anchor: "south")
      node(right-of("b1", 0.2), [#text(fill: green)[#strong[now installed]]], ..netlabel, text-width: 2.3)
    })
  })
]

#warning[
  Failover is not instant. The router must first decide the next hop is unreachable, and only then install the backup. Expect to lose several pings during the switch --- that gap is the cost of detection, and it is why fast-converging protocols like OSPF (Chapter~@ch:ospf) exist.

  One supplied slide shows `255.255.25.0` while explaining a /24 mask. Elsewhere the same lab consistently uses /24, whose decimal form is `255.255.255.0`. The notes follow the lab’s /24 objective and flag the source typo rather than treating it as a new subnet mask.
]

== Verification sequence

#utpsteps[
  + Use `display ip interface brief` to confirm all expected interfaces and addresses.
  + Ping directly connected neighbors first; a remote-routing test is meaningless if the local link is broken.
  + Use `display ip routing-table` and confirm that the intended static destination networks are present.
  + Ping the remote interface or loopback address.
  + For the backup-route portion, make the primary path unavailable as directed in the lab and confirm the alternate route becomes effective.
]

#checklist[
  Use both routing-table and ping evidence: one proves the route is installed; the other proves forwarding works.
]

#questions[
  + Why can R2 reach a directly connected network without a static route?
  + What information does the next-hop address provide?
  + Why is the backup route configured with a preference value of 80 rather than 60?
  + Which command proves that the route exists before you test it with ping?
]
