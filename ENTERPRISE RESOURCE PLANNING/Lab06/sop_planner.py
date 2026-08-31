"""
Enterprise Resource Planning --- Lab 6: Sales forecasting and S&OP.

Lab 6 in the notes requires a planning spreadsheet that was not supplied
with the course materials. This script reproduces the same calculation so
the lab is completable, and -- more usefully -- makes the formulas explicit
rather than hiding them in cells.

Build the spreadsheet as the tutorial requires. Use this to CHECK it.
If your sheet and this script disagree, one of you has a formula wrong,
and finding out which is the point.

Run:
    py sop_planner.py
    py sop_planner.py --safety-stock 500
"""

from __future__ import annotations

import argparse

# --- Tutorial 6 inputs -----------------------------------------------------

MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

PREVIOUS_YEAR_SALES = [2100, 1950, 2300, 2200, 2400, 3100,
                       2500, 2450, 2600, 2700, 3400, 3900]

# Promotions run last year that must be stripped out before growth is applied.
PREVIOUS_PROMOTION = [0, 0, 0, 0, 0, 400, 0, 0, 0, 0, 500, 600]

# Promotions planned for this year.
CURRENT_PROMOTION = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500, 400]

GROWTH_RATE = 0.03
PRODUCTION_RATE_PER_HOUR = 40      # shoes per hour
HOURS_PER_DAY = 8
WORKING_DAYS = [22, 20, 22, 21, 22, 21, 22, 22, 21, 22, 21, 20]
MAX_UTILISATION = 0.99


def forecast() -> list[dict]:
    """Part A --- the four-step forecast from the tutorial.

        base       = previous year sales - previous promotion
        growth     = base * 3%
        projection = base + growth
        forecast   = projection + current promotion

    Promotions are removed BEFORE growth is applied and added back after.
    Growing a promoted figure would compound a one-off uplift into the
    baseline, inflating every future year.
    """
    rows = []
    for i, month in enumerate(MONTHS):
        base = PREVIOUS_YEAR_SALES[i] - PREVIOUS_PROMOTION[i]
        growth = base * GROWTH_RATE
        projection = base + growth
        demand = projection + CURRENT_PROMOTION[i]

        rows.append({
            "month": month,
            "py_sales": PREVIOUS_YEAR_SALES[i],
            "py_promo": PREVIOUS_PROMOTION[i],
            "base": base,
            "growth": growth,
            "projection": projection,
            "cur_promo": CURRENT_PROMOTION[i],
            "forecast": demand,
        })
    return rows


def capacity(unit: str) -> list[float]:
    """Part B --- capacity expressed in the SAME unit as demand.

    The tutorial states demand in PAIRS but the production rate as 40
    SHOES/hour. Those are not the same unit, and the discrepancy is
    deliberate -- resolving it is the exercise.

    unit="pairs"  the line makes 40 PAIRS/hour. Capacity is ~7,000/month
                  against ~2,500 demand, so nothing ever binds and the
                  S&OP plan is trivial.

    unit="shoes"  the line makes 40 SHOES/hour = 20 pairs/hour. Capacity
                  halves to ~3,500/month, December demand exceeds it, and
                  you must build ahead. This is the interpretation that
                  produces a real planning problem.

    Run both. The fact that one reading makes the exercise meaningless is
    itself strong evidence for which the tutor intended -- say so in your
    submission rather than silently picking one.
    """
    shoes_per_hour = PRODUCTION_RATE_PER_HOUR
    pairs_per_hour = shoes_per_hour if unit == "pairs" else shoes_per_hour / 2
    return [pairs_per_hour * HOURS_PER_DAY * d for d in WORKING_DAYS]


def sop_plan(rows: list[dict], caps: list[float],
             opening_inventory: float, safety_stock: float) -> list[dict]:
    """Part C --- build a production plan respecting capacity and safety stock.

    Inventory balance:   I(t) = I(t-1) + P(t) - F(t)

    Plan production to end each month at or above safety stock, without
    exceeding the utilisation ceiling. Where demand outruns capacity --
    the festive peaks in June and December -- build ahead in earlier
    months rather than failing to deliver.
    """
    plan = []
    inventory = opening_inventory

    # Look ahead: if a later month's demand exceeds what that month can
    # produce, the deficit has to be built earlier. Level production is
    # the standard S&OP answer to a seasonal peak.
    deficits = [max(0.0, r["forecast"] - c * MAX_UTILISATION)
                for r, c in zip(rows, caps)]

    for i, row in enumerate(rows):
        demand = row["forecast"]
        cap = caps[i]
        usable = cap * MAX_UTILISATION

        # Produce for this month, plus a share of any future shortfall we
        # can still cover, finishing at or above safety stock.
        future_deficit = sum(deficits[i + 1:])
        required = demand + safety_stock - inventory + future_deficit
        production = max(0.0, min(required, usable))

        closing = inventory + production - demand
        utilisation = production / cap if cap else 0.0

        plan.append({
            "month": row["month"],
            "forecast": demand,
            "capacity": cap,
            "production": production,
            "utilisation": utilisation,
            "opening": inventory,
            "closing": closing,
            "shortfall": max(0.0, safety_stock - closing),
        })
        inventory = closing

    return plan


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--safety-stock", type=float, default=100.0,
        help="Tutorial 6 says 100; the supplied spreadsheet cell says 500. "
             "Confirm which your tutor wants and state it in your submission.",
    )
    parser.add_argument("--opening-inventory", type=float, default=500.0)
    parser.add_argument(
        "--unit", choices=["shoes", "pairs"], default="shoes",
        help="Whether the 40/hour production rate counts shoes or pairs. "
             "See capacity() -- 'pairs' makes the exercise trivial.",
    )
    args = parser.parse_args()

    rows = forecast()
    caps = capacity(args.unit)

    print("=" * 78)
    print("Part A --- sales forecast")
    print("=" * 78)
    print(f"  {'month':<6}{'PY sales':>10}{'PY promo':>10}{'base':>9}"
          f"{'growth':>9}{'projection':>12}{'promo':>8}{'forecast':>10}")
    for r in rows:
        print(f"  {r['month']:<6}{r['py_sales']:>10,}{r['py_promo']:>10,}"
              f"{r['base']:>9,}{r['growth']:>9,.0f}{r['projection']:>12,.0f}"
              f"{r['cur_promo']:>8,}{r['forecast']:>10,.0f}")
    print(f"\n  total forecast demand: {sum(r['forecast'] for r in rows):,.0f}")

    print("\n" + "=" * 78)
    print("Part C --- S&OP plan")
    print(f"(unit={args.unit}, safety stock {args.safety_stock:,.0f}, "
          f"opening inventory {args.opening_inventory:,.0f}, "
          f"max utilisation {MAX_UTILISATION:.0%})")
    print("=" * 78)
    plan = sop_plan(rows, caps, args.opening_inventory, args.safety_stock)

    print(f"  {'month':<6}{'forecast':>10}{'capacity':>10}{'produce':>10}"
          f"{'util':>8}{'opening':>10}{'closing':>10}{'short':>8}")
    for p in plan:
        flag = "  <--" if p["shortfall"] > 0 else ""
        print(f"  {p['month']:<6}{p['forecast']:>10,.0f}{p['capacity']:>10,.0f}"
              f"{p['production']:>10,.0f}{p['utilisation']:>8.1%}"
              f"{p['opening']:>10,.0f}{p['closing']:>10,.0f}"
              f"{p['shortfall']:>8,.0f}{flag}")

    shortfalls = [p for p in plan if p["shortfall"] > 0]
    peak = max(plan, key=lambda p: p["utilisation"])

    print(f"\n  peak utilisation : {peak['utilisation']:.1%} in {peak['month']}")
    if shortfalls:
        months = ", ".join(p["month"] for p in shortfalls)
        print(f"  months below safety stock: {months}")
        print("\n  A shortfall means level production cannot absorb the peak.")
        print("  Build ahead in earlier months, or negotiate overtime capacity.")
    else:
        print("  no month falls below safety stock")

    print("\n" + "=" * 78)
    print("Part D --- the source discrepancy")
    print("=" * 78)
    print("  Tutorial 6 states safety stock = 100.")
    print("  The supplied spreadsheet has 500 in the opening December cell.")
    print("  Do not hide the conflict. Run both, state which your tutor")
    print("  requires, and record the assumption in your submission:")
    print("\n      py sop_planner.py --safety-stock 100")
    print("      py sop_planner.py --safety-stock 500")


if __name__ == "__main__":
    main()
