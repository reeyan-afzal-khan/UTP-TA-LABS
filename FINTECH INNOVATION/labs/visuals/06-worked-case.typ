#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the exact tampering demonstration])[#flow([*\1. Input / state*

The initial four-block chain passes validate(chain, difficulty) with difficulty 2.], [*\2. Operation*

Change chain\[2\]'s transaction to bob-\>mallory 1000 without updating later stored links.], [*\3. Check*

Validation must report a broken previous-hash link at block 3; the assertion checks that failure.])]
