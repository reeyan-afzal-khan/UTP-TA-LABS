#import "/.shared/typst/utp.typ": *
#unit("labs", "09-wan")

#lab("9")[WAN links: HDLC, PPP, and authentication] <sec:lab09-wan>

#callout("labproject", title: [Connect two sites over serial, then make each end prove who it is])[#strong[Coverage.] Chapter~#ref(label("ch:wan"), supplement: none). \
#strong[Goal.] Configure serial encapsulation, switch from HDLC to PPP, and compare PAP with CHAP by capturing both.


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/09-flow.typ"


#strong[Worked implementation: A complete two-router PPP/CHAP baseline.] Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

#strong[R1 authenticator.] Use serial-capable routers; substitute the actual serial port shown by display interface brief. Configure the lab DCE clock according to its interface help before the link test. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-01.txt", first: 1, last: none, lang: "text")

#strong[R2 authenticated peer.] The name and password must match R1's AAA record. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-02.txt", first: 1, last: none, lang: "text")

#strong[Verify on R1.] After both ends are configured, inspect physical and protocol state before pinging. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-03.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] The serial interface must be up/up and the ping must succeed. Capture PAP and CHAP as separate runs using the mode-change steps below. CHAP avoids sending the password itself, but does not encrypt application traffic.

#strong[Part A --- Serial links are not Ethernet.]

Two differences matter immediately.

There is no MAC addressing and no ARP --- a serial link is point-to-point, so there is only one possible recipient. And one end must supply clocking.

#callout("keyidea", title: [Key idea])[On a serial link, one end is #strong[DCE] and provides the clock; the other is #strong[DTE] and follows it. In eNSP the DCE end is determined by which side you attached the cable from, and it is not obvious by inspection.

Find it before troubleshooting anything else:


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/09-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:wan"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Device image and interface names can differ, so use the supplied platform notes when selecting the serial port. A credential mismatch changes authentication; changing IP addresses does not repair that mismatch. Restore each deliberate failure before testing the next layer. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/09-worked-case.typ"


#code-block("<R1> display interface Serial 0/0/0", lang: "text")

No clock rate on the DCE end means the line stays down no matter how correct the IP configuration is.]

#code-block("interface Serial 0/0/0\n ip address 10.0.0.1 30\n # Set the DCE clock using this image's serial-interface help.\n undo shutdown\nquit", lang: "text")

#strong[Part B --- HDLC.]

#code-block("interface Serial 0/0/0\n link-protocol hdlc\nquit", lang: "text")

#callout("pitfall", title: [Common mistake])[Both ends must run the same encapsulation. HDLC on one end and PPP on the other gives Physical `up`, Protocol `down` --- the exact pattern from Lab~#link(label("sec:lab02-ensp"))[2], and the reason that lab insisted you learn to read those two columns separately.

Note also that HDLC is vendor-specific in practice. Huawei's and Cisco's implementations do not interoperate, which is one reason PPP is the safer default between equipment from different vendors.]

#strong[Part C --- Run OSPF across the WAN.]

Bring up OSPF over the serial links using Lab~#link(label("sec:lab04-ospf"))[4]'s configuration, and then look at the cost:

#code-block("<R1> display ip routing-table protocol ospf", lang: "text")

The serial path carries a far higher cost than any Ethernet path, because Huawei derives cost from bandwidth. If a parallel Ethernet route exists, OSPF will prefer it automatically --- which is usually correct, and occasionally not what you intended.

#strong[Part D --- Switch to PPP.]

#code-block("interface Serial 0/0/0\n link-protocol ppp\nquit", lang: "text")

VRP asks for confirmation because changing encapsulation drops the link. Change both ends.

#callout("keyidea", title: [Key idea])[PPP brings up a link in two phases, and knowing which phase failed halves your troubleshooting.

#strong[LCP] negotiates the link itself: MTU, magic numbers, and whether authentication is required. \
#strong[NCP] then negotiates each network-layer protocol, IPCP for IPv4.

Authentication sits between them. So a link that completes LCP and never reaches NCP is almost always failing authentication, not addressing.]

#strong[Part E --- PAP.]

On the authenticating side:

#code-block("aaa\n local-user branch password cipher Branch@123\n local-user branch service-type ppp\nquit\n\ninterface Serial 0/0/0\n ppp authentication-mode pap\nquit", lang: "text")

On the side being authenticated:

#code-block("interface Serial 0/0/0\n ppp pap local-user branch password cipher Branch@123\nquit", lang: "text")

#strong[Part F --- CHAP, and why it is better.]

#code-block("interface Serial 0/0/0\n ppp authentication-mode chap\nquit\n\n# far end\ninterface Serial 0/0/0\n ppp chap user branch\n ppp chap password cipher Branch@123\nquit", lang: "text")

#callout("keyidea", title: [Key idea])[PAP sends the password across the link in plaintext, once, at setup. Anyone capturing the link has the credential.

CHAP never sends the password. The authenticator sends a random challenge; the peer replies with a hash of the challenge combined with the secret. The authenticator computes the same hash and compares. A new challenge prevents simple replay; weak shared secrets can still be attacked offline.

Re-authentication may be configured, but CHAP does not provide application-data encryption or a general guarantee against session attacks.]

#strong[Part G --- Prove the difference.]

Capture both. With PAP the password is readable in the capture; with CHAP you see only a challenge and a hash.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Command], [Shows],),
    table.hline(),
    [display interface Serial 0/0/0], [Encapsulation, clock, LCP state, DCE/DTE],
    [display ppp all], [PPP state per interface],
    [debugging ppp all], [Live negotiation --- use sparingly],
    [display ip interface brief], [Whether the link came up at all],
  )]
  , kind: table
  )

#callout("troubleshoot", title: [Troubleshooting])[#strong[Physical down.] Cable not connected in eNSP, or the device is not started.

#strong[Physical up, protocol down.] Encapsulation mismatch, missing clock rate on the DCE end, or failed authentication. Check in that order.

#strong[LCP completes, IPCP never does.] Authentication is failing. The username must match the `local-user` exactly, and the password on both sides.

#strong[Works with PAP, fails with CHAP.] CHAP matches on the hostname by default. Confirm the `ppp chap user` matches the configured `local-user`.]

#callout("tryit", title: [Try it yourself])[Deliberately misconfigure the CHAP password on one end and capture the exchange. How many messages appear before the link gives up, and does the failure say anything useful?

Then relate the answer to Lab~#link(label("sec:lab05-ftp"))[5]: both labs show a credential crossing a link. Explain which design is safer and why, in two sentences.]]

#strong[Chapter connection.] Revisit #link(label("ch:wan"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/09-wan-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Capture the successful state, introduce one deliberate credential mismatch and record the changed negotiation state. Restore the credential and confirm recovery without changing addressing.

- DCE end identified from `display interface`, with the clock rate set there.

- Both HDLC and PPP configured, each with its own captured output.

- Both PAP and CHAP demonstrated with matching credentials.

- Captures show the PAP password in plaintext and the CHAP challenge-response.

- OSPF adjacency reaches Full across the serial link.]
