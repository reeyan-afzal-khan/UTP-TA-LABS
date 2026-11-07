# Complete executable companion to lab07_deep_learning_cnn_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

import re
import json
import os
import site
import subprocess
import sys
import zipfile
from pathlib import Path

# Anaconda's NumPy and pip's PyTorch each ship an OpenMP runtime on Windows; let them coexist.
os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import ConfusionMatrixDisplay, accuracy_score

# PyTorch: import it, or install the CPU build into this kernel's Python if it is missing.
try:
    import torch
except ModuleNotFoundError:
    print("PyTorch is not installed for", sys.executable, "- installing it once (a few hundred MB) ...")
    pip = [sys.executable, "-m", "pip", "install", "torch"]
    if subprocess.run(pip + ["--index-url", "https://download.pytorch.org/whl/cpu"]).returncode != 0:
        subprocess.run(pip, check=True)      # PyTorch's own index unreachable: fall back to PyPI
    site.addsitedir(site.getusersitepackages())   # pip may use the per-user folder, which some kernels skip
    import torch
from torch import nn

# Use a GPU when PyTorch can see one (NVIDIA "cuda" or Apple "mps"); otherwise the CPU.
# Neither lab needs a GPU: Lab 7 takes under a minute on a CPU, Lab 8 a little over one.
if torch.cuda.is_available():
    DEVICE = torch.device("cuda")
elif getattr(torch.backends, "mps", None) is not None and torch.backends.mps.is_available():
    DEVICE = torch.device("mps")
else:
    DEVICE = torch.device("cpu")
torch.manual_seed(42)
PROJECT_ROOT = Path.cwd().parent
DATA = PROJECT_ROOT / "all_datasets"
MODELS = PROJECT_ROOT / "models"
MODELS.mkdir(exist_ok=True)
print("Python", sys.version.split()[0], "at", sys.executable)
print("PyTorch", torch.__version__, "| device:", DEVICE,
      f"({torch.cuda.get_device_name(0)})" if DEVICE.type == "cuda" else "")

RESULTS = PROJECT_ROOT / "results" / "lab07"
RESULTS.mkdir(parents=True, exist_ok=True)
print("course folder:", PROJECT_ROOT.name)

columns = [f"pixel_{i}" for i in range(64)] + ["label"]
with zipfile.ZipFile(DATA / "optical_recognition_handwritten_digits.zip") as archive:
    members = {Path(name).name: name for name in archive.namelist()}
    train = pd.read_csv(archive.open(members["optdigits.tra"]), header=None, names=columns)
    test = pd.read_csv(archive.open(members["optdigits.tes"]), header=None, names=columns)

def to_tensors(frame):
    X = torch.tensor(frame.drop(columns="label").to_numpy(), dtype=torch.float32)
    X = X.reshape(-1, 1, 8, 8) / 16.0            # (rows, channels, height, width), values in [0, 1]
    y = torch.tensor(frame["label"].to_numpy(), dtype=torch.long)
    return X.to(DEVICE), y.to(DEVICE)         # tensors live on the chosen device

X_dev, y_dev = to_tensors(train)
X_test, y_test = to_tensors(test)
perm = torch.randperm(len(X_dev), generator=torch.Generator().manual_seed(42))
n_val = len(X_dev) // 4
X_val, y_val = X_dev[perm[:n_val]], y_dev[perm[:n_val]]
X_fit, y_fit = X_dev[perm[n_val:]], y_dev[perm[n_val:]]
print("fit:", X_fit.shape, " validation:", X_val.shape, " test:", X_test.shape)

fig, axes = plt.subplots(1, 10, figsize=(10, 1.4))
for ax, image, label in zip(axes, X_fit[:10], y_fit[:10]):
    ax.imshow(image[0].cpu(), cmap="gray_r")     # matplotlib wants a CPU tensor
    ax.set_title(int(label), fontsize=9)
    ax.axis("off")
plt.suptitle("Ten training digits as the network sees them", y=1.05)
plt.savefig(RESULTS / "ten_training_digits_as_the_network_sees_them.png", dpi=160, bbox_inches="tight")
plt.show()

def make_mlp():
    return nn.Sequential(
        nn.Flatten(),                 # 1 x 8 x 8  ->  64
        nn.Linear(64, 128), nn.ReLU(),
        nn.Linear(128, 10),           # ten class scores
    )

mlp = make_mlp().to(DEVICE)
print(mlp)
print("trainable weights:", sum(p.numel() for p in mlp.parameters()))

def accuracy(model, X, y):
    model.eval()
    with torch.no_grad():
        return (model(X).argmax(dim=1) == y).float().mean().item()

def train_classifier(model, X, y, X_v, y_v, epochs=20, lr=3e-3, batch_size=32):
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    loss_fn = nn.CrossEntropyLoss()
    history = {"train": [], "validation": []}
    for epoch in range(epochs):
        model.train()
        order = torch.randperm(len(X))
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
print("dense network: validation accuracy =", round(mlp_history["validation"][-1], 4))

def plot_history(history, title):
    plt.figure(figsize=(5.5, 3.4))
    plt.plot(range(1, len(history["train"]) + 1), history["train"], marker="o", label="training")
    plt.plot(range(1, len(history["validation"]) + 1), history["validation"],
             marker="o", label="validation")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy")
    plt.title(title)
    plt.legend()
    plt.tight_layout()
    plt.savefig(RESULTS / (re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_") + ".png"), dpi=160, bbox_inches="tight")
    plt.show()

plot_history(mlp_history, "Dense network: accuracy per epoch")

def make_cnn():
    return nn.Sequential(
        nn.Conv2d(1, 16, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),   # 16 x 4 x 4
        nn.Conv2d(16, 32, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),  # 32 x 2 x 2
        nn.Flatten(),                                                             # 128
        nn.Linear(32 * 2 * 2, 64), nn.ReLU(), nn.Dropout(0.2),
        nn.Linear(64, 10),
    )

cnn = make_cnn().to(DEVICE)
print("trainable weights:", sum(p.numel() for p in cnn.parameters()))
sample = X_fit[:1]
for layer in cnn:
    sample = layer(sample)
    if isinstance(layer, (nn.Conv2d, nn.MaxPool2d, nn.Flatten, nn.Linear)):
        print(f"{layer.__class__.__name__:10s} -> {tuple(sample.shape[1:])}")

torch.manual_seed(42)
cnn_history = train_classifier(cnn, X_fit, y_fit, X_val, y_val)
print("CNN: validation accuracy =", round(cnn_history["validation"][-1], 4))
plot_history(cnn_history, "CNN: accuracy per epoch")

test_scores = {
    "logistic on PCA (Lab 4)": 0.9477,
    "dense network": accuracy(mlp, X_test, y_test),
    "CNN": accuracy(cnn, X_test, y_test),
}
for name, value in test_scores.items():
    print(f"{name:26s} test accuracy = {value:.4f}")

plt.figure(figsize=(5, 3.2))
plt.bar(list(test_scores), list(test_scores.values()))
plt.ylim(0.9, 1.0)
plt.ylabel("Official test accuracy")
plt.title("Three models, one test file")
plt.tight_layout()
plt.savefig(RESULTS / "three_models_one_test_file.png", dpi=160, bbox_inches="tight")
plt.show()

cnn.eval()
with torch.no_grad():
    test_pred = cnn(X_test).argmax(dim=1)

ConfusionMatrixDisplay.from_predictions(y_test.cpu().numpy(), test_pred.cpu().numpy(), colorbar=False)
plt.title("CNN confusion matrix on the official test file")
plt.tight_layout()
plt.savefig(RESULTS / "cnn_confusion_matrix_on_the_official_test_file.png", dpi=160, bbox_inches="tight")
plt.show()

wrong = torch.nonzero(test_pred != y_test).flatten()[:10]
fig, axes = plt.subplots(1, len(wrong), figsize=(10, 1.6))
for ax, i in zip(axes, wrong):
    ax.imshow(X_test[i, 0].cpu(), cmap="gray_r")
    ax.set_title(f"{int(y_test[i])} read as {int(test_pred[i])}", fontsize=8)
    ax.axis("off")
plt.suptitle("Ten of the CNN's mistakes", y=1.1)
plt.savefig(RESULTS / "ten_of_the_cnn_s_mistakes.png", dpi=160, bbox_inches="tight")
plt.show()

filters = cnn[0].weight.detach().cpu()[:, 0]
fig, axes = plt.subplots(2, 8, figsize=(8, 2.4))
for ax, kernel in zip(axes.flat, filters):
    ax.imshow(kernel, cmap="coolwarm", vmin=-filters.abs().max(), vmax=filters.abs().max())
    ax.axis("off")
plt.suptitle("The sixteen 3x3 filters of the first convolutional layer", y=1.02)
plt.savefig(RESULTS / "the_sixteen_3x3_filters_of_the_first_convolutional_layer.png", dpi=160, bbox_inches="tight")
plt.show()

weights_path = MODELS / "digits_cnn.pt"
torch.save(cnn.state_dict(), weights_path)

card = {
    "task": "classify 8x8 handwritten digits (0-9)",
    "input": "tensor of shape (n, 1, 8, 8), pixel values divided by 16",
    "architecture": "make_cnn() in Lab 7: conv16-pool-conv32-pool-dense64-dense10",
    "training": {"epochs": 20, "learning_rate": 3e-3, "batch_size": 32, "seed": 42},
    "official_test_accuracy": round(test_scores["CNN"], 4),
    "torch_version": torch.__version__,
    "trained_on": str(DEVICE),
}
(MODELS / "digits_cnn_card.json").write_text(json.dumps(card, indent=2))

restored = make_cnn().to(DEVICE)
restored.load_state_dict(torch.load(weights_path, map_location=DEVICE, weights_only=True))
restored.eval()
with torch.no_grad():
    same = torch.equal(restored(X_test).argmax(dim=1), test_pred)
size_kb = weights_path.stat().st_size / 1024
print(f"saved {weights_path.name} ({size_kb:.0f} KB); reload reproduces predictions: {same}")

pd.DataFrame({"epoch": range(1, len(mlp_history["train"]) + 1),
              "mlp_train": mlp_history["train"], "mlp_validation": mlp_history["validation"],
              "cnn_train": cnn_history["train"], "cnn_validation": cnn_history["validation"]}).round(4).to_csv(
    RESULTS / "training_curves.csv", index=False)
pd.Series(test_scores, name="official_test_accuracy").rename_axis("model").round(4).to_csv(RESULTS / "metrics.csv")
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# Your work here

curves = {}
for epochs in [5, 40]:
    torch.manual_seed(42)
    net = make_cnn().to(DEVICE)
    curves[epochs] = train_classifier(net, X_fit, y_fit, X_val, y_val, epochs=epochs)
    print(f"{epochs:2d} epochs: validation accuracy = {curves[epochs]['validation'][-1]:.4f}, "
          f"test accuracy = {accuracy(net, X_test, y_test):.4f}")

plt.figure(figsize=(6, 3.6))
for epochs, h in curves.items():
    plt.plot(range(1, epochs + 1), h["train"], linestyle="--", label=f"training ({epochs} epochs)")
    plt.plot(range(1, epochs + 1), h["validation"], marker=".", label=f"validation ({epochs} epochs)")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.title("Where does the validation curve stop improving?")
plt.legend(fontsize=8)
plt.tight_layout()
plt.savefig(RESULTS / "cnn_5_vs_40_epochs.png", dpi=160, bbox_inches="tight")
plt.show()

def make_one_block_cnn():
    return nn.Sequential(
        nn.Conv2d(1, 16, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),   # 16 x 4 x 4
        nn.Flatten(),                                                             # 256
        nn.Linear(16 * 4 * 4, 64), nn.ReLU(), nn.Dropout(0.2),
        nn.Linear(64, 10),
    )

torch.manual_seed(42)
one_block = make_one_block_cnn().to(DEVICE)
train_classifier(one_block, X_fit, y_fit, X_val, y_val)
print("one-block CNN: weights =", sum(p.numel() for p in one_block.parameters()),
      " test accuracy =", round(accuracy(one_block, X_test, y_test), 4))
print("two-block CNN: weights =", sum(p.numel() for p in cnn.parameters()),
      " test accuracy =", round(test_scores["CNN"], 4))

