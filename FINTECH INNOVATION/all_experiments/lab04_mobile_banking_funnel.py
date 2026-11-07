# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab04"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Generate one ordered cohort
import pandas as pd
steps = ["app_open", "signup_start", "id_upload", "id_verified",
         "address_entered", "account_funded", "first_payment"]
probabilities = [.75, .85, .60, .93, .80, .90]
rows = []
for user in range(1000):
    device = random.choice(["older_phone", "newer_phone"])
    for index, step in enumerate(steps):
        if index and random.random() > probabilities[index - 1]:
            break
        rows.append((user, step, index, device))
events = pd.DataFrame(rows, columns=["user_id", "step", "sequence", "device"])
events.to_csv(OUT / "onboarding_events.csv", index=False)

# %% Validate sequence before counting conversion
assert not events.duplicated(["user_id", "step"]).any()
for _, group in events.groupby("user_id"):
    assert group.sort_values("sequence").step.tolist() == steps[:len(group)]
cohort = set(events.loc[events.step == steps[0], "user_id"])
previous = cohort
counts = []
for step in steps:
    reached = set(events.loc[events.step == step, "user_id"]) & previous
    counts.append(len(reached)); previous = reached
funnel = pd.DataFrame({"step": steps, "users": counts})
funnel["overall"] = funnel.users / len(cohort)
funnel["step_conversion"] = funnel.users / funnel.users.shift(1)
funnel["dropped"] = (funnel.users.shift(1) - funnel.users).fillna(0).astype(int)
print(funnel.round(3)); funnel.to_csv(OUT / "funnel.csv", index=False)
assert all(a >= b for a, b in zip(counts, counts[1:]))

# %% Inspect a suspected friction point using a denominator
upload = events.loc[events.step == "id_upload", ["user_id", "device"]].copy()
verified = set(events.loc[events.step == "id_verified", "user_id"])
upload["verified"] = upload.user_id.isin(verified)
print(upload.groupby("device").verified.agg(["mean", "count"]).round(3))
print("Device differences here are simulation noise, not a causal UX finding.")
