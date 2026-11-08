# Lab 07 — Deep learning I: a first neural network and a CNN for images

A dense network and a convolutional network written in PyTorch with one explicit training loop, trained on photos of seven kinds of wood surface defect and tested once on 3,134 images from boards no model has seen, against Lab 4's classical baseline on the same images. The lab inspects the CNN's mistakes and filters and saves its weights with a model card.

**Lab sheet:** [`Lab-07/Lab-Activity.pdf`](../../../.all_pdfs/machine-learning/Lab-07/Lab-Activity.pdf), which practises Chapter 21.

## Parts

The sheet and the notebook are divided the same way; each part ends with a checkpoint.

| Part | What you do | Questions |
| --- | --- | --- |
| A | Turn the images into tensors and split off validation | 2 |
| B | Build a dense network, write the training loop, read the curves | 3–5 |
| C | Build and train a CNN; test it once; inspect its mistakes and filters | 6–10 |
| D | Save the weights with a card and reload them | 11 |
| Finish | Save the evidence; then train longer and try a one-block CNN | 12–14 |
| After | Your-turn tasks, expected findings, troubleshooting and the two checklists (on the lab sheet) | — |

## Files

| File | What it is |
| --- | --- |
| `lab07_deep_learning_cnn_worked.ipynb` | The worked notebook: every question on the sheet, its output, and what the output shows |
| `lab07_deep_learning_cnn_worked.py` | The same code cells as one script, for a terminal or a quick check |

## Data

| File | Contents | Source |
| --- | --- | --- |
| `all_datasets/unsupervised/wood_surface_defects/wood_defects.npz` | 15,701 defect photos, 32 x 32 colour, seven types, with the board each came from (as in Lab 4) | Kodytek, Bodzas and Bilik (2022), via [Hugging Face](https://huggingface.co/datasets/iluvvatar/wood_surface_defects); CC BY 4.0 |

## Run

From the course folder:

```bash
jupyter lab                                              # open lab07_deep_learning_cnn_worked.ipynb, then Restart Kernel and Run All Cells
python all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py      # or the script
```

Needs PyTorch (see the course `requirements.txt`). A run takes about four minutes on a laptop CPU, most of it the Try-it solution's 25 epochs; a GPU is used automatically when PyTorch can see one.

## What a run writes

- `results/lab07/`: training curves, `metrics.csv`, and eight figures (curves, test comparison, confusion matrix, mistakes, filters and feature maps).
- `models/wood_cnn.pt` with `models/wood_cnn_card.json`; rebuild the network with `make_cnn()` before loading the weights.

Every run regenerates these files, so do not edit them by hand. `python all_experiments/book_checks/check_your_turn.py lab07` checks the numbers printed under *Expected findings* on the sheet.
