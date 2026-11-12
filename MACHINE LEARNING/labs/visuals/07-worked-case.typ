#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace the supplied CNN: one image], [1\. Input / state], [Input shape (1, 3, 32, 32). Conv2d with 16 filters, kernel 3 and padding 1 gives (1, 16, 32, 32).], [2\. Operation], [Pool to (1, 16, 16, 16); second convolution gives (1, 32, 16, 16); pool to (1, 32, 8, 8).], [3\. Check], [Flatten: 32 times 8 times 8 = 2,048. Linear layers produce 64 features, then 7 class scores.])
