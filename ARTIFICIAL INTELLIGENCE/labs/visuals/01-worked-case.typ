#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Verify an airline path independently])[#flow([*\1. Input / state*

Split the saved path into airport codes; edge\_km maps each source to its neighbours and distances.], [*\2. Operation*

For every adjacent pair a, b, confirm b is in edge\_km\[a\], then add edge\_km\[a\]\[b\].], [*\3. Check*

Compare the sum with path\_cost\_km; len(path) - 1 is the hop count.])]
