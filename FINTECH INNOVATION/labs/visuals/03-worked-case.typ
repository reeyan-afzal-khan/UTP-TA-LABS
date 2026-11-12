#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the implemented loan return convention], [1\. Input / state], [Each synthetic loan has interest\_rate, recovery\_rate and defaulted; equal principal is assumed and fee = .01.], [2\. Operation], [Non-default return is interest\_rate minus fee. Default return is recovery\_rate minus 1 minus fee.], [3\. Check], [loss is defaulted times (1 - recovery\_rate); group means summarise by grade.])
