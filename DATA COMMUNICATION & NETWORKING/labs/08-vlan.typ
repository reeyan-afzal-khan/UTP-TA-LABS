#import "/.shared/typst/utp.typ": *
#unit("labs", "08-vlan")

#lab("8")[VLANs: one switch, several networks] <sec:lab08-vlan>


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/08-flow.typ"


#strong[Worked implementation: Two VLANs across one trunk.] Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

#strong[S1.] Configure the access ports before connecting the hosts. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab08-01.txt", first: 1, last: none, lang: "text")

#strong[S2.] Configure the access ports before connecting the hosts. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab08-02.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] Cable GE0/0/24 between switches. On each switch, host port 1 belongs to VLAN 10 and host port 2 to VLAN 20. Use 192.168.10.11 and .12/24 for the VLAN 10 hosts; 192.168.20.11 and .12/24 for VLAN 20. Leave gateways empty: same-VLAN peers should communicate, inter-VLAN peers should not.

#callout("labproject", title: [Access, trunk, and hybrid ports --- and what each does to a tag])[#strong[Coverage.] Chapter~#ref(label("ch:vlan"), supplement: none). \
#strong[Part A --- What a VLAN actually separates.]

A switch floods broadcasts to every port. A VLAN restricts that flooding to a subset, which means one physical switch behaves as several independent switches.

#callout("keyidea", title: [Key idea])[Devices in different VLANs cannot reach each other #emph[at all] without a router, regardless of IP addressing. Putting them in the same subnet changes nothing --- the frames never leave their broadcast domain.

That is the point. VLAN separation is enforced at layer 2, below IP, so it cannot be bypassed by reconfiguring a host.]

#strong[Part B --- Three port types.]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Port type], [Incoming untagged frame], [Outgoing frame],),
    table.hline(),
    [Access], [Tagged with the port's PVID], [Tag removed],
    [Trunk], [Tagged with PVID], [Tagged, unless the VLAN is the native VLAN],
    [Hybrid], [Tagged with PVID], [Tagged #emph[or] untagged, configured per VLAN],
  )]
  , kind: table
  )

#callout("keyidea", title: [Key idea])[Every port has a #strong[PVID] --- the VLAN assigned to arriving untagged frames. For an access port the PVID is simply its VLAN.

The distinction that matters: access and trunk ports decide tagging by #emph[role]; a hybrid port decides per VLAN. That is what lets a hybrid port send VLAN 10 untagged to a PC while sending VLAN 20 tagged to a phone on the same cable.]

#strong[Part C --- Create VLANs and assign access ports.]


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/08-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:vlan"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Check the host address, access-port VLAN and trunk allow list as three separate checkpoints. Do not add gateways simply to make every ping succeed: isolation is an intended result of this lab's topology. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/08-worked-case.typ"


#code-block("system-view\nvlan batch 10 20 30\n\ninterface GigabitEthernet 0/0/1\n port link-type access\n port default vlan 10\nquit\n\ninterface GigabitEthernet 0/0/2\n port link-type access\n port default vlan 20\nquit", lang: "text")

#strong[Part D --- Carry VLANs between switches.]

An access port carries one VLAN. Connecting two switches that share three VLANs would need three cables --- unless the link is a trunk.

#code-block("interface Eth-Trunk 1\n port link-type trunk\n port trunk allow-pass vlan 10 20 30\nquit", lang: "text")

#callout("pitfall", title: [Common mistake])[`port trunk allow-pass vlan 10 20 30` does not #emph[add] to the allowed list on every VRP version --- on some it replaces it. Always confirm with `display port vlan` rather than assuming your second command extended the first.

And note that VLAN 1 is allowed by default. Leaving it there is a common audit finding, since it carries management traffic across a link that may not need it.]

#strong[Part E --- The native VLAN trap.]

#callout("keyidea", title: [Key idea])[A trunk sends one VLAN untagged: the #strong[native VLAN], which is the trunk port's PVID and defaults to VLAN 1.

If the two ends of a trunk disagree about the native VLAN, traffic leaks silently between them. Switch A sends VLAN 1 untagged; switch B receives an untagged frame and assigns it to #emph[its] native VLAN, say VLAN 99. Two supposedly separate VLANs are now joined, with no error message anywhere.

Set the native VLAN explicitly and identically on both ends, and never use a VLAN that carries user data.]

#code-block("interface Eth-Trunk 1\n port trunk pvid vlan 999\n port trunk allow-pass vlan 10 20 30\nquit", lang: "text")

#strong[Part F --- Hybrid ports.]

#code-block("interface GigabitEthernet 0/0/5\n port link-type hybrid\n port hybrid pvid vlan 10\n port hybrid untagged vlan 10\n port hybrid tagged vlan 20\nquit", lang: "text")

A PC sending untagged frames lands in VLAN 10 and receives VLAN 10 untagged. A device that understands tags can also use VLAN 20 on the same port.

#strong[Part G --- Verify.]

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Command], [Shows],),
    table.hline(),
    [display vlan], [Every VLAN and its member ports],
    [display port vlan], [Each port's type, PVID, and allowed VLANs],
    [display vlan 10 verbose], [Which ports carry VLAN 10, tagged or untagged],
    [display mac-address vlan 10], [Which hosts have been learned in that VLAN],
  )]
  , kind: table
  )

Then test: hosts in VLAN 10 must ping each other across both switches, and must fail to reach VLAN 20 even in the same subnet.

#callout("troubleshoot", title: [Troubleshooting])[#strong[Same VLAN, same switch, ping fails.] Check both ports are access ports in that VLAN with `display port vlan`.

#strong[Same VLAN, different switches, ping fails.] The trunk is not allowing that VLAN, or the VLAN does not exist on the second switch. It must be created on both.

#strong[Different VLANs can reach each other.] Native VLAN mismatch on the trunk --- the leak described in Part E.

#strong[Trunk works for some VLANs only.] `allow-pass` replaced rather than extended the list.]

#callout("tryit", title: [Try it yourself])[Set the native VLAN to 10 on one switch and 20 on the other, then ping between VLANs. It will work --- which is a security failure, not a success.

Capture it in Wireshark and explain which frames carry a tag and which do not. Then fix it and confirm the isolation returns.]]

#strong[Chapter connection.] Revisit #link(label("ch:vlan"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/08-vlan-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Record same-VLAN and cross-VLAN tests. Remove VLAN 10 from the lab trunk's allowed list, predict the affected pair, test it and restore the working configuration.

- VLANs created on both switches, not just one.

- Trunk explicitly permits every VLAN that must cross it.

- Native VLAN set identically on both ends and carries no user data.

- Same-VLAN connectivity proven across switches, and cross-VLAN isolation proven to fail.

- Hybrid port demonstrated with one VLAN tagged and one untagged.]
