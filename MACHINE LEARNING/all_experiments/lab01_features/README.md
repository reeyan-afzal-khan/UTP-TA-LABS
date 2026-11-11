# Lab 01 — Feature engineering and feature selection

Feature engineering and feature selection on three real tables: two Portuguese hotels' bookings, a telecom company's customers and a bank's marketing calls. You read a data card before the data, build features that exist when the booking is made, watch scaling change who counts as a neighbor, and select features without letting a column from the future leak in.

**Lab sheet:** [`Lab-01/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-01/Lab-Activity.pdf), which practises Chapters 1A to 3.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Check your versions, read the data card, find the gaps and the column that leaks the outcome | 2–4 |
| B | Engineer five columns from the hotel bookings and test them on a model | 5–7 |
| C | Repair the Telco columns and see how scaling changes a customer's neighbors | 8–9 |
| D | Select features for the bank's call list without leaking the outcome | 10–12 |
| Finish | Save the evidence; then add the arrival weekday yourself | 13–15 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab01_features_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab01_features_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/hotel_bookings/hotel_bookings.zip` | 119,390 bookings at two Portuguese hotels, arrivals July 2015 to August 2017, 32 columns; the data card is the `README.md` beside it | Antonio, de Almeida and Nunes (2019), via [Hugging Face](https://huggingface.co/datasets/gemuchu/hotel_bookings); CC BY 4.0 |
| `all_datasets/supervised/telco_customer_churn/telco_customer_churn.csv` | 7,043 telecom customers, 21 columns | IBM sample data, via [Hugging Face](https://huggingface.co/datasets/scikit-learn/churn-prediction); CC BY 4.0 |
| `all_datasets/supervised/bank_marketing/bank_marketing.csv` | 41,188 calls of a Portuguese bank, 2008–2010, in date order; fields separated by `;` | [UCI](https://archive.ics.uci.edu/dataset/222/bank+marketing) (Moro, Cortez and Rita, 2014), via [Hugging Face](https://huggingface.co/datasets/MLLab-TS/bank_marketing); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab01_features_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab01_features/lab01_features_worked.py      # or the script
```

A run takes about ten seconds on a laptop CPU and saves no model files.

## What a run writes

- `results/lab01/`: four figures and six tables (package versions, missing values, cancellation by days booked ahead, the nearest neighbors before and after scaling, the feature-set comparison, the L1 coefficients).

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab01` checks the numbers printed under *Expected findings* on the sheet.
