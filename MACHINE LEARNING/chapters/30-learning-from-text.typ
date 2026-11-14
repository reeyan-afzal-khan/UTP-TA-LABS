#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "30-learning-from-text")

#let text-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_text.py"

= Learning from Text <ch:text>

#chapterguide[Pipelines and leakage from #chapref(<ch:data>)\; cosine similarity from #chapref(<ch:foundations>)\; precision, recall and thresholds from #chapref(<ch:evaluation>)\; logistic regression and naive Bayes from #chapref(<ch:classification>) and #chapref(<ch:knn-nb>)\; and the SVD behind PCA from #chapref(<ch:dimred>).][turn messages into a table a model can read; say what a token, a vocabulary and a document-term matrix are; weigh words with tf-idf by hand; decide with evidence whether stop words, stemming and word pairs help; build a spam filter whose threshold protects real messages; search stored text by similarity; and explain what a word vector is, how one is learned without labels, and when it beats counting.]

Suppose you had to sort a sack of letters written in a language you cannot read. You could still do it quite well. Letters that keep using the same unusual words probably belong in the same pile, and a word that appears in every letter tells you nothing about any of them. You would be counting marks on paper without understanding one of them.

That is how a model reads. This chapter shows how far counting goes, which is further than most people expect, and where it stops. It follows two collections of short messages: 5,572 text messages labeled spam or ham (the usual name for a message that is not spam), and 13,083 questions typed to a bank's support chat. Every number comes from `all_experiments/book_checks/demo_text.py`.

== A message is not a row

Every model so far was handed a table: one row per example, one column per feature, a number in every cell. A text message has no columns. It is a string of characters of any length:

```terminal
WINNER!! As a valued network customer you have been selected to receivea £900 prize reward! To claim
call 09061701461. Claim code KL341. Valid 12 hours only.
```

Turning text into a table takes three decisions, and the rest of the chapter is about making them and measuring what each one does.

#utpsteps[
  + #term[What is one unit of text?] Splitting a message into units is called tokenizing, and each unit is a #term[token].
  + #term[Which units get a column?] The set of tokens that are kept is the #term[vocabulary].
  + #term[What number goes in each cell?] A count, a yes or no, or a weight.
]

One piece of housekeeping comes before any of that. Of the 5,572 messages, 403 repeat an earlier message word for word. A repeated message that lands on both sides of a split turns the test into a memory check (#secref(<sec:data-leakage>)), so the repeats are removed first. That leaves 5,169 different messages, 653 of them spam (12.6%). One split then sets aside 1,034 test messages and keeps 4,135 for everything else.

#block(breakable: false, width: 100%, codefrom(text-demo, "def read_messages():", "return sms, unique, split"))

Five terms recur on every page from here on:

#utptable[
  #tabularx(
    columns: (23%, 1fr, 31%),
    styles: (navy-bold,),
    header: ([Term], [Meaning], [In the text messages]),
    [Corpus], [The whole collection of texts], [5,169 different messages],
    [Document], [One text, which becomes one row], [one message],
    [Token], [One unit of a document after splitting], [`winner`, `900`, `prize`],
    [Vocabulary], [Every different token that is kept: one column each], [7,680 words],
    [Document-term matrix], [The finished table: documents down, vocabulary across], [4,135 rows and 7,680 columns],
  )
]

== Tokens

scikit-learn's `CountVectorizer` tokenizes with three default rules: turn every letter into lower case, keep each run of two or more letters or digits, and throw everything else away. Here is what those rules make of the message above:

```terminal
['winner', 'as', 'valued', 'network', 'customer', 'you', 'have', 'been', 'selected', 'to', 'receivea',
 '900', 'prize', 'reward', 'to', 'claim', 'call', '09061701461', 'claim', 'code', 'kl341', 'valid',
 '12', 'hours', 'only']
```

Compare the two versions and note what changed.

- #strong[The shouting is gone.] `WINNER!!` became `winner`. Capital letters and rows of exclamation marks are among the clearest signs of spam, and the default rules delete both.
- #strong[The pound sign is gone,] and so is the one-letter word `a`.
- #strong[A typing mistake became a word.] The sender ran two words together, and `receivea` now has a column of its own.
- #strong[The phone number is one token] that no other message will ever contain.

None of these outcomes is wrong, but each is a decision that someone else made for you. All of them can be changed, through the `lowercase` and `token_pattern` settings. The habit to keep is the one from #chapref(<ch:eda>): before modelling, print the tokens of a few real documents and read them.

== Counting: the bag of words

#block(breakable: false, width: 100%)[
  The simplest number to put in a cell is a count. Take four made-up messages:

  #utptable[
    #tabularx(
      columns: (1fr, auto, auto, auto, auto, auto, auto, auto, auto),
      align: (left, center, center, center, center, center, center, center, center),
      header: ([Message], [`are`], [`call`], [`free`], [`me`], [`now`], [`prize`], [`win`], [`you`]),
      [1. win a free prize now], [0], [0], [1], [0], [1], [1], [1], [0],
      [2. call me now], [0], [1], [0], [1], [1], [0], [0], [0],
      [3. free call free prize], [0], [1], [2], [0], [0], [1], [0], [0],
      [4. are you free now], [1], [0], [1], [0], [1], [0], [0], [1],
    )
  ]
]

The vocabulary is the eight different tokens, in alphabetical order. Each message becomes a row that says how many times each word occurs in it. This representation is called a #term[bag of words], because a bag holds things without keeping them in order. It has one property that every model in this book needs: a message of three words and a message of three hundred both become a row of the same width.

On the real training messages the table has 4,135 rows and 7,680 columns, which makes 31,756,800 cells. Only 54,735 of them, 0.17%, are not zero, because an average message has 14.3 tokens and the vocabulary has thousands. A table like that is stored as a #term[sparse matrix], which records the non-zero cells and their positions and nothing else. The vectorizers return one, and naive Bayes, logistic regression and linear SVMs all accept it directly.

#pitfall[
  Calling `.toarray()` on a document-term matrix writes out every zero. For these text messages that is 32 million numbers, which still fits in memory. For a hundred thousand documents and a vocabulary of two hundred thousand it would be twenty billion, and the notebook would stop. Keep the matrix sparse, and convert only a few rows when you want to look at them.
]

=== A few words do most of the work

#utpfig([How often each of the 7,680 words occurs in the training messages. More than half the vocabulary occurs exactly once. The 438 words that occur more than twenty times are 6% of the vocabulary and 68.5% of all the tokens.], label: <fig:word-tail>)[
  #canvas({
    axis(width: 11.5cm, height: 4.6cm, ..logaxis, xlabel: [times the word occurs in 4,135 training messages], ylabel: [words], xmin: 0.4, xmax: 5.6, ymin: 0, ymax: 4800, ybar: auto, bar-width: 30pt, xtick: (1, 2, 3, 4, 5), xticklabels: ([once], [twice], [3 to 5], [6 to 20], [over 20]), ytick: (0, 1000, 2000, 3000, 4000),
      addplot(fill: pale-blue, draw: blue, coords: ((1, 4253), (2, 1163), (3, 1011), (4, 815), (5, 438))),
      {
        node((1, 4500), [4,253], font: font("script", fill: navy))
        node((2, 1410), [1,163], font: font("script", fill: navy))
        node((3, 1258), [1,011], font: font("script", fill: navy))
        node((4, 1062), [815], font: font("script", fill: navy))
        node((5, 685), [438], font: font("script", fill: navy))
      },
    )
  })
]

The most frequent words are `you` (1,723 times), `to` (1,650), `the` (1,029) and `and` (773). At the other end, 4,253 of the 7,680 words occur once in all the training messages (#figref(<fig:word-tail>)). Both ends are poor material. A word that is everywhere cannot tell messages apart, and a word seen once offers a single example to learn from. The useful words live in between, and the next table shows a few of them.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center, center, center),
    header: ([Share of messages containing], [`call`], [`free`], [`txt`], [`claim`], [`you`], [`to`], [`my`], [`ok`]),
    [spam], [42.9%], [22.4%], [18.6%], [13.2%], [33.7%], [62.6%], [1.9%], [0.8%],
    [ham], [3.7%], [1.1%], [0.3%], [0.0%], [28.8%], [25.5%], [12.5%], [5.6%],
  )
]

`call` appears in 42.9% of the spam and 3.7% of the ham. `claim` appears in 13.2% of the spam and in none of the 3,613 real training messages. `my` and `ok` point the other way: people write them to people. `you` is nearly useless, as expected. And `to` holds a small trap. It is more than twice as common in spam, and the reason has nothing to do with the word: spam messages are longer (a median of 148 characters against 53), so every common word has more chances to occur in them. Counts mix up what a message says with how long it is. The weighting introduced below removes that.

== Trimming the vocabulary

Three ways of shrinking the vocabulary are taught so often that they can look compulsory.

/ Stop words.: A #term[stop list] is a fixed list of very common words to delete. scikit-learn's English list has 318 of them.
/ Rare words.: Setting `min_df=2` keeps only the words found in at least two documents.
/ Stemming.: A #term[stemmer] cuts endings off by rule, so that different forms of a word share one column. The Porter stemmer turns `calls`, `calling` and `called` into `call`, and `winning` and `wins` into `win`. Its rules know nothing about meaning. They leave `winner` and `won` as they are, turn `freely` into `freeli`, and merge `university` and `universe` into `univers`. #term[Lemmatization] does the same job with a dictionary instead of rules: it returns real words and can link `won` to `win`, but it is slower and needs to know each word's part of speech.

Whether any of them helps is a question for the data. Each row below is a naive Bayes filter on counts, scored by five-fold cross-validation on the training messages, using the average precision of #secref(<sec:classification-metrics>).

#utptable[
  #tabularx(
    columns: (1fr, auto, auto),
    align: (left, center, center),
    styles: (navy-bold,),
    header: ([Vocabulary], [Columns], [Average precision]),
    [Every word], [7,680], [0.955],
    [Without the stop list], [7,414], [0.965],
    [Words found in at least two messages], [3,322], [0.961],
    [Stemmed], [6,513], [0.952],
  )
]

On these messages, deleting stop words helps a little. Dropping every word that occurs in a single message removes more than half the columns and costs nothing. Stemming makes things very slightly worse.

#keyidea[
  Read that table as a result about one dataset and not as a rule. In a review that says "not good", the word `not` carries the meaning, and `not` is on the stop list. Every choice in this section is a setting of the pipeline, to be validated like any other setting (#chapref(<ch:training>)). What works for spam may hurt for sentiment.
]

== What counting throws away

Here are two sentences with opposite meanings:

#align(center)[
  _the offer is real, not a scam_ #h(2em) _the offer is a scam, not real_
]

Their bags of words are identical: the same six tokens, once each. No model, however clever, can tell apart two inputs that are the same row.

The standard repair is to count short runs of neighbouring words as well as single words. Runs of $n$ tokens are called #term[n-grams]: pairs are bigrams and triples are trigrams. The first sentence contains the pairs `is real` and `not scam`. The second contains `is scam` and `not real`. With `ngram_range=(1, 2)` the vectorizer makes a column for every single word and every pair, and the two sentences become different rows.

The price is paid in columns. On the training messages, single words need 7,680 columns, words and pairs need 42,642, and adding triples makes 87,043, nearly all of them seen once. Pairs are worth trying when short phrases carry the meaning. They are no cure for order in general: a pair cannot connect a word to something said ten words earlier. Models that read text in order are the subject of #chapref(<ch:sequence>).

== Weighing words: tf-idf

A count treats every word alike. But `you` occurs in 1,218 training messages and `prize` in 57, and a word found in a third of all messages says less about any one of them than a word found in a handful. #term[Tf-idf] turns that observation into a weight. The name joins its two factors: the term frequency, which is the count, and the inverse document frequency, which is larger for rarer words.

scikit-learn computes the second factor like this, where $n$ is the number of documents and $"df"(w)$ the number of documents that contain the word $w$:

$ "idf"(w) = ln frac(1 + n, 1 + "df"(w)) + 1. $

Each count is multiplied by the idf of its word. Then every row is divided by its own length, so that its squared values add up to 1.

#workedexample[
  Take the four made-up messages, so $n = 4$.

  `free` is in three of them: $"idf" = ln(5 \/ 4) + 1 = 1.223$. `call` and `prize` are in two: $ln(5 \/ 3) + 1 = 1.511$. `win` is in one: $ln(5 \/ 2) + 1 = 1.916$.

  Message 3 is "free call free prize". Its counts are 1, 2 and 1 for `call`, `free` and `prize`. Multiplied by the idf, they become 1.511, 2.446 and 1.511. The length of that row is $sqrt(1.511^2 + 2.446^2 + 1.511^2) = 3.248$, and dividing by it gives the final row:

  #align(center)[`call` 0.465 #h(1.5em) `free` 0.753 #h(1.5em) `prize` 0.465]

  The repeated word still weighs the most, but less than its count of 2 alone would give it, because it is also the most common word of the four messages.
]

On the real training messages the same formula gives these weights:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    header: ([Word], [`you`], [`call`], [`free`], [`claim`], [`prize`], [`lunch`]),
    [Training messages that contain it], [1,218], [358], [158], [69], [57], [29],
    [idf], [2.22], [3.44], [4.26], [5.08], [5.27], [5.93],
  )
]

Two things about tf-idf are easy to miss.

- #strong[The idf has never seen a label.] `lunch` gets a larger weight than `prize` for the plain reason that it is rarer. Whether a word points to spam is for the classifier to learn. The idf only decides how loudly each word speaks.
- #strong[Dividing each row by its length removes the length of the message.] A long message and a short one about the same thing point in the same direction. It also means that the sum of the products of two rows is exactly their cosine similarity (#figref(<fig:cosine>)), which a later section uses for search.

A common variant, `sublinear_tf=True`, replaces a count $c$ by $1 + ln c$, on the grounds that a word used ten times is not ten times as important as a word used once.

== A spam filter, measured honestly

The rules of the earlier chapters apply to text without change, and text makes each of them a little sharper.

/ The vectorizer is a fitted step.: Its vocabulary and its idf values are learned from documents. It therefore belongs inside the pipeline, where each fold of a cross-validation fits it on that fold's training messages only (#secref(<sec:preprocessing-pipeline>)).
/ Accuracy is the wrong score.: Answering "ham" every time is right for 87.4% of the training messages (#secref(<sec:baselines>)). Precision, recall and average precision say what the filter does with the spam.
/ The two mistakes do not cost the same.: Spam in the inbox is a nuisance. A real message in the spam folder may be a missed appointment.

#codefrom(text-demo, "def cross_validated(vectorizer, model, text, y):", "return cross_val_predict(")

Four filters, each cross-validated on the 4,135 training messages and read at a threshold of 0.5:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Filter], [Precision], [Recall], [Average \ precision], [Real messages \ flagged], [Spam \ missed]),
    [Naive Bayes on counts], [0.969], [0.902], [0.955], [15], [51],
    [Logistic on tf-idf, `C = 1`], [0.992], [0.738], [0.966], [3], [137],
    [Logistic on tf-idf, `C = 10`], [0.980], [0.862], [0.973], [9], [72],
    [Logistic on character pieces, `C = 10`], [0.996], [0.895], [0.985], [2], [55],
  )
]

"Logistic" stands for logistic regression. The training messages hold 3,613 real messages and 522 spam.

- #strong[Naive Bayes is hard to beat for its size.] It counts words in each class and multiplies (#secref(<sec:naive-bayes>)), trains in a fraction of a second, and catches 90% of the spam.
- #strong[The default penalty is too strong here.] With `C = 1` the logistic regression misses 137 spam messages. With thousands of columns and a few non-zero cells per row, the default penalty holds the weights too close to zero. Loosening it to `C = 10` halves the misses. `C` is a setting to tune (#secref(<sec:hyperparameter-tuning>)).
- #strong[Ranking and threshold are separate questions.] The logistic regression has the better average precision, 0.973 against 0.955: it puts spam above ham more reliably. At the 0.5 threshold it nevertheless catches less spam than naive Bayes. The threshold is a decision for later in this section.
- #strong[The last row wins on every count,] and it does not use words at all.

=== Characters instead of words

The fourth filter cuts each word into overlapping pieces of two to five characters, with a space marking the start and the end of the word. The three letters of `txt` become ten pieces: `_t`, `tx`, `xt`, `t_`, `_tx`, `txt`, `xt_`, `_txt`, `txt_` and `_txt_`, writing the space as an underscore. The setting is `analyzer="char_wb"` with `ngram_range=(2, 5)`, and on these messages it makes 69,650 columns.

Pieces help because of how spam is written. Its senders shorten words, run them together and fill messages with codes and prices, so many of its words are new every time. In the test messages, 7.7% of the tokens are words that never occurred in training, and 50.6% of the messages contain at least one such word. A word vectorizer drops an unknown word in silence: there is no error and no warning, and the model simply reads less of the message. An unknown word still shares most of its pieces with words that are known.

The cost is readability. A list of the most important words can be shown to anyone. A list of the most important three-letter pieces cannot.

=== What did the model learn?

For the word-based logistic regression, the largest weights can be read directly:

```terminal
words that push hardest towards spam: ['txt', 'text', 'reply', 'call', 'uk', 'chat', 'stop', 'www']
words that push hardest towards ham:  ['my', 'me', 'gt', 'can', 'lt', 'that']
```

The spam list is what anyone would expect. The ham list contains two strangers, `gt` and `lt`. They are what the tokenizer leaves of `&gt;` and `&lt;`, the codes that web pages use for the signs > and <. In this collection, numbers in some ham messages were replaced by a placeholder, as in the message `Wait  &lt;#&gt;  min..`, and 179 real training messages contain it against no spam message at all.

#pitfall[
  The model is right to use that pattern on this dataset, and it would be wrong on a real phone, where nobody's messages contain `&lt;`. The pattern describes how the data was collected. Reading the largest weights is the cheapest check for text: a strange token near the top usually means that something other than the task separates the classes.
]

=== The vectorizer and the folds

How much does it matter if the vectorizer is fitted on all the training messages before the cross-validation, instead of inside each fold?

```terminal
vectorizer fitted outside the folds: average precision 0.9696; inside the pipeline: 0.9732
```

Here, very little, and the shortcut did not even flatter the model. A vectorizer never sees a label, so it has little to leak. The rule stays anyway, for two reasons. The estimate should describe the system that will run, and that system will meet words it has never seen. And the next step people add is usually a supervised one, such as keeping the 500 words most strongly linked to the label. Done outside the folds, that step is the leak that made pure noise look like signal in #secref(<sec:data-leakage>). A pipeline makes both mistakes impossible.

=== Choosing the threshold

Suppose the product rule is that at most one real message in a thousand may go to the spam folder. The threshold that meets it can be read off the cross-validated probabilities: sort the real messages by their spam probability, allow the permitted number to be flagged, and put the threshold just above the next one.

#codefrom(text-demo, "def strict_threshold(y, prob, allowed=0.001):", "return float(ham[budget])")

For the character filter this gives a threshold of 0.37, which is below 0.5. At 0.5 the filter flagged 2 of the 3,613 real training messages. The rule allows 3, so the threshold can come down, and recall rises from 0.895 to 0.921.

Then the test messages are opened, once:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto),
    align: (left, center, center),
    styles: (navy-bold,),
    header: ([1,034 test messages, threshold 0.37], [Sent to the inbox], [Sent to the spam folder]),
    [903 real messages], [900], [3],
    [131 spam messages], [9], [122],
  )
]

The filter catches 122 of the 131 spam messages, a recall of 0.931, with a precision of 0.976. One of the nine that got through begins "In The Simpsons Movie released in July 2007 name the band that died at the start of the film?", which reads like a quiz from a friend.

Now look at the top row. The rule said one real message in a thousand, and the test found 3 in 903. That is not a contradiction. The threshold was fixed by the three most spam-like real messages among 3,613, and a rate estimated from three events is very uncertain (#chapref(<ch:foundations>)). A promise about one message in a thousand needs tens of thousands of real messages behind it. Until you have them, state the rate together with the count it rests on.

== Many classes: 77 kinds of question

The second collection is harder. Each of 13,083 questions to a bank's support chat belongs to one of 77 #term[intents], such as `card_arrival`, `change_pin` or `transfer_not_received_by_recipient`. Guessing is right 1.3% of the time. The collection comes with its own split: 10,003 questions to train on and 3,080 to test on.

The pipeline is the same one: tf-idf on single words, 2,320 of them, and a logistic regression with `C = 10`.

```terminal
logistic regression on tf-idf: test accuracy 0.9, right intent among its top three 0.97;
naive Bayes on counts 0.796; guessing 0.013
```

Nine questions in ten are sent to the right one of 77 intents by a model that only weighs words. With many classes, one accuracy figure hides most of the story, and two more views are worth the few lines they take.

#strong[Recall for each class.] Nine of the 77 intents have every one of their 40 test questions right. The three weakest:

#utptable[
  #tabularx(
    columns: (1fr, auto),
    align: (left, center),
    header: ([Intent], [Recall]),
    [`virtual_card_not_working`], [0.68],
    [`fiat_currency_support`], [0.75],
    [`pending_transfer`], [0.75],
  )
]

#strong[The pairs that get confused.] Three pairs are mixed up five times each:

#utptable[
  #tabularx(
    columns: (1fr, 1fr),
    header: ([The question was about], [The model answered]),
    [`virtual_card_not_working`], [`get_disposable_virtual_card`],
    [`verify_my_identity`], [`why_verify_identity`],
    [`balance_not_updated_after_bank_transfer`], [`transfer_not_received_by_recipient`],
  )
]

In each pair the two intents share nearly all their words, and a person might hesitate too.

The second number in the output suggests a design. The right intent is among the model's three most likely in 97% of the test questions. A support screen that offers three suggestions is right far more often than one that offers a single answer, and the model is the same.

== Search by similarity

A document-term matrix is also a search index. Because every tf-idf row has length 1, multiplying the matrix by the row of a new question gives the cosine similarity between that question and every stored one.

#codefrom(text-demo, "def nearest_messages(query, vectorizer, weights, texts, k=3):", "return [(round(float(similarity[i]), 2)")

For the question "how do I change my pin", the three nearest stored questions all have the intent `change_pin`, with similarities of 0.96, 0.94 and 0.86. A second question goes less well:

```terminal
query: my new card still has not arrived
    0.73  transfer_not_received_by_recipient   My transfer has not arrived.
    0.66  card_arrival                         Why has my new card still not come?
    0.62  transfer_not_received_by_recipient   Why has my transfer not arrived yet?
```

The nearest stored question is about a transfer. It shares `my`, `has`, `not` and `arrived` with the query. The question that asks the same thing comes second: it shares `my`, `new`, `card`, `still` and `not`, but it says `come` where the query says `arrived`. To a bag of words, `come` and `arrived` are two columns with nothing in common. The last part of this chapter is about that limit.

== From counting to meaning

=== Words as points

In a document-term matrix every word is a column of its own, and every column is as far from every other as it could be. `declined` is no closer to `rejected` than to `lunch`. The alternative is to give each word a short row of numbers of its own, a #term[word vector] or #term[embedding], chosen so that words used in the same way lie close together. A vocabulary of thousands then lives in a space of perhaps a hundred dimensions, and the distance between two words means something.

Nobody writes those numbers by hand. They are learned from one observation: #emph[words that can stand in for each other turn up among the same neighbours].

#utpfig([The neighbours of one word. With a window of two, the words within two positions of `declined` count as its company. Slide the window along every question in the collection and add up who appears beside whom.], label: <fig:context-window>)[
  #canvas({
    let chip = (..utpstep, min-width: 1.5, min-height: 0.7, font: font("script", fill: navy))
    let near = (..chip, fill: pale-teal, draw: teal)
    let centre = (..chip, fill: pale-orange, draw: orange, font: font("script", weight: "bold", fill: navy))
    node((0, 0), [my], ..chip)
    node((1.75, 0), [card], name: "l2", ..near)
    node((3.5, 0), [was], name: "l1", ..near)
    node((5.25, 0), [declined], name: "c", ..centre)
    node((7, 0), [at], name: "r1", ..near)
    node((8.75, 0), [the], name: "r2", ..near)
    node((10.5, 0), [shop], ..chip)
    node((5.25, 0.8), [the word], font: font("script", fill: orange))
    node((2.62, -0.8), [two words before], font: font("script", fill: teal))
    node((7.88, -0.8), [two words after], font: font("script", fill: teal))
  })
]

=== Vectors from counts of company

The recipe needs three steps and no labels.

#utpsteps[
  + #term[Count the company.] For every pair of words, count how often one occurs within four positions of the other, over all 10,003 training questions (#figref(<fig:context-window>)).
  + #term[Compare with chance.] `the` is near everything, so raw counts mostly measure how common a word is. Replace each count by how many times more often the pair occurs than it would if the two words were scattered independently, take the logarithm, and keep the pairs for which it is positive. This quantity is called positive pointwise mutual information.
  + #term[Compress.] The result is a table of 1,210 words by 1,210 words. An SVD, the tool behind PCA in #chapref(<ch:dimred>), squeezes each row to 100 numbers. Those 100 numbers are the word's vector.
]

#codefrom(text-demo, "def word_vectors(documents, window=4, size=100, min_count=3):", "return vocabulary, position, vectors")

The nearest neighbours of six words, by cosine similarity:

```terminal
pin       ['locked', 'blocked', 'entered', 'tries', 'unblock']
stolen    ['phone', 'lost', 'stole', 'smart', 'bag']
fee       ['extra', 'charged', 'charge', 'when', 'there']
declined  ['rejected', 'getting', 'keeps', 'today', 'declining']
cash      ['atm', 'withdrawal', 'amount', 'some', 'less']
atm       ['cash', 'machine', 'at', 'withdraw', 'the']
```

Nobody told the program that `declined` and `rejected` mean the same, that `stolen` goes with `lost` and `stole`, or that a `fee` is something `charged`. It found all of that in 10,003 questions by counting neighbours.

The lists also show what the method does not do. The neighbours of `pin` are `locked`, `blocked` and `tries`: words from the same situation, and none of them a synonym. Company measures what goes together as well as what means the same. And with so little text, a few filler words such as `the`, `when` and `there` get in.

=== Learning the vectors by prediction

The best-known method, #term[word2vec], reaches the same kind of vectors by another road. In place of counting and compressing, it trains a very small neural network on a guessing game played over an enormous text. In one version of the game the network sees the words around a gap and has to predict the word in the gap. In the other it sees one word and has to predict its neighbours. The vectors start as random numbers and are adjusted by gradient descent (#chapref(<ch:deep>)), and since words with the same neighbours need the same predictions, they end up with similar vectors.

What matters in practice is that such vectors have been trained on billions of words and can be downloaded. A model built on them starts with knowledge about the language that no small labeled dataset could supply.

=== A message as an average

A message can now be given a vector too: the average of the vectors of its words. Every question becomes 100 numbers, whatever its length. This is still a bag, and the order of the words is lost exactly as before. What changes is that `come` and `arrived` no longer have to match letter for letter.

Run the search that went wrong again, comparing these averages in place of the tf-idf rows, and then try a question whose main words are not the bank's own:

```terminal
query, by word vectors: my new card still has not arrived
    0.96  card_arrival      Why has my new card still not come?
    0.93  card_arrival      My card still hasn't been delivered
    0.93  card_arrival      My card hasn't arrived.
query, by word vectors: the cash machine swallowed my card
    0.95  card_swallowed    The ATM machine ate my card.
    0.92  card_swallowed    My card is stuck inside the ATM.
    0.92  card_swallowed    The ATM took my card.
```

All three answers to the first question are now about a card that has not come, and the transfer is gone. For the second question the best match says `ATM` for `cash machine` and `ate` for `swallowed`. The tf-idf search can only match words letter for letter, and its best answer to that question was "How do I get a new card as your machine swallowed mine!", at a similarity of 0.61. For search, where the user's words and the stored words differ, the dense vectors are a clear gain.

Do they classify better too? On the full training set, no.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto),
    align: (left, center, center),
    styles: (navy-bold,),
    header: ([Each question represented as], [Numbers per question], [Test accuracy]),
    [tf-idf weights, sparse], [2,320], [0.900],
    [tf-idf compressed by an SVD], [300], [0.871],
    [tf-idf compressed by an SVD], [100], [0.814],
    [The average of its word vectors], [100], [0.840],
  )
]

Seventy-seven fine-grained intents are told apart by exact words such as `virtual`, `disposable` and `pending`, and an average blurs exactly those. With about 130 labeled questions for each intent, the classifier can learn what every individual word is worth, and the sparse columns win.

Take most of the labels away, and the order changes.

#utpfig([Test accuracy on the 77 intents as the number of labeled questions grows. With two labels for each intent, averaged word vectors lead in all ten random draws of the labels. From five labels on, the sparse tf-idf columns lead, and the gap widens. The points for 2, 5 and 10 labels are means over ten draws.], label: <fig:few-labels>)[
  #canvas({
    axis(width: 11.5cm, height: 5.2cm, ..logaxis, xlabel: [labeled questions for each intent], ylabel: [test accuracy], xmin: 0.6, xmax: 4.4, ymin: 0.35, ymax: 0.95, xtick: (1, 2, 3, 4), xticklabels: ([2], [5], [10], [all, about 130]), ytick: (0.4, 0.5, 0.6, 0.7, 0.8, 0.9),
      addplot(draw: blue, mark: "*", mark-size: 1.9pt, line-width: widths.thick, coords: ((1, 0.413), (2, 0.595), (3, 0.706), (4, 0.900))),
      addplot(draw: orange, mark: "*", mark-size: 1.9pt, line-width: widths.thick, coords: ((1, 0.443), (2, 0.586), (3, 0.679), (4, 0.840))),
      {
        node((3.9, 0.925), [tf-idf], font: font("script", fill: blue), anchor: "east")
        node((4.3, 0.64), [averaged word vectors], font: font("script", fill: orange), anchor: "east")
        node((1.0, 0.475), [0.443], font: font("tiny", fill: orange))
        node((1.0, 0.383), [0.413], font: font("tiny", fill: blue))
      },
    )
  })
]

With two examples of an intent, a classifier on sparse columns knows only the words that happen to occur in those two questions. The word vectors were placed using all 10,003 questions, with no labels, so a classifier built on them can do something with a word it has never seen labeled, as long as that word lies near one it has. This is the trade of #chapref(<ch:semi-supervised>) again: unlabeled data is worth the most when labels are fewest (#figref(<fig:few-labels>)). It is also why language models are now trained first on vast amounts of unlabeled text and only afterwards shown a task, as #chapref(<ch:sequence>) describes.

== Choosing a representation

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr, 1.25fr),
    styles: (navy-bold,),
    header: ([Representation], [Keeps], [Loses], [Reach for it when]),
    [Word counts], [Which words occur, and how often], [Order, meaning, and how informative each word is], [You want a naive Bayes baseline within minutes],
    [Tf-idf], [The same, with rare words weighted up and the length of the text removed], [Order and meaning], [Always, first: for classification and search with linear models],
    [Tf-idf with word pairs], [Short phrases such as "not good"], [Longer-range order, and compactness: several times the columns], [Negation or fixed phrases carry the meaning],
    [Character pieces], [Spelling, codes, prices, misspellings], [Readable features], [The text is noisy, deliberately disguised, or mixes languages],
    [Averaged word vectors], [Which words resemble which], [Order, and the identity of exact words], [You search by meaning, labels are few, or the vectors come pretrained from a large text],
    [Models that read in order (#chapref(<ch:sequence>))], [Order and context], [Speed, simplicity and small-data safety], [Meaning depends on order: long documents, translation, questions and answers],
  )
]

A routine that fits most text problems:

#utpsteps[
  + #term[Read before you count.] Print twenty documents and their tokens. Look for repeats, placeholders and anything the tokenizer destroys.
  + #term[Build the plain baseline.] Remove repeats, split, and put tf-idf and a linear model in one pipeline. This is the number that everything else has to beat.
  + #term[Validate the preprocessing.] Stop words, stemming, pairs and character pieces are settings. Try them inside cross-validation and keep what helps.
  + #term[Read the largest weights.] A strange token at the top is a finding about the data.
  + #term[Set the threshold from the costs,] and report the rate together with the count it rests on.
  + #term[Only then try something heavier,] on the same split, and ask whether the gain pays for what it costs to run and to explain.
]

#tryit[
  In `demo_text.py`, set `CHECK_BOOK_NUMBERS = False`. Then change the rule in `strict_threshold` from one real message in a thousand to one in a hundred, by calling it with `allowed=0.01`, and run the script. How far does the threshold fall? How many more spam messages are caught in the test, and how many more real messages are lost? Which of the two rules would you choose for a phone, and which for a company's support inbox?
]

#block(breakable: false, width: 100%, chapterrecap[
  - Text becomes a table through three decisions: what a token is, which tokens get a column, and what number goes in each cell. Print the tokens of real documents before trusting the defaults.
  - A bag of words gives every document a row of the same width. The table is almost entirely zeros (0.17% of cells were filled), so it is stored sparse. More than half the vocabulary occurred once.
  - Stop words, rare words and stemming are settings to validate. On the text messages they moved the average precision between 0.952 and 0.965.
  - Counting loses order: two opposite sentences had the same bag. Word pairs repair short phrases, at several times the columns.
  - Tf-idf multiplies each count by a weight that is larger for rarer words, and scales each row to length 1, which removes the length of the text and makes a dot product a cosine similarity.
  - The vectorizer is a fitted step and belongs in the pipeline. Choose the threshold from the costs, and remember that a rate resting on three messages is uncertain.
  - The largest weights are worth reading: `gt` and `lt` showed that the model had learned how the data was collected.
  - A word vector places words used alike close together, and can be learned without labels. Averaged word vectors repaired a search that tf-idf got wrong. For classification they lost to tf-idf with all the labels (0.840 against 0.900) and won with two labels for each intent (0.443 against 0.413).
])

#quickcheck[
  + Define corpus, document, token and vocabulary, using a collection of customer reviews as the example.
  + A document-term matrix has 20,000 rows and 50,000 columns, and an average document has 40 different words. What share of its cells is not zero, and why does that matter for memory?
  + Three documents: "red apple", "green apple", "red red car". Compute the idf of `red`, `apple` and `car` with scikit-learn's formula, and then the tf-idf row of the third document before it is scaled.
  + Give one task in which removing stop words is likely to hurt, and say which word shows it.
  + Two messages have the same bag of words and opposite meanings. Name the change to the vectorizer that separates them, and what it costs.
  + Half of the test messages contained a word never seen in training. What does a word vectorizer do with such a word, and why are character pieces less affected?
  + A filter is tuned to flag at most one real message in a thousand, on 3,613 real messages. On the test it flags 3 of 903. Explain why this is not surprising.
  + The word `gt` has one of the largest weights in a spam filter. What do you check, and what might you conclude?
  + With all the labels, tf-idf beat averaged word vectors. With two labels for each class, it lost. Explain both results.
]
