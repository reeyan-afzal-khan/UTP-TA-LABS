#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-ospf")


#heading(level: 1)[Dynamic Routing with OSPF]
<ch:ospf> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Static routing, interface addressing, routing-table interpretation, and ping verification.

*By the end, you can:* Configure router IDs, advertise networks into OSPF area 0, inspect OSPF-learned routes and neighbors, and explain why dynamic routing reduces manual route maintenance.]


#heading(level: 2)[Where OSPF fits among routing approaches]
 OSPF is a dynamic, interior, link-state routing protocol. Instead of configuring every destination and next hop, routers form neighbor relationships and exchange topology information.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/routing-protocols-map.png", width: 90%)], caption: [The routing-protocol classification shown in the supplied Lab~4 slide. OSPF is a dynamic, interior, link-state protocol.]) <fig:routing-protocols-map>


#heading(level: 2)[Why dynamic routing is useful]
 Dynamic routing reduces manual maintenance and adapts to topology changes. OSPF uses a hierarchy centered on #strong[area 0]; this exercise places every participating interface in that single area.


#heading(level: 3)[What changes compared with Chapter~#ref(label("ch:static-routing"), supplement: none)]
 In the static lab you wrote a route on R1 and a mirror route on R3, then a backup pair on top, and a ping only worked once every one of them was present. Here you tell each router which of #emph[its own] interfaces take part, and reachability follows.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/7a0038105df77532.svg")], caption: [Every router holds the same map, then computes its own routes. OSPF floods link-state information until each router's database is identical; each router then runs Dijkstra from itself.]) <fig:ospf-lsdb>

#callout("keyidea", title: [Key idea])[A static route states a #emph[conclusion] ("send this network that way"). OSPF distributes the #emph[evidence] --- which links exist and what they cost --- and lets each router reach its own conclusion. That is why a failed link needs no new configuration: the evidence changes, and every router recomputes.]


#heading(level: 2)[Single-area OSPF topology]
 R1 connects to R2 over `10.0.12.0/24` and R3 over `10.0.13.0/24`. Loopbacks provide stable networks at `10.0.1.1/24`, `10.0.2.2/24`, and `10.0.3.3/24`; the source also shows `172.16.0.1/24` on R3's Loopback2.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/ospf-topology.png", width: 90%)], caption: [The single-area OSPF topology from the supplied Lab~4 slide. Every participating interface is in area~0.]) <fig:ospf-topology>


#heading(level: 2)[Router IDs and OSPF process 1]
 Each OSPF process receives a unique router ID matching the router's loopback address.

#code-block("[R1] ospf 1 router-id 10.0.1.1\n[R1-ospf-1] area 0\n[R1-ospf-1-area-0.0.0.0] network 10.0.1.0 0.0.0.255\n[R1-ospf-1-area-0.0.0.0] network 10.0.13.0 0.0.0.255\n[R1-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255\n\n[R2] ospf 1 router-id 10.0.2.2\n[R2-ospf-1] area 0\n[R2-ospf-1-area-0.0.0.0] network 10.0.2.0 0.0.0.255\n[R2-ospf-1-area-0.0.0.0] network 10.0.12.0 0.0.0.255", lang: "text") R3 follows the same pattern for the networks connected to it.

#callout("keyidea", title: [Key idea])[The `network` statements select local interfaces for OSPF. An unmatched interface does not participate or advertise its connected network through that process.]


#heading(level: 2)[Understand the wildcard mask used in the slides]
 The wildcard `0.0.0.255` matches addresses in the corresponding `x.x.x.0/24` network.


#heading(level: 2)[Verify convergence]
 After configuration, do not jump directly to ping. First verify the control plane. #code-block("<R1> display ip routing-table\n<R1> display ospf peer\n<R1> display ospf peer brief", lang: "text") The detailed output includes neighbor ID, address, state, priority, DR/BDR data, timers, and uptime; the brief form shows only the essentials.

#callout("vrpbox", title: [])[\<R1\> display ospf peer brief #code-block("OSPF Process 1 with Router ID 10.0.1.1\n                  Peer Statistic Information\n ----------------------------------------------------------------------------\n Area Id         Interface                     Neighbor id       State\n 0.0.0.0         GigabitEthernet0/0/0          10.0.2.2          (*\\higreen{Full}*)\n 0.0.0.0         GigabitEthernet0/0/1          10.0.3.3          (*\\higreen{Full}*)\n ----------------------------------------------------------------------------", lang: "text")] one line per adjacency, and both say `Full`. A neighbour that never appears at all is a different fault from one that appears stuck in another state --- the first is a hello problem, the second is in #ref(label("fig:ospf-states"), supplement: [Figure]).

Once the adjacencies are up, the routes they produced are worth seeing separately from the connected ones.

#callout("vrpbox", title: [])[\<R1\> display ip routing-table protocol ospf #code-block("Public routing table : OSPF\n         Destinations : 3         Routes : 3\n\nOSPF routing table status : <Active>\n         Destinations : 3         Routes : 3\n\nDestination/Mask    Proto  (*\\hi{Pre}*)  (*\\hi{Cost}*)  Flags NextHop         Interface\n      10.0.2.0/24   OSPF   (*\\hi{10}*)   (*\\hi{2}*)       D   10.0.12.2       GigabitEthernet0/0/0\n      10.0.3.0/24   OSPF   (*\\hi{10}*)   (*\\hi{2}*)       D   10.0.13.3       GigabitEthernet0/0/1\n     10.0.23.0/24   OSPF   (*\\hi{10}*)   (*\\hi{2}*)       D   10.0.12.2       GigabitEthernet0/0/0", lang: "text")] `Pre 10` against static routing's 60, so OSPF wins wherever both exist. `Cost` is derived from interface bandwidth rather than hop count, which is the subject of #ref(label("fig:ospf-cost"), supplement: [Figure]).


#heading(level: 3)[Reading the neighbour state as a diagnosis]
 `Full` is the only state that means success. Every other state names the step that failed, which makes `display ospf peer brief` the most useful single command in this chapter.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/238826d40655588f.svg")], caption: [The adjacency state machine, annotated with what a stall at each point actually means. A neighbour parked in one of these states is a specific fault, not a slow start.]) <fig:ospf-states>

#callout("pitfall", title: [Common mistake])[Neighbours also refuse to form when the hello or dead intervals differ, when the area IDs differ, or when authentication is set on one side only. None of these produce an error message; they produce a neighbour that never appears.]


#heading(level: 3)[Why the cost column changes the answer]
 Huawei derives OSPF cost from interface bandwidth, using a reference of 100 Mbit/s. A gigabit link therefore costs 1 and a 64 kbit/s serial link costs 1562, so OSPF prefers the fast path without being told to.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/999fa439ee93ed97.svg")], caption: [Two paths from R1 to R3. The direct serial link is one hop; the route through R2 is two. OSPF picks the two-hop path because it adds costs rather than counting hops.]) <fig:ospf-cost>

#callout("verification", title: [Verification checklist])[Require three checks: the expected neighbor is #strong[Full], remote networks appear as OSPF routes, and ping succeeds.]


#heading(level: 2)[Connectivity test]
 The lab pings from R2 to R1 and R3's loopback `10.0.3.3`, confirming that OSPF learned the remote paths.


#heading(level: 2)[Troubleshooting OSPF in the order the evidence suggests]


+ Confirm interface IP addresses and physical/protocol state.

+ Confirm each required network is matched by the OSPF configuration in area 0.

+ Use `display ospf peer brief`. If the expected neighbor is absent or not Full, solve the adjacency problem before studying remote routes.

+ Use `display ip routing-table` and locate the OSPF-learned destination.

+ Only then use ping to verify the data path.

#callout("pitfall", title: [Common mistake])[A missing route may reflect a failed adjacency. Do not mask the fault with a static route; inspect the interface and OSPF configuration.]

#callout("quickcheck", title: [Check your understanding])[+ Why does the lab explicitly configure a router ID?

+ What is the role of area 0 in the source material?

+ Which command gives the compact neighbor summary?

+ What two pieces of evidence should be present before you trust a successful OSPF configuration?]
