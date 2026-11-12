#import "/.shared/typst/utp.typ": *

#courselabtrace([One fork, two return paths], [Parent], [fork returns the positive child PID], [Child], [fork returns zero; getppid identifies its parent], [Join], [waitpid collects the child exit status])
