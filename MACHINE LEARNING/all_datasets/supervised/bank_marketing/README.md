# Bank marketing calls

41,188 phone calls of a Portuguese bank selling term deposits, May 2008 to November 2010, in date order, with 21 columns.

**Used in:** Lab 1 (prediction timing, feature selection, leakage).

**Source and licence:** [UCI](https://archive.ics.uci.edu/dataset/222/bank+marketing) (Moro, Cortez and Rita, 2014), via [Hugging Face](https://huggingface.co/datasets/MLLab-TS/bank_marketing); CC BY 4.0.

**Changed from the source:** None: the raw UCI file (`bank-additional-full.csv`), renamed.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `bank_marketing.csv` | 5.8 MB | `pd.read_csv(DATA / "supervised/bank_marketing/bank_marketing.csv", sep=";")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- Fields are separated by `;`, not commas: read it with `pd.read_csv(..., sep=";")`.
- 11.3% of calls end in a yes. 12 rows are exact duplicates.
- Gaps are in disguise: 12,716 cells say `unknown`, and `pdays` is 999 for the 96.3% of customers never called before.
- `duration` is known only after the call ends, so it leaks the outcome.

## Columns of `bank_marketing.csv`

41,188 rows and 21 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `age` | integer | 0 | 56 |
| `job` | text | 0 | housemaid |
| `marital` | text | 0 | married |
| `education` | text | 0 | basic.4y |
| `default` | text | 0 | no |
| `housing` | text | 0 | no |
| `loan` | text | 0 | no |
| `contact` | text | 0 | telephone |
| `month` | text | 0 | may |
| `day_of_week` | text | 0 | mon |
| `duration` | integer | 0 | 261 |
| `campaign` | integer | 0 | 1 |
| `pdays` | integer | 0 | 999 |
| `previous` | integer | 0 | 0 |
| `poutcome` | text | 0 | nonexistent |
| `emp.var.rate` | decimal | 0 | 1.1 |
| `cons.price.idx` | decimal | 0 | 93.994 |
| `cons.conf.idx` | decimal | 0 | -36.4 |
| `euribor3m` | decimal | 0 | 4.857 |
| `nr.employed` | decimal | 0 | 5191.0 |
| `y` | text | 0 | no |
