#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the actual search-engineering fixture], [1\. Input / state], [toy has S to A cost 2, S to B cost 5, A to G cost 5, and B to G cost 1.], [2\. Operation], [Routes S-A-G and S-B-G both have two hops; their costs are 7 and 6.], [3\. Check], [UCS selects cost 6. With the supplied consistent h, A-star must also return cost 6.])
