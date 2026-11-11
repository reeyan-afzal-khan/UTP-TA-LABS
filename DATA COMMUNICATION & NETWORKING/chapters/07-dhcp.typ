#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-dhcp")


#heading(level: 1)[DHCP Address Allocation]
<ch:dhcp> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Router and switch interface configuration, IPv4 subnetting, and basic reachability.

*By the end, you can:* Explain DHCP's purpose, enable DHCP, build global and interface-based pools, configure switches to request addresses, reserve/exclude addresses, set leases and DNS information, and verify allocation state.]


#heading(level: 2)[What DHCP automates]
 Dynamic Host Configuration Protocol (DHCP) assigns clients an IP address and options such as a subnet mask, gateway, and DNS server. It improves consistency and reduces manual administration.


#heading(level: 3)[The four-message exchange]
 A client with no address cannot yet be addressed, so the conversation begins as a broadcast. The four steps are remembered as #strong[DORA].

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/71c1ba4a1fe564ac.cetz.json") The #strong[Request] is broadcast rather than sent to the chosen server. That is deliberate: if two servers made offers, the broadcast tells the one that was #emph[not] chosen to release the address it had reserved.], caption: [The four DHCP messages, with the source and destination addresses each one actually carries. Note that the client is still using `0.0.0.0` as its source until the Acknowledge arrives.]) <fig:dora>

#callout("keyidea", title: [Key idea])[Discover and Request are broadcasts. Routers do not forward broadcasts, so a client and its DHCP server must share a broadcast domain --- or something must carry the request across. That "something" is the relay, in Section~#ref(label("sec:dhcp-relay"), supplement: none).]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/dhcp-overview-diagram.png", width: 90%)], caption: [A DHCP server and its clients, from the supplied overview. A client starts without an address and leases one from the server.]) <fig:dhcp-overview-diagram>


#heading(level: 2)[The detailed lab topology]
 R1 and R3 act as DHCP servers; S1 and S2 are clients. The lab compares named global pools with interface-based pools.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#image("/DATA COMMUNICATION & NETWORKING/figures/dhcp-topology.png", width: 90%)], caption: [The topology of the detailed supplied DHCP lab. R1 and R3 act as DHCP servers; S1 and S2 are clients.]) <fig:dhcp-topology>

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Mechanism], [How the source configures it],),
    table.hline(),
    [Global pool], [Define a named `ip pool`, then select it with `dhcp select global`.],
    [Interface-based pool], [Use `dhcp select interface`; configure exclusions, DNS, and lease settings under that interface.],
  )]
  , kind: table
  )


#heading(level: 2)[Step 1: prepare interfaces and isolate the intended path]
 Configure addressing and disable unused paths before testing, so only the intended DHCP server can respond.


#heading(level: 2)[Step 2: enable DHCP globally on the routers]
 Enable DHCP globally before configuring pools. #code-block("[R1] dhcp enable\n[R3] dhcp enable", lang: "text")


#heading(level: 2)[Step 3: create the global address pools]
 R1 creates `pool1` for `10.0.12.0/24`; R3 creates `pool2` for `10.0.23.0/24`. Each lease lasts 1 day and 12 hours.

#code-block("[R1] ip pool pool1\n[R1-ip-pool-pool1] network 10.0.12.0 mask 24\n[R1-ip-pool-pool1] gateway-list 10.0.12.1\n[R1-ip-pool-pool1] lease day 1 hour 12\n[R1] interface GigabitEthernet 0/0/1\n[R1-GigabitEthernet0/0/1] dhcp select global\n\n[R3] ip pool pool2\n[R3-ip-pool-pool2] network 10.0.23.0 mask 24\n[R3-ip-pool-pool2] gateway-list 10.0.23.3\n[R3-ip-pool-pool2] lease day 1 hour 12\n[R3] interface GigabitEthernet 0/0/2\n[R3-GigabitEthernet0/0/2] dhcp select global", lang: "text")


#heading(level: 2)[Step 4: make the switches DHCP clients]
 Configure the management interface as a DHCP client. #code-block("[S1] dhcp enable\n[S1] interface Vlanif 1\n[S1-Vlanif1] ip address dhcp-alloc\n<S1> display ip interface brief", lang: "text") Repeat on S2, then inspect the corresponding server pool.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Command], [What it proves],),
    table.hline(),
    [display ip pool name pool1], [R1 pool settings and allocation counters.],
    [display ip pool name pool2], [R3 pool settings and allocation counters.],
    [display ip interface brief], [Address and state of the switch Vlanif1.],
  )]
  , kind: table
  )


#heading(level: 2)[Step 5: build interface-based address pools]
 Next, configure DHCP directly under the active routed interfaces. #code-block("[R1] interface GigabitEthernet 0/0/2\n[R1-GigabitEthernet0/0/2] dhcp select interface\n[R1-GigabitEthernet0/0/2] dhcp server dns-list 10.0.23.254\n[R1-GigabitEthernet0/0/2] dhcp server excluded-ip-address 10.0.23.254\n[R1-GigabitEthernet0/0/2] dhcp server lease day 1 hour 12\n\n[R3] interface GigabitEthernet 0/0/1\n[R3-GigabitEthernet0/0/1] dhcp select interface\n[R3-GigabitEthernet0/0/1] dhcp server dns-list 10.0.12.254\n[R3-GigabitEthernet0/0/1] dhcp server excluded-ip-address 10.0.12.254\n[R3-GigabitEthernet0/0/1] dhcp server lease day 1 hour 12", lang: "text")

#callout("keyidea", title: [Key idea])[`excluded-ip-address` prevents the DNS server address from being leased to a client.]


#heading(level: 3)[What a lease actually does]
 The lab sets a lease of 1 day 12 hours. A lease is not a countdown to disconnection: the client starts trying to renew halfway through, so a brief server outage is invisible.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/f64e1b4cf766124f.cetz.json")], caption: [The three moments in a lease. A client that reaches T2 has lost contact with its own server and starts broadcasting to any server that will answer.]) <fig:dhcp-lease>

#callout("keyidea", title: [Key idea])[`display ip pool` shows how many addresses are used and how many are idle. An exhausted pool and a pool full of stale leases look identical in that output, which is why the lease time is a design decision rather than a default to leave alone.]


#heading(level: 2)[Step 6: force a fresh client request]
 Cycle Vlanif1 to force a fresh request from the interface-based pool. #code-block("[S2] interface Vlanif 1\n[S2-Vlanif1] shutdown\n[S2-Vlanif1] undo shutdown\n\n[R1] interface GigabitEthernet 0/0/2\n[R1-GigabitEthernet0/0/2] undo shutdown", lang: "text") Repeat for S1 and R3 on the other subnet.

#callout("verification", title: [Verification checklist])[Success requires a client address from the expected subnet and a matching used lease in the server pool.]


#heading(level: 2)[DHCP relay: reaching a server on another segment]
<sec:dhcp-relay>

Everything above assumes the client and the server share a segment. Real networks centralise the DHCP server, so the client's broadcast has to cross a router that, by design, will not forward it.

A #strong[relay agent] solves this by translating the conversation. The router receives the broadcast on the client side, rewrites it as a #emph[unicast] to the configured server, and inserts the receiving interface's address so the server knows which pool to allocate from.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/DATA COMMUNICATION & NETWORKING/figures/diagrams/b3640067e8961e88.cetz.json")], caption: [The relay converts a broadcast into a unicast, and back. It inserts the address of the interface that received the request, so the server picks the pool for the client's own subnet.]) <fig:dhcp-relay>

#code-block("[R1] dhcp enable\n[R1] interface GigabitEthernet 0/0/2\n[R1-GigabitEthernet0/0/2] ip address 192.168.3.1 24\n[R1-GigabitEthernet0/0/2] dhcp select relay\n[R1-GigabitEthernet0/0/2] dhcp relay server-ip 10.0.12.1", lang: "text")

#callout("pitfall", title: [Common mistake])[The relay must still be able to reach the server by ordinary routing, and the server needs a #emph[return] route to the client subnet. A relay that is configured correctly but has no return path produces the same silent symptom as no relay at all: the client waits and eventually gives up.]


#heading(level: 2)[Troubleshooting DHCP]


+ Confirm the server-side routed interface is up and has the intended subnet address.

+ Confirm `dhcp enable` is present on the router.

+ For a global pool, verify the pool network/gateway and `dhcp select global` on the correct interface.

+ For an interface pool, verify `dhcp select interface` plus any excluded/DNS/lease settings.

+ Confirm the client has DHCP enabled and uses `ip address dhcp-alloc` on Vlanif1.

+ Cycle the client interface if the exercise requires a new lease, then inspect the client and pool state again.

#callout("quickcheck", title: [Check your understanding])[+ What is the difference between a named global pool and an interface-based pool in this lab?

+ Why does the source exclude `10.0.23.254` and `10.0.12.254` from allocation?

+ Which command proves that a pool has allocated an address?

+ Why does the lab shut down unused links during preparation?]
