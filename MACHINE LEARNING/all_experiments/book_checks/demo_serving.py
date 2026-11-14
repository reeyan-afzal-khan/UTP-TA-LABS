"""Serving a model and watching it afterwards: the worked numbers of Chapter 33.

The booking-cancellation model of Chapter 32 is put behind a small web service, timed, and then
followed through five months of real bookings that arrived after it was trained: April to August 2017.
The script measures how the inputs move, how the model's answers hold up once the outcomes are known,
whether a second model would have done better, and what retraining every month buys.

Run from the course folder:      python all_experiments/book_checks/demo_serving.py
It reads all_datasets/supervised/hotel_bookings/ and takes about a minute.
"""
import io
import json
import os
import sys
import tempfile
import time
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import brier_score_loss, roc_auc_score

PROJECT = Path(__file__).resolve().parents[1] / "lab10_end_to_end_project" / "booking_project"
sys.path.insert(0, str(PROJECT))
from bookings import CONTRACT, FEATURES, TARGET, cancellation_risk, check_booking, make_challenger, read_bookings
from monitor import monthly_report, psi
from serve import create_app
from train import save, train

FILE = Path(__file__).resolve().parents[2] / "all_datasets" / "supervised/hotel_bookings/hotel_bookings.zip"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
pd.set_option("display.width", 200)
LIVE_MONTHS = pd.period_range("2017-04", "2017-08", freq="M")


def as_request(row):
    """One row of the table as the service would receive it: plain Python values, blanks as None."""
    return json.loads(row[list(CONTRACT)].to_json())


def size_in_kb(model):
    buffer = io.BytesIO()
    joblib.dump(model, buffer)
    return len(buffer.getvalue()) / 1024


def main():
    f = FOUND
    bookings = read_bookings(FILE)
    month = bookings["arrival_date"].dt.to_period("M")
    development = bookings[bookings["arrival_date"] < "2017-01-01"]
    test = bookings[(bookings["arrival_date"] >= "2017-01-01") & (bookings["arrival_date"] < "2017-04-01")]

    champion, facts = train(bookings, "2017-01-01")
    challenger, _ = train(bookings, "2017-01-01", make=make_challenger)
    f["gate"] = {key: facts[key] for key in ["version", "gate_bookings", "gate_auc", "gate_expected", "gate_cancelled"]}
    print("the champion's card, in part:", f["gate"])

    # 1. One booking in, one probability out.
    booking = as_request(test.iloc[0])
    f["booking"] = booking
    f["risk"] = round(float(cancellation_risk(champion, [booking])[0]), 4)
    print("\none booking, as the service receives it:\n   ", json.dumps(booking))
    print("its chance of cancelling:", f["risk"])
    broken = {**booking, "lead_time": -3, "deposit_type": "Maybe", "nights": 2}
    del broken["adr"]
    f["problems"] = check_booking(broken)
    print("the same booking after four mistakes:")
    for line in f["problems"]:
        print("   ", line)

    # 2. Speed and size.
    started = time.perf_counter()
    for _ in range(200):
        cancellation_risk(champion, [booking])
    one_at_a_time = (time.perf_counter() - started) / 200
    started = time.perf_counter()
    champion.predict_proba(test[FEATURES])
    all_at_once = (time.perf_counter() - started) / len(test)
    f["speed"] = (one_at_a_time, all_at_once)
    f["size"] = (round(size_in_kb(champion)), round(size_in_kb(challenger)))
    print(f"\none booking at a time: {1000 * one_at_a_time:.1f} milliseconds each; {len(test):,} bookings in one call: "
          f"{1e6 * all_at_once:.0f} microseconds each, {one_at_a_time / all_at_once:,.0f} times faster")
    print(f"saved size: champion {f['size'][0]} KB, challenger {f['size'][1]} KB")

    # 3. The service, exercised through Flask's test client: no server has to be started.
    with tempfile.TemporaryDirectory() as folder:
        log_path = Path(folder) / "predictions.log"
        client = create_app(champion, facts["version"], log_path=log_path).test_client()
        health = client.get("/health")
        good = client.post("/predict", json=booking)
        bad = client.post("/predict", json=broken)
        junk = client.post("/predict", data="hello")
        logged = [json.loads(line) for line in log_path.read_text(encoding="utf-8").splitlines()]
    f["service"] = {"health": (health.status_code, health.get_json()), "good": (good.status_code, good.get_json()),
                    "bad": (bad.status_code, bad.get_json()), "junk": (junk.status_code, junk.get_json()),
                    "logged": (len(logged), sorted(logged[0]))}
    print("\nGET /health            ->", *f["service"]["health"])
    print("POST /predict (good)   ->", *f["service"]["good"])
    print("POST /predict (broken) ->", f["service"]["bad"][0], f["service"]["bad"][1]["error"],
          f"({len(f['service']['bad'][1]['problems'])} problems listed)")
    print("POST /predict (text)   ->", *f["service"]["junk"])
    print("lines in the prediction log:", f["service"]["logged"][0], " fields of a line:", f["service"]["logged"][1])

    # 4. Five months of live bookings, month by month.
    report = monthly_report(champion, bookings, LIVE_MONTHS, development)
    f["report"] = report
    shown = report.assign(expected=report["expected"].round().astype(int))
    print("\nthe champion, frozen, month by month:")
    print(shown.round({"new_agent_share": 3, "psi_lead_time": 2, "psi_market_segment": 2, "psi_deposit_type": 2,
                       "psi_risk": 2, "auc": 3, "brier": 4}).to_string())
    short = report["cancelled"] - report["expected"]
    f["short"] = (short.round().astype(int).tolist(), (short / report["cancelled"]).round(3).tolist())
    print("cancellations the forecast missed, and as a share:", f["short"])
    alarms = {name: [column[4:] for column in report.columns if column.startswith("psi_") and row[column] > 0.25]
              for name, row in report.iterrows()}
    f["alarms"] = alarms
    print("signals above 0.25:", alarms)

    # What changed in the bookings themselves.
    def mix(table):
        return {"non_refund": round(float((table["deposit_type"] == "Non Refund").mean()), 3),
                "online_agent": round(float((table["market_segment"] == "Online TA").mean()), 3),
                "groups": round(float((table["market_segment"] == "Groups").mean()), 3),
                "median_lead_time": float(table["lead_time"].median()), "median_price": round(float(table["adr"].median()), 1)}
    shown_months = ["2016-07", "2016-08"] + [str(name) for name in LIVE_MONTHS]
    f["mix"] = {"development": mix(development), **{name: mix(bookings[month == name]) for name in shown_months}}
    print("the mix of bookings:")
    print(pd.DataFrame(f["mix"]).T.to_string())
    f["price_rise"] = tuple(round(f["mix"][f"2017-{m}"]["median_price"] / f["mix"][f"2016-{m}"]["median_price"] - 1, 3)
                            for m in ("07", "08"))
    print("median price, July and August 2017 against a year earlier:", f["price_rise"])

    # 5. A seasonal column sounds the alarm every summer: compare with the same month a year earlier.
    f["season"] = {}
    for name in ["2017-07", "2017-08"]:
        now, year_ago = bookings[month == name], bookings[month == pd.Period(name) - 12]
        f["season"][name] = {column: (round(psi(development[column], now[column]), 2), round(psi(year_ago[column], now[column]), 2))
                             for column in ["adr", "lead_time", "deposit_type", "market_segment"]}
    print("\nPSI against (all of development, the same month a year earlier):")
    for name, values in f["season"].items():
        print("   ", name, values)

    # The inputs look like last summer's. Do the outcomes? Each month scored by a model trained on all earlier ones.
    f["summers"] = {}
    for name in ["2016-07", "2016-08", "2017-07", "2017-08"]:
        current = bookings[month == name]
        model, _ = train(bookings, pd.Period(name).start_time)
        risk = model.predict_proba(current[FEATURES])[:, 1]
        no_deposit = (current["deposit_type"] == "No Deposit").to_numpy()
        f["summers"][name] = {"auc": round(float(roc_auc_score(current[TARGET], risk)), 3),
                              "no_deposit_share": round(float(no_deposit.mean()), 3),
                              "cancelled_without_deposit": round(float(current.loc[no_deposit, TARGET].mean()), 3),
                              "auc_without_deposit": round(float(roc_auc_score(current.loc[no_deposit, TARGET],
                                                                               risk[no_deposit])), 3)}
    print("two summers, each month scored by a model trained on every earlier booking:")
    print(pd.DataFrame(f["summers"]).T.to_string())

    # 6. The challenger, running beside the champion on the same bookings.
    side = []
    for name in LIVE_MONTHS:
        current = bookings[month == name]
        row = {"month": str(name)}
        for label, model in [("champion", champion), ("challenger", challenger)]:
            risk = model.predict_proba(current[FEATURES])[:, 1]
            row[f"{label}_auc"] = roc_auc_score(current[TARGET], risk)
            row[f"{label}_expected"] = risk.sum()
        row["cancelled"] = int(current[TARGET].sum())
        side.append(row)
    f["side"] = pd.DataFrame(side).set_index("month")
    f["lead"] = (f["side"]["challenger_auc"] - f["side"]["champion_auc"]).round(3).tolist()
    print("\nthe challenger's lead in AUC, month by month:", f["lead"])
    print("champion and challenger, both frozen:")
    print(f["side"].round({"champion_auc": 3, "challenger_auc": 3, "champion_expected": 0, "challenger_expected": 0}).to_string())

    # 7. Retraining on the first day of every month, with every booking that has arrived by then.
    again = []
    for name in LIVE_MONTHS:
        current = bookings[month == name]
        row = {"month": str(name), "cancelled": int(current[TARGET].sum())}
        for label, make in [("champion", None), ("challenger", make_challenger)]:
            model, card = train(bookings, name.start_time) if make is None else train(bookings, name.start_time, make=make)
            risk = model.predict_proba(current[FEATURES])[:, 1]
            row[f"{label}_auc"] = roc_auc_score(current[TARGET], risk)
            row[f"{label}_expected"] = risk.sum()
            row[f"{label}_brier"] = brier_score_loss(current[TARGET], risk)
            row[f"{label}_gate"] = card["gate_auc"]
        again.append(row)
    f["again"] = pd.DataFrame(again).set_index("month")
    print("\nboth models, retrained every month:")
    print(f["again"].round({"champion_auc": 3, "challenger_auc": 3, "champion_expected": 0, "challenger_expected": 0,
                            "champion_brier": 4, "challenger_brier": 4}).to_string())
    totals = {"cancelled": int(f["side"]["cancelled"].sum()),
              "champion frozen": int(round(f["side"]["champion_expected"].sum())),
              "champion retrained": int(round(f["again"]["champion_expected"].sum())),
              "challenger frozen": int(round(f["side"]["challenger_expected"].sum())),
              "challenger retrained": int(round(f["again"]["challenger_expected"].sum()))}
    f["totals"] = totals
    print("cancellations over the five months, actual and expected:", totals)
    policies = {}
    for label, table, column in [("champion, frozen", f["side"], "champion"), ("champion, retrained monthly", f["again"], "champion"),
                                 ("challenger, frozen", f["side"], "challenger"),
                                 ("challenger, retrained monthly", f["again"], "challenger")]:
        expected = table[f"{column}_expected"].sum()
        policies[label] = {"mean_auc": round(float(table[f"{column}_auc"].mean()), 3),
                           "months_ahead_of_champion_frozen": int((table[f"{column}_auc"] > f["side"]["champion_auc"]).sum()),
                           "expected": int(round(expected)),
                           "shortfall": round(float(1 - expected / totals["cancelled"]), 3)}
    f["policies"] = pd.DataFrame(policies).T
    print("four policies over the five months:")
    print(f["policies"].to_string())
    f["retraining_helped_every_month"] = all(
        bool((f["again"][f"{who}_auc"] > f["side"][f"{who}_auc"]).all()) for who in ("champion", "challenger"))
    print("retraining raised the AUC of both models in every month:", f["retraining_helped_every_month"])

    # 8. One PSI by hand: the deposit type, development against August 2017.
    then = development["deposit_type"].value_counts(normalize=True).sort_index()
    now = bookings.loc[month == "2017-08", "deposit_type"].value_counts(normalize=True).reindex(then.index, fill_value=0)
    terms = (now - then) * np.log(now / then)
    f["by_hand"] = pd.DataFrame({"then": then, "now": now, "term": terms}).round(4)
    print("\nthe PSI of the deposit type in August 2017, term by term:")
    print(f["by_hand"].to_string(), "\nsum:", round(float(terms.sum()), 2))

    # 9. The one-page app, run without a browser (skipped when Streamlit is not installed).
    try:
        from streamlit.testing.v1 import AppTest
    except ImportError:
        AppTest = None
    if AppTest is not None:
        with tempfile.TemporaryDirectory() as folder:
            save(champion, facts, folder, folder)
            os.environ["MODEL_PATH"] = str(Path(folder) / "booking_cancellation.joblib")
            page = AppTest.from_file(str(PROJECT / "app.py"), default_timeout=120).run()
            as_filled = page.metric[0].value
            page.selectbox(key="deposit_type").select("Non Refund").run()
            non_refundable = page.metric[0].value
            del os.environ["MODEL_PATH"]
        f["page"] = (as_filled, non_refundable, len(page.exception), len(page.error))
        print(f"\nthe app with its starting values: {as_filled}; with a non-refundable deposit: {non_refundable}; "
              f"errors raised: {len(page.exception)}")

    if not CHECK_BOOK_NUMBERS:
        return
    assert f["gate"] == {"version": "2017-01-01", "gate_bookings": 14517, "gate_auc": 0.8549, "gate_expected": 4585,
                         "gate_cancelled": 5548}
    assert f["risk"] == 0.2233 and (f["booking"]["hotel"], f["booking"]["lead_time"], f["booking"]["adr"]) == ("Resort Hotel", 74, 57.6)
    assert f["problems"] == ["lead_time: -3 is outside 0 to 800",
                             "deposit_type: 'Maybe' is not one of ['No Deposit', 'Non Refund', 'Refundable']",
                             "adr: missing", "unknown fields: ['nights']"]
    one, many = f["speed"]                    # timings differ from machine to machine: only their order is checked
    assert one < 0.2 and many * 100 < one
    assert f["size"][0] <= 20 and 200 <= f["size"][1] <= 600
    service = f["service"]
    assert service["health"] == (200, {"model_version": "2017-01-01", "status": "ok"})
    assert service["good"] == (200, {"cancel_probability": 0.2233, "model_version": "2017-01-01"})
    assert service["bad"][0] == 400 and service["bad"][1]["problems"] == f["problems"]
    assert service["junk"] == (400, {"error": "send one booking as a JSON object"})
    assert service["logged"] == (1, ["booking", "milliseconds", "model_version", "risk", "time"])
    report = f["report"]
    assert report["bookings"].tolist() == [5661, 6313, 5647, 5313, 4925]
    assert report["new_agent_share"].round(3).tolist() == [0.057, 0.054, 0.059, 0.056, 0.041]
    assert report["psi_lead_time"].round(2).tolist() == [0.21, 0.16, 0.23, 0.31, 0.23]
    assert report["psi_market_segment"].round(2).tolist() == [0.07, 0.07, 0.07, 0.35, 0.43]
    assert report["psi_deposit_type"].round(2).tolist() == [0.0, 0.0, 0.01, 0.16, 0.28]
    assert report["psi_risk"].round(2).tolist() == [0.09, 0.06, 0.05, 0.2, 0.34]
    assert report["expected"].round().astype(int).tolist() == [2313, 2542, 2281, 1824, 1565]
    assert report["cancelled"].tolist() == [2463, 2762, 2439, 1984, 1816]
    assert report["auc"].round(3).tolist() == [0.863, 0.854, 0.834, 0.779, 0.808]
    assert f["alarms"] == {"2017-04": [], "2017-05": [], "2017-06": [], "2017-07": ["lead_time", "market_segment"],
                           "2017-08": ["market_segment", "deposit_type", "risk"]}
    assert f["mix"]["development"] == {"non_refund": 0.133, "online_agent": 0.43, "groups": 0.177, "median_lead_time": 65.0,
                                       "median_price": 89.0}
    assert f["mix"]["2017-07"] == {"non_refund": 0.031, "online_agent": 0.656, "groups": 0.046, "median_lead_time": 148.0,
                                   "median_price": 132.5}
    assert f["mix"]["2017-08"]["non_refund"] == 0.014 and f["mix"]["2017-08"]["median_price"] == 155.0
    assert f["season"] == {"2017-07": {"adr": (1.51, 0.24), "lead_time": (0.31, 0.11), "deposit_type": (0.16, 0.03),
                                       "market_segment": (0.35, 0.03)},
                           "2017-08": {"adr": (2.04, 0.2), "lead_time": (0.23, 0.03), "deposit_type": (0.28, 0.05),
                                       "market_segment": (0.43, 0.01)}}
    summers = {name: tuple(values.values()) for name, values in f["summers"].items()}
    assert summers == {"2016-07": (0.857, 0.939, 0.285, 0.826), "2016-08": (0.846, 0.948, 0.327, 0.823),
                       "2017-07": (0.797, 0.967, 0.353, 0.780), "2017-08": (0.819, 0.985, 0.359, 0.812)}, summers
    mixes = {name: tuple(values.values()) for name, values in f["mix"].items()}
    assert mixes["2016-07"] == (0.061, 0.596, 0.062, 118.0, 115.3) and mixes["2016-08"] == (0.052, 0.667, 0.047, 116.0, 131.4)
    assert mixes["2017-08"] == (0.014, 0.66, 0.035, 128.0, 155.0)
    policies = f["policies"]
    assert policies["mean_auc"].tolist() == [0.827, 0.837, 0.838, 0.85]
    assert policies["months_ahead_of_champion_frozen"].tolist() == [0, 5, 5, 5]
    assert policies["expected"].tolist() == [10526, 10876, 10655, 10949]
    assert policies["shortfall"].tolist() == [0.082, 0.051, 0.071, 0.045]
    side, again = f["side"], f["again"]
    assert side["champion_auc"].round(3).tolist() == [0.863, 0.854, 0.834, 0.779, 0.808]
    assert side["challenger_auc"].round(3).tolist() == [0.87, 0.862, 0.84, 0.803, 0.814]
    assert again["champion_auc"].round(3).tolist() == [0.868, 0.859, 0.839, 0.797, 0.819]
    assert again["challenger_auc"].round(3).tolist() == [0.876, 0.867, 0.85, 0.824, 0.834]
    assert again["champion_expected"].round().astype(int).tolist() == [2307, 2561, 2373, 1960, 1675]
    assert again["champion_gate"].tolist() == [0.8553, 0.8603, 0.8593, 0.8535, 0.8393]
    assert again["challenger_gate"].tolist() == [0.8736, 0.8744, 0.8716, 0.8594, 0.8472]
    assert f["totals"] == {"cancelled": 11464, "champion frozen": 10526, "champion retrained": 10876,
                           "challenger frozen": 10655, "challenger retrained": 10949}
    assert f["short"] == ([150, 220, 158, 160, 251], [0.061, 0.08, 0.065, 0.081, 0.138])
    assert f["price_rise"] == (0.149, 0.18) and f["lead"] == [0.006, 0.008, 0.006, 0.024, 0.006]
    assert f["retraining_helped_every_month"]
    by_hand = f["by_hand"]
    assert by_hand["then"].tolist() == [0.8654, 0.1329, 0.0017] and by_hand["now"].tolist() == [0.9854, 0.014, 0.0006]
    assert by_hand["term"].tolist() == [0.0156, 0.2675, 0.0011]
    if "page" in f:
        assert f["page"] == ("46%", "99%", 0, 0), f["page"]
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
