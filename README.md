# UTP Teaching Assistant Labs Content

This repository collects laboratory materials, tutorial resources, implementations, and original LaTeX teaching companions from courses taught at Universiti Teknologi PETRONAS.

Each course is written as a book. Chapters explain the ideas, and each lab sheet comes straight after the chapter it practises. For finished courses there are also compiled PDFs of the whole book and of every lab sheet, and a worked Jupyter notebook for each lab that runs the same code as the sheet.

[YouTube playlist for software installation for these labs](https://youtube.com/playlist?list=PLinUrn8TVRE8TakJwrFYdOsH1i1GBBdVN)

## PDFs

All compiled PDFs are in [`.all_pdfs/`](.all_pdfs/). The full book has every chapter and lab in teaching order. Each lab PDF contains the same pages as that lab in the book, so you can print one or hand it out for a single session.

| Course | Full book | Lab sheets |
| --- | --- | --- |
| Machine Learning | [ML-book.pdf](.all_pdfs/machine-learning-pdfs/ML-book.pdf) · 162 pages | [1](.all_pdfs/machine-learning-pdfs/lab-01.pdf) · [2](.all_pdfs/machine-learning-pdfs/lab-02.pdf) · [3](.all_pdfs/machine-learning-pdfs/lab-03.pdf) · [4](.all_pdfs/machine-learning-pdfs/lab-04.pdf) · [5](.all_pdfs/machine-learning-pdfs/lab-05.pdf) · [6](.all_pdfs/machine-learning-pdfs/lab-06.pdf) · [7](.all_pdfs/machine-learning-pdfs/lab-07.pdf) · [8](.all_pdfs/machine-learning-pdfs/lab-08.pdf) |
| Artificial Intelligence | [AI-book.pdf](.all_pdfs/artificial-intelligence-pdfs/AI-book.pdf) · 89 pages | [1](.all_pdfs/artificial-intelligence-pdfs/lab-01.pdf) · [2](.all_pdfs/artificial-intelligence-pdfs/lab-02.pdf) · [3](.all_pdfs/artificial-intelligence-pdfs/lab-03.pdf) · [4](.all_pdfs/artificial-intelligence-pdfs/lab-04.pdf) · [5](.all_pdfs/artificial-intelligence-pdfs/lab-05.pdf) · [6](.all_pdfs/artificial-intelligence-pdfs/lab-06.pdf) · [7](.all_pdfs/artificial-intelligence-pdfs/lab-07.pdf) · [8](.all_pdfs/artificial-intelligence-pdfs/lab-08.pdf) |

## Working through a lab

1. **Read the theory.** Open the book at the chapters listed for the lab in the tables below.
2. **Open the lab sheet.** Use the lab PDF, or the page range shown in the tables to find it in the book.
3. **Run the worked notebook.** From the course folder, run `cd all_experiments`, start Jupyter, open the lab's notebook, and choose **Restart Kernel and Run All Cells**. The notebook writes its figures and tables to `results/labNN/`. Do not edit those files by hand, because every run regenerates them.

## Machine Learning

**[Book (PDF, 162 pages)](.all_pdfs/machine-learning-pdfs/ML-book.pdf)** · [LaTeX source](<MACHINE LEARNING/main.tex>) · [Notebook guide](<MACHINE LEARNING/all_experiments/README.md>) · [Datasets](<MACHINE LEARNING/all_datasets>)

This course moves step by step from data preparation and the shared mathematical foundations through supervised and unsupervised learning to a first look at deep learning. It has 21 chapters in five stages and ends with a capstone project.

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 Orientation and Tools | 1–2, plus the machine-learning map | 4 | |
| 2 Foundations Shared by Machine Learning | 3–5 | 17 | 1 |
| 3 Supervised Learning | 6–14 | 43 | 2, 3 |
| 4 Unsupervised Learning | 15–18 | 110 | 4, 5 |
| 5 Advanced Concepts | 19–21, then the capstone project | 136 | 6, 7, 8 |

| Lab | Lab sheet (PDF) | Read first | Book pages | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Feature engineering and feature selection](.all_pdfs/machine-learning-pdfs/lab-01.pdf) | Ch. 1–3 | 26–29 | [lab01_features_worked](<MACHINE LEARNING/all_experiments/lab01_features_worked.ipynb>) | Titanic, breast cancer, student performance |
| 2 | [Supervised learning I: regression, classification, and the workflow](.all_pdfs/machine-learning-pdfs/lab-02.pdf) | Ch. 4–10 | 77–83 | [lab02_supervised_workflow_worked](<MACHINE LEARNING/all_experiments/lab02_supervised_workflow_worked.ipynb>) | medical cost, bike sharing (day and hour), Titanic, breast cancer, heart failure |
| 3 | [Supervised learning II: model families](.all_pdfs/machine-learning-pdfs/lab-03.pdf) | Ch. 11–14 | 104–109 | [lab03_supervised_models_worked](<MACHINE LEARNING/all_experiments/lab03_supervised_models_worked.ipynb>) | breast cancer, Titanic, Ames housing, red wine quality |
| 4 | [Unsupervised learning I: clustering and PCA](.all_pdfs/machine-learning-pdfs/lab-04.pdf) | Ch. 15–17 | 126–129 | [lab04_clustering_pca_worked](<MACHINE LEARNING/all_experiments/lab04_clustering_pca_worked.ipynb>) | mall customers, handwritten digits |
| 5 | [Unsupervised learning II: anomaly detection and limited labels](.all_pdfs/machine-learning-pdfs/lab-05.pdf) | Ch. 18 | 133–135 | [lab05_anomaly_limited_labels_worked](<MACHINE LEARNING/all_experiments/lab05_anomaly_limited_labels_worked.ipynb>) | credit card fraud, breast cancer |
| 6 | [Reinforcement learning](.all_pdfs/machine-learning-pdfs/lab-06.pdf) | Ch. 19–20 | 147–149 | [lab06_reinforcement_worked](<MACHINE LEARNING/all_experiments/lab06_reinforcement_worked.ipynb>) | none (the notebook builds a GridWorld) |
| 7 | [Deep learning I: a first neural network and a CNN for images](.all_pdfs/machine-learning-pdfs/lab-07.pdf) | Ch. 21 | 154–157 | [lab07_deep_learning_cnn_worked](<MACHINE LEARNING/all_experiments/lab07_deep_learning_cnn_worked.ipynb>) | handwritten digits |
| 8 | [Deep learning II: an LSTM for time series](.all_pdfs/machine-learning-pdfs/lab-08.pdf) | Ch. 21 | 158–161 | [lab08_deep_learning_lstm_worked](<MACHINE LEARNING/all_experiments/lab08_deep_learning_lstm_worked.ipynb>) | bike sharing (hour) |

**Running the notebooks.** From `MACHINE LEARNING/`, run `pip install -r requirements.txt`. Labs 7 and 8 need PyTorch. They use an NVIDIA or Apple GPU when one is available and fall back to the CPU otherwise. Labs 2, 3, 4, 6, 7, and 8 save their models to [`models/`](<MACHINE LEARNING/models>). The [notebook guide](<MACHINE LEARNING/all_experiments/README.md>) covers kernels, GPUs, and reloading a saved model.

## Artificial Intelligence

**[Book (PDF, 89 pages)](.all_pdfs/artificial-intelligence-pdfs/AI-book.pdf)** · [LaTeX source](<ARTIFICIAL INTELLIGENCE/main.tex>) · [Datasets](<ARTIFICIAL INTELLIGENCE/all_datasets>)

This laboratory guide has eight lab-led modules covering search, fuzzy systems, robotics, natural language processing, and evolutionary optimization. Chapter *N* holds the theory for Lab *N*. Chapter 0 (page 4) sets up Python, the virtual environment, and the datasets.

| Lab | Lab sheet (PDF) | Theory chapter | Book pages | Worked notebook | Dataset |
| --- | --- | --- | --- | --- | --- |
| 1 | [Search Foundations on an Airline Network](.all_pdfs/artificial-intelligence-pdfs/lab-01.pdf) | 1 Uninformed Search (p. 8) | 15–18 | [lab01_search_foundations_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.ipynb>) | OpenFlights airports and routes |
| 2 | [Heuristic Search on the Airline Network](.all_pdfs/artificial-intelligence-pdfs/lab-02.pdf) | 2 Informed Search (p. 19) | 23–27 | [lab02_informed_search_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.ipynb>) | OpenFlights airports and routes |
| 3 | [Search Engineering: Package, Tests, CLI, and Benchmark](.all_pdfs/artificial-intelligence-pdfs/lab-03.pdf) | 3 Search Engineering (p. 28) | 32–36 | [lab03_search_engineering_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.ipynb>) | OpenFlights airports and routes |
| 4 | [Fuzzy Logic and ANFIS with Air-Quality Data](.all_pdfs/artificial-intelligence-pdfs/lab-04.pdf) | 4 Fuzzy Logic and ANFIS (p. 38) | 44–49 | [lab04_fuzzy_anfis_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab04_fuzzy_anfis_worked.ipynb>) | UCI Air Quality |
| 5 | [Robotics: Sensor-to-Action Control](.all_pdfs/artificial-intelligence-pdfs/lab-05.pdf) | 5 Robotics (p. 50) | 54–58 | [lab05_robotics_sensor_control_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab05_robotics_sensor_control_worked.ipynb>) | wall-following robot sensor readings |
| 6 | [NLP Foundations: Handwriting OCR Evaluation](.all_pdfs/artificial-intelligence-pdfs/lab-06.pdf) | 6 NLP Foundations (p. 60) | 64–69 | [lab06_handwriting_ocr_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab06_handwriting_ocr_worked.ipynb>) | handwritten prescriptions (zip) |
| 7 | [NLP Evaluation: Airline Tweet Sentiment Classification](.all_pdfs/artificial-intelligence-pdfs/lab-07.pdf) | 7 NLP Methods (p. 70) | 74–79 | [lab07_airline_sentiment_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab07_airline_sentiment_worked.ipynb>) | airline tweets |
| 8 | [Genetic Algorithms: Regression and Reproducibility](.all_pdfs/artificial-intelligence-pdfs/lab-08.pdf) | 8 Genetic Algorithms (p. 81) | 85–89 | [lab08_genetic_algorithm_regression_worked](<ARTIFICIAL INTELLIGENCE/all_experiments/lab08_genetic_algorithm_regression_worked.ipynb>) | medical insurance costs |

**Running the notebooks.** Follow Chapter 0 to create the environment. Lab 6 also needs the Tesseract OCR engine, which its lab setup explains. Labs 1–3 share the search package in [`all_experiments/utils/`](<ARTIFICIAL INTELLIGENCE/all_experiments/utils>). Lab 3 checks that package from a terminal before you open the notebook:

```bash
cd all_experiments
python -m pytest utils -q
python -m utils --algorithm astar --start KUL --goal KEF
```

## All courses

| Course | Note coverage |
| --- | --- |
| [Algorithms and Data Structures](<ALGORITHMS & DATA STRUCTURES/main.tex>) | Arrays through hashing, algorithm comparison, correctness arguments, complexity models, edge-case testing, and reproducible benchmarking |
| [Artificial Intelligence](<ARTIFICIAL INTELLIGENCE/main.tex>) | Search, fuzzy logic, ANFIS, robotics, NLP, genetic algorithms, experimental evaluation, error analysis, and responsible AI practice |
| [Data Communication and Networking](<DATA COMMUNICATION & NETWORKING/main.tex>) | Packet analysis, routing, services, switching, WAN links, layered troubleshooting, hardening, change control, and incident records |
| [Data Science](<DATA SCIENCE/main.tex>) | R foundations, data structures, data frames, visualization, correlation, normalization, data contracts, reproducible EDA, and evidence-based communication |
| [Enterprise Resource Planning](<ENTERPRISE RESOURCE PLANNING/main.tex>) | Integrated processes, Odoo practice, governance, segregation of duties, master-data controls, audit trails, and process analytics |
| [FinTech Innovation](<FINTECH INNOVATION/main.tex>) | Inclusion, alternative finance, digital banking, blockchain, Big Tech, cryptocurrencies, product economics, risk governance, and operational resilience |
| [Machine Learning](<MACHINE LEARNING/main.tex>) | Supervised, unsupervised, limited-label, and reinforcement learning, plus leakage prevention, reproducibility, subgroup evaluation, model cards, and monitoring |
| [Operating Systems](<OPERATING SYSTEMS/main.tex>) | Processes, scheduling, concurrency, memory, storage, security boundaries, least privilege, defensive programming, and observability |

## Repository layout

```text
.all_pdfs/
  machine-learning-pdfs/         ML-book.pdf, lab-01.pdf ... lab-08.pdf
  artificial-intelligence-pdfs/  AI-book.pdf, lab-01.pdf ... lab-08.pdf
.shared/                         preamble, cover, and logos used by every book
<COURSE>/
  main.tex                       the book: binds the chapters and labs together
  chapters/                      one .tex file per chapter
  labs/                          one .tex file per lab sheet
  all_experiments/               worked notebooks, one per lab
```

## Adding a course

Copy [`.shared/TEMPLATE-main.tex`](.shared/TEMPLATE-main.tex), which is commented top to bottom with every decision marked `REQUIRED` or `OPTIONAL`, and follow [`.shared/ADDING-A-COURSE.md`](.shared/ADDING-A-COURSE.md) for the folders, the first chapter, the labs, and the build.

## Disclaimer

These materials support teaching and independent study. They are not official university publications and do not replace the current course outline, assessment brief, or institutional policies.
