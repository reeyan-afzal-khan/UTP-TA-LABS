# Credit card fraud (ULB)

284,807 card transactions by European cardholders over two days in September 2013, 492 of them fraud (0.17%). `V1` to `V28` are anonymized principal components; `Time`, `Amount` and `Class` are as recorded.

**Used in:** Lab 5 (anomaly detection and imbalanced evaluation). The detectors never see `Class`: it is kept only to grade what they flag.

**Source and licence:** Machine Learning Group, Université Libre de Bruxelles (Dal Pozzolo and others, 2015), via [Hugging Face](https://huggingface.co/datasets/David-Egea/Creditcard-fraud-detection); Open Database License.

**Changed from the source:** `V1` to `V28` rounded to four decimals, which shrinks the file from 150 MB to 22 MB zipped; `Time`, `Amount` and `Class` unchanged.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `creditcard_fraud_ulb.zip` | 22.4 MB | `pd.read_csv(DATA / "unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- `Class` is 1 for fraud. At a 0.17% base rate, accuracy is meaningless: use average precision, or the frauds found in the top alerts.
- `Time` is seconds since the first transaction, so it doubles as a clock across the 48 hours.

## Columns of `creditcard_fraud_ulb.zip`

284,807 rows and 31 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `Time` | integer | 0 | 0 |
| `V1` ... `V28` | decimal (28 columns) | 0 | -1.3598 |
| `Amount` | decimal | 0 | 149.62 |
| `Class` | integer | 0 | 0 |
