#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-ospf")

= Dynamic Routing with OSPF <ch:ospf>

#chapterguide[Static routing, interface addressing, routing-table interpretation, and ping verification.][Configure router IDs, advertise networks into OSPF area 0, inspect OSPF-learned routes and neighbors, and explain why dynamic routing reduces manual route maintenance.]

== Where OSPF fits among routing approaches

OSPF is a dynamic, interior, link-state routing protocol. Instead of configuring every destination and next hop, routers form neighbor relationships and exchange topology information.

#utpfig([The routing-protocol classification shown in the supplied Lab~4 slide. OSPF is a dynamic, interior, link-state protocol.], label: <fig:routing-protocols-map>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/routing-protocols-map.png", width: 88%, height: 404.7848pt)
]

== Why dynamic routing is useful

Dynamic routing reduces manual maintenance and adapts to topology changes. OSPF uses a hierarchy centered on #term[area 0]; this exercise places every participating interface in that single area.

=== What changes compared with Chapter~@ch:static-routing

In the static lab you wrote a route on R1 and a mirror route on R3, then a backup pair on top, and a ping only worked once every one of them was present. Here you tell each router which of #emph[its own] interfaces take part, and reachability follows.

#utpfig([Every router holds the same map, then computes its own routes. OSPF floods link-state information until each router’s database is identical; each router then runs Dijkstra from itself.], label: <fig:ospf-lsdb>)[
  #canvas({
    let db = (shape: "rectangle", rounded: 1mm, draw: teal, fill: pale-teal, min-width: 2.5, min-height: 0.95, align: center, font: font("script", fill: navy))
    let ml = (font: font("script", fill: muted), align: center)
    node((0, 0), [R1], name: "r1", ..router)
    node(right-of("r1", 2.2), [R2], name: "r2", ..router)
    node(right-of("r2", 2.2), [R3], name: "r3", ..router)
    connect("r1", "r2", ..netlink)
    connect("r2", "r3", ..netlink)
    connect("r1", "r3", bend: -32deg, ..netlink, name: "curve-1")
    node(below-of("r1", 1.15), [identical \
   link-state DB], name: "d1", ..db)
    node(below-of("r2", 1.15), [identical \
   link-state DB], name: "d2", ..db)
    node(below-of("r3", 1.15), [identical \
   link-state DB], name: "d3", ..db)
    connect("d1", "d2", line-width: widths.thick, draw: teal, start: arrow-tip("to", line: widths.thick), end: arrow-tip("to", line: widths.thick))
    node(along("d1", "d2", t: 50%), [flood], ..ml, anchor: "south")
    connect("d2", "d3", line-width: widths.thick, draw: teal, start: arrow-tip("to", line: widths.thick), end: arrow-tip("to", line: widths.thick))
    node(along("d2", "d3", t: 50%), [flood], ..ml, anchor: "south")
    node(below-of("d2", 0.45), [Same database everywhere. Each router then runs Dijkstra #strong[from itself], so the routing tables all differ --- and all agree.], ..ml, text-width: 9.5)
  })
]

#note[
  A static route states a #emph[conclusion] (“send this network that way”). OSPF distributes the #emph[evidence] --- which links exist and what they cost --- and lets each router reach its own conclusion. That is why a failed link needs no new configuration: the evidence changes, and every router recomputes.
]

== Single-area OSPF topology

R1 connects to R2 over `10.0.12.0/24` and R3 over `10.0.13.0/24`. Loopbacks provide stable networks at `10.0.1.1/24`, `10.0.2.2/24`, and `10.0.3.3/24`; the source also shows `172.16.0.1/24` on R3’s Loopback2.

#utpfig([The single-area OSPF topology from the supplied Lab~4 slide. Every participating interface is in area~0.], label: <fig:ospf-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/ospf-topology.png", width: 79%, height: 404.7848pt)
]

== Router IDs and OSPF process 1

Each OSPF process receives a unique router ID matching the router’s loopback address.

```terminal
[R1] ospf 1 router-id 10.0.1.1
[R1-ospf-1] area 0
[R1-ospf-1-area-0.0.0.0] network 10.0.1.0 0.0.0.255
[R1-ospf-1-area-0.0.0.0] network 10.0.13.0 0.0.0.255
[R1-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255

[R2] ospf 1 router-id 10.0.2.2
[R2-ospf-1] area 0
[R2-ospf-1-area-0.0.0.0] network 10.0.2.0 0.0.0.255
[R2-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255
```

R3 follows the same pattern for the networks connected to it.

#note[
  The `network` statements select local interfaces for OSPF. An unmatched interface does not participate or advertise its connected network through that process.
]

== Understand the wildcard mask used in the slides

The wildcard `0.0.0.255` matches addresses in the corresponding `x.x.x.0/24` network.

== Verify convergence

After configuration, do not jump directly to ping. First verify the control plane.

```terminal
<R1> display ip routing-table
<R1> display ospf peer
<R1> display ospf peer brief
```

The detailed output includes neighbor ID, address, state, priority, DR/BDR data, timers, and uptime; the brief form shows only the essentials.

#vrpbox[\<R1\> display ospf peer brief][
  #vrp(
    (raw("         OSPF Process 1 with Router ID 10.0.1.1"),),
    (raw("                  Peer Statistic Information"),),
    (raw(" ----------------------------------------------------------------------------"),),
    (raw(" Area Id         Interface                     Neighbor id       State"),),
    (raw(" 0.0.0.0         GigabitEthernet0/0/0          10.0.2.2          "), [#higreen[Full]]),
    (raw(" 0.0.0.0         GigabitEthernet0/0/1          10.0.3.3          "), [#higreen[Full]]),
    (raw(" ----------------------------------------------------------------------------"),),
  )
]

#vrpread[one line per adjacency, and both say `Full`. A neighbour that never appears at all is a different fault from one that appears stuck in another state --- the first is a hello problem, the second is in #figref(<fig:ospf-states>).]

Once the adjacencies are up, the routes they produced are worth seeing
separately from the connected ones.

#vrpbox[\<R1\> display ip routing-table protocol ospf][
  #vrp(
    (raw("Public routing table : OSPF"),),
    (raw("         Destinations : 3         Routes : 3"),),
    (),
    (raw("OSPF routing table status : <Active>"),),
    (raw("         Destinations : 3         Routes : 3"),),
    (),
    (raw("Destination/Mask    Proto  "), [#hi[Pre]], raw("  "), [#hi[Cost]], raw("  Flags NextHop         Interface")),
    (raw("      10.0.2.0/24   OSPF   "), [#hi[10]], raw("   "), [#hi[2]], raw("       D   10.0.12.2       GigabitEthernet0/0/0")),
    (raw("      10.0.3.0/24   OSPF   "), [#hi[10]], raw("   "), [#hi[2]], raw("       D   10.0.13.3       GigabitEthernet0/0/1")),
    (raw("     10.0.23.0/24   OSPF   "), [#hi[10]], raw("   "), [#hi[2]], raw("       D   10.0.12.2       GigabitEthernet0/0/0")),
  )
]

#vrpread[`Pre 10` against static routing’s 60, so OSPF wins wherever both exist. `Cost` is derived from interface bandwidth rather than hop count, which is the subject of #figref(<fig:ospf-cost>).]

=== Reading the neighbour state as a diagnosis

`Full` is the only state that means success. Every other state names
the step that failed, which makes `display ospf peer brief` the most
useful single command in this chapter.

#utpfig([The adjacency state machine, annotated with what a stall at each point actually means. A neighbour parked in one of these states is a specific fault, not a slow start.], label: <fig:ospf-states>)[
  #canvas({
    node((0, 0), [Down], name: "d", ..statebad, min-width: 2.2)
    node((0, -1.15), [Init], name: "i", ..statewait, min-width: 2.2)
    node((0, -2.3), [2-Way], name: "t", ..statewait, min-width: 2.2)
    node((0, -3.45), [ExStart], name: "e", ..statewait, min-width: 2.2)
    node((0, -4.6), [Exchange], name: "x", ..statewait, min-width: 2.2)
    node((0, -5.75), [Loading], name: "l", ..statewait, min-width: 2.2)
    node((0, -6.9), [Full], name: "f", ..stategood, min-width: 2.2)
    for (a, b, lab-v) in (("d", "i", "hello received"), ("i", "t", "seen in peer's hello"), ("t", "e", "DR elected"), ("e", "x", "DBD exchange"), ("x", "l", "request missing LSAs"), ("l", "f", "LSAs installed")) {
      connect(a, b, ..stedge)
      node(along(a, b, t: 50%), [#lab-v], ..stlabel, xshift: 0.5mm, anchor: "west")
    }
    node((3.9, 0), [No hello has arrived. Check cabling, interface state, and whether OSPF is enabled on the interface at all.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: red)
    node((3.9, -1.15), [#strong[Stuck here: one-way traffic.] Your hellos arrive but yours are not being acknowledged. Compare subnet masks on both ends.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: red)
    node((3.9, -2.3), [#strong[Not necessarily a fault.] On a broadcast segment, routers that are neither DR nor BDR stay here on purpose.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: ink)
    node((3.9, -3.45), [Master and slave are being decided.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: muted)
    node((3.9, -4.6), [#strong[Stuck at ExStart or Exchange: MTU mismatch.] Compare `display interface` on both sides.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: red)
    node((3.9, -5.75), [Databases are being brought into line.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: muted)
    node((3.9, -6.9), [#strong[The only state that means success.] Databases synchronised and routes exchanged.], anchor: "west", font: font("script"), align: left, text-width: 7.4, text: green)
  })
]

#warning[
  Neighbours also refuse to form when the hello or dead intervals differ,
  when the area IDs differ, or when authentication is set on one side
  only. None of these produce an error message; they produce a neighbour
  that never appears.
]

=== Why the cost column changes the answer

Huawei derives OSPF cost from interface bandwidth, using a reference of
100 Mbit/s. A gigabit link therefore costs 1 and a 64 kbit/s serial
link costs 1562, so OSPF prefers the fast path without being told to.

#utpfig([Two paths from R1 to R3. The direct serial link is one hop; the route through R2 is two. OSPF picks the two-hop path because it adds costs rather than counting hops.], label: <fig:ospf-cost>)[
  #canvas({
    node((0, 0), [R1], name: "r1", ..router)
    node((3.2, 1.2), [R2], name: "r2", ..router)
    node((6.4, 0), [R3], name: "r3", ..router)
    connect("r1", "r2", ..activepath)
    node(along("r1", "r2", t: 50%), [cost 1], ..costlabel, anchor: "south")
    connect("r2", "r3", ..activepath)
    node(along("r2", "r3", t: 50%), [cost 1], ..costlabel, anchor: "south")
    connect("r1", "r3", ..deadpath)
    node(along("r1", "r3", t: 50%), [cost 1562], ..costlabel, anchor: "north")
    node(above-of("r2", 0.1), [GE, 1000 Mbit/s], ..netlabel)
    node(below-of(("r1", 50%, "r3"), 0.5), [Serial, 64 kbit/s], ..netlabel)
    node((7.3, 0.35), [#text(fill: green)[#strong[via R2: 1 + 1 = 2]]  (chosen) \ #v(1.9925pt)
   #text(fill: red)[#strong[direct: 1562]]  (ignored)], anchor: "west", font: font("script"), align: left)
    node((7.3, -0.8), [Hop count would have picked the serial link, which is why RIP is a poor fit for a mixed-speed network.], anchor: "west", font: font("tiny", fill: muted), text-width: 4.6)
  })
]

#checklist[
  Require three checks: the expected neighbor is #strong[Full], remote networks appear as OSPF routes, and ping succeeds.
]

== Connectivity test

The lab pings from R2 to R1 and R3’s loopback `10.0.3.3`, confirming that OSPF learned the remote paths.

== Troubleshooting OSPF in the order the evidence suggests

#utpsteps[
  + Confirm interface IP addresses and physical/protocol state.
  + Confirm each required network is matched by the OSPF configuration in area 0.
  + Use `display ospf peer brief`. If the expected neighbor is absent or not Full, solve the adjacency problem before studying remote routes.
  + Use `display ip routing-table` and locate the OSPF-learned destination.
  + Only then use ping to verify the data path.
]

#warning[
  A missing route may reflect a failed adjacency. Do not mask the fault with a static route; inspect the interface and OSPF configuration.
]

#questions[
  + Why does the lab explicitly configure a router ID?
  + What is the role of area 0 in the source material?
  + Which command gives the compact neighbor summary?
  + What two pieces of evidence should be present before you trust a successful OSPF configuration?
]
