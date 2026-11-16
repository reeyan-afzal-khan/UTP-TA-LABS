#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "18-feature-selection")

#let selection = "/MACHINE LEARNING/all_experiments/book_checks/demo_selection.py"

= Feature Selection <ch:feature-selection>

#chapterguide[The first look at selection in #chapref(<ch:feature-engineering>)\; the $F$ score of #chapref(<ch:inference>)\; cross-validation and regularization from #chapsref(<ch:evaluation>, <ch:training>)\; the L1 penalty of #chapref(<ch:regression>)\; and tree importances from #chapsref(<ch:decision-trees>, <ch:ensembles>).][say what an extra column costs; remove leaks, constants and twins before anything else; score columns one at a time and know what that misses; run a forward selection and stop it in time; read an L1 path; tell a forest's built-in importance from importance by shuffling; check whether a selection is stable; and keep the whole procedure inside validation.]

A carpenter does not carry every tool they own to every job. Each tool in the bag is weight on the shoulder, and a blunt chisel in the bag is a chisel that might get picked up by mistake. Columns are the same. Every feature a model uses has to be collected, checked and explained for as long as the model lives, and a useless one is something the model can fit by accident.

#chapref(<ch:feature-engineering>) built features. This chapter decides which ones stay. It works throughout on one table: 20,000 personal loans from Lab~3, with 25 columns that a lender knows when it approves a loan, and the question of whether the borrower will default.

To that table we add three columns of pure random noise, `noise_1`, `noise_2` and `noise_3`. They are the lie detector of this chapter: #emph[a method that keeps them has been fooled]. Every number comes from `all_experiments/book_checks/demo_selection.py`.

== What an extra column costs

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([The cost], [Why it matters]),
    [Noise to fit], [With enough columns, some will match the training labels by luck. The model learns the luck, and the validation score falls.],
    [Work at prediction time], [Every feature must be available, on time and in the same form, for every future prediction. One late or broken column stops the model.],
    [Speed and memory], [Training and tuning grow with the number of columns, and for some methods much faster than that.],
    [Explanation], [A model with eight inputs can be described to the person it affects. One with eight hundred cannot.],
    [Monitoring], [Each column can drift after deployment, so each one is something to watch (#chapref(<ch:serving>)).],
  )
]

Selection does not usually raise the score much. Its usual result is the same score from far fewer columns, and that is a real gain.

== Step zero: what must never be a feature

Before any method runs, remove what the model would not have at the moment of prediction. The loans file carries eight columns written after each loan was issued. Score a few of them, alone, by how well each ranks the loans by default:

```terminal
columns written after the loan was issued, each alone: {'last_fico_range_high': 0.933, 'recoveries': 0.859,
 'total_rec_prncp': 0.859, 'last_pymnt_amnt': 0.781}  best honest column alone: 0.703
```

The borrower's #emph[latest] credit score reaches a ROC AUC of 0.933 on its own, and the money recovered after a default reaches 0.859. The best column a lender actually has at approval reaches 0.703.

#note[
  Every selection method in this chapter would put those columns at the top of its list. None of them can tell you that a column comes from the future. Only the data card and the question "when is this value known?" can do that (#secref(<sec:data-leakage>)). Selection methods rank what you give them, so decide first what they are allowed to see.
]

== Three families of method

Selection methods differ in one thing: where the model sits (#figref(<fig:selection-families>)).

#utpfig([Where the model sits. A filter scores columns from the data alone and never fits the model. A wrapper fits the model again and again on different subsets and lets its validation score decide. An embedded method selects during a single round of training.], label: <fig:selection-families>)[
  #canvas({
    let step = (..utpstep, min-width: 2.75, min-height: 0.82, font: font("script", fill: navy))
    let model = (..utpstep, min-width: 2.75, min-height: 0.82, fill: pale-orange, draw: orange, font: font("script", weight: "bold", fill: navy))
    let lane(y, name, note) = {
      node((-1.1, y + 0.16), [#strong[#name]], font: font("small", fill: navy), anchor: "east")
      node((-1.1, y - 0.24), [#note], font: font("tiny", fill: muted), anchor: "east")
    }
    // filter
    lane(2.5, [Filter], [no model])
    node((0.6, 2.5), [all columns], name: "f1", ..step)
    node((4.0, 2.5), [score each column \ against the label], name: "f2", ..step)
    node((7.4, 2.5), [keep the best], name: "f3", ..step)
    node((10.8, 2.5), [fit the model once], name: "f4", ..model)
    connect("f1", "f2", ..utparrow)
    connect("f2", "f3", ..utparrow)
    connect("f3", "f4", ..utparrow)
    // wrapper
    lane(0.7, [Wrapper], [many fits])
    node((0.6, 0.7), [all columns], name: "w1", ..step)
    node((4.0, 0.7), [try a subset], name: "w2", ..step)
    node((7.4, 0.7), [fit and validate \ the model], name: "w3", ..model)
    node((10.8, 0.7), [keep the best subset], name: "w4", ..step)
    connect("w1", "w2", ..utparrow)
    connect("w2", "w3", ..utparrow)
    connect("w3", "w4", ..utparrow)
    connect("w3.south", (rel: (0, -0.42), to: "w3.south"), "-|", "w2.south", ..utparrow, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick, color: orange))
    node((5.7, -0.36), [next subset], font: font("tiny", fill: orange), fill: white, inner-sep: 1.5pt)
    // embedded
    lane(-1.5, [Embedded], [one fit])
    node((0.6, -1.5), [all columns], name: "e1", ..step)
    node((5.7, -1.5), [fit a model that drops or ranks columns as it trains], name: "e2", ..model, min-width: 6.15)
    node((10.8, -1.5), [read what it kept], name: "e3", ..step)
    connect("e1", "e2", ..utparrow)
    connect("e2", "e3", ..utparrow)
  })
]

== Filters

=== Without the label: constants and twins

Two kinds of column can be removed without looking at the target at all.

A #term[quasi-constant] column takes one value in nearly every row. In the training loans, `joint_application` is 0 for 99.95% of rows and `small_business` for 99.17%. A column that hardly varies can hardly explain anything, and the handful of rows that differ are too few to learn from.

#term[Twins] are columns that carry the same information, found by their correlation.

```terminal
twins: [('loan_amnt', 'installment', 0.952), ('int_rate', 'sub_grade', 0.991), ('fico_low', 'fico_high', 1.0)]
```

The lower and upper ends of the credit score band move in perfect step. The interest rate is set from the lender's sub-grade, and the monthly instalment follows from the amount borrowed. Keeping one of each pair costs nothing:

```terminal
logistic model on all 28 columns: cross-validated AUC 0.7265; without one twin of each pair: 0.7251
```

Three fewer columns and a difference of 0.0014, which the next section will show is well inside the noise. When choosing which twin to keep, prefer the one that is easier to obtain, has fewer gaps, or is simpler to explain.

#codefrom(selection, "def twins(X, limit=0.9):", "return [(a, b, r.loc[a, b])")

=== With the label: one column at a time

The next filters score every column against the target, each on its own. Three scores are common. The $F$ of #chapref(<ch:inference>) asks how far apart the two classes sit in the column's mean. #term[Mutual information] asks how much knowing the column reduces uncertainty about the target, whatever the shape of the relationship. And the simplest of all: the ROC AUC of the column used alone as a score.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Column], [$F$], [Mutual information], [AUC alone]),
    [`sub_grade`], [1310.3], [0.0374], [0.703],
    [`int_rate`], [1228.5], [0.0415], [0.697],
    [`term_months`], [854.8], [0.0263], [0.627],
    [`fico_low`], [241.2], [0.0057], [0.591],
    [`dti`], [179.1], [0.0055], [0.576],
    [#emph[fourteen columns omitted]], [], [], [],
    [`installment`], [5.5], [0.0214], [0.523],
    [`noise_1`], [2.4], [0.0000], [0.507],
    [`emp_years`], [0.2], [0.0034], [0.504],
    [`total_acc`], [0.0], [0.0009], [0.500],
  )
]

Four things are worth reading in that table.

- #strong[The top is not in doubt.] All three scores put the lender's own grade, the interest rate and the loan's term first.
- #strong[The scores can disagree.] `installment` is twentieth by $F$ and fourth by mutual information. Defaulters and repayers have nearly the same average instalment, so $F$ sees nothing, while the instalment still says something about default through the rate and the term it is computed from. $F$ finds shifts of the mean and misses everything else.
- #strong[Noise lands in the middle.] `noise_1` scores an $F$ of 2.4 and beats two real columns, the borrower's years in their job and their total number of credit lines. With 28 columns tested, that is what #chapref(<ch:inference>) said to expect.
- #strong[A filter is blind to company.] The two ends of the credit score band get the same score, 241.2 each, and a filter would happily keep both. It scores each column as if the others did not exist, so it sees neither redundancy nor columns that only help together.

In scikit-learn a filter is `SelectKBest(f_classif, k=10)`, or `mutual_info_classif`, or `chi2` for counts and yes/no columns. It runs in an instant on thousands of columns, which makes it the right first pass and the wrong last word.

== Wrappers: let the model judge

A #term[wrapper] asks the question that matters directly: with this set of columns, how well does #emph[my model] validate?

=== Forward selection

Start with no columns. Try each one alone and keep the best. Then try each remaining column beside it and keep the best pair, and so on.

#codefrom(selection, "def forward_selection(X, y, steps):", "return path")

#utpfig([Forward selection on the loans: the cross-validated ROC AUC as columns are added one at a time. The curve climbs fast, then creeps. At step ten the search adds `noise_1`, a column of random numbers, for a gain of 0.0004.], label: <fig:forward-selection>)[
  #canvas({
    axis(width: 13cm, height: 5.6cm, ..logaxis, xlabel: [columns in the model], ylabel: [cross-validated ROC AUC], xmin: 0.4, xmax: 12.6, ymin: 0.698, ymax: 0.732, xtick: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12), ytick: (0.70, 0.71, 0.72, 0.73),
      addplot(draw: muted, dash: "dashed", domain: (0.4, 12.6), x => 0.7265),
      addplot(draw: blue, mark: "*", mark-size: 1.7pt, line-width: widths.thick, coords: ((1, 0.7027), (2, 0.7132), (3, 0.7175), (4, 0.7201), (5, 0.7221), (6, 0.7237), (7, 0.725), (8, 0.7259), (9, 0.7267), (10, 0.7271), (11, 0.7274), (12, 0.7276))),
      {
        circle-at((10, 0.7271), 3.2pt, draw: red, fill: red)
        node((10, 0.7296), [`noise_1`], font: font("script", fill: red))
        node((1.15, 0.7012), [`sub_grade`], font: font("tiny", fill: navy), anchor: "west")
        node((2.15, 0.7118), [`term_months`], font: font("tiny", fill: navy), anchor: "west")
        node((3.15, 0.7161), [`renter`], font: font("tiny", fill: navy), anchor: "west")
        node((4.15, 0.7187), [`dti`], font: font("tiny", fill: navy), anchor: "west")
        node((5.15, 0.7207), [`fico_low`], font: font("tiny", fill: navy), anchor: "west")
        node((6.15, 0.7223), [`revol_util`], font: font("tiny", fill: navy), anchor: "west")
        node((3.3, 0.728), [all 28 columns: 0.7265], font: font("script", fill: muted))
      },
    )
  })
]

Three lessons come out of this one run.

/ Company matters.: The third column chosen is `renter`, which ranked eighth on its own. It adds something the grade and the term do not already say. And `int_rate`, the second-best column alone, is chosen only ninth, because its twin `sub_grade` got there first. This is what a filter cannot see.
/ The search does not know when to stop.: At step ten it adds `noise_1`, and it would have kept going. The gain at that step is 0.0004. The five folds of the cross-validation disagree with each other by 0.0153. Every gain after about the sixth column is smaller than a tenth of that spread, so the search has been ranking noise for half its length. Stop when a step gains less than the folds differ: here, six columns at 0.7237 against 0.7265 for all 28.
/ The cost is the fits.: Twelve steps fitted 1,350 models. Trying every possible subset of 28 columns would mean $2^(28) - 1 = 268","435","455$ subsets, each cross-validated. A wrapper is for tens of columns, after a filter has removed the hopeless ones.

#term[Backward elimination] runs the other way: start with every column and remove, at each step, the one whose removal hurts least. scikit-learn offers both as `SequentialFeatureSelector(model, direction="forward")` or `"backward"`.

=== Recursive feature elimination

#term[Recursive feature elimination], RFE, is a cheaper cousin. Fit the model once on all columns, drop the column with the smallest weight, and repeat. It needs one fit per step instead of one per candidate.

```terminal
five columns by elimination: ['loan_amnt', 'installment', 'term_months', 'int_rate', 'sub_grade'], AUC 0.7160
five columns by forward selection: ['sub_grade', 'term_months', 'renter', 'dti', 'fico_low'], AUC 0.7221
```

RFE's five are worse, and the reason is in the list: it kept both members of two pairs of twins. When two columns say the same thing, a linear model can give one a large positive weight and the other a large negative one, and the two nearly cancel. The weights are large, so RFE keeps them, while the pair together adds little. A weight measures importance only when the columns are not telling the same story (#chapref(<ch:regression>)). Remove the twins first, and then let RFE work. `RFECV` chooses how many columns to keep by cross-validation.

== Embedded methods: selection during training

=== The L1 penalty

An #term[L1 penalty] charges the model for the total size of its weights and, unlike the ridge penalty, pushes the weakest ones to exactly zero (#chapref(<ch:regression>)). One setting, `C`, controls the charge: the smaller `C`, the stronger the penalty and the fewer the survivors.

#utptable[
  #tabularx(
    columns: (auto, auto, auto, 1fr),
    align: (center, center, center, left),
    header: ([`C`], [Columns kept], [Validation AUC], [Noise columns kept]),
    [0.001], [2], [0.7190], [none],
    [0.003], [5], [0.7282], [none],
    [0.01], [13], [0.7347], [none],
    [0.03], [20], [0.7345], [`noise_1`, `noise_2`],
    [1.0], [28], [0.7344], [all three],
  )
]

Read down the table. Two columns already reach 0.7190. Thirteen reach 0.7347, the best the model gets. Past that point the penalty is too weak to keep the noise out, and nothing is gained by letting it in. The five columns kept at `C = 0.003` are `sub_grade`, `term_months`, `renter`, `dti` and `fico_low`: exactly the first five that forward selection chose, found with five fits instead of hundreds.

Scale the columns first, since the penalty compares weights across columns (#secref(<sec:scaling>)), and choose `C` by validation like any other setting. `SelectFromModel` turns any fitted model with weights or importances into a selection step for a pipeline.

=== A forest's built-in importance, and its blind spot

A random forest reports an importance for every column: how much, in total, splits on that column reduced impurity while the trees were grown (#secref(<sec:tree-feature-importance>)). On the loans:

```terminal
built-in importance, top eight: {'int_rate': 0.085, 'sub_grade': 0.077, 'dti': 0.065, 'revol_bal': 0.056,
 'noise_1': 0.056, 'noise_3': 0.055, 'credit_years': 0.055, 'noise_2': 0.055}
```

The three columns of random numbers come fifth, sixth and eighth out of 28, ahead of the credit score, the loan's term and the borrower's income. The forest has not found signal in noise. Its importances are measured on the #emph[training] rows, and a deep tree can always find a split on a column with many distinct values that tidies up the training rows a little. A column of random decimals has as many distinct values as a column can have.

== Shuffling: ask the fitted model what it uses

There is a better question to ask a fitted model. Take the validation rows, shuffle one column so that it no longer lines up with anything, and measure how far the validation score falls. That fall is the column's #term[permutation importance]. A column the model leans on costs a lot when scrambled, and a column it only memorized costs nothing, because the memorized patterns are not there in the validation rows.

#utpfig([The same forest, asked twice. Its built-in importance, measured while it was trained, puts all three noise columns in the top eight. Shuffling each column on validation loans puts them twelfth, twenty-second and twenty-sixth, with a drop in AUC of almost nothing.], label: <fig:two-importances>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.5cm, ..logaxis, width: 7.6cm, height: 5.3cm, xmin: 0.3, xmax: 8.7, ymin: 0, ybar: auto, bar-width: 13pt, xtick: (1, 2, 3, 4, 5, 6, 7, 8),
      nextgroupplot(title: [built-in importance (training rows)], ylabel: [importance], ymax: 0.1, ytick: (0, 0.05, 0.1), xticklabels: ([rate], [grade], [dti], [bal.], [n1], [n3], [yrs], [n2]),
        addplot(fill: pale-blue, draw: blue, coords: ((1, 0.085), (2, 0.077), (3, 0.065), (4, 0.056), (7, 0.055))),
        {
          for (x, v) in ((5, 0.056), (6, 0.055), (8, 0.055)) { rectangle((x - 0.27, 0), (x + 0.27, v), fill: pale-red, draw: red) }
        },
      ),
      nextgroupplot(title: [drop in AUC when shuffled (validation rows)], ylabel: [drop in ROC AUC], ymax: 0.035, ytick: (0, 0.01, 0.02, 0.03), xticklabels: ([term], [grade], [rate], [dti], [rent], [n1], [n3], [n2]),
        addplot(fill: pale-teal, draw: teal, coords: ((1, 0.0317), (2, 0.0237), (3, 0.0152), (4, 0.0069), (5, 0.0031))),
        {
          for (x, v) in ((6, 0.0015), (7, 0.0001), (8, 0.0)) { rectangle((x - 0.27, 0), (x + 0.27, calc.max(v, 0.00015)), fill: pale-red, draw: red) }
        },
      ),
    )
  })
]

Shuffling works for any model, uses rows the model did not train on, and is measured in the units of the score you care about. scikit-learn provides it as `sklearn.inspection.permutation_importance`. It has one blind spot of its own: twins hide each other. Scramble `sub_grade` and the forest still has `int_rate` to lean on, so each of the pair looks less important than the two are together. Deal with twins before trusting any importance.

== A selection is an estimate

Run a selection on a slightly different sample and you may get a different answer. To see how different, repeat the forward selection of six columns on five resamples of the training loans, each drawn with replacement as the bootstrap of #chapref(<ch:foundations>) does.

```terminal
times chosen in five resamples: {'sub_grade': 5, 'term_months': 5, 'dti': 5, 'fico_low': 4, 'renter': 3,
 'mort_acc': 3, 'income_verified': 3, 'revol_bal': 1, 'fico_high': 1}
```

Three columns are chosen every time. They are the core, and you can say so with confidence. After that the search is choosing among columns of similar value: `renter`, `mort_acc` and `income_verified` each appear in three resamples out of five. Reporting "the six selected features" as if the list were a fact about lending would overstate what the data supports. Report the stable core, and say that the rest are interchangeable.

== Selection is part of training

Every method above, except the two that ignore the label, learns from the target. That makes selection a fitted step, with the same rule as every other fitted step in this book: it happens inside the pipeline, on training rows only, and is refitted inside every fold. Selecting on all the rows first and validating afterwards is the leak that made pure noise score 80% in #secref(<sec:data-leakage>). When the selection method has settings of its own to tune, such as `k` or `C`, the honest estimate of the whole procedure needs the nested cross-validation of #chapref(<ch:training>).

== Choosing a method

#utptable[
  #tabularx(
    columns: (21%, 22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Method], [Cost], [Sees], [Use it]),
    [Constants and twins], [Almost none], [One column, or pairs], [Always, first],
    [$F$, chi-square, mutual information, AUC alone], [One pass over the data], [Each column alone against the label], [As a first cut when there are hundreds or thousands of columns],
    [Forward or backward selection], [Hundreds to thousands of fits], [Columns in each other's company, through your model], [With tens of columns, when the model is cheap to fit],
    [Recursive elimination], [One fit per column], [The model's weights or importances], [After twins are removed, when a wrapper is too slow],
    [L1 penalty], [One fit per setting], [All columns at once, in a linear model], [As a default for linear and logistic models],
    [Permutation importance], [A few predictions per column], [What a fitted model actually uses, on unseen rows], [To inspect any model, and to prune after training],
  )
]

A workable routine joins them in the order of their cost.

#utpsteps[
  + #term[Remove what is not allowed.] Leaks, identifiers and columns that will not exist at prediction time.
  + #term[Remove what cannot help.] Constants and one of each pair of twins.
  + #term[Cut the long tail cheaply,] if there is one, with a filter inside the pipeline.
  + #term[Let the model choose among the rest,] with an L1 penalty or a short forward selection, and stop when a step gains less than the folds differ.
  + #term[Check the survivors.] Shuffle each one on validation rows, repeat the selection on resamples, and keep what is stable.
  + #term[Ask whether the result makes sense] to someone who knows the domain. A selected column nobody can explain deserves a second look at when it was recorded.
]

#summary[
  - An extra column costs noise, work at prediction time, speed, explanation and monitoring. Selection usually buys the same score from far fewer columns.
  - No method can detect a leak. Decide what the model is allowed to see before selecting anything: the leaked columns scored up to 0.933 alone, against 0.703 for the best honest one.
  - Remove constants and twins first. Then filters score columns one at a time: fast, but blind to redundancy and to columns that help only together.
  - A wrapper lets the model judge subsets. Forward selection found six good columns, then kept going and chose a column of noise. Stop when the gain is smaller than the spread between folds.
  - An L1 penalty selects in one fit per setting and found the same five columns as forward selection.
  - A forest's built-in importance ranked noise fifth, sixth and eighth of 28. Shuffling on validation rows ranked it twelfth, twenty-second and twenty-sixth.
  - A selection is an estimate. Check it on resamples, keep it inside the pipeline, and report the stable core.
]

#exercises[
  In `demo_selection.py`, the table has three noise columns. Raise that to thirty, by changing `(1, 2, 3)` to `range(1, 31)`, and run the script again with `CHECK_BOOK_NUMBERS = False`. How many noise columns does forward selection pick in twelve steps now? How many survive the L1 penalty at `C = 0.01`? Which method would you trust on a table with a thousand candidate columns?
]

#questions[
  + Name three costs of an extra feature other than its effect on the score.
  + A column scores a ROC AUC of 0.93 on its own, far above every other column. What do you check before celebrating, and where do you look?
  + Two columns have a correlation of 0.99. A filter gives both a high score. Why is that not a reason to keep both, and how would you choose between them?
  + In the forward selection, `int_rate` was the second-best column alone but only the ninth to be chosen. Explain.
  + The gain at a forward-selection step is 0.0004 and the folds differ by 0.015. What should you do, and what happened on the loans when the search carried on?
  + Why does a random forest's built-in importance rate a column of random decimals highly, and why does shuffling that column on validation rows not?
  + A colleague selects the twenty best features on the whole table and then cross-validates a model on those twenty. What is wrong, and how is it repaired?
]
