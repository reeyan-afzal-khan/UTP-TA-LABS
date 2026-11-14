# Telco customer churn

7,043 customers of a telecom company and whether they left (`Churn`), with 21 columns of account and service details.

**Used in:** the chapter *Python for Data* (a first real table), Lab 1 (repairing types, scaling and nearest neighbors), Lab 2 (tuning, and the saved model), and the chapter *Training Deep Networks* (initialization, optimizers, learning rates and regularization on one table).

**Source and licence:** IBM sample data, via [Hugging Face](https://huggingface.co/datasets/scikit-learn/churn-prediction); CC BY 4.0.

**Changed from the source:** None: the source file, renamed.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `telco_customer_churn.csv` | 1.0 MB | `pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- `TotalCharges` is stored as text: 11 cells are blank, all for customers in their first month (`tenure` 0), who have not been billed yet. Zero is the right repair.
- `SeniorCitizen` is 0/1 while the other yes/no columns are text.

## Columns of `telco_customer_churn.csv`

7,043 rows and 21 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `customerID` | text | 0 | 7590-VHVEG |
| `gender` | text | 0 | Female |
| `SeniorCitizen` | integer | 0 | 0 |
| `Partner` | text | 0 | Yes |
| `Dependents` | text | 0 | No |
| `tenure` | integer | 0 | 1 |
| `PhoneService` | text | 0 | No |
| `MultipleLines` | text | 0 | No phone service |
| `InternetService` | text | 0 | DSL |
| `OnlineSecurity` | text | 0 | No |
| `OnlineBackup` | text | 0 | Yes |
| `DeviceProtection` | text | 0 | No |
| `TechSupport` | text | 0 | No |
| `StreamingTV` | text | 0 | No |
| `StreamingMovies` | text | 0 | No |
| `Contract` | text | 0 | Month-to-month |
| `PaperlessBilling` | text | 0 | Yes |
| `PaymentMethod` | text | 0 | Electronic check |
| `MonthlyCharges` | decimal | 0 | 29.85 |
| `TotalCharges` | text | 0 | 29.85 |
| `Churn` | text | 0 | No |
