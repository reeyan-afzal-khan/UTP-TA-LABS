"""
FinTech Innovation --- Lab 2: Measuring financial inclusion.

Moves from "FinTech improves financial inclusion", which is untestable as
written, to specific measured statements about who is excluded and why.

Data is synthetic and Findex-shaped (see tools/generate_datasets.py). If
you obtain the real Global Findex microdata, the column names match, so
this script runs against it unchanged.

Run:
    py inclusion_analysis.py
"""

from __future__ import annotations

import pandas as pd

BARRIERS = ["cost", "distance", "documentation", "trust", "no_credit_history"]


def load() -> pd.DataFrame:
    df = pd.read_csv("findex_sample.csv")
    # Stored as 0/1 for CSV portability; booleans make the logic below read
    # naturally and let & and | behave as expected.
    for col in ["has_account", "uses_credit", "uses_savings",
                "has_mobile_money", "has_utility_account", *BARRIERS]:
        df[col] = df[col].astype(bool)
    return df


def headline_and_gaps(df: pd.DataFrame) -> None:
    print("=" * 70)
    print("Part A --- the headline rate hides its own variance")
    print("=" * 70)
    print(f"  national account ownership: {df['has_account'].mean():.1%}\n")

    for dim in ["gender", "income_quintile", "urban_rural", "education"]:
        grouped = df.groupby(dim)["has_account"].agg(["mean", "count"])
        gap = grouped["mean"].max() - grouped["mean"].min()

        print(f"  --- by {dim} (gap: {gap:.1%}) ---")
        for key, row in grouped.iterrows():
            print(f"      {str(key):<12} {row['mean']:>7.1%}   n={int(row['count']):>6,}")
        print()

    print("  Always report the gap alongside the mean. Two countries at the")
    print("  same headline rate with different gaps have little in common.")


def access_versus_usage(df: pd.DataFrame) -> None:
    print("\n" + "=" * 70)
    print("Part B --- access is not usage")
    print("=" * 70)

    # Three progressively stricter definitions of "financially included".
    levels = {
        "access": df["has_account"],
        "active": df["has_account"] & (df["transactions_90d"] >= 3),
        "meaningful": (df["has_account"]
                       & (df["transactions_90d"] >= 3)
                       & (df["uses_credit"] | df["uses_savings"])),
    }

    previous = None
    for name, mask in levels.items():
        rate = mask.mean()
        drop = f"  (-{previous - rate:.1%})" if previous is not None else ""
        print(f"  {name:<12} {rate:>7.1%}{drop}")
        previous = rate

    print("\n  A dormant account counts in the ownership statistic and")
    print("  delivers none of the benefits inclusion is meant to produce.")


def barrier_ranking(df: pd.DataFrame) -> None:
    print("\n" + "=" * 70)
    print("Part C --- why the unbanked are unbanked (self-reported)")
    print("=" * 70)

    unbanked = df[~df["has_account"]]
    print(f"  unbanked respondents: {len(unbanked):,}\n")

    ranked = unbanked[BARRIERS].mean().sort_values(ascending=False)
    for barrier, share in ranked.items():
        bar = "#" * int(share * 40)
        print(f"  {barrier:<20} {share:>6.1%}  {bar}")

    print("\n  These are stated reasons, not causes. Respondents under-report")
    print("  trust and over-report cost, because cost is easier to admit.")


def alternative_data_reach(df: pd.DataFrame) -> None:
    print("\n" + "=" * 70)
    print("Part D --- who alternative data still cannot reach")
    print("=" * 70)

    thin_file = df[~df["uses_credit"]]
    reachable = thin_file["has_mobile_money"] | thin_file["has_utility_account"]

    print(f"  thin-file population      : {len(thin_file):,}")
    print(f"  reachable by alt data     : {reachable.mean():.1%}")
    print(f"  still invisible           : {(~reachable).mean():.1%}\n")

    invisible = thin_file[~reachable]
    print("  Composition of the still-invisible group:")
    composition = (invisible.groupby(["gender", "urban_rural"])
                   .size()
                   .sort_values(ascending=False))
    for (gender, area), count in composition.items():
        print(f"      {gender:<8} {area:<8} {count:>6,}  "
              f"({count / len(invisible):.1%} of invisible)")

    # Compare against the population baseline, or the largest group looks
    # alarming purely because it is the largest group overall.
    print("\n  Compared with the population baseline:")
    base = df.groupby(["gender", "urban_rural"]).size() / len(df)
    inv = composition / len(invisible)
    for key in inv.index:
        lift = inv[key] / base[key]
        flag = "  <-- over-represented" if lift > 1.15 else ""
        print(f"      {key[0]:<8} {key[1]:<8} {lift:>5.2f}x baseline{flag}")


def main() -> None:
    df = load()
    headline_and_gaps(df)
    access_versus_usage(df)
    barrier_ranking(df)
    alternative_data_reach(df)
    print("\n  NOTE: this dataset is synthetic. Do not quote these figures as fact.")


if __name__ == "__main__":
    main()
