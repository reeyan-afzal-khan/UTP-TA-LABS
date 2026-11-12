#import "/.shared/typst/utp.typ": *
#unit("labs", "04-ospf")

#labsection(4, label: <sec:lab04-ospf>)[OSPF: let the network work it out]

#labproject[Replace your static routes with a protocol that adapts][
  #strong[Coverage.] Chapter~#ref(<ch:ospf>). \

  #strong[Goal.] Configure single-area OSPF, watch adjacencies form, and see the network reroute itself without you.

  #include "visuals/04-flow.typ"

  #strong[Worked implementation: The same triangle with OSPF area zero.]
  Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

  #strong[R1.] Use the same cabling and PC addresses as Lab 3. Router IDs must be unique.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab04-01.txt", lang: "terminal")

  #strong[R2.] Use the same cabling and PC addresses as Lab 3. Router IDs must be unique.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab04-02.txt", lang: "terminal")

  #strong[R3.] Use the same cabling and PC addresses as Lab 3. Router IDs must be unique.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab04-03.txt", lang: "terminal")

  #strong[Expected evidence.] Start a fresh triangle without the static routes from Lab 3. R1 and R3 must learn each other’s LAN through OSPF. Capture neighbours and the route table before and after one link failure.

  #labmode[
    Use the same topology as Lab~#labref(<sec:lab03-static>). Remove every static route first --- leaving them in place means you will not know which mechanism is carrying your traffic, and static routes have a better preference so they will win.

    #include "visuals/04-trace.typ"

    #strong[Use the chapter while coding.] Revisit #link(<ch:ospf>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

    #strong[Follow the supplied implementation.] Start from the stated fresh topology without the earlier static routes. Diagnose interface and neighbour state before changing route preferences. A configured network statement is an instruction; the neighbour and route displays are the evidence it took effect.

    #include "visuals/04-worked-case.typ"

    ```terminal
    undo ip route-static 192.168.3.0 24 10.0.12.2
    ```
  ]

  #v(6pt)
  #strong[Part A --- Why bother.]

  Static routing worked in Lab~#labref(<sec:lab03-static>). It also required you to configure every route on every router in both directions, and to predict every failure in advance. Add a fourth router and the work grows faster than the network.

  #keyidea[
    Static routing scales with the number of #emph[paths]. Dynamic routing scales with the number of #emph[routers].

    OSPF routers describe their own links to each other, and every router independently computes shortest paths across the resulting map. Add a link and it is advertised automatically; lose a link and the recalculation happens without you.
  ]

  #v(6pt)
  #strong[Part B --- Router IDs.]

  ```terminal
  system-view
  ospf 1 router-id 1.1.1.1
   area 0
    network 10.0.12.0 0.0.0.255
    network 192.168.1.0 0.0.0.255
   quit
  quit
  ```

  #pitfall[
    Set the router ID explicitly. If you do not, VRP picks one from the interface addresses --- and it may pick a different one after a reboot, which tears down every adjacency and produces a fault that looks random.

    A router ID is a 32-bit identifier that merely looks like an IP address. It does not need to be reachable, and by convention it is `1.1.1.1`, `2.2.2.2`, and so on.
  ]

  #v(6pt)
  #strong[Part C --- The wildcard mask.]

  OSPF’s `network` statement takes a wildcard mask, which is the bitwise inverse of a subnet mask. This trips up nearly everyone the first time.

  #utptable[
    #tabularx(
      columns: (22%, 26%, 26%, 1fr),
      styles: ((font: "Source Code Pro", size: 0.88em), (font: "Source Code Pro", size: 0.88em), (font: "Source Code Pro", size: 0.88em)),
      header: ([Prefix], [Subnet mask], [Wildcard], [Matches]),
      [/24], [255.255.255.0], [0.0.0.255], [256 addresses],
      [/30], [255.255.255.252], [0.0.0.3], [4 addresses],
      [/32], [255.255.255.255], [0.0.0.0], [exactly one],
      [/16], [255.255.0.0], [0.0.255.255], [65 536 addresses],
    )
  ]

  The rule: subtract each octet of the subnet mask from 255. The supplied `wildcard_calc.py` does this and shows the working, but do a few by hand first --- it appears in examinations.

  #keyidea[
    A 0 bit in a wildcard means “this bit must match”; a 1 bit means “do not care”. So `0.0.0.255` means the first three octets must match and the last is free --- exactly a `/24`.

    The `network` statement does not advertise a network. It selects which #emph[interfaces] participate in OSPF: any interface whose address falls inside the range is enabled.
  ]

  #v(6pt)
  #strong[Part D --- Watch the adjacency form.]

  ```terminal
  <R1> display ospf peer brief
   Area Id         Interface              Neighbor id     State
   0.0.0.0         GigabitEthernet0/0/0   2.2.2.2         Full
  ```

  #keyidea[
    `Full` is the only state that means success. Anything else is a diagnosis:

    `Init` --- hellos are being sent but the neighbour is not acknowledging them. Usually one-way connectivity. \

    `2-Way` --- neighbours see each other; on a broadcast segment, non-designated routers legitimately stay here. \

    `ExStart` / `Exchange` --- stuck here almost always means an MTU mismatch across the link. \

    `Full` --- databases synchronised, routes exchanged.

    Neighbours also fail to form if hello and dead intervals differ, if area IDs differ, or if authentication is configured on one side only.
  ]

  #v(6pt)
  #strong[Part E --- Read the routing table again.]

  ```terminal
  <R1> display ip routing-table protocol ospf
  ```

  OSPF routes carry preference 10 against static routing’s 60, so OSPF wins wherever both exist. Note the `Cost` column: Huawei derives it from interface bandwidth, so a gigabit path is preferred over a serial one without you saying so.

  #v(6pt)
  #strong[Part F --- Break it, and time the recovery.]

  Start a continuous ping, shut down the primary link, and count lost packets --- then compare with the figure from Lab~#labref(<sec:lab03-static>).

  #troubleshoot[
    #strong[Neighbour never leaves Init.] Traffic flows one way only. Check masks on both ends and any access lists.

    #strong[Stuck in ExStart or Exchange.] MTU mismatch. Compare `display interface` on both sides.

    #strong[Adjacency forms but no routes appear.] The `network` statement covers the link but not the LAN interface. Add a statement covering it.

    #strong[Routes appear then vanish repeatedly.] Duplicate router IDs. Every router in the area must be unique.
  ]

  #tryit[
    Compare your two failover measurements. OSPF’s default dead interval is 40 seconds, so recovery is not instant --- but it required no backup route from you, and it would have handled a failure you never anticipated.

    State the trade-off in one sentence, then say which you would deploy on a three-router branch network and why.
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:ospf>)[the chapter explanation] and map its states to the steps below.

#include "visuals/04-ospf-chapter.typ"

#verification[
  #strong[Explain and extend your result.] Capture neighbours and the selected route, then change one link’s availability. Compare convergence evidence and the resulting next hop; do not infer the path solely from configuration text.

  - All static routes removed before OSPF is configured.
  - Router IDs set explicitly and unique.
  - `display ospf peer brief` shows `Full` on every adjacency.
  - OSPF routes present with preference 10 and their costs.
  - Failover time measured and compared against the static-routing result.
]
