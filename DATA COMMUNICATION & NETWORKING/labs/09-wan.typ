#import "/.shared/typst/utp.typ": *
#unit("labs", "09-wan")

#labsection(9, label: <sec:lab09-wan>)[WAN links: HDLC, PPP, and authentication]

#labproject[Connect two sites over serial, then make each end prove who it is][
  #strong[Coverage.] Chapter~#ref(<ch:wan>). \

  #strong[Goal.] Configure serial encapsulation, switch from HDLC to PPP, and compare PAP with CHAP by capturing both.

  #include "visuals/09-flow.typ"

  #strong[Worked implementation: A complete two-router PPP/CHAP baseline.]
  Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

  #strong[R1 authenticator.] Use serial-capable routers; substitute the actual serial port shown by display interface brief. Configure the lab DCE clock according to its interface help before the link test.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-01.txt", lang: "terminal")

  #strong[R2 authenticated peer.] The name and password must match R1’s AAA record.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-02.txt", lang: "terminal")

  #strong[Verify on R1.] After both ends are configured, inspect physical and protocol state before pinging.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab09-03.txt", lang: "terminal")

  #strong[Expected evidence.] The serial interface must be up/up and the ping must succeed. Capture PAP and CHAP as separate runs using the mode-change steps below. CHAP avoids sending the password itself, but does not encrypt application traffic.

  #v(6pt)
  #strong[Part A --- Serial links are not Ethernet.]

  Two differences matter immediately.

  There is no MAC addressing and no ARP --- a serial link is point-to-point, so there is only one possible recipient. And one end must supply clocking.

  #keyidea[
    On a serial link, one end is #term[DCE] and provides the clock; the other is #term[DTE] and follows it. In eNSP the DCE end is determined by which side you attached the cable from, and it is not obvious by inspection.

    Find it before troubleshooting anything else:

    #include "visuals/09-trace.typ"

    #strong[Use the chapter while coding.] Revisit #link(<ch:wan>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

    #strong[Follow the supplied implementation.] Device image and interface names can differ, so use the supplied platform notes when selecting the serial port. A credential mismatch changes authentication; changing IP addresses does not repair that mismatch. Restore each deliberate failure before testing the next layer.

    #include "visuals/09-worked-case.typ"

    ```terminal
    <R1> display interface Serial 0/0/0
    ```

    No clock rate on the DCE end means the line stays down no matter how correct the IP configuration is.
  ]

  ```terminal
  interface Serial 0/0/0
   ip address 10.0.0.1 30
   # Set the DCE clock using this image's serial-interface help.
   undo shutdown
  quit
  ```

  #v(6pt)
  #strong[Part B --- HDLC.]

  ```terminal
  interface Serial 0/0/0
   link-protocol hdlc
  quit
  ```

  #pitfall[
    Both ends must run the same encapsulation. HDLC on one end and PPP on the other gives Physical `up`, Protocol `down` --- the exact pattern from Lab~#labref(<sec:lab02-ensp>), and the reason that lab insisted you learn to read those two columns separately.

    Note also that HDLC is vendor-specific in practice. Huawei’s and Cisco’s implementations do not interoperate, which is one reason PPP is the safer default between equipment from different vendors.
  ]

  #v(6pt)
  #strong[Part C --- Run OSPF across the WAN.]

  Bring up OSPF over the serial links using Lab~#labref(<sec:lab04-ospf>)’s configuration, and then look at the cost:

  ```terminal
  <R1> display ip routing-table protocol ospf
  ```

  The serial path carries a far higher cost than any Ethernet path, because Huawei derives cost from bandwidth. If a parallel Ethernet route exists, OSPF will prefer it automatically --- which is usually correct, and occasionally not what you intended.

  #v(6pt)
  #strong[Part D --- Switch to PPP.]

  ```terminal
  interface Serial 0/0/0
   link-protocol ppp
  quit
  ```

  VRP asks for confirmation because changing encapsulation drops the link. Change both ends.

  #keyidea[
    PPP brings up a link in two phases, and knowing which phase failed halves your troubleshooting.

    #strong[LCP] negotiates the link itself: MTU, magic numbers, and whether authentication is required. \

    #strong[NCP] then negotiates each network-layer protocol, IPCP for IPv4.

    Authentication sits between them. So a link that completes LCP and never reaches NCP is almost always failing authentication, not addressing.
  ]

  #v(6pt)
  #strong[Part E --- PAP.]

  On the authenticating side:

  ```terminal
  aaa
   local-user branch password cipher Branch@123
   local-user branch service-type ppp
  quit

  interface Serial 0/0/0
   ppp authentication-mode pap
  quit
  ```

  On the side being authenticated:

  ```terminal
  interface Serial 0/0/0
   ppp pap local-user branch password cipher Branch@123
  quit
  ```

  #v(6pt)
  #strong[Part F --- CHAP, and why it is better.]

  ```terminal
  interface Serial 0/0/0
   ppp authentication-mode chap
  quit

  # far end
  interface Serial 0/0/0
   ppp chap user branch
   ppp chap password cipher Branch@123
  quit
  ```

  #keyidea[
    PAP sends the password across the link in plaintext, once, at setup. Anyone capturing the link has the credential.

    CHAP never sends the password. The authenticator sends a random challenge; the peer replies with a hash of the challenge combined with the secret. The authenticator computes the same hash and compares. A new challenge prevents simple replay; weak shared secrets can still be attacked offline.

    Re-authentication may be configured, but CHAP does not provide application-data encryption or a general guarantee against session attacks.
  ]

  #v(6pt)
  #strong[Part G --- Prove the difference.]

  Capture both. With PAP the password is readable in the capture; with CHAP you see only a challenge and a hash.

  #utptable[
    #tabularx(
      columns: (40%, 1fr),
      styles: ((font: "Source Code Pro", size: 0.88em),),
      header: ([Command], [Shows]),
      [display interface Serial 0/0/0], [Encapsulation, clock, LCP state, DCE/DTE],
      [display ppp all], [PPP state per interface],
      [debugging ppp all], [Live negotiation --- use sparingly],
      [display ip interface brief], [Whether the link came up at all],
    )
  ]

  #troubleshoot[
    #strong[Physical down.] Cable not connected in eNSP, or the device is not started.

    #strong[Physical up, protocol down.] Encapsulation mismatch, missing clock rate on the DCE end, or failed authentication. Check in that order.

    #strong[LCP completes, IPCP never does.] Authentication is failing. The username must match the `local-user` exactly, and the password on both sides.

    #strong[Works with PAP, fails with CHAP.] CHAP matches on the hostname by default. Confirm the `ppp chap user` matches the configured `local-user`.
  ]

  #tryit[
    Deliberately misconfigure the CHAP password on one end and capture the exchange. How many messages appear before the link gives up, and does the failure say anything useful?

    Then relate the answer to Lab~#labref(<sec:lab05-ftp>): both labs show a credential crossing a link. Explain which design is safer and why, in two sentences.
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:wan>)[the chapter explanation] and map its states to the steps below.

#include "visuals/09-wan-chapter.typ"

#verification[
  #strong[Explain and extend your result.] Capture the successful state, introduce one deliberate credential mismatch and record the changed negotiation state. Restore the credential and confirm recovery without changing addressing.

  - DCE end identified from `display interface`, with the clock rate set there.
  - Both HDLC and PPP configured, each with its own captured output.
  - Both PAP and CHAP demonstrated with matching credentials.
  - Captures show the PAP password in plaintext and the CHAP challenge-response.
  - OSPF adjacency reaches Full across the serial link.
]
