# Lab 00 — Python data toolkit and exploratory data analysis

A complete examination of one real table, 918 patients tested for heart disease, with NumPy, pandas and Matplotlib. You take the table's first measurements, find 173 missing values that are stored as zeros, study each column alone and against the diagnosis, watch those zeros reverse a correlation, and finish with a first model whose score you can defend.

**Lab sheet:** [`Lab-00/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-00/Lab-Activity.pdf), which practises the chapters *Python for Data* and *Exploratory Data Analysis*.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Load the table, take its first measurements, and catch the values that cannot be true | 2–5 |
| B | Seal a test set, then study one column at a time: shape, five numbers, fences, counts | 6–9 |
| C | Compare each column, and each gap, with the target | 10–12 |
| D | Compare columns with each other, and watch a correlation change sign | 13–14 |
| E | Turn the findings into baselines, a pipeline and one honest test score | 15–17 |
| Finish | Save the evidence; then examine women and men separately yourself | 18–20 |
| After | Your-turn tasks, expected findings, troubleshooting and the checklist (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab00_data_toolkit_eda_worked.ipynb` | The worked notebook: every question on the sheet, with *Read the code* notes, its output, and what the output shows |
| `lab00_data_toolkit_eda_worked.py` | The same code cells as one script; each cell starts with a `# %% Question n` line |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/heart_disease/heart_disease.csv` | 918 patients from five hospitals, 11 clinical measurements and a diagnosis; the data card is the `README.md` beside it | fedesoriano, *Heart Failure Prediction Dataset* (2021), [Kaggle](https://www.kaggle.com/datasets/fedesoriano/heart-failure-prediction); ODbL 1.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab00_data_toolkit_eda_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.py      # or the script
```

A run takes about ten seconds on a laptop CPU and saves no model files.

## What a run writes

- `results/lab00/`: eight figures and eight tables (the column overview, the cleaning log, five-number summaries, disease rates by category, the cholesterol correlations, the model comparison, the test metrics, and the exploration log).

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab00` checks the numbers printed under *Expected findings* on the sheet.
