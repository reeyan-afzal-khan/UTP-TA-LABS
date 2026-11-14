# Online Retail II

Every invoice line of a UK online gift shop from December 2009 to December 2011: 1,067,371 lines, 8 columns, one CSV inside the ZIP.

**Used in:** Lab 4 (customer segments with K-means and DBSCAN) and the chapter *Recommender Systems* (five recommenders tested on what customers bought next; `all_experiments/book_checks/demo_recommenders.py`).

**Source and licence:** [UCI](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (Chen, 2012), via [Hugging Face](https://huggingface.co/datasets/attik/Online-Retail-II-UCI); CC BY 4.0.

**Changed from the source:** The Hugging Face Parquet file, every invoice line, written as one CSV and zipped.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `online_retail_ii.zip` | 15.1 MB | `pd.read_csv(DATA / "unsupervised/online_retail_ii/online_retail_ii.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- Keep it zipped: pandas reads the CSV inside, and reading the million lines takes a few seconds.
- 22.8% of lines have no customer ID, 1.8% are cancellations, and 34,335 are exact duplicates; Lab 4's cleaning rules leave 779,425 lines from 5,878 customers.
- Read `Invoice` and `StockCode` as text: some codes carry letters.
- Real products have stock codes that begin with five digits. After Lab 4's cleaning, 2,848 lines under 12 other codes remain, almost all postage, carriage, discounts, bank charges, manual adjustments and test entries; the recommender chapter drops them.

## Columns of `online_retail_ii.zip`

1,067,371 rows and 8 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `Invoice` | text | 0 | 489434 |
| `StockCode` | text | 0 | 85048 |
| `Description` | text | 4,382 | 15CM CHRISTMAS GLASS BALL 20 LIGHTS |
| `Quantity` | integer | 0 | 12 |
| `InvoiceDate` | text | 0 | 2009-12-01 07:45:00 |
| `Price` | decimal | 0 | 6.95 |
| `Customer ID` | decimal | 243,007 | 13085.0 |
| `Country` | text | 0 | United Kingdom |
