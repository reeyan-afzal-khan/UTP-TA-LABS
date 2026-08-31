"""
FinTech Innovation --- Lab 8: Testing whether a cryptocurrency is money.

Measures the properties Chapter 8 discusses qualitatively, then applies
the three-function test with evidence rather than opinion.

Data is synthetic (see tools/generate_datasets.py). Volatility magnitudes
are calibrated to historical crypto and FX behaviour, but no row is a real
historical price. Do not quote a figure here as a real observation.

Run:
    py volatility_analysis.py
"""

from __future__ import annotations

import numpy as np
import pandas as pd

TRADING_DAYS = 365      # crypto trades every day; use 252 for equities only
PURCHASE = 20.00


def load() -> pd.DataFrame:
    return pd.read_csv("price_series.csv", parse_dates=["date"]).set_index("date")


def annualised_volatility(prices: pd.DataFrame) -> pd.Series:
    """Standard deviation of log returns, scaled to one year.

    Log returns rather than simple returns, for two reasons:
      * they are additive over time, so scaling by sqrt(T) is valid
      * they are symmetric in direction --- +50% then -50% is not a round
        trip in simple returns, but log returns handle it correctly
    """
    returns = np.log(prices / prices.shift(1)).dropna()
    return returns.std() * np.sqrt(TRADING_DAYS)


def max_drawdown(series: pd.Series) -> float:
    """Worst peak-to-trough decline over the period.

    Volatility treats gains and losses alike. A holder does not. Drawdown
    measures the loss actually experienced by someone who bought at the
    worst moment.
    """
    running_peak = series.cummax()
    return (series / running_peak - 1).min()


def recovery_required(drawdown: float) -> float:
    """Gain needed to undo a given drawdown.

    A 50% fall needs a 100% rise; an 80% fall needs 400%. The asymmetry is
    why drawdown matters more than volatility for a store of value.
    """
    return 1 / (1 + drawdown) - 1


def main() -> None:
    px = load()

    print("=" * 72)
    print("Part A --- annualised volatility")
    print("=" * 72)
    vol = annualised_volatility(px)
    for asset, value in vol.sort_values(ascending=False).items():
        print(f"  {asset:<16} {value:>7.1%}")

    ratio = vol["crypto_usd"] / vol["fiat_eurusd"]
    print(f"\n  The crypto series is {ratio:.0f}x as volatile as the fiat pair.")

    print("\n" + "=" * 72)
    print("Part B --- maximum drawdown, and the cost of recovering from it")
    print("=" * 72)
    print(f"  {'asset':<16} {'max drawdown':>14} {'gain to recover':>17}")
    for asset in px.columns:
        dd = max_drawdown(px[asset])
        print(f"  {asset:<16} {dd:>14.1%} {recovery_required(dd):>17.1%}")

    print("\n  Losses and the gains needed to undo them are not symmetric,")
    print("  and the deeper the fall the more violently the gap widens.")

    print("\n" + "=" * 72)
    print("Part C --- the three-function test")
    print("=" * 72)

    print("\n  Medium of exchange --- is the fee proportionate to daily spending?")
    for fee, condition in [(0.15, "quiet network"),
                           (1.20, "typical"),
                           (8.50, "congested")]:
        print(f"      ${fee:>5.2f} fee = {fee / PURCHASE:>6.1%} "
              f"of a ${PURCHASE:.0f} purchase   ({condition})")
    print(f"      settlement at 6 confirmations: ~{6 * 10} minutes")

    print("\n  Store of value --- can purchasing power survive the holding period?")
    dd = max_drawdown(px["crypto_usd"])
    print(f"      annualised volatility {vol['crypto_usd']:.1%}, "
          f"max drawdown {dd:.1%}")

    print("\n  Unit of account --- are prices quoted natively in it?")
    print("      Count real goods priced in the currency itself rather than")
    print("      converted from fiat at checkout. This is a research task,")
    print("      not a computation --- and the count is usually near zero.")

    print(
        "\n  The three functions are not independent, and the dependency runs\n"
        "  one way. Volatility undermines store of value directly. It also\n"
        "  undermines unit of account, because nobody prices a menu in a unit\n"
        "  that moves overnight. And it undermines medium of exchange, because\n"
        "  a merchant accepting payment converts to fiat immediately to avoid\n"
        "  the exposure --- making the currency a transfer rail, not money."
    )

    print("\n  NOTE: this dataset is synthetic. Do not quote these figures as fact.")


if __name__ == "__main__":
    main()
