#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [One fork, two return paths])[#flow([*Parent*

fork returns the positive child PID], [*Child*

fork returns zero; getppid identifies its parent], [*Join*

waitpid collects the child exit status])]
