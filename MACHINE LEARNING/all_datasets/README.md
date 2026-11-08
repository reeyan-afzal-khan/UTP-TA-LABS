# Course datasets

11 real, public datasets, sorted by how the course learns from them. Every dataset has its own folder, and every folder has a `README.md`: its data card, with the source and licence, what was changed, the columns, and what to watch for.

```
all_datasets/
  supervised/                          Labs 1 to 3
    hotel_bookings/                    bookings at two Portuguese hotels, cancelled or not
    telco_customer_churn/              telecom customers who left or stayed
    bank_marketing/                    a bank's phone calls selling deposits
    used_cars/                         car listings and their asking prices
    lending_club/                      personal loans, repaid or charged off
    sms_spam/                          text messages, ham or spam
  unsupervised/                        Labs 4 and 5
    online_retail_ii/                  invoice lines of an online shop
    creditcard_fraud_ulb/              card payments, a few of them fraud
    wood_surface_defects/              32 x 32 photos of defects on wooden boards
  advanced/                            Labs 5, 7 and 8
    banking77/                         bank support messages in 77 intents
    electricity_load/                  hourly electricity use of 158 customers
```

- **`supervised/`** (Labs 1 to 3): every row carries the answer a model learns to predict: a cancellation, a churn, a yes to a call, a price, a default, a spam label.
- **`unsupervised/`** (Labs 4 and 5): the labs look for structure without the answers: customer segments, the directions that describe an image, the payments that look unusual. Where a label exists, it is used only to grade what was found.
- **`advanced/`** (Labs 5, 7 and 8): few labels, deep networks and sequences: support messages with most labels hidden, and four years of hourly electricity use.

## Which lab uses what

| Dataset | File | Labs | Licence |
| --- | --- | --- | --- |
| [Hotel booking demand](supervised/hotel_bookings/) | `supervised/hotel_bookings/hotel_bookings.zip` | 1, 2 | CC BY 4.0 |
| [Telco customer churn](supervised/telco_customer_churn/) | `supervised/telco_customer_churn/telco_customer_churn.csv` | 1, 2 | CC BY 4.0 |
| [Bank marketing calls](supervised/bank_marketing/) | `supervised/bank_marketing/bank_marketing.csv` | 1 | CC BY 4.0 |
| [Used and new car listings (Cars.com)](supervised/used_cars/) | `supervised/used_cars/used_cars.zip` | 2, 3 | CC BY 4.0 |
| [Lending Club loans, 2014 and 2015](supervised/lending_club/) | `supervised/lending_club/lending_club_2014_2015.zip` | 3 | CC0 |
| [SMS spam collection](supervised/sms_spam/) | `supervised/sms_spam/sms_spam.csv` | 3 | CC BY 4.0 |
| [Online Retail II](unsupervised/online_retail_ii/) | `unsupervised/online_retail_ii/online_retail_ii.zip` | 4 | CC BY 4.0 |
| [Credit card fraud (ULB)](unsupervised/creditcard_fraud_ulb/) | `unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip` | 5 | ODbL |
| [Wood surface defects](unsupervised/wood_surface_defects/) | `unsupervised/wood_surface_defects/wood_defects.npz` | 4, 7 | CC BY 4.0 |
| [Banking77](advanced/banking77/) | `advanced/banking77/banking77.csv` | 5 | CC BY 4.0 |
| [Electricity load diagrams 2011 to 2014](advanced/electricity_load/) | `advanced/electricity_load/electricity_load_hourly.zip` | 8 | CC BY 4.0 |

Lab 6 needs no data file: its grid world is defined in the notebook.

## How the labs read them

Every lab's Setup cell sets `DATA` to this folder, and each file is then named by its path inside it:

```python
hotels = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
```

- **Keep the ZIP files zipped.** pandas reads the CSV inside each one.
- **Keep the names and folders as they are.** The notebooks, scripts and lab sheets all use these paths.
- **Do not edit the files.** Every cleaning step happens in the notebooks, so anyone can rerun it and see what it changed.

Six files hold every row of their source, renamed or converted from Parquet to a zipped CSV. Five were sampled, rounded, cut out or summed to keep the course folder small: the used cars, the Lending Club loans, the ULB payments, the wood defects and the electricity load. Each data card says exactly how.
