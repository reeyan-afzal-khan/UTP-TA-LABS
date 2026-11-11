# FinTech Innovation

**Status: in development.** The book, all eight lab sheets, and their PDFs are in place, but the data files and
scripts the labs work from are not yet in the repository.

A structured guide to TFB3323 FinTech Innovation: the unbundling of banking, financial inclusion, P2P lending and
crowdfunding, mobile and digital-only banks, blockchain, Big Tech in finance, and cryptocurrencies. Eight chapters
in three stages, each followed by a lab that turns the chapter's claims into numbers, and a final revision map.
Dated examples and regulatory snapshots are kept as presented in the lecturer's materials.

**[Book (PDF, the complete book)](../.all-pdfs/fintech-innovation/FI-Book.pdf)** ·
[Lab bundles](../.all-pdfs/fintech-innovation) ·
[Final revision map](../.all-pdfs/fintech-innovation/Final-Revision-Map.pdf) ·
[Typst source](main.typ) ·
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
[`.all-pdfs/fintech-innovation/`](../.all-pdfs/fintech-innovation) holds that chapter and the lab sheet. Page
numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Page ranges | Supplied files the sheet uses |
| --- | --- | --- | --- | --- |
| 1 | [Unbundling teardown of an incumbent bank](../.all-pdfs/fintech-innovation/Lab-01/Lab-Activity.pdf) | Ch. 1 | See manifest | `unbundling_scorecard.py` (students fill in `value_chain.csv`) |
| 2 | [Measuring financial inclusion](../.all-pdfs/fintech-innovation/Lab-02/Lab-Activity.pdf) | Ch. 2 | See manifest | `findex_sample.csv` |
| 3 | [P2P loan-book economics and diversification](../.all-pdfs/fintech-innovation/Lab-03/Lab-Activity.pdf) | Ch. 3 | See manifest | `loans.csv`, `loan_book.py` |
| 4 | [Mobile banking heuristic audit and funnel analysis](../.all-pdfs/fintech-innovation/Lab-04/Lab-Activity.pdf) | Ch. 4 | See manifest | `onboarding_events.csv` |
| 5 | [Neobank unit economics](../.all-pdfs/fintech-innovation/Lab-05/Lab-Activity.pdf) | Ch. 5 | See manifest | none; the code is in the sheet |
| 6 | [Build a blockchain from first principles](../.all-pdfs/fintech-innovation/Lab-06/Lab-Activity.pdf) | Ch. 6 | See manifest | none; students write `blockchain.py` |
| 7 | [Platform competition and the Big Tech threat](../.all-pdfs/fintech-innovation/Lab-07/Lab-Activity.pdf) | Ch. 7 | See manifest | `platform_scorecard.py` |
| 8 | [Testing whether a cryptocurrency is money](../.all-pdfs/fintech-innovation/Lab-08/Lab-Activity.pdf) | Ch. 8 | See manifest | `price_series.csv` |

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
  main.typ            the book: configuration and chapter list
  chapters/           8 chapters, the course map and the final revision map
  labs/               8 lab sheets, each input at the end of its chapter
  0.from_lecturer/    the lecturer's weekly slides, tutorials and practicals
```

## Building and live preview

Open the repository root in VS Code, install the recommended Tinymist extension, and open `main.typ`. Pin this file as the main document and start the preview. See the [portable setup guide](../.typst-setup/README.md).

```sh
python .typst-setup/scripts/build.py FI
python .typst-setup/scripts/publish.py FI
```

Run these commands from the repository root. Local builds go to `.build/`; publishing updates `.all-pdfs/`.

## Refined lab walkthroughs

8 labs now use compact visual routes, operation traces, and diagrams reused from the teaching chapters. The course fonts and shared page template are unchanged.

Complete runnable examples are in `all_experiments/lab*.py`. They generate labelled synthetic teaching inputs and result files under `results/labNN/`. The figures and captured outputs describe these fixtures, not observed financial markets or real institutions.

**Validation:** All eight programs ran successfully. Code coverage checks confirm every nonblank source line is printed in the relevant lab.
