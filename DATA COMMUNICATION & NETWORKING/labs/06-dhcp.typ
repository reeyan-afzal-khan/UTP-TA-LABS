#import "/.shared/typst/utp.typ": *
#unit("labs", "06-dhcp")

#labsection(6, label: <sec:lab06-dhcp>)[DHCP: addresses without a spreadsheet]

#labproject[Global pools, interface pools, and the relay that crosses a router][
  #strong[Coverage.] Chapter~#ref(<ch:dhcp>). \

  #strong[Goal.] Hand out addresses automatically, understand why the process works at all before a client has an address, and extend it across a router.

  #include "visuals/06-flow.typ"

  #strong[Worked implementation: A server and a remote client subnet.]
  Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

  #strong[DHCP server.] Server GE0/0/0 connects to relay GE0/0/0. The return route reaches the client subnet through the relay.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab06-01.txt", lang: "terminal")

  #strong[Relay.] Connect the DHCP client to relay GE0/0/1 and select DHCP in the client settings.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab06-02.txt", lang: "terminal")

  #strong[Inspect the lease.] Run on SERVER, then inspect the client address and ping its gateway.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab06-03.txt", lang: "terminal")

  #strong[Expected evidence.] The client must receive a 192.168.3.0/24 address outside the reserved range and gateway 192.168.3.1. Capture the relay address field and match it to the pool network.

  #v(6pt)
  #strong[Part A --- The four-message exchange.]

  A client with no address has to ask for one --- but it cannot address a request to a server it does not know about.

  #utptable[
    #tabularx(
      columns: (16%, 20%, 1fr),
      styles: (navy-bold, (font: "Source Code Pro", size: 0.88em)),
      header: ([Message], [Sent to], [Meaning]),
      [DISCOVER], [broadcast], [Is there a DHCP server out there?],
      [OFFER], [broadcast/unicast], [Yes, and here is an address you may have],
      [REQUEST], [broadcast], [I accept that one],
      [ACK], [broadcast/unicast], [Confirmed, it is yours for the lease duration],
    )
  ]

  #note[
    DISCOVER is broadcast because the client has no address and no server to aim at. It fills the source field with `0.0.0.0` and the destination with `255.255.255.255`.

    REQUEST is also broadcast, and this is the part students find odd. The client already knows which server it wants --- but if two servers made offers, the broadcast tells the #emph[declined] server to release the address it had reserved. Unicasting the request would leave that address stranded until its offer timed out.
  ]

  #v(6pt)
  #strong[Part B --- Global pools.]

  #include "visuals/06-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:dhcp>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] The relay forwards requests between the client LAN and server; it is not itself a replacement for the pool’s gateway setting. Keep this remote-pool exercise separate from the later local-pool example and test the gateway before a remote destination.

  #include "visuals/06-worked-case.typ"

  ```terminal
  system-view
  dhcp enable

  ip pool LAN1
   network 192.168.1.0 mask 255.255.255.0
   gateway-list 192.168.1.1
   dns-list 8.8.8.8 114.114.114.114
   excluded-ip-address 192.168.1.2 192.168.1.10
   lease day 1
  quit

  interface GigabitEthernet 0/0/0
   ip address 192.168.1.1 24
   dhcp select global
  quit
  ```

  #warning[
    `dhcp enable` is required globally before any pool works, and forgetting it is the most common failure in this lab. Pools configure without complaint and simply never respond.

    `excluded-ip-address` matters too. Reserve addresses used by statically configured hosts; do not rely on conflict detection to protect those assignments.
  ]

  #v(6pt)
  #strong[Part C --- Interface pools.]

  A global pool is defined centrally and selected per interface. An interface pool is defined on the interface itself and derives its network from that interface’s address:

  ```terminal
  interface GigabitEthernet 0/0/1
   ip address 192.168.2.1 24
   dhcp select interface
   dhcp server dns-list 8.8.8.8
   dhcp server excluded-ip-address 192.168.2.2 192.168.2.5
  quit
  ```

  Use interface pools for a single directly attached segment; use global pools when you need one definition serving several interfaces, or when a relay is involved.

  #v(6pt)
  #strong[Part D --- Crossing a router.]

  Routers do not forward broadcasts, so a client on one segment cannot reach a DHCP server on another. That is deliberate --- and the reason a relay exists.

  ```terminal
  interface GigabitEthernet 0/0/2
   dhcp select relay
   dhcp relay server-ip 192.168.1.1
  quit
  ```

  #note[
    The relay receives the broadcast DISCOVER, converts it to a unicast addressed to the server, and --- critically --- records the receiving interface’s address in the packet’s `giaddr` field.

    That field is how the server knows which pool to draw from. Without it the server would see a request arriving from a router and have no idea which subnet the client is actually on.
  ]

  #v(6pt)
  #strong[Part E --- Verify from both ends.]

  #utptable[
    #tabularx(
      columns: (44%, 1fr),
      styles: ((font: "Source Code Pro", size: 0.88em),),
      header: ([Command], [Shows]),
      [display ip pool], [Pools, sizes, and how many addresses are in use],
      [display ip pool name LAN1 used], [Which addresses are leased, and to whom],
      [display dhcp relay all], [Relay configuration and target server],
      [Client IP settings / ipconfig], [Whether the client actually received an address],
    )
  ]

  #tip[
    #strong[Client gets no address.] Check `dhcp enable` first --- then that the interface has `dhcp select` applied at all.

    #strong[Client gets an address from the wrong pool.] On a relayed request, the `giaddr` does not match any pool network. Confirm the relay interface’s address falls inside the intended pool.

    #strong[Address conflicts appear.] Static assignments are inside the pool range and not excluded.

    #strong[Works on the local segment, fails across the router.] Relay not configured, or pointing at an address the relay itself cannot reach. Ping the server from the relay router.
  ]

  #exercises[
    Capture the exchange in Wireshark with the display filter `dhcp` (older Wireshark versions may use `bootp`).

    Find the DISCOVER and read its source address. Then explain, in one sentence, how the server’s OFFER reaches a client that does not yet have an address to send it to.
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:dhcp>)[the chapter explanation] and map its states to the steps below.

#include "visuals/06-dhcp-chapter.typ"

#checklist[
  #strong[Explain and extend your result.] Inspect the assigned address, mask, gateway and lease. Test the gateway first, then a remote destination, and identify the first failed checkpoint if access is incomplete.

  - `dhcp enable` present before any pool configuration.
  - Both a global pool and an interface pool demonstrated.
  - Static addresses excluded from every pool range.
  - `display ip pool` shows leases actually issued.
  - Relay demonstrated with a client on a different segment from the server.
]
