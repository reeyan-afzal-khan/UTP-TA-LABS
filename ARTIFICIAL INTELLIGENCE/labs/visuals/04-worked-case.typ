#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace ventilation(20, 50)])[#flow([*\1. Input / state*

T = 20: mild = 0.8, cold = hot = 0. RH = 50: comfortable = 1, dry = humid = 0.], [*\2. Operation*

low = 0; medium = min(0.8, 1) = 0.8; high = 0. Clip only the medium output triangle.], [*\3. Check*

The clipped triangle is symmetric about 50. Its centroid gives ventilation demand 50%.])]
