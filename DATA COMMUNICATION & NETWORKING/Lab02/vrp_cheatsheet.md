# Huawei VRP cheat sheet

## Views — the prompt tells you where you are

| Prompt | View | You can |
| --- | --- | --- |
| `<R1>` | User | Look, ping, save. Not change configuration. |
| `[R1]` | System | Global configuration |
| `[R1-GigabitEthernet0/0/0]` | Interface | Configure that one interface |
| `[R1-ospf-1]` | Protocol | Configure that protocol instance |

**"Command not found" almost always means right command, wrong view.**
Read the prompt before re-reading the command.

## Moving around

```
system-view          enter system view from user view
quit                 go up one level
return   (or Ctrl+Z) jump straight back to user view
```

## Verification — run these constantly

```
display ip interface brief        which interfaces are up, with what addresses
display current-configuration     what is running right now
display saved-configuration       what survives a reboot
display ip routing-table          how this router forwards
display version                   VRP version and uptime
display interface GE 0/0/0        errors, duplex, counters
```

## The two status columns

```
Interface              IP Address/Mask   Physical  Protocol
GigabitEthernet0/0/0   192.168.1.1/24    up        up
```

| Physical | Protocol | Means |
| --- | --- | --- |
| down | down | Cable, port, or `shutdown`. Layer 1. |
| up | down | Link is electrically fine; layer 2/3 disagree. Encapsulation mismatch, missing address, failed authentication. |
| up | up | Working. |

Reading these two columns separately will diagnose most faults this semester.

## Undoing things

VRP has no `no` command. It uses `undo`:

```
undo shutdown
undo ip address
undo ip route-static 192.168.3.0 24 10.0.12.2
```

## Abbreviations

Any unambiguous prefix works: `dis ip int br` = `display ip interface brief`.
`d` alone does not — too many commands start with it.

## Saving

```
save
```

Configuration is **not** saved automatically. `display saved-configuration`
shows what would actually survive a reboot.

## Gotchas

- Wait for interface indicators to turn green before configuring. eNSP accepts
  configuration on a booting device and then discards it.
- `ip address 192.168.1.1 24` and `ip address 192.168.1.1 255.255.255.0` are
  equivalent. Pick one style and keep it — mixing them hides genuine mismatches.
- eNSP needs VirtualBox. Routers stuck red usually means VirtualBox is missing,
  the wrong version, or virtualisation is disabled in BIOS.
