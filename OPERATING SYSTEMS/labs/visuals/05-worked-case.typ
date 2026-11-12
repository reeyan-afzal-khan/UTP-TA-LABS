#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the descriptors in pipe\_demo], [1\. Input / state], [pipe\_fd\[0\] is the read end; pipe\_fd\[1\] is the write end. Both are inherited after fork.], [2\. Operation], [Child closes the write end and reads; parent closes the read end, writes the message including its terminator, then closes.], [3\. Check], [Child prints the returned byte count and message; parent waits for completion.])
