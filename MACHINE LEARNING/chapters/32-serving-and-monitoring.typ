#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "32-serving-and-monitoring")

#let serving-demo = "/MACHINE LEARNING/all_experiments/book_checks/demo_serving.py"
#let project = "/MACHINE LEARNING/all_experiments/lab10_end_to_end_project/booking_project/"

= Serving and Monitoring <ch:serving>

#chapterguide[The project of #chapref(<ch:project>), its contract, its champion and its challenger\; ROC AUC, the Brier score and the kinds of shift named in #chapref(<ch:evaluation>).][choose between scoring in batches and answering one request at a time; wrap a model in a small web service that checks every request against the contract; time it and size it; log what it answers; say which problems can be seen on the first day and which only when the outcomes arrive; compute a population stability index by hand and read it against the right reference; run a challenger in the shadow; and decide, by rules written in advance, when to retrain, when to switch models and when to roll back.]

A bridge is not finished on the day it opens. For as long as it stands, engineers measure how far it sways, how its cracks grow and how the traffic on it differs from the traffic it was designed for. Most of what they learn could not have been learned before the opening, because it depends on what the world does to the bridge.

A model is the same. #chapref(<ch:project>) ended with a champion that passed its test quarter. This chapter puts it to work and then follows it through the next five months of real bookings, April to August 2017, which no decision has touched. Some of what happens can be seen on the day each month begins, and some only when the month's outcomes are in. Every number comes from `all_experiments/book_checks/demo_serving.py`.

== Two ways to deliver a prediction

The hotel needs the model's answers in two different ways.

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [In a batch], [One request at a time]),
    [When], [On a schedule: the first day of each month], [Whenever a request arrives],
    [How many], [Every booking of the month in one call], [One booking],
    [What matters], [A complete table, ready on time], [An answer within a fraction of a second, every time],
    [Here], [The forecast of cancellations and the call list], [The front desk and the booking website, asking about a new booking],
    [Fails as], [A late or missing table], [Errors, or slow answers while a guest waits],
  )
]

The two cost very different amounts. Timings depend on the computer, so the script checks only their order. On the computer that produced this book, scoring one booking on its own took about 4.5 milliseconds, and a booking scored inside a batch of 12,828 took about 2 microseconds. Most of the cost of a single answer is the fixed work around it: building a table of one row and passing it through every step of the pipeline. A batch pays that once.

The saved files are small: 12 KB for the champion and 377 KB for the challenger, which keeps its hundred trees. Neither number is a reason to choose one model over the other here, but both matter on a phone or for a service that loads hundreds of models.

#keyidea[
  Prefer a batch whenever the decision is made on a schedule. It is simpler to build, to test and to repeat, and when something goes wrong there is a table to inspect. Build a service only for questions that arrive one at a time and need their answer at once.
]

== A service around the model

A #term[web service] is a program that waits for requests over the network and answers each one. The booking service answers two kinds of request. The address `/health` says whether the service is running and which model it holds. The address `/predict` takes one booking, written as #term[JSON] (a plain-text format for named values that every programming language can read and write), and returns its chance of cancelling.

The whole service is one function that builds a #term[Flask] application, Flask being a small Python library for web services:

#codefrom(project + "serve.py", "def create_app(model, version, log_path=None):", "return app")

Read it as four promises.

- #strong[The model is loaded once,] when the service starts, and not once per request.
- #strong[Every request is checked against the contract] of #chapref(<ch:project>) before the model sees it. A booking that breaks it is refused with the status code 400, which means "the request was wrong", and with a list of what was wrong.
- #strong[Every answer names the model version] that produced it, so that a strange answer can be traced to the model that gave it.
- #strong[Every answer is written to a log,] one line per request: the time, the version, the booking, the answer and how long it took.

#block(breakable: false, width: 100%)[
Here is a booking from the test quarter, as the service receives it, and the service's answers to four requests:

```terminal
{"hotel": "Resort Hotel", "lead_time": 74, "stays_in_weekend_nights": 1, "stays_in_week_nights": 0,
 "adults": 2, "children": 0.0, "babies": 0, "meal": "BB", "market_segment": "Online TA", ...}

GET /health            -> 200 {'model_version': '2017-01-01', 'status': 'ok'}
POST /predict (good)   -> 200 {'cancel_probability': 0.2233, 'model_version': '2017-01-01'}
POST /predict (broken) -> 400 the booking breaks the contract (4 problems listed)
POST /predict (text)   -> 400 {'error': 'send one booking as a JSON object'}
```
]

The broken request is the same booking with four mistakes in it, and the answer says exactly what they are:

```terminal
lead_time: -3 is outside 0 to 800
deposit_type: 'Maybe' is not one of ['No Deposit', 'Non Refund', 'Refundable']
adr: missing
unknown fields: ['nights']
```

Compare that with what would happen without the check. A missing price would be filled with the training median and a misspelled deposit type ignored by the encoder, and the service would return a confident probability for a booking that does not exist.

#pitfall[
  A model in service must never compute its features differently from the model in training. When the two are written separately, they drift apart one small change at a time: a column filled with 0 in one place and with the median in the other, a category spelled two ways. This is called #term[training-serving skew], and its symptom is a model that tests well and serves badly. The cure is the one built into the project: training and serving import the same `bookings.py`, and a test checks that a booking gets the same features alone as inside a table of thousands.
]

=== Testing a service without starting it

Flask can hand a test program a client that sends requests straight to the application, with no server and no network. The four answers above were produced that way, and so are the service's checks in `test_project.py`. Whatever a service promises (the status codes, the error messages, the version in every answer) belongs in tests that run before every release.

=== A page for people

The front desk does not write JSON. For people, the project has a one-page app built with #term[Streamlit], a library that turns a Python script into a web page with fields, buttons and results. Its fields offer only values that the contract allows, so a receptionist cannot type a booking the model would refuse. Streamlit can also run such a page without a browser, which is how it was checked: with its starting values the page shows a 46% chance of cancelling, and choosing a non-refundable deposit raises it to 99%.

=== Packaging: exact versions and a container

A service has to run on a computer other than the one it was built on. Two files in the project make that repeatable. `requirements.txt` names the exact version of every package, because a model saved by one version of scikit-learn is not guaranteed to load in another. The `Dockerfile` is a recipe for a #term[container]: a sealed package holding a small operating system, the right Python, the pinned packages, the code and the model, which runs the same way on a laptop and on a server.

#codefrom(project + "Dockerfile", "# 1. Start from", "CMD", lang: "dockerfile")

Building and running it needs Docker, which is installed separately. The recipe is worth reading even without it: every step that a person would otherwise do by hand, and might do differently next time, is written down.

== What can be watched, and when

Once the model is in service, the evidence about it arrives in two waves. Some arrives with the requests themselves. The rest waits for the outcomes: a booking's fate is known only when its arrival date has passed, up to a month after the forecast was made.

#utptable[
  #tabularx(
    columns: (35%, 21%, 1fr),
    styles: (navy-bold,),
    header: ([Signal], [Available], [What it catches]),
    [Requests refused by the contract, errors, response times], [At once], [A broken sender, an outage, a slow service],
    [Share of categories the model never saw, such as new travel agents], [At once], [New partners or products the model knows nothing about],
    [Drift of each input column], [When the month is scored], [A different mix of customers],
    [Drift of the predicted chance], [When the month is scored], [Any of the above that changes what the model says],
    [Expected against actual number of cancellations], [After the month], [A forecast that is off],
    [ROC AUC and Brier score, overall and by group], [After the month], [A model that ranks or counts worse than it did],
  )
]

The first four rows need no outcomes, and so they are the early warning. They can only say that something has changed, though. Whether the change matters is a question for the last two rows.

== Measuring drift: the population stability index

To say whether a column has changed, compare its distribution now with its distribution in a reference period. The #term[population stability index], or PSI, puts that comparison in one number. Cut the column into bins: its categories, or, for a number column, ten bins that each hold a tenth of the reference values. If $p_k$ is the share of the reference rows in bin $k$ and $q_k$ the share of the current rows, then

$ "PSI" = sum_k (q_k - p_k) ln(q_k / p_k). $

#workedexample[
  The deposit type, with the development period as the reference and August 2017 as the current month:

  #align(center, table(
    columns: 4, align: (left, center, center, center), stroke: none, inset: (x: 8pt, y: 3pt),
    table.hline(stroke: 0.5pt + navy),
    [*Deposit*], [*Then*, $p_k$], [*Now*, $q_k$], [$(q_k - p_k) ln(q_k / p_k)$],
    table.hline(stroke: 0.4pt + navy),
    [No Deposit], [0.8654], [0.9854], [0.0156],
    [Non Refund], [0.1329], [0.0140], [0.2675],
    [Refundable], [0.0017], [0.0006], [0.0011],
    table.hline(stroke: 0.5pt + navy),
  ))

  The index is $0.0156 + 0.2675 + 0.0011 = 0.28$. Nearly all of it comes from one bin: non-refundable bookings fell from 13.3% of the reference to 1.4% of August. Every term is zero or positive, because $q_k - p_k$ and $ln(q_k / p_k)$ always have the same sign, so a bin adds to the index whether it grows or shrinks.
]

The project computes the index with this function, which handles both kinds of column:

#codefrom(project + "monitor.py", "def psi(reference, current, bins=10):", "return float(((now - then)")

A common rule of thumb, which comes from credit scoring, reads the index in three bands: below 0.1 the column has hardly moved, from 0.1 to 0.25 it is worth watching, and above 0.25 it has moved enough to investigate. The thresholds are conventions, not laws, and the next sections show why the reference period matters as much as the threshold.

== Five months in service

The champion was trained on bookings arriving before 2017 and then left as it was: #term[frozen]. Here is its record for the five months that followed. The first five numeric columns could be seen on the first day of each month. The last four arrived only after it.

#utptable[
  #tabularx(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center, center, center, center, center),
    header: ([Month], [New \ agents], [PSI \ lead time], [PSI \ segment], [PSI \ deposit], [PSI \ chance], [Expected], [Cancelled], [AUC], [Brier]),
    [April], [5.7%], [0.21], [0.07], [0.00], [0.09], [2,313], [2,463], [0.863], [0.1462],
    [May], [5.4%], [0.16], [0.07], [0.00], [0.06], [2,542], [2,762], [0.854], [0.1499],
    [June], [5.9%], [0.23], [0.07], [0.01], [0.05], [2,281], [2,439], [0.834], [0.1601],
    [July], [5.6%], [*0.31*], [*0.35*], [0.16], [0.20], [1,824], [1,984], [0.779], [0.1813],
    [August], [4.1%], [0.23], [*0.43*], [*0.28*], [*0.34*], [1,565], [1,816], [0.808], [0.1716],
  )
]

#utpfig([Left: four drift signals of the frozen champion, each against the development period, with the investigation threshold of 0.25 dashed. Right: the champion's ROC AUC month by month, frozen and retrained on the first day of each month, and the same for the challenger.], label: <fig:five-months>)[
  #canvas({
    groupplot(group-size: (2, 1), horizontal-sep: 1.6cm, ..logaxis, width: 7.2cm, height: 5.4cm, xmin: 0.7, xmax: 5.3, xtick: (1, 2, 3, 4, 5), xticklabels: ([Apr], [May], [Jun], [Jul], [Aug]),
      nextgroupplot(title: [drift (PSI)], ymin: 0, ymax: 0.48, ytick: (0, 0.1, 0.2, 0.3, 0.4), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.97), anchor: "north-west"),
        addplot(draw: muted, dash: "dashed", domain: (0.7, 5.3), x => 0.25),
        addplot(draw: blue, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.21), (2, 0.16), (3, 0.23), (4, 0.31), (5, 0.23)), legend: [lead time]),
        addplot(draw: orange, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.07), (2, 0.07), (3, 0.07), (4, 0.35), (5, 0.43)), legend: [market segment]),
        addplot(draw: teal, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.0), (2, 0.0), (3, 0.01), (4, 0.16), (5, 0.28)), legend: [deposit type]),
        addplot(draw: red, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.09), (2, 0.06), (3, 0.05), (4, 0.2), (5, 0.34)), legend: [predicted chance]),
      ),
      nextgroupplot(title: [ROC AUC once the outcomes are in], ymin: 0.76, ymax: 0.885, ytick: (0.78, 0.80, 0.82, 0.84, 0.86, 0.88), legend-style: logaxis.at("legend-style", default: (:)) + (at: (0.03, 0.03), anchor: "south-west"),
        addplot(draw: blue, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.863), (2, 0.854), (3, 0.834), (4, 0.779), (5, 0.808)), legend: [champion, frozen]),
        addplot(draw: blue, dash: "dashed", mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.868), (2, 0.859), (3, 0.839), (4, 0.797), (5, 0.819)), legend: [champion, retrained]),
        addplot(draw: orange, mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.87), (2, 0.862), (3, 0.84), (4, 0.803), (5, 0.814)), legend: [challenger, frozen]),
        addplot(draw: orange, dash: "dashed", mark: "*", mark-size: 1.6pt, line-width: widths.thick, coords: ((1, 0.876), (2, 0.867), (3, 0.85), (4, 0.824), (5, 0.834)), legend: [challenger, retrained]),
      ),
    )
  })
]

Read the months in order, as the revenue manager would have (#figref(<fig:five-months>)).

/ April to June.: The model kept its promise on ranking, with AUCs of 0.863, 0.854 and 0.834, and it under-forecast every month, by 150, 220 and 158 cancellations (6.1%, 8.0% and 6.5%), as its card warned. Between 5% and 6% of the bookings came through a travel agent the model had never seen. The lead time sat in the "watch" band all spring.
/ July.: Two alarms: the lead time and, above all, the market segment. The AUC fell to 0.779, and the forecast was 160 cancellations short (8.1%).
/ August.: Three alarms, including the drift of the model's own output. The AUC recovered a little, to 0.808, and the forecast was 251 short (13.8%): outside the 10% agreed with the hotel.

The alarms of July and August rang in the months where the model did worst. It is tempting to conclude that the alarms work. The next section shows that they rang for a reason that had nothing to do with the model, and that the model did worse for a reason no alarm could see.

== An alarm is a question

What moved in July and August? The mix of bookings, compared with the development period and with the same months a year earlier:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    styles: (navy-bold,),
    header: ([Arrivals in], [Non-refundable], [Online agents], [Groups], [Median lead time], [Median price]),
    [Development period], [13.3%], [43.0%], [17.7%], [65 days], [89.0 euros],
    [July 2016], [6.1%], [59.6%], [6.2%], [118 days], [115.3 euros],
    [August 2016], [5.2%], [66.7%], [4.7%], [116 days], [131.4 euros],
    [July 2017], [3.1%], [65.6%], [4.6%], [148 days], [132.5 euros],
    [August 2017], [1.4%], [66.0%], [3.5%], [128 days], [155.0 euros],
  )
]

Summer at these hotels looks like this every year. Groups and non-refundable deals belong to the rest of the year, while in summer two bookings in three come through online agents, guests book months ahead, and prices rise. Measured against the same month of 2016 instead of the whole development period, the alarms fall silent:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([PSI of], [July, against \ development], [July, against \ July 2016], [August, against \ development], [August, against \ August 2016]),
    [Market segment], [0.35], [0.03], [0.43], [0.01],
    [Deposit type], [0.16], [0.03], [0.28], [0.05],
    [Lead time], [0.31], [0.11], [0.23], [0.03],
    [Price per night], [1.51], [0.24], [2.04], [0.20],
  )
]

The segment's index drops from 0.35 to 0.03 in July and from 0.43 to 0.01 in August, and the deposit type's from 0.16 and 0.28 to 0.03 and 0.05. What still moves is easy to explain: guests booked further ahead than a year earlier, and the median price was 14.9% higher in July and 18.0% higher in August. For a seasonal business, the right reference is the same season.

So the drift alarms were about the calendar. Yet the model did do worse in July 2017. Compare the two summers once more, scoring each month with a model trained on every booking before it, so that both years are judged alike:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Arrivals in], [ROC AUC], [Bookings without a deposit], [Of those, cancelled], [ROC AUC on those]),
    [July 2016], [0.857], [93.9%], [28.5%], [0.826],
    [August 2016], [0.846], [94.8%], [32.7%], [0.823],
    [July 2017], [0.797], [96.7%], [35.3%], [0.780],
    [August 2017], [0.819], [98.5%], [35.9%], [0.812],
  )
]

Two different things happened, and they need to be told apart.

- #strong[The easy cases disappeared.] Non-refundable bookings are almost certain to cancel, and the model ranks them at the top without effort. In summer 2017 they nearly vanished, so the overall AUC lost the easy points they used to contribute. That part of the fall says nothing about the model.
- #strong[The guests changed.] Among bookings without a deposit, the share that cancelled rose from 28.5% in July 2016 to 35.3% in July 2017, and the model's AUC on those bookings alone fell from 0.826 to 0.780. Something in how these guests behaved had changed, and the model, which learned from earlier years, did not know it.

#keyidea[
  Drift in the inputs can be seen on the first day, and it may be harmless: here it was the summer. A change in how the outcome depends on the inputs, which #chapref(<ch:evaluation>) called concept drift, can be seen only when the outcomes arrive. Watch both, compare like with like, and treat every alarm as a question to answer before acting.
]

== Champion and challenger

#chapref(<ch:project>) chose the logistic regression by a rule fixed in advance, and then saw the gradient boosting challenger do better on the test quarter. It did not switch then, because the test quarter had to stay a measurement. It set up a #term[shadow deployment] instead: the challenger scores every booking beside the champion, its answers are logged, and nobody acts on them.

The rule for promotion was written when the shadow began: #emph[the challenger replaces the champion if it has the higher AUC in each of three consecutive months]. Five months of new evidence:

#utptable[
  #tabularx(
    columns: (1fr, auto, auto, auto, auto, auto),
    align: (left, center, center, center, center, center),
    header: ([ROC AUC, both models frozen], [April], [May], [June], [July], [August]),
    [Champion: logistic regression], [0.863], [0.854], [0.834], [0.779], [0.808],
    [Challenger: gradient boosting], [0.870], [0.862], [0.840], [0.803], [0.814],
  )
]

The challenger led in every month, by between 0.006 and 0.024, with its largest lead in July, the hardest month. One quarter could not settle the question in #chapref(<ch:project>). Five months, all pointing the same way, do. By the rule, the challenger is promoted at the end of June, and the logistic regression stays on file, ready to come back.

One caution remains. The AUC judges the order of all the bookings, while the call list uses only the top few hundred of them. Lab~10 measures the two models on the call list itself, and the answer there is different: a reminder to check a model on the measure that each of its uses depends on.

#pitfall[
  Promoting a model because it won the test quarter, or because it won the month just ended, chooses by luck. Write the rule for promotion before the shadow begins, use new data only, and keep the old model where one command can restore it.
]

== Retraining

A frozen model learns nothing from the bookings that arrive after it. The alternative is to retrain on a schedule. Here, on the first day of each month, `train.py` fits a new model on every booking that has arrived by then, which takes a few seconds.

A new model is not trusted because it is new. Before the fit on all the data, the script holds back the latest complete quarter, fits on the rest and scores the held-back quarter: the #term[gate] of #chapref(<ch:project>). A retrained model replaces the one in service only if its gate AUC is at least 0.80, the floor agreed with the hotel, and the new file passed the contract check. The five retrained champions had gate AUCs of 0.8553, 0.8603, 0.8593, 0.8535 and 0.8393, so all five passed.

Four policies, scored on the same five months. "Months ahead" counts the months in which a policy beat the frozen champion, and "expected" is the number of cancellations it forecast in total, against 11,464 that happened.

#utptable[
  #tabularx(
    columns: (34%, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Policy], [Mean AUC], [Months ahead], [Expected], [Short by]),
    [Champion, frozen], [0.827], [---], [10,526], [8.2%],
    [Champion, retrained monthly], [0.837], [5 of 5], [10,876], [5.1%],
    [Challenger, frozen], [0.838], [5 of 5], [10,655], [7.1%],
    [Challenger, retrained monthly], [0.850], [5 of 5], [10,949], [4.5%],
  )
]

Retraining raised the AUC of both models in every one of the five months. On average it lifted the champion from 0.827 to 0.837 and the challenger from 0.838 to 0.850, and it cut the champion's shortfall from 8.2% to 5.1%. Switching to the challenger helped by about as much again, and the two gains added up. Even the best policy expected 4.5% too few cancellations, because the rate kept rising: 36.2% of the development bookings were cancelled, and 41.2% of the bookings that arrived from April to August 2017. A model trained on the past expects the past's rate, a little less so when it is retrained often.

When to retrain is itself a design choice.

/ On a schedule.: Simple, predictable and easy to audit. It suits this project, where a retrain costs seconds and a month of new outcomes arrives like clockwork.
/ On a trigger.: When a drift alarm or a drop in performance says the world has moved. It saves work when training is expensive, but it waits for the damage to show, and its triggers need the same care as any alarm.
/ Never.: Only when the world is known not to change, which is rarer than it looks.

Whichever is chosen, keep every version with its card, and put the version in every answer and every log line. A #term[rollback] is then one change of the model path and a restart. A model that cannot be rolled back cannot be shipped safely.

== Other ways a model fails in service

/ A loop through its own decisions.: The call list changes the outcomes it predicts. If staff call the riskiest bookings and some of those guests confirm who would otherwise have cancelled, next month's labels record the calls as much as the guests. Keep a small random share of risky bookings that are not called, so that the model can still be measured against what would have happened.
/ Categories nobody has seen.: Between 4% and 6% of each month's bookings came through a travel agent the model had never seen. The encoder gives an unknown agent the code for "unknown", which is safe, but a model cannot know anything about a partner it never saw. Watch the share, and retrain when it grows.
/ Logs that hold people's data.: The prediction log contains bookings. Keep only the fields needed for monitoring, decide how long to keep them, and protect them like any other customer record.

== A monthly routine

#utpsteps[
  + #term[Check the new export against the contract.] Stop on a missing column, and give every warning a written decision.
  + #term[Score the month in a batch.] Publish the expected number of cancellations and the call list, both labeled with the model version.
  + #term[Measure drift on the first day:] the PSI of the key columns and of the predicted chance, against the same month last year as well as against training, and the share of unknown categories.
  + #term[When last month's outcomes are in,] score the champion and the challenger: AUC, Brier score, expected against actual, by group.
  + #term[Retrain on everything up to today.] Replace the model only if the gate and the contract pass, and keep the old version.
  + #term[Apply the rules written in advance] for promotion, rollback and investigation, and write down what was done and why.
]

#tryit[
  In `demo_serving.py`, set `CHECK_BOOK_NUMBERS = False`, and in the line that collects the signals above 0.25, change the threshold to 0.1. Run the script. Which months raise alarms now, and on which columns? Compare them with the AUC of those months. Would you want to be woken for these alarms, and what would you change so that only useful ones remain?
]

#block(breakable: false, width: 100%, chapterrecap[
  - Score in a batch when the decision is made on a schedule. Build a service only for questions that arrive one at a time.
  - The service checks every request against the contract, answers with the model version, and logs every answer. A broken booking got a list of its four mistakes, not a confident probability.
  - Training and serving share one module, which prevents training-serving skew.
  - Some signals are available at once (refused requests, new categories, input and output drift) and some only after the outcomes (AUC, Brier score, the count).
  - The PSI adds $(q_k - p_k) ln(q_k / p_k)$ over the bins. The deposit type scored 0.28 in August, almost all from non-refundable bookings.
  - The drift alarms of July and August were the summer: against the same month a year earlier, the segment's PSI fell from 0.35 and 0.43 to 0.03 and 0.01. The real change was in behaviour: guests without a deposit cancelled more often, and only the outcomes showed it.
  - The challenger, run in the shadow, led in all five months and was promoted by a rule written in advance.
  - Retraining monthly, through a gate, added about 0.01 of AUC and cut the shortfall from 8.2% to 5.1%. Keep every version so that one command can roll back.
])

#quickcheck[
  + A bank scores every loan application the moment it is submitted, and also recomputes the risk of all its loans every night. Which of the two jobs is a batch, and which needs a service? What does each fail as?
  + Name the four promises of the booking service, and say for each what would go wrong without it.
  + What is training-serving skew, and which test in the project would catch it?
  + Compute the PSI of a yes/no column whose share of "yes" moves from 20% to 30%.
  + A drift alarm rings for the market segment every July. What reference would you compare July with, and why?
  + The AUC fell from 0.857 to 0.797 between two Julys. Give the two reasons found in this chapter, and say which one an input-drift alarm could have seen.
  + The challenger won the test quarter and was still not promoted then. What made it acceptable to promote it later?
  + A retrained model has a gate AUC of 0.78 and the floor is 0.80. What happens, and what do you look at next?
  + Staff call the riskiest bookings to reconfirm them. Why can that make next month's evaluation misleading, and how can it be prevented?
]
