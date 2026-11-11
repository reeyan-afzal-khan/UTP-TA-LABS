# Data Communication & Networking

**Status: in development.** The book, all nine labs, and their PDFs are in place; the course is still being
reviewed before it is marked ready.

Built from the lecturer's laboratory materials: packet capture with Wireshark, then Huawei eNSP and the VRP
command line for static and OSPF routing, FTP, DHCP, link aggregation, VLANs and serial WAN links. A reference
chapter on layers and addresses opens the book; nine chapters in five stages follow, each followed by its lab,
which asks for a working configuration and the evidence that it works. A group project and a command reference
close the book.

**[Book (PDF, 91 pages)](../.all_pdfs/data-communication-networking/DCN-Book.pdf)** ·
[Lab bundles](../.all_pdfs/data-communication-networking) ·
[LaTeX source](main.tex) ·
[Lecturer materials](0.from_lecturer) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| Reference: Foundations: Layers, Addresses, and Frames | | 1 | |
| 1 Observe and Configure | 1–2 | 5 | 1, 2 |
| 2 Make Networks Reachable | 3–4 | 22 | 3, 4 |
| 3 Add Network Services | 5–6 | 39 | 5, 6 |
| 4 Build the Switched LAN | 7–8 | 55 | 7, 8 |
| 5 Connect Sites Across a WAN | 9 | 73 | 9 |
| Group project and command reference | | 83 | |

## Labs

Lab *N* practises Chapter *N*; every lab also assumes the Foundations chapter, which sits in the Lab 1 folder as
`Chapter-00.pdf`. Each lab's folder under
[`.all_pdfs/data-communication-networking/`](../.all_pdfs/data-communication-networking) holds its chapter and
the lab sheet. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Lecturer source |
| --- | --- | --- | --- | --- |
| 1 | [Capture, filter, and read a live conversation](../.all_pdfs/data-communication-networking/Lab-01/Lab-Activity.pdf) | Foundations, Ch. 1 | 10–12 | Lab 1 - Wireshark |
| 2 | [Build a topology and survive the VRP command line](../.all_pdfs/data-communication-networking/Lab-02/Lab-Activity.pdf) | Ch. 2 | 19–21 | Lab 2A, 2B - eNSP Introduction |
| 3 | [Static routing and the backup route](../.all_pdfs/data-communication-networking/Lab-03/Lab-Activity.pdf) | Ch. 3 | 28–30 | Lab 3 - Static Routing |
| 4 | [OSPF: let the network work it out](../.all_pdfs/data-communication-networking/Lab-04/Lab-Activity.pdf) | Ch. 4 | 36–38 | Lab 4 - Dynamic Routing |
| 5 | [FTP: a service on top of a working network](../.all_pdfs/data-communication-networking/Lab-05/Lab-Activity.pdf) | Ch. 5 | 44–46 | Lab 5 - FTP |
| 6 | [DHCP: addresses without a spreadsheet](../.all_pdfs/data-communication-networking/Lab-06/Lab-Activity.pdf) | Ch. 6 | 52–54 | Lab 6 - DHCP server |
| 7 | [Link aggregation: several cables, one link](../.all_pdfs/data-communication-networking/Lab-07/Lab-Activity.pdf) | Ch. 7 | 61–63 | Lab 7 - LACP |
| 8 | [VLANs: one switch, several networks](../.all_pdfs/data-communication-networking/Lab-08/Lab-Activity.pdf) | Ch. 8 | 70–72 | Lab 8 - VLAN Configuration |
| 9 | [WAN links: HDLC, PPP, and authentication](../.all_pdfs/data-communication-networking/Lab-09/Lab-Activity.pdf) | Ch. 9 | 80–82 | Lab 9 - WAN |
| | [Group project: integrated eNSP network](../.all_pdfs/data-communication-networking/Capstone-Project.pdf) | all | 83–84 | Group Project - Template DCN |
| | [Command quick reference](../.all_pdfs/data-communication-networking/Command-Quick-Reference.pdf) | | 85–87 | |

## Running the labs

The labs need two tools:

- **Wireshark** for Lab 1's packet captures;
- **Huawei eNSP** for Labs 2–9, which are all built and verified on simulated routers and switches. eNSP needs
  VirtualBox; Lab 2's troubleshooting box covers devices that will not start.

Each lab ends with a *Verification evidence* box: the `display` commands and captures to hand in.

## Folder map

```text
DATA COMMUNICATION & NETWORKING/
  main.tex            the book: configuration and chapter list
  chapters/           foundations, Chapters 1-9, the course map, the group project and the command reference
  labs/               9 lab sheets, each input at the end of its chapter
  figures/            topology screenshots and slide images the chapters include
  0.from_lecturer/    the lecturer's lab slides and project template
```

The network diagrams (devices, packet headers, sequence diagrams, VRP transcripts) are drawn with the shared
[network diagram library](../.shared/diagrams/network.tex).

## Building the book

From the repository root:

```bash
python .shared/build.py DCN            # rebuild the book and its lab PDFs in .all_pdfs/data-communication-networking/
python .shared/build.py DCN --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
