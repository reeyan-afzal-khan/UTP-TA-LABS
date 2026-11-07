# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab03"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Create loans with transparent grade assumptions
import numpy as np
import pandas as pd
rng = np.random.default_rng(42)
rows = []
for grade, coupon, pd_rate, recovery in [
    ("A", .055, .015, .30), ("B", .08, .04, .28),
    ("C", .11, .08, .25), ("D", .15, .14, .20), ("E", .20, .23, .15)]:
    for _ in range(1000):
        rows.append((len(rows), grade, coupon, rng.random() < pd_rate, recovery))
loans = pd.DataFrame(rows, columns=["loan_id", "grade", "interest_rate", "defaulted", "recovery_rate"])
loans.to_csv(OUT / "loans.csv", index=False)
assert loans.loan_id.is_unique

# %% Use one consistent cash-flow model
# One period, equal principal, fee on every loan; defaults receive recovery only.
fee = .01
loans["loss"] = loans.defaulted * (1 - loans.recovery_rate)
loans["net_return"] = np.where(loans.defaulted,
    loans.recovery_rate - 1, loans.interest_rate) - fee
summary = loans.groupby("grade").agg(n=("loan_id", "count"),
    default_rate=("defaulted", "mean"), expected_loss=("loss", "mean"),
    mean_net_return=("net_return", "mean"))
print(summary.round(4)); summary.to_csv(OUT / "grade_summary.csv")
# Mean(default * loss-given-default) handles differing recoveries correctly.

# %% Resample equal-weight portfolios
# Independent draws with replacement are an IID classroom assumption.
# This does not model correlated defaults or predict future market returns.
values = loans.net_return.to_numpy()
results = []
for size in [1, 5, 20, 100, 500]:
    outcomes = rng.choice(values, size=(10000, size), replace=True).mean(axis=1)
    results.append((size, outcomes.mean(), outcomes.std(ddof=1),
                    np.quantile(outcomes, .05), (outcomes < 0).mean()))
result = pd.DataFrame(results, columns=["loans", "mean", "sd", "p05", "p_loss"])
print(result.round(4)); result.to_csv(OUT / "portfolios.csv", index=False)
assert result.iloc[-1]["sd"] < result.iloc[0]["sd"]
