#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "02-supervised-workflow")

#labsection(2, label: <sec:lab02-supervised-workflow>)[Supervised learning I: regression, classification, and the workflow]

#labproject[A regression problem, two classification problems, and saved models at the end][
  #strong[Read first.] Chapters~#ref(<ch:learning>)--#ref(<ch:classification>). \

  #strong[Goal.] Fit regression and classification pipelines on messy data, validate in date order where time matters, choose thresholds and hyperparameters on purpose, test once, and save models that can be loaded and used. \

  #strong[Scenario.] Three commissions: a used-car dealer wants asking prices estimated from a listing, a hotel group wants to know which bookings will be cancelled so it can resell rooms without turning guests away, and a telecom company wants a churn model it can hand to its call centre. Then the models must leave the notebook as files. \

  #strong[Data.] In `all_datasets/supervised/`: `used_cars/used_cars.zip`, 150,000 car listings collected from Cars.com in October 2026; `hotel_bookings/hotel_bookings.zip`, the hotel bookings from Lab~1; and `telco_customer_churn/telco_customer_churn.csv`, the telecom customers from Lab~1. Each folder’s `README.md` is its data card. \

  #strong[Notebook.] `all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.ipynb`, with `predict_churn.py` and a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab02/`, the model files and a decision memo, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Tidy the car listings, predict prices, read the coefficients and the residuals],
  [2--5],
  [B],
  [Validate hotel cancellations in date order, and see what a shuffled split hides],
  [6--8],
  [C],
  [Beat a baseline, read probabilities, and choose a threshold by cost],
  [9--12],
  [D],
  [Tune the churn model with cross-validation, then open the test set once],
  [13--14],
  [E],
  [Save the models with a card, reload them and use them],
  [15--16],
  [Finish],
  [Save the evidence; then model log prices and write an overbooking memo],
  [17--19],
  [After],
  [Your-turn tasks, expected findings, troubleshooting and the two checklists],
  [---],
)

#labmode[
  + Activate your course environment and confirm the three data files are in `all_datasets/supervised/`.
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes under a minute.

  ```terminal
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#yourturn[
  #strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

  + True values $10,20,30,40$ and predictions $12,18,30,50$. Compute MAE and RMSE. Why is RMSE larger? (MAE 3.5, RMSE about 5.2.)
  + Question~9’s logistic model at threshold 0.50 flags 2017 bookings as likely cancellations with $T P=8(,)616$, $F P=2(,)479$, $F N=7(,)129$ and $T N=22(,)463$. Compute precision, recall and accuracy. Then predict: if the threshold rises to 0.70, which of these four counts can only grow, and which can only shrink?
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for. `make_preprocess` is the same helper as in Lab~1: median imputation and scaling for numbers, most-frequent imputation and one-hot encoding for categories.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 1)

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab02/ and models/
    ```
  ]
]

#labpartopen([Part A], [Regression: ordinary least squares versus ridge], [Questions 2--5 • Data: used-car listings from Cars.com], [Tidy real listings, predict used-car prices with a straight-line model, read its coefficients, and see where it fails.])

#labquestion(2)[Read the car listings, tidy them, and split][
  Each row is one car with a numeric label, `price_usd`, so this is regression. Three fixed rules, chosen before any model, keep used cars with a believable price (\$1,000 to \$200,000) and a real odometer reading. Sellers also type the same thing many ways, so `tidy()` maps the spellings of drivetrain and fuel to a few groups. Two models will share the pipeline and the split; the only difference is ridge’s penalty on large coefficients. The car’s `model` (F-150, Camry and over a thousand others) is kept aside for now, and a Your-turn task brings it in.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 2)

  #refoutput[
    ```terminal
    shape: (150000, 19)
    stock_type
    Used    79262
    New     70738
    used listings kept: 77,646 of 79,262
    spellings before tidying: drivetrain 21  fuel 31
    {'AWD': 28787, 'FWD': 18290, '4WD': 17310, 'RWD': 9008, None: 4251}
    {'gasoline': 63296, None: 5474, 'electric': 3007, 'hybrid': 2986, 'diesel': 2160,
     'flex fuel': 594, 'plug-in hybrid': 129}
    62116 listings to train on and 15530 to validate
    ```
  ]

  #strong[What it means.] The rules drop 1,616 used listings, among them 295 with no price shown, 712 priced above \$200,000 (24 of them in the millions) and 659 with 100 miles or fewer on the clock; a few break two rules. Tidying turns 21 spellings of the drivetrain and 31 of the fuel into four and six groups; what matches no group (“2WD”, “Unknown”, a blank) becomes a gap that the pipeline’s imputer fills. Every rule is fixed and reads no label, so it may run before the split. The listings were collected on one day, so a random 80/20 split is honest here.
]

#labquestion(3)[Fit OLS and ridge][
  Three scores per model. MAE is the typical miss in dollars. RMSE weights big misses more, so when it is much larger than MAE a few predictions are badly wrong. $R^2$ is the share of the price’s variation the model explains. Always guessing the training mean is the baseline both must beat.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 3)

  #refoutput[
    ```terminal
    always the training mean: MAE 15408

    linear regression          ridge
    MAE: 9009                  MAE: 9062
    RMSE: 14336                RMSE: 14427
    R2: 0.575                  R2: 0.569
    ```
  ]

  #strong[What it means.] Both models cut the typical miss from \$15,400 to about \$9,000, and regularization did not help: with 62,116 rows the plain model is already stable. RMSE is about 60% above MAE, so some cars are missed by far more than the typical amount; Question~5 shows which.
]

#labquestion(4)[Read the coefficients][
  A linear model is readable: each coefficient is the change in predicted price for a one-unit change in that feature, the others held fixed. The two numeric columns were standardized, so one unit is one standard deviation. Every make gets its own one-hot coefficient, and the cell counts the training listings behind each one.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 4)

  #refoutput[
    ```terminal
    one standard deviation: {'age': 5.6, 'mileage_miles': 47396.4}
    num__age             -3302.0
    num__mileage_miles   -8553.0
    the four largest:
                  coefficient  listings
    McLaren          76900.0        16
    Ferrari          82800.0        18
    Lancia           83000.0         1
    Lamborghini     115700.0        14
    30 makes have 500 listings or more, for example: {'Porsche': 26300.0, 'Toyota': -11600.0,
     'Ford': -13100.0, 'Mitsubishi': -26800.0}
    ```
  ]

  #strong[What it means.] One standard deviation of mileage, about 47,000 miles, takes \$8,553 off the price, and one of age, 5.6 years, another \$3,302. Age matters less than you might expect partly because the two move together (correlation 0.61): an old car usually has high mileage, and the model credits much of the wear to the odometer. The make coefficients are read as differences: a Porsche is priced \$37,900 above an otherwise identical Toyota, and a Mitsubishi \$15,200 below. The largest coefficients belong to supercars, and Lancia’s rests on a single listing: a rare category gets a confident-looking number from almost no evidence. Each coefficient is an association inside this model, not a cause.
]

#labquestion(5)[Plot the residuals][
  Two diagnostic plots for the ridge model. A good residual plot is a shapeless band around zero; any shape is something the model failed to use.
]

#labanswer[
  #include "visuals/02-worked-case.typ"

  #labcode("lab02_supervised_workflow", 5)

  #refoutput[
    ```terminal
    spread of the residuals (standard deviation) by quarter of predicted price:
    cheapest     9172.0
    second       8125.0
    third       10943.0
    dearest     23079.0
    predicted prices below zero: 377
    ```
  ]

  #strong[What it means.] The residuals fan out: a typical miss of \$8,000 to \$9,000 on the cheaper half of the predictions grows to \$23,079 on the dearest quarter, and 377 cars get a negative price. One straight surface cannot serve a \$5,000 hatchback and a \$150,000 sports car equally well, because a car loses value in proportions, not in fixed dollars. The Try-it fixes the shape; Your-turn task~1 adds the idea the model is missing.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Linear regression misses by \$9,009 on average, against \$15,408 for always guessing the mean; ridge is no better.
    - The residual spread grows to \$23,079 on the dearest quarter of predictions, and 377 cars get a negative price.
  ]
]

#labpartopen([Part B], [Classification in time: validate in date order], [Questions 6--8 • Data: hotel bookings], [Validate a cancellation model the way a hotel would use it: train on past arrivals, score future ones.])

#labquestion(6)[Split the bookings in date order][
  Lab~1 scored its hotel model on a shuffled split. A hotel, though, always predicts bookings for dates that have not happened yet, from bookings that already have. So the rows are sorted by arrival date, Lab~1’s five engineered columns are rebuilt, and arrivals up to the end of 2016 train while the eight months of 2017 validate.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 6)

  #refoutput[
    ```terminal
    train: 2015-07-01 to 2016-12-31, 78,703 bookings, 36.2% cancelled
    valid: 2017-01-01 to 2017-08-31, 40,687 bookings, 38.7% cancelled
    ```
  ]

  #strong[What it means.] Two thirds of the bookings train and one third validate, and the cancellation rate is already higher in the later period. `reservation_status` stays out, as Lab~1 showed it must.
]

#labquestion(7)[Score one model on two splits][
  The same logistic regression as Lab~1, fitted twice: once on a shuffled 75/25 split, once on the date split. Only the split differs, so any gap between the two scores is what the shuffle was hiding.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 7)

  #refoutput[
    ```terminal
    shuffled split, ROC AUC:     0.858
    date split (2017), ROC AUC:  0.824
    ```
  ]

  #strong[What it means.] The shuffled split flatters the model by more than three points. It let the model train on bookings from the very weeks it was tested on, which a hotel can never do. Your-turn task~2 finds a second reason: thousands of bookings in this file have exact twins.
]

#labquestion(8)[Compare the months][
  Averaging the predicted probabilities over each month of arrival gives the share of bookings the model expected to cancel; the actual share sits beside it. Months before 2017 were seen in training, and the months after were not.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 8)

  #refoutput[
    ```terminal
    arrival_date  2016-12  2017-01  2017-02  2017-03  2017-04  2017-05  2017-06  2017-07  2017-08
    actual          0.362    0.340    0.325    0.336    0.435    0.438    0.432    0.373    0.369
    predicted       0.296    0.303    0.291    0.346    0.406    0.412    0.420    0.361    0.346
    ```
  ]

  #strong[What it means.] The model follows the training months closely, then under-predicts most of 2017: 30.3% expected in January against 34.0%, and about 41% in April to June against 43 to 44%. Its ranking still works, but the world it learned from had moved on, and only a split in date order shows it. Lab~8 forecasts a series from its own past, where the same rule holds.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Training arrivals end on 31 December 2016; the 40,687 arrivals of 2017 are the validation set.
    - The same model scores ROC AUC 0.858 shuffled and 0.824 in date order.
  ]
]

#labpartopen([Part C], [Classification: baselines, probabilities, and the threshold], [Questions 9--12 • Data: hotel bookings, split in date order], [Beat a baseline, read predicted probabilities, and choose a threshold by what each error costs.])

#labquestion(9)[Set a baseline and compare classifiers on 2017][
  The date split from Part~B, and two classifiers with the same preparation. Logistic regression is the simple, readable reference, and a random forest the more flexible challenger. Accuracy counts correct decisions at the default 0.5 cutoff; ROC AUC judges how well a model ranks bookings, independent of any cutoff. A hotel would act on a flagged booking by reselling its room, so precision asks: when the model says a booking will cancel, how often is it right?
]

#labanswer[
  #labcode("lab02_supervised_workflow", 9)

  #refoutput[
    ```terminal
    majority-class baseline accuracy: 0.613
    logistic       accuracy=0.764 roc_auc=0.824
    random_forest  accuracy=0.770 roc_auc=0.841
    threshold 0.30: precision=0.61 recall=0.77
    threshold 0.50: precision=0.78 recall=0.55
    threshold 0.70: precision=0.96 recall=0.29
    ```
  ]

  #strong[What it means.] Both models clear the baseline, and the forest leads by about two points of ROC AUC. With 40,687 validation bookings that gap is real, but both are scored on one period, and Your-turn task~2 shows how much the forest’s lead depends on the split. The threshold table is the same logistic model with three decision rules.
]

#labquestion(10)[Plot the cancellation probabilities][
  The logistic model gives every 2017 booking a probability of cancelling. Plot those probabilities separately for the bookings that were kept and those that were cancelled: a threshold is a vertical line, and every booking to its right is treated as a likely cancellation whose room can be resold.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 10)

  #refoutput[
    ```terminal
    share of 2017 bookings scored between 0.3 and 0.7: 0.374
    ```
  ]

  #strong[What it means.] The two groups overlap heavily: more than a third of the bookings sit in the uncertain middle, so wherever the line goes it cuts through both. One feature stands out, a tower of cancelled bookings near 1.0. These are the 4,126 non-refundable bookings of 2017, 99.8% of which were cancelled, the puzzling pattern the data card warns about.
]

#labquestion(11)[Count errors at two thresholds][
  The confusion matrix counts what happens on each side of the line: rows are the truth, columns are the decision. Precision asks how often a flagged booking really cancelled; recall asks how many of the cancellations were flagged.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 11)

  #refoutput[
    ```terminal
    threshold = 0.50
    [[22463  2479]
     [ 7129  8616]]
               1      0.777     0.547     0.642     15745
    threshold = 0.70
    [[24748   194]
     [11117  4628]]
               1      0.960     0.294     0.450     15745
    ```
  ]

  #strong[What it means.] At 0.50 the hotel flags 11,095 bookings and is right about 8,616 of them, but 2,479 flagged guests arrive to find their room resold. At 0.70 only 194 do, at the price of catching just 4,628 of the 15,745 cancellations and leaving the other rooms empty. Neither number is “the” answer: the default 0.50 quietly decides that a walked guest costs no more than an empty room.
]

#labquestion(12)[Summarize the ranking: ROC and PR][
  Two numbers summarize the ranking without choosing any threshold. ROC AUC is the chance that a random cancelled booking scores higher than a random kept one. Average precision (PR AUC) focuses on the positive class; guessing scores the positive rate, so it is the more honest number when positives are rare.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 12)

  #refoutput[
    ```terminal
    ROC AUC: 0.824
    PR AUC (average precision): 0.786  against 0.387 for guessing
    ```
  ]

  #strong[What it means.] The ranking is useful but far from perfect: a cancelled booking outranks a kept one about eight times in ten, and average precision doubles the guessing rate. With 38.7% positives the two summaries tell a similar story; in Lab~5, with 0.17% frauds, they will not.
]

#strong[Connect it to the chapter.] A loss decides what “wrong” costs during fitting, and the threshold decides what it costs afterwards.

#include "visuals/02-supervised-workflow-chapter.typ"

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - On 2017, the majority baseline scores 0.613; logistic regression 0.764 accuracy and 0.824 ROC AUC.
    - At a threshold of 0.50, 2,479 flagged bookings are kept; at 0.70, only 194 are.
    - ROC AUC 0.824, and average precision 0.786 against 0.387 for guessing.
  ]
]

#labpartopen([Part D], [Tune with cross-validation, then test once], [Questions 13--14 • Data: Telco customer churn], [Choose settings by cross-validation on the training rows, then open the test set exactly once.])

#labquestion(13)[Tune with cross-validation][
  Back to Lab~1’s telecom customers, now to predict who leaves (`Churn`). The column lists come from the data types, and a quarter of the customers is set aside as the #emph[test] set before anything is fitted, so no step of the search can see them. Inside the training rows, five-fold cross-validation scores every combination of `C` (regularization strength) and `class_weight`, and the grid search then refits the winning combination on all training rows.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 13)

  #refoutput[
    ```terminal
    4 numeric and 15 text columns; 26.5% of customers left
    cross-validated ROC AUC ranges from 0.841 to 0.844 ; typical fold-to-fold spread 0.015
    ```
  ]

  #strong[What it means.] The curve is flat: every setting lies between 0.841 and 0.844, while the error bars, one standard deviation across five folds, are about 0.015. This table does not care much about `C`, so small gaps between settings should not be over-read.
]

#labquestion(14)[Open the test set once][
  Only now is the test set touched, once.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 14)

  #refoutput[
    ```terminal
    best parameters: {'model__C': 10.0, 'model__class_weight': None}
    cross-validated ROC AUC: 0.844
    final test ROC AUC: 0.846 on 1761 customers
    ```
  ]

  #strong[What it means.] The test score agrees with the cross-validated one, as it should when the test rows were sealed from the start. It is still one draw: 1,761 customers carry an uncertainty of about a point either way, which Your-turn task~4 measures. Report the test number once, and do not tune again after seeing it.
]

#include "visuals/02-trace.typ"

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Best setting: `C` = 10 without class weights, cross-validated ROC AUC 0.844.
    - The final test ROC AUC, 0.846, is reported once, and nothing is tuned after it.
  ]
]

#labpartopen([Part E], [Save the models and use them], [Questions 15--16 • Data: the two fitted models], [Save each model with a card, reload it, and use it from a script.])

#labquestion(15)[Save the churn model with a card][
  A model that exists only inside a running notebook is not finished. `joblib.dump` writes the whole pipeline, preprocessing and estimator together, to one file. A model card written next to it records what the file expects, how well it did, and a typical customer whose values a script can use for any column it is not given.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 15)

  #refoutput[
    ```terminal
    saved: customer_churn.joblib (8.3 KB) and customer_churn_card.json
    ```
  ]
]

#labquestion(16)[Reload the models and use them][
  Deployment, in its smallest form, is three lines: load the file, hand it new rows with the same column names, read the predictions. No retraining and no preprocessing code, because the preprocessing traveled inside the file. A real customer’s row is the template for the two new ones, so every column the model expects is there. The car-price model is saved the same way and prices one car at two mileages.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 16)

  #refoutput[
    ```terminal
       tenure        Contract InternetService              PaymentMethod  churn_probability
    0       2  Month-to-month     Fiber optic           Electronic check              0.305
    1      60        Two year             DSL  Bank transfer (automatic)              0.004
         make body_type  age  mileage_miles  predicted_price
    0  Toyota       SUV    5          30000          36700.0
    1  Toyota       SUV    5          90000          25900.0
    ```
  ]

  #strong[What it means.] A new month-to-month fibre customer paying by electronic check has a 30.5% chance of leaving; a five-year customer on a two-year contract, 0.4%. The two Toyotas differ only in mileage, and 60,000 extra miles take \$10,800 off the price, the mileage coefficient of Question~4 at work. The script `predict_churn.py`, beside the notebook, does the same job from the terminal, filling every column it is not given from the card’s typical customer:

  ```terminal
  python all_experiments/lab02_supervised_workflow/predict_churn.py --tenure 2 --contract Month-to-month --monthly 85
  churn probability: 0.465  ->  likely to stay
  ```
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - `customer_churn.joblib` and its card are in `models/`, beside `used_car_prices.joblib`.
    - `predict_churn.py` prints a churn probability from the terminal.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 17--19], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(17)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 17)

  #strong[What it means.] `results/lab02/` now holds `metrics.csv`, `monthly_cancellations.csv` and the figures, and `models/` holds the churn model with its card and `used_car_prices.joblib`.
]

#labsubhead[Try it yourself]

#labquestion(18)[Try it yourself, and a decision memo][
  The residuals of Question~5 fan out, and 377 cars get a negative price. Refit Part~A’s linear regression on the logarithm of the price, turn its predictions back into dollars with `np.exp`, and compare the MAE, $R^2$ and the residual spread by quarter with Questions~3 and~5. Attempt it in this empty cell before reading the solution.

  #strong[Decision memo.] Choose the threshold above which the hotel treats a 2017 booking as a likely cancellation and resells its room, in a setting where walking a guest (finding them a room at another hotel, because theirs was resold) costs about twice the revenue lost on an empty room. State what happens to the confusion matrix when the threshold is lowered, and name the validation evidence from Part~C that supports your choice.
]

#labquestion(19)[One solution][
  Part~A’s model on the logarithm of the price. On that scale each coefficient is a percentage change.
]

#labanswer[
  #labcode("lab02_supervised_workflow", 19)

  #refoutput[
    ```terminal
    log-price model: MAE 7695  R2 0.611  prices below zero: 0
    spread of the residuals by quarter of predicted price:
    cheapest     7763.0
    second       8161.0
    third       11584.0
    dearest     21658.0
    one more year: x0.971   10,000 more miles: x0.931
    ```
  ]

  #strong[What it means.] The log-price model misses by \$7,695 instead of \$9,009, explains 61.1% of the variation in dollars instead of 57.5%, and prices no car below zero. The residuals still widen with price, because a 10% miss on a dear car is more dollars, but the model now treats price as multiplicative: each extra year multiplies it by 0.971 and each extra 10,000 miles by 0.931, whatever the car. A transformed label is often the cheapest fix for a fan of residuals.

  #strong[A model memo.] Threshold 0.65 for the cancellation model. At the default 0.50 the hotel would resell the rooms of 2,479 guests who then arrive, while missing 7,129 cancellations; at 0.70 only 194 guests would be walked, but 11,117 cancelled rooms would stand empty. If walking a guest costs twice an empty room, the cheapest threshold on the 2017 bookings is 0.65, with 10,065 empty rooms and 611 walked guests (Your-turn task~3). It sits close to the break-even probability, $2\/(2+1)=0.67$: resell a room only when the booking is at least twice as likely to cancel as to arrive. Lowering a threshold moves the line left through the histogram: more bookings are flagged, so fewer rooms stand empty but more guests are walked, and recall goes up while precision goes down. Change the cost ratio, and the right threshold changes with it: the threshold is a statement about costs.
]

#labpartopen([After the lab], [Your turn, troubleshooting and hand-in], [Your-turn tasks • Expected findings • Troubleshooting • Checklists], [Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.])

#yourturn[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

  + #strong[Add the missing idea.] Add `model` to the Part~A categorical columns, so each of the car models gets its own one-hot column. What happens to $R^2$ and MAE? Compare with the effect of ridge.
  + #strong[What did the date split hide?] Refit the Question~9 random forest on Question~7’s shuffled split. How does its ROC AUC compare with 0.841 on 2017? Then count how many shuffled validation bookings have an exact twin, every column equal, among the training bookings. Which number would you put in a report to the hotel?
  + #strong[Choose a threshold from costs.] Suppose walking a guest costs twice an empty room. Sweep the Question~10 thresholds from 0.05 to 0.95 in steps of 0.05 and compute $"empty rooms"+2 times "walked guests"$, where an empty room is a missed cancellation and a walked guest a flagged booking that was kept. Which threshold is cheapest?
  + #strong[How sure is a test score?] Repeat Part~D five times with `random_state` 0 to 4 in the train/test split, tuning and testing each time. How far apart are the five test scores, and what does that say about the 0.846 of Question~14?
]

#expectedfindings[
  #strong[Warm-up.] MAE 3.5 and RMSE 5.2: the one miss of 10 dominates the squares. Precision $8(,)616\/11(,)095=0.777$, recall $8(,)616\/15(,)745=0.547$, accuracy $31(,)079\/40(,)687=0.764$. Raising the threshold can only remove positive decisions, so $T P$ and $F P$ can only shrink, and $F N$ and $T N$ can only grow.

  + $R^2$ rises from 0.575 to 0.792 and MAE falls from \$9,009 to \$5,754, from 1,147 one-hot model columns. Ridge with the model scores 0.772 and \$6,128: the problem was a missing idea, which car it is, not an unstable fit, and the penalty even shrinks the coefficients of rare models that deserved to be large.
  + It jumps to 0.911. 9,366 of the 29,848 shuffled validation bookings have an exact twin among the training bookings, and a forest can recall a twin it has already seen. Report 0.841: the hotel will always be predicting bookings for dates that have not come yet.
  + 0.65, with 10,065 empty rooms and 611 walked guests, for a cost of 11,287. At 0.50 the cost is $7(,)129+2 times 2(,)479=12(,)087$, and at 0.70 it is $11(,)117+2 times 194=11(,)505$. Change the cost ratio, and the answer changes: the threshold is a statement about costs.
  + The five test scores run from 0.838 to 0.855, and the search picks `C` 1 or 10 without class weights each time. A test set of 1,761 customers pins the score down to about a point either way, so 0.846 is one honest draw from that range, and a gap of a point between two models on such a test set proves nothing.
]

#troubleshoot[
  / Every metric differs slightly from the sheet: Check that no earlier cell was edited, and rerun from the top. Running cells out of order reuses variables from the wrong part.
  / `FileNotFoundError` in `predict_churn.py`: Run Question~15 first: the script needs `models/customer_churn.joblib` and its card.
  / Question~2 keeps a different number of listings: The three rules must use the same bounds as the cell: a price from 1,000 to 200,000 dollars, inclusive, and more than 100 miles.
  / A loky or joblib message when the kernel stops: `n_jobs=-1` sometimes prints a harmless resource-tracker message on Windows when a pool closes. If the cell’s results printed, the run is fine.
]

#labchecklists[
  #verification[
    - Every model beats its baseline, and each comparison uses validation data, not the test set.
    - You can explain the car-price residual fan, why ridge did not help, and why Lancia’s coefficient deserves no trust.
    - The hotel split is in date order, and you can explain why the shuffled split scored higher.
    - The overbooking threshold is chosen from validation evidence and stated as a policy.
    - The final churn test ROC AUC, 0.846, is reported once, from test rows set aside before tuning.
    - `models/` holds `customer_churn.joblib` with its card, and `used_car_prices.joblib`, and both reload and predict.
  ]
]
