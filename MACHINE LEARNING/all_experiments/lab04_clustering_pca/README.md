# Lab 04 — Unsupervised learning I: clustering and PCA

Unsupervised learning on two real collections: every invoice line of a UK online shop from 2009 to 2011, turned into one row per customer and segmented with K-means and DBSCAN, and 15,701 photos of defects on sawn wooden boards, compressed with PCA under a budget chosen on validation, with whole boards kept on one side of every split.

**Lab sheet:** [`Lab-04/Lab-Activity.pdf`](../../../.all_pdfs/machine-learning/Lab-04/Lab-Activity.pdf), which practises Chapters 15 to 17.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Build customer rows, segment them with $K$-means, find outliers with DBSCAN | 2–6 |
| B | Compress wood-defect images with PCA, choose the budget, test once and save | 7–11 |
| Finish | Save the evidence; then cluster the defect images | 12–14 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab04_clustering_pca_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab04_clustering_pca_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/unsupervised/online_retail_ii/online_retail_ii.zip` | 1,067,371 invoice lines, December 2009 to December 2011, one CSV inside | [UCI](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (Chen, 2012), via [Hugging Face](https://huggingface.co/datasets/attik/Online-Retail-II-UCI); CC BY 4.0 |
| `all_datasets/unsupervised/wood_surface_defects/wood_defects.npz` | 15,701 defect photos, 32 x 32 colour, seven defect types, with the board each came from (also used in Lab 7) | Kodytek, Bodzas and Bilik (2022), via [Hugging Face](https://huggingface.co/datasets/iluvvatar/wood_surface_defects); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab04_clustering_pca_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py      # or the script
```

A run takes under a minute on a laptop CPU.

## What a run writes

- `results/lab04/`: K-means diagnostics, the customer segments, the PCA variance curve, `metrics.csv` and five figures.
- `models/wood_pca_logistic.joblib`, the PCA and logistic-regression pipeline.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab04` checks the numbers printed under *Expected findings* on the sheet.
