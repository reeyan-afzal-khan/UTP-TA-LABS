# Lab 10 — The end-to-end project

One model, taken from the first question to a watched service, on 119,390 real hotel bookings. You check the hotel's file against a data contract, validate the way the model will be used, keep an experiment log, choose between two finalists by a rule fixed in advance, open the test quarter once, ship the model with one command, tests, a web service and a page for people, and then follow it through five months of bookings that arrived after it was trained.

**Lab sheet:** [`Lab-10/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-10/Lab-Activity.pdf), which practises the chapters *The End-to-End Project* and *Serving and Monitoring*.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Read the bookings over time, check them against the contract, and find the columns written too late | 2–5 |
| B | Cut three periods, compare random and forward validation, find the repeated blocks, set baselines | 6–9 |
| C | Keep an experiment log, choose by a rule, open the test quarter once, write the card | 10–13 |
| D | Ship: one command, tests, a web service and a page for people | 14–17 |
| E | Watch five months: drift, the right reference, the call list, retraining | 18–21 |
| Finish | Save the evidence; then correct the monthly forecast yourself | 22–24 |
| After | Your-turn tasks, expected findings, troubleshooting and the checklist (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab10_end_to_end_project_worked.ipynb` | The worked notebook: every question on the sheet, with *Read the code* notes, its output, and what the output shows |
| `lab10_end_to_end_project_worked.py` | The same code cells as one script; each cell starts with a `# %% Question n` line |
| `booking_project/bookings.py` | The contract, the features and the models: everything that training and serving must do the same way |
| `booking_project/train.py` | One command from the hotel's file to a saved model, its card and a line in the run log |
| `booking_project/serve.py` | The web service: `/health`, and `/predict` for one booking at a time |
| `booking_project/app.py` | A one-page Streamlit app for the front desk |
| `booking_project/monitor.py` | The population stability index and the monthly report |
| `booking_project/test_project.py` | Seven tests that must pass before a new version ships |
| `booking_project/requirements.txt`, `Dockerfile` | The exact package versions, and a recipe for a container that runs the service |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/supervised/hotel_bookings/hotel_bookings.zip` | 119,390 bookings at a city hotel and a resort hotel in Portugal, July 2015 to August 2017; the data card is the `README.md` beside it | Antonio, de Almeida and Nunes, *Hotel booking demand datasets*, Data in Brief 22 (2019); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab10_end_to_end_project_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab10_end_to_end_project/lab10_end_to_end_project_worked.py      # or the script
```

A run takes about a minute and a half on a laptop CPU. Besides the packages of the earlier labs it needs `flask` and `streamlit`.

The project's own files run from this folder:

```bash
python booking_project/train.py                  # train, check, gate, save the model and its card
python booking_project/test_project.py           # the seven tests (or: pytest booking_project/test_project.py)
python booking_project/serve.py                  # the web service, at http://127.0.0.1:8000
streamlit run booking_project/app.py             # the page for the front desk, in a browser
```

## What a run writes

- `results/lab10/`: three figures and ten other files (the cancellations by quarter, the experiment log, the test quarter by group, the calibration table, the model card, the monthly report, the call-list results, the retraining comparison, the prediction log, and `runs.csv`, the run log, which gains one line every time `train.py` runs).
- `models/booking_cancellation.joblib` with `models/booking_cancellation_card.json`: the champion, as `train.py` saves it.

Every run regenerates these files, except that `runs.csv` keeps one line per run, which is its purpose. `python all_experiments/book_checks/check_your_turn.py lab10` checks the numbers printed under *Expected findings* on the sheet.
