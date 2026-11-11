#import "/.shared/typst/utp.typ": *
#unit("labs", "02-ensp-vrp")

#lab("2")[Build a topology and survive the VRP command line] <sec:lab02-ensp>

#callout("labproject", title: [Two routers, one cable, and a working ping])[#strong[Coverage.] Chapter~#ref(label("ch:ensp-vrp"), supplement: none). \
#strong[Goal.] Learn the view hierarchy well enough that every later lab becomes typing rather than guessing.


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/02-flow.typ"


#strong[Worked implementation: Two routers on one subnet.] Use fresh lab devices. These blocks target the classic eNSP VRP command family used in the chapter. Match interface names with `display interface brief`. Enter each block on its named device; respond to interactive prompts before continuing.

#strong[R1.] Cable R1 GE0/0/0 to R2 GE0/0/0. Apply this block on the named router. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab02-01.txt", first: 1, last: none, lang: "text")

#strong[R2.] Cable R1 GE0/0/0 to R2 GE0/0/0. Apply this block on the named router. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab02-02.txt", first: 1, last: none, lang: "text")

#strong[Verify on R1.] Both interfaces must be up/up before the ping. Save only after the check succeeds; answer the device confirmation prompt. #source-code("/DATA COMMUNICATION & NETWORKING/labs/configs/lab02-03.txt", first: 1, last: none, lang: "text")

#strong[Expected evidence.] R1 must reach R2 directly; no static route is needed for their shared subnet.

#callout("labmode", title: [How to use this lab])[This lab has almost no networking content, and it is the most important one in the course. Every configuration you write for the next seven labs assumes you can move between VRP views without thinking about it.

Do it until it is boring. Then do the troubleshooting section, which is where the actual learning is.]

#strong[Part A --- The view hierarchy.]

VRP puts you in one of several #strong[views], and a command only exists in the view it belongs to. "Command not found" almost always means "right command, wrong view".


#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/02-trace.typ"


#strong[Use the chapter while coding.] Revisit #link(label("ch:ensp-vrp"))[the earlier chapter explanation]; match its operation to the variables and state changes below.

#strong[Follow the supplied implementation.] Keep the worked configuration's addressing together. Later individual CLI exercises may use a separate practice subnet; do not mix one side from each example. Check the prompt to distinguish configuration commands from display commands. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/02-worked-case.typ"


#code-block("<Huawei>                        user view      -- look, do not change\n<Huawei> system-view\n[Huawei]                        system view    -- global configuration\n[Huawei] interface GigabitEthernet 0/0/0\n[Huawei-GigabitEthernet0/0/0]   interface view -- this interface only\n[Huawei-GigabitEthernet0/0/0] quit\n[Huawei] quit\n<Huawei>", lang: "text")

#callout("keyidea", title: [Key idea])[The prompt tells you where you are, and it is the only reliable indicator:

`<angle brackets>` --- user view. Read-only commands: `display`, `ping`, `save`. \
`[square brackets]` --- a configuration view. The text after the hyphen names the exact object you are editing.

If a command is rejected, read the prompt before re-reading the command.]

#strong[Part B --- Build the direct link.]

Place two routers, connect `GE0/0/0` to `GE0/0/0`, and start both devices. Wait for the interface indicators to turn green before configuring --- eNSP will accept configuration on a booting device and then discard it.

#code-block("system-view\nsysname R1\ninterface GigabitEthernet 0/0/0\n ip address 192.168.1.1 24\n undo shutdown\nquit", lang: "text")

Repeat on R2 with `192.168.1.2 24`. Then, from R1:

#code-block("<R1> ping 192.168.1.2", lang: "text")

#callout("pitfall", title: [Common mistake])[`ip address 192.168.1.1 24` uses a prefix length. `ip address 192.168.1.1 255.255.255.0` uses a mask. Both are accepted and mean the same thing --- but mixing the two styles across a lab report makes it hard to spot a genuine mismatch.

Pick one and use it everywhere. This course uses prefix length.]

#strong[Part C --- Verify, never assume.]

Configuration entered without error is not configuration that works.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Command], [Answers],),
    table.hline(),
    [display ip interface brief], [Which interfaces are up, with what addresses],
    [display current-configuration], [What is running right now],
    [display saved-configuration], [What survives a reboot],
    [display version], [VRP version and uptime],
    [display interface GigabitEthernet 0/0/0], [Errors, duplex, and packet counters],
  )]
  , kind: table
  )

The first of these is the one you will use hundreds of times:

#code-block("<R1> display ip interface brief\nInterface              IP Address/Mask      Physical  Protocol\nGigabitEthernet0/0/0   192.168.1.1/24       up        up\nGigabitEthernet0/0/1   unassigned           down      down", lang: "text")

#callout("keyidea", title: [Key idea])[Two status columns, two different failures.

#strong[Physical down] means the cable, the port, or `shutdown`. It is a layer-1 problem and no amount of IP configuration will fix it.

#strong[Physical up, protocol down] means the link is electrically fine but the layer-2 or layer-3 configuration disagrees --- a missing address, an encapsulation mismatch, or a failed PPP authentication as in Lab~#link(label("sec:lab09-wan"))[9].

Reading these two columns correctly will diagnose most of the faults you meet this semester.]

#strong[Part D --- Save your work.]

#code-block("<R1> save\nThe current configuration will be written to the device. Continue? [Y/N] y", lang: "text")

#callout("troubleshoot", title: [Troubleshooting])[#strong[Ping fails but both interfaces are up/up.] Check the addresses are in the same subnet. `192.168.1.1/24` and `192.168.2.2/24` are two different networks and will never ping directly.

#strong[Device will not start in eNSP.] eNSP needs VirtualBox. If routers stay red, VirtualBox is missing, the wrong version, or virtualisation is disabled in BIOS.

#strong[Configuration vanished after restart.] You did not `save`. `display saved-configuration` shows what would actually survive.

#strong[Command rejected in the right view.] Check the abbreviation is unambiguous --- `dis` works, `d` does not.]

#callout("tryit", title: [Try it yourself])[Run `shutdown` on R1's `GE0/0/0`, then check `display ip interface brief` on #emph[both] routers. Which columns change on R1, and which on R2? Explain why the far end can tell.]]

#strong[Chapter connection.] Revisit #link(label("ch:ensp-vrp"))[the chapter explanation] and map its states to the steps below. 
#include "/DATA COMMUNICATION & NETWORKING/labs/visuals/02-ensp-vrp-chapter.typ"


#callout("verification", title: [Verification checklist])[#strong[Explain and extend your result.] Save the working configuration and capture the interface summary. Temporarily shut the lab link, observe the state change, then restore it and repeat the direct ping.

- `display ip interface brief` shows up/up on both routers.

- A successful ping is captured with its statistics line, not just the prompt.

- The configuration was saved and confirmed with `display saved-configuration`.

- Address style (prefix length or mask) is consistent throughout.]
