#import "/.shared/typst/utp.typ": *
#unit("labs", "07-lacp")

#lab("7")[Link aggregation: several cables, one link] <sec:lab07-lacp>

#callout("labproject", title: [Bundle physical links, then make the bundle negotiate])[#strong[Coverage.] Chapter~#ref(label("ch:lacp"), supplement: none). \
#strong[Goal.] Build an Eth-Trunk in manual mode, rebuild it in LACP mode, and understand why the second is safer.


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/07-flow.typ"


#strong[Worked implementation: Two switches with two LACP members.] Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

#strong[S1.] Use default Layer-2 member ports in the isolated topology. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab07-01.txt", first: 1, last: none, lang: "text")

#strong[S2.] Use default Layer-2 member ports in the isolated topology. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab07-02.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] Connect GE0/0/1 to GE0/0/1 and GE0/0/2 to GE0/0/2. display eth-trunk 1 should show selected members. Shut one member locally; repeat the management-IP ping, then undo shutdown. Configure the aggregation before attaching both parallel cables.

#strong[Part A --- Two problems, one solution.]

Aggregation solves bandwidth and redundancy together. Four gigabit links behave as one four-gigabit link, and losing one degrades capacity instead of connectivity.

#callout("keyidea", title: [Key idea])[Aggregation also solves a problem you would otherwise create. Connect two switches with four parallel cables and no aggregation, and you have built four loops --- spanning tree will block three of them, leaving you exactly where you started with three cables wasted.

An Eth-Trunk presents the bundle to spanning tree as a single logical interface, so all four links forward.]

#strong[Part B --- Traffic does not split evenly.]

#callout("pitfall", title: [Common mistake])[A four-link trunk does not give one flow four times the bandwidth.

The switch hashes header fields --- source and destination MAC, IP, or port depending on configuration --- and every frame in a given conversation lands on the same physical link. This is deliberate: splitting a flow across links would reorder packets and hurt TCP badly.

So a single large file transfer uses one link. Aggregation increases #emph[aggregate] capacity across many flows, not the speed of any one of them. Expect uneven utilisation, and choose a hash that matches your traffic --- MAC-based hashing is useless behind a router, where every frame carries the same router MAC.]

#strong[Part C --- Manual mode.]


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/07-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:lacp"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Configure the aggregate before bringing up both parallel cables. The logical interface represents the bundle, while member status reports usable physical links. A single ping flow demonstrates connectivity and failover, not aggregate bandwidth. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/07-worked-case.typ"


#code-block("system-view\ninterface Eth-Trunk 1\n mode manual load-balance\nquit\n\ninterface GigabitEthernet 0/0/1\n eth-trunk 1\nquit\ninterface GigabitEthernet 0/0/2\n eth-trunk 1\nquit", lang: "text")

Configure the matching bundle on the far switch, then verify:

#code-block("<SW1> display eth-trunk 1", lang: "text")

#strong[Part D --- Why manual mode is dangerous.]

Manual mode forwards on every member port unconditionally. It never checks that the far end agrees.

#callout("keyidea", title: [Key idea])[Miscable one member --- into the wrong switch, or the wrong port --- and manual mode forwards over it anyway. The result is a forwarding loop that spanning tree cannot see, because the trunk hides its members from STP.

That is a broadcast storm, and it takes the segment down. It is the single best argument for LACP.]

#strong[Part E --- Static LACP mode.]

#code-block("interface Eth-Trunk 1\n undo mode manual load-balance\n mode lacp-static\nquit", lang: "text")

Now each end sends LACP protocol frames announcing its system ID, port priorities, and key. A member joins the bundle only when both ends agree it should. Miscabling produces a port that stays out of the bundle --- a fault that is visible, contained, and safe.

#strong[Part F --- Priorities decide the active links.]

LACP allows more member ports than active links. The rest wait as backups.

#code-block("lacp priority 100                    # system priority; lower wins\ninterface Eth-Trunk 1\n max active-linknumber 2\nquit\n\ninterface GigabitEthernet 0/0/1\n lacp priority 100                   # port priority; lower is preferred\nquit", lang: "text")

#callout("keyidea", title: [Key idea])[Two priorities, two different jobs.

#strong[System priority] decides which switch is in charge of selecting active links. Lower wins; ties break on system MAC. Only one end gets to choose, otherwise the two could disagree.

#strong[Port priority] is then used by that switch to rank candidate ports. Lower is preferred.

Setting port priorities on the switch that lost the system-priority election has no effect --- a result students often mistake for a broken configuration.]

Verify which end is deciding, and which ports are selected:

#code-block("<SW1> display eth-trunk 1\n<SW1> display lacp statistics eth-trunk 1", lang: "text")

#callout("troubleshoot", title: [Troubleshooting])[#strong[Trunk stays down.] Member ports differ in speed or duplex. All members must match.

#strong[Members configured but not selected.] Mode mismatch --- one end manual, the other LACP. Both ends must run the same mode.

#strong[One port never becomes active.] Expected if `max active-linknumber` is lower than the member count. Confirm it is a backup, not a fault.

#strong[Port refuses to join.] It probably still carries per-interface configuration. Ports must be cleared before being added to a trunk.]

#callout("tryit", title: [Try it yourself])[With the trunk up, shut down one active member and watch `display eth-trunk 1`. Does a backup take over, and how long does it take?

Then, on the switch that lost the system-priority election, change a port priority and confirm nothing happens. Explain why in one sentence.]]

#strong[Chapter connection.] Revisit #link(label("ch:lacp"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/07-lacp-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Capture active members, remove one member link and repeat connectivity tests. Explain which evidence demonstrates redundancy and which additional traffic test would be needed to study load distribution.

- Both manual and LACP modes configured and captured separately.

- Both ends use the same mode.

- `display eth-trunk 1` shows members Selected, with the count matching `max active-linknumber`.

- The deciding switch is identified from system priority.

- Failover to a backup member is demonstrated and timed.]
