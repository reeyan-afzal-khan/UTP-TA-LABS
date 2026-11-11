#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the actual regression benchmark])[#flow([*\1. Input / state*

train\_id fixes the split after complete-case filtering; test contains the remaining homes.], [*\2. Operation*

baseline\_pred repeats median(train\$SalePrice) for every test row; fit learns the multivariable regression.], [*\3. Check*

metrics scores both against test\$SalePrice. err = test\$SalePrice - pred feeds the diagnostics.])]
