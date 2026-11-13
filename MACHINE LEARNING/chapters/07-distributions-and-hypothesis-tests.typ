#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "07-distributions-and-hypothesis-tests")

#let explore = "/MACHINE LEARNING/all_experiments/book_checks/demo_exploration.py"

= Distributions and Hypothesis Tests <ch:inference>

#chapterguide[#chapref(<ch:foundations>): mean, standard deviation, standard error and the normal curve. #chapref(<ch:eda>): the heart table and the differences found in it.][say what a p-value is and is not; test a difference by shuffling labels, with no formula; name the two ways a test can be wrong; explain why averages are bell-shaped; run a t-test, a chi-square test and an ANOVA by hand; recognise the common distributions; and avoid the three classic ways a p-value misleads.]

#chapref(<ch:eda>) ended with a list of differences. Patients with heart disease reached a top heart rate 21 beats lower than the others. Their cholesterol was 10 mg/dl higher. Men had the disease more than twice as often as women. Each of those numbers came from 734 patients who happened to be in the table. A different 734 would have given different numbers. So before building on a difference, ask the question this chapter is about: #emph[could it be luck?]

== The sceptic's question

A friend flips a coin ten times and gets eight heads. "This coin is bent," she says. A sceptic answers: "Fair coins do that." Who is right?

The sceptic's claim can be checked, because the sceptic's world is fully specified: a fair coin, ten flips. In that world the number of ways to get exactly $k$ heads is $binom(10, k)$, out of $2^10 = 1024$ equally likely sequences. Eight, nine or ten heads account for $45 + 10 + 1 = 56$ of them.

$ P("8 or more heads") = frac(56, 1024) = 0.055. $

A fair coin produces a result this lopsided about one time in eighteen. That is unusual, but not rare enough to convict the coin. Ten flips cannot settle the matter.

That small calculation is a complete #term[hypothesis test], and every test in this chapter has the same four steps.

#utpsteps[
  + #term[State the dull explanation.] Assume nothing interesting is going on: the coin is fair, the two groups are the same, the two columns are unrelated. This is the #term[null hypothesis], the sceptic's world.
  + #term[Choose a number that measures the effect.] Here it is the count of heads. It is called the #term[test statistic].
  + #term[Ask how often the dull explanation would produce a number at least that extreme.] That frequency is the #term[p-value]. Here it is 0.055.
  + #term[Decide.] If the p-value is small, the dull explanation is hard to keep. If it is not, you have learned only that the data cannot rule luck out.
]

#keyidea[
  A p-value is the answer to one question: if nothing were going on, how often would data like mine turn up? A small p-value means the dull explanation fits the data badly. It does not say how large the effect is, how important it is, or how likely your own explanation is to be true.
]

== Shuffle the labels

The coin's sceptic was easy to simulate. What is the sceptic's world for the heart table? It is a world where the diagnosis has nothing to do with the heart rate, so that the label attached to each patient might as well have been dealt at random. That world can be built on a laptop: keep the 734 heart rates where they are, shuffle the 734 labels, and measure the gap between the two groups again. Do it ten thousand times.

#codefrom(explore, "def shuffle_test(values, labels", "return real_gap, gaps, p_value")

```terminal
MaxHR        gap  -21.14  largest shuffled gap  7.45  shuffle p 0.0000
RestingBP    gap    3.71  largest shuffled gap  4.94  shuffle p 0.0061
Cholesterol  gap    9.70  largest shuffled gap 18.20  shuffle p 0.0455
```

Read the three rows as three verdicts of different strength.

/ Highest heart rate.: The real gap is 21.14 beats. In ten thousand shuffles the largest gap that luck produced was 7.45. Not one shuffle came close, so the p-value is below one in ten thousand. Luck is not a serious explanation.
/ Resting blood pressure.: The real gap is 3.71 mm Hg, small, and yet only 61 shuffles in ten thousand matched it. The p-value is 0.0061. The gap is probably real, and it is also tiny, which is a different matter that this chapter returns to.
/ Cholesterol.: The real gap is 9.70 mg/dl, and 455 shuffles matched or beat it: a p-value of 0.0455. About one shuffled world in twenty-two looks like ours. The evidence is thin (#figref(<fig:shuffle>)).

#utpfig([Ten thousand shuffled worlds for cholesterol. Each bar counts the shuffles whose gap between the two group means fell in that band. The real gap, 9.70 mg/dl, is out in the tail but not beyond it: 455 shuffles, most of the shaded bars, were at least that far from zero in either direction.], label: <fig:shuffle>)[
  #canvas({
    axis(width: 12.6cm, height: 5cm, ..logaxis, xlabel: [gap in mean cholesterol after shuffling the labels (mg/dl)], ylabel: [shuffles], ybar: auto, bar-width: 22pt, xmin: -20, xmax: 20, ymin: 0, ymax: 2600, xtick: (-18, -12, -6, 0, 6, 12, 18), ytick: (0, 500, 1000, 1500, 2000, 2500),
      addplot(fill: pale-blue, draw: blue, coords: ((-7.5, 739), (-4.5, 1635), (-1.5, 2253), (1.5, 2385), (4.5, 1666), (7.5, 708))),
      {
        for (x, n) in ((-16.5, 18), (-13.5, 69), (-10.5, 228), (10.5, 236), (13.5, 57), (16.5, 5)) {
          rectangle((x - 1.35, 0), (x + 1.35, n), fill: pale-orange, draw: orange)
        }
        connect((9.7, 0), (9.7, 2350), dash: "dashed", draw: red, line-width: widths.thick)
        connect((-9.7, 0), (-9.7, 2350), dash: "dashed", draw: red, line-width: widths.thick)
        node((9.9, 2400), [real gap 9.70], font: font("script", fill: red), anchor: "west")
        node((-9.9, 2400), [as far the other way], font: font("script", fill: red), anchor: "east")
      },
    )
  })
]

This is a #term[permutation test]. It needs no formula and assumes almost nothing, which makes it the best first test to learn and a sound one to keep using. Its definition of "at least as extreme" counts gaps in both directions, because before looking we had no reason to rule out a gap the other way. That makes it a #term[two-sided] test. A #term[one-sided] test counts one direction only. It halves the p-value, and it is honest only when the direction was fixed before the data was seen.

== The vocabulary, and the threshold

#utptable[
  #tabularx(
    columns: (24%, 1fr, 30%),
    styles: (navy-bold,),
    header: ([Term], [Meaning], [In the cholesterol test]),
    [Null hypothesis $H_0$], [The dull explanation: no difference, no relationship.], [Both groups have the same mean cholesterol],
    [Alternative $H_1$], [What you suspect instead.], [The means differ],
    [Test statistic], [One number that measures the effect in the sample.], [The gap, 9.70 mg/dl],
    [p-value], [How often $H_0$ alone would give a statistic at least this extreme.], [0.0455],
    [Significance level $alpha$], [The threshold chosen #emph[before] looking, below which you will stop believing $H_0$.], [Usually 0.05],
  )
]

When the p-value is below $alpha$ the result is called #term[statistically significant], and $H_0$ is #term[rejected]. When it is not, the correct sentence is that you #emph[fail to reject] $H_0$. You never accept it. Ten flips did not prove the coin fair; they only failed to show it bent. An absence of evidence from a small sample is not evidence of absence.

The usual threshold of 0.05 is a convention, not a law of nature. With it, cholesterol at 0.0455 is "significant" and would not be at 0.0545. Nothing real changes between those two numbers. Report the p-value itself, and treat anything near the threshold as weak evidence either way.

== Two ways to be wrong

A test is an alarm, and an alarm fails in two ways (#chapref(<ch:orientation>) met them in the smoke detector).

#utptable[
  #tabularx(
    columns: (26%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [In truth nothing is going on], [In truth there is an effect]),
    [The test says "significant"], [#strong[Type I error]: a false alarm. Its rate is $alpha$, which you chose.], [Correct. The chance of this is the test's #term[power].],
    [The test says "not significant"], [Correct.], [#strong[Type II error]: a miss. Its rate is written $beta$.],
  )
]

The two errors trade against each other. Lower $alpha$ from 0.05 to 0.001 and false alarms become rare, but real effects are missed more often. The only way to reduce both is more data, because more rows shrink the standard error, and a smaller standard error lets a real gap stand clear of the noise. A study that finds "no significant difference" on forty rows has usually shown only that forty rows were too few.

== The distributions behind the shortcuts

Shuffling ten thousand times is honest but slow, and statisticians worked out long ago what the shuffled histogram will look like without drawing it. Those shortcuts rest on a handful of #term[distributions]: descriptions of which values a quantity takes, and how often. They are worth knowing by sight for a second reason: the shape of a column tells you how to treat it.

#utpfig([Four shapes to know by sight. A binomial count piles up around its expected value. A Poisson count of rare events leans right. The normal curve is symmetric. A log-normal quantity, such as a price or an income, has a long right tail that a logarithm removes.], label: <fig:four-distributions>)[
  #canvas({
    groupplot(group-size: (4, 1), horizontal-sep: 0.55cm, ..logaxis, width: 4.6cm, height: 4cm, ymin: 0, ytick: (),
      nextgroupplot(title: [Binomial], xlabel: [heads in 10 flips], ybar: auto, bar-width: 4.6pt, xmin: -0.8, xmax: 10.8, ymax: 0.27, xtick: (0, 5, 10),
        addplot(fill: pale-blue, draw: blue, coords: ((0, 0.001), (1, 0.0098), (2, 0.0439), (3, 0.1172), (4, 0.2051), (5, 0.2461), (6, 0.2051), (7, 0.1172), (8, 0.0439), (9, 0.0098), (10, 0.001))),
      ),
      nextgroupplot(title: [Poisson], xlabel: [events per hour], ybar: auto, bar-width: 5pt, xmin: -0.8, xmax: 9.8, ymax: 0.25, xtick: (0, 3, 6, 9),
        addplot(fill: pale-orange, draw: orange, coords: ((0, 0.0498), (1, 0.1494), (2, 0.224), (3, 0.224), (4, 0.168), (5, 0.1008), (6, 0.0504), (7, 0.0216), (8, 0.0081), (9, 0.0027))),
      ),
      nextgroupplot(title: [Normal], xlabel: [standard deviations], xmin: -3.4, xmax: 3.4, ymax: 0.44, xtick: (-2, 0, 2),
        addplot(draw: teal, line-width: widths.very-thick, domain: (-3.3, 3.3), samples: 80, x => calc.exp(-calc.pow(x, 2) / 2) / calc.sqrt(2 * calc.pi)),
      ),
      nextgroupplot(title: [Log-normal], xlabel: [value], xmin: 0, xmax: 5.2, ymax: 0.8, xtick: (0, 2, 4),
        addplot(draw: red, line-width: widths.very-thick, domain: (0.04, 5.1), samples: 120, x => calc.exp(-calc.pow(calc.ln(x), 2) / 0.72) / (x * 0.6 * calc.sqrt(2 * calc.pi))),
      ),
    )
  })
]

#utptable[
  #tabularx(
    columns: (16%, 30%, 1fr),
    styles: (navy-bold,),
    header: ([Distribution], [What it describes], [Where you meet it, and what it suggests]),
    [Bernoulli], [One yes or no with chance $p$.], [Every binary target: churned, cancelled, diseased. Its mean is $p$ and its variance is $p(1-p)$, which is where the standard error of a rate comes from.],
    [Binomial], [The number of yeses in $n$ independent tries.], [Heads in ten flips; the number of errors a classifier makes on a test set. It is why accuracy on 184 patients is good to about five points.],
    [Poisson], [The count of events in a fixed stretch of time or space, when events are rare and independent.], [Calls per hour, defects per board, purchases per customer. Its variance equals its mean, so busy periods are noisier.],
    [Uniform], [Every value in a range is equally likely.], [Random numbers, shuffles and random splits are built from it.],
    [Normal], [A symmetric bell set by a mean and a standard deviation.], [Measurement error, and almost any average, as the next section shows. Mean and standard deviation summarize it fully.],
    [Log-normal and power-law], [A long right tail: most values small, a few enormous.], [Prices, incomes, lead times, word counts, followers. A few rows dominate any mean; take logarithms, or use the median and a robust scaler (#secref(<sec:scaling>)).],
  )
]

== Why averages are bell-shaped

Lead times of hotel bookings, the number of days between booking and arrival, are far from bell-shaped. Across the 119,390 bookings of Lab~1 the mean is 104.0 days, the standard deviation 106.9, and the skew 1.35: most bookings are made a few weeks ahead and a few are made two years ahead. Now draw 10 bookings at random and average their lead times. Do that ten thousand times and draw the histogram of the ten thousand averages. Then do it again with 50 bookings at a time.

#utpfig([The central limit theorem on hotel lead times. Single bookings are heavily skewed. Averages of 10 bookings already form a hump, and averages of 50 form a narrow, nearly symmetric bell around the true mean of 104 days.], label: <fig:clt>)[
  #canvas({
    groupplot(group-size: (3, 1), horizontal-sep: 1.1cm, ..logaxis, width: 5.5cm, height: 4.2cm, ymin: 0, xmin: 0, xmax: 300, xtick: (0, 100, 200, 300), ybar: auto, bar-width: 8.2pt,
      nextgroupplot(title: [one booking], xlabel: [lead time (days)], ylabel: [draws of 10,000], ymax: 3000, ytick: (0, 1000, 2000, 3000),
        addplot(fill: pale-orange, draw: orange, coords: ((12.5, 2877), (37.5, 1398), (62.5, 1013), (87.5, 797), (112.5, 635), (137.5, 544), (162.5, 586), (187.5, 472), (212.5, 355), (237.5, 223), (262.5, 235), (287.5, 224))),
      ),
      nextgroupplot(title: [mean of 10 bookings], xlabel: [mean lead time (days)], ymax: 3000, ytick: (0, 1000, 2000, 3000),
        addplot(fill: pale-blue, draw: blue, coords: ((12.5, 20), (37.5, 419), (62.5, 1603), (87.5, 2838), (112.5, 2581), (137.5, 1574), (162.5, 712), (187.5, 195), (212.5, 42), (237.5, 15), (262.5, 1))),
      ),
      nextgroupplot(title: [mean of 50 bookings], xlabel: [mean lead time (days)], ymax: 5400, ytick: (0, 2000, 4000),
        addplot(fill: pale-teal, draw: teal, coords: ((62.5, 182), (87.5, 3919), (112.5, 5027), (137.5, 843), (162.5, 29))),
      ),
    )
  })
]

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Ten thousand samples of], [Spread of the sample means], [$sigma \/ sqrt(n)$], [Skew]),
    [1 booking], [105.71], [106.86], [1.37],
    [10 bookings], [33.93], [33.79], [0.42],
    [50 bookings], [15.13], [15.11], [0.23],
  )
]

Two things happened, and together they are the #term[central limit theorem]. The histogram of averages lost the skew of the original column and moved towards a bell: skew 1.37 for single bookings, 0.42 for means of 10, 0.23 for means of 50. And its spread shrank exactly as the standard error formula of #chapref(<ch:foundations>) predicts, $sigma \/ sqrt(n)$: 106.86 divided by $sqrt(50)$ is 15.11, and the simulation gave 15.13.

#keyidea[
  Averages of many independent values are close to normally distributed, whatever the shape of the values themselves, and their spread is $sigma \/ sqrt(n)$. This is why the normal curve appears everywhere, and why a formula can stand in for ten thousand shuffles: a gap between two means is itself an average.
]

The theorem needs independent rows. Rows that repeat a customer, or follow each other in time, share information, behave like fewer rows than they are, and make every formula in this chapter too confident.

== The t-test: a gap counted in standard errors

If a gap between two means is roughly normal, then its size in standard errors says how surprising it is. That ratio is the #term[t statistic]:

$ t = frac(macron(x)_1 - macron(x)_0, op("SE")), wide op("SE") = sqrt(frac(s_1^2, n_1) + frac(s_0^2, n_0)), $

where $s_1$ and $s_0$ are the standard deviations of the two groups and $n_1$ and $n_0$ their sizes. A $t$ beyond about $plus.minus 2$ corresponds to a p-value below 0.05, and one beyond $plus.minus 3$ to a p-value below 0.003.

#codefrom(explore, "def welch_by_hand(values, labels):", "return gap, standard_error, gap / standard_error")

#workedexample[
  #strong[Highest heart rate.] The gap is $-21.14$ beats and its standard error is 1.745, so $t = -21.14 \/ 1.745 = -12.12$. A gap twelve standard errors from zero has a p-value of $7 times 10^(-31)$. Shuffling could only say "fewer than one in ten thousand"; the formula says how many fewer.

  #strong[Cholesterol.] The gap is 9.70 mg/dl and its standard error is 4.858, so $t = 2.00$ and the p-value is 0.046. The shuffle test said 0.0455. Two quite different procedures agree to three decimals, which is the central limit theorem at work.

  #strong[The same result as an interval.] The gap, give or take 1.96 standard errors, is $9.70 plus.minus 9.52$: from 0.2 to 19.2 mg/dl. The interval just misses zero, exactly as the p-value just dips under 0.05. A 95% interval that excludes zero and a two-sided p-value below 0.05 are the same statement, and the interval is the more useful one, because it shows the plausible sizes of the effect and not only that it differs from zero.
]

This version, which lets the two groups have different spreads, is #term[Welch's t-test], `scipy.stats.ttest_ind(a, b, equal_var=False)`. Older texts distinguish a #term[z-test], for when the population's standard deviation is known, from a t-test, for when it is estimated from the sample. With more than about thirty rows per group the two give nearly the same answer, and the standard deviation is almost never known, so use the t-test.

== Two categories: the chi-square test

A t-test compares means, so it needs a number. To ask whether two #emph[categories] are related, such as sex and heart disease, compare counts. Start from the table of #term[observed] counts, then work out the counts you would #term[expect] if the two columns had nothing to do with each other.

#workedexample[
  Among the 734 training patients, 155 are women and 579 are men, and 328 are healthy and 406 have heart disease. If sex and disease were unrelated, women would be healthy in the same proportion as everyone, so the expected number of healthy women is

  $ frac(155 times 328, 734) = 69.3. $

  The same rule, row total times column total over the grand total, fills every cell.

  #v(6pt)
  #align(center)[#fsize("small")[
  #tabularx(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    header: ([], [Healthy: observed], [Healthy: expected], [Disease: observed], [Disease: expected]),
    [Women], [111], [69.3], [44], [85.7],
    [Men], [217], [258.7], [362], [320.3],
  )
  ]]
  #v(6pt)

  There are 111 healthy women where 69.3 were expected. Each cell contributes its squared surprise, scaled by what was expected:

  $ chi^2 = sum frac(("observed" - "expected")^2, "expected") = 25.15 + 20.32 + 6.73 + 5.44 = 57.64. $

  With unrelated columns this total would be near 1 for a two-by-two table. A value of 57.64 has a p-value of $3 times 10^(-14)$.
]

#codefrom(explore, "def chi_square_by_hand(observed):", "return expected, terms, terms.sum()")

How large $chi^2$ may get by luck depends on the size of the table, through its #term[degrees of freedom]: (rows $- 1$) times (columns $- 1$). The library does the bookkeeping, as `scipy.stats.chi2_contingency(table)`. Run on each category of the heart table against the diagnosis, it ranks them in the same order the rate tables of #chapref(<ch:eda>) suggested.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto),
    align: (left, center, center, center),
    styles: (navy-bold,),
    header: ([Category, against heart disease], [$chi^2$], [Degrees of freedom], [p-value]),
    [Slope of the ST segment], [309.2], [2], [$7 times 10^(-68)$],
    [Chest pain type], [214.3], [3], [$3 times 10^(-46)$],
    [Chest pain during exercise], [176.9], [1], [$2 times 10^(-40)$],
    [Sex], [57.6], [1], [$3 times 10^(-14)$],
    [Fasting blood sugar above 120], [50.2], [1], [$1 times 10^(-12)$],
    [Resting ECG], [9.8], [2], [0.0076],
  )
]

The test trusts its formula only when the expected count in every cell is about five or more. Rare categories break that rule, which is one more reason to merge them or to print their counts.

== More than two groups: ANOVA

Does the highest heart rate differ across the #emph[four] chest pain types? Running a t-test on each of the six pairs would be six chances of a false alarm. #term[Analysis of variance], ANOVA, asks one question instead: are the group means further apart than the scatter inside the groups can explain?

#workedexample[
  The four groups and their mean heart rates are: no chest pain, 403 patients, 128.5; atypical angina, 136 patients, 150.6; non-anginal pain, 155 patients, 141.9; typical angina, 40 patients, 145.8. The mean of all 734 is 136.4.

  / Between the groups.: For each group, take the squared distance of its mean from the overall mean, times its size, and add: 60,466. Divide by the number of groups minus one, 3: #strong[20,155.2].
  / Within the groups.: For each patient, take the squared distance from their own group's mean, and add: 428,671. Divide by the number of patients minus the number of groups, 730: #strong[587.2].

  $ F = frac("spread between the group means", "spread within the groups") = frac(20(,)155.2, 587.2) = 34.32. $

  If chest pain type told us nothing about heart rate, $F$ would be near 1. At 34.32 the p-value is $9 times 10^(-21)$.
]

#codefrom(explore, "def anova_by_hand(groups):", "return between, within, mean_between, mean_within, mean_between / mean_within")

ANOVA says that at least one group differs. It does not say which. For that, look at the group means, as the worked example did: patients without chest pain stand apart, 13 to 22 beats below the other three groups.

With exactly two groups, ANOVA is the t-test in disguise: $F = t^2$. That is worth knowing because scikit-learn's `f_classif`, the score behind the `SelectKBest` of Lab~1, is precisely this $F$ with the target's classes as the groups. For the heart table it gives 145.5 to `MaxHR`, 121.0 to `Oldpeak` and 46.6 to `Age`: a ranking of the number columns by how far apart the two diagnoses sit, compared with the scatter inside each.

== Which test for which question

#utptable[
  #tabularx(
    columns: (34%, 22%, 1fr),
    styles: (navy-bold,),
    header: ([The question], [The test], [In Python]),
    [Do two groups differ in the mean of a number?], [Welch's t-test], [`scipy.stats.ttest_ind(a, b, equal_var=False)`],
    [Do three or more groups differ in a mean?], [One-way ANOVA], [`scipy.stats.f_oneway(a, b, c)`],
    [Are two categories related?], [Chi-square], [`scipy.stats.chi2_contingency(pd.crosstab(a, b))`],
    [Is a rate different from a stated value?], [Binomial test], [`scipy.stats.binomtest(k, n, p)`],
    [Any statistic at all, with no formula to trust?], [Permutation test, or the bootstrap of #chapref(<ch:foundations>)], [A loop, as in `shuffle_test` above],
    [Rank every feature against a class target?], [ANOVA $F$ or chi-square], [`sklearn.feature_selection.f_classif`, `chi2`],
  )
]

Every formula-based test assumes independent rows, and the t-test and ANOVA also lean on the central limit theorem, so they are shakiest for small, skewed groups. When in doubt, shuffle: the permutation test makes the fewest assumptions and usually agrees with the formula when the formula is safe.

== Three ways a p-value misleads

=== It is not the chance that you are wrong

A p-value of 0.0455 does #emph[not] mean a 4.55% chance that cholesterol is unrelated to heart disease. It was computed by #emph[assuming] they are unrelated, so it cannot also be the probability of that assumption. Turning it round needs the base rate, as the medical test of #chapref(<ch:foundations>) did: if most of the ideas you test are false, most of your "significant" results at 0.05 will be false too.

=== Significant is not the same as large

With enough rows, any difference becomes significant. Among Lab~1's 119,390 hotel bookings, those that were cancelled had been booked for 2.562 week nights on average, and those that were kept for 2.464. The gap is a tenth of a night, 0.05 of a standard deviation. Its p-value is $7 times 10^(-18)$.

The arrival's day of the month is better still. Cancelled bookings arrived on day 15.73 on average and kept ones on day 15.84, a gap of 0.013 standard deviations, and the p-value is 0.034: "significant". No hotel should plan around it.

#keyidea[
  A p-value mixes two things: how large the effect is and how many rows you have. Always report the size of the effect beside it, in the column's own units and in standard deviations. On a large table, ask "how big?" and almost never "is it significant?".
]

=== Look often enough and you will find something

Take a table with no signal at all: 100 rows, 1,000 columns of random noise, and labels from coin flips. Test each column against the labels.

```terminal
noise columns with p < 0.05: 43, smallest p 0.0003, below 0.05/1000: 0
```

Forty-three columns are "significant" at 0.05, and the best has a p-value of 0.0003. Nothing is wrong with the test. A threshold of 0.05 is a false alarm one time in twenty by construction, so a thousand tests of nothing should ring about fifty times. This is the mechanism behind the leakage example of #secref(<sec:data-leakage>), where the twenty best noise columns gave a model 80% accuracy on coin flips.

The simplest defence is the #term[Bonferroni correction]: when you run $m$ tests, require $p < alpha \/ m$ of each. Here that is $0.05 \/ 1000 = 0.00005$, and no noise column passes. The stronger defence is the one this book uses everywhere: an idea found by looking at the data is a hypothesis, and it is confirmed only on rows that played no part in finding it. That is what a validation set is.

#pitfall[
  Trying twenty features, six transformations and five models, and reporting the one comparison that came out significant, is the same mistake as testing a thousand noise columns, spread over an afternoon. Decide what you will test before you look, or count everything you tried.
]

== Where machine learning uses tests

- #term[Screening features.] `f_classif` and `chi2` score every feature against the target, and `SelectKBest` keeps the top few. The score is a test statistic, so everything above applies: fit the selector on training rows only, and expect some noise columns to score well (#chapref(<ch:feature-selection>)).
- #term[Comparing two models.] Model A scores 0.857 and model B 0.853. Is A better? Compare them on the same folds and look at the fold-by-fold differences: if their mean is small beside their spread, the models are tied (#chapref(<ch:evaluation>)). Lab~0's three pipelines differed by one point with a spread of four.
- #term[Judging a change in production.] An A/B test gives half the customers the old model and half the new one, and tests the difference in the outcome that matters (#chapref(<ch:serving>)).
- #term[Noticing that the world has moved.] A test that compares this month's incoming data with the training data is an early warning that a model is being asked about customers it never saw (#chapref(<ch:serving>)).

#tryit[
  In `demo_exploration.py`, call `shuffle_test` on `Age` and on `Oldpeak` against the diagnosis, and compare the p-values with `scipy.stats.ttest_ind`. Then cut the training patients down to a random 60 with `train.sample(60, random_state=1)` and repeat the test on cholesterol. What happens to the p-value, and what does that say about the sentence "we found no significant difference"?
]

#chapterrecap[
  - A test grants the sceptic's world, the null hypothesis, and asks how often it would produce data at least as extreme as yours. That frequency is the p-value.
  - Shuffling the labels builds the sceptic's world directly. In ten thousand shuffles no gap in heart rate came near the real 21 beats, while 455 matched the real gap in cholesterol.
  - A false alarm is a Type I error and its rate is $alpha$. A miss is a Type II error. More rows reduce both.
  - Averages are close to normal with spread $sigma \/ sqrt(n)$, whatever the column's own shape. That is why formulas agree with shuffles.
  - $t$ is a gap in standard errors. $chi^2$ adds up $("observed" - "expected")^2 \/ "expected"$ over a table of counts. $F$ compares the spread between group means with the spread within groups, and with two groups $F = t^2$.
  - A p-value is not the chance you are wrong, says nothing about the size of an effect, and stops meaning much when many things were tried. Report the effect size and the interval.
]

#quickcheck[
  + A coin gives 9 heads in 10 flips. In a fair-coin world, 9 or 10 heads have probability $11\/1024$. What is the two-sided p-value, and what would you conclude at $alpha = 0.05$?
  + In the shuffle test for resting blood pressure, 61 of 10,000 shuffles gave a gap at least as large as the real one. State the p-value, and say in one sentence what it does and does not tell you.
  + A study of 30 patients reports "no significant difference" between two treatments. Give two different states of the world that would produce that sentence.
  + Single lead times have a standard deviation of 106.9 days. What spread do you expect for the mean lead time of 400 randomly chosen bookings?
  + In the chi-square example, why is the expected number of women with heart disease $155 times 406 \/ 734$? Compute it.
  + On a table of two million rows, a feature has a p-value of $10^(-40)$ against the target and a gap of 0.01 standard deviations between the classes. Would you expect it to improve a model much? Why?
  + You test 200 candidate features at $alpha = 0.05$, and 14 come out significant. Roughly how many would you expect if none of them mattered? What would you do before trusting the 14?
]
