#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Trace the OCR scoring fields])[#flow([*\1. Input / state*

Keep each filename, reference and prediction together; normalise both strings consistently.], [*\2. Operation*

add\_distances computes exact match and edit distances for each row; summarise aggregates the scored rows.], [*\3. Check*

Blank predictions remain failures. Compare baseline and preprocessed on the same labelled images.])]
