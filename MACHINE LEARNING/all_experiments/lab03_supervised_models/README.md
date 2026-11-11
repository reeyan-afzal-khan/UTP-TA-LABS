# Lab 03 — Supervised learning II: model families

Five model families under one workflow, on two real tables: 100,000 Lending Club loans, a hard and noisy credit problem where the data, not the algorithm, sets the ceiling, and Lab 2's Cars.com listings for forests against boosting. The Try-it puts naive Bayes on 5,572 text messages.

**Lab sheet:** [`Lab-03/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-03/Lab-Activity.pdf), which practises Chapters 11 to 14.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Rank loan defaults with KNN and naive Bayes; draw their boundaries | 2–5 |
| B | Read a small tree's rules, then watch a deep tree overfit | 6–8 |
| C | Compare a forest with boosting on used-car prices | 9–10 |
| D | Tune an SVM, map its two dials, save and verify it | 11–13 |
| Finish | Save the evidence; then classify text messages as spam | 14–16 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab03_supervised_models_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab03_supervised_models_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/lending_club/lending_club_2014_2015.zip` | 100,000 finished Lending Club loans issued in 2014 and 2015, 19.4% charged off | Lending Club's public loan data, via [Hugging Face](https://huggingface.co/datasets/codesignal/lending-club-loan-accepted); CC0 |
| `all_datasets/supervised/used_cars/used_cars.zip` | 150,000 car listings collected in October 2026 (as in Lab 2) | Cars.com listings collected by KTHESAT, via [Hugging Face](https://huggingface.co/datasets/KTHESAT/usa-used-car-market-cars-com); CC BY 4.0 |
| `all_datasets/supervised/sms_spam/sms_spam.csv` | 5,572 text messages, ham or spam (Try-it) | [UCI](https://archive.ics.uci.edu/dataset/228/sms+spam+collection) (Almeida and Hidalgo, 2011), via [Hugging Face](https://huggingface.co/datasets/codesignal/sms-spam-collection); CC BY 4.0 |

Each dataset's folder has a `README.md`, its data card: what every column means and what to watch for.

## Run

From the course folder:

```bash
jupyter lab                                              # open lab03_supervised_models_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py      # or the script
```

A run takes about two minutes on a laptop CPU; the neighbor search in Question 3 and the SVMs in Questions 11 and 12 take most of it.

## What a run writes

- `results/lab03/`: the k search, the loan tree's rules, the car-price fold scores, the SVM grid, `metrics.csv` and seven figures.
- `models/loan_default_svm.joblib`, the tuned SVM pipeline.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab03` checks the numbers printed under *Expected findings* on the sheet.
