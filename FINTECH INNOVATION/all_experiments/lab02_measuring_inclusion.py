# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab02"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Generate a reproducible respondent fixture
import pandas as pd
rows = []
for person in range(600):
    gender = random.choice(["female", "male"])
    income = random.randint(1, 5)
    account = random.random() < 0.35 + 0.1 * income
    rows.append(dict(person_id=person, gender=gender, income_quintile=income,
        urban_rural=random.choice(["urban", "rural"]),
        education=random.choice(["primary", "secondary", "tertiary"]),
        has_account=account, transactions_90d=random.randint(0, 6) if account else 0,
        uses_credit=account and random.random() < .25,
        uses_savings=account and random.random() < .4,
        cost=random.random() < .5, distance=random.random() < .3,
        documentation=random.random() < .4, trust=random.random() < .2,
        no_credit_history=random.random() < .5,
        has_mobile_money=random.random() < .6,
        has_utility_account=random.random() < .4))
pd.DataFrame(rows).to_csv(OUT / "inclusion_sample.csv", index=False)
df = pd.read_csv(OUT / "inclusion_sample.csv")
assert df.person_id.is_unique and len(df) == 600

# %% Measure access and subgroup denominators
print(f"Sample account ownership: {df.has_account.mean():.1%}")
for dim in ["gender", "income_quintile", "urban_rural", "education"]:
    print(dim)
    print(df.groupby(dim).has_account.agg(["mean", "count"]).round(3))

# %% Define nested inclusion levels
df["access"] = df.has_account
df["active"] = df.access & (df.transactions_90d >= 3)
df["meaningful"] = df.active & (df.uses_credit | df.uses_savings)
rates = df[["access", "active", "meaningful"]].mean()
assert rates.access >= rates.active >= rates.meaningful
print(rates.round(3))
rates.to_csv(OUT / "inclusion_levels.csv", header=["sample_rate"])

# %% Rank barriers within the appropriate population
barriers = ["cost", "distance", "documentation", "trust", "no_credit_history"]
unbanked = df.loc[~df.has_account]
print("Unbanked denominator:", len(unbanked))
print(unbanked[barriers].mean().sort_values(ascending=False).round(3))
thin = df.loc[~df.uses_credit]
reachable = thin.has_mobile_money | thin.has_utility_account
print("Thin-file denominator:", len(thin))
print(f"Alternative-data reach: {reachable.mean():.1%}")
print("The sample design is synthetic; these are not national estimates.")
