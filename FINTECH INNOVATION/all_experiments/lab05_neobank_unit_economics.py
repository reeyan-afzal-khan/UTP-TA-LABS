# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab05"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Define and validate unit economics
def unit_economics(cac, arpu, cost, churn):
    if cac <= 0 or arpu < 0 or cost < 0 or not 0 < churn <= 1:
        raise ValueError("Require CAC > 0, non-negative revenue/cost, and 0 < churn <= 1")
    contribution = arpu - cost
    return dict(contribution=contribution,
        payback=cac / contribution if contribution > 0 else None,
        ltv=contribution / churn, ltv_cac=contribution / churn / cac)

base = dict(cac=45, arpu=4.20, cost=1.80, churn=.03)
print(unit_economics(**base))
assert abs(unit_economics(**base)["payback"] - 18.75) < 1e-9
# LTV assumes constant margin and churn, no discounting and no fixed costs.

# %% Project the customer stock and cumulative cash
def project(months, new_per_month, stop_after=None, **assumptions):
    unit_economics(**assumptions)  # validate assumptions before the loop
    customers, cash, records = 0.0, 0.0, []
    for month in range(1, months + 1):
        acquired = new_per_month if stop_after is None or month <= stop_after else 0
        customers = customers * (1 - assumptions["churn"]) + acquired
        margin = customers * (assumptions["arpu"] - assumptions["cost"])
        cash += margin - acquired * assumptions["cac"]
        records.append((month, customers, cash))
    return records

# New customers earn one full month of contribution; existing customers churn first.
for label, rate, stop in [("fast", 50000, None), ("slow", 5000, None),
                          ("stop_after_24", 50000, 24)]:
    records = project(60, rate, stop, **base)
    with (OUT / (label + ".csv")).open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f); writer.writerow(["month", "customers", "cash"])
        writer.writerows(records)
    breakeven = next((m for m, n, cash in records if cash >= 0), None)
    print(label, "month 60:", tuple(round(v, 2) for v in records[-1]), "break-even:", breakeven)

# %% Change one assumption at a time
for key in base:
    for factor in [.8, 1.2]:
        trial = dict(base); trial[key] *= factor
        print(key, factor, "LTV/CAC", round(unit_economics(**trial)["ltv_cac"], 3))
