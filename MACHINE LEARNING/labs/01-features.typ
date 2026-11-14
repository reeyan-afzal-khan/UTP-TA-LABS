#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "01-features")

#labsection(1, label: <sec:lab01-features>)[Feature engineering and feature selection]

#labproject[Check the tools, understand the data, build features, and choose among them][
  #strong[Read first.] Chapters~#ref(<ch:data>) and~#ref(<ch:feature-engineering>). Chapter~@ch:toolkit sets up your tools. The lab fits logistic regression, with and without an L1 penalty, before its chapter: treat it as a black box for now, since the point here is what goes into it. \

  #strong[Goal.] Check the environment, read a data card, engineer features, see scaling change who counts as a neighbor, and select features without leakage. \

  #strong[Scenario.] You inherit three real tables and three questions: which hotel bookings will be cancelled, which phone customers resemble each other, and which bank customers are worth a call. Before any model matters, you have to get the columns right, including when each one was written down. \

  #strong[Data.] In `all_datasets/supervised/`: `hotel_bookings/hotel_bookings.zip`, the bookings of two Portuguese hotels for arrivals from 2015 to 2017 (Antonio, de Almeida and Nunes, 2019); `telco_customer_churn/telco_customer_churn.csv`, IBM’s sample of a telecom company’s customers; and `bank_marketing/bank_marketing.csv`, a Portuguese bank’s marketing calls from the UCI repository (Moro, Cortez and Rita, 2014). The `README.md` in each folder is its data card, and Chapter~@ch:toolkit links each source. \

  #strong[Notebook.] `all_experiments/lab01_features/lab01_features_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, the `results/lab01/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Check your versions, read the data card, find the gaps and the column that leaks the outcome],
  [2--4],
  [B],
  [Engineer five columns from the hotel bookings and test them on a model],
  [5--7],
  [C],
  [Repair the Telco columns and see how scaling changes a customer’s neighbors],
  [8--9],
  [D],
  [Select features for the bank’s call list without leaking the outcome],
  [10--12],
  [Finish],
  [Save the evidence; then add the arrival weekday yourself],
  [13--15],
  [After],
  [Your-turn tasks, expected findings, troubleshooting and the two checklists],
  [---],
)

#labmode[
  + Activate your course environment (Chapter~@ch:toolkit) and confirm that the three data files are in `all_datasets/supervised/`.
  + Warm up on the study log, which needs no data. From the course folder, run the command below. Its last line must read `Every number above matches the book.`
  + From the course folder, start Jupyter, open `all_experiments/lab01_features/lab01_features_worked.ipynb`, and choose #strong[Restart Kernel and Run All Cells]. It takes a few seconds.

  ```terminal
  python all_experiments/book_checks/demo_study_log.py
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab01_features/lab01_features_worked.py` runs the same code and writes the same evidence. Its first nine lines say what it is and set the working directory:

  #lstinput("/MACHINE LEARNING/all_experiments/lab01_features/lab01_features_worked.py", first: 1, last: 9, lang: "python")
]

#labroutine

#yourturn[
  #strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

  + Booking 14876 is for the resort hotel, made 132 days before arrival, for 2 weekend nights and 4 week nights, with 2 adults, no children and 1 baby, by a customer who had cancelled one booking before. Work out `total_nights`, `total_guests`, `with_children`, `log_lead_time`, which is $ln(1+"lead time")$, and `cancelled_before`. Could the hotel compute all five the moment the booking is made? Question~5 prints the numbers.
  + Two columns have means 2,279.73 and 32.37, and standard deviations 2,266.79 and 24.56. A gap of 100 in the first and of 12 in the second: which one dominates a raw distance, and which one after scaling? Question~9 shows the same effect on real customers.
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.
]

#labanswer[
  #labcode("lab01_features", 1)

  #readcode[
    - `sys.path.insert(0, "..")` lets Python import `course_setup.py` from the folder above this lab's own.
    - Each `from sklearn...` line imports one tool, and the comment beside a line says what the tool is for.
    - `start_lab("lab01")` returns three folders: `DATA` to read from, and `RESULTS` and `MODELS` to write to.
  ]

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab01/ and models/
    ```
  ]
]

#labpartopen([Part A], [Environment check and a first look at the data], [Questions 2--4 • Data: hotel bookings and their data card], [Confirm your setup, then learn what each booking column means and which one was written after the outcome.])

#labquestion(2)[Print the package versions][
  Every result in this course depends on four packages. Print their versions once, at the top, so that if a number ever changes between two runs you can rule out the environment first.
]

#labanswer[
  #labcode("lab01_features", 2)

  #readcode[
    - Every package stores its version in `__version__`. Printing it costs one line, and it saves an hour when two runs disagree.
  ]

  #refoutput[
    ```terminal
    NumPy: 2.3.5
    pandas: 2.3.3
    Matplotlib: 3.10.6
    scikit-learn: 1.7.2
    ```
  ]

  #strong[What it means.] These are the versions behind this sheet’s reference outputs, and the notebook file stores this same run. Yours may be newer. A newer scikit-learn can move the last digit of a score, which is exactly the kind of difference this cell lets you rule in or out.
]

#labquestion(3)[Read the data card, then the bookings][
  A professional reads the data dictionary before the data. Every dataset in this course has one, the data card `README.md` beside the file, which says what each column means, in which units, and how it was recorded. The cell prints its column meanings, then answers three questions from the table itself: how big is it, which hotels and dates does it cover, and how balanced is the label? The arrival date is spread over three columns, with the month as a word, so the cell joins them into one date.
]

#labanswer[
  #labcode("lab01_features", 3)

  #readcode[
    - `read_text()` loads the card as one long string. `card.index(...)` finds where its column table starts, and the loop splits each row on `" | "` into the column's name and its meaning.
    - `pd.read_csv` reads the CSV straight out of the ZIP file.
    - `value_counts()` counts the bookings of each hotel, and `.to_string()` prints the counts without the type line pandas adds at the end.
    - The three date columns are joined into text such as `2015-July-1`. `pd.to_datetime(..., format="%Y-%B-%d")` turns that text into real dates; `%B` stands for the month written as a word.
    - `value_counts(normalize=True)` gives shares instead of counts.
  ]

  #refoutput[
    ```terminal
    hotel                           `Resort Hotel` (Algarve) or `City Hotel` (Lisbon)
    is_canceled                     1 if the booking was cancelled: the label
    lead_time                       days from making the booking to the arrival date
    ...
    reservation_status              how the booking ended: `Canceled`, `No-Show` or `Check-Out`
    reservation_status_date         date that last status was set

    shape: (119390, 32)
    hotel
    City Hotel      79330
    Resort Hotel    40060
    arrivals from 2015-07-01 to 2017-08-31

    Cancellation rate:
     is_canceled
    0    0.63
    1    0.37
    ```
  ]

  #strong[What it means.] 119,390 bookings and 32 columns, two thirds of them at the city hotel, for arrivals over twenty-six months. 37.0% were cancelled, so a model that always says “not cancelled” is already 63.0% accurate, and anything built later has to beat that. Read the rest of the card too: `adr` is a price per night in euros, `lead_time` is counted in days, and the authors describe each booking as it stood on the day before arrival. Even a good card leaves questions open: the room types are bare letters, because the source hid their names.
]

#labquestion(4)[Chart the missing values, and date the columns][
  A bar chart makes the gaps easier to compare than a column of numbers. Then ask when each column was filled in. `reservation_status` says how the booking ended, so check whether it already knows who cancelled, and compare the date it was written with the arrival date.
]

#labanswer[
  #labcode("lab01_features", 4)

  #readcode[
    - `hotels.isna().mean()` is the share of blank cells in each column: the mean of a column of `True` and `False`.
    - `missing[missing > 0]` keeps only the columns that have gaps.
    - `plt.barh` draws horizontal bars. `savefig` writes the chart to the results folder before `show` displays it.
    - `pd.crosstab(a, b)` counts the bookings for every combination of two columns: here, how the booking ended against whether it was cancelled.
    - `status_date >= hotels["arrival_date"]` compares two date columns row by row, and `.rename(...)` gives the result a readable name for the table.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/01-notebook-reference.png", width: 80%, height: 4cm)
  ]

  #refoutput[
    ```terminal
    company     94.31
    agent       13.69
    country      0.41
    children     0.00

     is_canceled             0      1
    reservation_status
    Canceled                0  43017
    Check-Out           75166      0
    No-Show                 0   1207

     is_canceled                             0      1
    status written on or after arrival
    False                                   0  42137
    True                                75166   2087
    ```
  ]

  #strong[What it means.] `company` is empty for 94.3% of bookings and `agent` for 13.7%, but the data’s authors call these “not applicable”: no company or travel agent was involved, so here a blank is information, not a gap. `country` lacks 0.4% and `children` only 4 values. `reservation_status` is the answer in disguise: every `Canceled` and `No-Show` booking was cancelled, and every `Check-Out` was kept. Its date gives it away too: every kept booking had its status written on or after arrival, and 42,137 of the 44,224 cancelled ones before it. The column comes from the future, so it stays in the table as a record and never enters a model; Your-turn task~1 looks for subtler cases. Regenerate the plot rather than copying it; this saved figure is a reference, not evidence of your own run.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Your package versions print, and you know which ones differ from the sheet’s.
    - 119,390 bookings, 37.0% of them cancelled, so always guessing “not cancelled” is already 63.0% accurate.
    - You can say why `reservation_status` must never be a feature.
  ]
]

#labpartopen([Part B], [Feature engineering], [Questions 5--7 • Data: hotel bookings], [Turn nights, guests, lead time and booking history into five new columns, and measure whether they help a model.])

#labquestion(5)[Engineer five new columns][
  Feature engineering means building inputs the model cannot see on its own. `total_nights` adds the weekend and week nights, `total_guests` adds the adults, children and babies, and `with_children` flags a family; the four blank `children` counts are read as none. `log_lead_time` takes $ln(1+x)$ of the days booked ahead, because a few bookings were made up to two years early and would otherwise stretch the scale. `cancelled_before` flags a customer who has cancelled a booking before. Every new column uses only what was known when the booking was made, which is the test each feature must pass.
]

#labanswer[
  #include "visuals/01-worked-case.typ"

  #labcode("lab01_features", 5)

  #readcode[
    - Adding two columns adds them row by row. No loop is needed.
    - `fillna(0)` reads a blank children count as none, and `.astype(int)` turns the decimals into whole numbers.
    - `(children + hotels["babies"]) > 0` is a mask, and `.astype(int)` turns its `True` and `False` into 1 and 0.
    - `np.log1p(x)` computes ln(1 + x), which is safe when x is 0.
    - `hotels.loc[two_bookings, columns]` picks two rows by their labels and a list of columns. `.T` turns the result on its side, so that each column prints as a line.
  ]

  #refoutput[
    ```terminal
                                    14876       40060
    hotel                    Resort Hotel  City Hotel
    lead_time                         132           6
    stays_in_weekend_nights             2           0
    stays_in_week_nights                4           2
    adults                              2           1
    children                          0.0         0.0
    babies                              1           0
    previous_cancellations              1           0
    total_nights                        6           2
    total_guests                        3           1
    with_children                       1           0
    log_lead_time                    4.89       1.946
    cancelled_before                    1           0
    ```
  ]

  #strong[What it means.] Your warm-up should match the first column: 6 nights, 3 guests, a family, and $ln 133 = 4.89$. The city booking was made 6 days ahead, so its `log_lead_time` is $ln 7 = 1.95$. The logarithm squeezes long lead times together: 132 days is 22 times 6 days, but 4.89 is only 2.5 times 1.95, so the few bookings made a year or two ahead no longer dominate a linear model. Each column reads only its own booking’s fields, so it is a fixed rule that may run before the split. Do not use `is_canceled` to construct an input.
]

#labquestion(6)[Check the new columns for signal][
  Grouping the label by the new columns shows whether they carry signal. Lead time is cut into bands of days, and stays of eight nights or more share one bar.
]

#labanswer[
  #labcode("lab01_features", 6)

  #readcode[
    - `pd.cut(values, edges, labels=...)` sorts each lead time into a band. The first edge is -1 so that a lead time of 0 days falls in the first band.
    - `hotels.groupby(lead_band, observed=True)["is_canceled"].mean()` is the cancellation rate in each band. `observed=True` leaves out bands that hold no bookings.
    - `.clip(upper=8)` replaces every value above 8 by 8, so that long stays share one group.
    - `plt.subplots(1, 2)` makes two charts side by side, and `ax=axes[0]` tells pandas which one to draw on.
    - `.to_dict()` prints each result on one line.
  ]

  #refoutput[
    ```terminal
    by days ahead:     {'0-7': 0.096, '8-30': 0.279, '31-90': 0.377, '91-180': 0.447,
                        '181-365': 0.555, '366+': 0.677}
    by nights:         {0: 0.049, 1: 0.251, 2: 0.44, 3: 0.419, 4: 0.366, 5: 0.342, 6: 0.398,
                        7: 0.343, 8: 0.357}
    with children:     {0: 0.372, 1: 0.349}
    cancelled before:  {0: 0.339, 1: 0.916}
    ```
  ]

  #strong[What it means.] These are the bars in the plot. Cancellations climb steadily with lead time, from 9.6% for bookings made within a week to 67.7% for those made more than a year ahead: a plan made far in advance has more time to change. Bookings for zero nights, which arrive and leave on the same day, almost never cancel (4.9%). Customers who had cancelled before cancelled again 91.6% of the time, against 33.9%. Families cancel about as often as everyone else (34.9% against 37.2%), so `with_children` may add little.
]

#labquestion(7)[Test the new columns on a model][
  Does the engineering help a model? The only fair test is the same model and the same split, with and without the new columns. The raw set takes eleven numbers and five categories known when the booking is made. It leaves out the agent and company IDs (codes with over 300 values each), the arrival date columns, which Lab~2 puts to work, and columns that may have been filled in later: the country, the room actually assigned and the number of changes. Preprocessing lives inside a pipeline, so imputation, scaling and encoding are learned from the training rows and reapplied unchanged to validation rows.
]

#labanswer[
  #include "visuals/01-trace.typ"

  #labcode("lab01_features", 7)

  #readcode[
    - `make_preprocess` builds the preparation. Number columns have their gaps filled with the median and are then scaled. Text columns have their gaps filled with the most frequent value and are then one-hot encoded. `ColumnTransformer` sends each list of columns to its own steps.
    - `feature_sets` holds the two lists of columns to compare, and the loop runs the identical recipe on each.
    - `train_test_split(..., random_state=42, stratify=y)` makes the same split both times, with the same share of cancellations on each side.
    - `Pipeline([...])` chains preparation and model. `model.fit(X_train, y_train)` learns the medians, the scales, the categories and the weights from the training bookings only.
    - `predict_proba(X_valid)[:, 1]` is each validation booking's predicted chance of being cancelled, and `roc_auc_score` measures how well those chances rank the bookings.
  ]

  #refoutput[
    ```terminal
    raw columns        validation ROC AUC = 0.846
    raw + engineered   validation ROC AUC = 0.855
    validation bookings: 29848
    ```
  ]

  #strong[What it means.] Same logistic regression, about one point better, and the gain came entirely from better columns. On 29,848 validation bookings a point is unlikely to be luck, and `check_your_turn.py` confirms it with five-fold cross-validation: 0.858 against 0.848. Better columns are usually the cheapest improvement available, but they are rarely magic.
]

#strong[Connect it to the chapter.] Everything so far followed this safe order of operations.

#include "visuals/01-features-chapter.typ"

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Validation ROC AUC rises from 0.846 with the raw columns to 0.855 with the engineered ones.
    - You can explain why `log_lead_time` suits a linear model better than the raw lead time.
  ]
]

#labpartopen([Part C], [Scaling changes the geometry], [Questions 8--9 • Data: Telco customer churn], [Repair a number column stored as text, then see how scaling changes which customers count as neighbors.])

#labquestion(8)[Fix the types, then see the units][
  The Telco churn table has one row per customer of a phone and internet company, and `Churn` says whether they left. Distances need numbers, and `TotalCharges` arrives as text. Find the cells that will not convert, see whose they are, and repair them with a rule you can defend. Then compare the units of the three time-and-money columns.
]

#labanswer[
  #labcode("lab01_features", 8)

  #readcode[
    - `churn["TotalCharges"].dtype` shows how pandas stored the column; `object` means text.
    - `pd.to_numeric(..., errors="coerce")` converts what it can and turns the rest into `NaN`, so that the bad cells can be found instead of stopping the cell with an error.
    - `total.isna()` marks those cells, and `churn.loc[not_numbers, "tenure"].unique()` shows the tenure of the customers they belong to.
    - `fillna(0)` writes the repair.
    - `describe().loc[["mean", "std"]]` keeps two rows of the summary.
  ]

  #refoutput[
    ```terminal
    shape: (7043, 21)  TotalCharges is stored as: object
    rows that are not numbers: 11  their tenure: [0]
          tenure  MonthlyCharges  TotalCharges
    mean   32.37           64.76       2279.73
    std    24.56           30.09       2266.79
    ```
  ]

  #strong[What it means.] Eleven cells hold a blank, and all eleven belong to customers in their first month, who have not been billed yet. Zero is therefore the right repair; the mean, about \$2,280, would invent a bill for people who have never paid one. A typical gap in `TotalCharges` is about 2,267 dollars and a typical gap in `tenure` about 25 months, so in raw units the total bill will decide every distance on its own.
]

#labquestion(9)[Compare neighbors before and after scaling][
  Many models (nearest neighbors, clustering, SVMs, neural networks) work by measuring distances between rows. Take customer 7795-CFOCW, with 45 months of tenure at \$42.30 a month, and find the ten customers closest to them twice: once in raw units, and once after standardizing each column to mean 0 and standard deviation 1. Who counts as similar?
]

#labanswer[
  #labcode("lab01_features", 9)

  #readcode[
    - `to_numpy()` turns the three columns into a plain array, which the distance tools expect.
    - `StandardScaler().fit_transform(X_raw)` rescales each column to mean 0 and standard deviation 1. It is fitted on all the rows here because nothing is being predicted; in a model it belongs inside the pipeline.
    - `NearestNeighbors(n_neighbors=k + 1).fit(X)` prepares the search, and `kneighbors` returns the positions of the closest rows. One more than `k` is requested because the row closest to a customer is that customer.
    - `found[found != row][:k]` drops the customer's own row and keeps `k` neighbors.
    - `set(near_raw) & set(near_std)` is the set of customers that appear in both lists.
  ]

  #refoutput[
    ```terminal
    raw units     tenure 29-49 months   monthly $39.20-60.20   total $1,815-1,861
    standardized  tenure 43-47 months   monthly $38.25-45.55   total $1,755-2,065
    customers in both lists: 1
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/01-neighbors-reference.png", width: 80%, height: 5.5cm)
  ]

  #strong[What it means.] In raw units the ten neighbors have paid almost exactly the customer’s \$1,841, but they range from 29 to 49 months and from \$39.20 to \$60.20 a month: several are newer customers on dearer plans. After scaling they range from 43 to 47 months and \$38.25 to \$45.55 a month, customers who really do look alike, even though their totals spread wider. Only one customer is in both lists. Nothing about the customers changed, only the measuring stick, so any distance-based model answers differently on the two versions. That is why the scaler sits inside the pipeline; Your-turn task~3 measures the effect on a model.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - `TotalCharges` had 11 blank cells, all from first-month customers, so zero is the right repair.
    - The ten nearest neighbors in raw units and after scaling share only one customer.
  ]
]

#labpartopen([Part D], [Feature selection without leakage], [Questions 10--12 • Data: bank marketing calls], [Choose features for a bank’s call list using only what is known before the call.])

#labquestion(10)[Define the bank-call task][
  The bank-marketing table holds 41,188 phone calls that a Portuguese bank made between May 2008 and November 2010 to sell a term deposit, and `y` says whether the customer signed up. The task is to decide #emph[before dialing] whom to call, so `duration`, the length of the call, does not exist yet and is left out. The file separates its fields with semicolons, a common European format, so `read_csv` needs `sep=";"`.
]

#labanswer[
  #labcode("lab01_features", 10)

  #readcode[
    - `sep=";"` tells `read_csv` that this file separates its fields with semicolons.
    - `duplicated().sum()` counts the rows that repeat an earlier row, and `drop_duplicates().reset_index(drop=True)` removes them and renumbers the rows.
    - `(bank == "unknown").sum().sum()` counts the cells that hold the word `unknown`. The first sum counts within each column and the second adds the columns up.
    - `bank.drop(columns=["y", "duration"])` removes the label and the one column that is not known before the call.
    - `select_dtypes(include="number")` picks the number columns, and `exclude="number"` picks the rest.
  ]

  #refoutput[
    ```terminal
    shape: (41188, 21)  missing: 0  duplicates: 12
    said yes: 0.113  'unknown' cells: 12716  pdays = 999: 0.963
    9 numeric and 10 text features known before the call
    ```
  ]

  #strong[What it means.] The table looks complete, with no blank cells, but its gaps are in disguise. 12,716 cells say `unknown`, and `pdays`, the days since the bank last called, is 999 for the 96.3% of customers it had never called. A code like 999 is not a number of days, yet a scaler or a distance would treat it as one. Twelve exact duplicates are dropped, leaving 41,176 calls. Only 11.3% said yes, so always predicting no would be 88.7% accurate and useless; this part scores with ROC AUC instead.
]

#labquestion(11)[Compare feature sets, and see leakage][
  Four feature sets are compared with the same logistic regression. `SelectKBest` keeps the ten encoded columns whose averages differ most between yes and no, and the L1 penalty shrinks weak coefficients all the way to zero and so selects on its own. Both selectors sit #emph[inside] the pipeline, after encoding, so they only ever see training rows. The fourth run adds `duration` back on purpose, to show what leakage looks like. Average precision is printed beside ROC AUC; with 11% positives, it is the stricter of the two.
]

#labanswer[
  #labcode("lab01_features", 11)

  #readcode[
    - `evaluate` fits a pipeline on the training calls, scores the validation calls with two metrics, and returns the ROC AUC. Writing it once keeps the four runs identical.
    - Run A is the reference: every feature known before the call.
    - Run B adds a step, `("select", SelectKBest(f_classif, k=10))`, after the preparation. It keeps the ten prepared columns with the highest F scores. Because it sits inside the pipeline, those scores are computed from the training calls only.
    - Run C replaces selection by an L1 penalty: `penalty="l1"` with `C=0.03`. A smaller `C` is a stronger penalty, and `solver="liblinear"` is a solver that supports it.
    - Run D puts `duration` back with `assign(duration=...)`, matching rows by their index, to show what a leak does to the scores.
  ]

  #refoutput[
    ```terminal
    all 19 features              ROC AUC = 0.802   average precision = 0.452
    SelectKBest, k=10            ROC AUC = 0.791   average precision = 0.435
    L1 penalty (selects itself)  ROC AUC = 0.801   average precision = 0.449
    all 19 + duration (leakage)  ROC AUC = 0.939   average precision = 0.595
    ```
  ]

  #strong[What it means.] Ten columns do almost as well as all of them, and the L1 penalty matches the full model, so much of the table is noise for this task, and a selector inside the pipeline costs little. Guessing at random scores ROC AUC 0.5 and average precision 0.113, the share of yes answers, which is the true scale of these gains. The leaked column lifts ROC AUC to 0.939. That looks like a triumph and is a broken experiment, because nobody knows how long a call will last before making it. The dataset’s own documentation says the same, and keeps `duration` only for benchmarks.
]

#labquestion(12)[Read what the L1 penalty kept][
  The penalty’s zero coefficients are its selection. List the survivors, and ask whether a bank manager would believe them.
]

#labanswer[
  #labcode("lab01_features", 12)

  #readcode[
    - `named_steps["preprocess"].get_feature_names_out()` lists the prepared columns, such as `cat__month_may`: the step's name, two underscores, then the column and its category.
    - `named_steps["model"].coef_[0]` holds one weight per prepared column. Pairing the two in a `pd.Series` gives every weight its name.
    - `coefs[coefs != 0]` keeps the columns that the penalty did not set to zero.
    - `kept.reindex(kept.abs().sort_values(ascending=False).index)` reorders the survivors from the largest weight to the smallest, ignoring the sign.
  ]

  #refoutput[
    ```terminal
    the L1 penalty kept 21 of 62 encoded columns
    cat__month_may           -0.649
    cat__month_mar            0.558
    num__emp.var.rate        -0.488
    cat__contact_telephone   -0.434
    num__nr.employed         -0.422
    cat__poutcome_failure    -0.368
    ```
  ]

  #strong[What it means.] A third of the encoded columns survive. The strongest are the calendar and the economy. Calls in May did worse and calls in March better, and calls to a landline (`contact_telephone`) did worse than calls to a mobile. A higher employment-variation rate and more people employed (`nr.employed`) went with fewer sign-ups, and customers whose last campaign failed (`poutcome_failure`) said no more often. A manager would believe most of these, but they are associations in this bank’s calls of 2008 to 2010, not causes. The economic columns also stand in for the date, which Your-turn task~4 tests.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - All 19 features score ROC AUC 0.802; adding `duration` jumps to 0.939, and that jump is leakage.
    - The L1 penalty keeps 21 of the 62 encoded columns.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 13--15], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(13)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab01_features", 13)

  #readcode[
    - Each `to_csv` writes one table. `rename(...)` and `rename_axis(...)` give the values and the row labels readable names in the file.
    - `np.r_[customer, near_raw, near_std]` joins one number and two arrays into a single array of row positions.
    - `sorted(p.name for p in RESULTS.iterdir())` lists what is now in the results folder.
  ]

  #refoutput[
    ```terminal
    Saved: ['cancellation_by_days_ahead.csv', 'environment.csv', 'far_ahead_bookings_cancel_most.png',
     'feature_selection.csv', 'hotel_where_the_gaps_are.png', 'l1_coefficients.csv', 'missing_values.csv',
     'neighbors_raw_and_scaled.csv', 'one_customer_two_sets_of_neighbors.png', 'what_the_l1_penalty_kept.png']
    ```
  ]
]

#labsubhead[Try it yourself]

#labquestion(14)[Try it yourself][
  Engineer one more hotel feature, the weekday of arrival (from the `arrival_date` built in Question~3), and check whether the validation ROC AUC in Question~7 improves. Then rerun Question~11’s `SelectKBest` with `k=5` and `k=20` and see whether the score changes. Attempt it in this empty cell before reading the solution.
]

#labquestion(15)[One solution][
  The arrival weekday for the hotel bookings, then the two other `k` values for the bank calls.
]

#labanswer[
  #labcode("lab01_features", 15)

  #readcode[
    - `.dt.day_name()` turns each arrival date into the name of its weekday.
    - `reindex(days)` puts the weekdays in calendar order instead of alphabetical order.
    - The first loop reruns the model of Question~7 with and without the new column. Only the list of text columns changes.
    - The second loop reruns the `SelectKBest` pipeline of Question~11 with three values of `k`.
  ]

  #refoutput[
    ```terminal
    cancellation rate by arrival day: {'Monday': 0.341, 'Tuesday': 0.329, 'Wednesday': 0.361,
     'Thursday': 0.412, 'Friday': 0.406, 'Saturday': 0.395, 'Sunday': 0.323}
    raw + engineered           validation ROC AUC = 0.855
    raw + engineered + weekday validation ROC AUC = 0.856
    SelectKBest, k=5             ROC AUC = 0.775   average precision = 0.419
    SelectKBest, k=10            ROC AUC = 0.791   average precision = 0.435
    SelectKBest, k=20            ROC AUC = 0.799   average precision = 0.442
    ```
  ]

  #strong[What it means.] Arrivals on Thursday and Friday were cancelled most often (41.2% and 40.6%) and arrivals on Sunday least (32.3%), so the weekday carries real signal, yet the validation ROC AUC only moves from 0.855 to 0.856. Much of what the weekday says is probably already in the columns the model has, such as the weekend and week nights. A feature can be informative and still add nothing, which is why the test is the model’s validation score, not the group table. Five, ten and twenty selected columns score 0.775, 0.791 and 0.799, against 0.802 for all of them: the score climbs slowly with `k`, and the exact number matters far less than keeping the selector inside the pipeline.
]

#labpartopen([After the lab], [Your turn, troubleshooting and hand-in], [Your-turn tasks • Expected findings • Troubleshooting • Checklists], [Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.])

#yourturn[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

  + #strong[Two columns to date.] Add `room_changed`, which is 1 when `assigned_room_type` differs from `reserved_room_type`, to the engineered columns of Question~7; then, instead, add `from_portugal`, which is 1 when `country` is `PRT`. What happens to the validation ROC AUC of 0.855 each time? Group the cancellation rate by each new column, read the data card’s note on when the columns were written, and decide whether either could be used the moment a booking is made.
  + #strong[Is this leak harmful here?] Fit the Question~7 preprocessing on #emph[all] the rows, then fit the logistic model on the training rows only. Compare the score with the correct version, and with what happened to pure noise in #secref(<sec:data-leakage>). What do you conclude?
  + #strong[Does scaling change a model?] Predict `Churn` from the three Question~8 columns with `KNeighborsClassifier(73)`, once in raw units and once with a `StandardScaler` in front. Use a stratified 25% validation split with `random_state=42`; 73 is about the square root of the 5,282 training rows. Compare the ROC AUC.
  + #strong[Split by date.] The bank file is stored in date order. Train the Question~11 logistic model on the first 75% of calls and validate on the last 25%. How does the ROC AUC compare with the random split, and what happened to the share of yes answers?
  + #strong[Turn the L1 dial.] Refit the L1 model with `C` 0.001, 0.01 and 1; a smaller `C` is a stronger penalty. How many of the 62 columns survive, and what happens to the score?
]

#expectedfindings[
  #strong[Warm-up.] Booking 14876: `total_nights` 6, `total_guests` 3, `with_children` 1 (the baby counts), `log_lead_time` $ln 133 = 4.89$ and `cancelled_before` 1. All five can be computed the moment the booking is made: they read only this booking’s own fields, and `previous_cancellations` counts cancellations made before it. For the two gaps, 100 beats 12 in raw units; after scaling they are $100\/2266.79=0.04$ and $12\/24.56=0.49$, so the second dominates.

  + `room_changed` lifts the score to 0.868, and `from_portugal` to 0.888. Only 5.4% of the 14,917 bookings given a different room were cancelled, against 41.6% of the rest: rooms are mostly changed when the guest arrives, and a cancelled booking never arrives, so the column partly records the outcome. Domestic bookings were cancelled 56.6% of the time against 23.6%, a real pattern, but the data’s authors warn that hotels often learn a guest’s correct nationality only at check-in, so part of that jump may come from the future too. Neither column is safe until you know when the hotel wrote it, and the file cannot tell you: ask the people who keep the data. Any column recorded after the moment of prediction is a leak, however innocent its name.
  + It stays at 0.855 to three decimals. Medians and scales from 119,390 rows barely differ from those of 89,542 training rows, so this leak does little harm on this table. That does not make it safe: the same habit, applied to selection on all the labels, made pure noise score 0.80. Keep the pipeline, because you cannot know in advance which case you are in.
  + Raw units score 0.778 and standardized 0.815. In raw units the classifier’s neighbors are customers with a similar total bill, which mixes new customers on dear plans with loyal ones on cheap plans; after scaling, tenure and the monthly charge count too.
  + The ROC AUC falls from 0.802 to 0.712. The first 75% of calls had a yes rate of 6.4% and the last 25% one of 25.8%: the later campaigns met a different economy and different customers. A random split mixes the two periods and hides the change, but a model put to work in 2010 would have met it.
  + `C` 0.001 keeps 2 columns, `nr.employed` and `pdays`, with ROC AUC 0.765. `C` 0.01 keeps 12 with 0.794, the lab’s 0.03 keeps 21 with 0.801, and `C` 1 keeps 49 with 0.802. Two columns get most of the way, and a third of the table matches all of it.
]

#troubleshoot[
  / `FileNotFoundError`: A data file is missing or misnamed. Match the names in Chapter~@ch:toolkit, capitals too, and keep `hotel_bookings.zip` zipped: `read_csv` reads the CSV inside it.
  / `No module named 'course_setup'` in Question~1: The notebook is not running inside its lab folder, so `".."` is not `all_experiments/`. Open it from `all_experiments/lab01_features/` in your copy of the course; Jupyter and VS Code then run it there.
  / `FileNotFoundError: No all_datasets/ folder above` …: The notebook was copied out of the course folder. Work on it inside your copy of the course, where `all_datasets/` sits above it.
  / The bank table has one column: A first column named `age;"job";"marital";...` means the file was read with commas. Pass `sep=";"`, as Question~10 does.
  / Question~8 prints `str` instead of `object`: That is pandas 3 against pandas 2. The blanks are still blanks, and no number changes.
  / The L1 coefficients differ in the third decimal: The `liblinear` solver shuffles the rows; keep `random_state=42` in Question~11 to reproduce the sheet.
]

#labchecklists[
  #verification[
    - Package versions are printed, so the run can be reproduced.
    - You read the data card, and you can name the column written after the outcome and say why it never enters a model.
    - Every engineered feature (total nights, total guests, with children, log lead time, cancelled before) exists when the booking is made, and your hand calculation for booking 14876 matches.
    - Imputation, scaling and encoding are fitted inside the training pipeline, and both hotel feature sets use the same split: 0.846 and 0.855.
    - `TotalCharges` is repaired with 0 for the 11 new customers, and you can say why the neighbors of customer 7795-CFOCW change after scaling.
    - Feature selection stays inside the pipeline, and the `duration` run is identified as leakage rather than a better model.
    - `results/lab01/` holds the six tables and four figures listed in Question~13.
  ]
]
