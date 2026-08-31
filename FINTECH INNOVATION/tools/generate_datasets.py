"""
FinTech Innovation --- synthetic dataset generator.

Creates the CSV files the Labs 2, 3, 4, and 8 scripts read. Everything is
generated from a fixed seed, so results are reproducible and match the
worked figures quoted in the notes.

These datasets are SYNTHETIC. Their structure and magnitudes are calibrated
to public sources (World Bank Global Findex, published P2P loan-book
statistics, typical onboarding funnels, historical crypto volatility), but
no row is a real observation. Never quote a figure from them as fact.

Run from the course root:
    py tools/generate_datasets.py

Requires only the standard library.
"""

from __future__ import annotations

import csv
import math
import random
from pathlib import Path

SEED = 42
ROOT = Path(__file__).resolve().parent.parent


def _write(path: Path, header: list[str], rows: list[list]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(header)
        writer.writerows(rows)
    print(f"  wrote {path.relative_to(ROOT)}  ({len(rows):,} rows)")


# --------------------------------------------------------------------------
# Lab 2 --- financial inclusion survey, Findex-shaped
# --------------------------------------------------------------------------

def findex_sample(n: int = 12_000) -> None:
    rng = random.Random(SEED)

    rows = []
    for i in range(n):
        # Demographics. Rural and lower-income respondents are deliberately
        # over-represented relative to a census, as inclusion surveys are.
        gender = rng.choices(["female", "male"], weights=[0.51, 0.49])[0]
        quintile = rng.choices([1, 2, 3, 4, 5], weights=[26, 23, 20, 17, 14])[0]
        urban_rural = rng.choices(["urban", "rural"], weights=[0.58, 0.42])[0]
        education = rng.choices(
            ["none", "primary", "secondary", "tertiary"],
            weights=[0.10, 0.28, 0.44, 0.18],
        )[0]

        # Account ownership rises with income, urban residence, and education,
        # and carries a gender penalty. Coefficients chosen so the national
        # rate lands near 73%, with roughly a 12-point gender gap and a
        # 44-point education gap --- large enough that the headline number
        # is visibly misleading on its own, which is the point of Part A.
        odds = -0.55
        odds += 0.62 * quintile
        odds += 0.85 if urban_rural == "urban" else 0.0
        odds += {"none": -1.5, "primary": -0.5, "secondary": 0.4, "tertiary": 1.3}[education]
        odds += -0.75 if gender == "female" else 0.0

        p_account = 1 / (1 + math.exp(-odds))
        has_account = rng.random() < p_account

        # Usage, conditional on having an account. Dormancy is the point of
        # the access-versus-usage distinction in Part B.
        if has_account:
            activity = 0.30 + 0.11 * quintile + (0.10 if urban_rural == "urban" else 0)
            transactions = rng.choices(
                [0, 1, 2, 5, 12, 30], weights=[
                    max(0.05, 0.42 - activity), 0.13, 0.12, 0.16, 0.11, 0.06
                ]
            )[0]
            uses_credit = rng.random() < (0.05 + 0.07 * quintile)
            uses_savings = rng.random() < (0.10 + 0.09 * quintile)
        else:
            transactions, uses_credit, uses_savings = 0, False, False

        # Barriers are asked only of the unbanked. Multiple may be reported.
        if not has_account:
            cost = rng.random() < 0.58
            distance = rng.random() < (0.46 if urban_rural == "rural" else 0.14)
            documentation = rng.random() < 0.39
            trust = rng.random() < 0.27
            no_credit_history = rng.random() < 0.51
        else:
            cost = distance = documentation = trust = no_credit_history = False

        # Alternative-data reachability, used in Part D.
        has_mobile_money = rng.random() < (0.30 + 0.09 * quintile)
        has_utility_account = rng.random() < (
            0.20 + 0.10 * quintile + (0.22 if urban_rural == "urban" else 0)
        )

        rows.append([
            f"R{i:06d}", gender, quintile, urban_rural, education,
            int(has_account), transactions, int(uses_credit), int(uses_savings),
            int(cost), int(distance), int(documentation), int(trust),
            int(no_credit_history), int(has_mobile_money), int(has_utility_account),
        ])

    _write(
        ROOT / "Lab02" / "findex_sample.csv",
        ["respondent_id", "gender", "income_quintile", "urban_rural", "education",
         "has_account", "transactions_90d", "uses_credit", "uses_savings",
         "cost", "distance", "documentation", "trust", "no_credit_history",
         "has_mobile_money", "has_utility_account"],
        rows,
    )


# --------------------------------------------------------------------------
# Lab 3 --- P2P loan book
# --------------------------------------------------------------------------

def loan_book(n: int = 8_000) -> None:
    rng = random.Random(SEED + 1)

    # Grade -> (coupon, annual default probability, mean recovery).
    # Calibrated to published UK/US marketplace-lending disclosures.
    grades = {
        "A": (0.055, 0.018, 0.35),
        "B": (0.079, 0.041, 0.30),
        "C": (0.112, 0.082, 0.25),
        "D": (0.150, 0.140, 0.20),
        "E": (0.196, 0.225, 0.15),
    }
    weights = [0.22, 0.28, 0.24, 0.17, 0.09]

    rows = []
    for i in range(n):
        grade = rng.choices(list(grades), weights=weights)[0]
        coupon, pd_rate, mean_recovery = grades[grade]

        # Jitter the coupon slightly so each grade is a band, not a point.
        rate = round(max(0.01, rng.gauss(coupon, 0.006)), 4)
        defaulted = rng.random() < pd_rate

        # Recovery is only meaningful for defaulted loans; clamp to [0, 1].
        recovery = round(min(1.0, max(0.0, rng.gauss(mean_recovery, 0.10))), 4) \
            if defaulted else 0.0

        amount = rng.choice([500, 1000, 2500, 5000, 7500, 10000])
        term = rng.choice([12, 24, 36, 60])

        rows.append([f"L{i:06d}", grade, amount, term, rate,
                     int(defaulted), recovery])

    _write(
        ROOT / "Lab03" / "loans.csv",
        ["loan_id", "grade", "amount", "term_months", "interest_rate",
         "defaulted", "recovery_rate"],
        rows,
    )


# --------------------------------------------------------------------------
# Lab 4 --- onboarding funnel events
# --------------------------------------------------------------------------

def onboarding_events(users: int = 50_000) -> None:
    rng = random.Random(SEED + 2)

    STEPS = ["app_open", "signup_start", "id_upload", "id_verified",
             "address_entered", "account_funded", "first_payment"]

    # Base step-to-step conversion. id_verified is the deliberate bottleneck
    # so the lab has a clear finding, and it is concentrated on old_android.
    base = {"app_open": 1.00, "signup_start": 0.72, "id_upload": 0.88,
            "id_verified": 0.61, "address_entered": 0.94,
            "account_funded": 0.79, "first_payment": 0.91}

    rows = []
    for u in range(users):
        device = rng.choices(
            ["ios", "new_android", "old_android"], weights=[0.44, 0.38, 0.18]
        )[0]
        hour = rng.choices(range(24), weights=[
            1, 1, 1, 1, 1, 2, 4, 6, 7, 8, 8, 7, 7, 7, 7, 7, 7, 8, 9, 9, 8, 6, 4, 2
        ])[0]

        for step in STEPS:
            p = base[step]

            # The verification failure is overwhelmingly an old-handset
            # camera problem, not an interface problem. Segmenting by
            # device is what reveals this.
            if step == "id_verified" and device == "old_android":
                p = 0.24
            elif step == "id_verified" and device == "new_android":
                p = 0.66

            if rng.random() > p:
                break
            rows.append([f"U{u:06d}", step, device, hour])

    _write(
        ROOT / "Lab04" / "onboarding_events.csv",
        ["user_id", "step", "device_type", "hour_of_day"],
        rows,
    )


# --------------------------------------------------------------------------
# Lab 8 --- price series
# --------------------------------------------------------------------------

def price_series(days: int = 1_460) -> None:
    rng = random.Random(SEED + 3)

    # Daily volatility chosen so annualised sigma * sqrt(365) lands near
    # 72% for crypto and 9% for the fiat pair.
    series = {
        "crypto_usd": {"price": 8_000.0, "daily_vol": 0.0377, "drift": 0.0011},
        "fiat_eurusd": {"price": 1.10, "daily_vol": 0.0047, "drift": 0.0000},
        "equity_index": {"price": 3_200.0, "daily_vol": 0.0095, "drift": 0.0003},
    }

    rows = []
    start_year, start_month, start_day = 2021, 1, 1
    for d in range(days):
        # Simple date arithmetic; avoids a datetime import for clarity.
        y, m, day_of_month = start_year, start_month, start_day + d
        for length in [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] * 8:
            if day_of_month <= length:
                break
            day_of_month -= length
            m += 1
            if m > 12:
                m, y = 1, y + 1

        row = [f"{y:04d}-{m:02d}-{day_of_month:02d}"]
        for name, state in series.items():
            shock = rng.gauss(state["drift"], state["daily_vol"])
            state["price"] *= math.exp(shock)
            row.append(round(state["price"], 6))
        rows.append(row)

    _write(
        ROOT / "Lab08" / "price_series.csv",
        ["date", "crypto_usd", "fiat_eurusd", "equity_index"],
        rows,
    )


if __name__ == "__main__":
    print(f"Generating synthetic FinTech datasets (seed={SEED})\n")
    findex_sample()
    loan_book()
    onboarding_events()
    price_series()
    print("\nDone. All data is synthetic --- do not quote as real observations.")
