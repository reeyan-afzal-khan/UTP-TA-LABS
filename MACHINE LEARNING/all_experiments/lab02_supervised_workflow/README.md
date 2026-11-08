# Lab 02 — Supervised learning I: regression, classification, and the workflow

The supervised workflow from start to finish, on three real tables: Cars.com used-car listings for linear and ridge regression on messy data, two Portuguese hotels' bookings for a date-order split, probabilities and an overbooking threshold, and a telecom company's customers for tuning, a sealed test set and a saved model.

**Lab sheet:** [`Lab-02/Lab-Activity.pdf`](../../../.all_pdfs/machine-learning/Lab-02/Lab-Activity.pdf), which practises Chapters 4 to 10.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Tidy the car listings, predict prices, read the coefficients and the residuals | 2–5 |
| B | Validate hotel cancellations in date order, and see what a shuffled split hides | 6–8 |
| C | Beat a baseline, read probabilities, and choose a threshold by cost | 9–12 |
| D | Tune the churn model with cross-validation, then open the test set once | 13–14 |
| E | Save the models with a card, reload them and use them | 15–16 |
| Finish | Save the evidence; then model log prices and write an overbooking memo | 17–19 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab02_supervised_workflow_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab02_supervised_workflow_worked.py` | The same code cells as one script, for a terminal or a quick check |
| `predict_churn.py` | Loads the saved churn model and its card and predicts one customer from the terminal |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/used_cars/used_cars.zip` | 150,000 car listings, new and used, collected in October 2026 | Cars.com listings collected by KTHESAT, via [Hugging Face](https://huggingface.co/datasets/KTHESAT/usa-used-car-market-cars-com); CC BY 4.0 |
| `all_datasets/supervised/hotel_bookings/hotel_bookings.zip` | 119,390 bookings at two Portuguese hotels, arrivals July 2015 to August 2017 (as in Lab 1) | Antonio, de Almeida and Nunes (2019), via [Hugging Face](https://huggingface.co/datasets/gemuchu/hotel_bookings); CC BY 4.0 |
| `all_datasets/supervised/telco_customer_churn/telco_customer_churn.csv` | 7,043 telecom customers (as in Lab 1) | IBM sample data, via [Hugging Face](https://huggingface.co/datasets/scikit-learn/churn-prediction); CC BY 4.0 |

Each dataset's folder has a `README.md`, its data card: what every column means and what to watch for.

## Run

From the course folder:

```bash
jupyter lab                                              # open lab02_supervised_workflow_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.py      # or the script
python all_experiments/lab02_supervised_workflow/predict_churn.py --tenure 2 --contract Month-to-month --monthly 85
```

A run takes under a minute on a laptop CPU.

## What a run writes

- `results/lab02/`: `metrics.csv`, `monthly_cancellations.csv` and ten figures (the make coefficients, the residuals, the monthly cancellations, the two classifiers, the probability histogram, two confusion matrices, the threshold sweep, ROC and PR curves, and the grid search).
- `models/customer_churn.joblib` with `models/customer_churn_card.json`, and `models/used_car_prices.joblib`.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab02` checks the numbers printed under *Expected findings* on the sheet.
