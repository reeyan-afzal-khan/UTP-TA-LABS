#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-lacp")


#heading(level: 1)[Ethernet Link Aggregation and LACP]
<ch:lacp> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Switch CLI navigation and Ethernet interface configuration.

*By the end, you can:* Set interface speed manually, create an Eth-Trunk, compare manual aggregation with static LACP, explain system/interface priority, and verify active member links.]


#heading(level: 2)[Why aggregate Ethernet links?]
 Link aggregation combines physical Ethernet links into one logical connection. LACP coordinates membership and reacts to member failure or recovery.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/lacp-switch-server.png", width: 90%)], caption: [Link aggregation between a switch and a server: several physical links act as one logical connection.]) <fig:lacp-switch-server>

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/lacp-switch-switch.png", width: 90%)], caption: [Two physical links presented as one logical link between two switches.]) <fig:lacp-switch-switch>

#callout("keyidea", title: [Key idea])[An Eth-Trunk is the logical bundle; its physical interfaces are members. LACP coordinates the active set between peers.]


#heading(level: 3)[Two 1 Gbit/s links do not make one 2 Gbit/s link]
 Aggregation adds capacity, not speed. The switch hashes each conversation onto one member and keeps it there, so a single file transfer is still capped at the rate of one physical link. Frames must stay in order, and splitting one flow across two links would reorder them.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/064b0f419ae8c715.svg")], caption: [Four conversations spread across two members. Any one of them uses a single link; the aggregate benefit only appears once there are several flows.]) <fig:lacp-hash>


#heading(level: 2)[Priority concepts used by the source]
 The lab uses two priorities; for both, #strong[smaller values have higher priority].

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Priority], [Role in the lab],),
    table.hline(),
    [LACP system priority], [Helps select the device that controls active-link selection.],
    [LACP interface priority], [Ranks candidate member interfaces.],
  )]
  , kind: table
  )


#heading(level: 2)[Lab topology]
 S1 and S2 are connected using two member links, `G0/0/9` and `G0/0/10`. The bundle is represented as `Eth-Trunk 1`.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/lacp-topology.png", width: 90%)], caption: [The Ethernet link-aggregation topology from the supplied Lab~7 slide. S1 and S2 join over `G0/0/9` and `G0/0/10`, bundled as `Eth-Trunk 1`.]) <fig:lacp-topology>


#heading(level: 2)[Prepare the physical interfaces]
 The exercise disables auto-negotiation and sets both member links to 100 Mbit/s on each switch. #code-block("[S1] interface GigabitEthernet 0/0/9\n[S1-GigabitEthernet0/0/9] undo negotiation auto\n[S1-GigabitEthernet0/0/9] speed 100\n[S1] interface GigabitEthernet 0/0/10\n[S1-GigabitEthernet0/0/10] undo negotiation auto\n[S1-GigabitEthernet0/0/10] speed 100", lang: "text") Configure S2 identically, then verify both interfaces with `display interface`.


#heading(level: 2)[Manual link aggregation]
 First create Eth-Trunk 1 and add both interfaces manually. #code-block("[S1] interface Eth-Trunk 1\n[S1-Eth-Trunk1] quit\n[S1] interface GigabitEthernet 0/0/9\n[S1-GigabitEthernet0/0/9] eth-trunk 1\n[S1] interface GigabitEthernet 0/0/10\n[S1-GigabitEthernet0/0/10] eth-trunk 1", lang: "text") Repeat on S2.


#heading(level: 2)[Rebuild the bundle in static LACP mode]
 Remove the manual memberships with `undo eth-trunk`, then rebuild the trunk in LACP mode. #code-block("[S1] interface Eth-Trunk 1\n[S1-Eth-Trunk1] mode lacp\n[S1] interface GigabitEthernet 0/0/9\n[S1-GigabitEthernet0/0/9] eth-trunk 1\n[S1] interface GigabitEthernet 0/0/10\n[S1-GigabitEthernet0/0/10] eth-trunk 1", lang: "text") Repeat on S2.


#heading(level: 2)[Manipulate LACP priorities]
 Set S1's system and member-interface priorities to 100. #code-block("[S1] lacp priority 100\n[S1] interface GigabitEthernet 0/0/9\n[S1-GigabitEthernet0/0/9] lacp priority 100\n[S1] interface GigabitEthernet 0/0/10\n[S1-GigabitEthernet0/0/10] lacp priority 100", lang: "text")


#heading(level: 3)[How the two priorities combine]
 The election happens twice, in order. First the two switches decide which of them is in charge; only then does that switch rank the individual links. Interface priority on the losing switch is ignored entirely, which is why changing it there appears to do nothing.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/DATA COMMUNICATION & NETWORKING/figures/diagrams/84baec52b7cf4c04.svg")], caption: [The two-stage election. Lower values win at both stages, and a tie falls back to the MAC address or the interface number.]) <fig:lacp-election>


#heading(level: 2)[Verify the Eth-Trunk]
 Eth-Trunk output confirms the mode, member state, and actor/partner information.

#callout("vrpbox", title: [])[\<S1\> display eth-trunk 1 #code-block("Eth-Trunk1's state information is:\nLocal:\nLAG ID: 1                    WorkingMode: (*\\hi{STATIC}*)\nPreempt Delay: Disabled      Hash arithmetic: According to SIP-XOR-DIP\n(*\\hi{System Priority: 100}*)       System ID: 4c1f-cc11-1111\nLeast Active-linknumber: 1   Max Active-linknumber: 8\nOperate status: (*\\higreen{up}*)           Number Of Up Port In Trunk: (*\\higreen{2}*)\n--------------------------------------------------------------------------------\nActorPortName          Status    PortType PortPri PortNo PortKey PortState\nGigabitEthernet0/0/9   (*\\higreen{Selected}*)  1GE      (*\\hi{100}*)     10     305     10111100\nGigabitEthernet0/0/10  (*\\higreen{Selected}*)  1GE      (*\\hi{100}*)     11     305     10111100\n\nPartner:\n--------------------------------------------------------------------------------\nActorPortName          SysPri  SystemID        PortPri PortNo PortKey PortState\nGigabitEthernet0/0/9   32768   4c1f-cc22-2222  32768   10     305     10111100\nGigabitEthernet0/0/10  32768   4c1f-cc22-2222  32768   11     305     10111100", lang: "text")] `WorkingMode: STATIC` proves LACP is running rather than manual aggregation. `Selected` is the word that matters for each member --- `Unselect` means the port joined the trunk but is not carrying traffic. The `Partner` block shows S2 still at the default 32768, which is why S1 won the election in #ref(label("fig:lacp-election"), supplement: [Figure]).

#callout("verification", title: [Verification checklist])[Confirm that Eth-Trunk 1 exists on both switches, uses LACP, contains G0/0/9 and G0/0/10, and shows the expected selected members.]


#heading(level: 2)[Troubleshooting order]


+ Confirm the physical interfaces are up and use compatible speed/negotiation settings.

+ Confirm the same member links are assigned to Eth-Trunk 1 on both switches.

+ Confirm both sides use the same aggregation mode.

+ Inspect LACP system/interface priorities if active-link selection is not what the lab expects.

+ Use Eth-Trunk display output rather than checking only individual interfaces.

#callout("pitfall", title: [Common mistake])[A physical link may be up but excluded from the bundle when membership or LACP mode differs across peers. Verify the logical trunk on both ends.]

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between a physical member interface and an Eth-Trunk?

+ Why does the source disable auto-negotiation before forcing 100 Mbit/s?

+ Which numerical priority is higher: 100 or 32768, according to the lab's rule?

+ What extra capability does static LACP add compared with manual aggregation?]
