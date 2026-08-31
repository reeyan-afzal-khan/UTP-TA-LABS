"""
FinTech Innovation --- Lab 7: Platform competition scorecard.

Applies Chapter 7's "four assets and one liability" framework to a Big Tech
entrant against an incumbent bank, and separates contested segments from
defensible ones.

Scores live in platforms.csv so the analysis is auditable and you can
justify each number in your write-up.

Run:
    py platform_scorecard.py --platform grab --incumbent maybank
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

ASSETS = ["customer_access", "data", "brand_trust", "capital_talent"]
LIABILITY = "regulatory_position"

# Which assets decide each value-chain segment. A segment is contested when
# the challenger leads on the assets that actually matter for it.
SEGMENT_DRIVERS = {
    "payments":     ["customer_access", "data"],
    "fx":           ["customer_access", "capital_talent"],
    "micro_credit": ["data", "capital_talent"],
    "deposits":     ["brand_trust", LIABILITY],
    "mortgages":    ["brand_trust", LIABILITY, "capital_talent"],
    "wealth":       ["brand_trust", "data"],
    "corporate":    ["brand_trust", LIABILITY, "capital_talent"],
}


def load(path: Path) -> dict[str, dict[str, int]]:
    if not path.exists():
        sys.exit(f"{path} not found --- copy platforms.csv.example and edit it")

    scores: dict[str, dict[str, int]] = {}
    with path.open(encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            entity = row["entity"].strip().lower()
            scores[entity] = {
                k: int(row[k]) for k in [*ASSETS, LIABILITY]
            }
    return scores


def compare(platform: str, incumbent: str,
            scores: dict[str, dict[str, int]]) -> None:
    for name in (platform, incumbent):
        if name not in scores:
            sys.exit(f"{name!r} not in platforms.csv "
                     f"(have: {', '.join(sorted(scores))})")

    p, b = scores[platform], scores[incumbent]

    print(f"{'factor':<22}{platform:>12}{incumbent:>12}  advantage")
    print("-" * 60)
    for factor in [*ASSETS, LIABILITY]:
        if p[factor] > b[factor]:
            advantage = platform
        elif b[factor] > p[factor]:
            advantage = incumbent
        else:
            advantage = "neutral"

        marker = "  (liability)" if factor == LIABILITY else ""
        print(f"{factor:<22}{p[factor]:>12}{b[factor]:>12}  {advantage}{marker}")

    contested, defensible = [], []
    for segment, drivers in SEGMENT_DRIVERS.items():
        platform_strength = sum(p[d] for d in drivers)
        bank_strength = sum(b[d] for d in drivers)
        (contested if platform_strength > bank_strength else defensible).append(segment)

    print(f"\n  contested segments : {', '.join(contested) or 'none'}")
    print(f"  defensible segments: {', '.join(defensible) or 'none'}")

    print(
        "\n  Segments are judged on the assets that decide THAT segment, not\n"
        "  on the overall score. A platform can dominate on access and data\n"
        "  and still lose deposits, because deposits turn on trust and a\n"
        "  banking licence --- exactly the two the platform lacks."
    )

    if p[LIABILITY] < b[LIABILITY]:
        print(
            "\n  The liability binds. Big Tech firms have repeatedly retreated\n"
            "  from regulated banking while expanding in payments --- Google\n"
            "  Plex was cancelled, Libra/Diem collapsed. Name the specific\n"
            "  licence regime that stops your platform, in a named jurisdiction."
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--incumbent", required=True)
    parser.add_argument("--scores", default="platforms.csv", type=Path)
    args = parser.parse_args()

    compare(args.platform.lower(), args.incumbent.lower(), load(args.scores))


if __name__ == "__main__":
    main()
