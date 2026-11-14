#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "23-recommender-systems")

#let rec-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_recommenders.py"
#let yes = text(fill: orange, weight: "bold")[✓]

= Recommender Systems <ch:recommenders>

#chapterguide[Cosine similarity from #chapref(<ch:foundations>)\; nearest neighbours from #chapref(<ch:knn-nb>)\; the SVD behind PCA from #chapref(<ch:dimred>)\; splits that imitate the future from #secref(<sec:data-splits>)\; and the shop’s sales, cleaned in Lab~4.][explain why recommending is ranking; build a customer-product matrix from raw sales; test recommenders on what customers bought next; build five of them and read what each learned; choose their settings on a separate window; serve new customers and new products; and judge a list by its variety as well as its accuracy.]

A shop window has room for a few things. The gift shop of Lab~4 sold 4,619 different products to 5,852 customers in two years, and a page of its website has room for perhaps ten. Which ten should each customer see? Showing everyone the same best sellers is easy, and this chapter measures that it is already far better than chance. Showing each customer the ten products they are most likely to want next is the job of a #term[recommender system]. Most online shops, streaming services and news sites run one.

Lab~4 grouped these customers into segments. This chapter asks a sharper question about each one of them: what should they be shown next? It builds five recommenders on the shop’s sales, tests them on what customers bought in the last months of 2011, and then looks at what none of them can do on its own: serve a customer or a product it has never seen. Every number comes from `all_experiments/book_checks/demo_recommenders.py`, which runs in about half a minute.

== Recommending is ranking

A classifier answers one question for each row: spam or not, will this customer leave or not. A recommender answers a question of a different shape: out of 4,403 products, which ten should come first for this customer? Three things follow from that shape.

- #strong[The output is a list for each customer, and only its top is seen.] A product ranked eleventh is as good as hidden, so a recommender is judged on its first few places, not on all of them.
- #strong[Nobody labels the answer.] There is no column saying which products a customer would like, only a record of what each customer did.
- #strong[It sits between the two halves of this book.] It learns from unlabeled behaviour, like clustering and PCA, and it is tested on what customers did next, like a supervised model.

The record of what people did comes in two kinds:

#describe-nextline(1.35in)[
  / Explicit feedback: A judgement given on purpose: stars, a thumbs up, a review. There is little of it, because most people never rate anything, and an empty cell means "not rated yet".
  / Implicit feedback: A trace of behaviour: a purchase, a click, a song played, the time spent on a page. There is plenty of it, and an empty cell means "not bought", which mixes "would not want it" with "never saw it".
]

The shop’s data is implicit. It records who bought what, and never who disliked what.

#keyidea[
  An empty cell in a purchase matrix is not a no. Most empty cells are products the customer never saw. A recommender therefore learns from what was bought, ranks everything else, and is judged on what the customer buys next.
]

== From sales to a matrix

Lab~4’s rules remove the lines with no customer, the cancellations, the lines with a quantity or a price that is not positive, and exact repeats, which leaves 779,425 lines. Recommending needs one more rule. Real products have codes that begin with five digits. The other 12 codes cover 2,848 lines, almost all of them postage, carriage, discounts, bank charges, manual adjustments and test entries. Recommending postage to a customer would be accurate and useless, so those lines go. What remains is 5,852 customers, 4,619 products and 36,594 orders, from 1 December 2009 to 9 December 2011.

Each customer then becomes a row and each product a column, with a 1 where the customer bought the product at least once before a chosen date, called the cut:

#block(breakable: false, width: 100%, codefrom(rec-demo, "def purchase_matrix(sales, cut):", "return bought, customers, products"))

`np.searchsorted` turns each customer number and each product code into a position in the sorted lists, and `sparse.csr_matrix` stores the ones and nothing else. With the cut at 1 September 2011, the matrix has 5,224 rows and 4,403 columns, 23 million cells in all, and 387,122 of them are ones: 1.68%. The median customer had bought 41 different products. Kept sparse, the matrix takes 4.7 MB; written out in full, it would take 184 MB.

The same idea in miniature makes the methods below easy to follow by hand. Five made-up customers and five products, with a 1 for each purchase and the empty cells left empty:

#utptable[
  #tabularx(
    columns: (20%, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center, center),
    header: ([Customer], [teapot], [mug], [candle], [lantern], [card]),
    [Ann], [1], [1], [], [], [1],
    [Ben], [1], [1], [], [], [],
    [Cara], [], [1], [1], [1], [],
    [Dev], [], [], [1], [1], [1],
    [Eve], [1], [], [], [], [],
    [#strong[Buyers]], [#strong[3]], [#strong[3]], [#strong[2]], [#strong[2]], [#strong[2]],
  )
]

Eve has bought one product. What should she see next? Each of the next three methods answers in its own way, and all three agree.

== Testing on the future <sec:rec-test>

A recommender is used on one date to predict what happens after it, so it is tested in the same way (#secref(<sec:data-splits>)): everything before a cut is history, and what customers bought after it is the answer. Two decisions make the test fair.

#strong[Only first purchases count.] In the months after the cut, 39.1% of what established customers bought, they had bought before. Re-ordering is real and worth supporting, but it needs a different tool: a "buy again" list, sorted by how often and how recently each customer ordered each product. A recommender is for discovery, so its answers are the products each customer bought for the first time. After the 1 September cut there are 58,644 of them, from 2,238 customers, a median of 17 each.

#strong[Settings are chosen on an earlier window.] Two of the methods below have a setting to choose. Choosing it on the test would turn the test into a second validation set. So the same game is played first with the cut at 1 June 2011 and the answers from June to August, on 1,503 customers and 26,535 first purchases. The settings are chosen there, and the test is then run once (#figref(<fig:rec-windows>)).

#utpfig([The two cuts. Settings are chosen by learning from the sales before 1 June 2011 and checking against June to August. The test then learns from everything before 1 September 2011 and is scored once, on September to December.], label: <fig:rec-windows>)[
  #canvas({
    let m = 0.42
    let bar(x0, x1, y, colour, body) = {
      rectangle((x0 * m, y), (x1 * m, y + 0.62), fill: mix(colour, 22%), draw: colour)
      node(((x0 + x1) / 2 * m, y + 0.31), body, font: font("script", fill: navy))
    }
    bar(0, 18, 1.0, blue, [history: 18 months])
    bar(18, 21, 1.0, teal, [answers])
    bar(0, 21, 0, blue, [history: 21 months])
    bar(21, 24.3, 0, orange, [answers])
    node((-0.25, 1.31), [choose the settings], font: font("script", weight: "bold", fill: navy), anchor: "east")
    node((-0.25, 0.31), [final test], font: font("script", weight: "bold", fill: navy), anchor: "east")
    for (x, label) in ((0, [Dec 2009]), (12, [Dec 2010]), (18, [Jun 2011]), (21, [Sep 2011]), (24.3, [Dec 2011])) {
      connect((x * m, -0.05), (x * m, -0.22), draw: muted, line-width: widths.thin)
      node((x * m, -0.45), label, font: font("tiny", fill: muted))
    }
  })
]

Each recommender gives every customer a list of ten products they have not bought. Three numbers say how good the lists were:

#describe-nextline(1.35in)[
  / Hit rate at ten: The share of customers who bought at least one product on their list.
  / Precision at ten: The share of the ten places that went to a product the customer then bought, averaged over customers.
  / Recall at ten: The share of a customer’s first purchases that were on the list, averaged over customers.
]

Two more numbers say what kind of lists they were: how many different products appeared on any list at all, and what share of the places went to the shop’s 100 best sellers.

#block(breakable: false, width: 100%, codefrom(rec-demo, "def top_ten(scores, history):", "\"products shown\": len(np.unique(top))}"))

`top_ten` gives every product the customer has already bought a score of minus infinity, so that it can never be chosen, and sorts the rest. A stable sort breaks ties in column order, so the lists are the same on every run. Recall stays low for every method, because a list has ten places and the median customer went on to buy 17 new products.

#pitfall[
  A random split of the purchases would hide some of a customer’s Christmas orders and keep the others in the history. The recommender would then be asked to find the rest of a range it has already seen the customer buy, in a season it has already seen, and it would look better than it can ever be in use. Split by time, the way the shop will use it.
]

=== A 1, or a count?

A customer who ordered a product twelve times has said more about it than one who ordered it once. Should the cell hold the number of orders instead of a 1? The validation window can decide, without touching the test. Holding the number of orders lowered the hit rate of the item-based recommender below from 0.381 to 0.340, and of the factorization from 0.428 to 0.370. The logarithm of one plus the count, which shrinks large counts, gave 0.383 and 0.418: no real gain over a plain 1. The likely reason is that a staple ordered every week, a pack of paper napkins for example, then outweighs everything else the customer ever chose. A 1 lets every product count once, and the rest of the chapter keeps it.

== The bar to beat: best sellers

The simplest recommender ranks the products by how many customers bought them, and shows each customer the top ten they do not have yet. It learns nothing about anyone, and it is the bar that every other method must clear.

Its test hit rate is 0.300: three customers in ten bought at least one product on their list. Ten products drawn at random from those a customer had not bought would reach a hit rate of 0.058, so popularity is already worth five times chance. Its weakness shows in a different number. Across all 2,238 lists it showed only 77 different products, because everyone gets nearly the same ten.

== Customers who bought this also bought

Two products are similar if the same customers bought them. With 0s and 1s, the cosine similarity of #chapref(<ch:foundations>) between two product columns becomes a count:

$ "similarity"(a, b) = frac("customers who bought both", sqrt("buyers of" a times "buyers of" b)) $

#workedexample[
  #strong[Similar products by hand.] Teapot and mug: Ann and Ben bought both, and each has three buyers, so the similarity is $2 \/ sqrt(3 times 3) = 0.667$. Teapot and card: only Ann bought both, from three and two buyers, so $1 \/ sqrt(3 times 2) = 0.408$. Teapot and candle: no shared buyer, so 0. Candle and lantern were bought by exactly the same two customers, so 1.000.

  #v(4pt)
  To recommend, give each product a score: its total similarity to everything the customer bought. Eve bought only the teapot, so her scores are the teapot’s similarities: mug 0.667, card 0.408, candle and lantern 0. The mug comes first.
]

This is #term[item-based collaborative filtering]. #term[Collaborative] because each customer’s purchases help to choose for everyone else. The code computes every similarity at once:

#block(breakable: false, width: 100%, codefrom(rec-demo, "def product_similarity(bought):", "return np.asarray(history @ similar)"))

`normalize` scales each product’s column of buyers to length 1. One matrix product then gives the cosine for every pair of products, 4,403 by 4,403 of them. Setting the diagonal to 0 stops a product recommending itself.

On the shop’s history before the cut, the white hanging heart T-light holder, its best seller, had 1,383 buyers. The red version had 675, and 571 customers bought both, so the similarity is $571 \/ sqrt(1","383 times 675) = 0.591$. The white holder’s five nearest products are:

#utptable[
  #tabularx(
    columns: (1fr, auto),
    align: (left, center),
    header: ([Most similar to the white hanging heart T-light holder, by buyers], [Similarity]),
    [Red hanging heart T-light holder], [0.591],
    [Heart of wicker, large], [0.453],
    [Heart of wicker, small], [0.444],
    [Pink hanging heart candleholder], [0.436],
    [Cream heart card holder], [0.412],
  )
]

Nobody told the method that these are all hearts. It found them from who bought what. On the test, item-based lists reached a hit rate of 0.366, against 0.300 for the best sellers, and showed 801 different products.

The method has two strengths that explain why large shops have used it for decades. The similarity table is computed once, overnight, and serving a customer is then a single multiplication. And a list explains itself: "because you bought the white holder" is a reason a customer can check.

== Customers like you

Turn the matrix the other way. Two customers are similar if they bought the same products, measured by the same cosine between their rows. A customer’s list is then what their most similar customers bought. This is $k$-nearest neighbours (#secref(<sec:knn>)), with customers as the points, and it is called #term[user-based collaborative filtering].

#workedexample[
  #strong[Neighbours by hand.] Eve shares the teapot with Ann, who bought three products, so their similarity is $1 \/ sqrt(1 times 3) = 0.577$. She shares it with Ben, who bought two: $1 \/ sqrt(1 times 2) = 0.707$. She shares nothing with Cara or Dev. With two neighbours, each product scores the similarities of the neighbours who bought it, added up: the mug $0.577 + 0.707 = 1.284$, the card 0.577, from Ann alone. The teapot also scores 1.284, but Eve has it already. The mug wins again.
]

#block(breakable: false, width: 100%, codefrom(rec-demo, "def user_based(bought, rows, neighbours):", "return np.asarray((bought.T @ close.T).T)"))

The number of neighbours is a setting. Few neighbours make a noisy list, built on a handful of customers. Many neighbours make every list drift towards the best sellers, because once half the shop is your neighbour, its favourites are your favourites. On the validation window, 100 neighbours gave the highest hit rate, 0.413 (#figref(<fig:rec-settings>)), and the number of different products shown fell steadily as the neighbours grew, from 1,344 with 10 neighbours to 348 with 400. On the test, the lists of the 100 nearest customers reached a hit rate of 0.400.

User-based filtering is slower to serve than item-based filtering: each new list compares the customer with every other customer. And its reason, "customers like you bought this", points to people the customer has never met.

#utpfig([Validation hit rate as the setting of each method changes. The dashed line is the item-based recommender, which has no setting to choose. Both methods do best at 100: 100 neighbours, and 100 tastes.], label: <fig:rec-settings>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.5cm, ..logaxis, width: 6.6cm, height: 4.4cm, xmin: 0.6, xmax: 6.4, ymin: 0.35, ymax: 0.44, xtick: (1, 2, 3, 4, 5, 6), ytick: (0.36, 0.38, 0.40, 0.42, 0.44), yticklabels: ([0.36], [0.38], [0.40], [0.42], [0.44]),
      nextgroupplot(title: [user-based], xlabel: [neighbours], ylabel: [validation hit rate], xticklabels: ([10], [20], [50], [100], [200], [400]),
        addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((0.6, 0.381), (6.4, 0.381))),
        addplot(draw: blue, mark: "*", mark-size: 1.9pt, line-width: widths.thick, coords: ((1, 0.368), (2, 0.395), (3, 0.409), (4, 0.413), (5, 0.409), (6, 0.401))),
        {
          node((6.3, 0.376), [item-based], font: font("tiny", fill: orange), anchor: "east")
          node((4, 0.419), [0.413], font: font("tiny", weight: "bold", fill: navy))
        },
      ),
      nextgroupplot(title: [factorization], xlabel: [tastes], xticklabels: ([10], [20], [50], [100], [200], [300]),
        addplot(draw: orange, dash: "dashed", line-width: widths.thin, coords: ((0.6, 0.381), (6.4, 0.381))),
        addplot(draw: blue, mark: "*", mark-size: 1.9pt, line-width: widths.thick, coords: ((1, 0.358), (2, 0.379), (3, 0.412), (4, 0.428), (5, 0.395), (6, 0.387))),
        {
          node((6.3, 0.376), [item-based], font: font("tiny", fill: orange), anchor: "east")
          node((4, 0.434), [0.428], font: font("tiny", weight: "bold", fill: navy))
        },
      ),
    )
  })
]

== Tastes: matrix factorization

#analogy[
  A bookseller who knows you well does not remember every book you ever bought. They remember that you like crime novels set abroad and long histories of the sea, and they choose for you from that short description. Matrix factorization learns such a description for every customer, and a matching one for every product, from nothing but who bought what.
]

Both neighbour methods compare pairs: two products, or two customers. #term[Matrix factorization] looks at the whole matrix at once. It describes every customer by a few numbers, the customer’s #term[tastes], and every product by the same number of numbers, how much it appeals to each taste. A customer’s score for a product multiplies their matching numbers and adds them up. The tastes are not given to it; they are chosen so that the scores rebuild the purchase matrix as closely as possible (#figref(<fig:rec-factors>)). The SVD of #chapref(<ch:dimred>) finds them, all at once. Elsewhere you will see them called latent factors.

#utpfig([Matrix factorization writes the purchase matrix, approximately, as a product of two thin matrices: a row of tastes for each customer and a column of tastes for each product. A customer’s score for a product multiplies the customer’s row by the product’s column, number by number, and adds the results.], label: <fig:rec-factors>)[
  #canvas({
    rectangle((0, 0), (4.6, 3.2), fill: mix(blue, 10%), draw: blue)
    node((2.3, 3.5), [purchases], font: font("script", weight: "bold", fill: navy))
    node((2.3, -0.35), [5,224 customers × 4,403 products], font: font("tiny", fill: muted))
    node((5.1, 1.6), [$approx$], font: font("normal", fill: navy))
    rectangle((5.6, 0), (6.5, 3.2), fill: mix(teal, 22%), draw: teal)
    node((6.05, 3.5), [customers’ tastes], font: font("script", weight: "bold", fill: navy))
    node((6.05, -0.35), [5,224 × 100], font: font("tiny", fill: muted))
    node((7.0, 1.6), [$times$], font: font("normal", fill: navy))
    rectangle((7.5, 2.3), (12.1, 3.2), fill: mix(orange, 22%), draw: orange)
    node((9.8, 3.5), [products’ tastes], font: font("script", weight: "bold", fill: navy))
    node((9.8, 2.0), [100 × 4,403], font: font("tiny", fill: muted))
    rectangle((5.6, 1.9), (6.5, 2.1), fill: teal, draw: none)
    rectangle((10.6, 2.3), (10.8, 3.2), fill: orange, draw: none)
    rectangle((3.1, 1.9), (3.3, 2.1), fill: navy, draw: none)
    node((3.2, 1.5), [one customer’s score \ for one product], font: font("tiny", fill: navy), align: center)
  })
]

#workedexample[
  #strong[Two tastes by hand.] An SVD with two tastes, fitted to the five customers, gives:

  #v(6pt)
  #align(center)[#fsize("small")[
    #grid(columns: (auto, auto), column-gutter: 1.4em, align: top,
      tabularx(
        columns: (auto, auto, auto),
        align: (left, center, center),
        header: ([Customer], [Taste 1], [Taste 2]),
        [Ann], [1.43], [0.81],
        [Ben], [1.03], [0.89],
        [Cara], [1.36], [$-0.77$],
        [Dev], [1.18], [$-1.11$],
        [Eve], [0.44], [0.64],
      ),
      tabularx(
        columns: (auto, auto, auto),
        align: (left, center, center),
        header: ([Product], [Taste 1], [Taste 2]),
        [teapot], [0.44], [0.64],
        [mug], [0.58], [0.25],
        [candle], [0.39], [$-0.51$],
        [lantern], [0.39], [$-0.51$],
        [card], [0.40], [$-0.08$],
      ),
    )
  ]]

  #raggedright[
  #v(6pt)
  Taste 1 is positive for everyone and everything: it measures how much a customer buys and how popular a product is. Taste 2 separates the tea things from the lights, and Ann and Ben from Cara and Dev. Eve bought only the teapot, so her tastes are the teapot’s own. Her score for the mug is $0.44 times 0.58 + 0.64 times 0.25 = 0.42$, for the card 0.13, and for the candle and the lantern $-0.15$. The mug wins a third time, by a route that never compared two customers or two products directly. An SVD may flip the sign of a whole taste; the products of matching numbers, and so the scores, stay the same.
  ]
]

#block(breakable: false, width: 100%, codefrom(rec-demo, "def factorization(bought, history, factors):", "return tastes @ svd.components_"))

`TruncatedSVD` keeps only the largest tastes and works on the sparse matrix directly. Unlike PCA, it does not subtract each column’s mean first, which would put a number in every empty cell and make the matrix dense. `transform` finds a customer’s tastes from their row, and multiplying by `components_`, the products’ tastes, gives a score for every product.

#recipecard([Matrix factorization], [A row of tastes for every customer and a column of tastes for every product. A score multiplies the matching numbers and adds them.], [The squared difference between the purchase matrix and its rebuilt version, over every cell, with the empty cells counted as 0.], [The truncated SVD: an exact matrix routine that finds all the tastes at once.])

What did 100 tastes learn from the shop? The first one simply follows the best sellers. The products with its largest weights are the white hanging heart holder, the 72 retrospot cake cases and the Regency cake stand, so a customer’s first taste says how much of the popular range they buy. The others separate ranges of products. Each row of the next table shows the three products at the two ends of one taste:

#utptable[
  #tabularx(
    columns: (auto, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Taste], [At one end], [At the other end]),
    [2], [White hanging heart T-light holder; heart of wicker, small and large], [Spaceboy lunch bag; Spaceboy plasters in a tin; woodland snack boxes],
    [3], [Jumbo bag and lunch bag in red retrospot; jumbo bag in pink polkadot], [Vintage snap cards; vintage heads and tails card game; wooden school colouring set],
    [4], [Regency cake stand; red retrospot cake stand; Roses Regency teacup and saucer], [Rex cash-and-carry jumbo shopper; skull pencils in a tube; feltcraft butterfly hearts],
    [7], [Signs: "Please one person", "Hand over the chocolate", "Gin and tonic diet"], [Spotty cups in red, blue and pink],
  )
]

Read across a row: home decoration against children’s things, shopping bags against old-fashioned games, cake stands and teacups against a shopper, pencils and a craft kit, joke signs against plain spotty cups. The SVD was told none of these words. It found that the customers who stock wicker hearts are seldom the ones who stock Spaceboy lunch bags, and turned that fact into a number. This is the same discovery without labels as clustering and PCA, put to work.

The number of tastes is a setting. Too few cannot tell the ranges apart. Too many start to copy each customer’s own purchases instead of generalizing from them: the overfitting of #chapref(<ch:training>). On the validation window the hit rate rose from 0.358 with 10 tastes to 0.428 with 100 and fell back to 0.387 with 300 (#figref(<fig:rec-settings>)). The 100 tastes rebuild 39.0% of the matrix, measured by its sum of squares, and the first alone rebuilds 11.6%. Most of the rest is what is particular to each customer, which is exactly what cannot be generalized from. On the test, 100 tastes reached a hit rate of 0.448, the best of the five methods, and showed 1,062 different products.

== Describing the products

The three methods so far use only who bought what. A #term[content-based] recommender uses what the products are instead. The shop’s only description of a product is its name, so each name becomes the set of its words, and two products are similar when their names share words, measured by the same cosine. #chapref(<ch:text>) shows how to weigh words more carefully than this.

#block(breakable: false, width: 100%, codefrom(rec-demo, "def word_similarity(descriptions):", "return similar"))

By its name, the white hanging heart holder is closest to the red hanging heart T-light holder, the hanging heart zinc T-light holder and the hanging heart jar T-light holder, all at 0.800. Words find variants of the same product; buyers found what goes with it. On the test, lists built from names reached a hit rate of 0.294, a little below the best sellers, although they showed 1,934 different products. Words say what a product is, not who wants it: "red retrospot" is printed on cake cases, shopping bags and cups, and different customers buy each of them.

The strength of this method is elsewhere. It needs no buyers at all, and that matters in #secref(<sec:rec-cold>).

== Five recommenders on one test

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Recommender], [Hit rate], [Precision], [Recall], [Products shown], [From the top 100]),
    [Best sellers], [0.300], [0.042], [0.020], [77], [99.9%],
    [Item-based], [0.366], [0.062], [0.036], [801], [81.1%],
    [User-based, 100 neighbours], [0.400], [0.070], [0.038], [683], [72.0%],
    [Factorization, 100 tastes], [0.448], [0.074], [0.043], [1,062], [34.8%],
    [Product descriptions], [0.294], [0.045], [0.028], [1,934], [10.3%],
  )
]

The factorization leads on all three numbers at ten, with the user-based and then the item-based lists behind it. The product descriptions fall just below the best sellers on hit rate but beat them on precision and recall: they reached fewer customers, with more hits each. The factorization also shows a wider range of products than either neighbour method, and only a third of its places go to the 100 best sellers (#figref(<fig:rec-tradeoff>)). Here, the most accurate lists were also among the most varied.

#utpfig([Accuracy against variety on the test. Each point is one recommender: the share of customers who bought from their list, and how many different products appeared across all 2,238 lists.], label: <fig:rec-tradeoff>)[
  #canvas({
    axis(width: 11cm, height: 5cm, ..logaxis, xlabel: [different products shown across all lists], ylabel: [test hit rate], xmin: 0, xmax: 2100, ymin: 0.27, ymax: 0.47, xtick: (0, 500, 1000, 1500, 2000), xticklabels: ([0], [500], [1,000], [1,500], [2,000]), ytick: (0.30, 0.35, 0.40, 0.45), yticklabels: ([0.30], [0.35], [0.40], [0.45]),
      addplot(only-marks: true, mark: "*", mark-size: 2.2pt, draw: blue, fill: blue, coords: ((77, 0.300), (801, 0.366), (683, 0.400), (1062, 0.448), (1934, 0.294))),
      {
        node((140, 0.300), [best sellers], font: font("script", fill: navy), anchor: "west")
        node((860, 0.366), [item-based], font: font("script", fill: navy), anchor: "west")
        node((620, 0.400), [user-based], font: font("script", fill: navy), anchor: "east")
        node((1120, 0.448), [factorization], font: font("script", fill: navy), anchor: "west")
        node((1870, 0.294), [product descriptions], font: font("script", fill: navy), anchor: "east")
      },
    )
  })
]

Who gains the most? Split the test customers into thirds by the length of their history:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Products bought before the cut], [Best sellers], [Item-based], [User-based], [Factorization], [Descriptions]),
    [Up to 46], [0.291], [0.368], [0.393], [0.399], [0.252],
    [47 to 116], [0.285], [0.358], [0.396], [0.447], [0.318],
    [More than 116], [0.323], [0.372], [0.413], [0.500], [0.315],
  )
]

The factorization climbs from 0.399 to 0.500 as the history grows, while the best sellers and the item-based lists hardly move. Tastes need evidence: a customer who has bought 20 products has not yet shown many of them.

One customer makes the differences concrete. Before the cut, customer 12680 had bought 19 products, among them lunch boxes, aprons and cutlery for children in the Dolly Girl and Spaceboy designs, birthday cards, tissues, two pantry brushes, and two alarm clocks, one pink and one red. After the cut they bought 13 products that were new to them. Their three lists, with #yes against each product they went on to buy:

#utptable[
  #tabularx(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (center, left, left, left),
    header: ([], [Best sellers], [Item-based], [Factorization]),
    [1], [White hanging heart holder], [Spaceboy plasters in a tin], [Spaceboy plasters in a tin],
    [2], [Regency cake stand], [Circus parade lunch box #yes], [Alarm clock, green #yes],
    [3], [72 retrospot cake cases], [Spaceboy lunch bag], [Circus parade lunch box #yes],
    [4], [Retrospot baking set #yes], [Woodland plasters in a tin], [Alarm clock, orange],
    [5], [Assorted colour bird ornament], [Fruit snack boxes, set of 4], [Woodland plasters in a tin],
    [6], [Red retrospot jumbo bag], [Circus parade plasters in a tin #yes], [Pink fairy cake children’s apron],
    [7], [Party bunting], [Dolly Girl lunch bag], [Spaceboy tissues, pack of 12],
    [8], [Retrospot tea set, 11 pieces], [Woodland lunch bag], [Alarm clock, ivory #yes],
    [9], [Red retrospot lunch bag], [Spaceboy cake cases, pack of 60], [Fruit snack boxes, set of 4],
    [10], [Natural slate heart chalkboard], [Red retrospot lunch bag], [Circus parade plasters in a tin #yes],
  )
]

The best sellers are the same for everyone, and one of them happened to be bought. The item-based list stays close to the history, with more lunch bags, plasters and snack boxes for children, and two of them were bought. The factorization also offers the alarm clock in other colours, and the customer bought two of them, the green and the ivory, with two of the children’s products: four hits in ten.

#intuition[
  Look at what worked: another colour of a clock the customer already had. Many of this shop’s customers are themselves shops, and a shop stocks a product in several colours, so a second colour is a sale. For a household, a second alarm clock is a poor suggestion. Whether a similar product is a welcome companion or a pointless substitute depends on the business, and an offline test can only tell you what this shop’s customers did.
]

== Cold start <sec:rec-cold>

Every collaborative method needs a history. The #term[cold-start problem] is what to do without one, and it comes in two forms. After the 1 September cut, 628 customers bought from the shop for the first time, and 216 products were sold for the first time.

=== A new customer

Before a first order, a recommender has nothing to go on but the best sellers, or whatever the shop can learn at sign-up: the country, the page that brought the visitor, a few questions about what they sell. After the first order, things change. Of the 628 new customers, 232 came back for more after a first order of 23 products (the median). Take that first order as their whole history and rank the catalogue for the rest of their buying:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([After one order], [Hit rate], [Precision], [Recall], [Products shown]),
    [Best sellers], [0.371], [0.065], [0.022], [16],
    [Item-based], [0.513], [0.107], [0.067], [397],
    [Factorization, 100 tastes], [0.534], [0.114], [0.074], [581],
  )
]

One order is enough, and neither method needs to be refitted. The item-based recommender reuses its similarity table, and the factorization places the newcomer with `transform`, which finds the tastes that best explain their first order. These newcomers are a different group from the established customers of the main test, and nearly everything they buy is new to them, so compare the methods within this table and not with the earlier one.

=== A new product

A product with no buyers has an empty column. No collaborative method can recommend it: its similarity to every product is 0, and its tastes are unknown. Its description, however, exists from the day it is listed. The 216 new products were bought by 1,638 established customers, 10,580 pairs of customer and product. Ranking the new products for each of those customers by how closely their names match what the customer had bought gave a hit rate of 0.385. Ten new products drawn at random would have reached 0.235.

=== Hybrids

A #term[hybrid] recommender combines methods so that each covers the others’ blind spots. There are three common ways to combine them:

- #strong[Switch] by situation: best sellers for a visitor with no history, the factorization for a customer with one, product descriptions to place a new product.
- #strong[Blend] the scores of several methods, with the weights chosen on the validation window.
- #strong[Learn to rank]: use each method’s score, with features such as price, season and stock, as inputs to a supervised model, for example the boosted trees of #chapref(<ch:ensembles>), trained to predict what is bought next.

#utptable[
  #tabularx(
    columns: (17%, 1fr, 1fr, 1fr, 1.2fr),
    align: (left, left, left, left, left),
    styles: (navy-bold,),
    header: ([Recommender], [Learns from], [New customer], [New product], [Its reason]),
    [Best sellers], [Number of buyers], [At once], [Once it sells], ["Popular"],
    [Item-based], [Bought together], [After one order], [Once bought], ["You bought X"],
    [User-based], [Similar customers], [After one order], [Once bought], ["Customers like you"],
    [Factorization], [Hidden tastes], [After one order], [Once bought], [Hard to put in words],
    [Descriptions], [Product names], [After one order], [At once], ["Similar to X"],
  )
]

== Beyond the hit rate

An offline test rewards a list for predicting what customers bought without it. Once the list is on the page, it changes what they buy. That has three consequences.

#strong[The final test is an experiment.] Offline numbers choose which recommenders deserve a trial. The trial itself shows the new list to a random half of the customers and the old one to the other half, and compares what the two halves buy. Only that comparison measures what the list causes.

#strong[A list feeds its own data.] What is shown gets bought, and what is bought gets shown again. Left alone, the loop narrows every list towards the best sellers, which here spread the same 77 products over all 22,380 places. Measure variety alongside accuracy, as the tables above do, and keep a few places for new or randomly chosen products so that the data keeps teaching the model about the whole catalogue.

#strong[A list obeys the business.] Hide products that are out of stock, do not offer what a customer has just returned, respect margins, and decide whether near-duplicates belong on the same list. Large systems usually work in two stages: cheap methods such as the ones in this chapter choose a few hundred candidates from millions, and a supervised model ranks those candidates with everything else that is known. Tastes also drift, with seasons and fashions, so the model is refitted on a schedule and watched like any other (#chapref(<ch:serving>)).

#modelcard[Recommender Systems - Quick Guide][
  #tabularx(
    columns: (22%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [There are many customers and many products, a record of who chose what, and room to show only a few.],
    [Start with], [Best sellers as the bar to beat, then item-based filtering; matrix factorization once histories are long enough.],
    [Preprocessing], [Remove lines that are not products; decide between a 1 and a count on validation; split by time; keep only first purchases when the goal is discovery.],
    [Main controls], [The number of neighbours or tastes, the length of the list, and the room left for new and random products.],
    [Watch for], [Random splits, settings tuned on the test, lists that show only best sellers, and new products that no collaborative method can see.],
  )
]

#libnote[
  Everything in this chapter needs only #lib("NumPy"), #lib("SciPy") and #lib("scikit-learn"). #lib("implicit") fits factorizations to purchases and clicks by alternating least squares, #lib("Surprise") is built for star ratings, and #lib("LightFM") mixes collaborative and content information in one model.
]

#tryit[
  In `demo_recommenders.py`, set `CHECK_BOOK_NUMBERS = False`. Change `TOP` from 10 to 3 and run the script; then change it to 30. Which recommender gains the most from a longer list? Why does the hit rate rise while the precision falls? A phone screen shows three products and a page of a catalogue thirty: would you choose the same recommender for both?
]

#block(breakable: false, width: 100%, chapterrecap[
  - A recommender ranks thousands of products for each customer, and only the top of the list counts. Its evidence is usually implicit, and an empty cell is not a no.
  - Test on the future: learn from the sales before a cut and score on what customers bought for the first time after it. Choose settings on an earlier window. Here 39.1% of later buying repeated earlier purchases, a separate job for a "buy again" list.
  - Best sellers reached a hit rate of 0.300 at ten, five times chance (0.058), but showed only 77 different products.
  - Item-based filtering scores a product by its cosine similarity to what the customer bought; it is fast and explains itself (0.366). User-based filtering asks the most similar customers (0.400 with 100 neighbours).
  - Matrix factorization describes customers and products by the same hidden tastes, found by a truncated SVD. With 100 tastes it was the most accurate (0.448), showed 1,062 products, and gained the most from long histories.
  - Product descriptions alone were weaker (0.294), but they are the only way to place a new product: 0.385 against 0.235 at random. One first order is enough history for item-based filtering and factorization.
  - An offline test chooses candidates; an experiment decides. Watch the variety of the lists, keep room for new products, and let the business decide what a good suggestion is.
])

#quickcheck[
  + Why is an empty cell in a purchase matrix not a "no"? Name one consequence for how a recommender is tested.
  + One product has 40 buyers, another has 90, and 12 customers bought both. What is their cosine similarity?
  + Why does the test count only products the customer had never bought? What would a "buy again" list rank by instead?
  + Best sellers reached a hit rate of 0.300 and ten random products 0.058. What does each number tell you about the next method you try?
  + In user-based filtering, what happens to the lists as the number of neighbours grows very large, and why?
  + A factorization with 300 tastes did worse on validation than one with 100. Explain why more tastes can hurt.
  + A new customer has just placed a first order of 20 products. Which recommenders can serve them without being refitted, and how?
  + A new product arrives with a name and no buyers. Which recommender can place it, and how would you combine it with the others?
  + The factorization showed 1,062 different products and the best sellers 77. Why does that matter to the shop, beyond the hit rate?
]
