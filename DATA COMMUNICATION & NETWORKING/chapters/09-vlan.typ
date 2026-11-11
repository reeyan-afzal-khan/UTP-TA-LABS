#import "/.shared/typst/utp.typ": *
#unit("chapters", "09-vlan")


#heading(level: 1)[VLAN Configuration: Access, Trunk, and Hybrid Ports]
<ch:vlan> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Ethernet switch configuration and Eth-Trunk/LACP concepts from Lab 7.

*By the end, you can:* Create VLANs, bind access ports, turn the inter-switch Eth-Trunk into a VLAN trunk, configure hybrid ports and PVID behavior, and verify same-VLAN and controlled cross-VLAN communication.]


#heading(level: 2)[Purpose of VLANs]
 VLANs create separate Layer-2 broadcast domains on shared switches. Hosts in different VLANs remain isolated unless the design deliberately connects them.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/vlan-topology.png", width: 90%)], caption: [The VLAN topology from the supplied Lab~8 slide.]) <fig:vlan-topology>


#heading(level: 2)[Three port behaviors used in the exercise]
 #figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Port type], [Role in the supplied lab],),
    table.hline(),
    [Access], [Connects an untagged host to one VLAN.],
    [Trunk], [Carries multiple VLANs between switches.],
    [Hybrid], [Controls tagging per VLAN and classifies untagged ingress by PVID.],
  )]
  , kind: table
  )

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/4cd173e20ab4954d.cetz.json")], caption: [Where the VLAN tag is added, carried, and removed. The tag exists only between the switches. Hosts never see it, which is why a VLAN needs no configuration on the PC --- and why the switch, not the host, decides which VLAN a frame belongs to.]) <fig:vlan-tag>

#callout("keyidea", title: [Key idea])[A VLAN is enforced by the switch, not by the host's IP address. Two PCs can share a subnet and still be unable to reach each other if they sit in different VLANs --- changing the PC's address cannot bypass the separation.]


#heading(level: 3)[What the tag actually is]
 The tag is four bytes pushed into the Ethernet header between the source address and the type field. Twelve of its bits carry the VLAN ID, which is why the usable range stops at 4094.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/5ef84a3bedc6144f.cetz.json")], caption: [An 802.1Q tag inserted into the Ethernet II frame from #ref(label("fig:eth-frame"), supplement: [Figure]). The frame grows by four bytes, which is why a trunk port needs an MTU four bytes larger than its access ports.]) <fig:dot1q>


#heading(level: 2)[Step 1: build the inter-switch Eth-Trunk]
 Build static-LACP Eth-Trunk 1 with G0/0/9 and G0/0/10. The source shows both physical-interface membership and `trunkport` from the Eth-Trunk view. #code-block("[S1] interface Eth-Trunk 1\n[S1-Eth-Trunk1] mode lacp\n[S1] interface GigabitEthernet 0/0/9\n[S1-GigabitEthernet0/0/9] eth-trunk 1\n[S1] interface GigabitEthernet 0/0/10\n[S1-GigabitEthernet0/0/10] eth-trunk 1\n\n[S2] interface Eth-Trunk 1\n[S2-Eth-Trunk1] mode lacp\n[S2-Eth-Trunk1] trunkport GigabitEthernet 0/0/9\n[S2-Eth-Trunk1] trunkport GigabitEthernet 0/0/10", lang: "text")


#heading(level: 2)[Step 2: make Eth-Trunk 1 a VLAN trunk]
 #code-block("[S1] interface Eth-Trunk 1\n[S1-Eth-Trunk1] port link-type trunk\n[S1-Eth-Trunk1] port trunk allow-pass vlan all\n\n[S2] interface Eth-Trunk 1\n[S2-Eth-Trunk1] port link-type trunk\n[S2-Eth-Trunk1] port trunk allow-pass vlan all", lang: "text")

#callout("keyidea", title: [Key idea])[Eth-Trunk aggregates links; trunk mode carries VLANs. These are separate functions on the same logical interface.]


#heading(level: 2)[Step 3: create VLANs and bind access interfaces]
 The lab demonstrates two Huawei VRP configuration styles.

On S1, G0/0/13 is associated with VLAN 3 and G0/0/1 with VLAN 4: #code-block("[S1] interface GigabitEthernet 0/0/13\n[S1-GigabitEthernet0/0/13] port link-type access\n[S1] interface GigabitEthernet 0/0/1\n[S1-GigabitEthernet0/0/1] port link-type access\n[S1] vlan 2\n[S1-vlan2] vlan 3\n[S1-vlan3] port GigabitEthernet 0/0/13\n[S1-vlan3] vlan 4\n[S1-vlan4] port GigabitEthernet 0/0/1", lang: "text")

On S2, the source uses `vlan batch` and `port default vlan`: #code-block("[S2] vlan batch 2 to 4\n[S2] interface GigabitEthernet 0/0/3\n[S2-GigabitEthernet0/0/3] port link-type access\n[S2-GigabitEthernet0/0/3] port default vlan 4\n[S2] interface GigabitEthernet 0/0/6\n[S2-GigabitEthernet0/0/6] port link-type access\n[S2-GigabitEthernet0/0/6] port default vlan 2", lang: "text")


#heading(level: 2)[Step 4: address the hosts and verify VLAN isolation]
 Hosts in the same VLAN use a common subnet. Initially, R1 and R3 in VLAN 4 should communicate; hosts in different VLANs should not.

#callout("vrpbox", title: [])[\<S1\> display vlan #code-block("The total number of vlans is : 4\n--------------------------------------------------------------------------------\nU: Up;          D: Down;         TG: Tagged;         UT: Untagged;\nMP: Vlan-mapping;                ST: Vlan-stacking;\n--------------------------------------------------------------------------------\nVID  Type     Ports\n--------------------------------------------------------------------------------\n1    common   UT:GE0/0/2(U)     GE0/0/4(U)      GE0/0/5(U)\n2    common   (*\\hi{TG:Eth-Trunk1(U)}*)\n3    common   (*\\hi{UT:GE0/0/13(U)}*)   TG:Eth-Trunk1(U)\n4    common   (*\\hi{UT:GE0/0/1(U)}*)    TG:Eth-Trunk1(U)", lang: "text")] `UT` is an access or untagged port, `TG` a tagged one. Every VLAN lists `Eth-Trunk1` as `TG`, which is what `port trunk allow-pass vlan all` did. A VLAN missing from this table cannot carry traffic however the host is addressed.

Then test both outcomes on the hosts: a ping inside one VLAN, and a ping across two.

#callout("vrpbox", title: [])[\<R1\> ping 10.0.4.3 (same VLAN, expected to succeed) #code-block("PING 10.0.4.3: 56  data bytes, press CTRL_C to break\n    Reply from 10.0.4.3: bytes=56 Sequence=1 ttl=255 time=30 ms\n    Reply from 10.0.4.3: bytes=56 Sequence=2 ttl=255 time=20 ms\n\n  --- 10.0.4.3 ping statistics ---\n    5 packet(s) transmitted, (*\\higreen{5 packet(s) received}*), (*\\higreen{0.00\\% packet loss}*)", lang: "text")]

#callout("vrpbox", title: [])[\<R1\> ping 10.0.3.2 (different VLAN, expected to fail) #code-block("PING 10.0.3.2: 56  data bytes, press CTRL_C to break\n    Request time out\n    Request time out\n\n  --- 10.0.3.2 ping statistics ---\n    5 packet(s) transmitted, 0 packet(s) received, (*\\hired{100.00\\% packet loss}*)", lang: "text")] the second result is a pass, not a failure. A VLAN lab needs both transcripts, because only the failing one proves the isolation works.

#callout("verification", title: [Verification checklist])[Test both outcomes: same-VLAN connectivity and different-VLAN isolation before adding hybrid behavior.]


#heading(level: 2)[Step 5: change selected ports to hybrid mode]
 Hybrid ports then deliver VLAN 2 and VLAN 4 traffic untagged to selected devices. #code-block("[S1] interface GigabitEthernet 0/0/1\n[S1-GigabitEthernet0/0/1] port link-type hybrid\n[S1-GigabitEthernet0/0/1] port hybrid untagged vlan 2 4\n[S1-GigabitEthernet0/0/1] port hybrid pvid vlan 4\n\n[S2] interface GigabitEthernet 0/0/3\n[S2-GigabitEthernet0/0/3] port link-type hybrid\n[S2-GigabitEthernet0/0/3] port hybrid untagged vlan 2 4\n[S2-GigabitEthernet0/0/3] port hybrid pvid vlan 4\n\n[S2] interface GigabitEthernet 0/0/6\n[S2-GigabitEthernet0/0/6] port link-type hybrid\n[S2-GigabitEthernet0/0/6] port hybrid untagged vlan 2 4\n[S2-GigabitEthernet0/0/6] port hybrid pvid vlan 2", lang: "text")


#heading(level: 2)[PVID and untagged behavior]
 The commands are complementary:

- `port hybrid pvid vlan <id>` assigns a VLAN classification to untagged frames received from the host.

- `port hybrid untagged vlan 2 4` permits frames from the listed VLANs to leave that host-facing port without a VLAN tag.

Retest reachability: the selected VLAN-2 and VLAN-4 hosts should communicate, while the VLAN-3 host remains isolated.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/f5aeed7ffaed41e5.cetz.json")], caption: [The same two questions asked of all three port types. Access and trunk are special cases of hybrid, which is why hybrid is the only one that needs two separate commands.]) <fig:port-types>

#callout("keyidea", title: [Key idea])[The two hybrid commands answer the two different questions above. `port hybrid pvid vlan <id>` answers the ingress question; `port hybrid untagged vlan 2 4` answers the egress one. Setting one without the other is the usual cause of a hybrid port that half works.]


#heading(level: 2)[The native-VLAN mismatch: a leak that reports no error]
 A trunk sends exactly one VLAN #emph[untagged] --- the native VLAN, taken from the port's PVID. If the two ends disagree about which VLAN that is, each switch files the untagged frames into a different VLAN, and two supposedly isolated VLANs are joined.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/6015fd15f94274a8.cetz.json")], caption: [A mismatched native VLAN silently merges two VLANs. Each switch files untagged frames into its own PVID, so VLAN~10 traffic arrives in VLAN~20 while both configurations look correct.]) <fig:vlan-native-mismatch>

#callout("pitfall", title: [Common mistake])[If a cross-VLAN ping unexpectedly #emph[succeeds], that is not a success --- it is this bug. Set the native VLAN explicitly, to an unused VLAN carrying no user data (999 in the lab files), on #emph[both] ends. Confirm with `display port vlan` rather than assuming, because nothing else will tell you.]


#heading(level: 2)[Troubleshooting VLAN reachability]


+ Check the host IP/subnet first; VLAN experiments still require correct Layer-3 addressing on the endpoints.

+ Confirm the host-facing port link type and VLAN/PVID assignment.

+ Confirm the VLAN exists on both switches where required.

+ Confirm Eth-Trunk 1 is up and is configured as a trunk carrying the relevant VLANs.

+ For hybrid ports, inspect both the PVID and the tagged/untagged VLAN lists.

+ Use ping results as evidence only after the switch configuration matches the intended VLAN path.

#callout("tryit", title: [Try it yourself])[Complete the source assignment: build a topology with two switches, two routers, and two PCs. Put the routers in VLAN 2 and the PCs in VLAN 3. Verify same-VLAN and different-VLAN connectivity and capture the command-prompt evidence.]

#callout("quickcheck", title: [Check your understanding])[+ Why is the inter-switch Eth-Trunk configured as a trunk rather than an access port?

+ What does an access port simplify for a non-VLAN-aware host?

+ In the source exercise, what does the hybrid PVID control?

+ Why should the lab include both successful and failed ping tests?]
