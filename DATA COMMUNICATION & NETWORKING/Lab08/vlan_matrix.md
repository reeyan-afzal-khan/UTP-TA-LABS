# Lab 8 — connectivity matrix

Fill this in by testing. Predict each cell **before** you test it, then
record what actually happened. Disagreements are the interesting part.

## Hosts

| Host | Switch | Port | VLAN | Address |
| --- | --- | --- | --- | --- |
| PC1 | SW1 | GE0/0/1 | 10 | 192.168.10.1/24 |
| PC2 | SW1 | GE0/0/2 | 20 | 192.168.20.1/24 |
| PC3 | SW2 | GE0/0/1 | 10 | 192.168.10.2/24 |
| PC4 | SW2 | GE0/0/2 | 20 | 192.168.20.2/24 |
| PC5 | SW1 | GE0/0/3 | 30 | 192.168.10.3/24 |

Note PC5: **same subnet as VLAN 10, different VLAN.** It must still fail
to reach PC1. That is the whole point of layer-2 separation — it cannot be
bypassed by reconfiguring a host's IP address.

## Matrix

| From \ To | PC1 (v10) | PC2 (v20) | PC3 (v10) | PC4 (v20) | PC5 (v30) |
| --- | :---: | :---: | :---: | :---: | :---: |
| **PC1** (v10) | — | | | | |
| **PC2** (v20) | | — | | | |
| **PC3** (v10) | | | — | | |
| **PC4** (v20) | | | | — | |
| **PC5** (v30) | | | | | — |

Expected: same VLAN succeeds (including across the trunk); different VLAN
fails, regardless of subnet.

## Diagnosing a failure

| Symptom | Likely cause |
| --- | --- |
| Same VLAN, same switch, fails | Ports not both access in that VLAN — check `display port vlan` |
| Same VLAN, across switches, fails | Trunk not allowing that VLAN, or VLAN missing on the second switch |
| **Different VLANs succeed** | Native VLAN mismatch — a security failure, not a success |
| Some VLANs cross, others do not | `allow-pass` replaced rather than extended the list |

## The native VLAN experiment

Set the native VLAN to 10 on SW1 and 20 on SW2. Ping between VLANs — it
will work.

That is a leak, not a fix. SW1 sends VLAN 10 untagged; SW2 receives an
untagged frame and assigns it to its own native VLAN 20. Two supposedly
separate VLANs are now joined, silently, with no error anywhere.

Capture it in Wireshark, note which frames carry a tag and which do not,
then set both ends to 999 and confirm the isolation returns.
