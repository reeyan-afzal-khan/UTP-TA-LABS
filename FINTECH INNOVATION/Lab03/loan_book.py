"""
FinTech Innovation --- Lab 3: P2P loan-book economics and diversification.

Computes what an investor actually receives on a marketplace-lending book,
then demonstrates numerically why concentration is the risk that ruins
retail lenders.

Data is synthetic (see tools/generate_datasets.py). Magnitudes are
calibrated to published disclosures; individual loans are not real.

Run:
    py loan_book.py
"""

from __future__ import annotations

import numpy as np
import pandas as pd

PLATFORM_FEE = 0.01     # 1% of outstanding principal per year
CAPITAL = 5_000.0
TRIALS = 10_000


def load() -> pd.DataFrame:
    return pd.read_csv("loans.csv")


# --------------------------------------------------------------------------
# Part A/B --- advertised yield is not investor return
# --------------------------------------------------------------------------

def grade_economics(loans: pd.DataFrame) -> pd.DataFrame:
    """Net yield per grade, after expected loss and platform fee.

    Expected loss = PD x LGD, where loss given default is 1 - recovery.
    Recovery is recorded as 0 for performing loans, so it must be averaged
    over DEFAULTED loans only --- averaging over all loans would understate
    LGD badly and make every grade look profitable.
    """
    defaulted = loans[loans["defaulted"] == 1]

    table = pd.DataFrame({
        "n": loans.groupby("grade").size(),
        "coupon": loans.groupby("grade")["interest_rate"].mean(),
        "default_rate": loans.groupby("grade")["defaulted"].mean(),
        "recovery": defaulted.groupby("grade")["recovery_rate"].mean(),
    })

    table["lgd"] = 1 - table["recovery"]
    table["expected_loss"] = table["default_rate"] * table["lgd"]
    table["net_yield"] = table["coupon"] - table["expected_loss"] - PLATFORM_FEE

    return table.round(4)


# --------------------------------------------------------------------------
# Part C --- diversification
# --------------------------------------------------------------------------

def diversification(loans: pd.DataFrame, stress: float = 1.0) -> pd.DataFrame:
    """Deploy fixed capital across n loans, many times, and record the spread.

    `stress` multiplies every default probability, modelling a recession in
    which defaults become correlated across the whole book at once.
    """
    rng = np.random.default_rng(42)

    rate = loans["interest_rate"].to_numpy()
    recovery = loans["recovery_rate"].to_numpy()
    defaulted = loans["defaulted"].to_numpy().astype(bool)

    if stress != 1.0:
        # Re-draw defaults at a higher rate, applied to every loan together.
        base_pd = defaulted.mean()
        defaulted = rng.random(len(loans)) < min(1.0, base_pd * stress)

    results = []
    for n in [1, 5, 20, 100, 500]:
        idx = rng.integers(0, len(loans), size=(TRIALS, n))
        per_loan = CAPITAL / n

        # Defaulted loans return only the recovered fraction of principal;
        # performing loans return principal plus coupon.
        returned = np.where(
            defaulted[idx],
            per_loan * recovery[idx],
            per_loan * (1 + rate[idx]),
        ).sum(axis=1)

        outcomes = returned / CAPITAL - 1
        results.append({
            "n_loans": n,
            "mean": outcomes.mean(),
            "std_dev": outcomes.std(),
            "p05": np.percentile(outcomes, 5),
            "p95": np.percentile(outcomes, 95),
            "prob_loss": (outcomes < 0).mean(),
        })

    return pd.DataFrame(results).set_index("n_loans").round(4)


def main() -> None:
    loans = load()

    print("=" * 74)
    print("Part A/B --- net yield by grade")
    print("=" * 74)
    table = grade_economics(loans)
    print(table.to_string())

    best = table["net_yield"].idxmax()
    print(f"\n  highest coupon      : grade {table['coupon'].idxmax()}")
    print(f"  highest NET yield   : grade {best}")
    print("  -> the riskiest grade is not the most profitable, because")
    print("     expected loss eventually overtakes the extra coupon.")

    print("\n" + "=" * 74)
    print("Part C --- diversification (normal conditions)")
    print("=" * 74)
    normal = diversification(loans)
    print(normal.to_string())
    print("\n  mean barely moves; standard deviation and P(loss) collapse.")
    print("  Diversification does not raise expected return --- it cannot.")
    print("  It reduces the variance around that return.")

    print("\n" + "=" * 74)
    print("Part C --- diversification under correlated (3x) defaults")
    print("=" * 74)
    stressed = diversification(loans, stress=3.0)
    print(stressed.to_string())
    print("\n  The whole distribution shifts down. Diversification smooths the")
    print("  spread but cannot rescue a book where every loan sours together.")
    print("  This is the risk the marketing material does not price.")


if __name__ == "__main__":
    main()
