#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the actual fraud review budget])[#flow([*\1. Input / state*

anomaly\_score negates decision\_function so higher means more unusual; ranked sorts descending.], [*\2. Operation*

review\_budget is 100; take ranked.head(review\_budget) and count fraud\_label.], [*\3. Check*

found counts the frauds among those 100; prevalence is the comparison baseline.])]
