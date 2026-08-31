# Lab 3 verification sequence

Capture output at each stage. The three routing tables are the deliverable.

## Stage 0 — before any routes

```
display ip routing-table
```
Expect: only `Direct` entries. Ping PC1 → PC3 **fails**.

> R1 has no entry for 192.168.3.0/24, so it drops the packet and reports
> *Destination host unreachable*. The packet never reaches R2. Nothing is
> broken — the router is doing exactly what it was told.

## Stage 1 — routes on R1 only

```
ip route-static 192.168.3.0 24 10.0.12.2
```
Ping **still fails**. Prove why:

```
tracert 192.168.3.10
```
The trace advances further than before, then stops. Forward path works;
the return path does not.

## Stage 2 — both directions

Add the mirror route on R3. Ping now succeeds.

## Stage 3 — backup and failover

```
ip route-static 192.168.3.0 24 10.0.13.3 preference 100
display ip routing-table protocol static
```
Only the preference-60 route is installed.

Failover test:
1. Start `ping -c 100` (or a long ping) from PC1 to PC3
2. `interface GigabitEthernet 0/0/0` then `shutdown` on R1
3. Re-check the routing table — backup should now be installed
4. **Count lost packets.** Report the number.
5. `undo shutdown` and confirm the primary returns

## What to report

| Item | Evidence |
| --- | --- |
| Routing table before routes | all `Direct` |
| One-way failure | `tracert` output showing where it stops |
| Working connectivity | ping with 0% loss |
| Backup inactive | routing table showing only preference 60 |
| Failover | routing table after shutdown + lost packet count |

The lost-packet count is the real result. Static failover is not instant.
