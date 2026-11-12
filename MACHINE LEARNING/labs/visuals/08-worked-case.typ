#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the actual 24-step forecasting window], [1\. Input / state], [LOOKBACK = 24. First input: scaled\[0:24\], containing indices 0 through 23.], [2\. Operation], [First target: scaled\[24\]. Second input: scaled\[1:25\]; its target is scaled\[25\].], [3\. Check], [N observations produce N - 24 windows. unsqueeze(-1) gives shape (rows, 24, 1).])
