"""Lab 10: The end-to-end project.

The code cells of lab10_end_to_end_project_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab10_end_to_end_project/lab10_end_to_end_project_worked.py
It writes the same figures and tables as the notebook, to results/lab10/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The project of Chapters 32 and 33, in booking_project/: imported like any library.
sys.path.insert(0, "booking_project")
import bookings as project                   # the contract, the features and the models
from monitor import monthly_report, psi      # drift and monthly reports
from serve import create_app                 # the web service
from train import train                      # fit on every booking before a date, with a gate

# 3. The other libraries this lab uses.
import json
import subprocess                            # run a command, as you would in a terminal
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import brier_score_loss, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score

# 4. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab10")

# %% Question 2 - Read the bookings in date order
FILE = DATA / "supervised/hotel_bookings/hotel_bookings.zip"
bookings = project.read_bookings(FILE)
y = bookings["is_canceled"]
print(f"{len(bookings):,} bookings arriving from {bookings['arrival_date'].min():%d %B %Y}"
      f" to {bookings['arrival_date'].max():%d %B %Y}")

quarter = bookings["arrival_date"].dt.to_period("Q")
month = bookings["arrival_date"].dt.to_period("M")
by_quarter = bookings.groupby(quarter)["is_canceled"].agg(bookings="size", cancelled="mean")
print(pd.DataFrame({"bookings": by_quarter["bookings"].map("{:,}".format),
                    "cancelled": by_quarter["cancelled"].map("{:.1%}".format)}).T.to_string())

monthly_rate = bookings.groupby(month)["is_canceled"].mean()
fig, ax = plt.subplots(figsize=(9, 3.2))
ax.plot(monthly_rate.index.to_timestamp(), monthly_rate.to_numpy(), marker="o", markersize=3)
start, test_end, live_end = (pd.Timestamp(day) for day in ["2017-01-01", "2017-04-01", "2017-09-01"])
ax.axvspan(start, test_end, color="orange", alpha=0.15, label="test")
ax.axvspan(test_end, live_end, color="green", alpha=0.12, label="live")
ax.set_ylabel("Share cancelled")
ax.set_title("Cancellations by month of arrival")
ax.legend(loc="lower right")
plt.tight_layout()
plt.savefig(RESULTS / "cancellations_by_month_of_arrival.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 3 - Check the file against the contract
raw = pd.read_csv(FILE)
problems = project.validate(raw)
for line in problems:
    print(line)

big = raw[raw["adults"] > 10]
months_of_arrival = sorted(set(big["arrival_date_month"] + " " + big["arrival_date_year"].astype(str)))
print(f"\nmore than 10 adults: {len(big)} bookings at {big['hotel'].unique().tolist()},"
      f" arriving {months_of_arrival}")
print(f"    {big['adults'].min()} to {big['adults'].max()} adults each,"
      f" prices {big['adr'].unique().tolist()}, {big['is_canceled'].mean():.0%} cancelled")
print("prices outside 0 to 1,000:", raw.loc[~raw["adr"].between(0, 1000), "adr"].tolist(),
      "  highest price below 1,000:", raw.loc[raw["adr"] < 1000, "adr"].max())
print("bookings marked Undefined:", int((raw["market_segment"] == "Undefined").sum()), "segment,",
      int((raw["distribution_channel"] == "Undefined").sum()), "channel")
guests = raw["adults"] + raw["children"].fillna(0) + raw["babies"]
print("bookings with no guests at all:", int((guests == 0).sum()))

# %% Question 4 - Break an export on purpose, then check one booking
damaged = raw.drop(columns=["deposit_type"]).assign(
    lead_time=raw["lead_time"] * 24,                                  # hours instead of days
    meal=raw["meal"].replace({"BB": "Bed & Breakfast"}),              # a new spelling
)
for line in project.validate(damaged):
    if line not in problems:
        print("new:", line)

booking = json.loads(bookings.loc[1000, list(project.CONTRACT)].to_json())
print("\none booking:", booking)
print("its problems:", project.check_booking(booking))
print("with two mistakes:", project.check_booking({**booking, "adults": "two", "hotel": "Beach Hotel"}))

# %% Question 5 - Find the columns that are written too late
print(pd.crosstab(bookings["reservation_status"], y))
room_changed = bookings["assigned_room_type"] != bookings["reserved_room_type"]
share = y.groupby(room_changed).mean().round(3)
print("\nshare cancelled, same room:", share[False], "  room changed:", share[True])
print("written too late:", project.WRITTEN_LATER)
print("any of them among the features?", set(project.WRITTEN_LATER) & set(project.FEATURES) or "none")

# %% Question 6 - Cut three periods and four forward folds
development = (bookings["arrival_date"] < "2017-01-01").to_numpy()
test = ((bookings["arrival_date"] >= "2017-01-01") & (bookings["arrival_date"] < "2017-04-01")).to_numpy()
live = (bookings["arrival_date"] >= "2017-04-01").to_numpy()
for name, rows in [("development", development), ("test", test), ("live", live)]:
    print(f"{name:12s} {rows.sum():6,d} bookings, {y[rows].mean():.1%} cancelled")

folds = [(str(q), (quarter < q).to_numpy(), (quarter == q).to_numpy())
         for q in sorted(quarter[development].unique())[2:]]
for name, past, next_quarter in folds:
    print(f"fold {name}: train on {past.sum():,} earlier bookings, validate on {next_quarter.sum():,}")

def forward(make_model, columns=project.FEATURES):
    """Fit on the past and score the next quarter, fold by fold."""
    rows = []
    for name, past, next_quarter in folds:
        model = make_model().fit(bookings.loc[past, columns], y[past])
        risk = model.predict_proba(bookings.loc[next_quarter, columns])[:, 1]
        rows.append({"quarter": name, "auc": roc_auc_score(y[next_quarter], risk),
                     "brier": brier_score_loss(y[next_quarter], risk),
                     "expected": risk.sum(), "cancelled": int(y[next_quarter].sum())})
    return pd.DataFrame(rows).set_index("quarter")

# %% Question 7 - Random folds against forward folds
def forest():
    model = RandomForestClassifier(n_estimators=200, min_samples_leaf=5, random_state=42, n_jobs=-1)
    return project.with_trees(model)

shuffled = StratifiedKFold(5, shuffle=True, random_state=42)
X_dev, y_dev = bookings.loc[development, project.FEATURES], y[development]
for name, make in [("logistic regression", project.logistic), ("random forest", forest)]:
    random_auc = cross_val_score(make(), X_dev, y_dev, cv=shuffled, scoring="roc_auc").mean()
    forward_auc = forward(make)["auc"]
    print(f"{name:20s} random folds {random_auc:.3f}   forward folds {forward_auc.mean():.3f}"
          f"   by quarter {forward_auc.round(3).tolist()}")

# %% Question 8 - Find the blocks of identical bookings
columns = project.FEATURES + ["is_canceled"]
dev_rows = bookings.loc[development, columns + ["arrival_date"]]
repeats = dev_rows.duplicated(subset=columns)
blocks = (dev_rows.groupby(columns, dropna=False)
          .agg(bookings=("arrival_date", "size"), arrival_days=("arrival_date", "nunique"))
          .sort_values("bookings", ascending=False))
print(f"development bookings that repeat an earlier one: {repeats.sum():,}")
print(f"blocks of 10 or more identical bookings: {(blocks['bookings'] >= 10).sum()},"
      f" holding {blocks.loc[blocks['bookings'] >= 10, 'bookings'].sum():,} bookings")
largest, size = dict(zip(columns, blocks.index[0])), blocks.iloc[0]
print(f"the largest block: {size['bookings']} bookings arriving on {size['arrival_days']} day,"
      f" {largest['hotel']}, {largest['market_segment']}, {largest['deposit_type']},")
print(f"    booked {largest['lead_time']} days ahead at {largest['adr']} euros a night,"
      f" cancelled: {largest['is_canceled']}")

single = dev_rows.loc[~repeats, columns]
random_single = cross_val_score(forest(), single[project.FEATURES], single["is_canceled"], cv=shuffled,
                                scoring="roc_auc").mean()
print(f"random folds on the {len(single):,} bookings left: forest ROC AUC {random_single:.3f}")

# %% Question 9 - Two baselines on the forward folds
keys = ["hotel", "deposit_type", "market_segment"]
count_errors = []
for name, past, next_quarter in folds:
    truth = y[next_quarter]
    rule = (bookings.loc[next_quarter, "deposit_type"] == "Non Refund").to_numpy()
    table = bookings[past].groupby(keys)["is_canceled"].mean().rename("group_rate")
    rate = bookings.loc[next_quarter, keys].join(table, on=keys)["group_rate"].fillna(y[past].mean())
    print(f"{name}: rule AUC {roc_auc_score(truth, rule):.3f}"
          f"   lookup table AUC {roc_auc_score(truth, rate):.3f}"
          f"   expected {rate.sum():,.0f} against {truth.sum():,} cancelled")
    count_errors.append(rate.sum() / truth.sum() - 1)
print(f"mean error of the lookup table's count: {np.mean(count_errors):.1%}")

# %% Question 10 - Keep an experiment log
bookings["arrival_month"] = bookings["arrival_date"].dt.month
bookings["arrival_weekday"] = bookings["arrival_date"].dt.dayofweek
bookings["room_changed"] = room_changed.astype(int)

lab_numbers = project.NUMBERS[:-2]                       # the 16 number columns of Labs 1 and 2
lab_categories = project.CATEGORIES[:5]                  # and their 5 text columns
feature_sets = {
    "1 Labs 1 and 2": (lab_numbers, lab_categories),
    "2 + month, weekday": (lab_numbers + ["arrival_month", "arrival_weekday"], lab_categories),
    "3 + channel, room, repeat, waiting": (project.NUMBERS, lab_categories + ["distribution_channel",
                                                                            "reserved_room_type"]),
    "4 + travel agent (shipped)": (project.NUMBERS, project.CATEGORIES),
    "not allowed: + written later": (lab_numbers + ["booking_changes", "room_changed"],
                                     lab_categories + ["country"]),
}
log = []
for set_name, (numbers, categories) in feature_sets.items():
    for model_name, make in [("logistic", project.logistic), ("boosting", project.boosting)]:
        scores = forward(lambda: make(numbers, categories), numbers + categories)
        log.append({"features": set_name, "model": model_name, "columns": len(numbers) + len(categories),
                    "auc": scores["auc"].mean(), "brier": scores["brier"].mean(),
                    "count_error": (scores["expected"] / scores["cancelled"] - 1).mean()})
log = pd.DataFrame(log)
log.round(4).to_csv(RESULTS / "experiment_log.csv", index=False)
print(log.round(4).to_string(index=False))

# %% Question 11 - Choose between the finalists by a rule
finalists = {"logistic regression": forward(project.make_model),
             "gradient boosting": forward(project.make_challenger)}
for name, scores in finalists.items():
    print(f"{name:20s} by quarter {scores['auc'].round(3).tolist()}   mean {scores['auc'].mean():.4f}"
          f"   spread {scores['auc'].std(ddof=0):.4f}")
gap = finalists["gradient boosting"]["auc"].mean() - finalists["logistic regression"]["auc"].mean()
spread = finalists["gradient boosting"]["auc"].std(ddof=0)
champion_name = "gradient boosting" if gap > spread else "logistic regression"
print(f"gap {gap:.4f} against spread {spread:.4f}: the champion is the {champion_name}")

# %% Question 12 - Open the test quarter once
champion, card = train(bookings, "2017-01-01")
challenger, _ = train(bookings, "2017-01-01", make=project.make_challenger)
truth = y[test]
for name, model in [("champion", champion), ("challenger", challenger)]:
    risk = model.predict_proba(bookings.loc[test, project.FEATURES])[:, 1]
    print(f"{name:10s} ROC AUC {roc_auc_score(truth, risk):.3f}"
          f"   Brier {brier_score_loss(truth, risk):.4f}"
          f"   expected {risk.sum():,.0f} against {truth.sum():,} cancelled")

test_risk = champion.predict_proba(bookings.loc[test, project.FEATURES])[:, 1]
quarter_table = bookings[test].assign(risk=test_risk)

def by_group(column):
    rows = {}
    for value, group in quarter_table.groupby(column):
        if len(group) >= 500:
            rows[value] = {"bookings": len(group), "cancelled": group["is_canceled"].mean(),
                           "predicted": group["risk"].mean(),
                           "auc": roc_auc_score(group["is_canceled"], group["risk"])}
    return pd.DataFrame(rows).T

groups = pd.concat({column: by_group(column) for column in ["deposit_type", "market_segment"]})
print(groups.round(3).to_string())

# %% Question 13 - Check the chances and write the card
tenth = pd.qcut(quarter_table["risk"], 10, labels=False)
calibration = quarter_table.groupby(tenth).agg(predicted=("risk", "mean"),
                                               cancelled=("is_canceled", "mean"))
print(calibration.round(3).T.to_string())

plt.figure(figsize=(4.2, 4))
plt.plot([0, 1], [0, 1], linestyle="--", color="grey")
plt.plot(calibration["predicted"], calibration["cancelled"], marker="o")
plt.xlabel("Mean predicted chance in the group")
plt.ylabel("Share that cancelled")
plt.title("Are the chances right as numbers?")
plt.tight_layout()
plt.savefig(RESULTS / "are_the_chances_right_as_numbers.png", dpi=160, bbox_inches="tight")
plt.show()

full_card = card | {
    "model": "logistic regression (champion)",
    "test_quarter": "January to March 2017, opened once",
    "known_limits": ["weaker on bookings without a deposit",
                     "under-forecasts when the cancellation rate rises",
                     "too optimistic about the safest bookings"],
}
(RESULTS / "model_card.json").write_text(json.dumps(full_card, indent=2), encoding="utf-8")
print({key: full_card[key] for key in ["version", "trained_on", "gate_auc", "known_limits"]})

# %% Question 14 - Train with one command
command = [sys.executable, "booking_project/train.py", "--models", str(MODELS), "--results", str(RESULTS)]
result = subprocess.run(command, capture_output=True, text=True)
for line in result.stderr.splitlines():
    print(line.split(" ", 2)[2])
print("return code:", result.returncode)

saved_card = json.loads((MODELS / "booking_cancellation_card.json").read_text(encoding="utf-8"))
print("card:", {key: saved_card[key] for key in ["version", "trained_on", "gate_auc"]})
print("last line of the run log:", (RESULTS / "runs.csv").read_text().splitlines()[-1].split(",", 1)[1])

# %% Question 15 - Run the tests
command = [sys.executable, "booking_project/test_project.py"]
result = subprocess.run(command, capture_output=True, text=True)
print(result.stdout)
print("return code:", result.returncode)

# %% Question 16 - Send requests to the web service
log_path = RESULTS / "predictions.log"
log_path.unlink(missing_ok=True)                       # start a fresh log on every run
client = create_app(champion, card["version"], log_path=log_path).test_client()

print("health:", client.get("/health").get_json())
for label, sent in [("good booking", booking), ("lead time of -5", {**booking, "lead_time": -5})]:
    reply = client.post("/predict", json=sent)
    print(f"{label}: {reply.status_code} {reply.get_json()}")
reply = client.post("/predict", data="hello")
print(f"not a booking: {reply.status_code} {reply.get_json()}")

logged = [json.loads(line) for line in log_path.read_text(encoding="utf-8").splitlines()]
print("lines in the log:", len(logged), "  fields:", sorted(logged[0]))
print("first line, in part:", {key: logged[0][key] for key in ["model_version", "risk"]})

# %% Question 17 - Use the page made for the front desk
import logging
from streamlit.testing.v1 import AppTest
for name in list(logging.root.manager.loggerDict):     # Streamlit warns that no browser is attached,
    if name.startswith("streamlit"):                   # which is expected here: quieten its loggers
        logging.getLogger(name).setLevel(logging.ERROR)

page = AppTest.from_file("booking_project/app.py", default_timeout=120).run()
print("starting values:", page.metric[0].value)
changes = [("deposit_type", "Non Refund"), ("deposit_type", "No Deposit"), ("market_segment", "Groups"),
           ("market_segment", "Online TA")]
for key, value in changes:
    page.selectbox(key=key).select(value).run()
    print(f"{key} = {value}: {page.metric[0].value}")
for days in [0, 30, 120, 365, 600]:
    page.number_input(key="lead_time").set_value(days).run()
    print(f"lead time of {days} days: {page.metric[0].value}")

# %% Question 18 - The monthly report
live_months = pd.period_range("2017-04", "2017-08", freq="M")
report = monthly_report(champion, bookings, live_months, bookings[development])
first_day = ["bookings", "new_agent_share", "psi_lead_time", "psi_market_segment", "psi_deposit_type",
             "psi_risk"]
after = ["expected", "cancelled", "auc", "brier"]
print("seen on the first day of the month:")
print(report[first_day].round(3).to_string())
print("\nknown after the month:")
print(report[after].round({"expected": 0, "auc": 3, "brier": 4}).to_string())

fig, axes = plt.subplots(1, 2, figsize=(10.5, 3.6))
report.filter(like="psi_").plot(ax=axes[0], marker="o")
axes[0].axhline(0.25, linestyle="--", color="grey")
axes[0].set_title("Drift against the development period")
axes[0].set_ylabel("PSI")
report["auc"].plot(ax=axes[1], marker="o", color="black")
axes[1].set_title("ROC AUC, once the outcomes are in")
plt.tight_layout()
plt.savefig(RESULTS / "five_months_in_service.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 19 - Compare like with like
references = {}
for name in ["2017-07", "2017-08"]:
    now, year_ago = bookings[month == name], bookings[month == pd.Period(name) - 12]
    for column in ["market_segment", "deposit_type", "lead_time", "adr"]:
        references[(name, column)] = {
            "against development": psi(bookings.loc[development, column], now[column]),
            "against a year earlier": psi(year_ago[column], now[column])}
print(pd.DataFrame(references).T.round(2).to_string())

summers = {}
for name in ["2016-07", "2016-08", "2017-07", "2017-08"]:
    current = bookings[month == name]
    model, _ = train(bookings, pd.Period(name).start_time)
    no_deposit = (current["deposit_type"] == "No Deposit").to_numpy()
    risk = model.predict_proba(current[project.FEATURES])[:, 1]
    summers[name] = {"auc": roc_auc_score(current["is_canceled"], risk),
                     "share_without_deposit": no_deposit.mean(),
                     "cancelled_without_deposit": current.loc[no_deposit, "is_canceled"].mean()}
print(pd.DataFrame(summers).T.round(3).to_string())

# %% Question 20 - Measure the call list
calls = 300
call_list = []
for name in live_months:
    current = bookings[(month == name) & (bookings["deposit_type"] == "No Deposit")]
    cancelled = current["is_canceled"].to_numpy()
    row = {"month": str(name), "bookings": len(current), "at_random": cancelled.mean() * calls}
    for label, model in [("champion", champion), ("challenger", challenger)]:
        risk = model.predict_proba(current[project.FEATURES])[:, 1]
        top = np.argsort(risk)[::-1][:calls]
        row[label] = int(cancelled[top].sum())
    furthest = np.argsort(current["lead_time"].to_numpy())[::-1][:calls]
    row["furthest_ahead"] = int(cancelled[furthest].sum())
    call_list.append(row)
call_list = pd.DataFrame(call_list).set_index("month")
print(call_list.round(0).to_string())
print("in total:", call_list[["champion", "challenger", "furthest_ahead"]].sum().to_dict(),
      " at random:", round(call_list["at_random"].sum()))

# %% Question 21 - Retrain on the first day of every month
retraining = []
for name in live_months:
    current = bookings[month == name]
    model, facts = train(bookings, name.start_time)
    accepted = facts["gate_auc"] >= 0.80
    in_service = model if accepted else champion
    risk = in_service.predict_proba(current[project.FEATURES])[:, 1]
    frozen = champion.predict_proba(current[project.FEATURES])[:, 1]
    retraining.append({"month": str(name), "gate": facts["gate_auc"], "accepted": accepted,
                       "cancelled": int(current["is_canceled"].sum()),
                       "frozen": frozen.sum(), "retrained": risk.sum(),
                       "auc_frozen": roc_auc_score(current["is_canceled"], frozen),
                       "auc_retrained": roc_auc_score(current["is_canceled"], risk)})
retraining = pd.DataFrame(retraining).set_index("month")
print(retraining.round({"frozen": 0, "retrained": 0, "auc_frozen": 3, "auc_retrained": 3}).to_string())
totals = retraining[["cancelled", "frozen", "retrained"]].sum()
print("over five months:", totals.round(0).astype(int).to_dict())

# %% Question 22 - Save the evidence
by_quarter.rename_axis("quarter").to_csv(RESULTS / "cancellations_by_quarter.csv")
groups.round(4).to_csv(RESULTS / "test_quarter_by_group.csv")
calibration.round(4).rename_axis("tenth").to_csv(RESULTS / "test_quarter_calibration.csv")
report.round(4).to_csv(RESULTS / "monthly_report.csv")
call_list.round(1).to_csv(RESULTS / "call_list.csv")
retraining.round(4).to_csv(RESULTS / "retraining.csv")
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 23 - Try it yourself
# Your work here

# %% Question 24 - One solution
months = pd.period_range("2017-03", "2017-08", freq="M")
expected, actual = {}, {}
for name in months:
    current = bookings[month == name]
    expected[name] = champion.predict_proba(current[project.FEATURES])[:, 1].sum()
    actual[name] = int(current["is_canceled"].sum())

rows = []
for name in months[1:]:
    ratio = actual[name - 1] / expected[name - 1]                  # known on the first day of the month
    rows.append({"month": str(name), "cancelled": actual[name], "model": expected[name],
                 "ratio_used": ratio, "corrected": expected[name] * ratio})
corrected = pd.DataFrame(rows).set_index("month")
corrected["model_error"] = corrected["model"] / corrected["cancelled"] - 1
corrected["corrected_error"] = corrected["corrected"] / corrected["cancelled"] - 1
print(corrected.round({"model": 0, "ratio_used": 3, "corrected": 0, "model_error": 3,
                       "corrected_error": 3}).to_string())
total = corrected[["cancelled", "model", "corrected"]].sum()
print(f"over five months: {total['cancelled']:,.0f} cancelled, model {total['model']:,.0f}"
      f" ({total['model'] / total['cancelled'] - 1:.1%}), corrected {total['corrected']:,.0f}"
      f" ({total['corrected'] / total['cancelled'] - 1:.1%})")
