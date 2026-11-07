# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab07"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Make the scoring assumptions visible
# Fictional Platform P and Bank B: replace every rating with cited evidence.
rows = [("customer_access", 5, 3), ("data", 4, 3), ("brand_trust", 3, 5),
        ("capital_talent", 4, 4), ("regulatory_position", 2, 5)]
path = OUT / "platform_scores.csv"
with path.open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f);writer.writerow(["asset", "platform", "bank"])
    writer.writerows(rows)

# %% Compare assets without turning them into unsupported market forecasts
with path.open(encoding="utf-8") as f:
    records = list(csv.DictReader(f))
for row in records:
    platform, bank = int(row["platform"]), int(row["bank"])
    assert 1 <= platform <= 5 and 1 <= bank <= 5
    difference = platform - bank
    advantage = "platform" if difference > 0 else "bank" if difference < 0 else "tie"
    print(f'{row["asset"]:22s} {platform} {bank} {difference:+d} {advantage}')

# %% Create a record of evidence and dependencies
with (OUT / "evidence_template.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["asset", "entity", "score", "source_url", "date", "jurisdiction", "limitation"])
    for asset, *_ in rows:
        for entity in ["Platform P", "Bank B"]:
            writer.writerow([asset, entity, "", "", "", "", ""])
print("Ratings do not establish licensing rights, adoption, or future market share.")
