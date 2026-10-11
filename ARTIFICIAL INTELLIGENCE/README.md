# Artificial Intelligence

**Status: ready.** The book, all eight lab sheets, and a worked notebook for every lab are complete and published.

A laboratory guide with eight lab-led modules: uninformed and informed search, search engineering, fuzzy logic and
ANFIS, robotics, natural language processing, and genetic algorithms. Every lab sheet is a sequence of questions
and worked answers whose code is pasted from the lab's notebook. Labs are written in Python.

**[Book (PDF, 93 pages)](../.all_pdfs/artificial-intelligence/AI-Book.pdf)** ·
[Lab bundles](../.all_pdfs/artificial-intelligence) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| Setup: Python toolkit and environment | 1 | 1 | |
| 1 Search and Problem Solving | 2–4 | 8 | 1, 2, 3 |
| 2 Approximate Reasoning and Intelligent Control | 5–6 | 38 | 4, 5 |
| 3 Language Intelligence | 7–8 | 60 | 6, 7 |
| 4 Evolutionary Optimization | 9 | 81 | 8 |

## Labs

Lab *N* practises Chapter *N* + 1. Each lab folder under
[`.all_pdfs/artificial-intelligence/`](../.all_pdfs/artificial-intelligence) holds that chapter and the lab sheet.
Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Search Foundations on an Airline Network](../.all_pdfs/artificial-intelligence/Lab-01/Lab-Activity.pdf) | Ch. 1–2 | 16–19 | [lab01_search_foundations_worked](all_experiments/lab01_search_foundations_worked.ipynb) | OpenFlights airports and routes |
| 2 | [Heuristic Search on the Airline Network](../.all_pdfs/artificial-intelligence/Lab-02/Lab-Activity.pdf) | Ch. 3 | 24–28 | [lab02_informed_search_worked](all_experiments/lab02_informed_search_worked.ipynb) | OpenFlights airports and routes |
| 3 | [Search Engineering: Package, Tests, CLI, and Benchmark](../.all_pdfs/artificial-intelligence/Lab-03/Lab-Activity.pdf) | Ch. 4 | 33–37 | [lab03_search_engineering_worked](all_experiments/lab03_search_engineering_worked.ipynb) | OpenFlights airports and routes |
| 4 | [Fuzzy Logic and ANFIS with Air-Quality Data](../.all_pdfs/artificial-intelligence/Lab-04/Lab-Activity.pdf) | Ch. 5 | 45–50 | [lab04_fuzzy_anfis_worked](all_experiments/lab04_fuzzy_anfis_worked.ipynb) | UCI Air Quality |
| 5 | [Robotics: Sensor-to-Action Control](../.all_pdfs/artificial-intelligence/Lab-05/Lab-Activity.pdf) | Ch. 6 | 55–59 | [lab05_robotics_sensor_control_worked](all_experiments/lab05_robotics_sensor_control_worked.ipynb) | wall-following robot sensor readings |
| 6 | [NLP Foundations: Handwriting OCR Evaluation](../.all_pdfs/artificial-intelligence/Lab-06/Lab-Activity.pdf) | Ch. 7 | 65–70 | [lab06_handwriting_ocr_worked](all_experiments/lab06_handwriting_ocr_worked.ipynb) | handwritten prescriptions (zip) |
| 7 | [NLP Evaluation: Airline Tweet Sentiment Classification](../.all_pdfs/artificial-intelligence/Lab-07/Lab-Activity.pdf) | Ch. 8 | 75–80 | [lab07_airline_sentiment_worked](all_experiments/lab07_airline_sentiment_worked.ipynb) | airline tweets |
| 8 | [Genetic Algorithms: Regression and Reproducibility](../.all_pdfs/artificial-intelligence/Lab-08/Lab-Activity.pdf) | Ch. 9 | 86–90 | [lab08_genetic_algorithm_regression_worked](all_experiments/lab08_genetic_algorithm_regression_worked.ipynb) | medical insurance costs |

The dataset files in [`all_datasets/`](all_datasets) are named for the labs that read them
(`lab01-03_airports.csv`, `lab04-AirQuality.csv`, ...).

## Running the labs

Chapter 1 walks through installing Python, creating the `.venv` virtual environment and installing the packages:

```bash
python -m venv .venv
# activate it (.venv\Scripts\Activate.ps1 on Windows, source .venv/bin/activate elsewhere), then
pip install -r requirements.txt
cd all_experiments
jupyter lab
```

Open a notebook and choose **Restart Kernel and Run All Cells**. Notebooks write their evidence to
`results/labNN/`, which every run regenerates; never edit those files by hand.

- **Labs 1–3** share the search package in [`all_experiments/utils/`](all_experiments/utils). Lab 3 checks it
  from a terminal before you open the notebook:

  ```bash
  cd all_experiments
  python -m pytest utils -q
  python -m utils --algorithm astar --start KUL --goal KEF
  ```

- **Lab 6** also needs the Tesseract OCR engine, which the lab's setup section explains. The notebook extracts the
  prescription images from the committed zip on first run.

## Folder map

```text
ARTIFICIAL INTELLIGENCE/
  main.tex            the book: configuration and chapter list
  chapters/           9 chapters and the course map
  labs/               8 lab sheets, each input at the end of its chapter
  all_datasets/       the data each lab reads, named by lab
  all_experiments/    one worked notebook per lab, and utils/, the search package for Labs 1-3
  results/lab01-08/   figures and tables the notebooks write
  requirements.txt    Python packages for the notebooks
```

## Building the book

From the repository root:

```bash
python .shared/build.py AI            # rebuild the book and its lab PDFs in .all_pdfs/artificial-intelligence/
python .shared/build.py AI --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
