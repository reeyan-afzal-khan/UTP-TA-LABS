#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace preprocessing inside a validation fold])[#flow([*\1. Input / state*

K = 5. fold selects the current validation subset and its complementary training rows.], [*\2. Operation*

Estimate the scaling statistics on fold-training rows, then reuse them for validation.], [*\3. Check*

Collect results at thresholds .10, .25 and .50; aggregate across the same folds.])]
