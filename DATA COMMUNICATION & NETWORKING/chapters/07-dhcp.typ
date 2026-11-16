#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-dhcp")

= DHCP Address Allocation <ch:dhcp>

#chapterguide[Router and switch interface configuration, IPv4 subnetting, and basic reachability.][Explain DHCP’s purpose, enable DHCP, build global and interface-based pools, configure switches to request addresses, reserve/exclude addresses, set leases and DNS information, and verify allocation state.]

== What DHCP automates

Dynamic Host Configuration Protocol (DHCP) assigns clients an IP address and options such as a subnet mask, gateway, and DNS server. It improves consistency and reduces manual administration.

=== The four-message exchange

A client with no address cannot yet be addressed, so the conversation begins as a broadcast. The four steps are remembered as #term[DORA].

#utpfig([The four DHCP messages, with the source and destination addresses each one actually carries. Note that the client is still using `0.0.0.0` as its source until the Acknowledge arrives.], label: <fig:dora>)[
  #canvas({
    seqactor("c", 0, [Client (S1)], ..host)
    seqactor("s", 7.6, [Server (R1)], ..server)
    seqlife("c", -4.5)
    seqlife("s", -4.5)
    seqmsg("c", "s", -0.85, [#strong[D]iscover], "arrow")
    node((8.15, -0.85), [broadcast `255.255.255.255`], font: font("tiny", fill: orange), anchor: "west")
    seqmsg("s", "c", -1.75, [#strong[O]ffer], "arrowb")
    node((8.15, -1.75), [“you may have 10.0.12.20”], font: font("tiny", fill: muted), anchor: "west")
    seqmsg("c", "s", -2.65, [#strong[R]equest], "arrow")
    node((8.15, -2.65), [broadcast again --- see below], font: font("tiny", fill: orange), anchor: "west")
    seqmsg("s", "c", -3.55, [#strong[A]cknowledge], "arrowb")
    node((8.15, -3.55), [lease confirmed, clock starts], font: font("tiny", fill: green), anchor: "west")
    node((-0.35, -0.85), [src 0.0.0.0], font: font("tiny", fill: muted), anchor: "east", align: right)
    node((-0.35, -2.65), [src 0.0.0.0], font: font("tiny", fill: muted), anchor: "east", align: right)
    node((-0.35, -4.05), [now 10.0.12.20], font: font("tiny", fill: green), anchor: "east", align: right)
  })

  #fignote[The #strong[Request] is broadcast rather than sent to the chosen server. That is deliberate: if two servers made offers, the broadcast tells the one that was #emph[not] chosen to release the address it had reserved.]
]

#note[
  Discover and Request are broadcasts. Routers do not forward broadcasts, so a client and its DHCP server must share a broadcast domain --- or something must carry the request across. That “something” is the relay, in Section~#ref(<sec:dhcp-relay>).
]

#utpfig([A DHCP server and its clients, from the supplied overview. A client starts without an address and leases one from the server.], label: <fig:dhcp-overview-diagram>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/dhcp-overview-diagram.png", width: 66%, height: 404.7848pt)
]

== The detailed lab topology

R1 and R3 act as DHCP servers; S1 and S2 are clients. The lab compares named global pools with interface-based pools.

#utpfig([The topology of the detailed supplied DHCP lab. R1 and R3 act as DHCP servers; S1 and S2 are clients.], label: <fig:dhcp-topology>)[
  #fitted-image("/DATA COMMUNICATION & NETWORKING/figures/dhcp-topology.png", width: 82%, height: 404.7848pt)
]

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Mechanism], [How the source configures it]),
    [Global pool], [Define a named `ip pool`, then select it with `dhcp select global`.],
    [Interface-based pool], [Use `dhcp select interface`; configure exclusions, DNS, and lease settings under that interface.],
  )
]

== Step 1: prepare interfaces and isolate the intended path

Configure addressing and disable unused paths before testing, so only the intended DHCP server can respond.

== Step 2: enable DHCP globally on the routers

Enable DHCP globally before configuring pools.

```terminal
[R1] dhcp enable
[R3] dhcp enable
```

== Step 3: create the global address pools

R1 creates `pool1` for `10.0.12.0/24`; R3 creates `pool2` for `10.0.23.0/24`. Each lease lasts 1 day and 12 hours.

```terminal
[R1] ip pool pool1
[R1-ip-pool-pool1] network 10.0.12.0 mask 24
[R1-ip-pool-pool1] gateway-list 10.0.12.1
[R1-ip-pool-pool1] lease day 1 hour 12
[R1] interface GigabitEthernet 0/0/1
[R1-GigabitEthernet0/0/1] dhcp select global

[R3] ip pool pool2
[R3-ip-pool-pool2] network 10.0.23.0 mask 24
[R3-ip-pool-pool2] gateway-list 10.0.23.3
[R3-ip-pool-pool2] lease day 1 hour 12
[R3] interface GigabitEthernet 0/0/2
[R3-GigabitEthernet0/0/2] dhcp select global
```

== Step 4: make the switches DHCP clients

Configure the management interface as a DHCP client.

```terminal
[S1] dhcp enable
[S1] interface Vlanif 1
[S1-Vlanif1] ip address dhcp-alloc
<S1> display ip interface brief
```

Repeat on S2, then inspect the corresponding server pool.

#utptable[
  #tabularx(
    columns: (42%, 1fr),
    styles: ((font: "Source Code Pro", size: 0.88em),),
    header: ([Command], [What it proves]),
    [display ip pool name pool1], [R1 pool settings and allocation counters.],
    [display ip pool name pool2], [R3 pool settings and allocation counters.],
    [display ip interface brief], [Address and state of the switch Vlanif1.],
  )
]

== Step 5: build interface-based address pools

Next, configure DHCP directly under the active routed interfaces.

```terminal
[R1] interface GigabitEthernet 0/0/2
[R1-GigabitEthernet0/0/2] dhcp select interface
[R1-GigabitEthernet0/0/2] dhcp server dns-list 10.0.23.254
[R1-GigabitEthernet0/0/2] dhcp server excluded-ip-address 10.0.23.254
[R1-GigabitEthernet0/0/2] dhcp server lease day 1 hour 12

[R3] interface GigabitEthernet 0/0/1
[R3-GigabitEthernet0/0/1] dhcp select interface
[R3-GigabitEthernet0/0/1] dhcp server dns-list 10.0.12.254
[R3-GigabitEthernet0/0/1] dhcp server excluded-ip-address 10.0.12.254
[R3-GigabitEthernet0/0/1] dhcp server lease day 1 hour 12
```

#note[
  `excluded-ip-address` prevents the DNS server address from being leased to a client.
]

=== What a lease actually does

The lab sets a lease of 1 day 12 hours. A lease is not a countdown to
disconnection: the client starts trying to renew halfway through, so a
brief server outage is invisible.

#utpfig([The three moments in a lease. A client that reaches T2 has lost contact with its own server and starts broadcasting to any server that will answer.], label: <fig:dhcp-lease>)[
  #canvas({
    connect((0, 0), (11, 0), line-width: 2.1918pt, draw: pale-teal)
    connect((0, 0), (5.5, 0), line-width: 2.1918pt, draw: green)
    connect((5.5, 0), (9.6, 0), line-width: 2.1918pt, draw: orange)
    connect((9.6, 0), (11, 0), line-width: 2.1918pt, draw: red)
    for (x, lab-v, sub, col) in ((0, "0", "lease granted", green), (5.5, "T1", "50% — renew", green), (9.6, "T2", "87.5% — rebind", orange), (11, "expiry", "address released", red)) {
      connect((x, -0.18), (x, 0.18), draw: col, line-width: widths.thick)
      node((x, 0.25), [#lab-v], font: font("script", weight: "bold", fill: col), anchor: "south")
      node((x, -0.25), [#sub], font: font("tiny", fill: muted), anchor: "north", align: center)
    }
    node((2.75, -0.95), [Client uses the address \
   and says nothing.], font: font("tiny", fill: muted), anchor: "north", align: center, text-width: 4.4)
    node((7.5, -0.95), [Unicast renewal to the \
   server that issued it.], font: font("tiny", fill: muted), anchor: "north", align: center, text-width: 3.8)
    node((10.6, -0.95), [Broadcast to #emph[any] \
   server.], font: font("tiny", fill: muted), anchor: "north", align: center, text-width: 3.4)
  })
]

#note[
  `display ip pool` shows how many addresses are used and how many are
  idle. An exhausted pool and a pool full of stale leases look identical in
  that output, which is why the lease time is a design decision rather than
  a default to leave alone.
]

== Step 6: force a fresh client request

Cycle Vlanif1 to force a fresh request from the interface-based pool.

```terminal
[S2] interface Vlanif 1
[S2-Vlanif1] shutdown
[S2-Vlanif1] undo shutdown

[R1] interface GigabitEthernet 0/0/2
[R1-GigabitEthernet0/0/2] undo shutdown
```

Repeat for S1 and R3 on the other subnet.

#checklist[
  Success requires a client address from the expected subnet and a matching used lease in the server pool.
]

== DHCP relay: reaching a server on another segment <sec:dhcp-relay>

Everything above assumes the client and the server share a segment. Real networks centralise the DHCP server, so the client’s broadcast has to cross a router that, by design, will not forward it.

A #term[relay agent] solves this by translating the conversation. The router receives the broadcast on the client side, rewrites it as a #emph[unicast] to the configured server, and inserts the receiving interface’s address so the server knows which pool to allocate from.

#utpfig([The relay converts a broadcast into a unicast, and back. It inserts the address of the interface that received the request, so the server picks the pool for the client’s own subnet.], label: <fig:dhcp-relay>)[
  #canvas({
    let ml = (font: font("script", fill: ink), align: center, inner-sep: 1.4944pt)
    node((0, 0), [Client], name: "c", ..host)
    node(right-of("c", 2.6), [Relay], name: "r", ..router)
    node(right-of("r", 3), [Server], name: "s", ..router)
    connect("c", "r", ..flowarrow, draw: orange)
    node(along("c", "r", t: 50%), [broadcast \
   #fsize("tiny")[stops here]], ..ml, text-width: 2.3, anchor: "south")
    connect("r", "s", ..flowarrow, draw: green)
    node(along("r", "s", t: 50%), [unicast to server \
   #fsize("tiny")[\+ “I am 192.168.3.1”]], ..ml, text-width: 2.6, anchor: "south")
    node(below-of("r", 0.9), [The server picks the pool matching #strong[192.168.3.1], so the client gets an address on its #emph[own] subnet --- not the server’s.], ..ml, text-width: 8.2)
    node(below-of("c", 0.35), [192.168.3.0/24], font: font("script", fill: muted))
    node(below-of("s", 0.35), [different segment], font: font("script", fill: muted))
  })
]

```terminal
[R1] dhcp enable
[R1] interface GigabitEthernet 0/0/2
[R1-GigabitEthernet0/0/2] ip address 192.168.3.1 24
[R1-GigabitEthernet0/0/2] dhcp select relay
[R1-GigabitEthernet0/0/2] dhcp relay server-ip 10.0.12.1
```

#warning[
  The relay must still be able to reach the server by ordinary routing, and the server needs a #emph[return] route to the client subnet. A relay that is configured correctly but has no return path produces the same silent symptom as no relay at all: the client waits and eventually gives up.
]

== Troubleshooting DHCP

#utpsteps[
  + Confirm the server-side routed interface is up and has the intended subnet address.
  + Confirm `dhcp enable` is present on the router.
  + For a global pool, verify the pool network/gateway and `dhcp select global` on the correct interface.
  + For an interface pool, verify `dhcp select interface` plus any excluded/DNS/lease settings.
  + Confirm the client has DHCP enabled and uses `ip address dhcp-alloc` on Vlanif1.
  + Cycle the client interface if the exercise requires a new lease, then inspect the client and pool state again.
]

#questions[
  + What is the difference between a named global pool and an interface-based pool in this lab?
  + Why does the source exclude `10.0.23.254` and `10.0.12.254` from allocation?
  + Which command proves that a pool has allocated an address?
  + Why does the lab shut down unused links during preparation?
]
