"""
FinTech Innovation --- Lab 4: Onboarding funnel analysis.

Finds the single step where a digital-bank onboarding journey loses most
of its users, then segments that step to distinguish an interface problem
from a device problem.

Data is synthetic (see tools/generate_datasets.py).

Run:
    py funnel_analysis.py
"""

from __future__ import annotations

import pandas as pd

STEPS = ["app_open", "signup_start", "id_upload", "id_verified",
         "address_entered", "account_funded", "first_payment"]


def load() -> pd.DataFrame:
    return pd.read_csv("onboarding_events.csv")


def funnel(events: pd.DataFrame) -> pd.DataFrame:
    """Users reaching each step, with overall and step-to-step conversion.

    Read the STEP column, not the overall column. Overall conversion falls
    monotonically by construction, so its smallest value is always the last
    step --- which tells you nothing about where the product is broken.
    """
    counts = [events.loc[events["step"] == s, "user_id"].nunique() for s in STEPS]

    table = pd.DataFrame({"step": STEPS, "users": counts})
    table["overall"] = table["users"] / table["users"].iloc[0]
    table["step_conversion"] = table["users"] / table["users"].shift(1)
    table["dropped"] = (table["users"].shift(1) - table["users"]).fillna(0).astype(int)

    return table.set_index("step").round(4)


def segment(events: pd.DataFrame, step: str, previous: str,
            dimension: str) -> pd.DataFrame:
    """Step conversion split by one dimension.

    Conversion for a segment is (users of that segment reaching `step`) /
    (users of that segment reaching `previous`) --- both restricted to the
    same segment, or the ratio is meaningless.
    """
    reached_prev = events[events["step"] == previous][["user_id", dimension]]
    reached_step = set(events.loc[events["step"] == step, "user_id"])

    reached_prev = reached_prev.drop_duplicates("user_id").copy()
    reached_prev["converted"] = reached_prev["user_id"].isin(reached_step)

    out = reached_prev.groupby(dimension)["converted"].agg(["mean", "count"])
    out.columns = ["conversion", "users_at_previous_step"]
    return out.sort_values("conversion").round(4)


def main() -> None:
    events = load()

    print("=" * 72)
    print("Part C --- the onboarding funnel")
    print("=" * 72)
    table = funnel(events)
    print(table.to_string())

    # The worst step is the one with the lowest step-to-step conversion,
    # ignoring the first row which has no predecessor.
    worst = table["step_conversion"].iloc[1:].idxmin()
    worst_idx = STEPS.index(worst)
    previous = STEPS[worst_idx - 1]
    rate = table.loc[worst, "step_conversion"]
    lost = table.loc[worst, "dropped"]

    print(f"\n  Worst step: {previous} -> {worst}")
    print(f"  Converts at {rate:.1%}; {lost:,} users lost here.")
    print("  Every other step converts far higher, so this is where a fix")
    print("  returns the most users per unit of engineering effort.")

    print("\n" + "=" * 72)
    print(f"Segmenting '{worst}' before proposing a fix")
    print("=" * 72)

    for dimension in ["device_type", "hour_of_day"]:
        result = segment(events, worst, previous, dimension)
        print(f"\n  --- by {dimension} ---")

        if dimension == "hour_of_day":
            # 24 rows is noise; report only the spread.
            spread = result["conversion"].max() - result["conversion"].min()
            print(f"      best  {result['conversion'].max():.1%}   "
                  f"worst {result['conversion'].min():.1%}   "
                  f"spread {spread:.1%}")
            if spread < 0.10:
                print("      -> no meaningful time-of-day effect")
        else:
            print(result.to_string())

    print(
        "\n  The failure is concentrated on one device class, not spread\n"
        "  evenly across users. That points at camera and image quality on\n"
        "  older handsets rather than at the interface --- so the fix is\n"
        "  capture guidance and a lower-resolution fallback, not a redesign.\n"
        "\n"
        "  A uniform failure would have demanded the opposite conclusion.\n"
        "  Segment before you build."
    )


if __name__ == "__main__":
    main()
