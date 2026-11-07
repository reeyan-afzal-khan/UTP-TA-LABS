# Machine Learning

**Status: ready.** The book, all eight lab sheets, and a worked notebook for every lab are complete and published.

A step-by-step path from data preparation and the shared mathematical foundations, through supervised and
unsupervised learning, to neural networks, CNNs and LSTMs. One running example, a tutor's study log of ten students,
and one recipe, model, loss and optimizer, carry through the book. Each chapter opens with an everyday picture, works
a small example you can check by hand, and ends with a recap, a check and its answers. The book has 21 numbered
chapters in five stages (Chapter 1 comes in two parts, 1A and 1B), eight labs and a capstone project. Labs are written
in Python with scikit-learn and PyTorch.

**[Book (PDF, 274 pages)](../.all_pdfs/machine-learning/ML-Book.pdf)** ·
[Lab bundles](../.all_pdfs/machine-learning) ·
[Notebook guide](all_experiments/README.md) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| Setup | 1A, 1B | 1 | |
| 1 Orientation and Tools | 2 | 9 | |
| 2 Foundations Shared by Machine Learning | 3–5 | 17 | 1 |
| 3 Supervised Learning | 6–14 | 61 | 2, 3 |
| 4 Unsupervised Learning | 15–18 | 167 | 4 |
| 5 Advanced Concepts | 19–21 | 207 | 5, 6, 7, 8 |
| Capstone project | | 269 | |

Lab 5 practices Chapters 18 and 19, so its sheet comes after Chapter 19, at the start of Stage 5.

## Labs

Each lab has its own folder under [`.all_pdfs/machine-learning/`](../.all_pdfs/machine-learning), holding the
chapters to read before it and the lab sheet itself; Labs 7 and 8 both practice Chapter 21, so each folder has a
copy. Page numbers are the ones printed in the book. Every sheet has a header, setup steps, a warm-up on paper,
questions numbered to match the notebook, reference outputs with what they mean, Your-turn tasks with expected
findings, troubleshooting, and verification and submission checklists.

| Lab | Lab sheet | Read first | Pages | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Feature engineering and feature selection](../.all_pdfs/machine-learning/Lab-01/Lab-Activity.pdf) | Ch. 1A–3 | 30–41 | [lab01_features_worked](all_experiments/lab01_features_worked.ipynb) | Titanic, breast cancer, student performance |
| 2 | [Supervised learning I: regression, classification, and the workflow](../.all_pdfs/machine-learning/Lab-02/Lab-Activity.pdf) | Ch. 4–10 | 109–124 | [lab02_supervised_workflow_worked](all_experiments/lab02_supervised_workflow_worked.ipynb) | medical cost, bike sharing (day and hour), Titanic, breast cancer, heart failure |
| 3 | [Supervised learning II: model families](../.all_pdfs/machine-learning/Lab-03/Lab-Activity.pdf) | Ch. 11–14 | 154–166 | [lab03_supervised_models_worked](all_experiments/lab03_supervised_models_worked.ipynb) | breast cancer, Titanic, Ames housing, red wine quality |
| 4 | [Unsupervised learning I: clustering and PCA](../.all_pdfs/machine-learning/Lab-04/Lab-Activity.pdf) | Ch. 15–17 | 191–201 | [lab04_clustering_pca_worked](all_experiments/lab04_clustering_pca_worked.ipynb) | mall customers, handwritten digits |
| 5 | [Unsupervised learning II: anomaly detection and limited labels](../.all_pdfs/machine-learning/Lab-05/Lab-Activity.pdf) | Ch. 18–19 | 213–222 | [lab05_anomaly_limited_labels_worked](all_experiments/lab05_anomaly_limited_labels_worked.ipynb) | credit card fraud, breast cancer |
| 6 | [Reinforcement learning](../.all_pdfs/machine-learning/Lab-06/Lab-Activity.pdf) | Ch. 20 | 230–238 | [lab06_reinforcement_worked](all_experiments/lab06_reinforcement_worked.ipynb) | none (the notebook builds a GridWorld) |
| 7 | [Deep learning I: a first neural network and a CNN for images](../.all_pdfs/machine-learning/Lab-07/Lab-Activity.pdf) | Ch. 21 | 247–258 | [lab07_deep_learning_cnn_worked](all_experiments/lab07_deep_learning_cnn_worked.ipynb) | handwritten digits |
| 8 | [Deep learning II: an LSTM for time series](../.all_pdfs/machine-learning/Lab-08/Lab-Activity.pdf) | Ch. 21 | 259–268 | [lab08_deep_learning_lstm_worked](all_experiments/lab08_deep_learning_lstm_worked.ipynb) | bike sharing (hour) |
| | [Capstone project](../.all_pdfs/machine-learning/Capstone-Project.pdf) | all | 269–270 | | your choice |

## Running the labs

```bash
pip install -r requirements.txt
cd all_experiments
jupyter lab
```

Open a notebook and choose **Restart Kernel and Run All Cells**. Notebooks read from
[`all_datasets/`](all_datasets), write their figures and tables to `results/labNN/`, and save trained models to
[`models/`](models). Every run regenerates `results/`, so never edit those files by hand.

Labs 7 and 8 need PyTorch. They use an NVIDIA or Apple GPU when one is available and fall back to the CPU, which
is what the stored outputs come from. The [notebook guide](all_experiments/README.md) covers kernels, GPUs,
reloading a saved model, `predict_passenger.py`, and the scripts that check the book.

The reference outputs on the lab sheets come from one CPU run on Python 3.13.9, NumPy 2.3.5, pandas 2.3.3,
Matplotlib 3.10.6, scikit-learn 1.7.2 and PyTorch 2.11.0. The outputs stored in the notebooks come from an earlier
run on newer versions; the sheets say where the two differ. Every worked number in a chapter comes from
`all_experiments/demo_*.py`, and every expected finding from `all_experiments/check_your_turn.py`. These scripts
assert the numbers they print.

## Folder map

```text
MACHINE LEARNING/
  main.tex            the book: configuration and chapter list
  chapters/           the chapters, the course map, the capstone and the study-log figures
  labs/               8 lab sheets, each input after the chapters it practices
  all_datasets/       the CSV files and the digits archive the labs read
  all_experiments/    one worked notebook and .py twin per lab, the notebook guide, predict_passenger.py,
                      and the scripts that check the book (demo_*.py, check_your_turn.py)
  results/lab01-08/   figures and tables the notebooks write
  models/             trained models and their model cards
  requirements.txt    Python packages for the notebooks
```

## Building the book

From the repository root:

```bash
python .shared/build.py ML            # rebuild the book and its lab PDFs in .all_pdfs/machine-learning/
python .shared/build.py ML --check    # build only, to check a change; writes nothing
```

The build runs in a temporary folder, so nothing is written to this course folder. See [`.shared/`](../.shared)
for the shared styles every book uses.
