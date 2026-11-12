#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-lacp")

= Ethernet Link Aggregation and LACP <ch:lacp>

#chapterguide[Switch CLI navigation and Ethernet interface configuration.][Set interface speed manually, create an Eth-Trunk, compare manual aggregation with static LACP, explain system/interface priority, and verify active member links.]

== Why aggregate Ethernet links?

Link aggregation combines physical Ethernet links into one logical connection. LACP coordinates membership and reacts to member failure or recovery.

#utpfig([Link aggregation between a switch and a server: several physical links act as one logical connection.], label: <fig:lacp-switch-server>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/lacp-switch-server.png", width: 86%, height: 404.7848pt)
]

#utpfig([Two physical links presented as one logical link between two switches.], label: <fig:lacp-switch-switch>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/lacp-switch-switch.png", width: 82%, height: 303.5886pt)
]

#keyidea[
  An Eth-Trunk is the logical bundle; its physical interfaces are members. LACP coordinates the active set between peers.
]

=== Two 1 Gbit/s links do not make one 2 Gbit/s link

Aggregation adds capacity, not speed. The switch hashes each
conversation onto one member and keeps it there, so a single file
transfer is still capped at the rate of one physical link. Frames must
stay in order, and splitting one flow across two links would reorder
them.

#utpfig([Four conversations spread across two members. Any one of them uses a single link; the aggregate benefit only appears once there are several flows.], label: <fig:lacp-hash>)[
  #canvas({
    node((0, 0), [S1], name: "s1", ..switch, min-width: 1.5, min-height: 2.4)
    node((7.4, 0), [S2], name: "s2", ..switch, min-width: 1.5, min-height: 2.4)
    connect((0.78, 0.45), (6.6, 0.45), line-width: 1.9925pt, draw: blue)
    connect((0.78, -0.45), (6.6, -0.45), line-width: 1.9925pt, draw: teal)
    node((3.7, 0.72), [member 1 --- G0/0/9], ..costlabel, text: blue)
    node((3.7, -0.72), [member 2 --- G0/0/10], ..costlabel, text: teal)
    node((-1, 0.75), [flow A #text(fill: blue)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
    node((-1, 0.25), [flow B #text(fill: teal)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
    node((-1, -0.25), [flow C #text(fill: blue)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
    node((-1, -0.75), [flow D #text(fill: teal)[$bullet$]], anchor: "east", font: font("script", fill: ink), align: right)
    node((8.3, 0.2), [The hash uses source and destination addresses, so a given pair always takes the same member.], anchor: "west", font: font("script", fill: muted), text-width: 4, align: left)
    node((3.7, -1.5), [Two flows land on each link here. With one flow, one link would sit idle --- which is the usual reason a bandwidth test on a new trunk disappoints.], anchor: "north", font: font("tiny", fill: muted), align: center, text-width: 11)
  })
]

== Priority concepts used by the source

The lab uses two priorities; for both, #strong[smaller values have higher priority].

#utptable[
  #tabularx(
    columns: (35%, 1fr),
    styles: (navy-bold,),
    header: ([Priority], [Role in the lab]),
    [LACP system priority], [Helps select the device that controls active-link selection.],
    [LACP interface priority], [Ranks candidate member interfaces.],
  )
]

== Lab topology

S1 and S2 are connected using two member links, `G0/0/9` and `G0/0/10`. The bundle is represented as `Eth-Trunk 1`.

#utpfig([The Ethernet link-aggregation topology from the supplied Lab~7 slide. S1 and S2 join over `G0/0/9` and `G0/0/10`, bundled as `Eth-Trunk 1`.], label: <fig:lacp-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/lacp-topology.png", width: 76%, height: 404.7848pt)
]

== Prepare the physical interfaces

The exercise disables auto-negotiation and sets both member links to 100 Mbit/s on each switch.

```terminal
[S1] interface GigabitEthernet 0/0/9
[S1-GigabitEthernet0/0/9] undo negotiation auto
[S1-GigabitEthernet0/0/9] speed 100
[S1] interface GigabitEthernet 0/0/10
[S1-GigabitEthernet0/0/10] undo negotiation auto
[S1-GigabitEthernet0/0/10] speed 100
```

Configure S2 identically, then verify both interfaces with `display interface`.

== Manual link aggregation

First create Eth-Trunk 1 and add both interfaces manually.

```terminal
[S1] interface Eth-Trunk 1
[S1-Eth-Trunk1] quit
[S1] interface GigabitEthernet 0/0/9
[S1-GigabitEthernet0/0/9] eth-trunk 1
[S1] interface GigabitEthernet 0/0/10
[S1-GigabitEthernet0/0/10] eth-trunk 1
```

Repeat on S2.

== Rebuild the bundle in static LACP mode

Remove the manual memberships with `undo eth-trunk`, then rebuild the trunk in LACP mode.

```terminal
[S1] interface Eth-Trunk 1
[S1-Eth-Trunk1] mode lacp
[S1] interface GigabitEthernet 0/0/9
[S1-GigabitEthernet0/0/9] eth-trunk 1
[S1] interface GigabitEthernet 0/0/10
[S1-GigabitEthernet0/0/10] eth-trunk 1
```

Repeat on S2.

== Manipulate LACP priorities

Set S1’s system and member-interface priorities to 100.

```terminal
[S1] lacp priority 100
[S1] interface GigabitEthernet 0/0/9
[S1-GigabitEthernet0/0/9] lacp priority 100
[S1] interface GigabitEthernet 0/0/10
[S1-GigabitEthernet0/0/10] lacp priority 100
```

=== How the two priorities combine

The election happens twice, in order. First the two switches decide
which of them is in charge; only then does that switch rank the
individual links. Interface priority on the losing switch is ignored
entirely, which is why changing it there appears to do nothing.

#utpfig([The two-stage election. Lower values win at both stages, and a tie falls back to the MAC address or the interface number.], label: <fig:lacp-election>)[
  #canvas({
    node((-0.4, 1.6), [#strong[1\.] Which switch decides?], font: font("script", weight: "bold", fill: navy), anchor: "west")
    node((0.6, 0.55), [S1], name: "a", ..switch, min-width: 1.7, fill: pale-teal, draw: green, line-width: 0.9963pt)
    node((4, 0.55), [S2], name: "b", ..switch, min-width: 1.7)
    node(below-of("a", 0.1), [system priority #strong[100] \
   lower --- S1 wins], font: font("tiny", fill: green), align: center)
    node(below-of("b", 0.1), [system priority #strong[32768] \
   default], font: font("tiny", fill: muted), align: center)
    connect("a", "b", ..stedge)
    connect((6, -1.5), (6, 1.8), draw: mix(muted, 35%))
    node((6.5, 1.6), [#strong[2\.] S1 then ranks the links], font: font("script", weight: "bold", fill: navy), anchor: "west")
    node((6.5, 0.75), [G0/0/9   priority 100], ..hdrg, min-width: 3, anchor: "west")
    node((6.5, 0.05), [G0/0/10  priority 100], ..hdrg, min-width: 3, anchor: "west")
    node((6.5, -0.65), [G0/0/11  priority 32768], ..hdrm, min-width: 3, anchor: "west")
    node((9.7, 0.75), [active], font: font("tiny", fill: green), anchor: "west")
    node((9.7, 0.05), [active], font: font("tiny", fill: green), anchor: "west")
    node((9.7, -0.65), [standby], font: font("tiny", fill: muted), anchor: "west")
    node((-0.4, -2), [S2 simply accepts the result. Its own interface priorities are never consulted, so a bundle that will not form the way you expect is usually a system-priority question, not an interface one.], font: font("tiny", fill: muted), anchor: "west", text-width: 11)
  })
]

== Verify the Eth-Trunk

Eth-Trunk output confirms the mode, member state, and actor/partner information.

#vrpbox[\<S1\> display eth-trunk 1][
  #vrp(
    (raw("Eth-Trunk1's state information is:"),),
    (raw("Local:"),),
    (raw("LAG ID: 1                    WorkingMode: "), [#hi[STATIC]]),
    (raw("Preempt Delay: Disabled      Hash arithmetic: According to SIP-XOR-DIP"),),
    ([#hi[System Priority: 100]], raw("       System ID: 4c1f-cc11-1111")),
    (raw("Least Active-linknumber: 1   Max Active-linknumber: 8"),),
    (raw("Operate status: "), [#higreen[up]], raw("           Number Of Up Port In Trunk: "), [#higreen[2]]),
    (raw("--------------------------------------------------------------------------------"),),
    (raw("ActorPortName          Status    PortType PortPri PortNo PortKey PortState"),),
    (raw("GigabitEthernet0/0/9   "), [#higreen[Selected]], raw("  1GE      "), [#hi[100]], raw("     10     305     10111100")),
    (raw("GigabitEthernet0/0/10  "), [#higreen[Selected]], raw("  1GE      "), [#hi[100]], raw("     11     305     10111100")),
    (),
    (raw("Partner:"),),
    (raw("--------------------------------------------------------------------------------"),),
    (raw("ActorPortName          SysPri  SystemID        PortPri PortNo PortKey PortState"),),
    (raw("GigabitEthernet0/0/9   32768   4c1f-cc22-2222  32768   10     305     10111100"),),
    (raw("GigabitEthernet0/0/10  32768   4c1f-cc22-2222  32768   11     305     10111100"),),
  )
]

#vrpread[`WorkingMode: STATIC` proves LACP is running rather than manual aggregation. `Selected` is the word that matters for each member --- `Unselect` means the port joined the trunk but is not carrying traffic. The `Partner` block shows S2 still at the default 32768, which is why S1 won the election in #figref(<fig:lacp-election>).]

#verification[
  Confirm that Eth-Trunk 1 exists on both switches, uses LACP, contains G0/0/9 and G0/0/10, and shows the expected selected members.
]

== Troubleshooting order

#utpsteps[
  + Confirm the physical interfaces are up and use compatible speed/negotiation settings.
  + Confirm the same member links are assigned to Eth-Trunk 1 on both switches.
  + Confirm both sides use the same aggregation mode.
  + Inspect LACP system/interface priorities if active-link selection is not what the lab expects.
  + Use Eth-Trunk display output rather than checking only individual interfaces.
]

#pitfall[
  A physical link may be up but excluded from the bundle when membership or LACP mode differs across peers. Verify the logical trunk on both ends.
]

#quickcheck[
  + What is the difference between a physical member interface and an Eth-Trunk?
  + Why does the source disable auto-negotiation before forcing 100 Mbit/s?
  + Which numerical priority is higher: 100 or 32768, according to the lab’s rule?
  + What extra capability does static LACP add compared with manual aggregation?
]
