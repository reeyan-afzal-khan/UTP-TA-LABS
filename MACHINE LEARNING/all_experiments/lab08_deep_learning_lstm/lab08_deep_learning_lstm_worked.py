"""Lab 08: Deep learning II: an LSTM for time series.

The code cells of lab08_deep_learning_lstm_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab08_deep_learning_lstm/lab08_deep_learning_lstm_worked.py
It writes the same figures and tables as the notebook, to results/lab08/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab, start_pytorch

# 2. PyTorch: installed once if missing; then the device to train on (a GPU if PyTorch can see one, else the CPU).
DEVICE = start_pytorch()
import torch
from torch import nn

# 3. The other libraries this lab uses.
import copy                                  # to keep a copy of the best weights while training
import json
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# 4. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab08")

# %% Question 2 - Read the meters and add them up
# One row per hour, one column per customer, in kWh. hour_start becomes the row index.
loads = pd.read_csv(DATA / "advanced/electricity_load/electricity_load_hourly.zip",
                    parse_dates=["hour_start"], index_col="hour_start")
print("hours:", len(loads), " customers:", loads.shape[1], " first hour:", loads.index[0], " last hour:", loads.index[-1])

demand = loads.sum(axis=1) / 1000          # add up the customers, kWh -> MWh: what the supplier must buy each hour
print(f"demand per hour: mean {demand.mean():.1f} MWh")
print(f"lowest hour: {demand.min():.1f} MWh at {demand.idxmin()}; highest: {demand.max():.1f} MWh at {demand.idxmax()}")

fig, axes = plt.subplots(1, 2, figsize=(11, 3.4), gridspec_kw={"width_ratios": [2, 1]})
axes[0].plot(demand["2014-01-06":"2014-01-19"].to_numpy())         # two weeks, Monday to Sunday
axes[0].set_xlabel("Hour, from Monday 6 January 2014")
axes[0].set_ylabel("MWh")
axes[0].set_title("Two weeks of demand")
# The average day: mean demand at each hour of the day, for weekdays and for weekends.
weekend = demand.index.dayofweek >= 5
axes[1].plot(demand[~weekend].groupby(demand.index[~weekend].hour).mean(), label="Monday to Friday")
axes[1].plot(demand[weekend].groupby(demand.index[weekend].hour).mean(), label="weekend")
axes[1].set_xlabel("Hour of day")
axes[1].set_title("The average day")
axes[1].legend()
plt.tight_layout()
plt.savefig(RESULTS / "two_weeks_and_the_average_day.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 3 - Split by date and scale
# Label every hour with its period: three years to train, then two half-years.
period = pd.Series("train", index=demand.index)
period[demand.index >= "2014-01-01"] = "validation"
period[demand.index >= "2014-07-01"] = "test"
for name in ["train", "validation", "test"]:
    hours = demand.index[period == name]
    print(f"{name:10s} {len(hours):6d} hours, {hours[0]:%d %b %Y} to {hours[-1]:%d %b %Y}")

# Scale by the highest training hour, so the network sees numbers near [0, 1]. A training statistic only.
scale = float(demand[period == "train"].max())
scaled = (demand / scale).to_numpy(dtype=np.float32)
print(f"scale: {scale:.1f} MWh, the highest training hour")

# %% Question 4 - Build the windows
LOOKBACK = 24

def make_windows(values, lookback):
    """Row r holds the `lookback` values before hour t = lookback + r; its label is the value at hour t."""
    hours = np.arange(lookback, len(values))
    windows = np.stack([values[t - lookback:t] for t in hours])
    return windows, values[hours], hours

def split_by_period(X, y, hours):
    """Tensors for the train, validation and test periods; a row belongs to the period of the hour it predicts.
    Each window gets a last dimension of size 1: one value per step."""
    of_row = period.to_numpy()[hours]
    splits = []
    for p in ["train", "validation", "test"]:
        X_p = torch.tensor(X[of_row == p]).unsqueeze(-1).to(DEVICE)       # (rows, steps, 1)
        y_p = torch.tensor(y[of_row == p]).to(DEVICE)
        splits.append((X_p, y_p))
    return splits

windows, targets, target_hours = make_windows(scaled, LOOKBACK)
(X_train, y_train), (X_valid, y_valid), (X_test, y_test) = split_by_period(windows, targets, target_hours)
print("windows:", windows.shape, " train:", tuple(X_train.shape), " validation:", tuple(X_valid.shape),
      " test:", tuple(X_test.shape))
print("first window (MWh):", np.round(windows[0, :6] * scale, 1), "...")
print("its label, the next hour:", round(float(targets[0] * scale), 1), "MWh at", demand.index[target_hours[0]])

# %% Question 5 - Compute three free forecasts
def mae(forecast, name):
    """Mean absolute error in MWh over the hours of one period."""
    hours = period == name
    return float((demand[hours] - forecast[hours]).abs().mean())

# Each free forecast is the demand series shifted: by 1 hour, by 24 hours, by 168 hours.
free = {"last hour": demand.shift(1), "same hour yesterday": demand.shift(24), "same hour last week": demand.shift(168)}
baselines = {name: mae(forecast, "validation") for name, forecast in free.items()}
for name, value in baselines.items():
    print(f"{name:20s} validation MAE = {value:.2f} MWh")

# %% Question 6 - Build and train the LSTM
class LSTMForecaster(nn.Module):
    """An LSTM reads the window one step at a time; a linear layer turns its final state into one forecast."""

    def __init__(self, hidden_size=32, input_size=1):
        super().__init__()
        self.lstm = nn.LSTM(input_size=input_size, hidden_size=hidden_size, batch_first=True)
        self.head = nn.Linear(hidden_size, 1)

    def forward(self, x):
        states, _ = self.lstm(x)                          # (rows, steps, hidden_size): the state after each step
        return self.head(states[:, -1, :]).squeeze(-1)    # the final state predicts the next hour

def validation_mae(model, X, y):
    """Mean absolute error in MWh (the model works in scaled units, so multiply back by the scale)."""
    model.eval()
    with torch.no_grad():
        return (model(X) - y).abs().mean().item() * scale

def train_forecaster(model, X, y, X_v, y_v, epochs=12, lr=3e-3, batch_size=64, verbose=True):
    """Train with mean squared error; keep the weights of the epoch with the lowest validation MAE."""
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    loss_fn = nn.MSELoss()
    history, best_weights = [], None
    for epoch in range(epochs):
        model.train()
        order = torch.randperm(len(X))                    # a new shuffle every epoch
        for start in range(0, len(X), batch_size):
            batch = order[start:start + batch_size]
            optimizer.zero_grad()
            loss_fn(model(X[batch]), y[batch]).backward()
            optimizer.step()
        history.append(validation_mae(model, X_v, y_v))
        if history[-1] == min(history):                   # the best epoch so far: keep a copy of its weights
            best_weights = copy.deepcopy(model.state_dict())
        if verbose:
            print(f"epoch {epoch + 1:2d}: validation MAE = {history[-1]:.2f} MWh")
    model.load_state_dict(best_weights)                   # early stopping: the best epoch, not the last
    return history

torch.manual_seed(42)
model = LSTMForecaster().to(DEVICE)
print("trainable weights:", sum(p.numel() for p in model.parameters()))
history = train_forecaster(model, X_train, y_train, X_valid, y_valid)
best_epoch = int(np.argmin(history)) + 1
print(f"kept epoch {best_epoch}: validation MAE = {min(history):.2f} MWh")

# %% Question 7 - Read the validation curve
plt.figure(figsize=(6, 3.6))
plt.plot(range(1, len(history) + 1), history, marker="o", color="black", label="LSTM")
line_colors = {"last hour": "C1", "same hour yesterday": "C2", "same hour last week": "C3"}
for name, value in baselines.items():
    plt.axhline(value, linestyle="--", label=name, color=line_colors[name])
plt.xlabel("Epoch")
plt.ylabel("Validation MAE (MWh)")
plt.title("The LSTM has to beat three free forecasts")
plt.legend(fontsize=8)
plt.tight_layout()
plt.savefig(RESULTS / "the_lstm_has_to_beat_three_free_forecasts.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 8 - Open the test period once
# The LSTM's forecasts for every test hour, in MWh, as a series indexed by hour.
model.eval()
with torch.no_grad():
    lstm_test = pd.Series(model(X_test).cpu().numpy() * scale, index=demand.index[period == "test"])

test_scores = {name: mae(forecast, "test") for name, forecast in free.items()}
test_scores["LSTM"] = mae(lstm_test.reindex(demand.index), "test")
mean_test = demand[period == "test"].mean()
for name, value in test_scores.items():
    print(f"{name:20s} test MAE = {value:.2f} MWh ({100 * value / mean_test:.1f}% of the average hour)")

# %% Question 9 - Find the hours it gets wrong
actual = demand[period == "test"]
errors = (lstm_test - actual).rename("error")
print("largest LSTM errors in the test period (MWh):")
print(errors.abs().sort_values(ascending=False).head(6).round(1).to_string())

week = slice("2014-07-07", "2014-07-13")                     # the first full test week, Monday to Sunday
by_hour = errors.abs().groupby(errors.index.hour).mean()     # the mean miss at each hour of the day

fig, axes = plt.subplots(1, 2, figsize=(11, 3.6), gridspec_kw={"width_ratios": [2, 1]})
axes[0].plot(actual[week].to_numpy(), label="actual")
axes[0].plot(lstm_test[week].to_numpy(), label="LSTM forecast")
axes[0].plot(free["same hour yesterday"][week].to_numpy(), label="same hour yesterday", alpha=0.6)
axes[0].set_xlabel("Hour, from Monday 7 July 2014")
axes[0].set_ylabel("MWh")
axes[0].set_title("One-hour-ahead forecasts")
axes[0].legend(fontsize=8)
axes[1].bar(by_hour.index, by_hour.to_numpy())
axes[1].set_xlabel("Hour of day")
axes[1].set_ylabel("Test MAE (MWh)")
axes[1].set_title("Where the LSTM misses")
plt.tight_layout()
plt.savefig(RESULTS / "one_hour_ahead_forecasts_and_errors.png", dpi=160, bbox_inches="tight")
plt.show()
print("hours of day with the largest MAE:", by_hour.sort_values(ascending=False).head(3).round(2).to_dict())

# %% Question 10 - Save the weights and the scale
# The weights go to one file; the card records everything needed to use them, the scale above all.
weights_path = MODELS / "electricity_lstm.pt"
torch.save(model.state_dict(), weights_path)
card = {
    "task": "forecast next-hour total electricity demand (MWh) of 158 Portuguese customers from the previous 24 hours",
    "input": f"tensor of shape (n, {LOOKBACK}, 1): the last {LOOKBACK} hourly totals in MWh divided by scale",
    "output": "next-hour demand divided by scale; multiply by scale for MWh",
    "scale": round(scale, 4),
    "architecture": "LSTMForecaster(hidden_size=32) in Lab 8",
    "training": {"period": "2011-01-01 to 2013-12-31", "max_epochs": 12, "kept_epoch": best_epoch,
                 "learning_rate": 3e-3, "batch_size": 64, "seed": 42},
    "validation_mae_mwh": round(min(history), 2),
    "test_mae_mwh": {name: round(value, 2) for name, value in test_scores.items()},
    "torch_version": torch.__version__,
    "trained_on": str(DEVICE),
}
(MODELS / "electricity_lstm_card.json").write_text(json.dumps(card, indent=2))

# Rebuild the network, load the weights, check it forecasts exactly as before, then forecast the next hour.
restored = LSTMForecaster().to(DEVICE)
restored.load_state_dict(torch.load(weights_path, map_location=DEVICE, weights_only=True))
last_day = torch.tensor(scaled[-LOOKBACK:]).reshape(1, LOOKBACK, 1).to(DEVICE)      # the last 24 hours of 2014
restored.eval()
with torch.no_grad():
    same = torch.equal(restored(X_test), model(X_test))
    next_hour = restored(last_day).item() * card["scale"]
print(f"saved {weights_path.name}; reload reproduces the test forecasts: {same}")
print(f"forecast for {demand.index[-1] + pd.Timedelta(hours=1)}: {next_hour:.1f} MWh")

# %% Question 11 - Save the evidence
pd.DataFrame({"epoch": range(1, len(history) + 1), "validation_mae_mwh": history}).round(3).to_csv(
    RESULTS / "validation_curve.csv", index=False)
metrics = pd.DataFrame([
    {"model": name, "validation_mae_mwh": baselines.get(name, min(history)), "test_mae_mwh": value}
    for name, value in test_scores.items()
])
metrics.round(3).to_csv(RESULTS / "metrics.csv", index=False)
first_week = pd.DataFrame({"actual_mwh": actual[week], "lstm_forecast_mwh": lstm_test[week],
                           "same_hour_yesterday_mwh": free["same hour yesterday"][week]})
first_week.round(2).to_csv(RESULTS / "first_test_week.csv")
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 12 - Try it yourself
# Your work here

# %% Question 13 - One solution
def try_setting(lookback, hidden_size):
    """Train one LSTM exactly like Question 6; return its best validation MAE and its number of weights."""
    (X_t, y_t), (X_v, y_v), _ = split_by_period(*make_windows(scaled, lookback))
    torch.manual_seed(42)
    candidate = LSTMForecaster(hidden_size=hidden_size).to(DEVICE)
    curve = train_forecaster(candidate, X_t, y_t, X_v, y_v, verbose=False)
    return min(curve), sum(p.numel() for p in candidate.parameters())

for lookback, hidden_size in [(6, 32), (48, 32), (24, 64)]:
    best_mae, n_weights = try_setting(lookback, hidden_size)
    print(f"lookback = {lookback:2d} hours, hidden = {hidden_size}: validation MAE = {best_mae:.2f} MWh, "
          f"{n_weights} weights")
print(f"lookback = 24 hours, hidden = 32: validation MAE = {min(history):.2f} MWh (Question 6)")
