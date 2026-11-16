#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-vlan")

= VLAN Configuration: Access, Trunk, and Hybrid Ports <ch:vlan>

#chapterguide[Ethernet switch configuration and Eth-Trunk/LACP concepts from Lab 7.][Create VLANs, bind access ports, turn the inter-switch Eth-Trunk into a VLAN trunk, configure hybrid ports and PVID behavior, and verify same-VLAN and controlled cross-VLAN communication.]

== Purpose of VLANs

VLANs create separate Layer-2 broadcast domains on shared switches. Hosts in different VLANs remain isolated unless the design deliberately connects them.

#utpfig([The VLAN topology from the supplied Lab~8 slide.], label: <fig:vlan-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/vlan-topology.png", width: 88%, height: 404.7848pt)
]

== Three port behaviors used in the exercise

#utptable[
  #tabularx(
    columns: (23%, 1fr),
    styles: (navy-bold,),
    header: ([Port type], [Role in the supplied lab]),
    [Access], [Connects an untagged host to one VLAN.],
    [Trunk], [Carries multiple VLANs between switches.],
    [Hybrid], [Controls tagging per VLAN and classifies untagged ingress by PVID.],
  )
]

#utpfig([Where the VLAN tag is added, carried, and removed. The tag exists only between the switches. Hosts never see it, which is why a VLAN needs no configuration on the PC --- and why the switch, not the host, decides which VLAN a frame belongs to.], label: <fig:vlan-tag>)[
  #canvas({
    node((0, 0), [PC1], name: "pc1", ..host)
    node(right-of("pc1", 1.5), [SW1], name: "sw1", ..switch)
    node(right-of("sw1", 2.9), [SW2], name: "sw2", ..switch)
    node(right-of("sw2", 1.5), [PC3], name: "pc3", ..host)
    connect("pc1", "sw1", ..flowarrow)
    node(along("pc1", "sw1", t: 50%), [access], ..netlabel, anchor: "south")
    connect("sw1", "sw2", ..flowarrow)
    node(along("sw1", "sw2", t: 50%), [trunk], ..netlabel, anchor: "south")
    connect("sw2", "pc3", ..flowarrow)
    node(along("sw2", "pc3", t: 50%), [access], ..netlabel, anchor: "south")
    node(below-of("pc1", 0.8), [#strong[no tag] \
   #fsize("tiny")[the host has no idea VLANs exist]], ..netframe, text-width: 1.9, align: center)
    node(below-of(("sw1", 50%, "sw2"), 0.8), [#strong[tag = VLAN 10] \
   #fsize("tiny")[added on entry, so the far switch knows]], ..netframe, text-width: 2.5, align: center, draw: blue, fill: pale-blue)
    node(below-of("pc3", 0.8), [#strong[no tag] \
   #fsize("tiny")[stripped again on the way out]], ..netframe, text-width: 1.9, align: center)
    connect((rel: (0, -0.35), to: "pc1"), (rel: (0, -0.75), to: "pc1"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
    connect((rel: (0, -0.2), to: ("sw1", 50%, "sw2")), (rel: (0, -0.68), to: ("sw1", 50%, "sw2")), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
    connect((rel: (0, -0.35), to: "pc3"), (rel: (0, -0.75), to: "pc3"), draw: muted, dash: "dotted", end: arrow-tip("to", line: 0.4pt))
  })
]

#note[
  A VLAN is enforced by the switch, not by the host’s IP address. Two PCs can share a subnet and still be unable to reach each other if they sit in different VLANs --- changing the PC’s address cannot bypass the separation.
]

=== What the tag actually is

The tag is four bytes pushed into the Ethernet header between the source
address and the type field. Twelve of its bits carry the VLAN ID, which
is why the usable range stops at 4094.

#utpfig([An 802.1Q tag inserted into the Ethernet II frame from #figref(<fig:eth-frame>). The frame grows by four bytes, which is why a trunk port needs an MTU four bytes larger than its access ports.], label: <fig:dot1q>)[
  #canvas({
    let u = 0.4
    node((-0.15, 0), [untagged], anchor: "east", font: font("script", weight: "bold", fill: muted))
    protorow(0, u, ((6, [Destination MAC], hdrb), (6, [Source MAC], hdrb), (2, [Type], hdro), (8, [Payload], hdrpay), (4, [FCS], hdrg)))
    node((-0.15, -1.35), [tagged], anchor: "east", font: font("script", weight: "bold", fill: navy))
    protorow(-1.35, u, ((6, [Destination MAC], hdrb), (6, [Source MAC], hdrb), (4, [802.1Q tag], hdrr), (2, [Type], hdro), (8, [Payload], hdrpay), (4, [FCS], hdrg)))
    connect((4.85, -0.42), (4.85, -0.95), draw: red, line-width: widths.thick, end: arrow-tip("Stealth", length: 2mm, line: widths.thick))
    node((5, -0.68), [4 bytes inserted here], font: font("tiny", fill: red), anchor: "west")
    let vv = 1.05
    protorow(-3, vv, ((2, [TPID 0x8100], hdrr), (0.35, [PCP], hdrm), (0.15, [D], hdrm), (1.4, [VLAN ID], hdrb)))
    prototicks(-3.62, vv, ((2, [16 bits]), (0.35, [3]), (0.15, [1]), (1.4, [12 bits])))
    connect((3.6, -1.62), (0, -2.62), draw: red, dash: "dotted")
    connect((5.2, -1.62), (4.09, -2.62), draw: red, dash: "dotted")
    node((4.5, -3.15), [#strong[TPID] `0x8100` marks the frame as tagged. \
   #strong[PCP] is the priority field used by QoS. \
   #strong[VLAN ID] 12 bits $arrow.r$ 1--4094 usable.], anchor: "west", font: font("script", fill: muted), text-width: 5.4, align: left)
  })
]

== Step 1: build the inter-switch Eth-Trunk

Build static-LACP Eth-Trunk 1 with G0/0/9 and G0/0/10. The source shows both physical-interface membership and `trunkport` from the Eth-Trunk view.

```terminal
[S1] interface Eth-Trunk 1
[S1-Eth-Trunk1] mode lacp
[S1] interface GigabitEthernet 0/0/9
[S1-GigabitEthernet0/0/9] eth-trunk 1
[S1] interface GigabitEthernet 0/0/10
[S1-GigabitEthernet0/0/10] eth-trunk 1

[S2] interface Eth-Trunk 1
[S2-Eth-Trunk1] mode lacp
[S2-Eth-Trunk1] trunkport GigabitEthernet 0/0/9
[S2-Eth-Trunk1] trunkport GigabitEthernet 0/0/10
```

== Step 2: make Eth-Trunk 1 a VLAN trunk

```terminal
[S1] interface Eth-Trunk 1
[S1-Eth-Trunk1] port link-type trunk
[S1-Eth-Trunk1] port trunk allow-pass vlan all

[S2] interface Eth-Trunk 1
[S2-Eth-Trunk1] port link-type trunk
[S2-Eth-Trunk1] port trunk allow-pass vlan all
```

#note[
  Eth-Trunk aggregates links; trunk mode carries VLANs. These are separate functions on the same logical interface.
]

== Step 3: create VLANs and bind access interfaces

The lab demonstrates two Huawei VRP configuration styles.

On S1, G0/0/13 is associated with VLAN 3 and G0/0/1 with VLAN 4:

```terminal
[S1] interface GigabitEthernet 0/0/13
[S1-GigabitEthernet0/0/13] port link-type access
[S1] interface GigabitEthernet 0/0/1
[S1-GigabitEthernet0/0/1] port link-type access
[S1] vlan 2
[S1-vlan2] vlan 3
[S1-vlan3] port GigabitEthernet 0/0/13
[S1-vlan3] vlan 4
[S1-vlan4] port GigabitEthernet 0/0/1
```

On S2, the source uses `vlan batch` and `port default vlan`:

```terminal
[S2] vlan batch 2 to 4
[S2] interface GigabitEthernet 0/0/3
[S2-GigabitEthernet0/0/3] port link-type access
[S2-GigabitEthernet0/0/3] port default vlan 4
[S2] interface GigabitEthernet 0/0/6
[S2-GigabitEthernet0/0/6] port link-type access
[S2-GigabitEthernet0/0/6] port default vlan 2
```

== Step 4: address the hosts and verify VLAN isolation

Hosts in the same VLAN use a common subnet. Initially, R1 and R3 in VLAN 4 should communicate; hosts in different VLANs should not.

#vrpbox[\<S1\> display vlan][
  #vrp(
    (raw("The total number of vlans is : 4"),),
    (raw("--------------------------------------------------------------------------------"),),
    (raw("U: Up;          D: Down;         TG: Tagged;         UT: Untagged;"),),
    (raw("MP: Vlan-mapping;                ST: Vlan-stacking;"),),
    (raw("--------------------------------------------------------------------------------"),),
    (raw("VID  Type     Ports"),),
    (raw("--------------------------------------------------------------------------------"),),
    (raw("1    common   UT:GE0/0/2(U)     GE0/0/4(U)      GE0/0/5(U)"),),
    (raw("2    common   "), [#hi[TG:Eth-Trunk1(U)]]),
    (raw("3    common   "), [#hi[UT:GE0/0/13(U)]], raw("   TG:Eth-Trunk1(U)")),
    (raw("4    common   "), [#hi[UT:GE0/0/1(U)]], raw("    TG:Eth-Trunk1(U)")),
  )
]

#vrpread[`UT` is an access or untagged port, `TG` a tagged one. Every VLAN lists `Eth-Trunk1` as `TG`, which is what `port trunk allow-pass vlan all` did. A VLAN missing from this table cannot carry traffic however the host is addressed.]

Then test both outcomes on the hosts: a ping inside one VLAN, and a ping
across two.

#vrpbox[\<R1\> ping 10.0.4.3 #h(1em);(same VLAN, expected to succeed)][
  #vrp(
    (raw("  PING 10.0.4.3: 56  data bytes, press CTRL_C to break"),),
    (raw("    Reply from 10.0.4.3: bytes=56 Sequence=1 ttl=255 time=30 ms"),),
    (raw("    Reply from 10.0.4.3: bytes=56 Sequence=2 ttl=255 time=20 ms"),),
    (),
    (raw("  --- 10.0.4.3 ping statistics ---"),),
    (raw("    5 packet(s) transmitted, "), [#higreen[5 packet(s) received]], raw(", "), [#higreen[0.00% packet loss]]),
  )
]

#vrpbox[\<R1\> ping 10.0.3.2 #h(1em);(different VLAN, expected to fail)][
  #vrp(
    (raw("  PING 10.0.3.2: 56  data bytes, press CTRL_C to break"),),
    (raw("    Request time out"),),
    (raw("    Request time out"),),
    (),
    (raw("  --- 10.0.3.2 ping statistics ---"),),
    (raw("    5 packet(s) transmitted, 0 packet(s) received, "), [#hired[100.00% packet loss]]),
  )
]

#vrpread[the second result is a pass, not a failure. A VLAN lab needs both transcripts, because only the failing one proves the isolation works.]

#checklist[
  Test both outcomes: same-VLAN connectivity and different-VLAN isolation before adding hybrid behavior.
]

== Step 5: change selected ports to hybrid mode

Hybrid ports then deliver VLAN 2 and VLAN 4 traffic untagged to selected devices.

```terminal
[S1] interface GigabitEthernet 0/0/1
[S1-GigabitEthernet0/0/1] port link-type hybrid
[S1-GigabitEthernet0/0/1] port hybrid untagged vlan 2 4
[S1-GigabitEthernet0/0/1] port hybrid pvid vlan 4

[S2] interface GigabitEthernet 0/0/3
[S2-GigabitEthernet0/0/3] port link-type hybrid
[S2-GigabitEthernet0/0/3] port hybrid untagged vlan 2 4
[S2-GigabitEthernet0/0/3] port hybrid pvid vlan 4

[S2] interface GigabitEthernet 0/0/6
[S2-GigabitEthernet0/0/6] port link-type hybrid
[S2-GigabitEthernet0/0/6] port hybrid untagged vlan 2 4
[S2-GigabitEthernet0/0/6] port hybrid pvid vlan 2
```

== PVID and untagged behavior

The commands are complementary:

- `port hybrid pvid vlan <id>` assigns a VLAN classification to untagged frames received from the host.
- `port hybrid untagged vlan 2 4` permits frames from the listed VLANs to leave that host-facing port without a VLAN tag.

Retest reachability: the selected VLAN-2 and VLAN-4 hosts should communicate, while the VLAN-3 host remains isolated.

#utpfig([The same two questions asked of all three port types. Access and trunk are special cases of hybrid, which is why hybrid is the only one that needs two separate commands.], label: <fig:port-types>)[
  #canvas({
    node((2.5, 0.9), [Untagged frame arrives], font: font("script", weight: "bold", fill: navy), anchor: "west")
    node((7.6, 0.9), [Frame leaves the port], font: font("script", weight: "bold", fill: navy), anchor: "west")
    node((2.3, 0), [Access], anchor: "east", font: font("script", weight: "bold", fill: navy))
    node((2.5, 0), [tagged with the port’s single VLAN], ..hdrb, min-width: 4.9, anchor: "west", min-height: 1, font: font("script", fill: navy))
    node((7.55, 0), [tag removed, always untagged], ..hdrg, min-width: 5.3, anchor: "west", min-height: 1, font: font("script", fill: navy))
    node((2.3, -1.15), [Trunk], anchor: "east", font: font("script", weight: "bold", fill: navy))
    node((2.5, -1.15), [tagged with the PVID (the native VLAN)], ..hdrb, min-width: 4.9, anchor: "west", min-height: 1, font: font("script", fill: navy))
    node((7.55, -1.15), [tagged, except the native VLAN], ..hdrg, min-width: 5.3, anchor: "west", min-height: 1, font: font("script", fill: navy))
    node((2.3, -2.3), [Hybrid], anchor: "east", font: font("script", weight: "bold", fill: navy))
    node((2.5, -2.3), [tagged with `port hybrid pvid vlan`], ..hdrb, min-width: 4.9, anchor: "west", min-height: 1, font: font("script", fill: navy))
    node((7.55, -2.3), [per VLAN: `tagged` or `untagged`], ..hdrg, min-width: 5.3, anchor: "west", min-height: 1, font: font("script", fill: navy))
  })
]

#note[
  The two hybrid commands answer the two different questions above.
  `port hybrid pvid vlan <id>` answers the ingress question; `port hybrid untagged vlan 2 4` answers the egress one. Setting one without
  the other is the usual cause of a hybrid port that half works.
]

== The native-VLAN mismatch: a leak that reports no error

A trunk sends exactly one VLAN #emph[untagged] --- the native VLAN, taken from the port’s PVID. If the two ends disagree about which VLAN that is, each switch files the untagged frames into a different VLAN, and two supposedly isolated VLANs are joined.

#utpfig([A mismatched native VLAN silently merges two VLANs. Each switch files untagged frames into its own PVID, so VLAN~10 traffic arrives in VLAN~20 while both configurations look correct.], label: <fig:vlan-native-mismatch>)[
  #canvas({
    node((0, 0), [SW1], name: "s1", ..switch)
    node(right-of("s1", 3.4), [SW2], name: "s2", ..switch)
    node(left-of("s1", 1.3), [VLAN 10], name: "h1", ..vlanA)
    node(right-of("s2", 1.3), [VLAN 20], name: "h2", ..vlanB)
    connect("h1", "s1", ..flowarrow)
    connect("s1", "s2", line-width: widths.very-thick, draw: red, end: arrow-tip("Stealth", length: 2.2mm, line: widths.very-thick))
    node(along("s1", "s2", t: 50%), [frame crosses with #strong[no tag]], ..netlabel, text-width: 3.2, align: center, anchor: "south")
    connect("s2", "h2", ..flowarrow)
    node(below-of("s1", 0.2), [PVID 10 \
   #fsize("tiny")[“VLAN 10 goes untagged”]], ..netlabel, text-width: 3, align: center)
    node(below-of("s2", 0.2), [PVID 20 \
   #fsize("tiny")[“untagged means VLAN 20”]], ..netlabel, text-width: 3, align: center)
    node(below-of(("s1", 50%, "s2"), 1.35), [Result: VLAN 10 traffic is delivered into VLAN 20. \
   Both switches log nothing. Both configurations look correct.], font: font("script", weight: "bold", fill: red), text-width: 6.4, align: center)
  })
]

#warning[
  If a cross-VLAN ping unexpectedly #emph[succeeds], that is not a success --- it is this bug. Set the native VLAN explicitly, to an unused VLAN carrying no user data (999 in the lab files), on #emph[both] ends. Confirm with `display port vlan` rather than assuming, because nothing else will tell you.
]

== Troubleshooting VLAN reachability

#utpsteps[
  + Check the host IP/subnet first; VLAN experiments still require correct Layer-3 addressing on the endpoints.
  + Confirm the host-facing port link type and VLAN/PVID assignment.
  + Confirm the VLAN exists on both switches where required.
  + Confirm Eth-Trunk 1 is up and is configured as a trunk carrying the relevant VLANs.
  + For hybrid ports, inspect both the PVID and the tagged/untagged VLAN lists.
  + Use ping results as evidence only after the switch configuration matches the intended VLAN path.
]

#exercises[
  Complete the source assignment: build a topology with two switches, two routers, and two PCs. Put the routers in VLAN 2 and the PCs in VLAN 3. Verify same-VLAN and different-VLAN connectivity and capture the command-prompt evidence.
]

#questions[
  + Why is the inter-switch Eth-Trunk configured as a trunk rather than an access port?
  + What does an access port simplify for a non-VLAN-aware host?
  + In the source exercise, what does the hybrid PVID control?
  + Why should the lab include both successful and failed ping tests?
]
