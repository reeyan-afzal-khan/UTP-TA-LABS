"""Training a deep network: the worked numbers of Chapter 28.

One small table, 7,043 telephone customers and whether they left, is used to train networks the
right way and the wrong way: with activations that pass their gradient back and ones that do not,
with a sensible start and a constant one, with four optimizers, four learning rates, and three ways
of stopping a large network from memorizing. The last section asks whether any of it beats a
logistic regression.

Run from the course folder:      python all_experiments/book_checks/demo_deep_training.py
It reads all_datasets/supervised/telco_customer_churn/ and takes about a minute on a laptop CPU.
Network results move a little between computers and PyTorch versions, so their checks allow for it.
"""
import os
from pathlib import Path

os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")       # as in Labs 7 and 8, for some Windows installs
import numpy as np
import pandas as pd
import torch
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from torch import nn

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
torch.set_num_threads(4)


def customers():
    """Fill and scale the numbers, one-hot encode the rest; 60% to train, 20% to validate, 20% to test."""
    churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
    churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)    # Lab 1's repair
    y = (churn["Churn"] == "Yes").astype(int).to_numpy()
    X = churn.drop(columns=["customerID", "Churn"])
    numbers = ["tenure", "MonthlyCharges", "TotalCharges", "SeniorCitizen"]
    texts = [column for column in X.columns if column not in numbers]
    X_train, X_rest, y_train, y_rest = train_test_split(X, y, test_size=0.4, random_state=42, stratify=y)
    X_valid, X_test, y_valid, y_test = train_test_split(X_rest, y_rest, test_size=0.5, random_state=42, stratify=y_rest)
    prepare = ColumnTransformer([("num", StandardScaler(), numbers),
                                 ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), texts)])
    tensors = {
        "train": (torch.tensor(prepare.fit_transform(X_train), dtype=torch.float32), y_train),
        "valid": (torch.tensor(prepare.transform(X_valid), dtype=torch.float32), y_valid),
        "test": (torch.tensor(prepare.transform(X_test), dtype=torch.float32), y_test),
    }
    return tensors, prepare


TENSORS, PREPARE = customers()
LOSS = nn.BCEWithLogitsLoss()


def network(widths, activation=nn.ReLU, dropout=0.0, batch_norm=False):
    """A stack of dense layers, one unit out: the network's score, which a sigmoid turns into a chance."""
    layers, size = [], TENSORS["train"][0].shape[1]
    for width in widths:
        layers.append(nn.Linear(size, width))
        if batch_norm:
            layers.append(nn.BatchNorm1d(width))
        layers.append(activation())
        if dropout:
            layers.append(nn.Dropout(dropout))
        size = width
    layers.append(nn.Linear(size, 1))
    return nn.Sequential(*layers)


def scores(model, part):
    """Loss and ROC AUC of a model on one part of the data."""
    X, y = TENSORS[part]
    model.eval()
    with torch.no_grad():
        logits = model(X).squeeze(1)
    return LOSS(logits, torch.tensor(y, dtype=torch.float32)).item(), roc_auc_score(y, logits.numpy())


def fit(model, optimizer, epochs, batch_size=64, seed=0, keep_best=False):
    """Mini-batch training. Records the training loss, validation loss and validation AUC after every epoch.

    With keep_best, the weights of the epoch with the lowest validation loss are put back at the end."""
    X, y = TENSORS["train"]
    target = torch.tensor(y, dtype=torch.float32)
    order_maker = torch.Generator().manual_seed(seed)
    history, best, best_weights = [], np.inf, None
    for _ in range(epochs):
        model.train()
        order = torch.randperm(len(X), generator=order_maker)
        for start in range(0, len(order) - batch_size + 1, batch_size):        # full batches only
            batch = order[start:start + batch_size]
            optimizer.zero_grad()
            LOSS(model(X[batch]).squeeze(1), target[batch]).backward()
            optimizer.step()
        history.append((scores(model, "train")[0], *scores(model, "valid")))
        if keep_best and history[-1][1] < best:
            best = history[-1][1]
            best_weights = {name: value.clone() for name, value in model.state_dict().items()}
    if keep_best:
        model.load_state_dict(best_weights)
    return pd.DataFrame(history, columns=["train_loss", "valid_loss", "valid_auc"], index=range(1, epochs + 1))


def activations():
    z = torch.tensor([-4.0, -1.0, 0.0, 1.0, 4.0], requires_grad=True)
    table = {}
    for name, function in [("sigmoid", torch.sigmoid), ("tanh", torch.tanh), ("relu", torch.relu)]:
        z.grad = None
        out = function(z)
        out.sum().backward()
        table[name] = ([round(float(v), 3) for v in out.detach()], [round(float(v), 3) for v in z.grad])
        print(f"{name:8s} at -4, -1, 0, 1, 4: {table[name][0]}   slope: {table[name][1]}")
    FOUND["activations"] = table
    # Softmax turns three class scores into three chances; cross-entropy charges -ln(chance of the true class).
    chances = torch.softmax(torch.tensor([2.0, 1.0, 0.1]), dim=0)
    FOUND["softmax"] = [round(float(p), 3) for p in chances]
    FOUND["cross_entropy"] = {p: round(-float(np.log(p)), 3) for p in (0.9, 0.5, 0.1)}
    print("softmax of scores 2, 1, 0.1:", FOUND["softmax"], "  -ln(chance of the true class):", FOUND["cross_entropy"])


def vanishing():
    """Ten hidden layers of 32 units: how big is each layer's gradient at the start, and does the network learn?"""
    X, y = TENSORS["train"]
    target = torch.tensor(y, dtype=torch.float32)
    FOUND["gradients"], FOUND["deep"] = {}, {}
    for name, activation, norm in [("sigmoid", nn.Sigmoid, False), ("relu", nn.ReLU, False),
                                   ("sigmoid with batch norm", nn.Sigmoid, True)]:
        torch.manual_seed(42)
        model = network([32] * 10, activation, batch_norm=norm)
        model.train()
        LOSS(model(X).squeeze(1), target).backward()
        sizes = [layer.weight.grad.norm().item() for layer in model if isinstance(layer, nn.Linear)]
        FOUND["gradients"][name] = sizes
        print(f"\n{name}: gradient size, first hidden layer to output layer:", [f"{s:.1e}" for s in sizes])
        print("    as powers of ten:", [round(float(np.log10(s)), 2) for s in sizes],
              f"  output layer / first layer: {sizes[-1] / sizes[0]:.3g}"
              f"  average shrink per layer: {(sizes[-1] / sizes[0]) ** (1 / 10):.2f}")
        torch.manual_seed(42)
        model = network([32] * 10, activation, batch_norm=norm)
        history = fit(model, torch.optim.Adam(model.parameters(), lr=1e-3), epochs=20)
        FOUND["deep"][name] = history.loc[[1, 5, 20]]
        print(history.loc[[1, 5, 20]].round(3).to_string())
    base_rate = y.mean()
    FOUND["base_loss"] = -(base_rate * np.log(base_rate) + (1 - base_rate) * np.log(1 - base_rate))
    print(f"loss of predicting the share of leavers, {base_rate:.3f}, for everyone: {FOUND['base_loss']:.3f}")


def constant_start():
    """Every weight starts at 0.1: all units of a layer get the same gradient and stay copies of each other."""
    torch.manual_seed(42)
    model = network([32, 32])
    with torch.no_grad():
        for layer in model:
            if isinstance(layer, nn.Linear):
                layer.weight.fill_(0.1)
                layer.bias.fill_(0.0)
    history = fit(model, torch.optim.Adam(model.parameters(), lr=1e-3), epochs=20)
    distinct = len(torch.unique(model[0].weight.detach().round(decimals=5), dim=0))
    FOUND["constant"] = (distinct, round(history["valid_auc"].iloc[-1], 3))
    print(f"\nconstant start: {distinct} different units out of 32 after training; valid AUC {FOUND['constant'][1]}")


def optimizers():
    makers = {"SGD": lambda p: torch.optim.SGD(p, lr=0.01),
              "SGD with momentum": lambda p: torch.optim.SGD(p, lr=0.01, momentum=0.9),
              "RMSprop": lambda p: torch.optim.RMSprop(p, lr=1e-3),
              "Adam": lambda p: torch.optim.Adam(p, lr=1e-3)}
    FOUND["optimizers"] = {}
    print("\nfour optimizers, two hidden layers of 64, 30 epochs:")
    for name, make in makers.items():
        torch.manual_seed(42)
        model = network([64, 64])
        history = fit(model, make(model.parameters()), epochs=30)
        FOUND["optimizers"][name] = history
        print(f"{name:18s} training loss after 1, 5, 30 epochs {history['train_loss'].loc[[1, 5, 30]].round(3).tolist()}"
              f"   valid AUC {history['valid_auc'].loc[[1, 5, 30]].round(3).tolist()}")


def learning_rates():
    FOUND["rates"] = {}
    print("\nAdam with four learning rates:")
    for rate in (1e-4, 1e-3, 1e-2, 1e-1):
        torch.manual_seed(42)
        model = network([64, 64])
        history = fit(model, torch.optim.Adam(model.parameters(), lr=rate), epochs=30)
        FOUND["rates"][rate] = history
        print(f"learning rate {rate:<6} training loss after 1, 5, 30 epochs {history['train_loss'].loc[[1, 5, 30]].round(3).tolist()}"
              f"   valid loss {history['valid_loss'].loc[[1, 5, 30]].round(3).tolist()}")


def regularization():
    """A network with far more weights than the table needs, left alone and held back three ways."""
    variants = {"no brake": ({}, lambda p: torch.optim.Adam(p, lr=1e-3), False),
                "dropout 0.5": ({"dropout": 0.5}, lambda p: torch.optim.Adam(p, lr=1e-3), False),
                "weight decay 1.0": ({}, lambda p: torch.optim.AdamW(p, lr=1e-3, weight_decay=1.0), False),
                "early stopping": ({}, lambda p: torch.optim.Adam(p, lr=1e-3), True)}
    FOUND["regularization"] = {}
    print("\ntwo hidden layers of 256, 60 epochs:")
    for name, (options, make, keep_best) in variants.items():
        torch.manual_seed(42)
        model = network([256, 256], **options)
        history = fit(model, make(model.parameters()), epochs=60, keep_best=keep_best)
        best = int(history["valid_loss"].idxmin())
        kept = scores(model, "valid")
        FOUND["regularization"][name] = (history, best, kept, model)
        print(f"{name:17s} training loss at 60: {history['train_loss'].iloc[-1]:.3f}   lowest valid loss"
              f" {history['valid_loss'].min():.3f} at epoch {best}; model kept: valid loss {kept[0]:.3f}, AUC {kept[1]:.3f}")
    weights = sum(p.numel() for p in network([256, 256]).parameters())
    FOUND["wide_weights"] = (weights, len(TENSORS["train"][1]))
    print(f"weights in that network: {weights:,}, for {len(TENSORS['train'][1]):,} training customers")


def against_simpler_models():
    """The test customers, opened once: the early-stopped network against two models that need no tuning of this kind."""
    X_train, y_train = TENSORS["train"]
    X_test, y_test = TENSORS["test"]
    logistic = LogisticRegression(max_iter=2000).fit(X_train.numpy(), y_train)
    boosting = HistGradientBoostingClassifier(random_state=42).fit(X_train.numpy(), y_train)
    network_model = FOUND["regularization"]["early stopping"][3]
    FOUND["test"] = {"logistic regression": roc_auc_score(y_test, logistic.predict_proba(X_test.numpy())[:, 1]),
                     "gradient boosting": roc_auc_score(y_test, boosting.predict_proba(X_test.numpy())[:, 1]),
                     "network, early stopping": scores(network_model, "test")[1]}
    print("\ntest ROC AUC:", {name: round(value, 3) for name, value in FOUND["test"].items()})


def main():
    X_train, y_train = TENSORS["train"]
    print(f"{len(y_train):,} training, {len(TENSORS['valid'][1]):,} validation and {len(TENSORS['test'][1]):,} test customers;"
          f" {X_train.shape[1]} columns after encoding; {y_train.mean():.1%} left\n")
    activations()
    vanishing()
    constant_start()
    optimizers()
    learning_rates()
    regularization()
    against_simpler_models()
    if not CHECK_BOOK_NUMBERS:
        return
    f = FOUND

    def near(value, book, tolerance=0.02):
        assert abs(value - book) <= tolerance, f"got {value}, the book says {book}"

    assert f["activations"]["sigmoid"] == ([0.018, 0.269, 0.5, 0.731, 0.982], [0.018, 0.197, 0.25, 0.197, 0.018])
    assert f["activations"]["tanh"] == ([-0.999, -0.762, 0.0, 0.762, 0.999], [0.001, 0.42, 1.0, 0.42, 0.001])
    assert f["activations"]["relu"] == ([0.0, 0.0, 0.0, 1.0, 4.0], [0.0, 0.0, 0.0, 1.0, 1.0])
    assert f["softmax"] == [0.659, 0.242, 0.099] and f["cross_entropy"] == {0.9: 0.105, 0.5: 0.693, 0.1: 2.303}
    sigmoid, relu, normed = f["gradients"]["sigmoid"], f["gradients"]["relu"], f["gradients"]["sigmoid with batch norm"]
    assert sigmoid[0] < 1e-7 * sigmoid[-1] and relu[0] > 1e-4 * relu[-1] and normed[0] > 0.05 * normed[-1]
    # The ratios the chapter quotes; they come from a fixed seed, so they repeat on one computer.
    assert 3.0e8 < sigmoid[-1] / sigmoid[0] < 4.5e8 and 400 < relu[-1] / relu[0] < 750 and 3 < normed[-1] / normed[0] < 8
    near(f["base_loss"], 0.579, 0.001)
    deep = f["deep"]
    assert abs(deep["sigmoid"]["train_loss"].loc[20] - f["base_loss"]) < 0.003          # stuck at the base rate
    near(deep["relu"]["train_loss"].loc[20], 0.386)
    near(deep["sigmoid with batch norm"]["valid_auc"].loc[1], 0.847)
    assert f["constant"][0] == 1
    near(f["constant"][1], 0.829)
    opt = {name: history for name, history in f["optimizers"].items()}
    near(opt["SGD"]["valid_auc"].loc[1], 0.703, 0.04)
    near(opt["SGD with momentum"]["valid_auc"].loc[1], 0.84)
    assert opt["SGD"]["train_loss"].loc[1] > opt["SGD with momentum"]["train_loss"].loc[1] > opt["Adam"]["train_loss"].loc[1] - 0.02
    assert opt["Adam"]["valid_auc"].loc[30] < opt["Adam"]["valid_auc"].loc[5]                # Adam overfits by epoch 30
    rates = f["rates"]
    near(rates[1e-4]["train_loss"].loc[1], 0.617)
    near(rates[1e-2]["train_loss"].loc[30], 0.31)
    near(rates[1e-2]["valid_loss"].loc[30], 0.551, 0.04)
    assert rates[1e-1]["train_loss"].loc[30] > rates[1e-3]["train_loss"].loc[30]
    reg = f["regularization"]
    near(reg["no brake"][0]["train_loss"].iloc[-1], 0.108)
    near(reg["no brake"][2][0], 1.043, 0.1)
    near(reg["dropout 0.5"][2][0], 0.475, 0.03)
    near(reg["dropout 0.5"][0]["train_loss"].iloc[-1], 0.280)
    near(reg["weight decay 1.0"][0]["train_loss"].iloc[-1], 0.305)
    near(reg["weight decay 1.0"][2][1], 0.821)
    near(reg["dropout 0.5"][2][1], 0.831)
    near(reg["weight decay 1.0"][2][0], 0.458, 0.03)
    near(reg["early stopping"][2][0], 0.402, 0.01)
    assert reg["early stopping"][1] == 3 and reg["dropout 0.5"][1] == 9
    assert f["wide_weights"] == (77825, 4225)
    near(f["test"]["logistic regression"], 0.833, 0.001)
    near(f["test"]["gradient boosting"], 0.816, 0.001)
    near(f["test"]["network, early stopping"], 0.832, 0.01)
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
