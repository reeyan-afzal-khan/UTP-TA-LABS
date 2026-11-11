#import "/.shared/typst/utp.typ": *
#unit("chapters", "07-contiguous-memory-allocation")


#heading(level: 1)[Contiguous Memory Allocation]
<ch:allocation> #callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Basic arithmetic and the idea that a process needs memory while it runs.

*By the end, you can:* trace free holes and requests, distinguish internal from external fragmentation, and compare First Fit, Best Fit, and Worst Fit in Lab 7.]


#heading(level: 2)[The allocation problem]
 In a simple contiguous-allocation model, each request must be placed into one sufficiently large free region, often called a #strong[hole]. If a 120-byte request is placed into a 500-byte hole, the remaining 380 bytes become a smaller free hole.

This model is deliberately simpler than modern virtual memory, but it is useful because it makes fragmentation and online allocation decisions visible.


#heading(level: 2)[Internal and external fragmentation]
 #strong[Internal fragmentation] is unused space inside an allocated region. #strong[External fragmentation] is free memory split into separate holes such that a large request cannot fit even when the total free space is sufficient.

#callout("workedexample", title: [Worked example])[Suppose the free holes are 70, 40, and 60. Total free memory is 170, but a request for 100 cannot be placed because the largest individual hole is only 70. That is external fragmentation.]


#heading(level: 2)[First fit]
 First fit scans from the beginning and chooses the first hole large enough for the request. Its main appeal is simple search behaviour: it can stop as soon as a usable hole is found.


#heading(level: 2)[Best fit]
 Best fit chooses the smallest hole that can satisfy the current request. This minimizes the immediate remainder, but a very small remainder may be difficult to use later.


#heading(level: 2)[Worst fit]
 Worst fit chooses the largest available hole, leaving a large remainder. This can preserve medium-size holes but may also consume the largest flexible region too aggressively.

#callout("keyidea", title: [Key idea])[All three algorithms make an #emph[online] decision. They choose using the requests seen so far; they do not know the complete future workload.]


#heading(level: 2)[One worked comparison]
 For holes 120, 500, and 250 with a request of 200:

- first fit chooses 500 because 120 is too small and 500 is the first sufficient hole;

- best fit chooses 250 because it is the smallest sufficient hole;

- worst fit chooses 500 because it is the largest hole.

The policies already create different future hole lists after only one request.


#heading(level: 2)[Freeing memory and coalescing holes]
 Real allocators must also handle deallocation. If two free holes become physically adjacent, the allocator may #strong[coalesce] them into one larger hole.

For example, imagine allocated block A lies between two free regions of 100 and 80. If A is later freed and has size 50, all three adjacent regions can potentially become one 230-unit hole. Without coalescing, the allocator would see several smaller pieces instead.


#heading(level: 2)[Compaction is conceptually different]
 Coalescing combines only free regions that are already adjacent. #strong[Compaction] moves allocated regions so scattered free space becomes contiguous. Moving live memory is expensive and requires address-management support, which is one reason paging becomes attractive in later chapters.


#heading(level: 2)[How to compare placement policies fairly]
 Keep the initial holes and request order identical. Record after every request:

- selected hole;

- hole size before allocation;

- request size;

- remainder;

- complete free-hole list.

Useful summary measures include total free memory, the largest remaining hole, number of holes, and whether a request failed.

#callout("pitfall", title: [Common mistake])[A result from one request sequence is evidence about that workload, not proof that one policy is universally superior.]


#heading(level: 2)[What the Lab 7 simulator leaves out]
 The lab intentionally ignores many details of production allocators: metadata overhead, alignment, multiple free lists, coalescing strategies, page-based allocation, and concurrency. Its purpose is to make the placement decision itself easy to see.

#callout("quickcheck", title: [Check your understanding])[+ Can total free memory be greater than a request and still fail? Why?

+ How is coalescing different from compaction?

+ Why does "best fit" not mean "best final result"?]
