#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "31-the-end-to-end-project")

#let project-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_project.py"
#let project = "/MACHINE LEARNING/all_experiments/lab10_end_to_end_project/booking_project/"

= The End-to-End Project <ch:project>

#chapterguide[Splits, pipelines and leakage from #chapref(<ch:data>)\; metrics and validation from #chapref(<ch:evaluation>)\; tuning and model choice from #chapref(<ch:training>)\; feature engineering and selection from #chapref(<ch:feature-engineering>) and #chapref(<ch:feature-selection>)\; and the models of #chapref(<ch:classification>) and #chapref(<ch:ensembles>).][state a project as a decision made on a date; write a contract for the data and check a file against it; choose a validation scheme that imitates how the model will be used; set baselines; keep an experiment log; choose between finalists by a rule fixed in advance; open the test set once; find where a model's skill lies; write its card; and lay the work out so that one command reproduces it.]

A cook who makes a good dish once has a recipe. A restaurant that serves that dish every night needs a good deal more. It needs suppliers who deliver the same ingredients each week, and a check at the door when they do not. It needs a tasting routine, a recipe card that a new cook can follow, and a record of what was changed and why. None of that is cooking, and all of it decides whether the dish is still good in March.

The chapters so far taught the cooking. This one puts the pieces together into a project that someone else could run, check and take over. It follows one assignment from the first question to a tested model and its paperwork, on 119,390 real hotel bookings that Labs~1 and~2 have already explored. #chapref(<ch:serving>) then puts the model to work and watches it. Every number comes from `all_experiments/book_checks/demo_project.py`.

== The assignment

A hotel group runs a city hotel and a resort hotel. On the first day of each month, its revenue manager looks at the bookings due to arrive that month and asks two questions.

- #strong[How many of them will be cancelled?] The answer decides how many extra rooms can be sold.
- #strong[Which ones?] The riskiest bookings get a call to reconfirm.

One output serves both: for every booking, the chance that it will be cancelled. Added up over a month, the chances are the expected number of cancellations. Sorted, they are the call list.

The two uses need two measures. The call list depends on ranking, which ROC AUC measures (#secref(<sec:classification-metrics>)). The number of extra rooms depends on the chances being right as numbers, so the second measure compares the expected count with the actual one. A model can rank well and still count badly, and this project will show both.

Before any data is opened, the assignment is written down as answers to five questions. They are worth a page in every project, because each later decision is checked against them.

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    styles: (navy-bold,),
    header: ([Question], [Answer for this project]),
    [Who uses the output, and when?], [The revenue manager, on the first day of each month, for the bookings arriving that month.],
    [What is predicted?], [For each booking, whether it will be cancelled (`is_canceled`).],
    [What is done with it?], [The sum of the chances sets the number of extra rooms to sell. The order of the chances sets the call list.],
    [What is known at that moment?], [What was recorded when the booking was made. Nothing that is written at check-in or after a cancellation.],
    [What counts as success?], [Agreed with the hotel before modelling: a ROC AUC of at least 0.80 on months the model has never seen, and a forecast of the number of cancellations within 10% of what happens.],
  )
]

== A contract for the data

The hotel exports its bookings as a file, and it will export a new one every month. The model's work depends on that file keeping its shape: the same columns, the same units, the same spellings. A #term[data contract] writes the shape down, so that a program can check each new file against it and stop before a broken file reaches the model.

This project's contract is a dictionary. A number column has a lowest and a highest allowed value, and a text column has a set of allowed values.

#codefrom(project + "bookings.py", "CONTRACT = {", "\"meal\":")

Thirteen more columns follow in the same style. A second list names the columns that exist in the file and must never reach the model, because they are written after the first of the month: `reservation_status` and its date restate the outcome, `assigned_room_type` is settled at check-in, `booking_changes` keeps counting until the guest arrives or cancels, and `country` is often corrected at the front desk. Lab~1 met the first of these. The contract makes the whole list a rule that code can enforce.

The check itself is short:

#codefrom(project + "bookings.py", "def validate(table, contract=CONTRACT):", "return problems")

Run on the hotel's file, it reports five things.

#utptable[
  #tabularx(
    columns: (32%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Finding], [What it turned out to be], [Decision]),
    [`adults`: 12 values above 10], [Twelve bookings at the resort in autumn 2015, for 20 to 55 adults at a price of zero, all cancelled], [Keep. They are real rows, and the service will refuse such a request when it arrives alone.],
    [`children`: 4 blank cells], [Four bookings where the field was not filled in], [Keep. The pipeline fills blanks, and the service asks for the value.],
    [`Undefined` in two columns], [Two bookings with no `market_segment` and five with no `distribution_channel` recorded], [Keep. Too few to matter, and the encoder ignores a value it does not know.],
    [`adr`: 2 values outside 0 to 1,000], [A price of -6.38 euros, and one of 5,400 euros, more than ten times the next highest], [Keep for training. Ask the hotel what a negative price means.],
  )
]

A first run against real data usually goes like this. Some findings are mistakes in the data and some are mistakes in the contract, and each one ends in a written decision. One more oddity is not in the contract yet: 180 bookings have no guests at all. It goes on the list of questions for the hotel.

The contract earns its keep on the day the export changes. Suppose next month's file arrives with one column missing and with lead times counted in hours instead of days:

```terminal
new problems in a damaged export: ['lead_time: 78,666 values outside 0 to 800',
                                   'deposit_type: column is missing']
```

Without the check, the first of these would not raise any error at all. The model would read a lead time of 1,200 as 1,200 days and return confident nonsense.

#keyidea[
  A model fails loudly when a column is missing and silently when a column changes meaning. A contract turns the silent failures into loud ones. Write it when the project starts, and run it on every file and every request for as long as the model lives.
]

== Three periods, and a validation scheme that imitates use

#block(breakable: false, width: 100%)[
The bookings run from July 2015 to August 2017. They are cut into three periods by date of arrival (#figref(<fig:project-periods>)).

#utpfig([The project's calendar. Models are developed on the first eighteen months and tested once on the next three. The last five months are kept for #chapref(<ch:serving>). Below: the four forward folds. Each trains on everything before a quarter of 2016 and validates on that quarter.], label: <fig:project-periods>)[
  #canvas({
    let x(m) = 0.5 * m                       // months since July 2015
    let bar(from, to, y, fill, draw) = rectangle((x(from), y - 0.2), (x(to), y + 0.2), fill: fill, draw: draw, rounded: 0.7mm)
    bar(0, 18, 3.3, pale-blue, blue)
    bar(18, 21, 3.3, pale-orange, orange)
    bar(21, 26, 3.3, pale-teal, teal)
    node((x(9), 3.3), [development: 78,703 bookings], font: font("script", fill: navy))
    node((x(19.5), 3.85), [test: 12,828], font: font("script", fill: orange))
    node((x(23.5), 3.3), [live: 27,859], font: font("script", fill: navy))
    for (i, start) in ((0, 6), (1, 9), (2, 12), (3, 15)) {
      let y = 2.35 - 0.55 * i
      bar(0, start, y, pale-blue, mix(blue, 65%))
      bar(start, start + 3, y, pale-orange, orange)
      node((-0.25, y), [fold #(i + 1)], font: font("tiny", fill: muted), anchor: "east")
    }
    for (m, label) in ((0, [Jul 2015]), (6, [Jan 2016]), (12, [Jul 2016]), (18, [Jan 2017]), (21, [Apr]), (26, [Sep 2017])) {
      node((x(m), 0.1), label, font: font("tiny", fill: muted))
    }
    node((x(3), 2.35), [train], font: font("tiny", fill: navy))
    node((x(7.5), 2.35), [validate], font: font("tiny", fill: navy))
  })
]
]

The split is by date because the model will be used that way: trained on the past, asked about the months that follow. How much does that choice matter? Score three candidate models twice, once with the random five-fold cross-validation of #secref(<sec:cross-validation>) and once with folds that respect time.

#codefrom(project-demo, "def forward_validation(make_model, bookings, columns, folds):", "return pd.DataFrame(rows)")

#utpfig([The same three models on the same development bookings, validated two ways. Random folds put the forest far ahead. Folds that respect time put all three within 0.003 of each other, and far lower.], label: <fig:random-or-forward>)[
  #canvas({
    axis(width: 11.5cm, height: 5cm, ..logaxis, ylabel: [ROC AUC], xmin: 0.4, xmax: 3.6, ymin: 0.8, ymax: 0.95, ybar: auto, bar-width: 22pt, xtick: (1, 2, 3), xticklabels: ([logistic regression], [random forest], [gradient boosting]), ytick: (0.8, 0.85, 0.9, 0.95), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
      addplot(fill: pale-orange, draw: orange, coords: ((1, 0.869), (2, 0.927), (3, 0.922)), legend: [random folds]),
      addplot(fill: pale-blue, draw: blue, coords: ((1, 0.842), (2, 0.844), (3, 0.841)), legend: [forward folds]),
    )
  })
]

Random folds say that the forest reaches 0.927 and beats the logistic regression by 0.058. Forward folds say that it reaches 0.844 and leads by 0.002 (#figref(<fig:random-or-forward>)). One of these two pictures is wrong, and the reason is in the rows.

In the development period, 27,419 bookings repeat an earlier booking in every column the model uses and in the outcome. They are not typing mistakes. A tour operator books thirty rooms in one go, and when the tour is called off, cancels thirty rooms in one go. In a random split, the rooms of one block land on both sides. A model that can memorize, such as a deep forest, then recognizes the block in the validation fold and is praised for it.

The evidence is one more run. Remove the repeats, which leaves 51,284 rows, and the forest scores 0.838 on random folds: the same as its forward score. Lab~4 met this trap with photographs cut from the same board, and the cure is the same. Rows that belong together must stay on one side of every split. A forward fold does that here, because the rooms of a block arrive on the same day.

#pitfall[
  The validation scheme is part of the specification of a project, as much as the metric is. Ask how the model will meet new data, and split in that way: by time when it predicts the future, by group when rows come in families, at random only when rows are truly separate. A score from the wrong scheme is not a rough estimate of the right one. Here it ranked the models wrongly as well.
]

== Baselines

A model is judged against what could be done without it. Two baselines, on the same four quarters:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Quarter of 2016], [First], [Second], [Third], [Fourth]),
    [Accuracy of "nobody cancels"], [0.693], [0.625], [0.644], [0.618],
    [Accuracy of "non-refundable bookings cancel"], [0.802], [0.779], [0.729], [0.733],
    [ROC AUC of that rule], [0.678], [0.708], [0.619], [0.651],
  )
]

The second baseline is one line of logic taken from the data card: bookings with a non-refundable deposit were cancelled 99.4% of the time. It is right for three bookings in four and costs nothing to run or to explain. Its AUC lies between 0.62 and 0.71, and a model has to beat that by enough to be worth its upkeep.

== Three candidates, judged the honest way

On the columns that Labs~1 and~2 used, the forward folds give this:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Model], [Q1], [Q2], [Q3], [Q4], [Mean AUC], [Brier score]),
    [Logistic regression], [0.829], [0.859], [0.842], [0.837], [0.842], [0.1426],
    [Random forest], [0.819], [0.864], [0.848], [0.844], [0.844], [0.1432],
    [Gradient boosting], [0.814], [0.860], [0.842], [0.847], [0.841], [0.1463],
  )
]

Read the columns before the means. One model moves by as much as 0.046 from one quarter to the next, and the means of the three models lie within 0.003 of each other. The quarters disagree far more than the models do. On this evidence the three are tied, and the Brier score, which measures how good the chances are as numbers (lower is better), slightly prefers the simplest of them.

The same folds show the second measure failing. For the logistic regression, the expected number of cancellations fell short of the actual number in every quarter: by 440, 379, 201 and 894 bookings. The reason is in the data: the share of bookings that cancel was rising through 2016, and a model trained on the past expects the past's rate.

== The experiment log

From here the project is a sequence of ideas, each of which may help or not. An #term[experiment log] gives every idea one row: what was changed, how it was validated, what came out, and a sentence of conclusion. Without it, after a week nobody remembers which combination produced the good number. Five rows from this project's log, each validated on the forward folds:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Columns given to the model], [Count], [Logistic \ regression], [Gradient \ boosting], [Kept?]),
    [1. Those of Labs~1 and~2], [21], [0.8419], [0.8409], [start],
    [2. Plus the month and the weekday of arrival], [23], [0.8407], [0.8236], [no],
    [3. Plus channel, room type, repeat guest, days on the waiting list], [25], [0.8395], [0.8443], [yes],
    [4. Plus the travel agent that made the booking], [26], [0.8565], [0.8544], [yes],
    [Plus three columns written after the first of the month], [24], [0.8841], [0.8812], [never],
  )
]

Three of these rows carry a lesson.

/ Row 2.: Telling the model the month of arrival made gradient boosting clearly worse, 0.8236 against 0.8409. The history is eighteen months long, so the model has seen one July or two. What it learns about "July" is what happened in those particular Julys, and it carries that into a year where it does not hold. A seasonal feature needs several seasons.
/ Row 4.: The travel agent is the best find of the project: over row 3, the logistic regression gains 0.017 and gradient boosting 0.010. It also steadies the logistic regression, whose four quarterly scores now lie between 0.852 and 0.860. Some agents' customers cancel far more often than others'.
/ The last row.: Adding `booking_changes`, `country` and whether the room was changed gives 0.884, the best score in the log. It is also worthless. Those columns do not have their final values on the first of the month, so a model that needs them cannot be run. A log makes this temptation visible, and the contract answers it.

A real log row also records the date, the version of the data and of the code, and the settings. Tools such as MLflow keep such a log automatically and draw charts from it. A spreadsheet or a CSV file does the essential job, and the project's `train.py` appends one line to a file called `runs.csv` every time it runs.

== A small search, and a rule fixed in advance

Gradient boosting has settings worth trying (#secref(<sec:hyperparameter-tuning>)). Eight combinations of four settings, drawn at random from 144, each validated on the forward folds, give mean AUCs from 0.8476 to 0.8585. The best uses a learning rate of 0.1, 31 leaves, at least 50 bookings in a leaf, and 100 rounds. The search gained 0.004 over the settings used so far.

That leaves two finalists, and a choice to make.

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Finalist], [Q1], [Q2], [Q3], [Q4], [Mean AUC], [Spread]),
    [Logistic regression], [0.852], [0.860], [0.859], [0.855], [0.8565], [0.0031],
    [Gradient boosting, tuned], [0.833], [0.874], [0.858], [0.869], [0.8585], [0.0157],
  )
]

The rule for this choice was written down before the search ran, as it was for stopping a forward selection in #chapref(<ch:feature-selection>):

#keyidea[
  The simpler model wins unless the other one beats it by more than its own spread between folds.
]

The gap is 0.002 and the spread of the boosted model is 0.0157. The logistic regression becomes the #term[champion]: the model that will ship. Its saved file is about thirty times smaller, its weights can be read, and its score hardly moves between quarters. The boosted model is not thrown away. It becomes the #term[challenger], and #chapref(<ch:serving>) keeps it running beside the champion to find out whether the rule chose well.

== The test quarter, opened once

Everything so far used the development period. Now the champion is fitted on all of it and asked about January to March 2017, which no decision has touched.

```terminal
test quarter, January to March 2017, the champion (logistic regression):
    {'auc': 0.855, 'brier': 0.1352, 'expected': 4079, 'cancelled': 4281, 'bookings': 12828}
for the record, the challenger (gradient boosting):
    {'auc': 0.874, 'brier': 0.1295, 'expected': 4195, 'cancelled': 4281, 'bookings': 12828}
```

Against the two measures of success: the ROC AUC is 0.855, above the 0.80 that was agreed, and close to the 0.8565 that forward validation promised. The model expected 4,079 cancellations and 4,281 happened, a shortfall of 4.7%, inside the 10% that was agreed.

The second line is uncomfortable. On the test quarter the challenger did better, by 0.019. It is tempting to switch, and switching would be a mistake of method. The rule was fixed in advance so that the test set would be used once, to measure a decision already taken. Choosing by the test quarter would turn it into one more validation fold and leave nothing to measure with. The result is recorded as a question, and the next chapter answers it with new data.

The honest report on the count has two parts as well. The forecast passed on the test quarter, and in the four validation quarters it was short by 11.8%, 9.6%, 7.2% and 17.4%. It missed the 10% mark in two quarters of four, always in the same direction. That goes on the model's card as a known limit, with advice: until the forecast is corrected, sell fewer extra rooms than the model suggests.

== Where the skill is

One score for 12,828 bookings hides how the model does on the bookings that matter. Split the test quarter by deposit type:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Test bookings], [Bookings], [Cancelled], [Predicted], [ROC AUC]),
    [Non-refundable deposit], [1,307], [99.5%], [99.0%], [0.996],
    [No deposit], [11,521], [25.9%], [24.2%], [0.793],
    [All], [12,828], [33.4%], [31.8%], [0.855],
  )
]

Nearly every non-refundable booking is cancelled, the model knows it, and nobody needs a model to say so. On the nine bookings in ten where there is a real question, the AUC is 0.793. The headline of 0.855 mixes an easy group with a hard one. The number to report to the revenue manager is the second, because those are the bookings the call list is for.

Other cuts add detail. Among the booking sources, the model is strongest on bookings through offline travel agents (0.912) and weakest on direct bookings (0.767) and online travel agents (0.801), which are also the largest group, with 6,545 bookings. At the resort hotel it expects 19.0% to cancel where 22.2% do, so the shortfall in the count comes more from the resort than from the city.

The last check takes the chances themselves. Sort the test bookings by predicted chance, cut them into ten groups of equal size, and compare the average prediction in each group with what happened (#figref(<fig:project-calibration>)).

#utpfig([Predicted chance against actual share cancelled, in ten groups of test bookings from the safest to the riskiest. A model whose chances are right as numbers puts every dot on the dashed line. The dots for the safest groups sit above it: bookings the model calls nearly safe are cancelled more often than it says.], label: <fig:project-calibration>)[
  #canvas({
    axis(width: 6.6cm, height: 6.2cm, ..logaxis, xlabel: [mean predicted chance in the group], ylabel: [share actually cancelled], xmin: 0, xmax: 1.03, ymin: 0, ymax: 1.03, xtick: (0, 0.25, 0.5, 0.75, 1), ytick: (0, 0.25, 0.5, 0.75, 1),
      addplot(draw: muted, dash: "dashed", domain: (0, 1), x => x),
      addplot(draw: blue, fill: blue, only-marks: true, mark: "*", mark-size: 2.1pt, coords: ((0.004, 0.018), (0.039, 0.076), (0.079, 0.129), (0.12, 0.147), (0.185, 0.188), (0.259, 0.255), (0.363, 0.331), (0.481, 0.488), (0.662, 0.708), (0.991, 0.999))),
    )
  })
]

From a predicted 18% upwards the dots stay close to the line. Below that the model is too optimistic: the three safest groups are predicted to cancel 0.4%, 3.9% and 7.9% of the time and do so 1.8%, 7.6% and 12.9% of the time. That is where most of the missing cancellations of the count come from.

== The model card

The findings above are worth nothing to the next person unless they travel with the model. A #term[model card] is the page that does that. Lab~2 wrote a first one, and a project's card has more to say:

#utptable[
  #tabularx(
    columns: (24%, 1fr),
    styles: (navy-bold,),
    header: ([Field], [This project's entry]),
    [Task], [The chance that a hotel booking is cancelled, asked on the first day of its month of arrival],
    [Trained on], [78,703 bookings arriving July 2015 to December 2016],
    [Features], [The 26 columns of row 4 of the log],
    [Never use], [`reservation_status`, `reservation_status_date`, `assigned_room_type`, `booking_changes`, `country`],
    [Validation], [Four forward folds by quarter of 2016: mean ROC AUC 0.8565],
    [Test], [January to March 2017: ROC AUC 0.855, expected 4,079 cancellations against 4,281],
    [Known limits], [ROC AUC of 0.793 on bookings without a deposit. Under-forecasts the number of cancellations when the rate is rising. Too optimistic about the safest bookings.],
    [Challenger], [Gradient boosting with the tuned settings: 0.874 on the test quarter, not chosen],
  )
]

== The project as a folder

A notebook is the right place to explore, and the wrong place to keep a project. A notebook's cells can be run in any order, its results depend on what was run before, and nothing in it can be imported by another program. Once the exploring has settled, the code that matters moves into plain files:

```terminal
booking_project/
    bookings.py         the contract, the features and the models: imported by everything below
    train.py            one command: check the file, measure, fit, save the model, its card, a log line
    serve.py            the web service that answers for one booking
    app.py              a one-page app for the front desk
    monitor.py          drift and monthly reports, for after the model ships
    test_project.py     seven checks that must pass before a new version ships
    requirements.txt    the exact package versions
    Dockerfile          a recipe for a container that runs serve.py
```

Four habits are built into that layout.

/ One place for what must agree.: Training and serving both import `bookings.py`. The features of a booking are computed by the same function whether the booking is one of 78,703 in training or one alone in a request. When the two are written twice, sooner or later they differ, and the model in service is then fed something it was never trained on.
/ One command.: `python train.py` goes from the hotel's file to a saved model, with nothing done by hand in between. What needs a person to remember a step will one day be done wrongly.
/ A record of every run.: The script reports what it does through Python's `logging` module, with a time and a level on each line, and appends its result to the run log. A warning is a message that the run went on and someone should look.
/ Exact versions.: `requirements.txt` names the versions the model was trained with. A model saved by one version of scikit-learn is not guaranteed to load in another.

This is what one run prints, with the time at the start of each line left out:

```terminal
WARNING contract: adults: 12 values outside 0 to 10
WARNING contract: children: 4 blank cells
WARNING contract: market_segment: unexpected values ['Undefined']
WARNING contract: distribution_channel: unexpected values ['Undefined']
WARNING contract: adr: 2 values outside 0 to 1000
INFO read 119,390 bookings, 5 contract warnings
INFO gate: AUC 0.8549 on 14,517 bookings; expected 4,585 cancellations, 5,548 happened
INFO wrote booking_cancellation.joblib, booking_cancellation_card.json and a line in runs.csv
```

The five warnings are the findings of the contract check, repeated on every run so that they are not forgotten. The line that starts with `gate` is the fourth forward fold: before the final fit, the script holds back the most recent quarter, fits on the rest and measures. #chapref(<ch:serving>) uses that number to decide whether a retrained model may replace the one in service. Lab~10 builds this folder and runs every file in it.

== What "done" means

#utpsteps[
  + #term[The assignment is written down:] who uses the output, when, for what, and what counts as success.
  + #term[The data has a contract,] and the file passes it or every exception has a written decision.
  + #term[The validation scheme imitates use,] and a baseline was scored with it.
  + #term[Every experiment is in the log,] including the ones that failed and the one that was not allowed.
  + #term[The choice between finalists followed a rule] that was fixed before the scores were seen.
  + #term[The test set was opened once,] and the result is reported next to what was agreed.
  + #term[The model's skill is known by group,] with its weakest group named.
  + #term[The model has a card,] and the card lists what must never be used.
  + #term[One command reproduces the model] from the raw file, with pinned versions and a log.
]

#tryit[
  In `demo_project.py`, set `CHECK_BOOK_NUMBERS = False`, then change the adults entry of `CONTRACT` in `booking_project/bookings.py` to `(1, 10)`, so that a booking needs at least one adult. How many bookings break the contract now? Would you repair them, remove them, or ask the hotel? Put the entry back afterwards.
]

#block(breakable: false, width: 100%, chapterrecap[
  - A project starts as a dated decision: each month, how many bookings will cancel, and which.
  - A data contract turned a missing column and a change of units into errors that stop the run.
  - The validation scheme must imitate use. Random folds scored a forest at 0.927, forward folds at 0.844: blocks of identical bookings sat on both sides of the random splits.
  - Baselines set the bar: one rule from the data card reached an AUC between 0.62 and 0.71.
  - An experiment log keeps every idea with its result. The month of arrival hurt, the travel agent helped by 0.015, and the best score in the log used columns that are not allowed.
  - The finalists were 0.002 apart with a spread of 0.016, so a rule fixed in advance chose the simpler one. The test quarter was opened once: AUC 0.855, and 4,079 expected cancellations against 4,281.
  - The headline hides the groups: 0.996 on non-refundable bookings and 0.793 on the rest.
  - The model ships with a card, and the project is a folder in which one command rebuilds everything.
])

#quickcheck[
  + Write the five framing questions for a model that predicts which library books will be returned late.
  + Prices arrive in cents, not euros. Which contract entry catches it, and what happens without one?
  + Random folds gave a forest 0.927 and forward folds gave it 0.844. Explain where the difference came from, and name the earlier lab that met the same problem.
  + Adding the month of arrival made a model worse under forward validation. Why can a feature that is truly related to the outcome still hurt?
  + The best row of the experiment log was rejected. On what grounds, and which document settled it?
  + Two finalists differ by 0.002 and one of them varies by 0.016 between folds. What does the rule of this chapter choose, and why was the rule written before the search?
  + After the test, the model that was not chosen turns out to score higher. Why is switching now a mistake, and what should be done with the observation?
  + A model has a ROC AUC of 0.855 overall, 0.996 on one group and 0.793 on the other. Which number do you report to the person who will use the call list, and why?
  + Name three things that a project kept as plain files can do and a notebook cannot.
]
