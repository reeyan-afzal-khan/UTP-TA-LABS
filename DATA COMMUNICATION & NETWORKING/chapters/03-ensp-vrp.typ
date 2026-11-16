#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-ensp-vrp")

= eNSP and Huawei VRP Fundamentals <ch:ensp-vrp>

#chapterguide[Lab 1 packet observation and basic IPv4 addressing concepts.][Build and start an eNSP topology, capture packets from an eNSP interface, navigate Huawei VRP views, name devices, configure router interfaces, verify state, ping a neighbor, and save a configuration.]

== eNSP workflow

eNSP provides a visual environment for building and testing IP networks: place devices, connect interfaces, configure them, start the topology, generate traffic, and inspect the result.

#utpfig([The eNSP main workspace, as shown in the supplied Lab~2A material.], label: <fig:ensp-home>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/ensp-home.png", width: 90%, height: 404.7848pt)
]

== The eNSP workspace

Four regions of the window do all the work. Everything in this book is
reached from one of them.

#utpfig([Where things are in eNSP. The right-click menu on a device is the one worth memorising: it is how you open a console, start a capture, and add an interface card.], label: <fig:ensp-workspace>)[
  #canvas({
    node((0, 3.1), [toolbar --- new, open, and the #strong[start / stop] buttons], ..hdrm, min-width: 13, min-height: 0.55, anchor: "west", font: font("script", fill: navy))
    node((0, 2.75), [#strong[device palette] \ #v(1.9925pt)
   routers \
   switches \
   end devices \
   connections], ..hdrb, min-width: 3, min-height: 2.9, anchor: "north-west", align: center, font: font("script", fill: navy))
    node((3.1, 2.75), [#strong[canvas] \ #v(2.9888pt)
   drag a device here, then drag a #emph[connection] from the palette \
   and click the two interfaces you want joined], ..hdrpay, min-width: 9.9, min-height: 2.9, anchor: "north-west", align: center, font: font("script"))
    node((3.1, -0.45), [#strong[right-click a device] \ #v(1.9925pt)
    • #strong[CLI] --- open the VRP console \
    • #strong[Settings] --- add an interface card \
    • #strong[Data Capture] --- start Wireshark on one interface], ..hdro, min-width: 6, min-height: 1.55, anchor: "north-west", align: left, font: font("script", fill: navy))
    connect((6.1, -0.5), (6.1, 0.1), line-width: widths.thick, draw: orange, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((9.4, -1.2), [A device must be #strong[started] before its CLI will respond.], font: font("tiny", fill: muted), anchor: "west", text-width: 3.5)
  })
]

== Which device to drag

The labs name interfaces such as `GigabitEthernet0/0/0` and
`Serial1/0/0` without saying which eNSP model provides them. These
are the models the exercises assume.

#utptable[
  #tabularx(
    columns: (15%, 17%, 24%, 1fr),
    styles: (navy-bold,),
    header: ([Palette item], [Model], [Interfaces you get], [Used in]),
    [Router], [AR2220], [3 $times$ GE, no serial by default], [Labs 2--6, 9],
    [Switch], [S5700], [24 $times$ GE], [Labs 7--8],
    [Switch], [S3700], [24 $times$ FE], [where 100 Mbit/s is wanted],
    [End device], [PC], [one Ethernet interface], [Labs 2, 6, 8],
    [End device], [Server], [one Ethernet interface], [FTP and DHCP work],
  )
]

#warning[
  The AR2220 ships with #emph[no serial interfaces]. Lab~@ch:wan calls
  for `Serial1/0/0`, so before starting that topology you must
  right-click each router, open #strong[Settings], and drag a #strong[2SA]
  module into an empty slot. The device has to be powered off to accept it.
  Skipping this produces #mono[Error: Wrong parameter found at ’^’ position]
  on the very first `interface Serial 1/0/0`, which reads like a typing
  mistake and is not one.
]

=== Picking the right cable

The connection palette offers several cable types. Two of them cover
everything in this book.

#utptable[
  #tabularx(
    columns: (17%, 26%, 1fr),
    styles: (navy-bold,),
    header: ([Cable], [Join], [Note]),
    [Auto], [anything to anything], [eNSP picks the correct type; use it unless the lab says otherwise.],
    [Copper], [Ethernet to Ethernet], [The explicit form of the same thing.],
    [Serial], [Serial to Serial], [Lab~@ch:wan only. The end you draw #emph[from] becomes the DCE.],
  )
]

#note[
  A red dot on an interface means the link is down; green means up. After
  pressing start, wait for both ends to turn green before opening a console.
  Half the “the command did not work” reports in these labs are a console
  opened on a device that had not finished booting.
]

== The topology-building loop

#utpsteps[
  + Drag the required hosts, routers, and switches onto the canvas.
  + Connect the specified interfaces with the correct medium.
  + Configure addresses through host settings or device consoles.
  + Start the devices and wait for them to finish booting.
  + Start Wireshark on the interface to be monitored.
  + Generate traffic, such as `ping <IP-address>`, and inspect it.
]

#note[
  Use this cycle throughout the course: #strong[build $arrow.r$ configure $arrow.r$ inspect $arrow.r$ test $arrow.r$ save].
]

== Huawei VRP views

VRP commands are organized into hierarchical views; the prompt identifies the active view.

#utptable[
  #tabularx(
    columns: (40%, 1fr),
    header: ([Prompt pattern], [Meaning]),
    [`<Huawei>`], [User view; commonly used for display, ping, save, and entry into system view.],
    [`[Huawei]` or `[R1]`], [System view; used for device-wide configuration and entry into protocol/interface views.],
    [`[R1-GigabitEthernet0/0/0]`], [Interface view; commands affect the selected interface.],
    [`[R1-ospf-1]`], [Protocol/process view; commands affect the selected routing process.],
  )
]

The table says which view you are in. The diagram says how to get to the
next one, which is the part that trips people up: `quit` goes up one
level, `return` goes all the way to user view.

#utpfig([Moving between VRP views. Every configuration command in this book is entered somewhere on this tree, and the prompt always tells you where you are.], label: <fig:vrp-views>)[
  #canvas({
    node((0, 0), [`<Huawei>`], name: "u", ..netstate, min-width: 2.6)
    node(below-of("u", 0.05), [user view], ..layernum)
    node((0, -1.7), [`[Huawei]`], name: "s", ..netstate, min-width: 2.6)
    node(below-of("s", 0.05), [system view], ..layernum)
    node((-2.9, -3.6), [`[R1-GigabitEthernet0/0/0]`], name: "i", ..netstate, min-width: 3.4, fill: pale-teal, draw: teal)
    node(below-of("i", 0.05), [interface view], ..layernum)
    node((1.55, -3.6), [`[R1-ospf-1]`], name: "o", ..netstate, min-width: 2.4, fill: pale-teal, draw: teal)
    node(below-of("o", 0.05), [protocol view], ..layernum)
    node((4.9, -3.6), [`[R1-vlan3]`], name: "v", ..netstate, min-width: 2, fill: pale-teal, draw: teal)
    node(below-of("v", 0.05), [VLAN view], ..layernum)
    connect((rel: (-0.35, 0), to: "u.south"), (rel: (-0.35, 0), to: "s.north"), ..stedge, draw: blue)
    node(along((rel: (-0.35, 0), to: "u.south"), (rel: (-0.35, 0), to: "s.north"), t: 50%), [`system-view`], ..stlabel, anchor: "east")
    connect((rel: (0.5, 0), to: "s.north"), (rel: (0.5, 0), to: "u.south"), ..stedge, draw: orange)
    node(along((rel: (0.5, 0), to: "s.north"), (rel: (0.5, 0), to: "u.south"), t: 50%), [`quit`], ..stlabel, anchor: "west")
    connect("s.south", "i.north", ..stedge, draw: blue)
    node(along("s.south", "i.north", t: 55%), [`interface g0/0/0`], ..stlabel, anchor: "south")
    connect("s.south", "o.north", ..stedge, draw: blue)
    node(along("s.south", "o.north", t: 62%), [`ospf 1`], ..stlabel, anchor: "west")
    connect("s.south", "v.north", ..stedge, draw: blue)
    node(along("s.south", "v.north", t: 60%), [`vlan 3`], ..stlabel, anchor: "south")
    connect("i.west", "u.west", bend: 55deg, ..stedge, draw: red, dash: "dashed", name: "curve-1")
    node((name: "curve-1", anchor: 50%), [`return`], ..stlabel, anchor: "east")
  })
]

#warning[
  A command rejected as unrecognised is usually a command typed in the
  wrong view rather than a command that does not exist. `ip route-static` only works in system view; `ip address` only works in
  interface view. Read the prompt before re-typing.
]

=== Reading an interface name

Huawei interface names look verbose but are positional, and the labs
abbreviate them constantly.

#utpfig([`GigabitEthernet0/0/0` decomposed. On the eNSP AR-series routers used here the first two numbers are almost always 0, so `g0/0/1` and `g0/0/2` are the names you will actually type.], label: <fig:iface-naming>)[
  #canvas({
    node((0, 0), [GigabitEthernet 0 / 0 / 0], name: "n", font: font("large", fill: navy, family: "mono"))
    connect((-1.65, -0.32), (-1.65, -0.75), (-2.6, -0.75), draw: muted)
    node((-2.62, -0.75), [media type \
   and speed], anchor: "east", font: font("script", fill: muted), align: right)
    connect((0.72, -0.32), (0.72, -1.25), draw: blue)
    node((0.72, -1.3), [slot], anchor: "north", font: font("script", fill: blue), align: center)
    connect((1.48, -0.32), (1.48, -1.25), draw: teal)
    node((1.48, -1.3), [subcard], anchor: "north", font: font("script", fill: teal), align: center)
    connect((2.25, -0.32), (2.25, -0.75), (3.2, -0.75), draw: orange)
    node((3.22, -0.75), [port on \
   that subcard], anchor: "west", font: font("script", fill: orange), align: left)
  })
]

== Direct-link practice

R1 and R3 share `10.0.13.0/24`, using `10.0.13.1` and `10.0.13.3`, respectively.

#utpfig([The directly connected R1--R3 topology from the supplied Lab~2B slide. Both routers sit on `10.0.13.0/24`.], label: <fig:vrp-direct-link-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/vrp-direct-link-topology.png", width: 82%, height: 404.7848pt)
]

=== Configure R1

```terminal
<Huawei> system-view
[Huawei] sysname R1
[R1] interface GigabitEthernet 0/0/0
[R1-GigabitEthernet0/0/0] ip address 10.0.13.1 24
[R1-GigabitEthernet0/0/0] description This interface connects to R3-G0/0/0
```

=== Configure R3

```terminal
<Huawei> system-view
[Huawei] sysname R3
[R3] interface GigabitEthernet 0/0/0
[R3-GigabitEthernet0/0/0] ip address 10.0.13.3 255.255.255.0
[R3-GigabitEthernet0/0/0] description This interface connects to R1-G0/0/0
```

The prefix `24` and mask `255.255.255.0` are equivalent.

== Verification commands

The single most useful command after addressing anything is
`display ip interface brief`: it lists every interface, its address,
and both state columns on one screen.

#vrpbox[\<R1\> display ip interface brief][
  #vrp(
    (raw("*down: administratively down"),),
    (raw("^down: standby"),),
    (raw("(l): loopback"),),
    (raw("(s): spoofing"),),
    (raw("The number of interface that is UP in Physical is 2"),),
    (raw("The number of interface that is DOWN in Physical is 1"),),
    (raw("The number of interface that is UP in Protocol is 2"),),
    (raw("The number of interface that is DOWN in Protocol is 1"),),
    (),
    (raw("Interface                   IP Address/Mask    "), [#hi[Physical]], raw("  "), [#hi[Protocol]]),
    (raw("GigabitEthernet0/0/0        10.0.13.1/24       "), [#higreen[up]], raw("        "), [#higreen[up]]),
    (raw("GigabitEthernet0/0/1        unassigned         "), [#hired[down]], raw("      "), [#hired[down]]),
    (raw("NULL0                       unassigned         up        up(s)"),),
  )
]

#vrpread[the two state columns fail for different reasons. `Physical down` is a cabling or shutdown problem. `Physical up` with `Protocol down` means the wire is fine and the agreement across it is not --- an encapsulation or authentication mismatch, which is exactly the fault Lab~@ch:wan produces on purpose.]

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    styles: ((font: "Source Code Pro", size: 0.88em),),
    header: ([Command], [Evidence]),
    [display this], [Configuration in the current view.],
    [display interface GigabitEthernet 0/0/0], [Detailed state, address, description, MTU, and counters.],
    [display ip interface brief], [Interface addresses and physical/protocol states.],
    [ping 10.0.13.3], [Layer-3 reachability from R1 to R3.],
    [save], [Store the current configuration.],
    [display saved-configuration], [Stored configuration.],
  )
]

#checklist[
  A healthy direct link has compatible addresses and reports both physical and protocol status as #strong[up]. Verify it with ping, then save the configuration.
]

== Command abbreviations from the lab

Use abbreviations only after learning the full commands.

#utptable[
  #tabularx(
    columns: (auto, auto),
    header: ([Full command], [Abbreviation shown]),
    [`system-view`], [`sys`],
    [`interface GigabitEthernet 0/0/0`], [`int g 0/0/0`],
    [`ip address 10.0.13.1 24`], [`ip add 10.0.13.1 24`],
    [`display`], [`disp`],
    [`quit`], [`q`],
    [`save`], [`save`],
  )
]

#warning[
  A failed ping is only a symptom. Check interface state first: physical down indicates a link problem; physical up/protocol down points to configuration or peer state. Investigate routing only after the direct link is healthy.
]

#exercises[
  Build the small switch-and-two-PC topology requested in the Lab 2B material. Assign compatible IPv4 addresses, use `ipconfig` on both PCs, verify connectivity with `ping`, and capture a readable screenshot of the command panel showing the result.
]
