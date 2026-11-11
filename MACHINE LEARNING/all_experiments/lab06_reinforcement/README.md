# Lab 06 — Reinforcement learning

Tabular Q-learning on a 4×4 grid with a goal and a trap: the agent learns only from the rewards its own moves earn, its greedy policy is evaluated apart from the exploratory training, and the learned Q-table is saved as the model.

**Lab sheet:** [`Lab-06/Lab-Activity.pdf`](../../../.all-pdfs/machine-learning/Lab-06/Lab-Activity.pdf), which practises Chapter 20.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Define the grid world, train the Q-table and evaluate the policy | 2–5 |
| B | Save the Q-table, read the policy and its values | 6–7 |
| Finish | Save the evidence; then move the trap | 8–10 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab06_reinforcement_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab06_reinforcement_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

None: the GridWorld is defined in the notebook, so this lab reads no data file.

## Run

From the course folder:

```bash
jupyter lab                                              # open lab06_reinforcement_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py      # or the script
```

A run takes a few seconds on any laptop.

## What a run writes

- `results/lab06/`: the training curve, the training returns, the greedy policy and the values, and `metrics.csv`.
- `models/gridworld_q_table.npy`, the learned Q-table.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab06` checks the numbers printed under *Expected findings* on the sheet.
