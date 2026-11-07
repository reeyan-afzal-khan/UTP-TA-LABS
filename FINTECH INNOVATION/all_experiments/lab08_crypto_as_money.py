# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab08"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Generate comparable daily teaching series
import numpy as np
import pandas as pd
rng = np.random.default_rng(42)
dates = pd.date_range("2024-01-01", periods=366, freq="D")
px = pd.DataFrame(index=dates)
for label, daily_sd in [("high_volatility", .035), ("medium_volatility", .012),
                         ("low_volatility", .004)]:
    increments = rng.normal(0, daily_sd, len(dates) - 1)
    px[label] = 100 * np.exp(np.r_[0, increments.cumsum()])
px.index.name = "date"; px.to_csv(OUT / "synthetic_prices.csv")
assert (px > 0).all().all() and px.index.is_unique

# %% Measure volatility on the same observation frequency
returns = np.log(px / px.shift(1)).dropna()
annualised = returns.std(ddof=1) * np.sqrt(365)
print("Synthetic annualised volatility:"); print(annualised.round(4))
# The 365 factor is appropriate here because all three fixtures have daily observations.
# For actual exchange-traded data, state the calendar and align observations explicitly.

# %% Measure path-dependent drawdown and recovery
drawdowns = px / px.cummax() - 1
worst = drawdowns.min()
recovery = 1 / (1 + worst) - 1
summary = pd.DataFrame({"annualised_volatility": annualised,
                        "max_drawdown": worst, "gain_to_recover": recovery})
print(summary.round(4)); summary.to_csv(OUT / "risk_summary.csv")
assert (worst <= 0).all() and (recovery >= 0).all()

# %% Compare explicit payment assumptions
purchase = 20
for fee in [.15, 1.20, 8.50]:
    print(f"Assumed fee {fee:.2f}: {fee / purchase:.1%} of purchase")
print("Six blocks at an assumed ten-minute mean: 60 minutes expected, not guaranteed")
print("These fixtures cannot establish the performance of any actual asset.")
