#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

The labs progress from packet observation to device configuration, routing, services, Layer-2 switching, and WAN protocols. Five stages build on the #emph[Foundations] reference chapter that opens the book; the group project integrates them.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Observe], [Wireshark, eNSP, and VRP basics])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Reachability], [Static routing and OSPF])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Services], [FTP and DHCP])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Switched LAN], [Link aggregation and VLANs])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [WAN], [HDLC, PPP, PAP, and CHAP])], name: "e", ..card)
    node(left-of("e", 0.66), [#coursemapcard([STAGE 06], [Group project], [An integrated eNSP network])], name: "f", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
    connect("e", "f", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Packet capture and device configuration], [How do you see, and change, what a network is doing?],
    [2], [Static routing and OSPF], [How does a router learn where to send a packet?],
    [3], [FTP and DHCP], [How do services run on top of a working IP network?],
    [4], [Link aggregation and VLANs], [How are Layer-2 links bundled together and kept apart?],
    [5], [Serial WAN links], [How do distant sites join one routing domain securely?],
    [6], [Group project], [How do you prove a network works, layer by layer?],
  )
]

#heading(depth: 2, numbering: none)[What each stage configures]

#utptable[
  #tabularx(
    columns: (8%, 9%, 1fr),
    align: (center, center, left),
    styles: (navy-bold,),
    header: ([Stage], [Labs], [Configuration and evidence]),
    [---], [---], [Reference: layers, encapsulation, the three kinds of address, and the Ethernet and IPv4 header maps. Read once, then return to it whenever a later lab names a layer.],
    [1], [1--2], [Wireshark captures, eNSP topology building, VRP navigation, interface addressing, verification, and saving.],
    [2], [3--4], [Static and backup routes, single-area OSPF, routing tables, neighbours, and connectivity tests.],
    [3], [5--6], [FTP with AAA authorization; DHCP global and interface pools, leases, and DNS options.],
    [4], [7--8], [Manual aggregation, LACP priorities, VLAN port types, PVIDs, and isolation tests.],
    [5], [9], [HDLC, PPP, DCE clocking, OSPF, PAP/CHAP authentication, and debugging.],
    [6], [---], [Build and demonstrate an eNSP network, justify protocol choices, explain forwarding, and report the evidence.],
  )
]
