# Machine Learning

**Status: ready.** The book, eleven lab sheets (Labs 0 to 10), and a worked notebook for every lab are complete.

A step-by-step path through the whole machine-learning process: tools and data, exploration and features,
supervised and unsupervised learning, recommender systems, limited labels and rewards, deep learning, text, and a
model put to work and watched. One running example, a tutor's study log of ten students, and one recipe, model, loss
and optimizer, carry through the book; real public datasets carry the labs. Each chapter opens with an everyday
picture, works a small example you can check by hand, and ends with a recap and a check. The book has 33 numbered
chapters in seven stages, eleven labs and a capstone project. Labs are written in Python with scikit-learn and
PyTorch, on real public datasets from Hugging Face, the UCI repository and Kaggle.

**[Book (PDF, the complete book)](../.all-pdfs/machine-learning/ML-Book.pdf)** ·
[Lab bundles](../.all-pdfs/machine-learning) ·
[Notebook guide](all_experiments/README.md) ·
[Dataset guide](all_datasets/README.md) ·
[Typst source](main.typ) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| Setup | 1 | 1 | |
| 1 Orientation and Tools | 2–3 | 7 | |
| 2 Foundations Shared by Machine Learning | 4–9 | 27 | 0, 1 |
| 3 Supervised Learning | 10–19 | 132 | 2, 3 |
| 4 Unsupervised Learning | 20–24 | 258 | 4 |
| 5 Limited Labels and Rewards | 25–26 | 316 | 5, 6 |
| 6 Deep Learning | 27–30 | 356 | 7, 8 |
| 7 Language and Products | 31–33 | 417 | 9, 10 |
| Capstone project | | 512 | |

Lab 5 practises Chapters 23 and 25, so its sheet comes after Chapter 25, at the start of Stage 5. Stage 4 ends with
recommender systems (Chapter 24), built on the same online shop as Lab 4.

## Labs

Each lab has its own folder under [`.all-pdfs/machine-learning/`](../.all-pdfs/machine-learning), holding the
chapters to read before it and the lab sheet itself. Page numbers are the ones printed in the book. Every sheet opens
with a map of its parts; each part starts with its goal and data and ends with a checkpoint. Every sheet also has a
header, setup steps, a warm-up on paper, questions numbered to match the notebook, the code with a *Read the code*
note, reference outputs with what they mean, exercises with answers, troubleshooting tips, and a
checklist.

| Lab | Lab sheet | Read first | Page ranges | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 0 | [Python data toolkit and exploratory data analysis](../.all-pdfs/machine-learning/Lab-00/Lab-Activity.pdf) | Ch. 3, 7 | See manifest | [lab00_data_toolkit_eda_worked](all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.ipynb) | Heart disease |
| 1 | [Feature engineering and feature selection](../.all-pdfs/machine-learning/Lab-01/Lab-Activity.pdf) | Ch. 4, 9 | See manifest | [lab01_features_worked](all_experiments/lab01_features/lab01_features_worked.ipynb) | Hotel booking demand, Telco churn, bank marketing |
| 2 | [Supervised learning I: regression, classification, and the workflow](../.all-pdfs/machine-learning/Lab-02/Lab-Activity.pdf) | Ch. 10–14 | See manifest | [lab02_supervised_workflow_worked](all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.ipynb) | Used-car listings (Cars.com), hotel booking demand, Telco churn |
| 3 | [Supervised learning II: model families](../.all-pdfs/machine-learning/Lab-03/Lab-Activity.pdf) | Ch. 15–18 | See manifest | [lab03_supervised_models_worked](all_experiments/lab03_supervised_models/lab03_supervised_models_worked.ipynb) | Lending Club loans, used-car listings, SMS spam (Try-it) |
| 4 | [Unsupervised learning I: clustering and PCA](../.all-pdfs/machine-learning/Lab-04/Lab-Activity.pdf) | Ch. 20–22 | See manifest | [lab04_clustering_pca_worked](all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.ipynb) | Online Retail II invoices, wood surface defects |
| 5 | [Unsupervised learning II: anomaly detection and limited labels](../.all-pdfs/machine-learning/Lab-05/Lab-Activity.pdf) | Ch. 23, 25 | See manifest | [lab05_anomaly_limited_labels_worked](all_experiments/lab05_anomaly_limited_labels/lab05_anomaly_limited_labels_worked.ipynb) | ULB card fraud, Banking77 support messages |
| 6 | [Reinforcement learning](../.all-pdfs/machine-learning/Lab-06/Lab-Activity.pdf) | Ch. 26 | See manifest | [lab06_reinforcement_worked](all_experiments/lab06_reinforcement/lab06_reinforcement_worked.ipynb) | none (the notebook builds a GridWorld) |
| 7 | [Deep learning I: a first neural network and a CNN for images](../.all-pdfs/machine-learning/Lab-07/Lab-Activity.pdf) | Ch. 27–29 | See manifest | [lab07_deep_learning_cnn_worked](all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.ipynb) | Wood surface defects |
| 8 | [Deep learning II: an LSTM for time series](../.all-pdfs/machine-learning/Lab-08/Lab-Activity.pdf) | Ch. 30 (with 28 and 4) | See manifest | [lab08_deep_learning_lstm_worked](all_experiments/lab08_deep_learning_lstm/lab08_deep_learning_lstm_worked.ipynb) | Portuguese electricity load, 2011–2014 |
| 9 | [Learning from text](../.all-pdfs/machine-learning/Lab-09/Lab-Activity.pdf) | Ch. 31 | See manifest | [lab09_learning_from_text_worked](all_experiments/lab09_learning_from_text/lab09_learning_from_text_worked.ipynb) | SMS spam, Banking77 support messages |
| 10 | [The end-to-end project](../.all-pdfs/machine-learning/Lab-10/Lab-Activity.pdf) | Ch. 32–33 | See manifest | [lab10_end_to_end_project_worked](all_experiments/lab10_end_to_end_project/lab10_end_to_end_project_worked.ipynb) | Hotel booking demand |
| | [Capstone project](../.all-pdfs/machine-learning/Capstone-Project.pdf) | all | See manifest | | your choice |

## Running the labs

```bash
pip install -r requirements.txt
jupyter lab
```

Start Jupyter from the course folder, open a lab's notebook in its folder under `all_experiments/`, and choose
**Restart Kernel and Run All Cells**. Notebooks read from
[`all_datasets/`](all_datasets), write their figures and tables to `results/labNN/`, and save trained models to
[`models/`](models). Every run regenerates `results/`, so never edit those files by hand.

Labs 7 and 8 need PyTorch. They use an NVIDIA or Apple GPU when one is available and fall back to the CPU, which
is what the stored outputs come from; set `CUDA_VISIBLE_DEVICES=-1` to reproduce them exactly on a machine with a GPU.
Lab 10 also uses Flask and Streamlit for its web service and page. The [notebook guide](all_experiments/README.md)
covers kernels, GPUs, reloading a saved model, `predict_churn.py`, the booking project, and the scripts that check
the book.

The reference outputs on the lab sheets come from one CPU run on Python 3.13.9, NumPy 2.3.5, pandas 2.3.3,
Matplotlib 3.10.6, scikit-learn 1.7.2, PyTorch 2.11.0, Flask 3.1.2 and Streamlit 1.51.0, and every notebook stores
that same run. Every worked number in a chapter comes from one of the sixteen scripts in
`all_experiments/book_checks/`: a `demo_*.py` for each group of chapters, and `check_your_turn.py` for every expected
finding. These scripts assert the numbers they print.

## Folder map

```text
MACHINE LEARNING/
  main.typ            the book: configuration and chapter list
  course-tools.typ    the course's own Typst helpers (code listings pulled from the scripts and notebooks)
  chapters/           33 chapters, the course map, the capstone and the study-log figures
  labs/               11 lab sheets, each input after the chapters it practises
  all_datasets/       12 datasets in supervised/, unsupervised/ and advanced/, each with a data card
  all_experiments/    one folder per lab (worked notebook, .py twin, README), course_setup.py, the notebook guide,
                      and book_checks/, the scripts that check the book (demo_*.py, check_your_turn.py)
  results/lab00-10/   figures and tables the notebooks write
  models/             trained models and their model cards
  requirements.txt    Python packages for the notebooks
```

## Building and live preview

Open the repository root in VS Code, install the recommended Tinymist extension, and open `main.typ`. Pin this file as the main document and start the preview. See the [portable setup guide](../.typst-setup/README.md).

```sh
python .typst-setup/scripts/build.py ML
python .typst-setup/scripts/publish.py ML
```

Run these commands from the repository root. Local builds go to `.build/`; publishing updates `.all-pdfs/`.
