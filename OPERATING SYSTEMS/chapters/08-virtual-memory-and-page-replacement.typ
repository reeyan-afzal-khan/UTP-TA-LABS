#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-virtual-memory-and-page-replacement")


#heading(level: 1)[Virtual Memory and Page Replacement]
<ch:vm> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Chapter 7: physical-memory placement and fragmentation.

*By the end, you can:* translate page/frame terminology, identify hits and page faults, and justify FIFO, LRU, and LFU replacement decisions in Lab 8.]


#heading(level: 2)[Why virtual memory changes the problem]
 Paging divides virtual memory into fixed-size #strong[pages] and physical memory into equal-size #strong[frames]. A page table records which frame currently contains each resident virtual page. Because pages need not occupy adjacent frames, paging removes external fragmentation from physical allocation, though the last page of an object can still create internal fragmentation.


#heading(level: 2)[Address translation]
 Divide the virtual address by the page size. The quotient is the page number; the remainder is the offset. The page table replaces the page number with a frame number, while the offset stays unchanged. In compact form: `physical address = frame `$times$` page size + offset`.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/OPERATING SYSTEMS/figures/diagrams/1f8a2f86733bb5d7.cetz.json")

Only the #emph[page number] is translated. The offset passes through untouched, which is why the page size fixes how many bits each part uses --- and why page size is always a power of two.], caption: [Translating virtual address 9000 with 4096-byte pages: page 2, offset 808. The page table maps page 2 to frame 5, so the physical address is $5 times 4096 + 808 = 21 thin 288$.]) <fig:address-translation>

#callout("keyidea", title: [Key idea])[Translation replaces the page number and copies the offset. If a virtual address is contiguous inside one page, its physical address is contiguous too; across a page boundary it need not be, because the next page may live in any frame.]


#heading(level: 2)[Page faults]
 A #strong[page fault] occurs when a referenced virtual page is not currently resident in a usable physical frame. The OS must locate the page on backing storage (or otherwise materialize it), obtain a frame, update mapping metadata, and restart/resume the faulting instruction as appropriate.


#heading(level: 2)[Replacement policies]
 When no free frame exists, the OS needs a victim page.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Policy], [Victim rule], [State required],),
    table.hline(),
    [FIFO], [Page resident for the longest time], [Arrival/load order],
    [LRU], [Page whose most recent use is farthest in the past], [Recency information],
    [LFU], [Page with the smallest reference count], [Frequency counts plus a tie-breaker],
  )]
  , kind: table
  )


#heading(level: 2)[FIFO]
 FIFO treats loaded pages like a queue. It is easy to implement but does not use actual access behavior. FIFO can exhibit #strong[Belady's anomaly]: for some reference strings, adding more frames can increase the number of faults.


#heading(level: 2)[LRU]
 LRU approximates the principle of temporal locality: a page used recently is likely to be used again soon. Exact LRU can be expensive, so real systems often use hardware-assisted approximations.


#heading(level: 2)[LFU]
 LFU retains frequently referenced pages. Pure cumulative counts can preserve stale historical popularity, so practical frequency-based schemes often age counts or use bounded windows.

#callout("workedexample", title: [Worked example])[With three frames and reference string 1, 2, 3, 1, 4: the first three references fault and fill the frames. The second reference to 1 is a hit. On reference 4, FIFO evicts 1 if 1 was loaded earliest, whereas LRU evicts 2 because 2 is the least recently used at that moment.]


#heading(level: 2)[Locality explains why replacement policies can work]
 Programs often reuse recently accessed instructions and data (temporal locality) and access addresses close to one another (spatial locality). Page-replacement policies try to exploit these patterns indirectly. LRU uses recent history; LFU uses frequency history; FIFO deliberately ignores reference history and uses load order only.

#callout("keyidea", title: [Key idea])[A page-replacement algorithm is a prediction policy: it tries to choose a resident page whose removal will hurt future execution as little as possible. The policy never knows the future perfectly, so the workload matters.]


#heading(level: 2)[How to trace replacement professionally]
 A trustworthy trace shows the reference, frame contents after the reference, hit/fault result, and enough policy state to justify a victim. Totals are useful only after individual decisions can be checked.

#callout("quickcheck", title: [Check your understanding])[+ Which part of a virtual address remains unchanged during page-table translation?

+ What is the difference between a page hit and a page fault?

+ Why can LRU and LFU choose different victims even on the same reference string?]
