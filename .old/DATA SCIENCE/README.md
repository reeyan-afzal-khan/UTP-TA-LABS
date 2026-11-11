# Introduction to Data Science

**Status: ready.** The book, all ten lab sheets, and a runnable R script for every lab are complete and published.

Practical data science in R, from framing a question and auditing data quality, through wrangling, exploration,
visualization and inference, to regression, classification, validation and unsupervised learning, with
reproducibility and responsible communication throughout. Eleven chapters in four stages, ten labs and a capstone.

**[Book (PDF, 106 pages)](../.all_pdfs/data-science/DS-Book.pdf)** ·
[Lab bundles](../.all_pdfs/data-science) ·
[Dataset guide](all_datasets/DATASET_GUIDE.md) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 Foundations: Questions, Data, and Reproducibility | 1–3 | 1 | 1, 2 |
| 2 Working with Data and Finding Patterns | 4–6 | 26 | 3, 4, 5 |
| 3 Uncertainty and Predictive Modelling | 7–10 | 50 | 6, 7, 8, 9 |
| 4 Unsupervised Learning and Integration | 11 | 91 | 10 |
| Capstone: an end-to-end analysis | 12 | 101 | |

## Labs

Each lab folder under [`.all_pdfs/data-science/`](../.all_pdfs/data-science) holds the chapters to read before the
lab and the lab sheet. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Script | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Frame a question and build a reproducible data profile](../.all_pdfs/data-science/Lab-01/Lab-Activity.pdf) | Ch. 1–2 | 14–15 | [lab01_workflow.R](all_experiments/lab01_workflow.R) | bike sharing (day) |
| 2 | [Audit missingness, categories, and validity](../.all_pdfs/data-science/Lab-02/Lab-Activity.pdf) | Ch. 3 | 23–25 | [lab02_data_quality.R](all_experiments/lab02_data_quality.R) | Iris, Titanic; Ames housing and red wine as extensions |
| 3 | [Reshape time-aware data and engineer defensible features](../.all_pdfs/data-science/Lab-03/Lab-Activity.pdf) | Ch. 4 | 32–33 | [lab03_wrangling.R](all_experiments/lab03_wrangling.R) | bike sharing (hour) |
| 4 | [Explore distributions, subgroups, and relationships](../.all_pdfs/data-science/Lab-04/Lab-Activity.pdf) | Ch. 5 | 40–41 | [lab04_eda.R](all_experiments/lab04_eda.R) | medical cost |
| 5 | [Design graphics that answer a question](../.all_pdfs/data-science/Lab-05/Lab-Activity.pdf) | Ch. 6 | 48–49 | [lab05_visualization.R](all_experiments/lab05_visualization.R) | red wine quality; bike sharing (hour) as an extension |
| 6 | [Quantify uncertainty with bootstrap and permutation logic](../.all_pdfs/data-science/Lab-06/Lab-Activity.pdf) | Ch. 7 | 57–59 | [lab06_inference.R](all_experiments/lab06_inference.R) | student performance |
| 7 | [Build and diagnose a regression model](../.all_pdfs/data-science/Lab-07/Lab-Activity.pdf) | Ch. 8 | 67–69 | [lab07_regression.R](all_experiments/lab07_regression.R) | Ames housing |
| 8 | [Evaluate probabilistic classification](../.all_pdfs/data-science/Lab-08/Lab-Activity.pdf) | Ch. 9 | 78–80 | [lab08_classification.R](all_experiments/lab08_classification.R) | heart failure; breast cancer and digits as extensions |
| 9 | [Validate an imbalanced classifier without leakage](../.all_pdfs/data-science/Lab-09/Lab-Activity.pdf) | Ch. 10 | 88–90 | [lab09_validation.R](all_experiments/lab09_validation.R) | credit card fraud; heart failure for calibration |
| 10 | [Discover structure with clustering and PCA](../.all_pdfs/data-science/Lab-10/Lab-Activity.pdf) | Ch. 11 | 98–100 | [lab10_unsupervised.R](all_experiments/lab10_unsupervised.R) | mall customers, wine recognition |
| | [Capstone project](../.all_pdfs/data-science/Capstone-Project.pdf) | all | 101–103 | | your choice |

## Running the labs

Install R and RStudio as Chapter 1 describes. The lab scripts use base R only, so they run on a fresh
installation; the chapters' own examples also use a few packages, installed once:

```r
install.packages(c("ggplot2", "dplyr", "tidyr", "readr", "broom"))
```

Run a lab script from the course folder (or from `all_experiments/`, which the scripts also detect):

```bash
Rscript all_experiments/lab01_workflow.R
```

or open it in RStudio and choose **Source**. Each lab sheet prints the full script, so the code in the book and
the code that runs are the same. The scripts read [`all_datasets/`](all_datasets) and never write to it; treat
the datasets as read-only, as the [dataset guide](all_datasets/DATASET_GUIDE.md) explains.

## Folder map

```text
DATA SCIENCE/
  main.tex            the book: configuration and chapter list
  chapters/           11 chapters, the course map and the capstone
  labs/               10 lab sheets, each input after its chapter
  all_datasets/       the bundled CSV files and DATASET_GUIDE.md
  all_experiments/    one R script per lab
  figures/            the charts the chapters include, listed in figures/MANIFEST.md
```

## Building the book

From the repository root:

```bash
python .shared/build.py DS            # rebuild the book and its lab PDFs in .all_pdfs/data-science/
python .shared/build.py DS --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
