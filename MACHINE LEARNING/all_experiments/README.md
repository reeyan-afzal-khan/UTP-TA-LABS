# Worked notebooks

One folder per lab. Each holds the executed notebook, a `.py` twin with the same code cells, and a
README naming the lab's data, outputs, run time and the chapters it practises. Every code cell has
a `### Question n` heading, and the lab sheet in `labs/*.tex` uses the same number and title, so
`[n]` after Run All is Question n on the sheet. Each notebook has a Setup cell, a *What the output
shows* note with the actual numbers after each part, a map of the lab's parts in its first cell, a goal under
each part heading and a checkpoint closing each part (the same as on the sheet), an Evidence cell that writes tables and
figures to `results/labNN/`, the lab's Try-it prompt with an empty cell to attempt it, and then
**one worked solution** (code plus an explanation of what it shows).

```
all_experiments/
  course_setup.py                 the setup every lab shares (see below)
  lab01_features/                 lab01_features_worked.ipynb, .py twin, README.md
  lab02_supervised_workflow/      ... and predict_churn.py
  lab03_supervised_models/
  lab04_clustering_pca/
  lab05_anomaly_limited_labels/
  lab06_reinforcement/
  lab07_deep_learning_cnn/
  lab08_deep_learning_lstm/
  book_checks/                    scripts that check every number the book prints
```

The listings printed on the lab sheets are pulled from the `.py` twins by line number, so adding
or removing a line in a twin means updating the sheet's `firstline` and `lastline`.

## Run

From the course folder:

```bash
jupyter lab
```

Open a lab's notebook and choose **Restart Kernel and Run All Cells**. Each notebook finds the
course folder by looking upward for `all_datasets/`, so it runs wherever Jupyter was started
inside the course. Most labs take under a minute on a laptop CPU, Lab 3 about two. Labs 7 and 8
train neural networks and took about four minutes each on the CPU behind the printed numbers.

### The Setup cell

Every lab's first code cell has the same three steps, in this order:

```python
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses, grouped by what they are for.
import numpy as np
import pandas as pd
...

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab02")
```

`start_lab` returns `DATA` (the `all_datasets/` folder), `RESULTS` (`results/labNN/`, created if
needed) and `MODELS` (`models/`), and prints where they are. Data files are then named by their
place inside `all_datasets/`, for example `DATA / "supervised/hotel_bookings/hotel_bookings.zip"`. Labs 7 and 8
also call `start_pytorch()`, which returns `DEVICE` (see below). `course_setup.py` is short and
documented; read it once.

Each twin runs the same code from a terminal and writes the same evidence:

```bash
python all_experiments/lab01_features/lab01_features_worked.py
```

### PyTorch, GPUs, and kernels (Labs 7 and 8)

The two deep-learning labs need PyTorch. `start_pytorch()` in their Setup cell handles the common situations:

- **PyTorch already installed** in the Python behind the kernel: it is imported and the cell
  prints the version and the device.
- **PyTorch missing**: the cell installs the CPU build into that same Python once
  (`pip install torch --index-url https://download.pytorch.org/whl/cpu`, about 200 MB) and
  continues. `pip install -r requirements.txt` from the course folder does the same up front.
  If pip had to use the per-user folder (`%APPDATA%\Python\...` on Windows), which some Jupyter
  launchers hide from the kernel, the cell adds that folder to the path as well.
- **GPU or not**: the cell sets `DEVICE` to `cuda` (NVIDIA) or `mps` (Apple Silicon) when PyTorch
  can see one, otherwise `cpu`. The rest of the lab is written once and runs on whichever was
  chosen. A GPU is a convenience, not a requirement; the stored outputs come from a CPU run,
  and GPU runs differ from them in the last digits because GPU kernels are not bit-for-bit
  deterministic. To reproduce the printed numbers on a machine with a GPU, set
  `CUDA_VISIBLE_DEVICES=-1` before starting Jupyter (never an empty string).

The first line the Setup cell prints is the Python that is actually running the notebook. If it
is not the environment you installed PyTorch into (a common cause of `No module named 'torch'`),
the notebook is on the wrong kernel. Register the right environment once, then pick it under
*Kernel > Change Kernel* (Jupyter) or the interpreter picker (VS Code):

```bash
conda activate my_env
pip install ipykernel
python -m ipykernel install --user --name my_env --display-name "Python (my_env)"
```

## Index

| Folder | Lab | Datasets (in `all_datasets/`) | Chapters | Saves a model |
| --- | --- | --- | --- | --- |
| `lab01_features/` | 1 Feature engineering and feature selection | hotel_bookings, telco_customer_churn, bank_marketing | 1A–3 | |
| `lab02_supervised_workflow/` | 2 Supervised learning I: regression, classification, and the workflow | used_cars, hotel_bookings, telco_customer_churn | 4–10 | `customer_churn.joblib` + card, `used_car_prices.joblib` |
| `lab03_supervised_models/` | 3 Supervised learning II: model families | lending_club, used_cars, sms_spam (Try-it) | 11–14 | `loan_default_svm.joblib` |
| `lab04_clustering_pca/` | 4 Unsupervised learning I: clustering and PCA | online_retail_ii, wood_surface_defects | 15–17 | `wood_pca_logistic.joblib` |
| `lab05_anomaly_limited_labels/` | 5 Unsupervised learning II: anomaly detection and limited labels | creditcard_fraud_ulb, banking77 | 18–19 | |
| `lab06_reinforcement/` | 6 Reinforcement learning | none (GridWorld in the notebook) | 20 | `gridworld_q_table.npy` |
| `lab07_deep_learning_cnn/` | 7 Deep learning I: a first neural network and a CNN for images | wood_surface_defects | 21 | `wood_cnn.pt` + card |
| `lab08_deep_learning_lstm/` | 8 Deep learning II: an LSTM for time series | electricity_load_hourly | 21 | `electricity_lstm.pt` + card |

`all_datasets/` groups the datasets by how the course learns from them (`supervised/`,
`unsupervised/`, `advanced/`), one folder per dataset with a README, its data card: source,
licence, what each column means, and quirks. The ZIP files
are read in place by pandas; nothing needs extracting.

## Model files

`models/` holds the saved models. A scikit-learn file contains the preprocessing *and* the
estimator, so it is used by loading it and passing new rows with the original column names. The
card beside a model lists those columns:

```python
import joblib, pandas as pd
model = joblib.load("models/used_car_prices.joblib")
model.predict(pd.DataFrame([{"age": 5, "mileage_miles": 30000, "make": "Toyota", "body_type": "SUV",
                             "drive": "AWD", "fuel_type": "gasoline"}]))
```

`predict_churn.py` does the same for Lab 2's churn model from the terminal, filling every column it is not given from the card's typical customer:

```bash
python all_experiments/lab02_supervised_workflow/predict_churn.py --tenure 2 --contract Month-to-month --monthly 85
```

The PyTorch files (`.pt`) hold weights only; rebuild the architecture with `make_cnn()` (Lab 7)
or `LSTMForecaster()` (Lab 8) and call `load_state_dict`, as the labs' Part D shows. The LSTM
card also stores the scale the inputs must be divided by.

## Scripts that check the book

Every worked number printed in a chapter comes from one of the scripts in `book_checks/`, which
assert it and end with `Every number above matches the book.` Run them from the course folder.

| Script | What it checks |
| --- | --- |
| `demo_study_log.py` | The ten-student study log that runs through the book |
| `demo_foundations.py` | Chapters 3 and 5 to 9 |
| `demo_model_families.py` | Chapters 10 to 14, and Lab 3's printed numbers |
| `demo_unsupervised.py` | Chapters 15 to 19, and Lab 5's printed numbers |
| `demo_advanced.py` | Chapters 20 and 21, with NumPy only |
| `check_your_turn.py` | The expected findings of every lab's Your-turn tasks; `python all_experiments/book_checks/check_your_turn.py lab03` runs one lab |

## Evidence

`results/labNN/` holds the figures (`.png`) and tables (`.csv`, `.txt`) each notebook writes.
They are regenerated on every run; do not edit them by hand.
