# SMS spam collection

5,572 text messages, each labeled `ham` (ordinary) or `spam`.

**Used in:** Lab 3's Try-it (naive Bayes against nearest neighbors on text).

**Source and licence:** [UCI](https://archive.ics.uci.edu/dataset/228/sms+spam+collection) (Almeida and Hidalgo, 2011), via [Hugging Face](https://huggingface.co/datasets/codesignal/sms-spam-collection); CC BY 4.0.

**Changed from the source:** None: the source file, renamed.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `sms_spam.csv` | 481 KB | `pd.read_csv(DATA / "supervised/sms_spam/sms_spam.csv")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- 13.4% of messages are spam.
- 403 messages appear more than once, so a random split can put the same message on both sides.

## Columns of `sms_spam.csv`

5,572 rows and 2 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `label` | text | 0 | ham |
| `message` | text | 0 | Go until jurong point, crazy.. Availab... |
