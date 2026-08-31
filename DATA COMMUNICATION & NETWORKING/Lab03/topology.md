# Lab 3 topology — static routing with a backup path

```
        192.168.1.0/24                          192.168.3.0/24
              |                                       |
            [PC1]                                   [PC3]
              |                                       |
        GE0/0/1|                                      |GE0/0/1
          +----+----+   10.0.12.0/30   +---------+    +----+----+
          |   R1    |------------------|   R2    |----|   R3    |
          |         |GE0/0/0    GE0/0/0|         |GE0/0/1  GE0/0/0
          +----+----+                  +---------+    +----+----+
               |                                           |
               |          10.0.13.0/30 (backup path)       |
               +-------------------------------------------+
                GE0/0/2                              GE0/0/2
```

## Addressing

| Device | Interface | Address | Purpose |
| --- | --- | --- | --- |
| R1 | GE0/0/1 | 192.168.1.1/24 | LAN 1 gateway |
| R1 | GE0/0/0 | 10.0.12.1/30 | primary link to R2 |
| R1 | GE0/0/2 | 10.0.13.1/30 | backup link to R3 |
| R2 | GE0/0/0 | 10.0.12.2/30 | link to R1 |
| R2 | GE0/0/1 | 10.0.23.2/30 | link to R3 |
| R3 | GE0/0/0 | 10.0.23.3/30 | link to R2 |
| R3 | GE0/0/1 | 192.168.3.1/24 | LAN 3 gateway |
| R3 | GE0/0/2 | 10.0.13.3/30 | backup link to R1 |
| PC1 | — | 192.168.1.10/24, gw 192.168.1.1 | |
| PC3 | — | 192.168.3.10/24, gw 192.168.3.1 | |

## Why /30 on the transit links

A point-to-point link needs exactly two usable addresses. A /30 gives four
total: network, two hosts, broadcast. Using /24 there would waste 252
addresses and tells a reader nothing about the link's purpose.

## The three phases

1. **Before routes.** Ping PC1 → PC3 fails. R1 has no entry for 192.168.3.0/24
   and drops the packet. Capture `display ip routing-table` — every entry is
   `Direct`. This is your "before" evidence.

2. **Routes one way only.** Add routes on R1. Ping still fails, because R3 has
   no route back and the *reply* is dropped. `tracert` shows the trace getting
   further before stopping — that is the return path failing.

3. **Both directions plus backup.** Add the reverse routes, then a backup with
   worse preference. Shut the primary and count lost pings.
