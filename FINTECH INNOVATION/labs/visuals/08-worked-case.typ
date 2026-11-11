#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the synthetic daily risk calculation])[#flow([*\1. Input / state*

px has 366 daily prices; log(px / px.shift(1)).dropna() yields 365 returns.], [*\2. Operation*

annualised uses sample standard deviation times sqrt(365); drawdowns divides prices by the running maximum.], [*\3. Check*

worst is each column's minimum drawdown; recovery = 1 / (1 + worst) - 1.])]
