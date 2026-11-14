# Electricity load diagrams 2011 to 2014

Hourly electricity use, in kWh, of 158 Portuguese customers from 1 January 2011 to 31 December 2014: 35,064 hours, one column per customer, one CSV inside the ZIP.

**Used in:** the chapter *Sequence Models and Attention* (recurrent networks, GRU, LSTM and attention on the same forecast) and Lab 8 (LSTM forecasting).

**Source and licence:** [UCI](https://archive.ics.uci.edu/dataset/321/electricityloaddiagrams20112014) (Trindade, 2015, doi:10.24432/C58C86), via [Hugging Face](https://huggingface.co/datasets/sxj1024/electricity_load_2011_2014); CC BY 4.0.

**Changed from the source:** The source holds kW per 15 minutes for 370 customers. Kept: the 158 customers already connected at the first reading, so every column covers all four years. Each hour is the sum of its four readings divided by 4, which gives kWh, labeled by the hour's start (`hour_start`, Portuguese local time).

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `electricity_load_hourly.zip` | 15.5 MB | `pd.read_csv(DATA / "advanced/electricity_load/electricity_load_hourly.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- Lab 8 adds the 158 columns into one demand series, in MWh: 109.8 MWh in an average hour.
- The clock changes survive from the source on purpose. On the day the clocks go forward in March the meters record nearly nothing around 1 a.m.; on the day they go back in October that hour holds two hours of use. The March 2014 change is the lowest hour in the file, and the October 2014 change gives Lab 8's LSTM its two largest test errors.

## Columns of `electricity_load_hourly.zip`

35,064 rows and 159 columns.

| Column | Type | Missing | Example |
| --- | --- | --- | --- |
| `hour_start` | text | 0 | 2011-01-01 00:00 |
| `MT_124` ... `MT_331` | decimal (158 columns) | 0 | 69.38 |
