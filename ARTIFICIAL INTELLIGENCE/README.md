# Artificial Intelligence

**Status: ready.** The book, all eight lab sheets, and a worked notebook for every lab are complete and published.

A laboratory guide with eight lab-led modules: uninformed and informed search, search engineering, fuzzy logic and
ANFIS, robotics, natural language processing, and local search with genetic algorithms. It closes with a reading
chapter on game search. The search chapters follow one robot through one maze, so every method can be compared on
the same numbers. Every lab sheet is a sequence of questions and worked answers whose code is pasted from the lab's
notebook. Labs are written in Python.

**[Book (PDF, 152 pages)](../.all_pdfs/artificial-intelligence/AI-Book.pdf)** ·
[Lab bundles](../.all_pdfs/artificial-intelligence) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| Setup: Python toolkit, environment and Git | 1A–1B | 1 | |
| 1 Search and Problem Solving | 2–4 | 9 | 1, 2, 3 |
| 2 Approximate Reasoning and Intelligent Control | 5–6 | 61 | 4, 5 |
| 3 Language Intelligence | 7–8 | 93 | 6, 7 |
| 4 Local Search and Evolutionary Optimization | 9–10 | 121 | 8 |
| 5 Adversarial Search | 11 | 143 | |

## Labs

Lab *N* practises Chapter *N* + 1, except that Lab 8 practises Chapters 9 and 10 together. Chapter 11 is a reading
chapter with a runnable demo and no lab, so it has its own
[PDF](../.all_pdfs/artificial-intelligence/Adversarial-Search-When-Someone-Fights-Back.pdf). Each lab folder under
[`.all_pdfs/artificial-intelligence/`](../.all_pdfs/artificial-intelligence) holds the chapters that lab practises
and the lab sheet. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Search Foundations on an Airline Network](../.all_pdfs/artificial-intelligence/Lab-01/Lab-Activity.pdf) | Ch. 1A–2 | 25–30 | [lab01_search_foundations_worked](all_experiments/lab01_search_foundations_worked.ipynb) | OpenFlights airports and routes |
| 2 | [Heuristic Search on the Airline Network](../.all_pdfs/artificial-intelligence/Lab-02/Lab-Activity.pdf) | Ch. 3 | 39–45 | [lab02_informed_search_worked](all_experiments/lab02_informed_search_worked.ipynb) | OpenFlights airports and routes |
| 3 | [Search Engineering: Package, Tests, CLI, and Benchmark](../.all_pdfs/artificial-intelligence/Lab-03/Lab-Activity.pdf) | Ch. 4 | 52–60 | [lab03_search_engineering_worked](all_experiments/lab03_search_engineering_worked.ipynb) | OpenFlights airports and routes |
| 4 | [Fuzzy Logic and ANFIS with Air-Quality Data](../.all_pdfs/artificial-intelligence/Lab-04/Lab-Activity.pdf) | Ch. 5 | 71–78 | [lab04_fuzzy_anfis_worked](all_experiments/lab04_fuzzy_anfis_worked.ipynb) | UCI Air Quality |
| 5 | [Robotics: Sensor-to-Action Control](../.all_pdfs/artificial-intelligence/Lab-05/Lab-Activity.pdf) | Ch. 6 | 85–92 | [lab05_robotics_sensor_control_worked](all_experiments/lab05_robotics_sensor_control_worked.ipynb) | wall-following robot sensor readings |
| 6 | [NLP Foundations: Handwriting OCR Evaluation](../.all_pdfs/artificial-intelligence/Lab-06/Lab-Activity.pdf) | Ch. 7 | 99–107 | [lab06_handwriting_ocr_worked](all_experiments/lab06_handwriting_ocr_worked.ipynb) | handwritten prescriptions (zip) |
| 7 | [NLP Evaluation: Airline Tweet Sentiment Classification](../.all_pdfs/artificial-intelligence/Lab-07/Lab-Activity.pdf) | Ch. 8 | 113–120 | [lab07_airline_sentiment_worked](all_experiments/lab07_airline_sentiment_worked.ipynb) | airline tweets |
| 8 | [Genetic Algorithms: Regression and Reproducibility](../.all_pdfs/artificial-intelligence/Lab-08/Lab-Activity.pdf) | Ch. 9–10 | 135–142 | [lab08_genetic_algorithm_regression_worked](all_experiments/lab08_genetic_algorithm_regression_worked.ipynb) | medical insurance costs |

The dataset files in [`all_datasets/`](all_datasets) are named for the labs that read them
(`lab01-03_airports.csv`, `lab04-AirQuality.csv`, ...).

## Demos

Four small programs print the numbers the chapters quote. They need no dataset and run from this course folder,
for example `python all_experiments/demo_robot_maze.py`.

| Demo | Chapters | What it runs | Time |
| --- | --- | --- | --- |
| [`demo_robot_maze.py`](all_experiments/demo_robot_maze.py) | 2–4 | every route search on the robot's maze, dry and in the rain | seconds |
| [`demo_sliding_puzzle.py`](all_experiments/demo_sliding_puzzle.py) | 2–3 | breadth-first search, two ripples and A* with two heuristics on the 8-puzzle | seconds |
| [`demo_local_search.py`](all_experiments/demo_local_search.py) | 9–10 | hill climbing, restarts, simulated annealing and a genetic algorithm on eight queens, and beam search | about a minute |
| [`demo_game_search.py`](all_experiments/demo_game_search.py) | 11 | minimax, alpha-beta, evaluation functions and Monte Carlo Tree Search on noughts and crosses | about a second |

The demos assert their key results, and the maze demo checks every number it prints against the book, so to
experiment, work in a copy. Chapter 2 explains the maze demo's `CHECK_BOOK_NUMBERS` switch.

## Running the labs

Chapter 1A walks through installing Python, creating the `.venv` virtual environment and installing the packages:

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
  prescription images from the committed zip on first run. Without Tesseract it falls back to the saved predictions
  and says so in the first line it prints, so the run cannot be mistaken for live OCR.

## Folder map

```text
ARTIFICIAL INTELLIGENCE/
  main.tex            the book: configuration and chapter list
  chapters/           11 chapters, the course map and the shared maze figures
  labs/               8 lab sheets, each input at the end of the chapter it follows
  all_datasets/       the data each lab reads, named by lab
  all_experiments/    one worked notebook per lab with a .py twin, 4 demo_ programs,
                      and utils/, the search package for Labs 1-3
  results/lab01-08/   figures and tables the notebooks write
  requirements.txt    Python packages for the notebooks
```

Files in `chapters/` are numbered differently from the book: `01-uninformed-search.tex` prints as Chapter 2. The Git
chapter (1B) comes from [`.shared/`](../.shared).

## Building the book

From the repository root:

```bash
python .shared/build.py AI            # rebuild the book and its lab PDFs in .all_pdfs/artificial-intelligence/
python .shared/build.py AI --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.

## Lab sheets and what has been checked

Each lab sheet has setup steps, a warm-up on paper, questions numbered to match its notebook with reference outputs,
your-turn tasks with expected findings, troubleshooting, and verification and submission checklists. Complete notebook
code is printed in execution order and exported to `all_experiments/lab*_worked.py`; run those companions from this
folder, since each sets its own working directory. Lab 3 also prints the shared search-engine implementation.

**Checked by running them:** all eight notebooks and all eight `.py` companions (on a scratch copy, so `results/` stays
as shipped), the four demos, the `utils` test suite, and the your-turn results quoted in the sheets.

**Not checked:** live Tesseract OCR. Lab 6 ran only in its labelled cached mode, so its first two your-turn tasks were
recomputed from saved predictions, and the third, which needs live OCR, has no fixed answer in the sheet. ANFIS results
in Lab 4 can differ in the third decimal across SciPy versions, and the sheet says so.

**Building on a MiKTeX machine:** `main.tex` registers the Source Sans font map, because some MiKTeX installs otherwise
stop at the cover. A comment in `main.tex` explains it.
