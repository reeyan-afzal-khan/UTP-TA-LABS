# Banking77

13,083 messages that customers typed to a bank's support chat, each labeled with one of 77 intents such as `card_arrival` or `exchange_rate`: the official train (10,003) and test (3,080) sets in one CSV, with a `split` column.

**Used in:** Lab 5 (learning from few labels: self-training and active learning), the chapter *Learning from Text*, and Lab 9 (a 77-class intent classifier, similarity search and word vectors).

**Source and licence:** Casanueva and others, PolyAI, 2020, via [Hugging Face](https://huggingface.co/datasets/PolyAI/banking77); CC BY 4.0.

**Changed from the source:** The official train and test files joined, with a `split` column; `intent` spells out the name of each `label` code.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `banking77.csv` | 1.2 MB | `pd.read_csv(DATA / "advanced/banking77/banking77.csv")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- The test set has exactly 40 messages per intent; the training set has 35 to 187.
- Messages are short: the median is 10 words.
- Neighbouring intents are easy to confuse, for example `card_arrival` and `card_delivery_estimate`, or `top_up_failed` and `top_up_reverted`.
- Lab 5 draws its labelled and unlabelled messages from `split == "train"` and keeps the 3,080 test messages for the end. Lab 9 uses the official split as it is.

## Columns of `banking77.csv`

13,083 rows and 4 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `text` | text | 0 | I am still waiting on my card? |
| `label` | integer | 0 | 11 |
| `intent` | text | 0 | card_arrival |
| `split` | text | 0 | train |
