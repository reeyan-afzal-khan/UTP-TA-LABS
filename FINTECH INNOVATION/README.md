# FinTech Innovation

**Status: in development.** The book, all eight lab sheets, and their PDFs are in place, but the data files and
scripts the labs work from are not yet in the repository.

A structured guide to TFB3323 FinTech Innovation: the unbundling of banking, financial inclusion, P2P lending and
crowdfunding, mobile and digital-only banks, blockchain, Big Tech in finance, and cryptocurrencies. Eight chapters
in three stages, each followed by a lab that turns the chapter's claims into numbers, and a final revision map.
Dated examples and regulatory snapshots are kept as presented in the lecturer's materials.

**[Book (PDF, 105 pages)](../.all_pdfs/fintech-innovation/FI-Book.pdf)** ·
[Lab bundles](../.all_pdfs/fintech-innovation) ·
[Final revision map](../.all_pdfs/fintech-innovation/Final-Revision-Map.pdf) ·
[LaTeX source](main.tex) ·
[Lecturer materials](0.from_lecturer) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 FinTech Foundations and Access | 1–2 | 1 | 1, 2 |
| 2 Alternative Finance and Digital Banking | 3–5 | 23 | 3, 4, 5 |
| 3 Distributed Infrastructure and Platform Competition | 6–8 | 63 | 6, 7, 8 |
| Final revision map | | 99 | |

## Labs

Lab *N* practises Chapter *N*; each lab's folder under
[`.all_pdfs/fintech-innovation/`](../.all_pdfs/fintech-innovation) holds that chapter and the lab sheet. Page
numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Supplied files the sheet uses |
| --- | --- | --- | --- | --- |
| 1 | [Unbundling teardown of an incumbent bank](../.all_pdfs/fintech-innovation/Lab-01/Lab-Activity.pdf) | Ch. 1 | 10–12 | `unbundling_scorecard.py` (students fill in `value_chain.csv`) |
| 2 | [Measuring financial inclusion](../.all_pdfs/fintech-innovation/Lab-02/Lab-Activity.pdf) | Ch. 2 | 20–22 | `findex_sample.csv` |
| 3 | [P2P loan-book economics and diversification](../.all_pdfs/fintech-innovation/Lab-03/Lab-Activity.pdf) | Ch. 3 | 33–36 | `loans.csv`, `loan_book.py` |
| 4 | [Mobile banking heuristic audit and funnel analysis](../.all_pdfs/fintech-innovation/Lab-04/Lab-Activity.pdf) | Ch. 4 | 44–46 | `onboarding_events.csv` |
| 5 | [Neobank unit economics](../.all_pdfs/fintech-innovation/Lab-05/Lab-Activity.pdf) | Ch. 5 | 59–62 | none; the code is in the sheet |
| 6 | [Build a blockchain from first principles](../.all_pdfs/fintech-innovation/Lab-06/Lab-Activity.pdf) | Ch. 6 | 72–75 | none; students write `blockchain.py` |
| 7 | [Platform competition and the Big Tech threat](../.all_pdfs/fintech-innovation/Lab-07/Lab-Activity.pdf) | Ch. 7 | 83–85 | `platform_scorecard.py` |
| 8 | [Testing whether a cryptocurrency is money](../.all_pdfs/fintech-innovation/Lab-08/Lab-Activity.pdf) | Ch. 8 | 96–98 | `price_series.csv` |

## Running the labs

The labs use Python: pandas for the data labs (2, 3, 4, 8), the standard library for the blockchain lab, and two
supplied scorecard scripts run from a terminal (Labs 1 and 7). Each sheet prints the code it runs and the output
to expect. Labs 2–4 use synthetic, seeded data, so their results match the worked numbers in the sheets.

## Still to do

- Add the supplied files listed above under `all_datasets/` (data) and `all_experiments/` (scripts), with a
  `requirements.txt`, so every lab runs from a clean checkout as the finished courses do. None of them is in the
  repository yet.

## Folder map

```text
FINTECH INNOVATION/
  main.tex            the book: configuration and chapter list
  chapters/           8 chapters, the course map and the final revision map
  labs/               8 lab sheets, each input at the end of its chapter
  0.from_lecturer/    the lecturer's weekly slides, tutorials and practicals
```

## Building the book

From the repository root:

```bash
python .shared/build.py FI            # rebuild the book and its lab PDFs in .all_pdfs/fintech-innovation/
python .shared/build.py FI --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
