# Machine Learning

**Status: ready.** The book, all eight lab sheets, and a worked notebook for every lab are complete and published.

A step-by-step path from data preparation and the shared mathematical foundations, through supervised and
unsupervised learning, to a first look at deep learning. The book has 21 chapters in five stages, eight labs
and a capstone project. Labs are written in Python with scikit-learn and PyTorch.

**[Book (PDF, 160 pages)](../.all_pdfs/machine-learning/ML-Book.pdf)** ·
[Lab bundles](../.all_pdfs/machine-learning) ·
[Notebook guide](all_experiments/README.md) ·
[LaTeX source](main.tex) ·
[All courses](../README.md)

## Stages

| Stage | Chapters | Starts on page | Labs |
| --- | --- | --- | --- |
| 1 Orientation and Tools | 1–2 | 1 | |
| 2 Foundations Shared by Machine Learning | 3–5 | 12 | 1 |
| 3 Supervised Learning | 6–14 | 38 | 2, 3 |
| 4 Unsupervised Learning | 15–18 | 105 | 4, 5 |
| 5 Advanced Concepts | 19–21 | 131 | 6, 7, 8 |
| Capstone project | | 157 | |

## Labs

Each lab has its own folder under [`.all_pdfs/machine-learning/`](../.all_pdfs/machine-learning), holding the
chapters to read before it and the lab sheet itself; Labs 7 and 8 both practise Chapter 21, so each folder has a
copy. Page numbers are the ones printed in the book.

| Lab | Lab sheet | Read first | Pages | Worked notebook | Datasets |
| --- | --- | --- | --- | --- | --- |
| 1 | [Feature engineering and feature selection](../.all_pdfs/machine-learning/Lab-01/Lab-Activity.pdf) | Ch. 1–3 | 21–24 | [lab01_features_worked](all_experiments/lab01_features_worked.ipynb) | Titanic, breast cancer, student performance |
| 2 | [Supervised learning I: regression, classification, and the workflow](../.all_pdfs/machine-learning/Lab-02/Lab-Activity.pdf) | Ch. 4–10 | 72–78 | [lab02_supervised_workflow_worked](all_experiments/lab02_supervised_workflow_worked.ipynb) | medical cost, bike sharing (day and hour), Titanic, breast cancer, heart failure |
| 3 | [Supervised learning II: model families](../.all_pdfs/machine-learning/Lab-03/Lab-Activity.pdf) | Ch. 11–14 | 99–104 | [lab03_supervised_models_worked](all_experiments/lab03_supervised_models_worked.ipynb) | breast cancer, Titanic, Ames housing, red wine quality |
| 4 | [Unsupervised learning I: clustering and PCA](../.all_pdfs/machine-learning/Lab-04/Lab-Activity.pdf) | Ch. 15–17 | 121–124 | [lab04_clustering_pca_worked](all_experiments/lab04_clustering_pca_worked.ipynb) | mall customers, handwritten digits |
| 5 | [Unsupervised learning II: anomaly detection and limited labels](../.all_pdfs/machine-learning/Lab-05/Lab-Activity.pdf) | Ch. 18 | 128–130 | [lab05_anomaly_limited_labels_worked](all_experiments/lab05_anomaly_limited_labels_worked.ipynb) | credit card fraud, breast cancer |
| 6 | [Reinforcement learning](../.all_pdfs/machine-learning/Lab-06/Lab-Activity.pdf) | Ch. 19–20 | 142–144 | [lab06_reinforcement_worked](all_experiments/lab06_reinforcement_worked.ipynb) | none (the notebook builds a GridWorld) |
| 7 | [Deep learning I: a first neural network and a CNN for images](../.all_pdfs/machine-learning/Lab-07/Lab-Activity.pdf) | Ch. 21 | 149–152 | [lab07_deep_learning_cnn_worked](all_experiments/lab07_deep_learning_cnn_worked.ipynb) | handwritten digits |
| 8 | [Deep learning II: an LSTM for time series](../.all_pdfs/machine-learning/Lab-08/Lab-Activity.pdf) | Ch. 21 | 153–156 | [lab08_deep_learning_lstm_worked](all_experiments/lab08_deep_learning_lstm_worked.ipynb) | bike sharing (hour) |
| | [Capstone project](../.all_pdfs/machine-learning/Capstone-Project.pdf) | all | 157 | | your choice |

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
reloading a saved model, and `predict_passenger.py`.

## Folder map

```text
MACHINE LEARNING/
  main.tex            the book: configuration and chapter list
  chapters/           21 chapters, the course map and the capstone
  labs/               8 lab sheets, each input at the end of its chapter
  all_datasets/       the CSV files and the digits archive the labs read
  all_experiments/    one worked notebook per lab, the notebook guide, predict_passenger.py
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
