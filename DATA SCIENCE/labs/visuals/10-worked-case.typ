#import "/.shared/typst/utp.typ": *

#courselabtrace([Trace PCA on the supplied wine measurements], [1\. Input / state], [178 samples and 13 measurements. Exclude sample\_id and cultivar, then centre and standardise.], [2\. Operation], [explained = sdev squared / sum(sdev squared). PC1: 36.20%; PC2: 19.21%.], [3\. Check], [Two PCs retain 55.41%. Five PCs retain 80.16%, first exceeding the script threshold of 80%.])
