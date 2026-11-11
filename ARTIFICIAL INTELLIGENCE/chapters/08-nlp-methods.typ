#import "/.shared/typst/utp.typ": *
#unit("chapters", "08-nlp-methods")


#heading(level: 1)[NLP Methods: Text Classification Done Honestly]
 <ch:nlp-methods>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know the NLP pipeline of #ref(label("ch:nlp-foundations"), supplement: [Chapter]), basic probability, and what precision, recall and F1 measure.

*By the end, you can:* turn tweets into a bag-of-words matrix; explain how Multinomial Naive Bayes scores a class and why smoothing is needed; choose metrics for imbalanced classes; run a leakage-safe train/validation/test protocol; and read a confusion matrix, a per-group table and an error sample as evidence.]

Lab~7 classifies airline tweets as negative, neutral or positive using Multinomial Naive Bayes on word counts. The model is deliberately simple, because the focus here is the evaluation protocol: prepare text without leakage, tune on validation data, report metrics that respect imbalance, and inspect the errors. The same protocol applies to much larger models.


#heading(level: 2)[From text to numbers]


A classifier needs numbers, and a tweet is a string. The simplest bridge is a #strong[bag of words]: represent each document by how many times each vocabulary term occurs in it, and throw away the word order.

#callout("analogy", title: [Analogy])[Tip a tweet's words into a bag and shake it. You can still count them, and "cancelled" appearing three times tells you a good deal about the mood. You can no longer tell "not good, very bad" from "not bad, very good". That lost order is the price of this representation, and it is why this chapter ends by asking what to try next.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/b016c0ccb3866850.cetz.json")], caption: [One tweet through Lab~7's preprocessing. Placeholders stand in for the handle and the link, and then the tokeniser and the stop-word list do their work. "Again" is on scikit-learn's English stop list, so it disappears, as do "not", "no" and "never" in other tweets.]) <fig:preprocess>

Lab~7's `clean` function replaces URLs and handles with the placeholders `URL` and `USER` and then lowercases everything, so they become the single features `url` and `user` rather than thousands of one-off terms. `CountVectorizer` then tokenises, removes English stop words, requires a term to occur in at least two training tweets, and caps the vocabulary at 20,000.


#heading(level: 3)[N-grams]


#strong[Bigrams] add pairs of adjacent tokens as extra features, which brings back a little of the lost word order. Pairs such as `hold hours`, `great flight` and `best airline` turn up among the most class-specific features in Lab~7. Features grow from 4,671 to 11,850, and the matrix becomes sparser, so let validation performance decide whether they help.


#heading(level: 2)[Multinomial Naive Bayes]


Naive Bayes chooses the class $c$ that makes the document $d$ most probable: $ hat(c) = "argmax"_c #h(0em) P \( c \) product_(w in d) P \( w divides c \)^(n_w) \, $ where $n_w$ counts term $w$ in the document, $P \( c \)$ is the class's share of the training set, and $P \( w divides c \)$ is how often term $w$ appears among that class's words. The "naive" part is the assumption that terms are independent once the class is known. That is plainly false for language, and the model works usefully anyway.

#callout("intuition", title: [Conceptual intuition])[Think of every word as a witness giving evidence. "Delayed" testifies strongly for negative, "thanks" testifies for positive, and "flight" says about the same to everyone, so it barely matters. Naive Bayes multiplies the testimony together, starting from how common each class is, and the largest product wins.]

#ref(label("fig:naive-bayes"), supplement: [Figure]) scores two short tweets with the probabilities the fitted Lab~7 model actually learned. Notice the second tweet. Positive tweets are only 16 % of the data, so the model starts sceptical, but "great" and "thanks" are strong enough evidence to overturn that.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/d7ce7438997cbe8e.cetz.json")], caption: [Two short messages scored with single-word probabilities from the fitted Lab~7 model. Each class starts from its share of the training set and multiplies in one probability per word. "Flight" contributes much the same to every class; the other words do the deciding. The largest score in each row is the prediction.]) <fig:naive-bayes>


#heading(level: 3)[Smoothing]


What if a word never occurred in any training tweet of some class? Its probability is zero, and one zero wipes out the whole product, however strongly the other words point that way. One unfamiliar witness silences everyone. #strong[Laplace smoothing] prevents this by adding a small pseudo-count $alpha$ to every term, as if each word had been seen a tiny number of times in every class: $ P \( w divides c \) = frac(upright("count") \( w \, c \) + alpha, sum_(w') upright("count") \( w' \, c \) + alpha thin \| V \|) . $ Small $alpha$ trusts the observed counts, and large $alpha$ moves the probabilities towards uniform. Multiplying many small numbers also underflows a computer's floating point, so real implementations add logarithms instead. Lab~7 selects $alpha = 0.3$ from ${ 0.3 \, 0.5 \, 1 \, 2 }$ on validation data, and n-grams turn out to matter more than smoothing here.


#heading(level: 2)[Metrics for imbalanced classes]


Tweets are 63 % negative, 21 % neutral and 16 % positive. A model that always says "negative" scores 63 % accuracy while being completely useless, so accuracy cannot be the headline. Report per-class metrics as well:

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Metric], [Definition], [Answers],),
    table.hline(),
    [Precision], [Of the tweets predicted as class $c$, the fraction that are $c$], [When the model says positive, how often is it right?],
    [Recall], [Of the tweets that are $c$, the fraction predicted as $c$], [How many of the positive tweets did it find?],
    [F1], [Harmonic mean of precision and recall], [One number per class that punishes neglecting either],
  )]
  , kind: table
  )

#ref(label("fig:nb-confusion"), supplement: [Figure]) shows where these come from on the real test set. #strong[Macro F1] is the plain average of the three class F1 scores, so each class counts equally however rare it is. The majority baseline has recall~1 for negative and~0 otherwise, giving macro F1 $0.26$; Naive Bayes reaches $0.70$.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/2da23cc74ce0910a.cetz.json")], caption: [Lab~7's test results on 2,143 tweets. For #emph[neutral]: recall reads along its row, $239 \/ 447 = 0.53$, and precision reads down its column, $239 \/ 400 = 0.60$. Their harmonic mean is F1 $= 0.56$. The largest off-diagonal cell, 158, is neutral tweets called negative.]) <fig:nb-confusion>

#callout("pitfall", title: [Common mistake])[Compute the majority baseline first. Accuracy rises from 63 % to 77 %, which sounds modest, while macro F1 rises from $0.26$ to $0.70$. Together they show what the model adds.]


#heading(level: 2)[A leakage-safe protocol]


#strong[Leakage] occurs when test information influences training or model selection. It is the examination equivalent of seeing the final paper in advance: the score goes up and tells you nothing about what you can do on a new paper. Lab~7 controls leakage at each stage (#ref(label("fig:protocol"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ARTIFICIAL INTELLIGENCE/figures/diagrams/1e64b983df8b9b1f.cetz.json")], caption: [Deduplicate before splitting, fit vocabulary and model on training data, select settings on validation data, and evaluate once on test data.]) <fig:protocol>

/ Duplicates before the split.: #block[
There are 213 exact duplicates and 355 duplicates after URL and mention replacement. Keep one copy of each normalised text before splitting, or a retweet in the training set could hand the model the answer to its twin in the test set.
]

/ Stratified, seeded, saved.: #block[
Preserve class proportions in a seeded 70/15/15 split and save the assignment for audit.
]

/ Vocabulary from training text only.: #block[
Fit `CountVectorizer` on training tweets, then transform validation and test tweets. Words seen only in the test set stay unknown, exactly as they would for a deployed model.
]

/ Selection on validation, one look at test.: #block[
Compare eight settings on validation data, refit the winner, then evaluate once on test data.
]

#callout("keyidea", title: [Key idea])[Deduplicate, split, fit, tune, test. Respecting these boundaries keeps the final score separate from model development.]


#heading(level: 2)[Reading the evidence]


The lab produces four kinds of evidence, each answering a question the headline score cannot.

/ The confusion matrix.: #block[
Neutral tweets are often predicted as negative, because questions about delays share vocabulary with complaints.
]

/ Per-class scores.: #block[
Negative F1 $0.86$, positive $0.67$, neutral $0.56$. Neutral is the hardest class, with few distinctive words of its own. Its most class-specific features are one-off news topics such as `wall street` and `journal`, which say little about any future tweet.
]

/ Per-group scores.: #block[
Airline macro F1 ranges from $0.66$ to $0.78$, with 63--594 test tweets per airline. Different sample sizes, class mixes and topics make this a diagnostic, not an airline ranking.
]

/ An error sample.: #block[
Tag the four most confident mistakes per true class, twelve tweets in all. The reproducible sample reveals missed negation, low-sentiment questions, short texts and a repeatedly retweeted joke with inconsistent labels. The last is a data-quality issue, not just a model error.
]

#callout("pitfall", title: [Common mistake])[Every sampled error has posterior above $0.999$. Being confident and wrong is the most damaging kind of mistake, and Naive Bayes does it often because its independence assumption multiplies correlated evidence as if it were new each time. Use these scores for ranking, not as reliable probabilities of being right.]


#heading(level: 2)[What the protocol does not fix]


Bag-of-words Naive Bayes struggles with negation, sarcasm and word order, and one choice in this pipeline makes that worse. The English stop list removes `not`, `no` and `never`, so "not good" and "good" look identical. Keeping stop words raises validation macro F1 from $0.697$ to $0.720$ with the same model. That is a real finding, and it came from questioning a default rather than from a more complicated model. The deliverable asks what representation to try next: weighted counts, embeddings or contextual models. Whatever you try, keep the deduplicated split, validation-based selection and single final test evaluation unchanged.

#callout("chapterrecap", title: [Chapter recap])[- A bag of words counts terms and discards order; bigrams recover a little of it.

- Naive Bayes multiplies a class's share by one probability per word, and smoothing stops one unseen word from zeroing a class.

- On imbalanced classes, compare macro F1 against a majority baseline and read the confusion matrix.

- Deduplicate, split, fit on train, tune on validation and test once. Anything else leaks.

- Confidence is not correctness, and defaults such as the stop list deserve testing too.]

#callout("quickcheck", title: [Check your understanding])[+ Why are URLs and `@handles` replaced by placeholder tokens rather than deleted or kept?

+ A term appears 0 times in the positive training tweets. What happens to a tweet containing it under Naive Bayes without smoothing, and with $alpha = 1$?

+ The majority baseline scores 63 % accuracy and 0.26 macro F1. Explain both numbers from the class shares alone.

+ Which step would leak if the vectoriser were fitted on all 14,285 tweets, and what would the symptom be?

+ Virgin America has the highest per-airline macro F1 and only 63 test tweets. Why does the lab warn against reading this as an airline ranking?]
