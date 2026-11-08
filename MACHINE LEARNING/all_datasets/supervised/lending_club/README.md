# Lending Club loans, 2014 and 2015

100,000 personal loans issued by Lending Club, a US peer-to-peer lender, in 2014 and 2015, each either paid in full or charged off (`loan_status`), with 40 columns: what the borrower declared, their credit file, the loan's terms, and eight columns written after the loan was issued. One CSV inside the ZIP.

**Used in:** Lab 3 (nearest neighbors, naive Bayes, trees and SVMs on loan defaults).

**Source and licence:** Lending Club's public loan data, 2007 to 2018, via [Hugging Face](https://huggingface.co/datasets/codesignal/lending-club-loan-accepted); CC0.

**Changed from the source:** The source holds 2.26 million loans in 151 columns. Kept: loans issued in 2014 or 2015 that had finished, a random 100,000 of them (seed 42), and 40 columns.

## Files

| File | Size | Read it with |
| --- | --- | --- |
| `lending_club_2014_2015.zip` | 7.4 MB | `pd.read_csv(DATA / "supervised/lending_club/lending_club_2014_2015.zip")` |

`DATA` is the course's `all_datasets/` folder; every lab's Setup cell defines it.

## What to watch for

- 19.4% of the loans were charged off. Default rises with Lending Club's own `grade`, from 5.5% for grade A to 49.6% for grade G.
- Eight columns were written after the loan was issued and give the outcome away: `total_pymnt`, `total_rec_prncp`, `total_rec_int`, `recoveries`, `last_pymnt_d`, `last_pymnt_amnt`, `last_fico_range_high` and `last_fico_range_low`. They are kept for the leakage lesson only.
- `grade`, `sub_grade` and `int_rate` are the lender's own risk estimate. A model that uses them partly copies the lender's model.
- `term` starts with a space (` 36 months`), `emp_length` is text (`10+ years`, `< 1 year`), and `int_rate` and `revol_util` are percentages.
- `mths_since_last_delinq` is empty for 48,836 borrowers who have no late payment on record: the gap is information, not noise.
- `emp_title` is free text with 37,663 different job titles.

## Columns of `lending_club_2014_2015.zip`

100,000 rows and 40 columns.

| Column | Meaning | Type | Missing | Example |
| --- | --- | --- | --- | --- |
| `loan_amnt` | amount lent, in dollars | decimal | 0 | 13200.0 |
| `term` | ` 36 months` or ` 60 months` | text | 0 |  60 months |
| `int_rate` | interest rate, percent a year | decimal | 0 | 9.17 |
| `installment` | monthly payment, in dollars | decimal | 0 | 275.11 |
| `grade` | Lending Club's risk grade, `A` (safest) to `G` | text | 0 | B |
| `sub_grade` | finer grade, `A1` to `G5` | text | 0 | B1 |
| `emp_title` | job title, as the borrower typed it | text | 5,738 | Institutional Sales and Trading |
| `emp_length` | years in the current job, `< 1 year` to `10+ years` | text | 5,542 | 8 years |
| `home_ownership` | `RENT`, `MORTGAGE`, `OWN` or other | text | 0 | MORTGAGE |
| `annual_inc` | annual income the borrower declared, in dollars | decimal | 0 | 115000.0 |
| `verification_status` | whether Lending Club checked the income | text | 0 | Not Verified |
| `issue_d` | month the loan was issued | text | 0 | Jul-2014 |
| `loan_status` | `Fully Paid` or `Charged Off`: the label | text | 0 | Fully Paid |
| `purpose` | what the borrower said the loan is for | text | 0 | debt_consolidation |
| `title` | loan title, as the borrower typed it | text | 18 | Debt consolidation |
| `addr_state` | borrower's US state | text | 0 | NY |
| `dti` | debt-to-income ratio: monthly debt payments, without mortgage or this loan, over monthly income, in percent | decimal | 1 | 8.94 |
| `delinq_2yrs` | payments 30 or more days late in the past two years | decimal | 0 | 0.0 |
| `earliest_cr_line` | month the borrower's first credit line opened | text | 0 | Aug-1985 |
| `fico_range_low` | lower end of the borrower's FICO credit score at application | decimal | 0 | 750.0 |
| `fico_range_high` | upper end of that FICO score | decimal | 0 | 754.0 |
| `inq_last_6mths` | credit enquiries in the last six months | decimal | 0 | 0.0 |
| `mths_since_last_delinq` | months since the last late payment; empty if none | decimal | 48,836 | 80.0 |
| `open_acc` | open credit lines | decimal | 0 | 19.0 |
| `pub_rec` | derogatory public records | decimal | 0 | 0.0 |
| `revol_bal` | revolving balance (mostly card debt), in dollars | decimal | 0 | 31416.0 |
| `revol_util` | share of available revolving credit in use, in percent | decimal | 39 | 23.2 |
| `total_acc` | credit lines ever opened | decimal | 0 | 39.0 |
| `initial_list_status` | how the loan was first offered to investors: `w` whole or `f` fractional | text | 0 | f |
| `application_type` | `Individual` or `Joint App` | text | 0 | Individual |
| `mort_acc` | mortgage accounts | decimal | 0 | 2.0 |
| `pub_rec_bankruptcies` | bankruptcies on public record | decimal | 0 | 0.0 |
| `total_pymnt` | after issue: everything the borrower paid | decimal | 0 | 15638.949045873 |
| `total_rec_prncp` | after issue: principal repaid | decimal | 0 | 13200.0 |
| `total_rec_int` | after issue: interest paid | decimal | 0 | 2438.95 |
| `recoveries` | after issue: money recovered after a charge-off | decimal | 0 | 0.0 |
| `last_pymnt_d` | after issue: month of the last payment | text | 66 | Jan-2017 |
| `last_pymnt_amnt` | after issue: amount of the last payment | decimal | 0 | 7660.76 |
| `last_fico_range_high` | after issue: upper end of the latest FICO score | decimal | 0 | 764.0 |
| `last_fico_range_low` | after issue: lower end of the latest FICO score | decimal | 0 | 760.0 |
