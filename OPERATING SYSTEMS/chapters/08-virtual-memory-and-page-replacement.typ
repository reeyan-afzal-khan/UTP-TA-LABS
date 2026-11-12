#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-virtual-memory-and-page-replacement")

= Virtual Memory and Page Replacement <ch:vm>

#chapterguide[Chapter 7: physical-memory placement and fragmentation.][translate page/frame terminology, identify hits and page faults, and justify FIFO, LRU, and LFU replacement decisions in Lab 8.]

== Why virtual memory changes the problem

Paging divides virtual memory into fixed-size #term[pages] and physical memory into equal-size #term[frames]. A page table records which frame currently contains each resident virtual page. Because pages need not occupy adjacent frames, paging removes external fragmentation from physical allocation, though the last page of an object can still create internal fragmentation.

== Address translation

Divide the virtual address by the page size. The quotient is the page number;
the remainder is the offset. The page table replaces the page number with a
frame number, while the offset stays unchanged. In compact form:
#mono[physical address = frame $times$ page size + offset].

#utpfig([Translating virtual address 9000 with 4096-byte pages: page 2, offset 808. The page table maps page 2 to frame 5, so the physical address is $5 times 4096+808=21 thin 288$.], label: <fig:address-translation>)[
  #align(center)[

  #canvas({
    let cell = (draw: blue, fill: pale-blue, min-width: 1.6, min-height: 0.7, font: font("small", fill: navy), align: center)
    let off = (draw: orange, fill: pale-orange, min-width: 1.6, min-height: 0.7, font: font("small", fill: navy), align: center)
    let pte = (draw: teal, fill: pale-teal, min-width: 1.2, min-height: 0.58, font: font("script", fill: navy))
    let lab = (font: font("script", fill: muted), align: center)
    let ar = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.2mm, line: widths.thick))
    node((0, 3.5), [#strong[Virtual address] \
   $v = 9 thin 000$,  $P = 4 thin 096$], ..lab)
    node((4.9, 4), [#strong[Page table]], ..lab)
    node((9.6, 3.5), [#strong[Physical address]], ..lab)
    node((4.9, 3.2), [0 $arrow.r$ 7], name: "p0", ..pte)
    node((4.9, 2.6), [1 $arrow.r$ 3], name: "p1", ..pte)
    node((4.9, 2), [2 $arrow.r$ 5], name: "p2", ..pte, draw: red, fill: pale-red, line-width: widths.very-thick)
    node((4.9, 1.4), [3 $arrow.r$ 1], name: "p3", ..pte)
    node((0, 2), [page 2], name: "vp", ..cell)
    node((0, 0.5), [offset 808], name: "vo", ..off)
    node((9.6, 2), [frame 5], name: "pf", ..cell)
    node((9.6, 0.5), [offset 808], name: "po", ..off)
    node((0, -0.35), [$floor.l 9000\/4096 floor.r = 2$ \
   $9000 mod 4096 = 808$], ..lab)
    node((9.6, -0.35), [$5 times 4096 + 808$ \
   $= 21 thin 288$], ..lab)
    connect("vp.east", "p2.west", ..ar)
    node(along("vp.east", "p2.west", t: 50%), [look up], ..lab, anchor: "south")
    connect("p2.east", "pf.west", ..ar)
    node(along("p2.east", "pf.west", t: 50%), [gives frame], ..lab, anchor: "south")
    connect("vo.east", "po.west", ..ar, draw: orange)
    node(along("vo.east", "po.west", t: 50%), [copied unchanged --- it never enters the page table], ..lab, anchor: "south")
  })

  #v(3pt)
  #fsize("script")[Only the #emph[page number] is translated. The offset passes through
  untouched, which is why the page size fixes how many bits each part uses --- and
  why page size is always a power of two.]
  ]
]

#keyidea[
  Translation replaces the page number and copies the offset. If a virtual address is contiguous inside one page, its physical address is contiguous too; across a page boundary it need not be, because the next page may live in any frame.
]

== Page faults

A #term[page fault] occurs when a referenced virtual page is not currently resident in a usable physical frame. The OS must locate the page on backing storage (or otherwise materialize it), obtain a frame, update mapping metadata, and restart/resume the faulting instruction as appropriate.

== Replacement policies

When no free frame exists, the OS needs a victim page.

#utptable[
  #tabularx(
    columns: (12%, 44%, 1fr),
    styles: (navy-bold,),
    header: ([Policy], [Victim rule], [State required]),
    [FIFO], [Page resident for the longest time], [Arrival/load order],
    [LRU], [Page whose most recent use is farthest in the past], [Recency information],
    [LFU], [Page with the smallest reference count], [Frequency counts plus a tie-breaker],
  )
]

== FIFO

FIFO treats loaded pages like a queue. It is easy to implement but does not use actual access behavior. FIFO can exhibit #term[Belady’s anomaly]: for some reference strings, adding more frames can increase the number of faults.

== LRU

LRU approximates the principle of temporal locality: a page used recently is likely to be used again soon. Exact LRU can be expensive, so real systems often use hardware-assisted approximations.

== LFU

LFU retains frequently referenced pages. Pure cumulative counts can preserve stale historical popularity, so practical frequency-based schemes often age counts or use bounded windows.

#workedexample[
  With three frames and reference string 1, 2, 3, 1, 4: the first three references fault and fill the frames. The second reference to 1 is a hit. On reference 4, FIFO evicts 1 if 1 was loaded earliest, whereas LRU evicts 2 because 2 is the least recently used at that moment.
]

== Locality explains why replacement policies can work

Programs often reuse recently accessed instructions and data (temporal locality) and access addresses close to one another (spatial locality). Page-replacement policies try to exploit these patterns indirectly. LRU uses recent history; LFU uses frequency history; FIFO deliberately ignores reference history and uses load order only.

#keyidea[
  A page-replacement algorithm is a prediction policy: it tries to choose a resident page whose removal will hurt future execution as little as possible. The policy never knows the future perfectly, so the workload matters.
]

== How to trace replacement professionally

A trustworthy trace shows the reference, frame contents after the reference, hit/fault result, and enough policy state to justify a victim. Totals are useful only after individual decisions can be checked.

#quickcheck[
  + Which part of a virtual address remains unchanged during page-table translation?
  + What is the difference between a page hit and a page fault?
  + Why can LRU and LFU choose different victims even on the same reference string?
]
