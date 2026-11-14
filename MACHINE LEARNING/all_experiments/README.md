# Worked notebooks

One folder per lab. Each holds the executed notebook, a `.py` twin with the same code cells, and a
README naming the lab's data, outputs, run time and the chapters it practises. Every code cell has
a `### Question n` heading, and the lab sheet in `labs/*.typ` uses the same number and title, so
`[n]` after Run All is Question n on the sheet. Each notebook has a Setup cell, a *What the output
shows* note with the actual numbers after each part, a map of the lab's parts in its first cell, a goal under
each part heading and a checkpoint closing each part (the same as on the sheet), an Evidence cell that writes tables and
figures to `results/labNN/`, the lab's Try-it prompt with an empty cell to attempt it, and then
**one worked solution** (code plus an explanation of what it shows).

```
all_experiments/
  course_setup.py                 the setup every lab shares (see below)
  lab00_data_toolkit_eda/         lab00_data_toolkit_eda_worked.ipynb, .py twin, README.md
  lab01_features/
  lab02_supervised_workflow/      ... and predict_churn.py
  lab03_supervised_models/
  lab04_clustering_pca/
  lab05_anomaly_limited_labels/
  lab06_reinforcement/
  lab07_deep_learning_cnn/
  lab08_deep_learning_lstm/
  lab09_learning_from_text/
  lab10_end_to_end_project/       ... and booking_project/, the project as a package
  book_checks/                    scripts that check every number the book prints
```

The listings printed on the lab sheets are pulled from the `.py` twins by their `# %% Question n`
markers, so a cell can grow or shrink without touching the sheet. Keep the markers as they are.

## Run

From the course folder:

```bash
jupyter lab
```

Open a lab's notebook and choose **Restart Kernel and Run All Cells**. Each notebook finds the
course folder by looking upward for `all_datasets/`, so it runs wherever Jupyter was started
inside the course. Most labs take under a minute on a laptop CPU, Labs 3 and 10 about two. Labs 7
and 8 train neural networks and took about four minutes each on the CPU behind the printed numbers.

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
| `lab00_data_toolkit_eda/` | 0 Python data toolkit and exploratory data analysis | heart_disease | 3, 7 | |
| `lab01_features/` | 1 Feature engineering and feature selection | hotel_bookings, telco_customer_churn, bank_marketing | 4, 9 | |
| `lab02_supervised_workflow/` | 2 Supervised learning I: regression, classification, and the workflow | used_cars, hotel_bookings, telco_customer_churn | 10–14 | `customer_churn.joblib` + card, `used_car_prices.joblib` |
| `lab03_supervised_models/` | 3 Supervised learning II: model families | lending_club, used_cars, sms_spam (Try-it) | 15–18 | `loan_default_svm.joblib` |
| `lab04_clustering_pca/` | 4 Unsupervised learning I: clustering and PCA | online_retail_ii, wood_surface_defects | 20–22 | `wood_pca_logistic.joblib` |
| `lab05_anomaly_limited_labels/` | 5 Unsupervised learning II: anomaly detection and limited labels | creditcard_fraud_ulb, banking77 | 23, 25 | |
| `lab06_reinforcement/` | 6 Reinforcement learning | none (GridWorld in the notebook) | 26 | `gridworld_q_table.npy` |
| `lab07_deep_learning_cnn/` | 7 Deep learning I: a first neural network and a CNN for images | wood_surface_defects | 27–29 | `wood_cnn.pt` + card |
| `lab08_deep_learning_lstm/` | 8 Deep learning II: an LSTM for time series | electricity_load | 30 | `electricity_lstm.pt` + card |
| `lab09_learning_from_text/` | 9 Learning from text | sms_spam, banking77 | 31 | `bank_intent_tfidf_logistic.joblib` + card |
| `lab10_end_to_end_project/` | 10 The end-to-end project | hotel_bookings | 32, 33 | `booking_cancellation.joblib` + card |

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

Lab 10's booking model is served the way a real model is: `booking_project/serve.py` puts it behind
a small Flask web service, `booking_project/app.py` is a Streamlit page for trying one booking, and
`booking_project/test_project.py` runs the project's tests, either as a script or with `pytest`. The
chapter *Serving and Monitoring* shows how each one is started; the folder's `requirements.txt` and
`Dockerfile` pin what a server needs.

## Scripts that check the book

Every worked number printed in a chapter comes from one of the scripts in `book_checks/`, which
assert it and end with `Every number above matches the book.` Run them from the course folder.

| Script | What it checks |
| --- | --- |
| `demo_study_log.py` | The ten-student study log that runs through the book (Chapters 2, 5, 13, 14, 21 and 22) |
| `demo_data_toolkit.py` | Chapter 3: NumPy, pandas and plots |
| `demo_foundations.py` | Chapters 4, 6 and 10 to 13: data, statistics, losses, metrics, training |
| `demo_exploration.py` | Chapters 7 to 9: exploring a table, hypothesis tests, features |
| `demo_model_families.py` | Chapters 14 to 18, and Lab 3's printed numbers |
| `demo_selection.py` | Chapter 19: feature selection |
| `demo_unsupervised.py` | Chapters 20 to 23 and 25, and Lab 5's printed numbers |
| `demo_recommenders.py` | Chapter 24: recommender systems |
| `demo_advanced.py` | Chapters 26, 27, 29 and 30: the small worked numbers, with NumPy only |
| `demo_deep_training.py` | Chapter 28: training deep networks |
| `demo_cnn.py` | Chapter 29: convolutional networks |
| `demo_sequence.py` | Chapter 30: sequence models and attention |
| `demo_text.py` | Chapter 31: learning from text |
| `demo_project.py` | Chapter 32: the end-to-end project |
| `demo_serving.py` | Chapter 33: serving and monitoring |
| `check_your_turn.py` | The expected findings of every lab's Your-turn tasks; `python all_experiments/book_checks/check_your_turn.py lab03` runs one lab |

The scripts that train networks (`demo_deep_training.py`, `demo_cnn.py`, `demo_sequence.py`) take one
to two minutes each and allow for the small differences that another computer's arithmetic can make.

## Evidence

`results/labNN/` holds the figures (`.png`) and tables (`.csv`, `.txt`) each notebook writes.
They are regenerated on every run; do not edit them by hand.
