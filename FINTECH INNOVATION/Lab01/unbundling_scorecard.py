"""
FinTech Innovation --- Lab 1: Unbundling scorecard.

Keeps the disruption-likelihood arithmetic honest and reproducible. The
analysis is yours; this only stops the scoring drifting between segments.

Chapter 1 argues disruption concentrates where four conditions hold
together: high customer friction, weak regulatory moat, low capital
intensity, and a data or network advantage available to the entrant.

Score each 1-5 in value_chain.csv, where 5 always means "more favourable
to the challenger". Note that moat and capital are therefore INVERTED
relative to the bank's strength: a strong regulatory moat scores 1.

Run:
    py unbundling_scorecard.py value_chain.csv
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

# Weights reflect Chapter 1's emphasis: regulatory protection is the
# single strongest determinant of whether an entrant can operate at all.
WEIGHTS = {
    "friction": 0.30,
    "moat": 0.35,
    "capital": 0.15,
    "data": 0.20,
}


def load(path: Path) -> list[dict]:
    with path.open(encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))

    if not rows:
        sys.exit(f"{path}: no rows found")

    required = {"segment", "revenue", *WEIGHTS}
    missing = required - set(rows[0])
    if missing:
        sys.exit(f"{path}: missing column(s): {', '.join(sorted(missing))}")

    return rows


def score(row: dict) -> float:
    """Weighted disruption-likelihood score, 1.0 to 5.0."""
    total = 0.0
    for factor, weight in WEIGHTS.items():
        try:
            value = float(row[factor])
        except ValueError:
            sys.exit(f"segment {row['segment']!r}: {factor} is not a number")
        if not 1 <= value <= 5:
            sys.exit(f"segment {row['segment']!r}: {factor}={value} outside 1-5")
        total += value * weight
    return total


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("usage: py unbundling_scorecard.py value_chain.csv")

    rows = load(Path(sys.argv[1]))

    scored = []
    for row in rows:
        s = score(row)
        revenue = float(row["revenue"] or 0)
        # Revenue at risk scales with score above the neutral midpoint of 3.
        at_risk = revenue * max(0.0, (s - 3.0) / 2.0)
        scored.append((s, at_risk, row, revenue))

    scored.sort(reverse=True, key=lambda r: r[0])

    print(f"{'segment':<16}{'fric':>6}{'moat':>6}{'cap':>6}{'data':>6}"
          f"{'score':>8}{'revenue':>12}{'at risk':>12}")
    print("-" * 72)

    total_revenue = total_at_risk = 0.0
    for s, at_risk, row, revenue in scored:
        flag = "  <-- investigate" if s > 3.0 else ""
        print(f"{row['segment']:<16}"
              f"{row['friction']:>6}{row['moat']:>6}"
              f"{row['capital']:>6}{row['data']:>6}"
              f"{s:>8.2f}{revenue:>12,.0f}{at_risk:>12,.0f}{flag}")
        total_revenue += revenue
        total_at_risk += at_risk

    print("-" * 72)
    share = total_at_risk / total_revenue if total_revenue else 0
    print(f"{'TOTAL':<16}{'':>32}{total_revenue:>12,.0f}{total_at_risk:>12,.0f}")
    print(f"\n  {share:.1%} of mapped revenue sits in segments scoring above 3.0.")
    print("\n  A high score is a HYPOTHESIS, not a finding. Every segment above")
    print("  3.0 needs a named challenger and evidence of real volume. If you")
    print("  cannot name one, revise the score and say why.")


if __name__ == "__main__":
    main()
