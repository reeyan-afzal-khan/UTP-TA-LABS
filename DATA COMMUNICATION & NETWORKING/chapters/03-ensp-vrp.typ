#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-ensp-vrp")


#heading(level: 1)[eNSP and Huawei VRP Fundamentals]
<ch:ensp-vrp> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Lab 1 packet observation and basic IPv4 addressing concepts.

*By the end, you can:* Build and start an eNSP topology, capture packets from an eNSP interface, navigate Huawei VRP views, name devices, configure router interfaces, verify state, ping a neighbor, and save a configuration.]


#heading(level: 2)[eNSP workflow]
 eNSP provides a visual environment for building and testing IP networks: place devices, connect interfaces, configure them, start the topology, generate traffic, and inspect the result.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/ensp-home.png", width: 90%)], caption: [The eNSP main workspace, as shown in the supplied Lab~2A material.]) <fig:ensp-home>


#heading(level: 2)[The eNSP workspace]
 Four regions of the window do all the work. Everything in this book is reached from one of them.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/7a1611026105b713.cetz.json")], caption: [Where things are in eNSP. The right-click menu on a device is the one worth memorising: it is how you open a console, start a capture, and add an interface card.]) <fig:ensp-workspace>


#heading(level: 2)[Which device to drag]
 The labs name interfaces such as `GigabitEthernet0/0/0` and `Serial1/0/0` without saying which eNSP model provides them. These are the models the exercises assume.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Palette item], [Model], [Interfaces you get], [Used in],),
    table.hline(),
    [Router], [AR2220], [3 $times$ GE, no serial by default], [Labs 2--6, 9],
    [Switch], [S5700], [24 $times$ GE], [Labs 7--8],
    [Switch], [S3700], [24 $times$ FE], [where 100 Mbit/s is wanted],
    [End device], [PC], [one Ethernet interface], [Labs 2, 6, 8],
    [End device], [Server], [one Ethernet interface], [FTP and DHCP work],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[The AR2220 ships with #emph[no serial interfaces]. Lab~#ref(label("ch:wan"), supplement: none) calls for `Serial1/0/0`, so before starting that topology you must right-click each router, open #strong[Settings], and drag a #strong[2SA] module into an empty slot. The device has to be powered off to accept it. Skipping this produces `Error: Wrong parameter found at ’^’ position` on the very first `interface Serial 1/0/0`, which reads like a typing mistake and is not one.]


#heading(level: 3)[Picking the right cable]
 The connection palette offers several cable types. Two of them cover everything in this book.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Cable], [Join], [Note],),
    table.hline(),
    [Auto], [anything to anything], [eNSP picks the correct type; use it unless the lab says otherwise.],
    [Copper], [Ethernet to Ethernet], [The explicit form of the same thing.],
    [Serial], [Serial to Serial], [Lab~#ref(label("ch:wan"), supplement: none) only. The end you draw #emph[from] becomes the DCE.],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[A red dot on an interface means the link is down; green means up. After pressing start, wait for both ends to turn green before opening a console. Half the "the command did not work" reports in these labs are a console opened on a device that had not finished booting.]


#heading(level: 2)[The topology-building loop]


+ Drag the required hosts, routers, and switches onto the canvas.

+ Connect the specified interfaces with the correct medium.

+ Configure addresses through host settings or device consoles.

+ Start the devices and wait for them to finish booting.

+ Start Wireshark on the interface to be monitored.

+ Generate traffic, such as `ping <IP-address>`, and inspect it.

#callout("keyidea", title: [Key idea])[Use this cycle throughout the course: #strong[build $arrow.r$ configure $arrow.r$ inspect $arrow.r$ test $arrow.r$ save].]


#heading(level: 2)[Huawei VRP views]
 VRP commands are organized into hierarchical views; the prompt identifies the active view.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Prompt pattern], [Meaning],),
    table.hline(),
    [`<Huawei>`], [User view; commonly used for display, ping, save, and entry into system view.],
    [`[Huawei]` or `[R1]`], [System view; used for device-wide configuration and entry into protocol/interface views.],
    [`[R1-GigabitEthernet0/0/0]`], [Interface view; commands affect the selected interface.],
    [`[R1-ospf-1]`], [Protocol/process view; commands affect the selected routing process.],
  )]
  , kind: table
  )

The table says which view you are in. The diagram says how to get to the next one, which is the part that trips people up: `quit` goes up one level, `return` goes all the way to user view.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/5bbd9057e26eb9f8.cetz.json")], caption: [Moving between VRP views. Every configuration command in this book is entered somewhere on this tree, and the prompt always tells you where you are.]) <fig:vrp-views>

#callout("pitfall", title: [Common mistake])[A command rejected as unrecognised is usually a command typed in the wrong view rather than a command that does not exist. `ip route-static` only works in system view; `ip address` only works in interface view. Read the prompt before re-typing.]


#heading(level: 3)[Reading an interface name]
 Huawei interface names look verbose but are positional, and the labs abbreviate them constantly.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/39fabcdc25f3b9b0.cetz.json")], caption: [`GigabitEthernet0/0/0` decomposed. On the eNSP AR-series routers used here the first two numbers are almost always 0, so `g0/0/1` and `g0/0/2` are the names you will actually type.]) <fig:iface-naming>


#heading(level: 2)[Direct-link practice]
 R1 and R3 share `10.0.13.0/24`, using `10.0.13.1` and `10.0.13.3`, respectively.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/vrp-direct-link-topology.png", width: 90%)], caption: [The directly connected R1--R3 topology from the supplied Lab~2B slide. Both routers sit on `10.0.13.0/24`.]) <fig:vrp-direct-link-topology>


#heading(level: 3)[Configure R1]
 #code-block("<Huawei> system-view\n[Huawei] sysname R1\n[R1] interface GigabitEthernet 0/0/0\n[R1-GigabitEthernet0/0/0] ip address 10.0.13.1 24\n[R1-GigabitEthernet0/0/0] description This interface connects to R3-G0/0/0", lang: "text")


#heading(level: 3)[Configure R3]
 #code-block("<Huawei> system-view\n[Huawei] sysname R3\n[R3] interface GigabitEthernet 0/0/0\n[R3-GigabitEthernet0/0/0] ip address 10.0.13.3 255.255.255.0\n[R3-GigabitEthernet0/0/0] description This interface connects to R1-G0/0/0", lang: "text")

The prefix `24` and mask `255.255.255.0` are equivalent.


#heading(level: 2)[Verification commands]
 The single most useful command after addressing anything is `display ip interface brief`: it lists every interface, its address, and both state columns on one screen.

#callout("vrpbox", title: [])[\<R1\> display ip interface brief #code-block("*down: administratively down\n^down: standby\n(l): loopback\n(s): spoofing\nThe number of interface that is UP in Physical is 2\nThe number of interface that is DOWN in Physical is 1\nThe number of interface that is UP in Protocol is 2\nThe number of interface that is DOWN in Protocol is 1\n\nInterface                   IP Address/Mask    (*\\hi{Physical}*)  (*\\hi{Protocol}*)\nGigabitEthernet0/0/0        10.0.13.1/24       (*\\higreen{up}*)        (*\\higreen{up}*)\nGigabitEthernet0/0/1        unassigned         (*\\hired{down}*)      (*\\hired{down}*)\nNULL0                       unassigned         up        up(s)", lang: "text")] the two state columns fail for different reasons. `Physical down` is a cabling or shutdown problem. `Physical up` with `Protocol down` means the wire is fine and the agreement across it is not --- an encapsulation or authentication mismatch, which is exactly the fault Lab~#ref(label("ch:wan"), supplement: none) produces on purpose.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Command], [Evidence],),
    table.hline(),
    [display this], [Configuration in the current view.],
    [display interface GigabitEthernet 0/0/0], [Detailed state, address, description, MTU, and counters.],
    [display ip interface brief], [Interface addresses and physical/protocol states.],
    [ping 10.0.13.3], [Layer-3 reachability from R1 to R3.],
    [save], [Store the current configuration.],
    [display saved-configuration], [Stored configuration.],
  )]
  , kind: table
  )

#callout("verification", title: [Verification checklist])[A healthy direct link has compatible addresses and reports both physical and protocol status as #strong[up]. Verify it with ping, then save the configuration.]


#heading(level: 2)[Command abbreviations from the lab]
 Use abbreviations only after learning the full commands. #figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Full command], [Abbreviation shown],),
    table.hline(),
    [`system-view`], [`sys`],
    [`interface GigabitEthernet 0/0/0`], [`int g 0/0/0`],
    [`ip address 10.0.13.1 24`], [`ip add 10.0.13.1 24`],
    [`display`], [`disp`],
    [`quit`], [`q`],
    [`save`], [`save`],
  )]
  , kind: table
  )

#callout("pitfall", title: [Common mistake])[A failed ping is only a symptom. Check interface state first: physical down indicates a link problem; physical up/protocol down points to configuration or peer state. Investigate routing only after the direct link is healthy.]

#callout("tryit", title: [Try it yourself])[Build the small switch-and-two-PC topology requested in the Lab 2B material. Assign compatible IPv4 addresses, use `ipconfig` on both PCs, verify connectivity with `ping`, and capture a readable screenshot of the command panel showing the result.]
