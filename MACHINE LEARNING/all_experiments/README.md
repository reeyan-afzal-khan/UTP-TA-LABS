# Worked notebooks

One executed notebook per lab. The code cells and the explanations between them are the lab
text from `labs/*.tex`, in the same order and with the same settings, so a notebook and the
printed lab never disagree. Each notebook adds a Setup cell, a *What the output shows* note
with the actual numbers after each part, an Evidence cell that writes tables to
`results/labNN/`, the lab's Try-it or Decision-memo prompt with an empty cell to attempt it,
and then **one worked solution** (code plus an explanation of what it shows).

## Run

```bash
cd all_experiments
jupyter lab
```

Open a notebook and choose **Restart Kernel and Run All Cells**. Paths are relative to the
course folder (`Path.cwd().parent`), so launch Jupyter from this directory. Every notebook
finishes in under a minute on a laptop CPU; the two deep-learning labs need PyTorch
(`pip install -r requirements.txt` installs the CPU build).

## Index

| Notebook | Lab | Datasets | Chapters | Saves a model |
| --- | --- | --- | --- | --- |
| `lab01_features_worked.ipynb` | 1 Feature engineering and feature selection | titanic, breast_cancer, student_performance | 2–3, 5, 8 | |
| `lab02_supervised_workflow_worked.ipynb` | 2 Supervised learning I: regression, classification, and the workflow | medical_cost_personal, bike_sharing_day + hour, titanic, breast_cancer, heart_failure (Try-it) | 6–10 | `titanic_survival.joblib` + card, `insurance_charges.joblib` |
| `lab03_supervised_models_worked.ipynb` | 3 Supervised learning II: model families | breast_cancer, titanic, ames_housing, red_wine_quality | 11–14 | `breast_cancer_svm.joblib` |
| `lab04_clustering_pca_worked.ipynb` | 4 Unsupervised learning I: clustering and PCA | mall_customers, optical_recognition_handwritten_digits.zip | 15–17 | `digits_pca_logistic.joblib` |
| `lab05_anomaly_limited_labels_worked.ipynb` | 5 Unsupervised learning II: anomaly detection and limited labels | credit_card_fraud, breast_cancer | 18–19 | |
| `lab06_reinforcement_worked.ipynb` | 6 Reinforcement learning | none (GridWorld in the notebook) | 20 | `gridworld_q_table.npy` |
| `lab07_deep_learning_cnn_worked.ipynb` | 7 Deep learning I: a first neural network and a CNN for images | optical_recognition_handwritten_digits.zip | 21 | `digits_cnn.pt` + card |
| `lab08_deep_learning_lstm_worked.ipynb` | 8 Deep learning II: an LSTM for time series | bike_sharing_hour | 21 | `bike_lstm.pt` + card |

The digits archive is read directly from the `.zip` with `zipfile`; nothing needs extracting.

## Model files

`models/` holds the saved models. A scikit-learn file contains the preprocessing *and* the
estimator, so it is used by loading it and passing new rows with the original column names:

```python
import joblib, pandas as pd
model = joblib.load("../models/titanic_survival.joblib")
model.predict_proba(pd.DataFrame([{"Pclass": 2, "Sex": "female", "Age": 30,
                                   "SibSp": 0, "Parch": 0, "Fare": 20.0, "Embarked": "S"}]))
```

`predict_passenger.py` does this from the terminal using the Lab 2 model and its card:

```bash
python predict_passenger.py --pclass 2 --sex female --age 30 --fare 20
```

The PyTorch files (`.pt`) hold weights only; rebuild the architecture with `make_cnn()` (Lab 7)
or `LSTMForecaster()` (Lab 8) and call `load_state_dict`, as the labs' Part D shows. The LSTM
card also stores the scale factor the inputs must be divided by.

## Evidence

`results/labNN/` holds the figures (`.png`) and tables (`.csv`, `.txt`) each notebook writes.
They are regenerated on every run; do not edit them by hand.
