#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the supplied outlier flag], [1\. Input / state], [q stores charge quartiles; iqr is IQR(d\$charges).], [2\. Operation], [upper\_fence = q\[3\] + 1.5 times iqr; flagged keeps rows above that boundary.], [3\. Check], [Inspect flagged records; the script does not remove them before subgroup comparisons.])
