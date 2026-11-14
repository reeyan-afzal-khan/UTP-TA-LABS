"""One project from the first question to a tested model: the worked numbers of Chapter 32.

A hotel group wants to know, on the first day of each month, which of the bookings due to arrive that
month will be cancelled. The script walks through the whole project on 119,390 real bookings: a contract
for the data, a validation scheme that matches how the model will be used, baselines, three candidate
models, an experiment log, a small search over settings, one final test, and a model card.

The contract, the features and the models are not defined here. They live in the project itself,
all_experiments/lab10_end_to_end_project/booking_project/bookings.py, which Lab 10 builds on.

Run from the course folder:      python all_experiments/book_checks/demo_project.py
It reads all_datasets/supervised/hotel_bookings/ and takes about a minute and a half.
"""
import sys
from itertools import product
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import brier_score_loss, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score

PROJECT = Path(__file__).resolve().parents[1] / "lab10_end_to_end_project" / "booking_project"
sys.path.insert(0, str(PROJECT))
from bookings import CATEGORIES, NUMBERS, WRITTEN_LATER, boosting, logistic, read_bookings, validate, with_trees

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
FILE = DATA / "supervised/hotel_bookings/hotel_bookings.zip"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
pd.set_option("display.width", 200)

# Five sets of columns, tried in this order. The fourth is the one the project ships.
LAB_NUMBERS = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
               "previous_cancellations", "previous_bookings_not_canceled", "adr", "required_car_parking_spaces",
               "total_of_special_requests", "total_nights", "total_guests", "with_children", "log_lead_time",
               "cancelled_before"]
LAB_CATEGORIES = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]
FEATURE_SETS = {
    "1: the columns of Labs 1 and 2": (LAB_NUMBERS, LAB_CATEGORIES),
    "2: plus the month and weekday of arrival": (LAB_NUMBERS + ["arrival_month", "arrival_weekday"], LAB_CATEGORIES),
    "3: plus channel, room type, repeat guest, waiting list": (
        LAB_NUMBERS + ["is_repeated_guest", "days_in_waiting_list"],
        LAB_CATEGORIES + ["distribution_channel", "reserved_room_type"]),
    "4: plus the travel agent": (NUMBERS, CATEGORIES),
    "not allowed: plus three columns written later": (
        LAB_NUMBERS + ["booking_changes", "room_changed"], LAB_CATEGORIES + ["country"]),
}


def load_bookings():
    """The project's table, plus three columns that only the experiments of this chapter use."""
    bookings = read_bookings(FILE)
    bookings["arrival_month"] = bookings["arrival_date"].dt.month
    bookings["arrival_weekday"] = bookings["arrival_date"].dt.dayofweek
    bookings["room_changed"] = (bookings["assigned_room_type"] != bookings["reserved_room_type"]).astype(int)
    return bookings


def forest(numbers, categories):
    model = RandomForestClassifier(n_estimators=200, min_samples_leaf=5, random_state=42, n_jobs=-1)
    return with_trees(model, numbers, categories)


def forward_folds(bookings, in_development):
    """Four folds in time order: train on everything before a quarter of 2016, validate on that quarter."""
    quarter = bookings["arrival_date"].dt.to_period("Q")
    quarters = sorted(quarter[in_development].unique())[2:]            # the first two quarters only ever train
    return [(str(q), (quarter < q).to_numpy(), (quarter == q).to_numpy()) for q in quarters]


def forward_validation(make_model, bookings, columns, folds):
    """Score a model the way it will be used: fitted on the past, asked about the quarter that follows."""
    y = bookings["is_canceled"]
    rows = []
    for name, past, next_quarter in folds:
        model = make_model().fit(bookings.loc[past, columns], y[past])
        prob = model.predict_proba(bookings.loc[next_quarter, columns])[:, 1]
        rows.append({"quarter": name, "auc": roc_auc_score(y[next_quarter], prob),
                     "brier": brier_score_loss(y[next_quarter], prob),
                     "expected": prob.sum(), "cancelled": int(y[next_quarter].sum())})
    return pd.DataFrame(rows).set_index("quarter")


def main():
    f = FOUND
    bookings = load_bookings()
    y = bookings["is_canceled"]

    # 1. The contract.
    raw = pd.read_csv(FILE)
    f["problems"] = validate(raw)
    print("contract check of the raw file:")
    for line in f["problems"]:
        print("   ", line)
    no_guests = int(((raw["adults"] + raw["children"].fillna(0) + raw["babies"]) == 0).sum())
    f["no_guests"] = no_guests
    print(f"    (not in the contract yet) bookings with no guests at all: {no_guests}")
    # The same check on a damaged export: one column missing, one column in hours instead of days.
    damaged = raw.drop(columns=["deposit_type"]).assign(lead_time=raw["lead_time"] * 24)
    f["damaged"] = [line for line in validate(damaged) if line not in f["problems"]]
    print("new problems in a damaged export:", f["damaged"])

    # 2. Three periods: develop, test once, then live.
    development = (bookings["arrival_date"] < "2017-01-01").to_numpy()
    test = ((bookings["arrival_date"] >= "2017-01-01") & (bookings["arrival_date"] < "2017-04-01")).to_numpy()
    live = (bookings["arrival_date"] >= "2017-04-01").to_numpy()
    f["periods"] = {name: (int(rows.sum()), round(float(y[rows].mean()), 3))
                    for name, rows in [("development", development), ("test", test), ("live", live)]}
    print("\nperiods (bookings, share cancelled):", f["periods"])

    # 3. Two ways to validate. Random folds first, as in the early chapters.
    numbers, categories = FEATURE_SETS["1: the columns of Labs 1 and 2"]
    columns = numbers + categories
    shuffled = StratifiedKFold(5, shuffle=True, random_state=42)
    makers = {"logistic regression": logistic, "random forest": forest, "gradient boosting": boosting}
    f["random_cv"] = {}
    for name, make in makers.items():
        scores = cross_val_score(make(numbers, categories), bookings.loc[development, columns], y[development],
                                 cv=shuffled, scoring="roc_auc")
        f["random_cv"][name] = round(float(scores.mean()), 3)
    print("\nrandom five-fold cross-validation on the development bookings, ROC AUC:", f["random_cv"])

    # Then folds that respect time.
    folds = forward_folds(bookings, development)
    f["fold_sizes"] = {name: (int(past.sum()), int(nxt.sum())) for name, past, nxt in folds}
    print("forward folds (bookings to train on, bookings to validate on):", f["fold_sizes"])
    f["forward"] = {}
    for name, make in makers.items():
        table = forward_validation(lambda: make(numbers, categories), bookings, columns, folds)
        f["forward"][name] = table
        print(f"{name:20s} AUC by quarter {table['auc'].round(3).tolist()}  mean {table['auc'].mean():.3f}"
              f"  Brier {table['brier'].mean():.4f}  expected minus cancelled {(table['expected'] - table['cancelled']).round().tolist()}")

    # Why random folds flatter: rows that are identical in every model column and in the outcome.
    twins = pd.concat([bookings.loc[development, columns], y[development]], axis=1)
    f["repeats"] = int(twins.duplicated().sum())
    single = twins.drop_duplicates()
    scores = cross_val_score(forest(numbers, categories), single[columns], single["is_canceled"], cv=shuffled, scoring="roc_auc")
    f["random_cv_single"] = (len(single), round(float(scores.mean()), 3))
    print(f"development rows that repeat an earlier row in every model column and the outcome: {f['repeats']:,}")
    print(f"random folds on the {len(single):,} rows that remain: forest ROC AUC {scores.mean():.3f}")

    # 4. Baselines, on the same forward folds.
    f["baselines"] = {}
    for name, past, nxt in folds:
        rule = (bookings.loc[nxt, "deposit_type"] == "Non Refund").to_numpy()
        f["baselines"][name] = (round(float(1 - y[nxt].mean()), 3), round(float((rule == (y[nxt] == 1)).mean()), 3),
                                round(float(roc_auc_score(y[nxt], rule)), 3))
    print("\nbaselines by quarter (accuracy of 'nobody cancels', accuracy and AUC of 'non-refundable bookings cancel'):")
    print("   ", f["baselines"])

    # 5. The experiment log: one question at a time, every answer kept.
    log = []
    for feature_set, (numbers_, categories_) in FEATURE_SETS.items():
        for name, make in [("logistic regression", logistic), ("gradient boosting", boosting)]:
            table = forward_validation(lambda: make(numbers_, categories_), bookings, numbers_ + categories_, folds)
            log.append({"features": feature_set, "model": name, "columns": len(numbers_) + len(categories_),
                        "auc": table["auc"].mean(), "spread": table["auc"].std(ddof=0), "brier": table["brier"].mean()})
    f["log"] = pd.DataFrame(log)
    print("\nexperiment log (forward validation):")
    print(f["log"].round(4).to_string(index=False))

    # 6. A small random search over the boosting settings, on the best allowed feature set.
    numbers4, categories4 = FEATURE_SETS["4: plus the travel agent"]
    columns4 = numbers4 + categories4
    names = ["learning_rate", "max_leaf_nodes", "min_samples_leaf", "max_iter"]
    every_setting = list(product([0.03, 0.05, 0.1, 0.2], [15, 31, 63], [20, 50, 100, 200], [100, 200, 400]))
    rng = np.random.default_rng(0)
    search = []
    for pick in rng.choice(len(every_setting), 8, replace=False):          # eight different combinations of 144
        settings = dict(zip(names, every_setting[pick]))
        table = forward_validation(lambda: boosting(numbers4, categories4, **settings), bookings, columns4, folds)
        search.append({**settings, "auc": table["auc"].mean(), "spread": table["auc"].std(ddof=0),
                       "brier": table["brier"].mean(), "by_quarter": table["auc"].round(3).tolist()})
    f["search"] = pd.DataFrame(search).sort_values("auc", ascending=False).reset_index(drop=True)
    print("\neight random settings for gradient boosting, best first:")
    print(f["search"].drop(columns="by_quarter").round(4).to_string(index=False))
    best = f["search"].iloc[0]
    tuned = {"learning_rate": float(best["learning_rate"]), "max_leaf_nodes": int(best["max_leaf_nodes"]),
             "min_samples_leaf": int(best["min_samples_leaf"]), "max_iter": int(best["max_iter"])}
    f["tuned"] = tuned

    # 7. Choose. The rule was fixed before looking: the simpler model wins unless the other one beats it
    #    by more than its own spread between folds.
    simple = forward_validation(lambda: logistic(numbers4, categories4), bookings, columns4, folds)
    gap = best["auc"] - simple["auc"].mean()
    champion = "gradient boosting" if gap > best["spread"] else "logistic regression"
    f["choice"] = {"logistic by quarter": simple["auc"].round(3).tolist(), "boosting by quarter": best["by_quarter"],
                   "gap": round(float(gap), 4), "boosting spread": round(float(best["spread"]), 4), "champion": champion}
    print("\nthe two finalists:", f["choice"])
    f["forecast"] = {quarter_: (int(round(row["expected"])), int(row["cancelled"]),
                                round(float(row["expected"] / row["cancelled"] - 1), 3)) for quarter_, row in simple.iterrows()}
    print("the champion's forecast of the number of cancellations (expected, happened, error):", f["forecast"])

    # 8. Fit both on all the development bookings, and open the test quarter once.
    finalists = {"logistic regression": logistic(numbers4, categories4), "gradient boosting": boosting(numbers4, categories4, **tuned)}
    f["test"] = {}
    for name, model in finalists.items():
        model.fit(bookings.loc[development, columns4], y[development])
        prob = model.predict_proba(bookings.loc[test, columns4])[:, 1]
        f["test"][name] = {"auc": round(float(roc_auc_score(y[test], prob)), 3), "brier": round(float(brier_score_loss(y[test], prob)), 4),
                           "expected": int(round(prob.sum())), "cancelled": int(y[test].sum()), "bookings": int(test.sum())}
        if name == champion:
            quarter = bookings[test].assign(risk=prob)
    print(f"test quarter, January to March 2017, the champion ({champion}):", f["test"][champion])
    challenger = [name for name in finalists if name != champion][0]
    print(f"for the record, the challenger ({challenger}, settings {tuned}):", f["test"][challenger])

    # 9. Where is the skill? The same test bookings, group by group.
    def by_group(column):
        rows = []
        for value, group in quarter.groupby(column):
            if len(group) >= 500:
                rows.append({column: value, "bookings": len(group), "cancelled": group["is_canceled"].mean(),
                             "predicted": group["risk"].mean(), "auc": roc_auc_score(group["is_canceled"], group["risk"])})
        return pd.DataFrame(rows).set_index(column)
    f["groups"] = {column: by_group(column) for column in ["deposit_type", "hotel", "market_segment"]}
    for column, table in f["groups"].items():
        print(table.round(3).to_string())
    tenth = pd.qcut(quarter["risk"], 10, labels=False, duplicates="drop")
    f["calibration"] = quarter.groupby(tenth).agg(predicted=("risk", "mean"), cancelled=("is_canceled", "mean"))
    print("predicted and actual share cancelled, in ten groups from the safest to the riskiest:")
    print(f["calibration"].round(3).T.to_string())

    # 10. The card that travels with the model.
    card = {
        "task": "chance that a hotel booking is cancelled, scored on the first day of its month of arrival",
        "trained_on": f"{f['periods']['development'][0]:,} bookings arriving July 2015 to December 2016",
        "features": columns4,
        "never_use": WRITTEN_LATER,
        "model": champion,
        "validation": "four forward folds by quarter, 2016",
        "test": f["test"][champion],
        "known_limits": "weaker on bookings without a deposit; under-forecasts cancellations when the rate rises",
        "challenger": f"{challenger} {tuned}",
    }
    f["card_keys"] = list(card)
    print("\nmodel card:")
    for key, value in card.items():
        print(f"    {key}: {value}")

    if not CHECK_BOOK_NUMBERS:
        return
    assert f["problems"] == ["adults: 12 values outside 0 to 10", "children: 4 blank cells",
                             "market_segment: unexpected values ['Undefined']",
                             "distribution_channel: unexpected values ['Undefined']", "adr: 2 values outside 0 to 1000"]
    assert f["no_guests"] == 180
    assert f["damaged"] == ["lead_time: 78,666 values outside 0 to 800", "deposit_type: column is missing"]
    assert f["periods"] == {"development": (78703, 0.362), "test": (12828, 0.334), "live": (27859, 0.412)}
    assert f["random_cv"] == {"logistic regression": 0.869, "random forest": 0.927, "gradient boosting": 0.922}
    assert f["fold_sizes"] == {"2016Q1": (21996, 10963), "2016Q2": (32959, 16198), "2016Q3": (49157, 15029),
                               "2016Q4": (64186, 14517)}
    forward = {name: (table["auc"].round(3).tolist(), round(table["auc"].mean(), 3), round(table["brier"].mean(), 4),
                      (table["expected"] - table["cancelled"]).round().astype(int).tolist())
               for name, table in f["forward"].items()}
    assert forward == {
        "logistic regression": ([0.829, 0.859, 0.842, 0.837], 0.842, 0.1426, [-440, -379, -201, -894]),
        "random forest": ([0.819, 0.864, 0.848, 0.844], 0.844, 0.1432, [-719, -469, -426, -935]),
        "gradient boosting": ([0.814, 0.86, 0.842, 0.847], 0.841, 0.1463, [-857, -379, -532, -1000])}, forward
    assert f["repeats"] == 27419 and f["random_cv_single"] == (51284, 0.838)
    assert f["baselines"] == {"2016Q1": (0.693, 0.802, 0.678), "2016Q2": (0.625, 0.779, 0.708),
                              "2016Q3": (0.644, 0.729, 0.619), "2016Q4": (0.618, 0.733, 0.651)}
    log = f["log"]
    assert log["auc"].round(4).tolist() == [0.8419, 0.8409, 0.8407, 0.8236, 0.8395, 0.8443, 0.8565, 0.8544, 0.8841, 0.8812]
    assert log["brier"].round(4).tolist() == [0.1426, 0.1463, 0.1534, 0.1576, 0.1434, 0.1449, 0.1374, 0.1404, 0.1329, 0.1302]
    assert log["columns"].tolist() == [21, 21, 23, 23, 25, 25, 26, 26, 24, 24]
    assert log["spread"].round(4).tolist()[6:8] == [0.0031, 0.012]
    assert f["tuned"] == {"learning_rate": 0.1, "max_leaf_nodes": 31, "min_samples_leaf": 50, "max_iter": 100}
    assert f["search"]["auc"].round(4).tolist() == [0.8585, 0.8583, 0.8576, 0.8575, 0.8558, 0.8544, 0.8488, 0.8476]
    assert f["choice"] == {"logistic by quarter": [0.852, 0.86, 0.859, 0.855], "boosting by quarter": [0.833, 0.874, 0.858, 0.869],
                           "gap": 0.002, "boosting spread": 0.0157, "champion": "logistic regression"}
    assert f["forecast"] == {"2016Q1": (2972, 3371, -0.118), "2016Q2": (5488, 6072, -0.096),
                             "2016Q3": (4962, 5346, -0.072), "2016Q4": (4585, 5548, -0.174)}
    assert f["test"]["logistic regression"] == {"auc": 0.855, "brier": 0.1352, "expected": 4079, "cancelled": 4281,
                                                "bookings": 12828}
    assert f["test"]["gradient boosting"] == {"auc": 0.874, "brier": 0.1295, "expected": 4195, "cancelled": 4281,
                                              "bookings": 12828}
    deposit = f["groups"]["deposit_type"].round(3)
    assert deposit.loc["No Deposit"].tolist() == [11521, 0.259, 0.242, 0.793]
    assert deposit.loc["Non Refund"].tolist() == [1307, 0.995, 0.990, 0.996]
    assert f["groups"]["hotel"]["cancelled"].round(3).tolist() == [0.393, 0.222]
    assert round(float(quarter["risk"].mean()), 3) == 0.318 and round(float(quarter["is_canceled"].mean()), 3) == 0.334
    assert f["groups"]["hotel"]["auc"].round(3).tolist() == [0.854, 0.836]
    assert f["groups"]["hotel"]["predicted"].round(3).tolist() == [0.386, 0.19]
    segment = f["groups"]["market_segment"].round(3)
    assert segment["auc"].to_dict() == {"Corporate": 0.877, "Direct": 0.767, "Groups": 0.881, "Offline TA/TO": 0.912,
                                        "Online TA": 0.801}
    assert segment["bookings"].tolist() == [783, 1594, 2507, 1302, 6545]
    assert f["calibration"]["predicted"].round(3).tolist() == [0.004, 0.039, 0.079, 0.12, 0.185, 0.259, 0.363, 0.481, 0.662, 0.991]
    assert f["calibration"]["cancelled"].round(3).tolist() == [0.018, 0.076, 0.129, 0.147, 0.188, 0.255, 0.331, 0.488, 0.708, 0.999]
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
