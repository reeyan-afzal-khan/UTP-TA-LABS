#import "/.shared/typst/utp.typ": *
#unit("chapters", "00-toolkit")

= Your Toolkit and Environment Setup <ch:toolkit>

#chapterguide[Prepare the Windows environment for Wireshark and Huawei eNSP.][Install Wireshark for Lab~1, set up eNSP and VirtualBox, and verify that a virtual router reaches the VRP prompt.]

#strong[#link("https://www.wireshark.org/download.html")[Wireshark]] captures and decodes traffic that reaches a selected network interface; use it for packet observations in Lab~1. Huawei eNSP is the simulator used to build and run topologies in Labs~2--9. It starts virtual routers and switches through Oracle VirtualBox, so an installation is ready only after a device boots to its VRP prompt. Follow the versions specified by your instructor to avoid compatibility problems.

== Follow the course installation sequence

The course walkthrough follows three steps: prepare a Windows~10 virtual
machine in VirtualBox, install Wireshark for Lab~1, then install eNSP inside
that Windows environment. Complete them in order.

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    column-fill: (mix(pale-blue, 55%), none),
    [Part 1: Windows], [#strong[#text(fill: blue)[#link("https://www.youtube.com/watch?v=PK8ZYZh7S_w\\&t=2s")[Install Windows 10 in VirtualBox]]]],
    table.hline(stroke: 0.55pt + rule-color),
    [Part 2: eNSP], [#strong[#text(fill: blue)[#link("https://youtu.be/YT5YimhyX18?t=5")[Install eNSP in the Windows environment]]]],
  )
]

=== Quick troubleshooting

- #strong[Wireshark shows no interfaces:] confirm Npcap was installed,
  then restart Windows and check that the interface is enabled.
- #strong[An eNSP device will not start:] verify that VirtualBox is
  installed and that hardware virtualization is available to the Windows
  environment; confirm the course-specified versions are being used.
- #strong[The console has not reached the VRP prompt:] allow the device
  time to boot. If it remains stuck, record the exact message and ask for
  help before changing several settings at once.
