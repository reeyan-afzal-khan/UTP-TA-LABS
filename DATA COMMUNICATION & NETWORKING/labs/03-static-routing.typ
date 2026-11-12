#import "/.shared/typst/utp.typ": *
#unit("labs", "03-static-routing")

#labsection(3, label: <sec:lab03-static>)[Static routing and the backup route]

#labproject[Three routers, three networks, and one deliberate failure][
  #strong[Coverage.] Chapter~#ref(<ch:static-routing>). \

  #strong[Goal.] Make a router forward to a network it is not attached to, then prove a backup route takes over when the primary fails.

  #include "visuals/03-flow.typ"

  #strong[Worked implementation: Three-router primary and backup paths.]
  Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

  #strong[R1 addressing.] Cable the matching 10.0.12, 10.0.23 and 10.0.13 subnets. R1 and R3 GE0/0/2 connect to their LAN PCs.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-01.txt", lang: "terminal")

  #strong[R2 addressing.] Cable the matching 10.0.12, 10.0.23 and 10.0.13 subnets. R1 and R3 GE0/0/2 connect to their LAN PCs.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-02.txt", lang: "terminal")

  #strong[R3 addressing.] Cable the matching 10.0.12, 10.0.23 and 10.0.13 subnets. R1 and R3 GE0/0/2 connect to their LAN PCs.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-03.txt", lang: "terminal")

  #strong[R1 routes.] Apply after recording the connected-only route table. To observe the missing-return-path failure, apply R3’s routes last.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-04.txt", lang: "terminal")

  #strong[R2 routes.] Apply after recording the connected-only route table. To observe the missing-return-path failure, apply R3’s routes last.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-05.txt", lang: "terminal")

  #strong[R3 routes.] Apply after recording the connected-only route table. To observe the missing-return-path failure, apply R3’s routes last.

  #lstinput("/DATA COMMUNICATION & NETWORKING/labs/configs/lab03-06.txt", lang: "terminal")

  #strong[Expected evidence.] R3 normally returns directly over the R1--R3 link; this keeps the return path available when R1’s R2-facing link is disabled. The forward and return paths may differ. Use PC1 192.168.1.10/24, gateway 192.168.1.1, and PC3 192.168.3.10/24, gateway 192.168.3.1. Ping between PCs. Disable R1 GE0/0/0 to withdraw the local primary next hop; inspect the route before restoring the interface.

  #v(6pt)
  #strong[Part A --- Why the first ping fails.]

  Configure the interfaces, then ping from R1’s LAN to R3’s LAN before adding any routes. It will fail, and understanding exactly why is the point of the lab.

  #keyidea[
    A router forwards only to networks in its routing table. Directly connected networks appear automatically; everything else must be learned --- statically here, dynamically in Lab~#labref(<sec:lab04-ospf>).

    R1 has no entry for R3’s LAN, so it drops the packet and reports #emph[Destination host unreachable]. The packet never reaches R2. Nothing is broken; the router is doing exactly what it was told.
  ]

  Confirm before configuring:

  #include "visuals/03-trace.typ"

  #strong[Use the chapter while coding.] Revisit #link(<ch:static-routing>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Match the destination prefix and next hop in display ip routing-table to the configuration, not just to a successful ping. This experiment removes R1’s direct link to the primary next hop. It does not demonstrate detection of every remote failure. Record the selected next hop before shutdown, during failover and after undo shutdown; then explain the return path from R3.

  #include "visuals/03-worked-case.typ"

  ```terminal
  <R1> display ip routing-table
  ```

  Count the entries. Identify connected prefixes and local host routes; the exact route types depend on the VRP image. Record that output --- it is the \"before\" half of your evidence.

  #v(6pt)
  #strong[Part B --- Static route syntax.]

  ```terminal
  ip route-static <destination> <mask> <next-hop>
  ```

  The next hop must be an address R1 can already reach --- normally the neighbouring router’s interface on the shared link. A next hop R1 cannot resolve produces a route that looks correct in the table and silently discards traffic.

  #pitfall[
    The destination is a #emph[network] address, not a host address.

    `ip route-static 192.168.3.0 24 10.0.12.2` is a route to a network. \

    `ip route-static 192.168.3.1 24 10.0.12.2` has host bits set for that mask; correct it instead of relying on platform-specific handling.

    Always write the network address with host bits zeroed.
  ]

  #v(6pt)
  #strong[Part C --- Routes are one-directional.]

  Add routes on R1 so it can reach R3’s LAN. Ping again. It still fails.

  #keyidea[
    This is the single most common static-routing error, and it is worth meeting deliberately.

    Your ping now reaches R3. R3 has no route back to R1’s LAN, so the #emph[reply] is dropped. From R1 the symptom looks identical to the original failure, which is why students often conclude their route did not work.

    Connectivity requires a route in both directions. Always configure and verify both ends before concluding anything.
  ]

  Use the LAN PCs for this test. Inspect the forward and return route tables separately: a stalled traceroute alone cannot prove which direction failed.

  #v(6pt)
  #strong[Part D --- Backup routes and preference.]

  Add a second route to the same destination through a different neighbour, with a worse preference:

  ```terminal
  ip route-static 192.168.3.0 24 10.0.12.2              # primary, preference 60
  ip route-static 192.168.3.0 24 10.0.13.3 preference 100  # backup
  ```

  #keyidea[
    #term[Preference] (Huawei’s term for administrative distance) ranks #emph[sources] of routing information. Lower wins. Static routes default to 60; OSPF internal routes are 10.

    Only the preferred route is installed in the forwarding table. The backup sits inactive until the primary’s next hop becomes unreachable, at which point it is installed automatically.

    This is failover, not load sharing. Traffic does not split across the two paths --- give them equal preference if that is what you want.
  ]

  #v(6pt)
  #strong[Part E --- Prove the failover.]

  #utpsteps[
    + `display ip routing-table` --- confirm only the primary is present, with preference 60.
    + Start a long ping from R1’s LAN so you can watch the interruption.
    + Shut down the primary link: `interface GigabitEthernet 0/0/0` then `shutdown`.
    + `display ip routing-table` again --- the backup should now be installed.
    + Count how many pings were lost during the transition.
    + `undo shutdown` and confirm the primary returns.
  ]

  That lost-ping count is the real result of this lab. Static failover is not instant: the router must first decide the next hop is unreachable.

  #troubleshoot[
    #strong[Route shows in the table but traffic fails.] The next hop is probably unreachable. Ping the next hop itself from the same router.

    #strong[Backup never activates.] Shutting an interface on the far end may leave the local interface up, so the next hop still appears valid. Shut the local interface, or verify with `display ip routing-table protocol static`.

    #strong[Both routes appear active.] They have equal preference, so you have configured load sharing rather than failover.
  ]

  #tryit[
    Replace both static routes with one default route, `ip route-static 0.0.0.0 0 10.0.12.2`. Does connectivity still work? What have you given up, and in what topology would that choice be dangerous?
  ]
]

#strong[Chapter connection.] Revisit #link(<ch:static-routing>)[the chapter explanation] and map its states to the steps below.

#include "visuals/03-static-routing-chapter.typ"

#verification[
  #strong[Explain and extend your result.] Record the route and ping before, during and after the specified shutdown. Explain why return routing must still work and why a failed ping alone does not identify the failed hop.

  - Routing tables captured before routes, after routes, and after the failover.
  - Both directions configured, with the one-way failure demonstrated rather than skipped.
  - Preference values visible in the table output.
  - Packet loss during failover counted and reported.
]
