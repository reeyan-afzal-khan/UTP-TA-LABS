#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "02-python-data-toolkit")

#let toolkit = "/MACHINE LEARNING/all_experiments/book_checks/demo_data_toolkit.py"

= Python for Data: NumPy, pandas and Plots <ch:pydata>

#chapterguide[#chapref(<ch:toolkit>): a working environment. You can write a Python loop, a function and a list.][do arithmetic on whole columns with NumPy; pick rows with a condition; read a file into a pandas table and take its first measurements; summarize by group; join two tables without losing or multiplying rows; choose a chart for a question; and hand a table to a scikit-learn model.]

Open any lab notebook in this course and count the lines. About one line in ten trains a model. The other nine load a table, pick columns, fill gaps, group, join and draw. Those nine are this chapter. It is a tour of the moves the labs use again and again, each shown on the tutor's ten students first and on a real table second, so that when a lab says `groupby` you are reading, not decoding.

#utptable[
  #tabularx(
    columns: (17%, 30%, 1fr),
    styles: (navy-bold,),
    header: ([Library], [What it holds], [What the labs use it for]),
    [NumPy], [A grid of numbers of one type: an #term[array]], [Arithmetic on whole columns at once, distances, random numbers, images],
    [pandas], [A table whose rows and columns have names: a #term[DataFrame]], [Reading files, cleaning, selecting, grouping, joining],
    [Matplotlib], [A figure made of one or more charts], [Every plot in the labs; pandas and seaborn draw through it],
    [scikit-learn], [Models and preparation steps with one shared set of verbs], [Splitting, preparing, fitting, predicting, scoring],
  )
]

Every block of code in this chapter is a piece of one script, `all_experiments/book_checks/demo_data_toolkit.py`. Run it, change a line, and run it again: that is the fastest way to learn these libraries.

== NumPy: one operation, a whole column

A shopkeeper who raises every price by 5% does not think about each price tag in turn. The instruction is one sentence about the whole shelf. A Python list makes you visit every tag in a loop. A NumPy array lets you say the sentence.

A list and an array can hold the same ten marks. The difference shows the moment you compute with them.

#codefrom(toolkit, "# A list holds the marks", "print(\"marks above the mean:\"")

```terminal
list * 2 repeats the list: 20 items
array * 2 doubles each mark: [ 94 100 118 130 136 154 124 104  86  76]
marks above the mean: [ -9.1  -6.1   2.9   8.9  11.9  20.9   5.9  -4.1 -13.1 -18.1]
```

The last line did ten subtractions with no loop in sight. `mark.mean()` is one number, 56.1, and the array subtracted it from every mark. Writing arithmetic on whole arrays is called #term[vectorizing], and it is both shorter and much faster, because the loop still happens but inside compiled code:

#codefrom(toolkit, "# One million numbers", "print(f\"loop {loop_seconds")

On the laptop that printed this book the loop took 0.21 seconds and the array expression 0.003, the same answer about seventy times sooner. Your timings will differ; the gap will not close. When a lab cell seems slow, look for a Python loop over rows first.

=== Making arrays

#codefrom(toolkit, "# Ways to make an array.", "print(\"three random draws:\"")

```terminal
[0. 0. 0.] [1. 1. 1.] [0 2 4 6 8] [0.   0.25 0.5  0.75 1.  ]
three random draws: [ 0.3  -1.04  0.75]
```

`arange(0, 10, 2)` counts from 0 in steps of 2 and stops before 10, like `range`. `linspace(0, 1, 5)` asks for five evenly spaced values and includes both ends. The last two lines matter more than they look. A computer's random numbers come from a formula that starts from a #term[seed], so the same seed gives the same numbers on every machine. Every split, shuffle and starting point in the labs is seeded for that reason. An unseeded result cannot be reproduced, which means it cannot be checked.

=== Shape, rows and columns

The whole study log fits in one array of ten rows and four columns.

#codefrom(toolkit, "# The whole study log as one array", "print(\"shape:\"")

```terminal
shape: (10, 4)  dimensions: 2  type of each number: int64
```

`shape` is the first thing to print when something goes wrong. Most NumPy errors are a shape that is not what you assumed. Positions are written `[row, column]` and count from 0, so student F, the sixth student, is row 5.

#codefrom(toolkit, "# Indexing is [row, column]", "print(\"first three students")

```terminal
student F: [12 13  6 77]
F's mark: 77
everyone's hours: [ 2  4  6  8 10 12 14 16 18 20]
first three students, hours and mark: [[2, 47], [4, 50], [6, 59]]
```

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    header: ([You write], [You get]),
    [`LOG[5]`], [Row 5: one student, all four columns],
    [`LOG[5, 3]`], [Row 5, column 3: one number],
    [`LOG[:, 0]`], [Every row of column 0: one column. A bare colon means "all"],
    [`LOG[:3]`], [Rows 0, 1 and 2. The stop position is left out, as in `range`],
    [`LOG[-1]`], [The last row. Negative positions count from the end],
    [`LOG[:3, [0, 3]]`], [Rows 0 to 2 of columns 0 and 3: a list picks any positions, in any order],
  )
]

=== Masks: asking a question of every row

This is the move to learn by heart. A comparison on an array gives one `True` or `False` per element, called a #term[mask], and a mask placed in the square brackets keeps the rows where it is `True`.

#codefrom(toolkit, "# A condition gives one True or False per row", "print(\"how many passed:\"")

```terminal
mask: [False False False False False  True  True  True  True  True]
marks of those who studied more than 10 hours: [77 62 52 43 38]  mean: 54.4
how many passed: 7  share: 0.7
```

Read the second line as a sentence: #emph[the marks, where the hours exceed ten]. The last line uses a quiet fact: `True` counts as 1 and `False` as 0. So the sum of a mask is how many rows pass the test, and its mean is the share that do. Every accuracy, error rate and class balance in this book is the mean of a mask.

=== Down the rows or across the columns

A summary of a table needs a direction. `axis=0` runs down the rows and leaves one answer per column. `axis=1` runs across the columns and leaves one answer per row.

#utpfig([The direction of a summary. `axis=0` squashes the rows, so ten students become one mean per column. `axis=1` squashes the columns, so four measurements become one number per student.], label: <fig:axis>)[
  #canvas({
    let cellw = 1.2
    let cellh = 0.5
    let values = ((2, 8, 8, 47), (4, 6, 8, 50), (6, 7, 7, 59))
    let heads = ("hours", "lectures", "sleep", "mark")
    for (j, h) in heads.enumerate() {
      node((j * cellw, 0.62), [#h], font: font("script", weight: "bold", fill: navy))
    }
    for (i, row) in values.enumerate() {
      for (j, v) in row.enumerate() {
        node((j * cellw, -i * cellh), [#v], ..hcell, min-width: cellw, min-height: cellh)
      }
    }
    for j in range(4) {
      node((j * cellw, -3 * cellh), [...], ..hcell, min-width: cellw, min-height: cellh, draw: mix(blue, 25%))
    }
    // axis = 0
    connect((-1.05, 0.2), (-1.05, -1.7), ..utparrow)
    node((-1.15, -0.75), [`axis=0`], font: font("script", fill: teal), anchor: "east")
    let means = ("11.0", "8.4", "5.7", "56.1")
    for (j, m) in means.enumerate() {
      node((j * cellw, -4.6 * cellh), [#m], ..hkey, min-width: cellw, min-height: cellh)
    }
    node((1.5 * cellw, -5.75 * cellh), [one mean per column], ..utplabel)
    // axis = 1
    connect((-0.5, 1.1), (4.1, 1.1), ..utparrow, draw: orange, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick, color: orange))
    node((1.8, 1.35), [`axis=1`], font: font("script", fill: orange))
    let sums = ("65", "68", "79")
    for (i, s) in sums.enumerate() {
      node((4.75 * cellw, -i * cellh), [#s], ..hhot, min-width: cellw, min-height: cellh)
    }
    node((4.75 * cellw, -3 * cellh), [...], ..hcell, min-width: cellw, min-height: cellh, draw: mix(orange, 45%))
    node((4.75 * cellw, 0.62), [row sum], font: font("script", weight: "bold", fill: orange))
  })
]

#codefrom(toolkit, "# axis=0 runs down the rows", "print(\"best mark is in row\"")

```terminal
column means: [11.   8.4  5.7 56.1]
best mark is in row 5  rows from lowest to highest mark: [9 8 0 1 7 2 6 3 4 5]
```

`argmax` and `argsort` answer #emph[where], not #emph[what]: the best mark sits in row 5, student F, and the weakest in row 9, student J. A position can then pick the matching row out of another array, which is how a lab turns "the ten highest scores" into "the ten customers who have them".

=== Broadcasting: shapes that stretch

Standardizing a table means subtracting each column's own mean and dividing by its own spread (#secref(<sec:scaling>)). NumPy does all four columns in one line.

#codefrom(toolkit, "# Broadcasting:", "print(\"every column now has mean\"")

```terminal
standardized F: [0.17 1.51 0.15 1.81]
every column now has mean [-0.0, -0.0, -0.0, -0.0] and sd [1.0, 1.0, 0.9999999999999999, 1.0]
```

`LOG` has shape `(10, 4)` and `LOG.mean(axis=0)` has shape `(4,)`. NumPy lines the shapes up from the right, sees that the row of four means fits under every row of the table, and repeats it ten times. That stretching is #term[broadcasting]. Student F reads as 0.17 standard deviations above average for hours and 1.81 above for the mark. The spread printed as 0.9999999999999999 is 1: a computer stores decimals approximately, which is why two decimals are compared with `np.isclose` and never with `==`.

#warning[
  Broadcasting never warns you when shapes happen to fit. Subtract a `(10,)` array from a `(10, 1)` array and you get a `(10, 10)` grid, with no error. This is the classic bug when a target column has been reshaped. Print the shapes of both sides whenever a result looks too big.
]

=== A slice is a window, not a copy

#codefrom(toolkit, "# A slice is a view", "LOG[0, 3] = 47")

```terminal
LOG changed too: 99  the copy did not: 47
```

A slice shares memory with the array it came from, so writing into the slice rewrites the original. NumPy does this to avoid copying large tables. Call `.copy()` whenever you intend to change a piece and keep the whole.

== pandas: a table with names

An array knows positions. It does not know that column 3 is the mark or that row 5 is student F, and it cannot mix words with numbers. A pandas #term[DataFrame] adds the names: every column has a label, every row has a label called the #term[index], and each column keeps its own type.

#codefrom(toolkit, "log = pd.DataFrame(LOG", "print(log.describe()")

```terminal
   hours  lectures  sleep  mark  passed
A      2         8      8    47   False
B      4         6      8    50    True
C      6         7      7    59    True
      hours  lectures  sleep   mark
mean  11.00       8.4   5.70  56.10
std    6.06       3.2   2.11  12.19
min    2.00       3.0   2.00  38.00
max   20.00      13.0   8.00  77.00
```

`log["passed"] = log["mark"] >= 50` is the mask from the last section, now stored as a new column. No loop, and the whole column is filled.

=== The first five commands on any table

Before anything else, a new table gets the same short inspection. Lab~0 runs it on patients, and every later lab runs it on something.

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    header: ([Command], [The question it answers]),
    [`df.shape`], [How many rows and columns are there?],
    [`df.head()`], [What does a row look like? Do the columns hold what their names promise?],
    [`df.info()`], [What type did pandas give each column, and how many cells are filled?],
    [`df.describe()`], [Where do the numbers sit? Is a minimum or a maximum impossible?],
    [`df.isna().sum()`], [How many blanks are in each column?],
    [`df["col"].value_counts()`], [Which values does a category take, and how often? Any misspelled twins?],
  )
]

=== Selecting columns and rows

#codefrom(toolkit, "# One column is a Series", "print(log.loc[\"F\", \"mark\"]")

```terminal
Series DataFrame
   hours  lectures  sleep  mark  passed
F     12        13      6    77    True
G     14        12      5    62    True
H     16        10      4    52    True
77 77 {'A': {'hours': 2, 'mark': 47}, 'J': {'hours': 20, 'mark': 38}}
```

One pair of brackets with a name gives one column, a #term[Series]. A list of names inside the brackets gives a smaller table. A mask inside the brackets gives the rows that pass, exactly as in NumPy. Two conditions are joined with `&` for "and" or `|` for "or", and each one needs its own parentheses.

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    header: ([You write], [You get]),
    [`log["mark"]`], [One column, as a Series],
    [`log[["hours", "mark"]]`], [Two columns, as a table],
    [`log[log["mark"] >= 50]`], [The rows where the condition holds],
    [`log.loc["F", "mark"]`], [By #emph[label]: row F, column mark],
    [`log.iloc[5, 3]`], [By #emph[position]: row 5, column 3],
    [`log.loc["A":"F", ["hours"]]`], [Rows A to F #emph[including F], column hours as a table],
    [`log.query("hours > 10 and mark >= 50")`], [The same filter, written as text],
  )
]

#warning[
  `loc` slices include the last label, so `"A":"F"` is six students, while `iloc` slices stop before the last position, so `0:5` is five. Also, assign through one `loc`, as in `df.loc[mask, "col"] = value`. Chained brackets such as `df[mask]["col"] = value` may write into a temporary copy and change nothing, with only a warning to tell you.
]

=== Sort, and take the top

#codefrom(toolkit, "# Sorting, and the top rows.", "print(log.sort_values(")

```terminal
['F', 'E', 'D'] ['A', 'B']
```

=== Split, apply, combine

"What is the average for each kind of row?" is the most common question asked of a table, and `groupby` answers it in three steps that it runs for you: split the rows into groups, apply a summary to each group, and combine the answers into a new table (#figref(<fig:groupby>)).

#utpfig([Split, apply, combine. `groupby("passed")` sends each student to the group of their own result, the mean is taken inside each group, and the two answers come back as a two-row table.], label: <fig:groupby>)[
  #canvas({
    let w = 0.78
    let h = 0.44
    let row(x, y, name, hrs, style) = {
      node((x, y), [#name], ..style, min-width: w, min-height: h)
      node((x + w, y), [#hrs], ..style, min-width: w, min-height: h)
    }
    node((0.39, 0.55), [all ten students], ..utplabel)
    let all = (("A", 2, 0), ("B", 4, 1), ("C", 6, 1), ("H", 16, 1), ("I", 18, 0), ("J", 20, 0))
    for (i, r) in all.enumerate() {
      row(0, -i * h, r.at(0), r.at(1), if r.at(2) == 1 { hkey } else { hhot })
    }
    node((0.39, -6.3 * h), [(four rows not drawn)], ..utplabel)
    // split
    node((4.2, 0.55), [passed: True], font: font("script", weight: "bold", fill: teal))
    for (i, r) in (("B", 4), ("C", 6), ("H", 16)).enumerate() { row(3.8, -i * h, r.at(0), r.at(1), hkey) }
    node((4.2, -1.75), [passed: False], font: font("script", weight: "bold", fill: orange))
    for (i, r) in (("A", 2), ("I", 18), ("J", 20)).enumerate() { row(3.8, -2.2 - i * h, r.at(0), r.at(1), hhot) }
    connect((1.35, -0.4), (3.3, -0.4), ..utparrow)
    connect((1.35, -1.9), (3.3, -2.6), ..utparrow)
    node((2.3, 0.0), [split], font: font("script", weight: "bold", fill: navy))
    // apply
    node((7.4, -0.44), [mean hours 10.00], name: "m1", ..utpstep, min-width: 2.7)
    node((7.4, -2.64), [mean hours 13.33], name: "m2", ..utpstep, min-width: 2.7)
    connect((5.15, -0.44), "m1.west", ..utparrow)
    connect((5.15, -2.64), "m2.west", ..utparrow)
    node((5.55, 0.0), [apply], font: font("script", weight: "bold", fill: navy))
    // combine
    node((11.3, -1.3), [True], ..hkey, min-width: 1.0, min-height: h)
    node((12.35, -1.3), [10.00], ..hkey, min-width: 1.1, min-height: h)
    node((11.3, -1.3 - h), [False], ..hhot, min-width: 1.0, min-height: h)
    node((12.35, -1.3 - h), [13.33], ..hhot, min-width: 1.1, min-height: h)
    connect("m1.east", (10.7, -1.3), ..utparrow)
    connect("m2.east", (10.7, -1.3 - h), ..utparrow)
    node((9.75, 0.0), [combine], font: font("script", weight: "bold", fill: navy))
  })
]

#codefrom(toolkit, "# Split the rows into groups", "print(by_result)")

```terminal
        hours  lectures  sleep
passed
False   13.33      5.33   4.33
True    10.00      9.71   6.29
```

The table already tells the story the rest of the book keeps returning to. The three students who failed studied #emph[more] hours on average, 13.33 against 10.00, but attended fewer lectures and slept two hours less. One grouped mean, and the idea that "more hours means a better mark" is in trouble.

== The same moves on a real table

Ten rows are for understanding. Here are the same moves on 7,043 customers of a telecom company, the table Labs~1 and~2 use. `Churn` says whether the customer left.

#codefrom(toolkit, "churn = pd.read_csv(", "print(churn[\"Contract\"].value_counts())")

```terminal
(7043, 21)
   tenure        Contract  MonthlyCharges TotalCharges Churn
0       1  Month-to-month           29.85        29.85    No
1      34        One year           56.95       1889.5    No
2       2  Month-to-month           53.85       108.15   Yes
Contract
Month-to-month    3875
Two year          1695
One year          1473
```

`read_csv` guesses a type for each column, and its guesses are worth checking. It reads a ZIP file directly when the archive holds one CSV, which is why the course keeps its large files zipped. Three arguments solve most loading problems: `sep=";"` for files that separate with semicolons, as Lab~1’s bank file does; `encoding="latin-1"` when names with accents fail to load; and `usecols=[...]` to read only the columns you need from a wide file.

=== A column that looks like numbers and is not

#codefrom(toolkit, "# Text that should be a number", "churn[\"left\"] =")

```terminal
cells that are not numbers: 11
```

`TotalCharges` arrived as text because eleven cells hold a blank instead of a number. `pd.to_numeric(..., errors="coerce")` converts what it can and turns the rest into `NaN`, the marker for a missing value, so the problem cells can be counted and inspected instead of crashing the conversion. Lab~1 finds out whose cells they are before deciding how to fill them. The last line of the listing turns the words `Yes` and `No` into 1 and 0, so that a mean of the column is a churn rate.

=== One number per group, then several

#codefrom(toolkit, "# One number per group, then several", "print(summary.round(2))")

```terminal
Contract
Month-to-month    0.427
One year          0.113
Two year          0.028
                customers  churn_rate  median_tenure  mean_monthly
Contract
Month-to-month       3875        0.43           12.0         66.40
One year             1473        0.11           44.0         65.05
Two year             1695        0.03           64.0         60.77
```

Customers who pay month to month left 42.7% of the time, and those on two-year contracts 2.8%. In `agg`, each new column is named on the left and defined on the right as a pair: the column to summarize and the summary to apply. `"size"` counts rows. The second table adds what the first one hides: month-to-month customers are also the newest, with a median of 12 months against 64, so contract type and time with the company arrive tangled together. A grouped table shows association, and #chapref(<ch:eda>) returns to what it cannot show.

=== Two groupings at once

#codefrom(toolkit, "# Two grouping columns at once", "print(table)")

```terminal
InternetService    DSL  Fiber optic     No
Contract
Month-to-month   0.322        0.546  0.189
One year         0.093        0.193  0.025
Two year         0.019        0.072  0.008
```

A #term[pivot table] puts one grouping on the rows and another on the columns. More than half of the month-to-month customers on fiber left, 54.6%, against 0.8% of two-year customers with no internet service. `pd.crosstab(a, b)` builds the same grid when all you want is counts.

=== Bands, and a row compared with its own group

#codefrom(toolkit, "# Cut a number into bands", "print(rate_by_band)")

```terminal
tenure
0-12     0.474
13-24    0.287
25-48    0.204
49-72    0.095
```

`pd.cut` turns a number into labelled bands, so a number can be grouped like a category. Nearly half of first-year customers left, and fewer than one in ten of those who stayed past four years.

`agg` shrinks each group to one row. Sometimes you want the opposite: every row keeps its place and receives its group's answer beside it. That is `transform`.

#codefrom(toolkit, "# transform() gives every row", "print(churn[\"above_contract_mean\"]")

Here each customer is compared with the average charge of their own contract type, and 55.7% pay more than it. The same pattern, with the grouping done on training rows only, is how #chapref(<ch:feature-engineering>) builds features such as "this customer against customers like them".

=== Joining two tables

Real data rarely arrives as one table. Orders sit in one file and customers in another, joined by a customer number. `merge` matches rows on a shared column, the #term[key].

#utpfig([A left join keeps every row of the left table and looks up its match in the right table. When a key appears twice on the right, the left row comes back twice, which is how a join silently creates rows.], label: <fig:merge>)[
  #canvas({
    let w = 1.55
    let h = 0.46
    let cellrow(x, y, a, b, style, w2: 1.0) = {
      node((x, y), [#a], ..style, min-width: w, min-height: h)
      node((x + w / 2 + w2 / 2, y), [#b], ..style, min-width: w2, min-height: h)
    }
    node((0.3, 0.6), [customers (left)], ..utplabel)
    cellrow(0, 0, [Month-to-month], [\$29.85], hcell, w2: 1.1)
    cellrow(0, -h, [One year], [\$56.95], hcell, w2: 1.1)
    cellrow(0, -2 * h, [Month-to-month], [\$53.85], hcell, w2: 1.1)
    node((4.75, 0.6), [lookup (right)], ..utplabel)
    cellrow(4.4, 0, [Month-to-month], [30], hkey, w2: 0.7)
    cellrow(4.4, -h, [One year], [60], hkey, w2: 0.7)
    cellrow(4.4, -2 * h, [Two year], [90], hkey, w2: 0.7)
    node((2.85, -0.46), [#strong[+]], font: font("normal", fill: navy))
    connect((6.35, -0.46), (7.35, -0.46), ..utparrow)
    node((9.3, 0.6), [`merge(on="Contract", how="left")`], ..utplabel)
    let out(y, a, b, c) = {
      node((8.5, y), [#a], ..hcell, min-width: w, min-height: h)
      node((8.5 + w / 2 + 0.55, y), [#b], ..hcell, min-width: 1.1, min-height: h)
      node((8.5 + w / 2 + 1.1 + 0.35, y), [#c], ..hkey, min-width: 0.7, min-height: h)
    }
    out(0, [Month-to-month], [\$29.85], [30])
    out(-h, [One year], [\$56.95], [60])
    out(-2 * h, [Month-to-month], [\$53.85], [30])
    node((9.3, -3.35 * h), [three rows in, three rows out], ..utplabel)
  })
]

#codefrom(toolkit, "# Joining two tables on a shared column", "print(len(churn.merge(bad_lookup")

```terminal
7043 7043 0
10918
```

The first join behaves: 7,043 customers go in, 7,043 come out, and none is left without a match. The second lookup lists `Month-to-month` twice, and every one of the 3,875 month-to-month customers comes back twice, so the table grows to 10,918 rows without a single warning. A model trained on that table would count those customers double.

#note[
  Count the rows before and after every join. If the count changed and you did not expect it to, a key is repeated or missing. `how="left"` keeps every row of the left table, `how="inner"` keeps only rows with a match on both sides, and `validate="many_to_one"` makes pandas raise an error if the right table repeats a key.
]

To stack tables with the same columns, one under another, use `pd.concat([a, b])`. To go the other way and turn several columns into rows, use `melt`, which Lab~0 uses to draw many columns on one chart.

== A chart for each question

A chart is an answer, so choose it by the question. Five charts cover almost everything the labs draw.

#utptable[
  #tabularx(
    columns: (17%, 36%, 1fr),
    styles: (navy-bold,),
    header: ([Chart], [The question it answers], [In pandas]),
    [Histogram], [What shape does one number have? One hump or two? A long tail?], [`df["x"].plot.hist(bins=30)`],
    [Bar chart], [How does one number compare across groups?], [`df.groupby("g")["x"].mean().plot.bar()`],
    [Box plot], [How does the spread differ between groups, and where are the extremes?], [`df.boxplot(column="x", by="g")`],
    [Scatter plot], [How do two numbers move together?], [`df.plot.scatter(x="a", y="b")`],
    [Line chart], [How does a number change along an order, usually time?], [`df.groupby("month")["x"].mean().plot()`],
  )
]

#utpfig([Three questions about the telecom table, each with its chart. Left: monthly charges have two humps, a spike of basic plans near \$20 and a broad group near \$80, which a mean of \$64.76 describes badly. Middle and right: the churn rate falls with a longer contract and with a longer stay.], label: <fig:three-charts>)[
  #canvas({
    groupplot(group-size: (3, 1), horizontal-sep: 1.15cm, ..logaxis, width: 5.45cm, height: 4.3cm, ymin: 0,
      nextgroupplot(title: [histogram], xlabel: [monthly charge (\$)], ylabel: [customers], ybar: auto, bar-width: 7.4pt, xmin: 10, xmax: 130, ymax: 1500, xtick: (20, 60, 100), ytick: (0, 500, 1000, 1500),
        addplot(fill: pale-blue, draw: blue, coords: ((20, 1389), (30, 342), (40, 288), (50, 601), (60, 519), (70, 776), (80, 932), (90, 888), (100, 782), (110, 461), (120, 65))),
      ),
      nextgroupplot(title: [bar chart], xlabel: [contract], ylabel: [churn rate], ybar: auto, bar-width: 16pt, xmin: 0.4, xmax: 3.6, ymax: 0.5, xtick: (1, 2, 3), xticklabels: ([monthly], [1 year], [2 years]), ytick: (0, 0.1, 0.2, 0.3, 0.4, 0.5),
        addplot(fill: pale-orange, draw: orange, coords: ((1, 0.427), (2, 0.113), (3, 0.028))),
      ),
      nextgroupplot(title: [line chart], xlabel: [months with the company], ylabel: [churn rate], xmin: 0.6, xmax: 4.4, ymax: 0.5, xtick: (1, 2, 3, 4), xticklabels: ([0--12], [13--24], [25--48], [49--72]), ytick: (0, 0.1, 0.2, 0.3, 0.4, 0.5),
        addplot(draw: teal, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.474), (2, 0.287), (3, 0.204), (4, 0.095))),
      ),
    )
  })
]

Matplotlib builds a chart in two layers. The #term[figure] is the sheet of paper, and each set of #term[axes] is one chart on it. This is the pattern in every lab:

```python
fig, axes = plt.subplots(1, 2, figsize=(9, 3.4))      # one row, two charts
axes[0].hist(churn["MonthlyCharges"], bins=30)
axes[0].set_xlabel("Monthly charge ($)")
axes[0].set_title("Two kinds of customer")            # say the finding, not the chart type
rate_by_contract.plot.bar(ax=axes[1], rot=0)          # a pandas plot drawn on our axes
plt.tight_layout()
plt.savefig(RESULTS / "charges_and_contracts.png", dpi=160, bbox_inches="tight")
plt.show()
```

The `ax=` argument tells pandas which chart to draw on. A title should state what the reader is meant to see, because "Histogram of MonthlyCharges" repeats the axis label and says nothing. Label both axes with units. Save before `show`, since some setups clear the figure once it is displayed. The seaborn library draws statistical charts in one call each, such as `sns.histplot`, `sns.boxplot` and `sns.heatmap`, and it draws on Matplotlib axes too, so everything above still applies. #chapref(<ch:eda>) uses these charts to interrogate a table.

== From a table to a model

scikit-learn expects two things: a table of features, usually called `X`, with one row per example, and one column of answers, `y`. The model here is the straight line of #chapref(<ch:orientation>), fitted to the first six students.

#codefrom(toolkit, "X = log.loc[\"A\":\"F\", [\"hours\"]]", "print(\"mark expected after 9 hours:\"")

```terminal
slope 3.0 intercept 40.0
mark expected after 9 hours: 67.0
```

Three lines recovered the line $"mark" = 3 times "hours" + 40$ that #chapref(<ch:orientation>) found by trying guesses. Notice the double brackets in `log.loc["A":"F", ["hours"]]`: scikit-learn wants `X` as a table even when it has one column, so that it never has to guess whether six numbers are six rows or six columns.

Every scikit-learn object answers to the same few verbs, which is why the labs can swap one model for another by changing a single line.

#utptable[
  #tabularx(
    columns: (25%, 1fr, 30%),
    header: ([Verb], [What it does], [Who has it]),
    [`fit(X, y)`], [Learns from the training rows: a slope, a mean to scale by, a tree], [Everything],
    [`predict(X)`], [Applies what was learned to give an answer for each row], [Models],
    [`predict_proba(X)`], [Gives a probability for each class instead of one answer], [Most classifiers],
    [`transform(X)`], [Applies what was learned to change the columns: scale, encode, fill], [Preparation steps],
    [`fit_transform(X)`], [`fit` then `transform`, on the same rows. Use it on training rows only], [Preparation steps],
    [`score(X, y)`], [A default quality score: accuracy for classifiers, $R^2$ for regressors], [Models],
  )
]

Whatever `fit` learned is stored in attributes whose names end in an underscore, such as `coef_` and `intercept_` above. That trailing underscore is scikit-learn's way of saying "this came from the data".

#note[
  `fit` is the only verb that learns. Calling it on rows that will later be used for testing is how most leakage happens (#secref(<sec:data-leakage>)), so the question to ask of any line of code is: which rows did `fit` see?
]

== When the code fails

Three habits prevent most wasted hours.

#utpsteps[
  + #term[Read the last line of the error first.] It names the problem. The lines above it only say where you were.
  + #term[Print the shape and the types.] `df.shape`, `df.dtypes` and `arr.shape` settle most surprises faster than rereading the code.
  + #term[Shrink the problem.] Run the line on `df.head(5)`. A table you can read in full tells you what the code actually did.
]

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    header: ([The message], [What it usually means]),
    [`KeyError: 'Mark'`], [No column has that exact name. Check capitals and stray spaces with `df.columns.tolist()`],
    [`could not convert string to float`], [A number column holds text. Find the cells with `pd.to_numeric(..., errors="coerce")`],
    [`operands could not be broadcast`], [Two arrays whose shapes do not line up. Print both shapes],
    [`Found input variables with inconsistent numbers of samples`], [`X` and `y` have different numbers of rows, often after filtering only one of them],
    [`Input contains NaN`], [The model met a blank. Fill it in the pipeline (#chapref(<ch:data>))],
    [`SettingWithCopyWarning`], [You may be writing into a copy. Assign with `df.loc[rows, column] = value`],
  )
]

#summary[
  - An array does arithmetic on every element at once. A loop over rows is the first place to look when code is slow.
  - A comparison makes a mask; a mask in brackets keeps the rows that pass; the mean of a mask is a share.
  - `axis=0` leaves one answer per column and `axis=1` one per row. Broadcasting stretches a row of four numbers under a table of four columns.
  - Inspect every new table the same way: shape, head, info, describe, blanks, value counts.
  - `groupby` splits, applies and combines. `agg` gives one row per group; `transform` gives every row its group's answer.
  - Count rows before and after a join. A repeated key multiplies rows and nothing warns you.
  - Pick the chart by the question, state the finding in the title, and label the axes.
  - In scikit-learn, `fit` learns and everything else applies. Ask which rows `fit` saw.
]

#exercises[
  Run `python all_experiments/book_checks/demo_data_toolkit.py`, then answer these by changing it. Which student has the highest standardized hours? What is the churn rate of customers who pay by electronic check, in the `PaymentMethod` column? Among customers with fiber internet, what share have been with the company more than two years? Each answer is one line.
]

#questions[
  + `mark` holds the ten marks of the study log. What does `(mark < 50).mean()` compute, and what is its value?
  + `LOG` has shape `(10, 4)`. What are the shapes of `LOG.mean(axis=0)` and `LOG.mean(axis=1)`, and what does each number in them describe?
  + Why does `log[log["hours"] > 10 & log["mark"] >= 50]` fail, and how do you repair it?
  + In the telecom table, `groupby("Contract")["left"].mean()` gives three numbers. What would `groupby("Contract")["left"].transform("mean")` give instead, and how many values would it hold?
  + You join 5,000 orders to a table of customers and get 5,230 rows. Name two possible causes and the check you would run first.
  + A histogram of a column shows two separate humps. Why is the mean of that column a poor summary, and what would you do next?
  + Why does scikit-learn want `X` as a table with double brackets even when there is only one feature?
]
