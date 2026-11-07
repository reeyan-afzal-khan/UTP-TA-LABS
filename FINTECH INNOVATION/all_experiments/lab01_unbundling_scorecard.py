# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab01"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Build an explicit scoring fixture
# Scores run from 1 to 5; higher always favours the challenger.
# These are invented classroom ratings, not ratings of a real bank.
rows = [
    ("payments", 4, 2, 2, 4), ("deposits", 2, 1, 3, 2),
    ("lending", 3, 2, 1, 4), ("wealth", 4, 3, 4, 3),
    ("fx", 5, 2, 5, 3), ("sme_services", 4, 3, 3, 4),
    ("trust_compliance", 1, 1, 2, 2),
]
fields = ["segment", "friction", "weak_moat", "low_capital", "data_advantage"]
path = OUT / "value_chain.csv"
with path.open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f); writer.writerow(fields); writer.writerows(rows)

# %% Load, validate, then rank
# Equal weighting is an assumption. Change it in the sensitivity exercise.
weights = [0.25, 0.25, 0.25, 0.25]
assert abs(sum(weights) - 1) < 1e-9
with path.open(encoding="utf-8") as f:
    records = list(csv.DictReader(f))
ranked = []
for row in records:
    scores = [int(row[name]) for name in fields[1:]]
    assert all(1 <= score <= 5 for score in scores)
    score = sum(w * value for w, value in zip(weights, scores))
    ranked.append((row["segment"], score))
for segment, score in sorted(ranked, key=lambda pair: pair[1], reverse=True):
    print(f"{segment:20s} {score:.2f}")

# %% Save evidence separately from the numeric score
with (OUT / "evidence_template.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["segment", "criterion", "score", "source_url", "page", "year", "reason"])
    for segment, *_ in rows:
        for criterion in fields[1:]:
            writer.writerow([segment, criterion, "", "", "", "", ""])
print("Saved value_chain.csv and evidence_template.csv")
