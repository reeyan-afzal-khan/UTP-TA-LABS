#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "00-data-toolkit-eda")

#labsection(0, label: <sec:lab00-data-toolkit-eda>)[Python data toolkit and exploratory data analysis]

#labproject[Meet a table, examine it, and write down what the model must be told][
  #strong[Read first.] Chapter~#ref(<ch:pydata>) and Chapter~#ref(<ch:eda>). Chapter~@ch:toolkit sets up your tools. Part~E fits a logistic regression before its chapter: treat it as a black box for now, since the point here is what you learn about a table before any model sees it. \

  #strong[Goal.] Use NumPy, pandas and Matplotlib to take a table's first measurements, catch the values that cannot be true, study each column alone and against the target, compare columns with each other, and turn the findings into a first model that is scored honestly. \

  #strong[Scenario.] A clinic hands you a table of 918 patients and asks whether routine measurements could flag heart disease. The table has no blank cells and looks ready to use. It is not, and nothing in the file says so: you have to find out by looking. \

  #strong[Data.] In `all_datasets/supervised/heart_disease/`: `heart_disease.csv`, 918 patients examined at five hospitals, with eleven clinical measurements and a diagnosis. The `README.md` beside it is its data card. \

  #strong[Notebook.] `all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, the `results/lab00/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Load the table, take its first measurements, and catch the values that cannot be true],
  [2--5],
  [B],
  [Seal a test set, then study one column at a time: shape, five numbers, fences, counts],
  [6--9],
  [C],
  [Compare each column, and each gap, with the target],
  [10--12],
  [D],
  [Compare columns with each other, and watch a correlation change sign],
  [13--14],
  [E],
  [Turn the findings into baselines, a pipeline and one honest test score],
  [15--17],
  [Finish],
  [Save the evidence; then examine women and men separately yourself],
  [18--20],
  [After],
  [Your-turn tasks, expected findings, troubleshooting and the checklist],
  [---],
)

#labmode[
  + Activate your course environment (Chapter~@ch:toolkit) and confirm that `heart_disease.csv` is in `all_datasets/supervised/heart_disease/`.
  + Warm up on the chapter's toolkit script. From the course folder, run the first command below. Its last line must read `Every number above matches the book.`
  + From the course folder, start Jupyter, open `all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.ipynb`, and choose #strong[Restart Kernel and Run All Cells]. It takes about ten seconds.

  ```terminal
  python all_experiments/book_checks/demo_data_toolkit.py
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.py` runs the same code and writes the same evidence. In the script each cell starts with a line such as `# %% Question 4 - Could every value be real?`, so you can find any question, and editors such as VS Code can run the cells one at a time.
]

#labroutine

#strong[How each answer is laid out.] Under every question you will find the code of that cell, then #strong[Read the code], which explains its lines in the order they run, then the #strong[Reference output], and last #strong[What it means]. Type the code yourself the first time; reading it is not the same as writing it.

#yourturn[
  #strong[Warm-up on paper.] Do these before opening the notebook; the code will check you.

  + Seven cholesterol readings are 0, 180, 200, 220, 240, 260 and 300, and the 0 means "not measured". Work out the mean and the median with the zero, and again without it. Which of the two summaries moved more? Question~7 shows the same effect on 734 patients.
  + A column has $Q_1 = 210$ and $Q_3 = 277$. Where do the two fences of its box plot sit? Is a reading of 380 beyond a fence? Question~8 prints both fences.
  + In a group of 40 patients, 45% have a disease. Two standard errors of a rate $p$ measured on $n$ patients are $1.96 sqrt(p(1-p)\/n)$. Between which two percentages could the true rate plausibly lie? Question~11 prints this for every group.
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way: the course helper, the libraries, and the three folders the lab uses.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 1)

  #readcode[
    - `sys.path.insert(0, "..")` lets Python import `course_setup.py` from the folder above this lab's own.
    - `import numpy as np` and `import pandas as pd` give the two libraries the short names used throughout the book.
    - Each `from sklearn...` line pulls in one tool by name. Every tool is explained at the question that first uses it.
    - `start_lab("lab00")` returns three folders: `DATA` to read from, and `RESULTS` and `MODELS` to write to.
  ]

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab00/ and models/
    ```
  ]
]

#labpartopen([Part~A], [First contact with a table], [Questions~2--5 • Data: heart disease and its data card], [Load the heart table, learn what every column means, and find the values that no patient could have.])

#labquestion(2)[Read the data card, then the table][
  A professional reads the data dictionary before the data. The data card, the `README.md` beside the file, says what each column means and in which units. The cell prints the card's column meanings, loads the table, and shows its size and its first three patients.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 2)

  #readcode[
    - `read_text()` loads the card as one long string. The loop walks through the lines of its column table and splits each line on `" | "` to pick out the column's name and meaning.
    - `pd.read_csv(...)` reads the file into a DataFrame. `DATA / "supervised/..."` joins folder names in a way that works on every operating system.
    - `heart.shape` is the pair (rows, columns).
    - `heart.head(3)` is the first three rows. `.T` turns the result on its side, so each column of the table becomes a line and nothing is cut off.
  ]

  #refoutput[
    ```terminal
    Age             age in years
    Sex             `M` or `F`
    ChestPainType   `TA` typical angina, `ATA` atypical angina, `NAP` non-anginal pain, `ASY` no chest pain
    RestingBP       resting blood pressure in mm Hg; 0 means not measured
    Cholesterol     serum cholesterol in mg/dl; 0 means not measured
    FastingBS       1 if fasting blood sugar is above 120 mg/dl
    RestingECG      resting electrocardiogram: `Normal`, `ST` (ST-T wave abnormality) or `LVH` (thickened left
        ventricle)
    MaxHR           highest heart rate reached in the exercise test, beats per minute
    ExerciseAngina  chest pain brought on by exercise: `Y` or `N`
    Oldpeak         how far the ST segment of the ECG drops during exercise, in mm
    ST_Slope        slope of the ST segment at peak exercise: `Up`, `Flat` or `Down`
    HeartDisease    1 if diagnosed with heart disease: the label
    
    shape: (918, 12)
                         0       1    2
    Age                 40      49   37
    Sex                  M       F    M
    ChestPainType      ATA     NAP  ATA
    RestingBP          140     160  130
    Cholesterol        289     180  283
    FastingBS            0       0    0
    RestingECG      Normal  Normal   ST
    MaxHR              172     156   98
    ExerciseAngina       N       N    N
    Oldpeak            0.0     1.0  0.0
    ST_Slope            Up    Flat   Up
    HeartDisease         0       1    0
    ```
  ]

  #strong[What it means.] 918 patients, one per row, and 12 columns. Patient 0 is a 40-year-old man with atypical angina, a blood pressure of 140, a cholesterol of 289 and a top heart rate of 172, and he does not have heart disease. Read the card's lines for `RestingBP` and `Cholesterol` once more before the next question: they say what a zero means.
]

#labquestion(3)[Types, blanks, repeats and distinct values][
  Take three quick measurements of every column: its type, how many of its cells are blank, and how many different values it holds. The last one decides how a column is treated. A column with two to four distinct values is a category, even when it is stored as a number.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 3)

  #readcode[
    - A DataFrame can be built from a dictionary: each key becomes a column name and each value a column. `heart.dtypes`, `heart.isna().sum()` and `heart.nunique()` each give one entry per column of `heart`, so they line up as three columns of the overview.
    - `isna()` gives `True` for a blank cell, and `.sum()` counts the `True`s in each column.
    - `duplicated()` marks a row that repeats an earlier row exactly.
    - The two list comprehensions sort the column names into `categories` (four distinct values or fewer) and `numbers` (the rest), leaving out the target. Every later question reuses these two lists.
    - `heart[target].mean()` is the share of ones in a column of zeros and ones.
  ]

  #refoutput[
    ```terminal
                       type  blank  distinct
    Age               int64      0        50
    Sex              object      0         2
    ChestPainType    object      0         4
    RestingBP         int64      0        67
    Cholesterol       int64      0       222
    FastingBS         int64      0         2
    RestingECG       object      0         3
    MaxHR             int64      0       119
    ExerciseAngina   object      0         2
    Oldpeak         float64      0        53
    ST_Slope         object      0         3
    HeartDisease      int64      0         2
    
    repeated rows: 0
    numbers:    ['Age', 'RestingBP', 'Cholesterol', 'MaxHR', 'Oldpeak']
    categories: ['Sex', 'ChestPainType', 'FastingBS', 'RestingECG', 'ExerciseAngina', 'ST_Slope']
    share with heart disease: 0.553
    ```
  ]

  #strong[What it means.] No blank cells and no repeated rows. Five columns are numbers and six are categories: `FastingBS` is stored as an integer but takes only the values 0 and 1, so it joins the categories. 55.3% of the patients have heart disease. The two classes are close to balanced, and always guessing #emph[disease] would already be 55.3% accurate.
]

#labquestion(4)[Could every value be real?][
  A table with no blanks can still have missing values. Print the smallest, the middle and the largest value of each number column, and ask of each one: could a living patient have this value?
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 4)

  #readcode[
    - `describe()` summarizes every number column, and `.loc[["min", "50%", "max"]]` keeps three of its rows. `"50%"` is the median.
    - `heart["RestingBP"] == 0` compares every row with 0 and gives a column of `True` and `False`: a mask.
    - The `.sum()` of a mask counts the rows where it is `True`, and its `.mean()` is their share. The format `:.1%` prints a share as a percentage with one decimal.
    - `heart.loc[no_pressure, [...]]` selects rows with the mask and columns with a list of names.
  ]

  #refoutput[
    ```terminal
          Age  RestingBP  Cholesterol  MaxHR  Oldpeak
    min  28.0        0.0          0.0   60.0     -2.6
    50%  54.0      130.0        223.0  138.0      0.6
    max  77.0      200.0        603.0  202.0      6.2
    
    blood pressure of 0: 1   cholesterol of 0: 172 (18.7% of the patients)   negative Oldpeak: 13
         Age Sex  RestingBP  Cholesterol  MaxHR  HeartDisease
    449   55   M          0            0    155             1
    ```
  ]

  #strong[What it means.] The minimum of `RestingBP` and of `Cholesterol` is 0, which no living person has. One patient has a blood pressure of 0, and 172 patients, 18.7% of the table, have a cholesterol of 0. The data card says what this means: the value was not measured. The single patient with no blood pressure, row 449, has no cholesterol reading either. `Oldpeak` is negative for 13 patients. The card does not call that impossible, so those values stay.
]

#labquestion(5)[See the zeros, then mark them as missing][
  Draw the suspicious column, repair it, and write down what you did. The repair replaces each impossible zero with `NaN`, the marker pandas uses for a missing value. It is a fixed rule that comes from the meaning of the column, not from any statistic of the data, so it may run before the table is split. No row is dropped.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 5)

  #readcode[
    - `raw = heart.copy()` keeps an untouched copy, because the next lines change `heart` itself. Later questions compare the two.
    - `replace(0, np.nan)` swaps every 0 in the column for a missing value, and assigning the result back to `heart[column]` stores it.
    - `plt.subplots(1, 2, sharey=True)` makes one row of two charts with a shared vertical scale. `bins=np.arange(0, 651, 25)` cuts cholesterol into bands 25 mg/dl wide.
    - `dropna()` leaves the missing values out of the second histogram.
    - The `cleaning_log` dictionary records each rule and how many cells it touched.
    - `blanks[blanks > 0]` is a mask again, this time on a column of counts: it keeps the columns that now have blanks.
  ]

  #refoutput[
    ```terminal
    {'rows': 918, 'RestingBP zeros marked missing': 1, 'Cholesterol zeros marked missing': 172, 'rows dropped':
        0}
    blank cells now: {'RestingBP': 1, 'Cholesterol': 172}
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/cholesterol_before_and_after.png", width: 96%, height: 4.6cm)
  ]

  #strong[What it means.] The left chart has a bar of 172 patients standing alone at 0, far from everyone else. The right chart is the same column without them: one hump with a tail to the right. The table now has 173 blank cells, 1 in `RestingBP` and 172 in `Cholesterol`, and still has 918 rows. From here on pandas leaves the blanks out of every mean and histogram, and the pipeline of Part~E decides how to fill them.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 918 patients and 12 columns: five numbers, six categories and the target. 55.3% have heart disease.
    - The table had no blank cells, yet 173 values were missing: 172 cholesterol readings and 1 blood pressure were stored as 0.
    - You can say why this repair may run before the split, and why no row was dropped.
  ]
]

#labpartopen([Part~B], [One column at a time], [Questions~6--9 • Data: the 734 training patients], [Set the test patients aside, then describe each column of the training patients: its shape, its five numbers, its extremes and its counts.])

#labquestion(6)[Seal a test set][
  Everything so far asked what the columns are. The rest of the lab asks how they relate to the answer, and those relationships are what a model learns. Set a fifth of the patients aside now, and do not look at them again until Question~17. If you study relationships on every row, your choices will have seen the test rows, and the final score will flatter them.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 6)

  #readcode[
    - `train_test_split` shuffles the rows and cuts them in two. `test_size=0.2` puts 20% of them in the test set.
    - `stratify=heart[target]` keeps the share of heart disease the same in both parts, and `random_state=42` fixes the shuffle, so everyone gets the same split.
    - `raw.loc[train.index]` picks the same training patients out of the untouched copy. `train.index` holds their row labels.
  ]

  #refoutput[
    ```terminal
    training patients: 734   test patients: 184
    share with heart disease: training 0.553   test 0.554
    ```
  ]

  #strong[What it means.] 734 patients to learn from and 184 sealed away, with the same disease rate on both sides, 55.3% and 55.4%. Every number from here to Question~16 is computed on the 734.
]

#labquestion(7)[The shape of each number column][
  A summary compresses a column into a few numbers, and a histogram shows all of it. Draw the five number columns, and print the mean, the median and the skewness of each. Skewness is 0 for a symmetric column, positive when the long tail points right and negative when it points left.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 7)

  #readcode[
    - `plt.subplots(1, 5)` returns five charts, and `zip(axes, numbers)` pairs each chart with a column name, so one loop draws all five.
    - The `f"..."` string builds each title, and `{train[column].skew():.2f}` prints the skewness with two decimals.
    - `describe().loc[[...]].T` keeps three rows of the summary and turns them on their side, one line per feature. `count` is the number of values that are not missing.
    - The next lines recompute cholesterol on `raw_train`, the same patients with the zeros still in.
    - `train["RestingBP"] % 10 == 0` is a mask for readings that are a multiple of 10: `%` gives the remainder of a division.
  ]

  #refoutput[
    ```terminal
                 count    mean    50%  skew
    Age          734.0   53.85   55.0 -0.21
    RestingBP    734.0  132.87  130.0  0.63
    Cholesterol  605.0  246.56  238.0  1.24
    MaxHR        734.0  136.38  138.0 -0.19
    Oldpeak      734.0    0.87    0.5  0.95
    
    cholesterol with the zeros left in: mean 203.2  skew -0.64
    share of Oldpeak that is exactly 0: 0.414
    share of blood pressures that are a multiple of 10: 0.642
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/the_shape_of_each_number_column.png", width: 96%, height: 3.1cm)
  ]

  #strong[What it means.] `Age` and `MaxHR` are close to symmetric. Cholesterol has 605 values, a mean of 246.56 and a skew of 1.24. With the zeros left in, the same column had a mean of 203.2 and a skew of −0.64: the repair moved the mean by 43 mg/dl and reversed the direction of the tail. `Oldpeak` is a pile and a tail, with 41.4% of its values exactly 0. `RestingBP` shows tall thin spikes, because 64.2% of the readings are a multiple of 10. Blood pressures are not really that tidy: someone read a gauge by eye and rounded. A histogram shows how a column was measured as well as what was measured.
]

#labquestion(8)[Five numbers, fences and box plots][
  Five numbers describe a column without assuming any shape: the minimum, the first quartile Q1, the median, the third quartile Q3 and the maximum. A box plot draws them. Its fences sit one and a half box-lengths beyond the box, its whiskers stop at the last value inside each fence, and every value beyond a fence is drawn as a dot. Compute all of this for each column, then compare with the rival rule that flags values more than three standard deviations from the mean.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 8)

  #readcode[
    - `quantile([0.25, 0.50, 0.75])` returns the three quartiles at once, and the three names on the left unpack them.
    - `(values < low_fence) | (values > high_fence)` joins two masks with `|`, which means "or". Each mask needs its own parentheses.
    - The function returns a `pd.Series` with named entries. That lets `train[numbers].apply(five_numbers)` build a table by calling the function once per column, and `.T` puts one feature on each line.
    - `z` rewrites every value as a number of standard deviations from its column's mean. It uses broadcasting: a table minus a row of means. `z.abs() > 3` is then a table of masks, and `.sum()` counts per column.
    - `ax.boxplot(..., vert=False)` draws a horizontal box plot. It needs the missing values dropped first.
  ]

  #refoutput[
    ```terminal
                  min     Q1  median     Q3    max  low fence  high fence  outside
    Age          29.0   47.0    55.0   61.0   77.0      26.00       82.00      0.0
    RestingBP    92.0  120.0   130.0  141.0  200.0      88.50      172.50     20.0
    Cholesterol  85.0  210.0   238.0  277.0  603.0     109.50      377.50     20.0
    MaxHR        60.0  119.0   138.0  156.0  202.0      63.50      211.50      2.0
    Oldpeak      -2.6    0.0     0.5    1.5    5.6      -2.25        3.75     13.0
    
    beyond 3 standard deviations: {'Age': 0, 'RestingBP': 6, 'Cholesterol': 7, 'MaxHR': 0, 'Oldpeak': 6}
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/box_plots_of_the_number_columns.png", width: 96%, height: 2.5cm)
  ]

  #strong[What it means.] For cholesterol, Q1 is 210, the median 238 and Q3 277, so the box is 67 wide and the fences sit at 109.5 and 377.5. Twenty readings lie outside them. The fence rule flags 20 blood pressures, 20 cholesterol readings, 2 heart rates and 13 `Oldpeak` values, while the three-standard-deviation rule flags 6, 7, 0 and 6. The two rules disagree because the mean and the standard deviation are themselves pulled by the extreme values they are meant to judge. None of these values is impossible, so none is removed. A cholesterol of 603 is a patient, and probably one the model matters for.
]

#labquestion(9)[Count the categories][
  For a category the summary is a count per value. Two questions matter. Is any value spelled two ways? And is any value so rare that a rate computed from it will be mostly luck?
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 9)

  #readcode[
    - `value_counts()` counts how often each value occurs, the most frequent first, and `.plot.bar(ax=ax)` draws those counts on the chart you pass in.
    - `to_dict()` turns the counts into `{value: count}`, so that each column fits on one printed line.
    - The `min(...)` line builds one tuple per category column, holding the size of its smallest group, the column and the value, and keeps the smallest tuple. Tuples compare by their first entry.
  ]

  #refoutput[
    ```terminal
    Sex             {'M': 579, 'F': 155}
    ChestPainType   {'ASY': 403, 'NAP': 155, 'ATA': 136, 'TA': 40}
    FastingBS       {0: 566, 1: 168}
    RestingECG      {'Normal': 447, 'LVH': 146, 'ST': 141}
    ExerciseAngina  {'N': 434, 'Y': 300}
    ST_Slope        {'Flat': 374, 'Up': 313, 'Down': 47}
    
    smallest group: TA in ChestPainType, 40 patients (5.4%)
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/how_often_each_category_occurs.png", width: 96%, height: 2.7cm)
  ]

  #strong[What it means.] No category is spelled two ways. Men are 579 of the 734 patients, 79%. Chest pain is `ASY`, no pain, for 403 patients, more than half. The smallest group anywhere is typical angina, `TA`, with 40 patients, 5.4% of the table, and `Down` in `ST_Slope` has 47. Remember those two groups at Question~11.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - 734 training patients and 184 test patients, both with about 55% heart disease.
    - Marking the zeros as missing moved the mean cholesterol from 203.2 to 246.6 and its skew from −0.64 to 1.24.
    - The cholesterol fences are 109.5 and 377.5, and 20 readings lie outside them. You can say why they stay in the table.
    - The smallest category, typical angina, has 40 patients.
  ]
]

#labpartopen([Part~C], [Each column against the target], [Questions~10--12 • Data: the 734 training patients], [Find out which columns, and which gaps, change what you expect of the answer, and how far each finding can be trusted.])

#labquestion(10)[Numbers against the target][
  Now ask whether a column tells you anything about the answer. Split the patients by the target and compare each number column in the two groups, first by its mean and then on a chart, because two groups with different means can still overlap almost completely.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 10)

  #readcode[
    - `train.groupby(target)[numbers].mean()` splits the patients into those without heart disease (0) and with it (1), and averages each number column inside each group.
    - The inner loop draws two histograms on the same chart. `alpha=0.6` makes the bars see-through, so the overlap is visible, and `label=` names each group for the legend.
    - `train.loc[low, target].mean()` is the pattern "the rate of the target among the rows that pass a test". You will write it many times.
  ]

  #refoutput[
    ```terminal
                    Age  RestingBP  Cholesterol   MaxHR  Oldpeak
    HeartDisease
    0             51.28     130.82       241.91  148.07     0.42
    1             55.92     134.53       251.61  126.93     1.22
    
    disease rate when the highest heart rate is under 120: 0.793  at 150 or more: 0.322
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/numbers_against_the_target.png", width: 96%, height: 3.9cm)
  ]

  #strong[What it means.] Patients with heart disease are older by about five years (55.92 against 51.28), reach a top heart rate 21 beats lower (126.93 against 148.07) and have an `Oldpeak` nearly three times as large (1.22 against 0.42). Blood pressure and cholesterol hardly differ. The histograms show two humps that are shifted but overlap: 79.3% of the patients whose heart rate stayed under 120 have the disease, against 32.2% of those who reached 150, and in between the column alone cannot say.
]

#labquestion(11)[Categories against the target: a rate and a count][
  For a category, compute the share of each group that has the disease, and always print the size of the group beside it. The last column of the table says how far each rate could be off by chance: two standard errors either way, where the standard error of a rate p measured on n patients is the square root of p(1 − p)/n.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 11)

  #readcode[
    - `agg(patients="size", disease_rate="mean")` computes two summaries per group and names each new column on the left of its `=`.
    - The `give_or_take` line is arithmetic on whole columns: `np.sqrt` takes the square root of every entry at once.
    - `pd.concat({...}, names=[...])` stacks the six small tables into one, labelled by column and value.
    - `ax.bar(..., yerr=..., capsize=3)` draws each bar with an error bar of that half-height.
    - `ax.axhline(...)` adds a horizontal line at the overall disease rate, so each bar reads as above or below average.
  ]

  #refoutput[
    ```terminal
                           patients  disease_rate  give_or_take
    column         value
    Sex            F            155         0.284         0.071
                   M            579         0.625         0.039
    ChestPainType  ASY          403         0.787         0.040
                   ATA          136         0.140         0.058
                   NAP          155         0.335         0.074
                   TA            40         0.450         0.154
    FastingBS      0            566         0.482         0.041
                   1            168         0.792         0.061
    RestingECG     LVH          146         0.575         0.080
                   Normal       447         0.512         0.046
                   ST           141         0.660         0.078
    ExerciseAngina N            434         0.350         0.045
                   Y            300         0.847         0.041
    ST_Slope       Down          47         0.830         0.107
                   Flat         374         0.832         0.038
                   Up           313         0.179         0.042
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/disease_rate_in_each_category.png", width: 96%, height: 2.8cm)
  ]

  #strong[What it means.] These categories separate the patients far better than any number did. With an `Up` slope the disease rate is 17.9%, and with a `Flat` one it is 83.2%. With chest pain during exercise it is 84.7%, against 35.0% without. One result looks backwards: patients with no chest pain, `ASY`, have the highest rate, 78.7%. People are sent for a heart examination for a reason, and those who arrive without chest pain were usually sent because of something more serious. Now read the last column. The 45.0% for typical angina rests on 40 patients and could be off by 15 points either way, while the 78.7% for `ASY` rests on 403 patients and is good to 4 points.
]

#labquestion(12)[A gap against the target][
  One more column deserves a comparison with the target: the fact that a value is missing. If the patients without a cholesterol reading are like everyone else, the gap is harmless. If they are not, the gap is information.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 12)

  #readcode[
    - `isna()` gives `True` where cholesterol is missing, and `.rename(...)` gives that column of `True` and `False` a readable name for the table.
    - `pd.crosstab(a, b)` counts the rows for every combination of two columns.
    - `~not_measured` flips the mask: `~` means "not".
  ]

  #refoutput[
    ```terminal
    HeartDisease                0    1
    cholesterol not measured
    False                     315  290
    True                       13  116
    
    disease rate when cholesterol was not measured: 0.899   when it was: 0.479
    ```
  ]

  #strong[What it means.] Of the 129 training patients with no cholesterol reading, 116 have heart disease: 89.9%, against 47.9% of the 605 who were measured. The gap is not random. The table joins five hospitals, and the zeros come from the ones that did not record cholesterol and whose patients were sicker. A model should be told that the value was missing, which Question~16 does with a flag column.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - Heart rate, age and `Oldpeak` differ between the two groups, while blood pressure and cholesterol hardly do.
    - An `Up` ST slope goes with a disease rate of 17.9%, and a `Flat` one with 83.2%.
    - The rate for typical angina, 45.0% on 40 patients, could be off by 15 points either way.
    - 89.9% of the patients with no cholesterol reading have heart disease, against 47.9% of the rest.
  ]
]

#labpartopen([Part~D], [Columns against each other], [Questions~13--14 • Data: the 734 training patients], [Measure how the number columns move together, and see how the zeros of Part~A would have invented a relationship.])

#labquestion(13)[Correlations, computed twice][
  A correlation puts one number between −1 and 1 on how two number columns move together along a straight line. Compute the whole table twice, once on the patients as they arrived and once with the zeros marked as missing, and compare the cholesterol column of the two.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 13)

  #readcode[
    - `.corr()` computes the correlation of every pair of columns in the table. Blank cells are left out, pair by pair.
    - The small DataFrame puts the `Cholesterol` column of both tables side by side.
    - `ax.imshow(table, cmap="RdBu_r", vmin=-1, vmax=1)` paints a grid of colours, red for positive and blue for negative. This is a heatmap.
    - The two nested `for` loops write each number on top of its cell with `ax.text`, in white where the cell is dark.
  ]

  #refoutput[
    ```terminal
                  zeros left in  zeros as missing
    Age                   -0.10              0.03
    RestingBP              0.08              0.10
    Cholesterol            1.00              1.00
    MaxHR                  0.26              0.00
    Oldpeak                0.09              0.06
    HeartDisease          -0.24              0.08
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/correlations_with_and_without_the_zeros.png", width: 96%, height: 5.6cm)
  ]

  #strong[What it means.] With the zeros left in, cholesterol has a correlation of −0.24 with heart disease: higher cholesterol, less disease. Mark the zeros as missing and it becomes +0.08, small and in the direction a doctor expects. The correlation of 0.26 with `MaxHR` falls to 0.00. Both relationships were produced by 129 zeros that belong to sick patients and sit at the bottom of the scale. In the repaired table the strongest pairs are `MaxHR` with heart disease (−0.41), age with `MaxHR` (−0.40) and `Oldpeak` with heart disease (0.38). Nothing is near ±0.9, so no column simply repeats another.
]

#labquestion(14)[Two numbers and the target on one chart][
  A scatter plot shows two numbers at once, and colour adds the target. Then draw one chart for all five numbers: put every column on the same scale, stack the columns into one long table with `melt`, and draw a pair of box plots per column.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 14)

  #readcode[
    - The first loop draws the two groups one after the other, so that each gets its own colour and legend entry. `s=10` is the size of a dot.
    - `standard` holds each value as a number of standard deviations from its column's mean, so that five columns with different units fit on one axis.
    - `assign(HeartDisease=...)` adds the target as a column. `melt(id_vars=target, ...)` then turns the five number columns into two: `column`, which names the feature, and `standard units`, which holds the value. 734 rows become 3,670.
    - `long.loc[(...) & (...), "standard units"]` selects one feature in one class. The list comprehension collects five such groups, and `boxplot(groups, positions=...)` draws them side by side, shifted left for one class and right for the other.
  ]

  #refoutput[
    ```terminal
       HeartDisease column  standard units
    0             1    Age        0.969351
    1             0    Age        0.121945
    2             1    Age        0.545648
    rows: 734 patients x 5 columns = 3670
    correlation of age with highest heart rate: -0.4
    ```
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/results/lab00/two_numbers_and_the_target.png", width: 96%, height: 4.6cm)
  ]

  #strong[What it means.] The cloud of the scatter plot slopes downwards: older patients reach lower heart rates, a correlation of −0.40. The orange dots, the patients with heart disease, sit lower and further right. In the second chart the two boxes are furthest apart for `MaxHR` and `Oldpeak` and nearly level for blood pressure and cholesterol, which is the table of Question~10 as a picture.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The correlation of cholesterol with heart disease is −0.24 with the zeros left in and +0.08 with the zeros marked as missing.
    - No pair of columns is correlated beyond ±0.41, so no column repeats another.
    - `melt` turned 734 rows and 5 columns into 3,670 rows.
  ]
]

#labpartopen([Part~E], [From findings to a first model], [Questions~15--17 • Data: the training patients, then the 184 test patients], [Set the bar with two baselines, build a pipeline that carries out the decisions of Parts A to D, and open the test set once.])

#labquestion(15)[Two baselines that need no fitting][
  Before fitting anything, set the bar. The first baseline gives every patient the more common answer. The second is one sentence read off the rate table of Question~11: predict heart disease unless the ST slope is `Up`.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 15)

  #readcode[
    - `np.ones(len(train), dtype=int)` is an array of 1s, one per training patient: the prediction "disease" for everyone.
    - `train["ST_Slope"] != "Up"` is a mask, and `.astype(int)` turns its `True` and `False` into 1 and 0, which makes it a prediction.
    - `accuracy_score(truth, prediction)` is the share of patients on whom the two agree.
    - The crosstab shows where the rule is right and where it is wrong.
  ]

  #refoutput[
    ```terminal
    always say disease: 0.553
    one rule on ST_Slope: 0.827
    HeartDisease    0    1
    ST_Slope
    Down            8   39
    Flat           63  311
    Up            257   56
    ```
  ]

  #strong[What it means.] Always answering #emph[disease] is right for 55.3% of the training patients. The one-sentence rule is right for 82.7%: of the 313 patients with an `Up` slope, 257 have no disease, and of the 421 others, 350 do. Any model worth building has to beat 82.7%, not 55.3%.
]

#labquestion(16)[A pipeline, scored by cross-validation][
  Now a real model: a logistic regression inside a pipeline that carries out the decisions of the exploration. It fills missing numbers with the median, scales the numbers, and one-hot encodes the six categories. Treat the model itself as a black box for now; the chapter on linear models for classification opens it. Three versions are compared by five-fold cross-validation: the table as it arrived, the zeros marked as missing, and the zeros marked as missing together with a flag column that says so. For each version the cell also prints the weight the model gives to cholesterol.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 16)

  #readcode[
    - `SimpleImputer(strategy="median", add_indicator=flag_missing)` fills each blank with its column's median. With `add_indicator=True` it also adds a 0/1 column saying where the blanks were.
    - `StandardScaler()` rescales each number column to mean 0 and standard deviation 1, and `OneHotEncoder` turns each category into one 0/1 column per value.
    - `ColumnTransformer` applies the number steps to the `numbers` columns and the encoder to the `categories` columns. `Pipeline` chains preparation and model into one object, so whatever is learned is learned from the rows passed to `fit` and from nothing else.
    - `StratifiedKFold(5, shuffle=True, random_state=42)` cuts the training patients into five parts. `cross_val_score` fits on four of them and scores on the fifth, five times, and returns the five scores.
    - `fitted.named_steps["model"].coef_[0]` holds one weight per prepared column and `get_feature_names_out()` their names. `filter(like="Cholesterol")` keeps the cholesterol ones.
  ]

  #refoutput[
    ```terminal
    zeros left in            accuracy 0.853 (+/- 0.041)  ROC AUC 0.925  {'Cholesterol': -0.49}
    zeros as missing         accuracy 0.847 (+/- 0.030)  ROC AUC 0.922  {'Cholesterol': 0.05}
    zeros as missing + flag  accuracy 0.857 (+/- 0.039)  ROC AUC 0.928  {'Cholesterol': 0.04,
        'missingindicator_Cholesterol': 0.71}
    ```
  ]

  #strong[What it means.] All three versions score about 85%, three points above the one-sentence rule. Their accuracies differ by one point, well inside the spread of three to four points between folds, so the score cannot tell them apart. The weights can. With the zeros left in, cholesterol gets a weight of −0.49: the model has learned that low cholesterol predicts heart disease, because zero is the lowest value there is. With the zeros marked as missing and a flag added, the weight on cholesterol itself is 0.04 and the flag carries 0.71: #emph[not having been measured] is what goes with the disease. The first model scores as well and has learned something false, and it would fail at any hospital that measures every patient.
]

#labquestion(17)[Open the test set, once][
  The procedure is chosen: zeros as missing, with a flag. Fit it on all 734 training patients and open the test set once. Report accuracy, ROC AUC and the confusion matrix, and, because the exploration found that four patients in five are men, report the two sexes separately.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 17)

  #readcode[
    - `predict_proba(...)[:, 1]` is the model's probability of heart disease for each test patient. Column 0 would be the probability of no disease.
    - `chance >= 0.5` turns the probabilities into yes or no answers at a threshold of one half.
    - `confusion_matrix(truth, prediction)` counts the four outcomes. Its rows are the truth and its columns the prediction.
    - `roc_auc_score` takes the probabilities, not the yes or no answers, because it measures how well the model ranks patients.
    - `(test["Sex"] == sex).to_numpy()` is a mask as a plain array, used to pick the matching entries of `y_test` and `predicted`.
  ]

  #refoutput[
    ```terminal
    test accuracy: 0.897   test ROC AUC: 0.932
                predicted no  predicted yes
    no disease            71             11
    disease                8             94
    men    146 test patients  accuracy 0.890  disease rate 0.658
    women   38 test patients  accuracy 0.921  disease rate 0.158
    ```
  ]

  #strong[What it means.] The model is right for 165 of the 184 test patients, 89.7%, with a ROC AUC of 0.932. It raises 11 false alarms among the 82 healthy patients and misses 8 of the 102 who have the disease. By sex it scores 89.0% on 146 men and 92.1% on 38 women. Do not read much into that gap. Thirty-eight patients is a small group, and only 15.8% of the women in the test set have the disease, so always answering #emph[no disease] would already score 84.2% on them. A result for a small group needs its count and its own baseline beside it.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The bar to beat: 55.3% for always answering disease, and 82.7% for one rule on the ST slope.
    - The three pipelines score 0.853, 0.847 and 0.857, but only the last gives cholesterol a believable weight.
    - On the sealed test set: accuracy 0.897, ROC AUC 0.932, 11 false alarms and 8 misses.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions~18--20], [Write the results folder and the exploration log, then extend the examination yourself before reading one worked solution.])

#labquestion(18)[Save the evidence][
  Write the tables to the results folder, together with the exploration log: each thing you saw, and what the pipeline does about it. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 18)

  #readcode[
    - `to_csv(path)` writes a table to a file. `index=False` leaves out the row labels when they carry no information.
    - `pd.Series(cleaning_log, name="count")` turns the dictionary of Question~5 into a column, so that it can be saved.
    - The exploration log is built from a list of tuples, one per finding, with the column names given once.
    - `RESULTS.iterdir()` lists the files in the folder, and `sorted(...)` puts their names in order.
  ]

  #refoutput[
    ```terminal
    Saved: ['box_plots_of_the_number_columns.png', 'cholesterol_before_and_after.png',
        'cholesterol_correlations.csv', 'cleaning_log.csv', 'column_overview.csv',
        'correlations_with_and_without_the_zeros.png', 'disease_rate_by_category.csv',
        'disease_rate_in_each_category.png', 'exploration_log.csv', 'five_number_summaries.csv',
        'how_often_each_category_occurs.png', 'metrics.csv', 'model_comparison.csv',
        'numbers_against_the_target.png', 'the_shape_of_each_number_column.png',
        'two_numbers_and_the_target.png']
    ```
  ]

  #strong[What it means.] Sixteen files: eight figures and eight tables. Open `exploration_log.csv`: it is the examination of this table on one page, and the pipeline of Question~16 does exactly what it says.
]

#labsubhead[Try it yourself]

#labquestion(19)[Try it yourself][
  The exploration found that men are four patients in five, so every rate so far is mostly a rate for men. First, compute the disease rate by chest pain type separately for women and for men, with the number of patients in each group. Second, `Oldpeak` is exactly 0 for 41.4% of the training patients: add a column `any_drop`, which is 1 when `Oldpeak` is above 0, and check whether it improves the cross-validated accuracy of Question~16.

  Attempt it in the cell below before reading the solution.
]

#labquestion(20)[One solution][
  The rate table once per sex, then the pipeline of Question~16 with one more number column.
]

#labanswer[
  #labcode("lab00_data_toolkit_eda", 20)

  #readcode[
    - `train[train["Sex"] == sex]` keeps the patients of one sex, and the same `groupby(...).agg(...)` as in Question~11 then runs on that smaller table.
    - `table.assign(any_drop=...)` returns a copy of the table with one more column and leaves `train` itself unchanged.
    - `make_model_with(extra)` is the pipeline of Question~16 with the list of number columns made longer by `extra`.
  ]

  #refoutput[
    ```terminal
    women - overall disease rate 0.284
                   patients  disease_rate
    ChestPainType
    ASY                  59         0.576
    ATA                  47         0.085
    NAP                  40         0.125
    TA                    9         0.111
    
    men - overall disease rate 0.625
                   patients  disease_rate
    ChestPainType
    ASY                 344         0.823
    ATA                  89         0.169
    NAP                 115         0.409
    TA                   31         0.548
    
    as in Question 16      accuracy 0.857 (+/- 0.039)
    with any_drop added    accuracy 0.858 (+/- 0.032)
    disease rate with no drop: 0.361   with a drop: 0.699
    ```
  ]

  #strong[What it means.] Women have a much lower disease rate than men, 28.4% against 62.5%, and the order of the chest pain types is the same for both: no chest pain is the worst sign. But the women's table rests on small groups. Nine women have typical angina and one of them has the disease, so the 11.1% printed there means almost nothing. The new column carries real signal, a disease rate of 69.9% with a drop against 36.1% without, yet the cross-validated accuracy only moves from 0.857 to 0.858. The model already had `Oldpeak` itself and the ST slope, which say much the same thing. A feature can be informative and still add nothing, which is why the test is always the model's validation score.
]

#labpartopen([After the lab], [Your turn, troubleshooting and hand-in], [Your-turn tasks • Expected findings • Troubleshooting • Checklist], [Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the checklist before you hand it in.])

#yourturn[
  Add new cells at the end of the notebook for these tasks, and record your numbers before reading the expected findings.

  + #strong[Drop instead of flag.] A teammate proposes dropping the 129 training patients with no cholesterol reading, to "keep the data clean". Do it with `train.dropna(subset=["Cholesterol"])`. How many patients remain, what is their disease rate, and how many of the 406 training patients with heart disease did you discard? Score the Question~16 pipeline on what is left by cross-validation, then fit it and score it on the full test set and on the test patients who have no cholesterol reading.
  + #strong[Cap the extremes.] Clip cholesterol to its fences with `clip(109.5, 377.5)` and blood pressure to `clip(88.5, 172.5)`. What happens to the skew of each column, and to the cross-validated accuracy of the flag pipeline?
  + #strong[Is age a straight line?] Cut `Age` into the bands under 45, 45--54, 55--64, and 65 and over with `pd.cut`, and print the disease rate and the number of patients in each band.
  + #strong[Read the model.] Print the five largest weights, by absolute value, of the model fitted in Question~17. Which columns of Question~11 do they name?
  + #strong[One split is one draw.] Repeat the split, the fit and the test score of Questions~6 and~17 with `random_state` set to 0, 1, ..., 9. What are the lowest, highest and mean test accuracy? Where does this sheet's 0.897 fall?
]

#expectedfindings[
  #strong[Warm-up.] With the zero the mean is 200 and the median 220; without it the mean is 233.3 and the median 230. The mean moved 33 and the median 10: the mean is the one a hidden zero damages most. The fences are $210 - 1.5 times 67 = 109.5$ and $277 + 1.5 times 67 = 377.5$, so 380 lies beyond the high fence. Two standard errors are $1.96 sqrt(0.45 times 0.55 \/ 40) = 0.15$, so the true rate could plausibly lie anywhere from 30% to 60%.

  + 605 patients remain, with a disease rate of 47.9% instead of 55.3%, and 116 of the 406 patients with heart disease are gone: more than a quarter of the cases the model exists to find. Cross-validation on what is left reports 0.853, which looks as good as before. The test set tells the truth: 0.864 against 0.897 for the flag pipeline, and on the 43 test patients with no cholesterol reading, 0.721 against 0.860. Cross-validation could not see the damage, because the patients it would have been wrong about had been removed from it too. A score measured on a filtered table describes a filtered world.
  + The skew of cholesterol falls from 1.24 to 0.31 and that of blood pressure from 0.63 to 0.33, with 20 values changed in each column. The accuracy moves from 0.857 to 0.858. Capping tidied the histograms and taught the model nothing, so here it is not worth a step in the pipeline. Judge a preparation step by the validation score, not by how the chart looks.
  + The disease rate is 36.2% under 45 (138 patients), 46.9% at 45--54 (224), 67.6% at 55--64 (287) and 67.1% at 65 and over (85). It climbs to the mid-fifties and then levels off. A linear model gives age one slope and so cannot follow that bend; Chapter~@ch:feature-engineering shows what to do about it.
  + `ST_Slope_Up` $-1.29$, `ChestPainType_ASY` $+1.16$, `ST_Slope_Flat` $+1.08$, the missing-cholesterol flag $+0.71$ and `Sex_F` $-0.65$. These are the columns that separated the patients best in Question~11, plus the gap found in Question~12. The model leans on what the exploration found.
  + The ten test accuracies run from 0.842 to 0.886, with a mean of 0.866. The sheet's 0.897 is above all ten: the split with `random_state=42` happened to be a kind one. A single test score on 184 patients is good to about five points either way, so report it with that margin, and prefer the cross-validated 0.857 as the estimate.
]

#troubleshoot[
  / `FileNotFoundError`: The data file is missing or misnamed. It must be `all_datasets/supervised/heart_disease/heart_disease.csv`, capitals included.
  / `No module named 'course_setup'` in Question~1: The notebook is not running inside its lab folder, so `".."` is not `all_experiments/`. Open it from `all_experiments/lab00_data_toolkit_eda/` in your copy of the course.
  / `KeyError: 'Cholesterol '` or a similar name: A column name is misspelled or has a stray space. Print `heart.columns.tolist()` and copy the name from there.
  / `The truth value of a Series is ambiguous`: Two masks were joined with `and` or `or`. Use `&` or `|`, and put each mask in its own parentheses.
  / Question~5 changes nothing when run twice: The first run already replaced the zeros. Rerun from Question~2, or choose #strong[Restart Kernel and Run All Cells].
  / `Input X contains NaN` in Question~16: The model was fitted outside the pipeline. The imputer inside `make_model` is what fills the blanks, so always fit the whole pipeline.
  / The charts do not appear: In a plain script, `plt.show()` opens one window at a time and waits for you to close it. Every chart is also saved in `results/lab00/`.
  / Your accuracies differ in the third decimal: A different scikit-learn version can do that. The counts, rates and correlations of Parts~A to~D should match exactly.
]

#labchecklists[
  #verification[
    - You read the data card, and you can say what a 0 means in `RestingBP` and in `Cholesterol`.
    - The 173 impossible zeros are marked as missing by a fixed rule before the split, and no row was dropped.
    - The test set was sealed in Question~6 and opened once, in Question~17.
    - For cholesterol you can state $Q_1$, the median, $Q_3$ and both fences, and say why the 20 readings outside them stay.
    - Every rate you report has its count beside it, and you can say how far the rate for typical angina could be off.
    - You can explain why the correlation of cholesterol with heart disease changes sign when the zeros are marked as missing.
    - The three pipelines are compared on the same five folds, and you can say why the one with the flag is preferred although its score is the same.
    - `results/lab00/` holds the eight figures and eight tables listed in Question~18, including `exploration_log.csv`.
  ]
]
