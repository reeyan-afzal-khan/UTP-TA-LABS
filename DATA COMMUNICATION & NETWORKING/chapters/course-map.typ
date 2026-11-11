#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


The labs progress from packet observation to device configuration, routing, services, Layer-2 switching, and WAN protocols. Five stages build on the #emph[Foundations] reference chapter that opens the book; the group project integrates them.

#callout("utpfigure", title: [])[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/04e9f29bd3c71801.svg")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [Packet capture and device configuration], [How do you see, and change, what a network is doing?],
    [2], [Static routing and OSPF], [How does a router learn where to send a packet?],
    [3], [FTP and DHCP], [How do services run on top of a working IP network?],
    [4], [Link aggregation and VLANs], [How are Layer-2 links bundled together and kept apart?],
    [5], [Serial WAN links], [How do distant sites join one routing domain securely?],
    [6], [Group project], [How do you prove a network works, layer by layer?],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[What each stage configures]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Labs], [Configuration and evidence],),
    table.hline(),
    [---], [---], [Reference: layers, encapsulation, the three kinds of address, and the Ethernet and IPv4 header maps. Read once, then return to it whenever a later lab names a layer.],
    [1], [1--2], [Wireshark captures, eNSP topology building, VRP navigation, interface addressing, verification, and saving.],
    [2], [3--4], [Static and backup routes, single-area OSPF, routing tables, neighbours, and connectivity tests.],
    [3], [5--6], [FTP with AAA authorization; DHCP global and interface pools, leases, and DNS options.],
    [4], [7--8], [Manual aggregation, LACP priorities, VLAN port types, PVIDs, and isolation tests.],
    [5], [9], [HDLC, PPP, DCE clocking, OSPF, PAP/CHAP authentication, and debugging.],
    [6], [---], [Build and demonstrate an eNSP network, justify protocol choices, explain forwarding, and report the evidence.],
  )]
  , kind: table
  )
