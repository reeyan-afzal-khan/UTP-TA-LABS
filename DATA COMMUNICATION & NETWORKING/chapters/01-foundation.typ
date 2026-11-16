#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-foundation")

= Foundations: Layers, Addresses, and Frames <ch:foundations>

Every later chapter assumes three things: that a message is wrapped in
layers, that each layer carries its own kind of address, and that a
device only reads as far up the stack as its job requires. This chapter
is the reference for all three. Nothing here is configured in eNSP ---
it is the vocabulary the labs are written in.

== Two models, one stack

OSI has seven layers and is the language people use to #emph[describe]
faults. TCP/IP has four and is what the software actually implements.
The labs use OSI numbering (“a Layer-2 problem”, “a Layer-3 device”)
and TCP/IP behaviour.

#utpfig([The two reference models side by side. Layer numbers come from OSI; the protocols in the right-hand column are what the eNSP labs actually configure.], label: <fig:osi-tcpip>)[
  #canvas({
    node((0, 0), [Application], name: "o7", ..layerapp)
    node(below-of("o7", 0.12), [Presentation], name: "o6", ..layerapp)
    node(below-of("o6", 0.12), [Session], name: "o5", ..layerapp)
    node(below-of("o5", 0.12), [Transport], name: "o4", ..layertra)
    node(below-of("o4", 0.12), [Network], name: "o3", ..layernet)
    node(below-of("o3", 0.12), [Data Link], name: "o2", ..layerlnk)
    node(below-of("o2", 0.12), [Physical], name: "o1", ..layerphy)
    for (n, num) in (("o7", 7), ("o6", 6), ("o5", 5), ("o4", 4), ("o3", 3), ("o2", 2), ("o1", 1)) {
      node(left-of(n, 0.15), [#num], ..layernum)
    }
    node(above-of("o7", 0.25), [OSI], font: font("small", weight: "bold", fill: navy))
    node(right-of("o6", 2.6), [Application], name: "t4", ..layerapp, min-height: 2.64)
    node(below-of("t4", 0.12), [Transport], name: "t3", ..layertra, min-height: 0.8)
    node(below-of("t3", 0.12), [Internet], name: "t2", ..layernet, min-height: 0.8)
    node(below-of("t2", 0.12), [Network Access], name: "t1", ..layerlnk, min-height: 1.72)
    node(above-of("t4", 0.25), [TCP/IP], font: font("small", weight: "bold", fill: navy))
    node(right-of("t4", 0.3), [HTTP, #strong[FTP], #strong[DHCP], DNS \ #v(0.9963pt)
   #text(fill: teal)[#strong[PDU: data]]], anchor: "west", font: font("script", fill: ink), align: left)
    node(right-of("t3", 0.3), [TCP, UDP \ #v(0.9963pt)
  #text(fill: teal)[#strong[PDU: segment]]], anchor: "west", font: font("script", fill: ink), align: left)
    node(right-of("t2", 0.3), [IPv4, ICMP, #strong[OSPF] \ #v(0.9963pt)
  #text(fill: teal)[#strong[PDU: packet]]], anchor: "west", font: font("script", fill: ink), align: left)
    node(right-of("t1", 0.3), [Ethernet, #strong[802.1Q], #strong[PPP], #strong[HDLC] \ #v(0.9963pt)
   #text(fill: teal)[#strong[PDU: frame]] $arrow.r$ bits], anchor: "west", font: font("script", fill: ink), align: left)
    brace((rel: (0.15, 0), to: "o7.north-east"), (rel: (0.15, 0), to: "o5.south-east"), amplitude: 3.4869pt, draw: muted)
    brace((rel: (0.15, 0), to: "o2.north-east"), (rel: (0.15, 0), to: "o1.south-east"), amplitude: 3.4869pt, draw: muted)
  })
]

#note[
  Bold entries are configured somewhere in this book. The course spends
  almost all of its time at Layers 2 and 3, which is where a switch and a
  router respectively make their forwarding decisions.
]

== Encapsulation: each layer adds its own header

A layer treats everything handed down to it as opaque payload and puts
its own header in front. The receiver reverses the process. This is why
a single Wireshark row can be expanded into four or five nested
protocols.

#utpfig([Sending data down the stack. Each layer prepends a header; only Ethernet also appends a trailer. The receiving host strips them in the opposite order.], label: <fig:encapsulation>)[
  #canvas({
    let u = 0.3
    protorow(0, u, ((14, [Application data], hdrpay),))
    node((5, 0), [Data], anchor: "west", font: font("script", weight: "bold", fill: purple))
    protorow(-1.05, u, ((4, [TCP hdr], hdrg), (14, [Application data], hdrpay)))
    node((5.7, -1.05), [Segment], anchor: "west", font: font("script", weight: "bold", fill: teal))
    protorow(-2.1, u, ((4, [IP hdr], hdrb), (4, [TCP hdr], hdrg), (14, [Application data], hdrpay)))
    node((6.9, -2.1), [Packet], anchor: "west", font: font("script", weight: "bold", fill: blue))
    protorow(-3.15, u, ((4, [Eth hdr], hdro), (4, [IP hdr], hdrb), (4, [TCP hdr], hdrg), (14, [Application data], hdrpay), (3, [FCS], hdro)))
    node((8.8, -3.15), [Frame], anchor: "west", font: font("script", weight: "bold", fill: orange))
    connect((-0.75, 0.15), (-0.75, -3.5), line-width: widths.thick, draw: muted, end: arrow-tip("Stealth", length: 2.5mm, line: widths.thick))
    node((-0.95, -1.7), [sending host], rotate: (90) * 1deg, anchor: "south", font: font("script", fill: muted))
  })
]

== Three addresses, three jobs

Beginners conflate these constantly. They answer different questions and
they change at different rates as a packet crosses a network.

#utptable[
  #tabularx(
    columns: (15%, 15%, 20%, 1fr),
    styles: (navy-bold,),
    header: ([Address], [Layer], [Answers], [Changes in transit?]),
    [MAC], [2], [Which device on #emph[this] link?], [Yes --- rewritten at every router hop.],
    [IP], [3], [Which host on #emph[any] network?], [No --- constant end to end.],
    [Port], [4], [Which program on that host?], [No.],
  )
]

#utpfig([The IP addresses stay put; the MAC addresses are replaced on every link. A router is the device that performs the rewrite.], label: <fig:addr-rewrite>)[
  #canvas({
    node((0, 0), [PC1], name: "a", ..host)
    node(right-of("a", 2.6), [R1], name: "r", ..router)
    node(right-of("r", 2.6), [PC2], name: "b", ..host)
    connect("a", "r", ..netlink)
    connect("r", "b", ..netlink)
    node(above-of("a", 0.05), [10.0.1.10], ..netlabel)
    node(above-of("b", 0.05), [10.0.2.20], ..netlabel)
    node(above-of("r", 0.05), [R1 routes between them], ..netlabel)
    node(below-of("a", 0.9), [#fsize("script")[src MAC #strong[aa] \
   #fsize("script")[dst MAC #strong[r1] \ #v(0.9963pt)
   #fsize("script")[src IP 10.0.1.10 \
   #fsize("script")[dst IP 10.0.2.20]]]]], ..netframe, text-width: 3, align: center, draw: orange)
    node(below-of("b", 0.9), [#fsize("script")[src MAC #strong[r1] \
   #fsize("script")[dst MAC #strong[bb] \ #v(0.9963pt)
   #fsize("script")[src IP 10.0.1.10 \
   #fsize("script")[dst IP 10.0.2.20]]]]], ..netframe, text-width: 3, align: center, draw: orange)
    connect((rel: (0, -0.42), to: "a"), (rel: (0, -0.72), to: "a"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
    connect((rel: (0, -0.42), to: "b"), (rel: (0, -0.72), to: "b"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
    node(below-of("r", 2.35), [MAC changed, IP untouched], font: font("script", weight: "bold", fill: red), text-width: 4.4, align: center)
  })
]

== The Ethernet II frame

This is the frame Wireshark shows in Lab~1 and the frame a VLAN tag is
inserted into in Lab~8.

#utpfig([Ethernet II framing. Widths are proportional to the real field sizes. The preamble and SFD are generated by the hardware and are not shown by Wireshark.], label: <fig:eth-frame>)[
  #canvas({
    let u = 0.4
    protorow(0, u, ((7, [Preamble], hdrm), (1, [S], hdrm), (6, [Destination MAC], hdrb), (6, [Source MAC], hdrb), (2, [Type], hdro), (11, [Payload], hdrpay), (4, [FCS], hdrg)))
    prototicks(-0.63, u, ((7, [7]), (1, [1]), (6, [6]), (6, [6]), (2, [2]), (11, [46--1500]), (4, [4])))
    node((-0.12, -0.63), [bytes], ..hdrtick, anchor: "east")
    brace((0, -0.95), (3.2, -0.95), amplitude: 2.9888pt, mirror: true, draw: muted)
    node((1.6, -1.3), [added by the NIC], ..hdrtick)
    brace((3.25, -0.95), (14.75, -0.95), amplitude: 2.9888pt, mirror: true, draw: teal)
    node((9, -1.3), [what a capture shows], ..hdrtick, text: teal)
  })
]

#note[
  `Type` tells the receiver which Layer-3 protocol is inside:
  `0x0800` for IPv4, `0x0806` for ARP, `0x8100` for a
  VLAN-tagged frame. Wireshark reads this field to decide which dissector
  to run, which is why an unrecognised type shows as raw data.
]

== The IPv4 header

Four fields matter for these labs: the two addresses, the TTL that stops
routing loops, and the protocol number that identifies the payload.

#utpfig([The IPv4 header, drawn as the 32-bit rows Wireshark displays. Shaded fields are the ones the labs read or change.], label: <fig:ipv4-header>)[
  #canvas({
    let u = 0.36
    protorow(0, u, ((4, [Ver], hdrm), (4, [IHL], hdrm), (8, [DSCP + ECN], hdrm), (16, [Total length], hdrm)))
    protorow(-0.85, u, ((16, [Identification], hdrm), (3, [Flg], hdrm), (13, [Fragment offset], hdrm)))
    protorow(-1.7, u, ((8, [TTL], hdro), (8, [Protocol], hdro), (16, [Header checksum], hdrm)))
    protorow(-2.55, u, ((32, [Source IP address], hdrb),))
    protorow(-3.4, u, ((32, [Destination IP address], hdrb),))
    node((0, 0.62), [0], ..hdrtick, anchor: "west")
    node((5.76, 0.62), [16], ..hdrtick)
    node((11.52, 0.62), [31], ..hdrtick, anchor: "east")
    connect((0, 0.45), (11.52, 0.45), draw: mix(muted, 50%))
    node((11.9, -1.7), [#text(fill: orange)[#strong[TTL]] drops by 1 per hop. \
   #text(fill: orange)[#strong[Protocol]]: 1 ICMP, \
   6 TCP, 17 UDP, 89 OSPF.], anchor: "west", font: font("script", fill: muted), align: left)
    node((11.9, -2.98), [#text(fill: blue)[#strong[The pair a router]] \
   #text(fill: blue)[#strong[matches against its]] \
   #text(fill: blue)[#strong[routing table.]]], anchor: "west", font: font("script", fill: muted), align: left)
  })
]

== What each device reads

A device only decodes as far up as it needs to. This single fact
explains why a switch cannot fix a routing problem and why a VLAN
cannot be bypassed by changing a PC’s IP address.

#utpfig([How far up the stack each device looks. The dividing line between a switch and a router is the whole of Chapters~@ch:static-routing and~#ref(<ch:ospf>).], label: <fig:device-scope>)[
  #canvas({
    for (x, name, desc) in ((0, "Hub", "repeats bits"), (3.5, "Switch", "learns MAC"), (7, "Router", "reads IP"), (10.5, "Firewall", "reads ports")) {
      node((x + 0.9, 0.55), [#name], font: font("small", weight: "bold", fill: navy))
      node((x + 0.9, 0.15), [#desc], font: font("script", fill: muted))
    }
    for (y, lab-v, st) in ((-0.4, "Physical", hdrm), (-1.1, "Data Link", hdro), (-1.8, "Network", hdrb), (-2.5, "Transport", hdrg)) {
      node((-0.25, y), [#lab-v], ..st, min-width: 1.6, anchor: "east", font: font("script", fill: navy))
    }
    for (x, top) in ((0, 1), (3.5, 2), (7, 3), (10.5, 4)) {
      for i in range(1, 5) {
        let yy = -0.4 - (i - 1) * 0.7
        if i > top {
          node((x + 0.9, yy), [--], draw: mix(muted, 30%), fill: white, min-width: 1.8, min-height: 0.55, font: font("tiny", fill: mix(muted, 60%)))
        } else {
          node((x + 0.9, yy), [reads], draw: green, fill: pale-teal, min-width: 1.8, min-height: 0.55, font: font("tiny", weight: "bold", fill: green))
        }
      }
    }
  })
]

#note[
  A switch forwards on MAC addresses and never looks at an IP address.
  Two PCs in different VLANs stay unreachable however you renumber them,
  because the switch stops reading before it reaches the IP header.
]

== Collision and broadcast domains

The terms recur in Chapters~@ch:lacp and~#ref(<ch:vlan>). A hub gives
one collision domain and one broadcast domain. A switch gives one
collision domain per port but still one broadcast domain. Only a router
or a VLAN splits the broadcast domain.

#utpfig([What each device splits. The middle case is the one people get wrong: a switch gives every port its own collision domain but leaves the broadcast domain intact.], label: <fig:domains>)[
  #canvas({
    for (x, dev, coll, bcast) in ((0, "Hub", 1, 1), (5, "Switch", 4, 1), (10, "Router", 4, 4)) {
      node((x + 1.6, 1.5), [#dev], font: font("small", weight: "bold", fill: navy))
      node((x + 1.6, 0.75), [], font: font("script"), ..switch, min-width: 2.6)
      for i in range(0, 4) {
        node((x + 0.45 + i * 0.77, -0.35), [], ..host, min-width: 0.62, min-height: 0.42, font: font("tiny"))
        connect((x + 0.45 + i * 0.77, -0.15), (x + 0.45 + i * 0.77, 0.45), ..netlink)
      }
      node((x + 1.6, -1), [#strong[#coll] collision  \
   #strong[#bcast] broadcast], font: font("script"), align: center, text: muted)
    }
    draw.on-layer(-1, draw.scope({
      rectangle((-0.05, -0.62), (3.25, 0.42), ..bcastzone)
      for i in range(0, 4) {
        rectangle((5.15 + i * 0.77, -0.62), (5.75 + i * 0.77, 0.42), ..bcastzone)
      }
      for i in range(0, 4) {
        rectangle((10.15 + i * 0.77, -0.62), (10.75 + i * 0.77, 0.42), ..bcastalt)
      }
    }))
  })
]

#questions[
  + A packet crosses two routers. How many times is its destination
    MAC address rewritten, and how many times its destination IP?
  + Which header field would you check first to diagnose a routing loop?
  + A frame arrives with Type `0x8100`. What does the switch expect
    to find next, and which chapter configures it?
  + Why can a switch not resolve a problem caused by a missing static route?
]
