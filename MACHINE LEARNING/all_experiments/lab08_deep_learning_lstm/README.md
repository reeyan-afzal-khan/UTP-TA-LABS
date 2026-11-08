# Lab 08 — Deep learning II: an LSTM for time series

An LSTM written in PyTorch that forecasts the next hour of total electricity demand for 158 Portuguese customers from the previous 24 hours, trained on 2011-2013, tuned on the first half of 2014 and tested once on the second half against three free forecasts. The lab finds the hours it gets wrong and saves the weights with the scale they depend on.

**Lab sheet:** [`Lab-08/Lab-Activity.pdf`](../../../.all_pdfs/machine-learning/Lab-08/Lab-Activity.pdf), which practises Chapter 21; the time-split rule in Chapter 3.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Build one demand series, split it by date, cut it into windows | 2–4 |
| B | Score three free forecasts | 5 |
| C | Train the LSTM, test it once, find the hours it gets wrong | 6–9 |
| D | Save the weights and the scale, then forecast the first hour of 2015 | 10 |
| Finish | Save the evidence; then try other lookbacks and a wider LSTM | 11–13 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab08_deep_learning_lstm_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab08_deep_learning_lstm_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/advanced/electricity_load/electricity_load_hourly.zip` | 35,064 hours x 158 customers, kWh per hour, 2011-2014; see `all_datasets/README.md` for how it was made from the 15-minute source | [UCI](https://archive.ics.uci.edu/dataset/321/electricityloaddiagrams20112014) (Trindade, 2015), via [Hugging Face](https://huggingface.co/datasets/sxj1024/electricity_load_2011_2014); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab08_deep_learning_lstm_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab08_deep_learning_lstm/lab08_deep_learning_lstm_worked.py      # or the script
```

Needs PyTorch (see the course `requirements.txt`). A run takes about four minutes on a laptop CPU, about half of it the Try-it solution; a GPU is used automatically when PyTorch can see one.

## What a run writes

- `results/lab08/`: `validation_curve.csv`, `metrics.csv`, `first_test_week.csv` and three figures.
- `models/electricity_lstm.pt` with `models/electricity_lstm_card.json`, which holds the scale; rebuild the network with `LSTMForecaster()` before loading the weights.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab08` checks the numbers printed under *Expected findings* on the sheet.
