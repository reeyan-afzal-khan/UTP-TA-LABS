#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the supplied bootstrap and permutation])[#flow([*\1. Input / state*

yes and no contain G3 for the two higher-education-aspiration groups; observed is their mean difference.], [*\2. Operation*

With B = 5000, bootstrap resamples each group; permutation shuffles group labels.], [*\3. Check*

ci uses bootstrap quantiles .025 and .975; p\_value compares absolute permuted differences with abs(observed).])]
