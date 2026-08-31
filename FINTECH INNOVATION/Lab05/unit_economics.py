"""
FinTech Innovation --- Lab 5: Neobank unit economics.

Answers the chapter's third strategic priority --- expand PROFITABLY ---
and identifies which input the answer is most sensitive to.

No data file needed; every input is a parameter you vary.

Run:
    py unit_economics.py
"""

from __future__ import annotations

BASE = dict(cac=45.0, arpu=4.20, cost_to_serve=1.80, monthly_churn=0.03)


def unit_economics(cac: float, arpu: float,
                   cost_to_serve: float, monthly_churn: float) -> dict:
    """Core per-customer metrics.

    LTV = contribution / churn assumes churn is CONSTANT FOREVER, which it
    is not --- churn is high early and falls as customers settle. The
    formula therefore understates a seasoned customer and overstates a book
    dominated by new sign-ups. A fast-growing neobank has a young book, so
    its reported LTV is the least reliable number in its deck.
    """
    contribution = arpu - cost_to_serve

    if contribution <= 0:
        # Guard first: a negative contribution makes LTV negative and the
        # payback period meaningless, so report the verdict instead of
        # printing a number that looks like an answer.
        return {"verdict": "loses money on every customer",
                "contribution": round(contribution, 2)}

    ltv = contribution / monthly_churn
    return {
        "contribution": round(contribution, 2),
        "payback_months": round(cac / contribution, 1),
        "avg_lifetime_months": round(1 / monthly_churn, 1),
        "ltv": round(ltv, 2),
        "ltv_cac": round(ltv / cac, 2),
    }


def project(months: int, new_per_month: int, cac: float, arpu: float,
            cost_to_serve: float, churn: float, label: str = "",
            stop_acquiring_at: int | None = None) -> tuple[float, int | None]:
    """Cumulative cash over time.

    Each new customer costs CAC today and repays over the payback period,
    so acquisition consumes cash NOW against profit LATER.

    `stop_acquiring_at` halts new acquisition from that month onward, which
    is what turns the existing book from a cost into a harvest.
    """
    header = f"\n  {label}  ({new_per_month:,}/month"
    header += f", stop at month {stop_acquiring_at})" if stop_acquiring_at else ")"
    print(header)
    print(f"  {'month':>6}  {'customers':>12}  {'cumulative cash':>17}")

    customers, cash, break_even = 0.0, 0.0, None
    for m in range(1, months + 1):
        acquired = 0 if (stop_acquiring_at and m >= stop_acquiring_at) else new_per_month

        customers = customers * (1 - churn) + acquired
        cash += customers * (arpu - cost_to_serve) - acquired * cac

        if cash > 0 and break_even is None:
            break_even = m
        if m % 6 == 0 or m == months:
            print(f"  {m:>6}  {customers:>12,.0f}  {cash:>17,.0f}")

    verdict = f"month {break_even}" if break_even else f"not within {months} months"
    print(f"  cash break-even: {verdict}")
    return cash, break_even


def sensitivity(base: dict) -> None:
    """Vary each input +/-20% and rank by effect on LTV/CAC."""
    baseline = unit_economics(**base)["ltv_cac"]
    print(f"\n  baseline LTV/CAC: {baseline}\n")
    print(f"  {'input':<16} {'-20%':>10} {'+20%':>10} {'swing':>10}")

    rows = []
    for key in base:
        results = {}
        for factor in (0.8, 1.2):
            trial = dict(base)
            trial[key] = base[key] * factor
            results[factor] = unit_economics(**trial)["ltv_cac"]
        swing = abs(results[1.2] - results[0.8])
        rows.append((swing, key, results))

    for swing, key, results in sorted(rows, reverse=True):
        print(f"  {key:<16} {results[0.8]:>10.2f} {results[1.2]:>10.2f} {swing:>10.2f}")

    dominant = max(rows)[1]
    print(f"\n  Most influential input: {dominant}")


def main() -> None:
    print("=" * 70)
    print("Part A --- per-customer economics")
    print("=" * 70)
    for key, value in BASE.items():
        print(f"  {key:<16} {value}")
    print()
    for key, value in unit_economics(**BASE).items():
        print(f"  {key:<22} {value}")

    print("\n  A venture benchmark for LTV/CAC is 3.0. Below that, there is")
    print("  little left over to cover engineering, compliance, and licensing")
    print("  --- fixed costs this model has not touched.")

    print("\n" + "=" * 70)
    print("Part B --- growth consumes cash before it produces it")
    print("=" * 70)
    fast, fast_be = project(60, 50_000, BASE["cac"], BASE["arpu"],
                            BASE["cost_to_serve"], BASE["monthly_churn"],
                            "fast growth")
    slow, slow_be = project(60, 5_000, BASE["cac"], BASE["arpu"],
                            BASE["cost_to_serve"], BASE["monthly_churn"],
                            "slow growth")

    print(f"\n  fast/slow cash ratio at month 60: {fast / slow:.1f}x")
    print(f"  break-even month --- fast: {fast_be}, slow: {slow_be}")
    print(
        "\n  The two curves are EXACT multiples of each other, and the\n"
        "  break-even month is identical. With constant acquisition, both\n"
        "  customers and cash scale linearly in new_per_month, so growth\n"
        "  rate changes the SIZE of the hole but not its SHAPE.\n"
        "\n"
        "  Growing more slowly does not reach profitability sooner. Only\n"
        "  better unit economics, or stopping acquisition, does that:"
    )

    harvest, harvest_be = project(60, 50_000, BASE["cac"], BASE["arpu"],
                                  BASE["cost_to_serve"], BASE["monthly_churn"],
                                  "harvest the book", stop_acquiring_at=24)
    print(
        f"\n  Halting acquisition at month 24 breaks even at month {harvest_be},\n"
        "  because the existing book keeps paying while the CAC stops. This is\n"
        "  the lever a board actually pulls when funding tightens --- and it\n"
        "  trades future scale for present solvency."
    )

    print("\n" + "=" * 70)
    print("Part C --- sensitivity")
    print("=" * 70)
    sensitivity(BASE)

    print("\n" + "=" * 70)
    print("Edge case --- when contribution is negative")
    print("=" * 70)
    print(" ", unit_economics(cac=45, arpu=1.50, cost_to_serve=1.80,
                              monthly_churn=0.03))


if __name__ == "__main__":
    main()
