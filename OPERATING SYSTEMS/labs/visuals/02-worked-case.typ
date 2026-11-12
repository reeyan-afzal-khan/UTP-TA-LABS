#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace file\_info: argument, stat, output], [1\. Input / state], [One PATH argument is required: argc must equal 2, counting the executable name.], [2\. Operation], [stat(argv\[1\], &info) fills metadata. Failure prints perror and returns exit status 2.], [3\. Check], [Read st\_size, st\_ino and st\_nlink; mask st\_mode with 0777 for permissions. Success returns 0.])
