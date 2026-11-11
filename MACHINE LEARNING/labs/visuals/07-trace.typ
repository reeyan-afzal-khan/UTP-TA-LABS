#import "/.shared/typst/utp.typ": *

#callout("labvisual", title: [Follow one minibatch])[#flow([*Forward*

Images become logits for each class], [*Backward*

Cross-entropy gradients update training weights], [*Evaluate*

Disable gradient recording; report held-out accuracy])]
