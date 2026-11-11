#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace training-only sensor selection])[#flow([*\1. Input / state*

X has US00 through US23; train\_idx and test\_idx preserve the stratified split.], [*\2. Operation*

Compute mi on X.loc\[train\_idx\] and training actions; sort feature\_table and take its first four sensor names.], [*\3. Check*

selected is reused, in the same order, for tree fitting and held-out predictions.])]
