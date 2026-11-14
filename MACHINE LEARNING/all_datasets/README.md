# Course datasets

12 real, public datasets, sorted by how the course learns from them. Every dataset has its own folder, and every folder has a `README.md`: its data card, with the source and licence, what was changed, the columns, and what to watch for.

```
all_datasets/
  supervised/                          the answer is known
    heart_disease/                     patients tested for heart disease
    hotel_bookings/                    bookings at two Portuguese hotels, cancelled or not
    telco_customer_churn/              telecom customers who left or stayed
    bank_marketing/                    a bank's phone calls selling deposits
    used_cars/                         car listings and their asking prices
    lending_club/                      personal loans, repaid or charged off
    sms_spam/                          text messages, ham or spam
  unsupervised/                        find structure without the answer
    online_retail_ii/                  invoice lines of an online shop
    creditcard_fraud_ulb/              card payments, a few of them fraud
    wood_surface_defects/              32 x 32 photos of defects on wooden boards
  advanced/                            few labels, text and sequences
    banking77/                         bank support messages in 77 intents
    electricity_load/                  hourly electricity use of 158 customers
```

- **`supervised/`**: every row carries the answer a model learns to predict: a diagnosis, a cancellation, a churn, a yes to a call, a price, a default, a spam label.
- **`unsupervised/`**: the labs look for structure without the answers: customer segments, what to recommend next, the directions that describe an image, the payments that look unusual. Where a label exists, it is used only to grade what was found.
- **`advanced/`**: few labels, text and sequences: support messages with most labels hidden, and four years of hourly electricity use.

## Which lab and chapter uses what

| Dataset | File | Labs | Chapters built on it | Licence |
| --- | --- | --- | --- | --- |
| [Heart disease](supervised/heart_disease/) | `supervised/heart_disease/heart_disease.csv` | 0 | 7, 8 | ODbL 1.0 |
| [Hotel booking demand](supervised/hotel_bookings/) | `supervised/hotel_bookings/hotel_bookings.zip` | 1, 2, 10 | 32, 33 | CC BY 4.0 |
| [Telco customer churn](supervised/telco_customer_churn/) | `supervised/telco_customer_churn/telco_customer_churn.csv` | 1, 2 | 3, 28 | CC BY 4.0 |
| [Bank marketing calls](supervised/bank_marketing/) | `supervised/bank_marketing/bank_marketing.csv` | 1 | | CC BY 4.0 |
| [Used and new car listings (Cars.com)](supervised/used_cars/) | `supervised/used_cars/used_cars.zip` | 2, 3 | | CC BY 4.0 |
| [Lending Club loans, 2014 and 2015](supervised/lending_club/) | `supervised/lending_club/lending_club_2014_2015.zip` | 3 | 19 | CC0 |
| [SMS spam collection](supervised/sms_spam/) | `supervised/sms_spam/sms_spam.csv` | 3, 9 | 31 | CC BY 4.0 |
| [Online Retail II](unsupervised/online_retail_ii/) | `unsupervised/online_retail_ii/online_retail_ii.zip` | 4 | 24 | CC BY 4.0 |
| [Credit card fraud (ULB)](unsupervised/creditcard_fraud_ulb/) | `unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip` | 5 | | ODbL |
| [Wood surface defects](unsupervised/wood_surface_defects/) | `unsupervised/wood_surface_defects/wood_defects.npz` | 4, 7 | 29 | CC BY 4.0 |
| [Banking77](advanced/banking77/) | `advanced/banking77/banking77.csv` | 5, 9 | 31 | CC BY 4.0 |
| [Electricity load diagrams 2011 to 2014](advanced/electricity_load/) | `advanced/electricity_load/electricity_load_hourly.zip` | 8 | 30 | CC BY 4.0 |

The chapters listed use the dataset as their running example, and their scripts in `all_experiments/book_checks/` read it from here; smaller worked examples in other chapters, and the lab results the chapters quote, use most of the datasets too. Lab 6 needs no data file: its grid world is defined in the notebook.

`advanced/lab06-ocr-handwritten-prescription.zip` is not used by any lab or chapter: its 89 phone photos each carry a different drug name, too few examples of each to learn from, and its source and licence are not recorded.

## How the labs read them

Every lab's Setup cell sets `DATA` to this folder, and each file is then named by its path inside it:

```python
hotels = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
```

- **Keep the ZIP files zipped.** pandas reads the CSV inside each one.
- **Keep the names and folders as they are.** The notebooks, scripts and lab sheets all use these paths.
- **Do not edit the files.** Every cleaning step happens in the notebooks, so anyone can rerun it and see what it changed.

Seven files hold every row of their source, renamed or converted from Parquet to a zipped CSV. Five were sampled, rounded, cut out or summed to keep the course folder small: the used cars, the Lending Club loans, the ULB payments, the wood defects and the electricity load. Each data card says exactly how.
