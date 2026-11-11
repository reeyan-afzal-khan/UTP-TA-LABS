# Lab 05 — Unsupervised learning II: anomaly detection and limited labels

Two ways to learn when labels are missing or scarce, on real data: an Isolation Forest that ranks 284,807 European card transactions for fraud review without ever seeing a fraud label, and self-training and active learning that stretch a small labeling budget for 13,083 messages to a bank's support chat in 77 intents (Banking77).

**Lab sheet:** [`Lab-05/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-05/Lab-Activity.pdf), which practises Chapters 18 and 19.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Rank card fraud with an Isolation Forest and judge the ranking | 2–4 |
| B | Self-train from 1,000 labels; compare two ways of buying labels | 5–9 |
| Finish | Save the evidence; then size a review budget and read the messages the learner finds hardest | 10–12 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab05_anomaly_limited_labels_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab05_anomaly_limited_labels_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip` | 284,807 card transactions over two days, 492 frauds; `V1`–`V28` are anonymized principal components, rounded to 4 decimals | Machine Learning Group, Université Libre de Bruxelles (Dal Pozzolo and others, 2015), via [Hugging Face](https://huggingface.co/datasets/David-Egea/Creditcard-fraud-detection); Open Database License |
| `all_datasets/advanced/banking77/banking77.csv` | 13,083 customer-support messages in 77 intents, with the official train/test split as a column | Casanueva and others, PolyAI (2020), via [Hugging Face](https://huggingface.co/datasets/PolyAI/banking77); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab05_anomaly_limited_labels_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab05_anomaly_limited_labels/lab05_anomaly_limited_labels_worked.py      # or the script
```

A run takes about 15 seconds on a laptop CPU.

## What a run writes

- `results/lab05/`: `metrics.csv`, the 100 top-ranked transactions, the active-learning curve, and two figures. This lab saves no model.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab05` checks the numbers printed under *Expected findings* on the sheet.
