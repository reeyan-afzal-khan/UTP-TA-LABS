"""Sequence models and attention: the worked numbers of Chapter 30.

Self-attention is worked by hand on three tiny tokens, with and without positions. Then five networks
forecast the next hour of electricity demand from the previous 24, as in Lab 8: a plain recurrent
network, an LSTM, a GRU, and a small attention model with and without positional encoding. Each is
trained from three random starts on 2013, stopped early on January to June 2014, and scored once on
July to December 2014. The script also asks which hours of the window each model's forecast depends on.

Run from the course folder:      python all_experiments/book_checks/demo_sequence.py
It reads all_datasets/advanced/electricity_load/ and takes about three minutes on a laptop CPU.
Network results move a little between computers and PyTorch versions, so their checks allow for it.
"""
import copy
import math
import os
from pathlib import Path

os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")
import numpy as np
import pandas as pd
import torch
from torch import nn

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
LOOKBACK = 24
torch.set_num_threads(4)


# ------------------------------------------------------------------ attention by hand
def attention(X, positions=None):
    """Self-attention with the identity as the query, key and value maps: softmax(X X^T / sqrt(d)) X."""
    if positions is not None:
        X = X + positions
    scores = X @ X.T / math.sqrt(X.shape[1])
    weights = torch.softmax(scores, dim=1)
    return scores, weights, weights @ X


def positional_encoding(length, size):
    """Sines and cosines of the position at a range of wavelengths, one pair of columns per wavelength."""
    position = torch.arange(length).unsqueeze(1)
    rate = torch.exp(torch.arange(0, size, 2) * (-math.log(10000.0) / size))
    table = torch.zeros(length, size)
    table[:, 0::2] = torch.sin(position * rate)
    table[:, 1::2] = torch.cos(position * rate)
    return table


def rounded(table):
    return [[round(float(value), 3) for value in row] for row in table]


def by_hand():
    tokens = torch.tensor([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
    scores, weights, out = attention(tokens)
    FOUND["scores"] = rounded(scores)
    FOUND["weights"] = rounded(weights)
    FOUND["outputs"] = rounded(out)
    print("scores:", FOUND["scores"])
    print("attention weights:", FOUND["weights"])
    print("outputs:", FOUND["outputs"])
    reordered = tokens[[2, 1, 0]]
    _, _, out_reordered = attention(reordered)
    FOUND["same_when_reordered"] = torch.allclose(out_reordered, out[[2, 1, 0]])
    print("reversing the tokens only reverses the outputs:", FOUND["same_when_reordered"])
    table = positional_encoding(3, 4)
    FOUND["positions"] = rounded(table)
    print("positional encoding, positions 0, 1, 2, size 4:", FOUND["positions"])
    with_positions = torch.cat([tokens, torch.zeros(3, 2)], dim=1)
    _, _, a = attention(with_positions, table)
    _, _, b = attention(with_positions[[2, 1, 0]], table)
    FOUND["differs_with_positions"] = not torch.allclose(b, a[[2, 1, 0]], atol=1e-4)
    print("with positions added, reversing the tokens changes what each one receives:", FOUND["differs_with_positions"])


# ------------------------------------------------------------------ electricity
def windows():
    """Lab 8's windows: 24 scaled hours in, the next hour out; train on 2013, validate on the first half of 2014."""
    loads = pd.read_csv(DATA / "advanced/electricity_load/electricity_load_hourly.zip", parse_dates=["hour_start"],
                        index_col="hour_start")
    demand = loads.sum(axis=1) / 1000
    scale = float(demand[demand.index < "2014-01-01"].max())
    values = (demand / scale).to_numpy(np.float32)
    hours = np.arange(LOOKBACK, len(values))
    X = np.stack([values[t - LOOKBACK:t] for t in hours])
    y = values[hours]
    when = demand.index[hours]
    parts = {"train": (when >= "2013-01-01") & (when < "2014-01-01"),
             "valid": (when >= "2014-01-01") & (when < "2014-07-01"),
             "test": when >= "2014-07-01"}
    tensors = {name: (torch.tensor(X[rows]).unsqueeze(-1), torch.tensor(y[rows])) for name, rows in parts.items()}
    baselines = {}
    for part in ("valid", "test"):
        rows = parts[part]
        truth = demand.to_numpy()[hours][rows]
        baselines[part] = {"last hour": float(np.abs(truth - demand.shift(1).to_numpy()[hours][rows]).mean()),
                           "same hour yesterday": float(np.abs(truth - demand.shift(24).to_numpy()[hours][rows]).mean())}
    return tensors, scale, baselines


TENSORS, SCALE, BASELINES = windows()


class Recurrent(nn.Module):
    """A recurrent layer reads the window step by step; its last state feeds one linear output."""

    def __init__(self, layer, hidden=32):
        super().__init__()
        self.rnn = layer(input_size=1, hidden_size=hidden, batch_first=True)
        self.head = nn.Linear(hidden, 1)

    def forward(self, x):
        states, _ = self.rnn(x)
        return self.head(states[:, -1]).squeeze(-1)


class Attention(nn.Module):
    """Each hour becomes a vector of 32; one transformer encoder layer lets every hour attend to every other."""

    def __init__(self, positions=True, size=32, heads=4):
        super().__init__()
        self.positions = positions
        self.embed = nn.Linear(1, size)
        self.register_buffer("table", positional_encoding(LOOKBACK, size))
        layer = nn.TransformerEncoderLayer(d_model=size, nhead=heads, dim_feedforward=64, dropout=0.0, batch_first=True)
        self.encoder = nn.TransformerEncoder(layer, num_layers=1, enable_nested_tensor=False)
        self.head = nn.Linear(size, 1)

    def forward(self, x):
        h = self.embed(x)
        if self.positions:
            h = h + self.table
        return self.head(self.encoder(h).mean(dim=1)).squeeze(-1)


MODELS = {"plain recurrent": lambda: Recurrent(nn.RNN), "LSTM": lambda: Recurrent(nn.LSTM),
          "GRU": lambda: Recurrent(nn.GRU), "attention with positions": lambda: Attention(True),
          "attention without positions": lambda: Attention(False)}


def mae(model, part):
    X, y = TENSORS[part]
    model.eval()
    with torch.no_grad():
        return (model(X) - y).abs().mean().item() * SCALE


def train(make, seed, epochs=12, lr=3e-3, batch_size=64):
    """Adam on the squared error; keep the weights of the epoch with the lowest validation MAE."""
    torch.manual_seed(seed)
    model = make()
    X, y = TENSORS["train"]
    order_maker = torch.Generator().manual_seed(seed)
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    curve, best = [], None
    for _ in range(epochs):
        model.train()
        order = torch.randperm(len(X), generator=order_maker)
        for start in range(0, len(order), batch_size):
            batch = order[start:start + batch_size]
            optimizer.zero_grad()
            nn.functional.mse_loss(model(X[batch]), y[batch]).backward()
            optimizer.step()
        curve.append(mae(model, "valid"))
        if curve[-1] == min(curve):
            best = copy.deepcopy(model.state_dict())
    model.load_state_dict(best)
    return model, curve


def sensitivity(model):
    """How much the forecast moves with each hour of the window, as shares that add up to one."""
    X = TENSORS["valid"][0][:2000].clone().requires_grad_(True)
    model.eval()
    model(X).sum().backward()
    share = X.grad.abs().mean(dim=0).squeeze(-1)
    share = share / share.sum()
    return share.numpy()


def electricity():
    sizes = {name: (len(TENSORS[name][1])) for name in ("train", "valid", "test")}
    FOUND["sizes"] = sizes
    FOUND["baselines"] = {part: {k: round(v, 2) for k, v in values.items()} for part, values in BASELINES.items()}
    print(f"\nwindows: {sizes}; scale {SCALE:.1f} MWh")
    print("free forecasts, MAE in MWh:", FOUND["baselines"])
    FOUND["models"] = {}
    for name, make in MODELS.items():
        valid, test, curves = [], [], []
        for seed in (0, 1, 2):
            model, curve = train(make, seed)
            valid.append(min(curve))
            test.append(mae(model, "test"))
            curves.append(curve)
            if seed == 0:
                weights = sum(p.numel() for p in model.parameters())
                first = model
        X, y = TENSORS["valid"]
        shuffled = X[:, torch.randperm(LOOKBACK, generator=torch.Generator().manual_seed(1))]
        first.eval()
        with torch.no_grad():
            scrambled = (first(shuffled) - y).abs().mean().item() * SCALE
        share = sensitivity(first)
        jumps = [float(np.mean(np.abs(np.diff(c)))) for c in curves]
        FOUND["models"][name] = {"weights": weights, "valid": valid, "test": test, "scrambled": scrambled,
                                 "last_hour_share": float(share[-1]), "yesterday_share": float(share[0]),
                                 "epoch_to_epoch": float(np.mean(jumps))}
        print(f"{name:28s} {weights:5d} weights   validation MAE {np.round(valid, 2).tolist()}   test MAE"
              f" {np.round(test, 2).tolist()}   hours scrambled {scrambled:.2f}   change per epoch {np.mean(jumps):.2f}")
        print(f"{'':28s} share of the forecast's sensitivity: last hour {share[-1]:.2f}, same hour yesterday"
              f" {share[0]:.2f}, the 22 hours between {share[1:-1].sum():.2f}")
    FOUND["means"] = {name: (round(float(np.mean(v["valid"])), 2), round(float(np.mean(v["test"])), 2))
                      for name, v in FOUND["models"].items()}
    print("mean over the three starts (validation, test):", FOUND["means"])


def main():
    by_hand()
    electricity()
    if not CHECK_BOOK_NUMBERS:
        return
    f = FOUND
    assert f["scores"] == [[0.707, 0.0, 0.707], [0.0, 0.707, 0.707], [0.707, 0.707, 1.414]]
    assert f["weights"] == [[0.401, 0.198, 0.401], [0.198, 0.401, 0.401], [0.248, 0.248, 0.503]]
    assert f["outputs"] == [[0.802, 0.599], [0.599, 0.802], [0.752, 0.752]]
    assert f["same_when_reordered"] and f["differs_with_positions"]
    assert f["positions"] == [[0.0, 1.0, 0.0, 1.0], [0.841, 0.54, 0.01, 1.0], [0.909, -0.416, 0.02, 1.0]]
    assert f["sizes"] == {"train": 8760, "valid": 4344, "test": 4416}
    assert f["baselines"]["valid"] == {"last hour": 5.77, "same hour yesterday": 3.07}
    assert f["baselines"]["test"] == {"last hour": 6.12, "same hour yesterday": 3.69}
    book = {"plain recurrent": (3.04, 3.35), "LSTM": (2.53, 2.84), "GRU": (2.97, 3.10),
            "attention with positions": (2.08, 2.44), "attention without positions": (21.71, 23.36)}
    for name, (valid, test) in book.items():
        assert abs(f["means"][name][0] - valid) < 0.3 and abs(f["means"][name][1] - test) < 0.3, (name, f["means"][name])
    near_valid = {"plain recurrent": [2.78, 3.76, 2.57], "LSTM": [2.5, 2.29, 2.8], "GRU": [3.16, 3.06, 2.69],
                  "attention with positions": [2.29, 2.04, 1.9]}
    for name, values in near_valid.items():
        assert all(abs(a - b) < 0.5 for a, b in zip(f["models"][name]["valid"], values)), (name, f["models"][name]["valid"])
    m = f["models"]
    assert {name: values["weights"] for name, values in m.items()} == {
        "plain recurrent": 1153, "LSTM": 4513, "GRU": 3393, "attention with positions": 8641,
        "attention without positions": 8641}
    # The patterns the chapter draws, which must hold whatever the exact numbers.
    mean = {name: float(np.mean(values["valid"])) for name, values in m.items()}
    assert mean["attention without positions"] > 4 * mean["LSTM"]
    assert mean["LSTM"] < mean["plain recurrent"] and mean["attention with positions"] < mean["GRU"]
    assert all(values["scrambled"] > 3 * mean[name] for name, values in m.items() if name != "attention without positions")
    assert abs(m["attention without positions"]["scrambled"] - np.mean(m["attention without positions"]["valid"])) < 4
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
