# Used and new car listings (Cars.com)

150,000 car listings from Cars.com, a random sample of the 1,614,161 listings in the source, with 19 columns: make, model, year, mileage, price, fuel, body, colours and the seller's ZIP code. One CSV inside the ZIP.

**Used in:** Lab 2 (linear regression on prices) and Lab 3 (random forests against boosting).

**Source and licence:** Listings collected from Cars.com by KTHESAT, via [Hugging Face](https://huggingface.co/datasets/KTHESAT/usa-used-car-market-cars-com); CC BY 4.0.

**Changed from the source:** A random 150,000 rows (seed 42) and 19 of the source's columns, written as one CSV and zipped.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `used_cars.zip` | 5.7 MB | `pd.read_csv(DATA / "supervised/used_cars/used_cars.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- `stock_type` is `Used` for 79,262 listings and `New` for 70,738. The labs price used cars, so they keep the `Used` rows; new cars have almost no mileage and a list price.
- `price_usd` is 0 or less for 834 listings (no price shown), and a few prices run into the millions, up to $21,995,995: extremes that a squared-error model would chase.
- `msrp_usd` (the maker's list price) is 0 for 74,952 listings, 73,666 of them used: it is not given, not free.
- Half the details are missing: `mpg` for 88,323 listings, `interior_color` for 73,678, `engine` for 71,960 and `transmission` for 71,730.
- `mpg` is text such as `25-33` (city and highway), and `engine` is a free-text description.
- `year` runs from 1927 to 2027: next year's models were already on sale. 552 rows are exact copies.

## Columns of `used_cars.zip`

150,000 rows and 19 columns.

| Column | Meaning | Type | Missing | Example |
| --- | --- | --- | --- | --- |
| `make` | maker, such as `Ford` | text | 0 | Lexus |
| `model` | model, such as `F-150` | text | 0 | RX 350 |
| `trim` | trim level, such as `XLT` | text | 3,433 | Premium |
| `year` | model year | integer | 0 | 2026 |
| `price_usd` | asking price, in US dollars: the label | integer | 0 | 69909 |
| `msrp_usd` | maker's suggested retail price; 0 when not given | integer | 0 | 69310 |
| `mileage_miles` | odometer reading, in miles | integer | 0 | 2 |
| `fuel` | fuel type | text | 6,048 | Gasoline |
| `transmission` | gearbox, as the seller wrote it | text | 71,730 | Automatic |
| `engine` | engine, as the seller described it | text | 71,960 | Smartstream 2.5L I-4 port/direct injec... |
| `drivetrain` | driven wheels, written two ways (`All-wheel Drive` and `AWD`) | text | 5,293 | All-wheel Drive |
| `mpg` | miles per US gallon, city and highway, as text | text | 88,323 | 25-33 |
| `body_type` | body, such as `SUV` or `Sedan` | text | 260 | SUV |
| `exterior_color` | paint colour, as the seller named it | text | 3,915 | white |
| `interior_color` | interior colour, as the seller named it | text | 73,678 | Black |
| `stock_type` | `New` or `Used` | text | 0 | New |
| `cpo` | 1 if certified pre-owned under a maker's dealer programme | integer | 0 | 0 |
| `seller_zip` | seller's US ZIP code | decimal | 86 | 8054.0 |
| `first_seen_at` | when the listing was collected | text | 0 | 2026-10-17 07:39:23 |
