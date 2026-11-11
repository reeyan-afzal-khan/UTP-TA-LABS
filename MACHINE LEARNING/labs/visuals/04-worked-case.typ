#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the actual customer segmentation])[#flow([*\1. Input / state*

Log and scale recency, orders and spend to form X, one row per customer.], [*\2. Operation*

KMeans uses four clusters and 20 starts; DBSCAN uses eps 0.5 and min\_samples 10.], [*\3. Check*

k\_labels assign K-means groups; d\_labels uses -1 for noise. The profile reports medians in the original units.])]
