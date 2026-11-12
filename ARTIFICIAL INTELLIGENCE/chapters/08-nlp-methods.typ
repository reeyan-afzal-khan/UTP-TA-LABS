#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-nlp-methods")

= NLP Methods: Text Classification Done Honestly <ch:nlp-methods>

#chapterguide[Know the NLP pipeline of #chapref(<ch:nlp-foundations>), basic probability, and what precision, recall and F1 measure.][turn tweets into a bag-of-words matrix; explain how Multinomial Naive Bayes scores a class and why smoothing is needed; choose metrics for imbalanced classes; run a leakage-safe train/validation/test protocol; and read a confusion matrix, a per-group table and an error sample as evidence.]

Lab~7 classifies airline tweets as negative, neutral or positive using Multinomial Naive Bayes on word counts. The model is deliberately simple, because the focus here is the evaluation protocol: prepare text without leakage, tune on validation data, report metrics that respect imbalance, and inspect the errors. The same protocol applies to much larger models.

== From text to numbers

A classifier needs numbers, and a tweet is a string. The simplest bridge is a #term[bag of words]: represent each document by how many times each vocabulary term occurs in it, and throw away the word order.

#analogy[
  Tip a tweet’s words into a bag and shake it. You can still count them, and “cancelled” appearing three times tells you a good deal about the mood. You can no longer tell “not good, very bad” from “not bad, very good”. That lost order is the price of this representation, and it is why this chapter ends by asking what to try next.
]

#utpfig([One tweet through Lab~7’s preprocessing. Placeholders stand in for the handle and the link, and then the tokeniser and the stop-word list do their work. “Again” is on scikit-learn’s English stop list, so it disappears, as do “not”, “no” and “never” in other tweets.], label: <fig:preprocess>)[
  #canvas({
    let stage = (..utpbox, text-width: 2.7, min-height: 1.05, font: font("script", fill: navy, family: "mono"))
    let stagelabel = (..utplabel, anchor: "north", align: center, text-width: 2.7)
    node((0, 0), [\@united Flight \
  cancelled AGAIN! \
  http:/\/t.co/x], name: "raw", ..stage)
    node(right-of("raw", 0.6), [user flight \
  cancelled again! \
  url], name: "normalized", ..stage)
    node(right-of("normalized", 0.6), [user flight \
  cancelled url], name: "filtered", ..stage)
    node(right-of("filtered", 0.6), [cancelled:1 flight:1 \
  url:1 user:1], name: "counts", ..stage, fill: pale-teal, draw: green)
    connect("raw.east", "normalized.west", ..utparrow)
    connect("normalized.east", "filtered.west", ..utparrow)
    connect("filtered.east", "counts.west", ..utparrow)
    node((rel: (0, -0.2), to: "raw.south"), [Raw tweet], ..stagelabel)
    node((rel: (0, -0.2), to: "normalized.south"), [Replace handles and \
  URLs, lowercase], ..stagelabel)
    node((rel: (0, -0.2), to: "filtered.south"), [Tokenise, drop \
  stop words], ..stagelabel)
    node((rel: (0, -0.2), to: "counts.south"), [Count terms \
  (the bag of words)], ..stagelabel)
  })
]

Lab~7’s `clean` function replaces URLs and handles with the placeholders `URL` and `USER` and then lowercases everything, so they become the single features `url` and `user` rather than thousands of one-off terms. `CountVectorizer` then tokenises, removes English stop words, requires a term to occur in at least two training tweets, and caps the vocabulary at 20,000.

=== N-grams

#term[Bigrams] add pairs of adjacent tokens as extra features, which brings back a little of the lost word order. Pairs such as `hold hours`, `great flight` and `best airline` turn up among the most class-specific features in Lab~7. Features grow from 4,671 to 11,850, and the matrix becomes sparser, so let validation performance decide whether they help.

== Multinomial Naive Bayes

Naive Bayes chooses the class $c$ that makes the document $d$ most probable:

$ hat(c)=op("arg max", limits: #true)_c med P(c) product _(w in d)P(w divides c)^(n_w), $

where $n_w$ counts term $w$ in the document, $P(c)$ is the class’s share of the training set, and $P(w divides c)$ is how often term $w$ appears among that class’s words. The “naive” part is the assumption that terms are independent once the class is known. That is plainly false for language, and the model works usefully anyway.

#intuition[
  Think of every word as a witness giving evidence. “Delayed” testifies strongly for negative, “thanks” testifies for positive, and “flight” says about the same to everyone, so it barely matters. Naive Bayes multiplies the testimony together, starting from how common each class is, and the largest product wins.
]

#figref(<fig:naive-bayes>) scores two short tweets with the probabilities the fitted Lab~7 model actually learned. Notice the second tweet. Positive tweets are only 16 % of the data, so the model starts sceptical, but “great” and “thanks” are strong enough evidence to overturn that.

#utpfig([Two short messages scored with single-word probabilities from the fitted Lab~7 model. Each class starts from its share of the training set and multiplies in one probability per word. “Flight” contributes much the same to every class; the other words do the deciding. The largest score in each row is the prediction.], label: <fig:naive-bayes>)[
  #canvas({
    let head = (..utpcell, min-width: 1.3, min-height: 0.55, font: font("script", weight: "bold", fill: navy))
    let val(arg) = (min-width: 1.3, min-height: 0.5, draw: mix(arg, 55%), fill: mix(arg, 10%), font: font("script", fill: navy), inner-sep: 0pt)
    let cl = (..utplabel, anchor: "east", font: font("script", weight: "bold"))
    let score = (..utplabel, anchor: "west", font: font("script", fill: navy))
    let tw = 1.4
    node((-0.95, 1.75), [#strong[tweet 1]], font: font("small"), ..utplabel, anchor: "east", text: navy)
    for (hh, i) in (("share", 0), ("flight", 1), ("delayed", 2), ("hold", 3)) {
      node((tw * i, 1.75), [#hh], font: font("small"), ..head)
    }
    for (vv, i) in ((0.635, 0), (0.0235, 1), (0.0039, 2), (0.0048, 3)) {
      node((tw * i, 1.15), [#vv], font: font("small"), ..val(red))
    }
    for (vv, i) in ((0.209, 0), (0.0175, 1), (0.0007, 2), (0.0007, 3)) {
      node((tw * i, 0.6), [#vv], font: font("small"), ..val(muted))
    }
    for (vv, i) in ((0.156, 0), (0.0129, 1), (0.0006, 2), (0.0002, 3)) {
      node((tw * i, 0.05), [#vv], font: font("small"), ..val(green))
    }
    node((-0.75, 1.15), [negative], font: font("small"), ..cl, text: red)
    node((-0.75, 0.6), [neutral], font: font("small"), ..cl, text: muted)
    node((-0.75, 0.05), [positive], font: font("small"), ..cl, text: green)
    node((5, 1.15), [$=2.8 times 10^(-7)$#h(1em)#strong[predicted: negative]], font: font("small"), ..score)
    node((5, 0.6), [$=1.6 times 10^(-9)$], font: font("small"), ..score)
    node((5, 0.05), [$=2.7 times 10^(-10)$], font: font("small"), ..score)
    draw.scope({
      draw.translate((0, -2.75))
      node((-0.95, 1.75), [#strong[tweet 2]], font: font("small"), ..utplabel, anchor: "east", text: navy)
      for (hh, i) in (("share", 0), ("great", 1), ("flight", 2), ("thanks", 3)) {
        node((tw * i, 1.75), [#hh], font: font("small"), ..head)
      }
      for (vv, i) in ((0.635, 0), (0.0007, 1), (0.0235, 2), (0.0026, 3)) {
        node((tw * i, 1.15), [#vv], font: font("small"), ..val(red))
      }
      for (vv, i) in ((0.209, 0), (0.0005, 1), (0.0175, 2), (0.0041, 3)) {
        node((tw * i, 0.6), [#vv], font: font("small"), ..val(muted))
      }
      for (vv, i) in ((0.156, 0), (0.0084, 1), (0.0129, 2), (0.0203, 3)) {
        node((tw * i, 0.05), [#vv], font: font("small"), ..val(green))
      }
      node((-0.75, 1.15), [negative], font: font("small"), ..cl, text: red)
      node((-0.75, 0.6), [neutral], font: font("small"), ..cl, text: muted)
      node((-0.75, 0.05), [positive], font: font("small"), ..cl, text: green)
      node((5, 1.15), [$=2.6 times 10^(-8)$], font: font("small"), ..score)
      node((5, 0.6), [$=7.0 times 10^(-9)$], font: font("small"), ..score)
      node((5, 0.05), [$=3.4 times 10^(-7)$#h(1em)#strong[predicted: positive]], font: font("small"), ..score)
    })
  })
]

=== Smoothing

What if a word never occurred in any training tweet of some class? Its probability is zero, and one zero wipes out the whole product, however strongly the other words point that way. One unfamiliar witness silences everyone. #term[Laplace smoothing] prevents this by adding a small pseudo-count $alpha$ to every term, as if each word had been seen a tiny number of times in every class:

$ P(w divides c)=frac("count"(w,c)+ alpha, sum _(w')"count"(w',c)+ alpha thin |V|). $

Small $alpha$ trusts the observed counts, and large $alpha$ moves the probabilities towards uniform. Multiplying many small numbers also underflows a computer’s floating point, so real implementations add logarithms instead. Lab~7 selects $alpha =0.3$ from ${ 0.3,0.5,1,2 }$ on validation data, and n-grams turn out to matter more than smoothing here.

== Metrics for imbalanced classes

Tweets are 63 % negative, 21 % neutral and 16 % positive. A model that always says “negative” scores 63 % accuracy while being completely useless, so accuracy cannot be the headline. Report per-class metrics as well:

#utptable[
  #tabularx(
    columns: (16%, 36%, 1fr),
    styles: (navy-bold,),
    header: ([Metric], [Definition], [Answers]),
    [Precision], [Of the tweets predicted as class $c$, the fraction that are $c$], [When the model says positive, how often is it right?],
    [Recall], [Of the tweets that are $c$, the fraction predicted as $c$], [How many of the positive tweets did it find?],
    [F1], [Harmonic mean of precision and recall], [One number per class that punishes neglecting either],
  )
]

#figref(<fig:nb-confusion>) shows where these come from on the real test set. #term[Macro F1] is the plain average of the three class F1 scores, so each class counts equally however rare it is. The majority baseline has recall~1 for negative and~0 otherwise, giving macro F1 $0.26$; Naive Bayes reaches $0.70$.

#utpfig([Lab~7’s test results on 2,143 tweets. For #emph[neutral]: recall reads along its row, $239\/447=0.53$, and precision reads down its column, $239\/400=0.60$. Their harmonic mean is F1 $=0.56$. The largest off-diagonal cell, 158, is neutral tweets called negative.], label: <fig:nb-confusion>)[
  #canvas({
    let hit = (draw: green, fill: mix(green, 28%), min-width: 1.75, min-height: 0.74, font: font("small", weight: "bold", fill: navy))
    let miss = (draw: mix(muted, 30%), fill: white, min-width: 1.75, min-height: 0.74, font: font("small", fill: muted))
    let bad = (draw: orange, fill: pale-orange, min-width: 1.75, min-height: 0.74, font: font("small", weight: "bold", fill: navy))
    let cw = 1.8
    let ch = 0.78
    for (i, name) in ("negative", "neutral", "positive").enumerate() {
      node((cw * i, 0.42), [predicted \
  #name], font: font("script", fill: navy), anchor: "south", align: center)
    }
    for (i, name) in ("negative", "neutral", "positive").enumerate() {
      node((-1, -ch * i), [true #name], font: font("script", fill: navy), anchor: "east")
    }
    node((0, 0), [1185], font: font("small"), ..hit)
    node((cw, 0), [115], font: font("small"), ..miss)
    node((2 * cw, 0), [61], font: font("small"), ..miss)
    node((0, -ch), [158], font: font("small"), ..bad)
    node((cw, -ch), [239], font: font("small"), ..hit)
    node((2 * cw, -ch), [50], font: font("small"), ..miss)
    node((0, -2 * ch), [63], font: font("small"), ..miss)
    node((cw, -2 * ch), [46], font: font("small"), ..miss)
    node((2 * cw, -2 * ch), [226], font: font("small"), ..hit)
    node((2 * cw + 1.3, -ch), [#strong[Per-class F1] \ #v(1.9925pt)
   negative $0.86$ \
   neutral $0.56$ \
   positive $0.67$ \ #v(2.9888pt)
   macro F1 $=(0.86+0.56+0.67)\/3=0.70$], anchor: "west", align: left, text-width: 5.2, font: font("script", fill: navy))
  })
]

#pitfall[
  Compute the majority baseline first. Accuracy rises from 63 % to 77 %, which sounds modest, while macro F1 rises from $0.26$ to $0.70$. Together they show what the model adds.
]

== A leakage-safe protocol

#term[Leakage] occurs when test information influences training or model selection. It is the examination equivalent of seeing the final paper in advance: the score goes up and tells you nothing about what you can do on a new paper. Lab~7 controls leakage at each stage (#figref(<fig:protocol>)).

#utpfig([Deduplicate before splitting, fit vocabulary and model on training data, select settings on validation data, and evaluate once on test data.], label: <fig:protocol>)[
  #canvas({
    let s = (..utpbox, min-width: 2.6, min-height: 1, font: font("script", fill: navy), align: center)
    node((0, 0), [#strong[1\. Deduplicate] \
  exact and normalised \
  copies removed], name: "dedup", font: font("small"), ..s)
    node(right-of("dedup", 0.45), [#strong[2\. Split 70/15/15] \
  stratified, seed 42 \
  saved to split.csv], name: "split", font: font("small"), ..s)
    node(right-of("split", 0.45), [#strong[3\. Fit on train] \
  vocabulary and \
  Naive Bayes], name: "fit", font: font("small"), ..s, fill: pale-orange, draw: orange)
    node(right-of("fit", 0.45), [#strong[4\. Tune on validation] \
  n-grams and $alpha$ \
  by macro F1], name: "tune", font: font("small"), ..s, fill: pale-orange, draw: orange)
    node(right-of("tune", 0.45), [#strong[5\. Test once] \
  metrics, confusion \
  matrix, errors], name: "test", font: font("small"), ..s, fill: pale-teal, draw: green)
    for (a, b) in (("dedup", "split"), ("split", "fit"), ("fit", "tune"), ("tune", "test")) {
      connect(a, b, ..utparrow)
    }
    node((7.05, -0.75), [sees training and validation rows only], font: font("small"), ..utplabel, anchor: "north", text: orange)
    node((11.9, -0.75), [sees test rows: once], font: font("small"), ..utplabel, anchor: "north", text: green)
  })
]

/ Duplicates before the split.: There are 213 exact duplicates and 355 duplicates after URL and mention replacement. Keep one copy of each normalised text before splitting, or a retweet in the training set could hand the model the answer to its twin in the test set.
/ Stratified, seeded, saved.: Preserve class proportions in a seeded 70/15/15 split and save the assignment for audit.
/ Vocabulary from training text only.: Fit `CountVectorizer` on training tweets, then transform validation and test tweets. Words seen only in the test set stay unknown, exactly as they would for a deployed model.
/ Selection on validation, one look at test.: Compare eight settings on validation data, refit the winner, then evaluate once on test data.

#keyidea[
  Deduplicate, split, fit, tune, test. Respecting these boundaries keeps the final score separate from model development.
]

== Reading the evidence

The lab produces four kinds of evidence, each answering a question the headline score cannot.

/ The confusion matrix.: Neutral tweets are often predicted as negative, because questions about delays share vocabulary with complaints.
/ Per-class scores.: Negative F1 $0.86$, positive $0.67$, neutral $0.56$. Neutral is the hardest class, with few distinctive words of its own. Its most class-specific features are one-off news topics such as `wall street` and `journal`, which say little about any future tweet.
/ Per-group scores.: Airline macro F1 ranges from $0.66$ to $0.78$, with 63--594 test tweets per airline. Different sample sizes, class mixes and topics make this a diagnostic, not an airline ranking.
/ An error sample.: Tag the four most confident mistakes per true class, twelve tweets in all. The reproducible sample reveals missed negation, low-sentiment questions, short texts and a repeatedly retweeted joke with inconsistent labels. The last is a data-quality issue, not just a model error.

#pitfall[
  Every sampled error has posterior above $0.999$. Being confident and wrong is the most damaging kind of mistake, and Naive Bayes does it often because its independence assumption multiplies correlated evidence as if it were new each time. Use these scores for ranking, not as reliable probabilities of being right.
]

== What the protocol does not fix

Bag-of-words Naive Bayes struggles with negation, sarcasm and word order, and one choice in this pipeline makes that worse. The English stop list removes `not`, `no` and `never`, so “not good” and “good” look identical. Keeping stop words raises validation macro F1 from $0.697$ to $0.720$ with the same model. That is a real finding, and it came from questioning a default rather than from a more complicated model. The deliverable asks what representation to try next: weighted counts, embeddings or contextual models. Whatever you try, keep the deduplicated split, validation-based selection and single final test evaluation unchanged.

#chapterrecap[
  - A bag of words counts terms and discards order; bigrams recover a little of it.
  - Naive Bayes multiplies a class’s share by one probability per word, and smoothing stops one unseen word from zeroing a class.
  - On imbalanced classes, compare macro F1 against a majority baseline and read the confusion matrix.
  - Deduplicate, split, fit on train, tune on validation and test once. Anything else leaks.
  - Confidence is not correctness, and defaults such as the stop list deserve testing too.
]

#quickcheck[
  + Why are URLs and `@handles` replaced by placeholder tokens rather than deleted or kept?
  + A term appears 0 times in the positive training tweets. What happens to a tweet containing it under Naive Bayes without smoothing, and with $alpha =1$?
  + The majority baseline scores 63 % accuracy and 0.26 macro F1. Explain both numbers from the class shares alone.
  + Which step would leak if the vectoriser were fitted on all 14,285 tweets, and what would the symptom be?
  + Virgin America has the highest per-airline macro F1 and only 63 test tweets. Why does the lab warn against reading this as an airline ranking?
]
