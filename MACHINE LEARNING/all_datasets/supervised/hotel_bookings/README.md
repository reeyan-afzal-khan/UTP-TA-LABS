# Hotel booking demand

119,390 bookings at two hotels in Portugal, a resort hotel in the Algarve and a city hotel in Lisbon, for arrivals from 1 July 2015 to 31 August 2017, with 32 columns. `is_canceled` says whether the booking was cancelled. One CSV inside the ZIP.

**Used in:** Lab 1 (first look, feature engineering, and the column that leaks the outcome) and Lab 2 (validating in date order, and a threshold set by what an empty room and an overbooked guest cost).

**Source and licence:** Antonio, de Almeida and Nunes, *Hotel booking demand datasets*, Data in Brief 22 (2019), 41-49, doi:[10.1016/j.dib.2018.11.126](https://doi.org/10.1016/j.dib.2018.11.126); CC BY 4.0. Via [Hugging Face](https://huggingface.co/datasets/gemuchu/hotel_bookings).

**Changed from the source:** The Hugging Face Parquet file written as one CSV and zipped.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `hotel_bookings.zip` | 1.2 MB | `pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- 37.0% of bookings were cancelled, so always guessing "not cancelled" is 63.0% accurate.
- The authors timestamp each booking at the day before arrival, but some columns were written later. `reservation_status` (`Canceled`, `No-Show` or `Check-Out`) and `reservation_status_date` record how the booking ended: they restate the outcome and must never be features.
- Softer traps: the authors note that hotels often learn a guest's correct nationality (`country`) only at check-in, and `booking_changes` counts changes up to check-in or cancellation. Bookings whose `assigned_room_type` differs from `reserved_room_type` were cancelled only 5.4% of the time, a sign that rooms are usually changed on arrival. Date every column before you use it.
- `deposit_type` `Non Refund` bookings were cancelled 99.4% of the time, against 28.4% for `No Deposit`: the opposite of what the name suggests, and a pattern to question before trusting.
- The rows are grouped by hotel, not sorted by date. Build the arrival date from `arrival_date_year`, `arrival_date_month` (a month name) and `arrival_date_day_of_month` before any split in time.
- Gaps: `company` is empty for 112,593 bookings and `agent` for 16,340. The authors call these "not applicable" rather than missing: no company or travel agent was involved. `country` is empty for 488 bookings and `children` for 4.
- `adr`, the average daily rate in euros, runs from -6.38 to 5,400: 1,959 bookings pay nothing, and the 5,400 is more than ten times the next highest rate (510).
- 31,994 rows are exact copies of another row. The file has no booking number, so bookings with the same details cannot be told apart.
- 180 bookings have no guests at all: zero adults, children and babies.

## Columns of `hotel_bookings.zip`

119,390 rows and 32 columns.

| Column | Meaning | Type | Missing | Example |
| --- | --- | --- | --- | --- |
| `hotel` | `Resort Hotel` (Algarve) or `City Hotel` (Lisbon) | text | 0 | Resort Hotel |
| `is_canceled` | 1 if the booking was cancelled: the label | integer | 0 | 0 |
| `lead_time` | days from making the booking to the arrival date | integer | 0 | 342 |
| `arrival_date_year` | year of arrival | integer | 0 | 2015 |
| `arrival_date_month` | month of arrival, as a word | text | 0 | July |
| `arrival_date_week_number` | week of the year of arrival | integer | 0 | 27 |
| `arrival_date_day_of_month` | day of the month of arrival | integer | 0 | 1 |
| `stays_in_weekend_nights` | Saturday and Sunday nights booked | integer | 0 | 0 |
| `stays_in_week_nights` | Monday to Friday nights booked | integer | 0 | 0 |
| `adults` | adults on the booking | integer | 0 | 2 |
| `children` | children on the booking | decimal | 4 | 0.0 |
| `babies` | babies on the booking | integer | 0 | 0 |
| `meal` | board booked: `BB` bed and breakfast, `HB` half board, `FB` full board, `SC` or `Undefined` none | text | 0 | BB |
| `country` | guest's country, as a three-letter ISO code | text | 488 | PRT |
| `market_segment` | where the booking came from, for example `Online TA` (travel agent) or `Groups` | text | 0 | Direct |
| `distribution_channel` | channel the booking came through: `TA/TO`, `Direct`, `Corporate`, `GDS` | text | 0 | Direct |
| `is_repeated_guest` | 1 if the guest had stayed before | integer | 0 | 0 |
| `previous_cancellations` | earlier bookings this customer cancelled | integer | 0 | 0 |
| `previous_bookings_not_canceled` | earlier bookings this customer kept | integer | 0 | 0 |
| `reserved_room_type` | room type booked (a code) | text | 0 | C |
| `assigned_room_type` | room type given (a code); can differ from the one booked | text | 0 | C |
| `booking_changes` | changes made to the booking until check-in or cancellation | integer | 0 | 3 |
| `deposit_type` | `No Deposit`, `Non Refund` (the full stay, not refundable) or `Refundable` | text | 0 | No Deposit |
| `agent` | ID of the travel agency that made the booking | decimal | 16,340 | 304.0 |
| `company` | ID of the company that made or pays for the booking | decimal | 112,593 | 110.0 |
| `days_in_waiting_list` | days the booking waited before it was confirmed | integer | 0 | 0 |
| `customer_type` | `Transient`, `Transient-Party`, `Contract` or `Group` | text | 0 | Transient |
| `adr` | average daily rate: the stay's lodging price per night, in euros | decimal | 0 | 0.0 |
| `required_car_parking_spaces` | car parking spaces asked for | integer | 0 | 0 |
| `total_of_special_requests` | special requests, such as a twin bed or a high floor | integer | 0 | 0 |
| `reservation_status` | how the booking ended: `Canceled`, `No-Show` or `Check-Out` | text | 0 | Check-Out |
| `reservation_status_date` | date that last status was set | text | 0 | 2015-07-01 |
