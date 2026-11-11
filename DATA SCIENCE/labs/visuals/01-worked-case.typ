#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the daily-data profile])[#flow([*\1. Input / state*

bike contains one row per day; dteday must be parsed before ordering.], [*\2. Operation*

profile records storage type, missing count and distinct values for each column.], [*\3. Check*

Use profile to choose valid summaries; the working-day comparison groups cnt by workingday.])]
