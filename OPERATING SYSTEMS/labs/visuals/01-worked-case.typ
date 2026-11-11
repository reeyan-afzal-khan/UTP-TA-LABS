#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace fork\_demo and process ownership])[#flow([*\1. Input / state*

fork returns a child PID in the parent and zero in the child; failure is a separate branch.], [*\2. Operation*

The child prints its identity; the parent retains child\_pid and waits for that specific child.], [*\3. Check*

waitpid collects the child's termination status; printed PID values vary by run.])]
