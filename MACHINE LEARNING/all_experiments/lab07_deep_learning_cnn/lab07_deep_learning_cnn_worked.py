"""Lab 07: Deep learning I: a first neural network and a CNN for images.

The code cells of lab07_deep_learning_cnn_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab07_deep_learning_cnn/lab07_deep_learning_cnn_worked.py
It writes the same figures and tables as the notebook, to results/lab07/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab, start_pytorch

# 2. PyTorch: installed once if missing; then the device to train on
#    (a GPU if PyTorch can see one, else the CPU).
DEVICE = start_pytorch()
import torch
from torch import nn

# 3. The other libraries this lab uses.
import re
import json
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import ConfusionMatrixDisplay
from sklearn.model_selection import GroupShuffleSplit      # keep each board on one side of a split

# 4. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab07")

# %% Question 2 - Turn images into tensors
wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
class_names = [str(name) for name in wood["classes"]]
labels, boards = wood["y"], wood["board"]

# Lab 4's board-wise splits, with the same seeds, so the test boards are the ones Lab 4's PCA model saw.
dev, test = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42)
                 .split(labels, labels, boards))
fit, val = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42)
                .split(dev, labels[dev], boards[dev]))
fit, val = dev[fit], dev[val]

def to_tensors(rows):
    """Images as (images, channels, height, width) with values in [0, 1], and labels as whole numbers."""
    X = torch.tensor(wood["x"][rows], dtype=torch.float32).permute(0, 3, 1, 2) / 255.0    # colour first
    return X.to(DEVICE), torch.tensor(labels[rows], dtype=torch.long).to(DEVICE)

X_fit, y_fit = to_tensors(fit)
X_val, y_val = to_tensors(val)
X_test, y_test = to_tensors(test)
print("fit:", tuple(X_fit.shape), " validation:", tuple(X_val.shape), " test:", tuple(X_test.shape))

fig, axes = plt.subplots(1, 7, figsize=(10, 1.9))
for ax, k in zip(axes, range(7)):
    first = int(torch.nonzero(y_fit == k)[0])                  # the first training image of each type
    ax.imshow(X_fit[first].permute(1, 2, 0).cpu())            # matplotlib wants height x width x colour
    ax.set_title(class_names[k], fontsize=8)
    ax.axis("off")
plt.suptitle("One training image of each type, as the network sees it", y=1.08)
plt.savefig(RESULTS / "one_training_image_of_each_type.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 3 - Build a dense network
def make_mlp():
    """A dense network: 3,072 pixel values -> 128 hidden units with ReLU -> 7 class scores."""
    return nn.Sequential(
        nn.Flatten(),                 # 3 x 32 x 32  ->  3,072
        nn.Linear(3 * 32 * 32, 128), nn.ReLU(),
        nn.Linear(128, 7),            # seven class scores
    )

mlp = make_mlp().to(DEVICE)
print(mlp)
print("trainable weights:", sum(p.numel() for p in mlp.parameters()))

# %% Question 4 - Write the training loop and train
def predict(model, X, batch_size=2000):
    """Class predictions in chunks, so a big test set never has to fit in memory at once."""
    model.eval()                                     # evaluation mode: dropout off
    with torch.no_grad():                            # no gradients needed just to predict
        chunks = [model(X[i:i + batch_size]).argmax(dim=1) for i in range(0, len(X), batch_size)]
    return torch.cat(chunks)

def accuracy(model, X, y):
    return (predict(model, X) == y).float().mean().item()

def train_classifier(model, X, y, X_v, y_v, epochs=10, lr=1e-3, batch_size=128):
    """The training loop: shuffle, then for every batch predict, measure the loss, and step downhill.
    Returns the training and validation accuracy after each epoch."""
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    loss_fn = nn.CrossEntropyLoss()
    history = {"train": [], "validation": []}
    for epoch in range(epochs):
        model.train()                                # training mode: dropout on
        order = torch.randperm(len(X))               # a new shuffle every epoch
        for start in range(0, len(X), batch_size):
            batch = order[start:start + batch_size]
            optimizer.zero_grad()                    # forget the previous gradients
            loss = loss_fn(model(X[batch]), y[batch])
            loss.backward()                          # backpropagation: gradient for every weight
            optimizer.step()                         # move every weight a small step
        history["train"].append(accuracy(model, X, y))
        history["validation"].append(accuracy(model, X_v, y_v))
    return history

torch.manual_seed(42)
mlp_history = train_classifier(mlp, X_fit, y_fit, X_val, y_val)
print("dense network: validation accuracy by epoch =", [round(a, 3) for a in mlp_history["validation"]])

# %% Question 5 - Read the accuracy curves
def plot_history(history, title):
    """Training and validation accuracy against the epoch; the title doubles as the file name."""
    epochs = range(1, len(history["train"]) + 1)
    plt.figure(figsize=(5.5, 3.4))
    plt.plot(epochs, history["train"], marker="o", label="training")
    plt.plot(epochs, history["validation"], marker="o", label="validation")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy")
    plt.title(title)
    plt.legend()
    plt.tight_layout()
    file_name = re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_") + ".png"
    plt.savefig(RESULTS / file_name, dpi=160, bbox_inches="tight")
    plt.show()

plot_history(mlp_history, "Dense network: accuracy per epoch")

# %% Question 6 - Build a CNN and trace its shapes
def make_cnn():
    """Two blocks of convolution, ReLU and pooling, then a small dense classifier."""
    return nn.Sequential(
        nn.Conv2d(3, 16, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),   # 16 x 16 x 16
        nn.Conv2d(16, 32, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),  # 32 x 8 x 8
        nn.Flatten(),                                                             # 2,048
        nn.Linear(32 * 8 * 8, 64), nn.ReLU(), nn.Dropout(0.2),
        nn.Linear(64, 7),
    )

torch.manual_seed(42)
cnn = make_cnn().to(DEVICE)
print("trainable weights:", sum(p.numel() for p in cnn.parameters()))

# Pass one image through the layers one at a time, and print the shape after each main layer.
sample = X_fit[:1]
for layer in cnn:
    sample = layer(sample)
    if isinstance(layer, (nn.Conv2d, nn.MaxPool2d, nn.Flatten, nn.Linear)):
        print(f"{layer.__class__.__name__:10s} -> {tuple(sample.shape[1:])}")

# %% Question 7 - Train the CNN
torch.manual_seed(42)
cnn_history = train_classifier(cnn, X_fit, y_fit, X_val, y_val)
print("CNN: validation accuracy by epoch =", [round(a, 3) for a in cnn_history["validation"]])
plot_history(cnn_history, "CNN: accuracy per epoch")

# %% Question 8 - Open the test images once
# The test boards, opened once for each model. The first number is Lab 4's result on the same images.
test_scores = {
    "PCA + logistic (Lab 4)": 0.6331,
    "dense network": accuracy(mlp, X_test, y_test),
    "CNN": accuracy(cnn, X_test, y_test),
}
for name, value in test_scores.items():
    print(f"{name:24s} test accuracy = {value:.4f}")

plt.figure(figsize=(5.5, 3.2))
plt.bar(list(test_scores), list(test_scores.values()))
plt.ylim(0.5, 0.9)
plt.ylabel("Test accuracy")
plt.title("Three models, one set of test boards")
plt.tight_layout()
plt.savefig(RESULTS / "three_models_one_set_of_test_boards.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 9 - Inspect the CNN's mistakes
test_pred = predict(cnn, X_test)
truth, guess = y_test.cpu().numpy(), test_pred.cpu().numpy()

# Recall within each type: of the test images that truly are type c, how many did the CNN call c?
per_class = pd.Series([(guess[truth == c] == c).mean() for c in range(7)], index=class_names)
print("test recall by type:\n" + per_class.round(3).sort_values().to_string())

fig, ax = plt.subplots(figsize=(6.5, 5.5))
ConfusionMatrixDisplay.from_predictions(truth, guess, display_labels=class_names, colorbar=False,
                                        xticks_rotation=45, ax=ax)
ax.set_title("CNN confusion matrix on the test boards")
plt.tight_layout()
plt.savefig(RESULTS / "cnn_confusion_matrix_on_the_test_boards.png", dpi=160, bbox_inches="tight")
plt.show()

# The first ten test images the CNN got wrong.
wrong = torch.nonzero(test_pred != y_test).flatten()[:10]
fig, axes = plt.subplots(1, len(wrong), figsize=(12, 1.9))
for ax, i in zip(axes, wrong):
    ax.imshow(X_test[i].permute(1, 2, 0).cpu())
    ax.set_title(f"{class_names[int(y_test[i])]}\nread as\n{class_names[int(test_pred[i])]}", fontsize=7)
    ax.axis("off")
plt.suptitle("Ten of the CNN's mistakes", y=1.25)
plt.savefig(RESULTS / "ten_of_the_cnn_s_mistakes.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 10 - Look at the learned filters
# The first layer's sixteen 3 x 3 filters, with their three colour layers added together
# (blue negative, red positive), so each one can be drawn as a small grid of weights.
filters = cnn[0].weight.detach().cpu().sum(dim=1)                  # 16 x 3 x 3
limit = filters.abs().max()
fig, axes = plt.subplots(2, 8, figsize=(8, 2.4))
for ax, kernel in zip(axes.flat, filters):
    ax.imshow(kernel, cmap="coolwarm", vmin=-limit, vmax=limit)
    ax.axis("off")
plt.suptitle("The sixteen 3x3 filters of the first convolutional layer, colours added", y=1.02)
plt.savefig(RESULTS / "the_sixteen_3x3_filters_of_the_first_convolutional_layer.png",
            dpi=160, bbox_inches="tight")
plt.show()

# What the first layer (convolution, then ReLU) makes of one test image: sixteen feature maps.
maps = cnn[1](cnn[0](X_test[:1])).detach().cpu()[0]
fig, axes = plt.subplots(2, 8, figsize=(8, 2.4))
for ax, fmap in zip(axes.flat, maps):
    ax.imshow(fmap, cmap="gray_r")
    ax.axis("off")
plt.suptitle(f"The first layer's sixteen views of a test {class_names[int(y_test[0])]}", y=1.02)
plt.savefig(RESULTS / "the_first_layer_s_sixteen_views.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 11 - Save the weights with a card
# The weights (the "state dict") go to one file ...
weights_path = MODELS / "wood_cnn.pt"
torch.save(cnn.state_dict(), weights_path)

# ... and the card records what is needed to use them.
card = {
    "task": "classify 32x32 colour photos of wood surface defects (seven types)",
    "classes": class_names,
    "input": "tensor of shape (n, 3, 32, 32), pixel values divided by 255",
    "architecture": "make_cnn() in Lab 7: conv16-pool-conv32-pool-dense64-dense7",
    "training": {"epochs": 10, "learning_rate": 1e-3, "batch_size": 128, "seed": 42},
    "test_accuracy": round(test_scores["CNN"], 4),
    "torch_version": torch.__version__,
    "trained_on": str(DEVICE),
}
(MODELS / "wood_cnn_card.json").write_text(json.dumps(card, indent=2))

# To load the weights, build the same network first; then check it predicts exactly as before.
restored = make_cnn().to(DEVICE)
restored.load_state_dict(torch.load(weights_path, map_location=DEVICE, weights_only=True))
same = torch.equal(predict(restored, X_test), test_pred)
size_kb = weights_path.stat().st_size / 1024
print(f"saved {weights_path.name} ({size_kb:.0f} KB); reload reproduces predictions: {same}")

# %% Question 12 - Save the evidence
curves = pd.DataFrame({
    "epoch": range(1, len(mlp_history["train"]) + 1),
    "mlp_train": mlp_history["train"], "mlp_validation": mlp_history["validation"],
    "cnn_train": cnn_history["train"], "cnn_validation": cnn_history["validation"],
})
curves.round(4).to_csv(RESULTS / "training_curves.csv", index=False)
pd.Series(test_scores, name="test_accuracy").rename_axis("model").round(4).to_csv(RESULTS / "metrics.csv")
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 13 - Try it yourself
# Your work here

# %% Question 14 - One solution
# Part 1: the same CNN, trained for 25 epochs.
torch.manual_seed(42)
long_run = make_cnn().to(DEVICE)
long_history = train_classifier(long_run, X_fit, y_fit, X_val, y_val, epochs=25)
best = int(np.argmax(long_history["validation"])) + 1
print(f"25 epochs: best validation {max(long_history['validation']):.4f} at epoch {best}; "
      f"last epoch: training {long_history['train'][-1]:.4f}, "
      f"validation {long_history['validation'][-1]:.4f}")
plot_history(long_history, "CNN over 25 epochs")

# Part 2: a CNN with only the first block; the flattened vector is now 16 x 16 x 16.
def make_one_block_cnn():
    return nn.Sequential(
        nn.Conv2d(3, 16, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),   # 16 x 16 x 16
        nn.Flatten(),                                                             # 4,096
        nn.Linear(16 * 16 * 16, 64), nn.ReLU(), nn.Dropout(0.2),
        nn.Linear(64, 7),
    )

torch.manual_seed(42)
one_block = make_one_block_cnn().to(DEVICE)
train_classifier(one_block, X_fit, y_fit, X_val, y_val)
print("one-block CNN: weights =", sum(p.numel() for p in one_block.parameters()),
      " test accuracy =", round(accuracy(one_block, X_test, y_test), 4))
print("two-block CNN: weights =", sum(p.numel() for p in cnn.parameters()),
      " test accuracy =", round(test_scores["CNN"], 4))
