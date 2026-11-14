"""The Your-turn tasks of every lab sheet, solved, so their expected findings can be checked.

Try each task yourself first. The lab sheets ask for these in new notebook cells; this file is
the record of how the numbers under "Expected findings" were produced.

Run from the course folder:
    python all_experiments/book_checks/check_your_turn.py            every lab, a few minutes on a CPU
    python all_experiments/book_checks/check_your_turn.py lab03      one lab
Nothing is written to results/ or models/. Each expect() line checks a number the book prints;
network results get a wide tolerance, because they move with the PyTorch version and the device.
"""
from __future__ import annotations

import os
import sys
import warnings
import zipfile
from pathlib import Path

os.environ.setdefault("OMP_NUM_THREADS", "1")            # avoids a known K-means warning on Windows
os.environ.setdefault("KMP_DUPLICATE_LIB_OK", "TRUE")    # as in the notebooks of Labs 7 and 8
warnings.filterwarnings("ignore")

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.compose import ColumnTransformer
from sklearn.decomposition import PCA
from sklearn.ensemble import IsolationForest, RandomForestClassifier, RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression, LogisticRegression, Ridge
from sklearn.metrics import accuracy_score, adjusted_rand_score, average_precision_score, mean_absolute_error, r2_score, roc_auc_score
from sklearn.model_selection import GridSearchCV, GroupShuffleSplit, StratifiedKFold, cross_val_score, train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import Pipeline
from sklearn.semi_supervised import SelfTrainingClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, StandardScaler
from sklearn.svm import SVC

DATA = Path(__file__).resolve().parents[2] / "all_datasets"


def expect(name, value, target, tolerance):
    """Stop if a number has drifted from the one printed on the lab sheet or in a chapter."""
    assert abs(value - target) <= tolerance, f"{name}: got {value}, the book says {target}"



def make_preprocess(num_cols, cat_cols):
    return ColumnTransformer([
        ("num", Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), num_cols),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ])


def lab00():
    print("Lab 0")
    heart = pd.read_csv(DATA / "supervised/heart_disease/heart_disease.csv")
    for column in ["RestingBP", "Cholesterol"]:
        heart[column] = heart[column].replace(0, np.nan)
    target = "HeartDisease"
    numbers = ["Age", "RestingBP", "Cholesterol", "MaxHR", "Oldpeak"]
    categories = ["Sex", "ChestPainType", "FastingBS", "RestingECG", "ExerciseAngina", "ST_Slope"]
    features = numbers + categories
    train, test = train_test_split(heart, test_size=0.2, random_state=42, stratify=heart[target])
    y = train[target]
    folds = StratifiedKFold(5, shuffle=True, random_state=42)

    def make_model(flag_missing):
        number_steps = Pipeline([("impute", SimpleImputer(strategy="median", add_indicator=flag_missing)),
                                 ("scale", StandardScaler())])
        prepare = ColumnTransformer([("num", number_steps, numbers),
                                     ("cat", OneHotEncoder(handle_unknown="ignore"), categories)])
        return Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=2000))])

    # Task 1: drop the patients with no cholesterol reading instead of flagging them.
    kept = train.dropna(subset=["Cholesterol"])
    lost = int(y.sum() - kept[target].sum())
    cv_kept = cross_val_score(make_model(False), kept[features], kept[target], cv=folds, scoring="accuracy").mean()
    dropped = make_model(False).fit(kept[features], kept[target])
    flagged = make_model(True).fit(train[features], y)
    unmeasured = test["Cholesterol"].isna()
    scores = {name: (accuracy_score(test[target], model.predict(test[features])),
                     accuracy_score(test.loc[unmeasured, target], model.predict(test.loc[unmeasured, features])))
              for name, model in [("dropped", dropped), ("flagged", flagged)]}
    print(f"  drop the gaps: {len(kept)} patients left, disease rate {kept[target].mean():.3f}, "
          f"{lost} of {int(y.sum())} patients with the disease discarded; cross-validation {cv_kept:.3f}")
    print(f"  on the test set: dropped {scores['dropped'][0]:.3f}, flagged {scores['flagged'][0]:.3f}; on its "
          f"{int(unmeasured.sum())} unmeasured patients: dropped {scores['dropped'][1]:.3f}, flagged {scores['flagged'][1]:.3f}")
    expect("patients kept", len(kept), 605, 0)
    expect("disease rate of the kept", kept[target].mean(), 0.479, 0.0005)
    expect("disease cases discarded", lost, 116, 0)
    expect("cross-validation on the kept", cv_kept, 0.853, 0.0005)
    expect("test, dropped", scores["dropped"][0], 0.864, 0.0005)
    expect("test, flagged", scores["flagged"][0], 0.897, 0.0005)
    expect("unmeasured test patients, dropped", scores["dropped"][1], 0.721, 0.0005)
    expect("unmeasured test patients, flagged", scores["flagged"][1], 0.860, 0.0005)

    # Task 2: cap blood pressure and cholesterol at their fences.
    capped = train.assign(Cholesterol=train["Cholesterol"].clip(109.5, 377.5), RestingBP=train["RestingBP"].clip(88.5, 172.5))
    as_is = cross_val_score(make_model(True), train[features], y, cv=folds, scoring="accuracy").mean()
    with_caps = cross_val_score(make_model(True), capped[features], y, cv=folds, scoring="accuracy").mean()
    print(f"  cap at the fences: cholesterol skew {train['Cholesterol'].skew():.2f} -> {capped['Cholesterol'].skew():.2f}, "
          f"blood pressure {train['RestingBP'].skew():.2f} -> {capped['RestingBP'].skew():.2f}; accuracy {as_is:.3f} -> {with_caps:.3f}")
    expect("capped cholesterol skew", capped["Cholesterol"].skew(), 0.31, 0.005)
    expect("capped blood pressure skew", capped["RestingBP"].skew(), 0.33, 0.005)
    expect("accuracy as is", as_is, 0.857, 0.0005)
    expect("accuracy capped", with_caps, 0.858, 0.0005)

    # Task 3: the disease rate by age band.
    bands = pd.cut(train["Age"], [0, 44, 54, 64, 100], labels=["under 45", "45-54", "55-64", "65 and over"])
    by_age = train.groupby(bands, observed=True)[target].agg(["size", "mean"])
    print("  by age band:", by_age.round(3).to_dict("index"))
    for band, (size, rate) in {"under 45": (138, 0.362), "45-54": (224, 0.469), "55-64": (287, 0.676),
                               "65 and over": (85, 0.671)}.items():
        expect(f"{band}: patients", by_age.loc[band, "size"], size, 0)
        expect(f"{band}: rate", by_age.loc[band, "mean"], rate, 0.0005)

    # Task 4: the five largest weights of the final model.
    weights = pd.Series(flagged.named_steps["model"].coef_[0], index=flagged.named_steps["prepare"].get_feature_names_out())
    largest = weights.reindex(weights.abs().sort_values(ascending=False).index).head(5).round(2)
    print("  largest weights:", largest.to_dict())
    assert largest.to_dict() == {"cat__ST_Slope_Up": -1.29, "cat__ChestPainType_ASY": 1.16, "cat__ST_Slope_Flat": 1.08,
                                 "num__missingindicator_Cholesterol": 0.71, "cat__Sex_F": -0.65}

    # Task 5: ten different splits of the same table.
    accuracies = []
    for seed in range(10):
        tr, te = train_test_split(heart, test_size=0.2, random_state=seed, stratify=heart[target])
        accuracies.append(accuracy_score(te[target], make_model(True).fit(tr[features], tr[target]).predict(te[features])))
    print(f"  ten splits: test accuracy from {min(accuracies):.3f} to {max(accuracies):.3f}, mean {np.mean(accuracies):.3f}")
    expect("lowest of ten splits", min(accuracies), 0.842, 0.0005)
    expect("highest of ten splits", max(accuracies), 0.886, 0.0005)
    expect("mean of ten splits", float(np.mean(accuracies)), 0.866, 0.0005)


def lab01():
    print("Lab 1")
    df = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
    children = df["children"].fillna(0).astype(int)
    df["total_nights"] = df["stays_in_weekend_nights"] + df["stays_in_week_nights"]
    df["total_guests"] = df["adults"] + children + df["babies"]
    df["with_children"] = ((children + df["babies"]) > 0).astype(int)
    df["log_lead_time"] = np.log1p(df["lead_time"])
    df["cancelled_before"] = (df["previous_cancellations"] > 0).astype(int)
    df["room_changed"] = (df["assigned_room_type"] != df["reserved_room_type"]).astype(int)
    df["from_portugal"] = (df["country"] == "PRT").astype(int)
    y = df["is_canceled"]
    raw_num = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
               "previous_cancellations", "previous_bookings_not_canceled", "adr",
               "required_car_parking_spaces", "total_of_special_requests"]
    cat = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]
    num = raw_num + ["total_nights", "total_guests", "with_children", "log_lead_time", "cancelled_before"]
    # Task 1: two columns that may have been written after the booking was made.
    for flag in ("room_changed", "from_portugal"):
        rates = df.groupby(flag)["is_canceled"].mean()
        print(f"  cancellation rate by {flag}: {rates.round(3).to_dict()}  bookings flagged: {int(df[flag].sum()):,}")
    expect("room changed rate", df.loc[df["room_changed"] == 1, "is_canceled"].mean(), 0.054, 0.0005)
    expect("room unchanged rate", df.loc[df["room_changed"] == 0, "is_canceled"].mean(), 0.416, 0.0005)
    expect("Portugal rate", df.loc[df["from_portugal"] == 1, "is_canceled"].mean(), 0.566, 0.0005)
    expect("other countries rate", df.loc[df["from_portugal"] == 0, "is_canceled"].mean(), 0.236, 0.0005)
    for label, cols, target in (("engineered", num, 0.855), ("engineered + room_changed", num + ["room_changed"], 0.868),
                                ("engineered + from_portugal", num + ["from_portugal"], 0.888)):
        X = df[cols + cat]
        X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
        m = Pipeline([("p", make_preprocess(cols, cat)), ("m", LogisticRegression(max_iter=3000))]).fit(X_tr, y_tr)
        auc = roc_auc_score(y_va, m.predict_proba(X_va)[:, 1])
        print(f"  {label:<30} ROC AUC {auc:.3f}")
        expect(label, auc, target, 0.0015)
    # The sheet also quotes five-fold cross-validation for the raw and engineered sets.
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    for label, cols_n, target in (("raw columns", raw_num, 0.848), ("raw + engineered", num, 0.858)):
        m = Pipeline([("p", make_preprocess(cols_n, cat)), ("m", LogisticRegression(max_iter=3000))])
        cv_auc = cross_val_score(m, df[cols_n + cat], y, cv=folds, scoring="roc_auc").mean()
        print(f"  five-fold ROC AUC, {label:<17} {cv_auc:.3f}")
        expect(f"cross-validated {label}", cv_auc, target, 0.0015)
    # Task 2: fitting the preprocessing on every row, the mistake the lab warns about, on this table.
    X = df[num + cat]
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    all_rows = make_preprocess(num, cat).fit(X)
    leaky = LogisticRegression(max_iter=3000).fit(all_rows.transform(X_tr), y_tr)
    auc = roc_auc_score(y_va, leaky.predict_proba(all_rows.transform(X_va))[:, 1])
    print(f"  preprocessing fitted on all rows  ROC AUC {auc:.3f}")
    expect("all-rows preprocessing", auc, 0.855, 0.0015)
    # Does scaling change a model? Nearest neighbors on the churn table, k near the root of the training rows.
    churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
    churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)
    money = ["tenure", "MonthlyCharges", "TotalCharges"]
    y_c = (churn["Churn"] == "Yes").astype(int)
    c_tr, c_va, yc_tr, yc_va = train_test_split(churn[money], y_c, test_size=0.25, random_state=42, stratify=y_c)
    assert len(c_tr) == 5282
    for label, model, target in (("raw units", KNeighborsClassifier(73), 0.778),
                                 ("standardized", Pipeline([("s", StandardScaler()), ("m", KNeighborsClassifier(73))]), 0.815)):
        auc = roc_auc_score(yc_va, model.fit(c_tr, yc_tr).predict_proba(c_va)[:, 1])
        print(f"  churn KNN, k=73, {label:<13} ROC AUC {auc:.3f}")
        expect(f"KNN {label}", auc, target, 0.002)
    # The bank file is stored in date order, May 2008 to November 2010.
    bank = pd.read_csv(DATA / "supervised/bank_marketing/bank_marketing.csv", sep=";").drop_duplicates().reset_index(drop=True)
    y_b = (bank["y"] == "yes").astype(int)
    X_b = bank.drop(columns=["y", "duration"])
    num_b = X_b.select_dtypes(include="number").columns.tolist()
    cat_b = X_b.select_dtypes(exclude="number").columns.tolist()
    cut = int(len(bank) * 0.75)
    m = Pipeline([("p", make_preprocess(num_b, cat_b)), ("m", LogisticRegression(max_iter=2000))])
    m.fit(X_b.iloc[:cut], y_b.iloc[:cut])
    auc = roc_auc_score(y_b.iloc[cut:], m.predict_proba(X_b.iloc[cut:])[:, 1])
    early, late = y_b.iloc[:cut].mean(), y_b.iloc[cut:].mean()
    print(f"  bank, first 75% of calls to predict the last 25%: ROC AUC {auc:.3f}; yes rate {early:.3f} then {late:.3f}")
    expect("date-order split", auc, 0.712, 0.002)
    expect("early yes rate", early, 0.064, 0.001)
    expect("late yes rate", late, 0.258, 0.001)
    # The L1 penalty: a smaller C is a stronger penalty, so fewer columns survive.
    Xb_tr, Xb_va, yb_tr, yb_va = train_test_split(X_b, y_b, test_size=0.25, random_state=42, stratify=y_b)
    for C, columns, target in ((0.001, 2, 0.765), (0.01, 12, 0.794), (0.03, 21, 0.801), (1.0, 49, 0.802)):
        m = Pipeline([("p", make_preprocess(num_b, cat_b)),
                      ("m", LogisticRegression(penalty="l1", C=C, solver="liblinear", random_state=42))]).fit(Xb_tr, yb_tr)
        kept = int((m.named_steps["m"].coef_ != 0).sum())
        auc = roc_auc_score(yb_va, m.predict_proba(Xb_va)[:, 1])
        print(f"  L1 penalty, C={C}: kept {kept} of 62 columns, ROC AUC {auc:.3f}")
        expect(f"L1 C={C}", auc, target, 0.002)
        assert kept == columns, f"L1 C={C} kept {kept}"


def used_cars():
    """Lab 2's cleaned used-car listings: the same fixed rules as Question 2."""
    cars = pd.read_csv(DATA / "supervised/used_cars/used_cars.zip", low_memory=False)
    used = cars[(cars["stock_type"] == "Used") & cars["price_usd"].between(1_000, 200_000)
                & (cars["mileage_miles"] > 100)].copy()

    def tidy(column, groups):
        text = column.str.lower()
        matches = [text.str.contains(pattern, na=False) for pattern in groups.values()]
        return pd.Series(np.select(matches, list(groups), default=None), index=column.index)

    used["drive"] = tidy(used["drivetrain"], {"AWD": "all|awd", "4WD": "four|4wd|4x4", "FWD": "front|fwd", "RWD": "rear|rwd"})
    used["fuel_type"] = tidy(used["fuel"], {"plug-in hybrid": "plug", "hybrid": "hybrid|mild", "electric": "electric",
                                            "diesel": "diesel", "flex fuel": "flex|e85", "gasoline": "gas|petrol|unleaded"})
    used["age"] = (2026 - used["year"]).clip(lower=0)
    return used


def hotel_bookings():
    """The hotel bookings in arrival order, with Lab 1's five engineered columns."""
    h = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
    text_date = (h["arrival_date_year"].astype(str) + "-" + h["arrival_date_month"]
                 + "-" + h["arrival_date_day_of_month"].astype(str))
    h["arrival_date"] = pd.to_datetime(text_date, format="%Y-%B-%d")
    h = h.sort_values("arrival_date", kind="stable").reset_index(drop=True)
    children = h["children"].fillna(0).astype(int)
    h["total_nights"] = h["stays_in_weekend_nights"] + h["stays_in_week_nights"]
    h["total_guests"] = h["adults"] + children + h["babies"]
    h["with_children"] = ((children + h["babies"]) > 0).astype(int)
    h["log_lead_time"] = np.log1p(h["lead_time"])
    h["cancelled_before"] = (h["previous_cancellations"] > 0).astype(int)
    return h


HOTEL_NUM = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
             "previous_cancellations", "previous_bookings_not_canceled", "adr", "required_car_parking_spaces",
             "total_of_special_requests", "total_nights", "total_guests", "with_children", "log_lead_time",
             "cancelled_before"]
HOTEL_CAT = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]


def lab02():
    print("\nLab 2")
    # Task 1. Add the missing idea: the car's model, as a category.
    used = used_cars()
    num, cat = ["age", "mileage_miles"], ["make", "body_type", "drive", "fuel_type"]
    tr, va = train_test_split(used, test_size=0.20, random_state=42)
    for label, cats, est, r2_target, mae_target in (
            ("Part A columns, OLS", cat, LinearRegression(), 0.575, 9009),
            ("Part A columns + model, OLS", cat + ["model"], LinearRegression(), 0.792, 5754),
            ("Part A columns + model, ridge", cat + ["model"], Ridge(alpha=10.0), 0.772, 6128)):
        m = Pipeline([("p", make_preprocess(num, cats)), ("m", est)]).fit(tr, tr["price_usd"])
        pred = m.predict(va)
        r2, mae = r2_score(va["price_usd"], pred), mean_absolute_error(va["price_usd"], pred)
        print(f"  {label:<32} R2 {r2:.3f}  MAE {mae:,.0f}")
        expect(label, r2, r2_target, 0.002)
        expect(label + " MAE", mae, mae_target, 5)
    print(f"  {used['model'].nunique()} models among {len(used):,} listings")

    # Task 2. What did the date split hide? The Part C forest on Question 7's shuffled split.
    h = hotel_bookings()
    X, y = h[HOTEL_NUM + HOTEL_CAT], h["is_canceled"]
    forest = lambda: Pipeline([("p", make_preprocess(HOTEL_NUM, HOTEL_CAT)),
                               ("m", RandomForestClassifier(n_estimators=300, min_samples_leaf=5, random_state=42, n_jobs=-1))])
    in_train = (h["arrival_date"] < "2017-01-01").to_numpy()
    dated = forest().fit(X[in_train], y[in_train])
    auc_dated = roc_auc_score(y[~in_train], dated.predict_proba(X[~in_train])[:, 1])
    Xr_tr, Xr_va, yr_tr, yr_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    shuffled = forest().fit(Xr_tr, yr_tr)
    auc_shuffled = roc_auc_score(yr_va, shuffled.predict_proba(Xr_va)[:, 1])
    print(f"  forest, date split ROC AUC {auc_dated:.3f}; shuffled split {auc_shuffled:.3f}")
    expect("forest on 2017", auc_dated, 0.841, 0.002)
    expect("forest shuffled", auc_shuffled, 0.911, 0.002)
    # How many shuffled validation bookings have an exact twin among the training bookings?
    cols = [c for c in h.columns if c not in ("arrival_date",)]
    seen = set(map(tuple, h.loc[Xr_tr.index, cols].astype(str).to_numpy()))
    twins = sum(tuple(r) in seen for r in h.loc[Xr_va.index, cols].astype(str).to_numpy())
    print(f"  shuffled validation bookings with an exact twin in training: {twins:,} of {len(Xr_va):,}")
    assert twins == 9366, twins

    # Task 3. Choose a threshold from costs: walking a guest costs twice an empty room.
    logistic = Pipeline([("p", make_preprocess(HOTEL_NUM, HOTEL_CAT)), ("m", LogisticRegression(max_iter=3000))])
    prob = logistic.fit(X[in_train], y[in_train]).predict_proba(X[~in_train])[:, 1]
    y_va = y[~in_train].to_numpy()
    print("  threshold  empty rooms  walked guests  cost = empty + 2*walked")
    best, costs = None, {}
    for t in np.round(np.arange(0.05, 0.96, 0.05), 2):
        fn, fp = int(((prob < t) & (y_va == 1)).sum()), int(((prob >= t) & (y_va == 0)).sum())
        costs[float(t)] = (fn, fp, fn + 2 * fp)
        if best is None or fn + 2 * fp < best[0]:
            best = (fn + 2 * fp, float(t), fn, fp)
        if t in (0.3, 0.5, 0.6, 0.65, 0.7, 0.8, 0.9):
            print(f"    {t:.2f}     {fn:>6}       {fp:>6}        {fn + 2 * fp:>6}")
    print("  cheapest:", best)
    assert best == (11287, 0.65, 10065, 611), best
    assert costs[0.5][:2] == (7129, 2479) and costs[0.7][:2] == (11117, 194), (costs[0.5], costs[0.7])

    # Task 4. How sure is a test score? Part D with five different splits.
    churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
    churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)
    X_c = churn.drop(columns=["customerID", "Churn"])
    y_c = (churn["Churn"] == "Yes").astype(int)
    c_num = X_c.select_dtypes(include="number").columns.tolist()
    c_cat = X_c.select_dtypes(exclude="number").columns.tolist()
    tests = []
    for seed in range(5):
        a, b, ya, yb = train_test_split(X_c, y_c, test_size=0.25, random_state=seed, stratify=y_c)
        search = GridSearchCV(Pipeline([("p", make_preprocess(c_num, c_cat)), ("m", LogisticRegression(max_iter=3000))]),
                              {"m__C": [0.01, 0.1, 1.0, 10.0, 100.0], "m__class_weight": [None, "balanced"]},
                              scoring="roc_auc", cv=StratifiedKFold(5, shuffle=True, random_state=42), n_jobs=-1).fit(a, ya)
        tests.append(roc_auc_score(yb, search.predict_proba(b)[:, 1]))
        print(f"  churn split seed {seed}: best {search.best_params_}, test ROC AUC {tests[-1]:.3f}")
    print(f"  test ROC AUC from {min(tests):.3f} to {max(tests):.3f}")
    expect("lowest test score", min(tests), 0.838, 0.002)
    expect("highest test score", max(tests), 0.855, 0.002)


def loan_features():
    """Lab 3's thirteen numbers known at application, for all 100,000 loans, and the default label."""
    loans = pd.read_csv(DATA / "supervised/lending_club/lending_club_2014_2015.zip", low_memory=False)
    issued = pd.to_datetime(loans["issue_d"], format="%b-%Y")
    first_credit = pd.to_datetime(loans["earliest_cr_line"], format="%b-%Y")
    X = pd.DataFrame({
        "loan_amnt": loans["loan_amnt"],
        "term_months": loans["term"].str.extract(r"(\d+)")[0].astype(int),
        "int_rate": loans["int_rate"],
        "log_income": np.log1p(loans["annual_inc"]),
        "dti": loans["dti"],
        "fico": (loans["fico_range_low"] + loans["fico_range_high"]) / 2,
        "revol_util": loans["revol_util"],
        "inquiries_6m": loans["inq_last_6mths"],
        "delinq_2y": loans["delinq_2yrs"],
        "open_acc": loans["open_acc"],
        "mort_acc": loans["mort_acc"],
        "emp_years": loans["emp_length"].replace({"< 1 year": "0 years"}).str.extract(r"(\d+)")[0].astype(float),
        "credit_years": (issued - first_credit).dt.days / 365.25,
    })
    return X, (loans["loan_status"] == "Charged Off").astype(int)


def lab03():
    print("\nLab 3")
    X_all, y_all = loan_features()
    X = X_all.sample(20_000, random_state=42)
    y = y_all.loc[X.index]
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    impute = lambda: ("i", SimpleImputer(strategy="median"))
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    # Task 1. Take the scaler away from the chosen KNN.
    print("  standard deviations:", X_tr.std().round(1).to_dict())
    for label, steps, target_cv, target_va in [("scaled", [impute(), ("s", StandardScaler())], 0.719, 0.723),
                                               ("raw units", [impute()], 0.571, 0.586)]:
        m = Pipeline(steps + [("m", KNeighborsClassifier(n_neighbors=801))])
        cv = cross_val_score(m, X_tr, y_tr, cv=folds, scoring="roc_auc").mean()
        va = roc_auc_score(y_va, m.fit(X_tr, y_tr).predict_proba(X_va)[:, 1])
        print(f"  KNN k=801, {label:<10} CV ROC AUC {cv:.3f}  validation ROC AUC {va:.3f}")
        expect(f"knn {label} cv", cv, target_cv, 0.002)
        expect(f"knn {label} validation", va, target_va, 0.002)
    # Task 3. Count the support vectors of the tuned SVM.
    svm = Pipeline([impute(), ("s", StandardScaler()),
                    ("m", SVC(kernel="rbf", C=0.1, gamma=0.01, class_weight="balanced"))]).fit(X_tr, y_tr)
    kept = svm.named_steps["m"].n_support_
    print(f"  tuned SVM keeps {kept.sum()} of {len(X_tr)} loans as support vectors "
          f"({kept[1]} of the {int(y_tr.sum())} defaults)")
    assert (kept.sum(), kept[1]) == (11478, 2205), kept
    # Task 4. How much of the skill is the lender's own interest rate?
    for label, cols, target in (("all thirteen", list(X.columns), 0.731),
                                ("without int_rate", [c for c in X.columns if c != "int_rate"], 0.708),
                                ("without int_rate and term", [c for c in X.columns if c not in ("int_rate", "term_months")], 0.669),
                                ("int_rate alone", ["int_rate"], 0.707)):
        m = Pipeline([impute(), ("s", StandardScaler()), ("m", LogisticRegression(max_iter=2000))]).fit(X_tr[cols], y_tr)
        auc = roc_auc_score(y_va, m.predict_proba(X_va[cols])[:, 1])
        print(f"  logistic, {label:<27} ROC AUC {auc:.3f}")
        expect(f"logistic {label}", auc, target, 0.002)
    # Task 2. How many trees are enough? The car-price forest on Question 10's split.
    used = used_cars()
    cat = ["make", "model", "body_type", "drive", "fuel_type"]
    codes = OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1, encoded_missing_value=-1)
    X_c = pd.concat([used[["age", "mileage_miles", "cpo"]].reset_index(drop=True),
                     pd.DataFrame(codes.fit_transform(used[cat]), columns=cat)], axis=1)
    y_c = np.log(used["price_usd"]).reset_index(drop=True)
    Xc_tr, Xc_va, yc_tr, yc_va = train_test_split(X_c, y_c, test_size=0.25, random_state=42)
    for trees, target in ((1, 0.2836), (10, 0.2135), (50, 0.2067), (150, 0.2055), (400, 0.2053)):
        m = RandomForestRegressor(n_estimators=trees, max_features=0.5, min_samples_leaf=2, random_state=42, n_jobs=-1)
        rmse = float(np.sqrt(np.mean((yc_va - m.fit(Xc_tr, yc_tr).predict(Xc_va)) ** 2)))
        print(f"  car-price forest of {trees:>3} trees: log-RMSE {rmse:.4f}")
        expect(f"forest {trees}", rmse, target, 0.0015)
    rmse = float(np.sqrt(np.mean((yc_va - yc_tr.mean()) ** 2)))
    print(f"  car prices, always the training mean: log-RMSE {rmse:.4f}")
    expect("car mean", rmse, 0.6553, 0.001)


def retail_customers():
    """Lab 4's cleaning rules and RFM table, as the notebook builds them."""
    lines = pd.read_csv(DATA / "unsupervised/online_retail_ii/online_retail_ii.zip", dtype={"Invoice": str, "StockCode": str},
                        parse_dates=["InvoiceDate"])
    sales = lines.dropna(subset=["Customer ID"])
    sales = sales[~sales["Invoice"].str.startswith("C") & (sales["Quantity"] > 0) & (sales["Price"] > 0)].drop_duplicates()
    sales = sales.assign(revenue=sales["Quantity"] * sales["Price"])
    day_after = sales["InvoiceDate"].max().normalize() + pd.Timedelta(days=1)
    return sales.groupby("Customer ID").agg(recency_days=("InvoiceDate", lambda d: (day_after - d.max()).days),
                                            orders=("Invoice", "nunique"), spend=("revenue", "sum"))


def wood_fit_split():
    """Lab 4's development images split board by board into fitting and validation rows, as in Question 8."""
    wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
    X = wood["x"].reshape(len(wood["x"]), -1) / 255.0
    y, boards = wood["y"], wood["board"]
    dev, _ = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42).split(X, y, boards))
    fit, valid = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42).split(X[dev], y[dev], boards[dev]))
    return X[dev][fit], X[dev][valid], y[dev][fit], y[dev][valid]


def lab04():
    print("\nLab 4")
    customers = retail_customers()
    X = StandardScaler().fit_transform(np.log1p(customers))
    starts = [KMeans(4, n_init=1, random_state=seed).fit(X).inertia_ for seed in range(8)]
    print("  customers, k=4, one start each, seeds 0-7:", np.round(starts, 1).tolist())
    expect("customer starts low", min(starts), 4963.7, 0.05)
    expect("customer starts high", max(starts), 4964.0, 0.05)
    X_fit, X_valid, y_fit, y_valid = wood_fit_split()
    codes = PCA(n_components=50, random_state=42).fit_transform(X_fit)
    starts = [KMeans(7, n_init=1, random_state=seed).fit(codes).inertia_ for seed in range(8)]
    print("  images, k=7, one start each, seeds 0-7:", np.round(starts, 0).tolist())
    expect("image starts low", min(starts), 248598, 1)
    expect("image starts high", max(starts), 251895, 1)
    # Without the logs, spend in pounds decides the clusters.
    logged = KMeans(4, n_init=20, random_state=42).fit_predict(X)
    raw = KMeans(4, n_init=20, random_state=42).fit_predict(StandardScaler().fit_transform(customers))
    ari, sizes = adjusted_rand_score(logged, raw), sorted(np.bincount(raw).tolist(), reverse=True)
    print(f"  without the logs: adjusted Rand index {ari:.3f} against Question 4, cluster sizes {sizes}")
    expect("no-log ARI", ari, 0.172, 0.001)
    assert sizes == [3840, 1999, 35, 4], sizes
    # Four or five segments?
    five = KMeans(5, n_init=20, random_state=42).fit_predict(X)
    profile = customers.assign(c=five).groupby("c").agg(customers=("orders", "size"), recency=("recency_days", "median"),
                                                        orders=("orders", "median"), spend=("spend", "median"))
    print(profile.round(0).to_string())
    top = profile.sort_values("spend").iloc[-1]
    assert (top["customers"], top["recency"], top["orders"]) == (480, 7, 23), top
    expect("champion spend", top["spend"], 9323.61, 0.01)
    # How few components?
    for n, target in ((2, 0.420), (10, 0.538), (50, 0.591)):
        m = Pipeline([("pca", PCA(n_components=n, random_state=42)), ("model", LogisticRegression(max_iter=1000))]).fit(X_fit, y_fit)
        acc = accuracy_score(y_valid, m.predict(X_valid))
        print(f"  {n:>2} components: validation accuracy {acc:.4f}")
        expect(f"{n} components", acc, target, 0.002)
    two = PCA(n_components=2, random_state=42).fit(X_fit).explained_variance_ratio_.sum()
    print(f"  two components keep {two:.3f} of the variance")
    expect("two components variance", two, 0.530, 0.001)


def lab05():
    print("\nLab 5")
    cards = pd.read_csv(DATA / "unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip")
    X = cards[[f"V{i}" for i in range(1, 29)]].assign(log_amount=np.log1p(cards["Amount"]))
    y = cards["Class"]

    def ranking(X_tr, X_te, y_tr, y_te, label):
        forest = IsolationForest(n_estimators=300, random_state=42, n_jobs=-1).fit(X_tr)
        score = -forest.decision_function(X_te)
        logistic = LogisticRegression(max_iter=2000).fit(X_tr, y_tr).predict_proba(X_te)[:, 1]
        out = {}
        for name, s in (("isolation forest", score), ("logistic, with labels", logistic)):
            top = int(y_te.to_numpy()[np.argsort(-s)][:100].sum())
            out[name] = (roc_auc_score(y_te, s), average_precision_score(y_te, s), top)
            print(f"  {label}, {name:<22} ROC AUC {out[name][0]:.3f}  AP {out[name][1]:.3f}  frauds in top 100: {top}")
        return out, score

    random_split = train_test_split(X, y, test_size=0.30, random_state=42, stratify=y)
    out, score = ranking(*random_split, "random split")
    for name, (auc, ap, top) in {"isolation forest": (0.950, 0.219, 39), "logistic, with labels": (0.956, 0.711, 86)}.items():
        expect(name + " auc", out[name][0], auc, 0.002)
        expect(name + " ap", out[name][1], ap, 0.002)
        assert out[name][2] == top, (name, out[name][2])
    # The review budget: each review costs $5, each fraud caught saves $200.
    hits = random_split[3].to_numpy()[np.argsort(-score)]
    savings = {k: 200 * int(hits[:k].sum()) - 5 * k for k in (50, 100, 300, 1000, 2000, 5000)}
    print("  frauds found:", {k: int(hits[:k].sum()) for k in savings}, " net saving:", savings)
    assert savings == {50: 4750, 100: 7300, 300: 11100, 1000: 14800, 2000: 13200, 5000: -400}, savings
    # Split by time: train on the first 70% of the two days, test on the rest.
    cut = cards["Time"].quantile(0.70)
    early, late = cards["Time"] <= cut, cards["Time"] > cut
    out, _ = ranking(X[early], X[late], y[early], y[late], f"time split at hour {cut / 3600:.1f}")
    for name, (auc, ap, top) in {"isolation forest": (0.944, 0.044, 1), "logistic, with labels": (0.972, 0.706, 72)}.items():
        expect(name + " time auc", out[name][0], auc, 0.002)
        expect(name + " time ap", out[name][1], ap, 0.002)
        assert out[name][2] == top, (name, out[name][2])
    # Self-training with a lower confidence threshold: more pseudo-labels, more of them wrong.
    messages = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
    train_part = messages[messages["split"] == "train"]
    val = train_part.sample(2000, random_state=42)
    pool = train_part.drop(val.index)
    vectorizer = TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True).fit(pool["text"])
    X_pool, X_val = vectorizer.transform(pool["text"]), vectorizer.transform(val["text"])
    y_pool, y_val = pool["label"].to_numpy(), val["label"].to_numpy()
    labeled = np.random.default_rng(42).choice(len(y_pool), 1000, replace=False)
    alone = accuracy_score(y_val, LogisticRegression(max_iter=2000, C=10).fit(X_pool[labeled], y_pool[labeled]).predict(X_val))
    print(f"  1,000 labels only: validation accuracy {alone:.3f}")
    expect("1,000 labels alone", alone, 0.638, 0.002)
    for threshold, target in ((0.8, 0.632), (0.5, 0.596), (0.3, 0.606)):
        partial = np.full(len(y_pool), -1)
        partial[labeled] = y_pool[labeled]
        semi = SelfTrainingClassifier(LogisticRegression(max_iter=2000, C=10), threshold=threshold).fit(X_pool, partial)
        pseudo = semi.labeled_iter_ > 0
        right = float(np.mean(semi.transduction_[pseudo] == y_pool[pseudo]))
        together = accuracy_score(y_val, semi.predict(X_val))
        print(f"  self-training, threshold {threshold}: adopted {int(pseudo.sum())} pseudo-labels, {right:.1%} right;"
              f" validation accuracy {together:.3f}")
        expect(f"self-training threshold {threshold}", together, target, 0.002)


def lab06():
    print("\nLab 6")
    goal, start = (3, 3), (0, 0)
    actions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    names = ["up", "down", "left", "right"]

    def train(trap=(1, 3), cost=-0.04, gamma=0.95, eps0=1.0, eps_min=0.05, decay=0.9985, seed=42, episodes=5000):
        rng = np.random.default_rng(seed)
        q = np.zeros((4, 4, 4))
        eps = eps0
        returns = []

        def step(state, a):
            r, c = state
            nxt = (min(max(r + actions[a][0], 0), 3), min(max(c + actions[a][1], 0), 3))
            if nxt == goal:
                return nxt, 1.0, True
            if nxt == trap:
                return nxt, -1.0, True
            return nxt, cost, False

        for _ in range(episodes):
            s = start
            earned = 0.0
            for _ in range(100):
                a = int(rng.integers(4)) if rng.random() < eps else int(np.argmax(q[s]))
                nxt, reward, done = step(s, a)
                earned += reward
                target = reward if done else reward + gamma * np.max(q[nxt])
                q[s][a] += 0.15 * (target - q[s][a])
                s = nxt
                if done:
                    break
            returns.append(earned)
            eps = max(eps_min, eps * decay)
        s, total, moves = start, 0.0, 0
        for _ in range(100):
            s, reward, done = step(s, int(np.argmax(q[s])))
            total += reward
            moves += 1
            if done:
                break
        reached = s == goal
        return q, reached, moves, total, returns

    def describe(label, want_return, **kwargs):
        q, reached, moves, total, returns = train(**kwargs)
        print(f"  {label:<34} reaches goal {reached}, moves {moves}, return {total:.2f}")
        assert reached and moves == 6
        expect(label, total, want_return, 1e-6)
        return q, returns

    q, returns = describe("the lab's settings", 0.80)
    print(f"   mean return, first 100 episodes {np.mean(returns[:100]):.3f}, last 100 {np.mean(returns[-100:]):.3f}")
    expect("first 100 episodes", np.mean(returns[:100]), -0.914, 0.001)
    expect("last 100 episodes", np.mean(returns[-100:]), 0.788, 0.001)
    # The learned values against the exact ones, computed by value iteration.
    exact = np.zeros((4, 4))
    for _ in range(200):
        for r in range(4):
            for c in range(4):
                if (r, c) in (goal, (1, 3)):
                    continue
                best = -np.inf
                for dr, dc in actions:
                    nxt = (min(max(r + dr, 0), 3), min(max(c + dc, 0), 3))
                    best = max(best, 1.0 if nxt == goal else -1.0 if nxt == (1, 3) else -0.04 + 0.95 * exact[nxt])
                exact[r, c] = best
    print("   values, first row:", q.max(axis=2)[0].round(3).tolist(), " exact:", exact[0].round(3).tolist())
    assert np.abs(q.max(axis=2) - exact).max() < 0.001
    moved, _ = describe("trap moved to (3, 1)", 0.80, trap=(3, 1))
    print("   policy row by row:", [[names[int(np.argmax(moved[r, c]))] for c in range(4)] for r in range(4)])
    describe("no step cost", 1.00, cost=0.0)
    describe("step cost -0.5", -1.50, cost=-0.5)
    describe("never explores (epsilon 0)", 0.80, eps0=0.0, eps_min=0.0)
    describe("always explores (epsilon 1)", 0.80, eps0=1.0, eps_min=1.0)
    describe("gamma 0.1", 0.80, gamma=0.1)


def lab07():
    print("\nLab 7")
    import torch
    from torch import nn
    wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
    labels, boards = wood["y"], wood["board"]
    dev, test = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42).split(labels, labels, boards))
    fit_rows, val_rows = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42).split(dev, labels[dev], boards[dev]))

    def tensors(rows):
        X = torch.tensor(wood["x"][rows], dtype=torch.float32).permute(0, 3, 1, 2) / 255.0
        return X, torch.tensor(labels[rows], dtype=torch.long)

    X_fit, y_fit = tensors(dev[fit_rows])
    X_val, y_val = tensors(dev[val_rows])
    X_test, y_test = tensors(test)

    def accuracy(model, X, y):
        model.eval()
        with torch.no_grad():
            hits = sum((model(X[i:i + 2000]).argmax(dim=1) == y[i:i + 2000]).sum().item() for i in range(0, len(X), 2000))
        return hits / len(X)

    def fit(model, epochs=10, lr=1e-3, batch_size=128):
        optimizer = torch.optim.Adam(model.parameters(), lr=lr)
        loss_fn = nn.CrossEntropyLoss()
        for _ in range(epochs):
            model.train()
            order = torch.randperm(len(X_fit))
            for start in range(0, len(X_fit), batch_size):
                batch = order[start:start + batch_size]
                optimizer.zero_grad()
                loss_fn(model(X_fit[batch]), y_fit[batch]).backward()
                optimizer.step()
        return accuracy(model, X_val, y_val), accuracy(model, X_test, y_test)

    def cnn(dropout=0.2):
        return nn.Sequential(
            nn.Conv2d(3, 16, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(16, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Flatten(), nn.Linear(32 * 8 * 8, 64), nn.ReLU(), nn.Dropout(dropout), nn.Linear(64, 7))

    torch.manual_seed(42)
    scores = fit(nn.Sequential(nn.Flatten(), nn.Linear(3072, 128), nn.Linear(128, 7)))
    print("  dense network without ReLU: validation %.4f, test %.4f" % scores)
    expect("no ReLU", scores[1], 0.450, 0.02)
    torch.manual_seed(42)
    scores = fit(nn.Sequential(nn.Flatten(), nn.Linear(3072, 128), nn.ReLU(), nn.Linear(128, 7)))
    print("  dense network with ReLU:    validation %.4f, test %.4f" % scores)
    expect("ReLU", scores[1], 0.557, 0.02)
    for lr, target in ((1e-4, 0.571), (1e-3, 0.686), (1e-2, 0.690), (1e-1, 0.197)):
        torch.manual_seed(42)
        scores = fit(cnn(), lr=lr)
        print(f"  CNN, learning rate {lr:<7}: validation %.4f, test %.4f" % scores)
        expect(f"lr {lr}", scores[1], target, 0.02)
    torch.manual_seed(42)
    scores = fit(cnn(0.0))
    print("  CNN without dropout:        validation %.4f, test %.4f" % scores)
    expect("no dropout", scores[1], 0.699, 0.02)


def lab08():
    print("\nLab 8")
    import copy
    import torch
    from torch import nn
    loads = pd.read_csv(DATA / "advanced/electricity_load/electricity_load_hourly.zip", parse_dates=["hour_start"], index_col="hour_start")
    demand = loads.sum(axis=1) / 1000
    period = pd.Series("train", index=demand.index)
    period[demand.index >= "2014-01-01"] = "validation"
    period[demand.index >= "2014-07-01"] = "test"
    scale = float(demand[period == "train"].max())
    scaled = (demand / scale).to_numpy(dtype=np.float32)
    hour_of_day = (demand.index.hour.to_numpy() / 23).astype(np.float32)

    def data(lookback=24, horizon=1, channels=(scaled,)):
        """Windows of `lookback` hours that end `horizon` hours before the hour they predict."""
        stack = np.stack(channels, axis=-1)
        targets = np.arange(lookback + horizon - 1, len(scaled))
        X = np.stack([stack[t - horizon + 1 - lookback:t - horizon + 1] for t in targets])
        of_row = period.to_numpy()[targets]
        return [(torch.tensor(X[of_row == p]), torch.tensor(scaled[targets][of_row == p])) for p in ["train", "validation", "test"]]

    class Forecaster(nn.Module):
        def __init__(self, inputs=1):
            super().__init__()
            self.lstm = nn.LSTM(input_size=inputs, hidden_size=32, batch_first=True)
            self.head = nn.Linear(32, 1)

        def forward(self, x):
            states, _ = self.lstm(x)
            return self.head(states[:, -1, :]).squeeze(-1)

    def mae(model, X, y):
        model.eval()
        with torch.no_grad():
            return (model(X) - y).abs().mean().item() * scale

    def fit(splits, epochs=12, report_at=None):
        """Train as the notebook does; return the validation curve and the test MAE of the best epoch.
        With report_at, also print the test MAE of the best epoch up to that point."""
        (Xtr, ytr), (Xva, yva), (Xte, yte) = splits
        torch.manual_seed(42)
        model = Forecaster(Xtr.shape[-1])
        optimizer = torch.optim.Adam(model.parameters(), lr=3e-3)
        loss_fn = nn.MSELoss()
        curve, best = [], None
        for _ in range(epochs):
            model.train()
            order = torch.randperm(len(Xtr))
            for start in range(0, len(Xtr), 64):
                batch = order[start:start + 64]
                optimizer.zero_grad()
                loss_fn(model(Xtr[batch]), ytr[batch]).backward()
                optimizer.step()
            curve.append(mae(model, Xva, yva))
            if curve[-1] == min(curve):
                best = copy.deepcopy(model.state_dict())
            if len(curve) == report_at:              # score the best epoch so far without touching the random state
                current = copy.deepcopy(model.state_dict())
                model.load_state_dict(best)
                fit.early_test = mae(model, Xte, yte)
                model.load_state_dict(current)
        model.load_state_dict(best)
        return curve, mae(model, Xte, yte)

    def baseline(lag, name):
        hours = period == name
        return float((demand[hours] - demand.shift(lag)[hours]).abs().mean())

    free = {"last hour": 1, "same hour yesterday": 24, "same hour last week": 168}
    print("  free forecasts, validation and test MAE:",
          {name: (round(baseline(lag, "validation"), 2), round(baseline(lag, "test"), 2)) for name, lag in free.items()})
    expect("last hour, test", baseline(1, "test"), 6.12, 0.005)
    expect("same hour yesterday, test", baseline(24, "test"), 3.69, 0.005)
    expect("same hour yesterday, validation", baseline(24, "validation"), 3.07, 0.005)

    curve, test = fit(data(), epochs=30, report_at=12)
    best = int(np.argmin(curve)) + 1
    print(f"  30 epochs: validation MAE by epoch {np.round(curve, 2).tolist()}")
    print(f"  the notebook's 12 epochs: best validation {min(curve[:12]):.2f}, test {fit.early_test:.2f}")
    print(f"  30 epochs: best epoch {best}, validation {min(curve):.2f}, test {test:.2f}")
    expect("12 epochs: validation, as in the notebook", min(curve[:12]), 2.16, 0.3)
    expect("12 epochs: test, as in the notebook", fit.early_test, 2.57, 0.4)
    expect("30 epochs: best validation", min(curve), 1.56, 0.3)
    expect("30 epochs: test", test, 1.79, 0.4)

    curve, test = fit(data(channels=(scaled, hour_of_day)))
    print(f"  demand plus hour of day: validation {min(curve):.2f}, test {test:.2f}")
    expect("hour of day: validation", min(curve), 2.07, 0.3)
    expect("hour of day: test", test, 2.59, 0.4)

    for horizon in (2, 24):
        curve, test = fit(data(horizon=horizon))
        free = {"last known hour": horizon, "same hour yesterday": 24, "same hour last week": 168}
        scores = {name: (baseline(lag, "validation"), baseline(lag, "test")) for name, lag in free.items()}
        print(f"  {horizon} hours ahead: LSTM validation {min(curve):.2f}, test {test:.2f}; "
              + "; ".join(f"{name} {v:.2f}, {t:.2f}" for name, (v, t) in scores.items()))
        expect(f"{horizon} hours ahead: LSTM test", test, {2: 2.98, 24: 3.71}[horizon], 0.4)


def lab09():
    print("Lab 9")
    from sklearn.feature_extraction.text import CountVectorizer
    from sklearn.metrics import average_precision_score, precision_score, recall_score
    from sklearn.model_selection import cross_val_predict
    from sklearn.naive_bayes import MultinomialNB
    from demo_text import message_vectors, neighbors, word_vectors       # the chapter's script, in this folder

    sms = pd.read_csv(DATA / "supervised/sms_spam/sms_spam.csv")
    unique = sms.drop_duplicates("message").reset_index(drop=True)
    is_spam = (unique["label"] == "spam").astype(int)
    text_train, text_test, y_train, y_test = train_test_split(unique["message"], is_spam, test_size=0.20,
                                                              random_state=42, stratify=is_spam)
    y_train, y_test = y_train.to_numpy(), y_test.to_numpy()
    folds = StratifiedKFold(5, shuffle=True, random_state=42)

    def cross_validated(vectorizer, model, text):
        pipeline = Pipeline([("words", vectorizer), ("model", model)])
        return cross_val_predict(pipeline, text, y_train, cv=folds, method="predict_proba")[:, 1]

    def pieces():
        return TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 5), sublinear_tf=True)

    # Task 1: allow one real message in a hundred.
    cv_prob = cross_validated(pieces(), LogisticRegression(max_iter=2000, C=10), text_train)
    ham = np.sort(cv_prob[y_train == 0])[::-1]
    loose = float(ham[int(0.01 * len(ham))]) + 1e-6
    spam_filter = Pipeline([("words", pieces()), ("model", LogisticRegression(max_iter=2000, C=10))]).fit(text_train, y_train)
    test_prob = spam_filter.predict_proba(text_test)[:, 1]
    flagged = test_prob >= loose
    caught, lost = int((flagged & (y_test == 1)).sum()), int((flagged & (y_test == 0)).sum())
    cv_recall = recall_score(y_train, cv_prob >= loose)
    print(f"  one in a hundred: threshold {loose:.2f}, cross-validated recall {cv_recall:.3f}; on the test {caught} of "
          f"{int(y_test.sum())} spam caught, {lost} of {int((y_test == 0).sum())} real messages flagged")
    FOUND = {"loose": (round(loose, 2), round(cv_recall, 3), caught, lost)}

    # Task 2: remove the placeholders, then score the word filter again.
    cleaned = text_train.str.replace(r"&lt;.*?&gt;", " ", regex=True)
    FOUND["placeholders"] = {}
    for name, text in [("as collected", text_train), ("placeholders removed", cleaned)]:
        p = cross_validated(TfidfVectorizer(), LogisticRegression(max_iter=2000, C=10), text)
        word_filter = Pipeline([("words", TfidfVectorizer()), ("model", LogisticRegression(max_iter=2000, C=10))]).fit(text, y_train)
        weight = pd.Series(word_filter.named_steps["model"].coef_[0], index=word_filter.named_steps["words"].get_feature_names_out())
        FOUND["placeholders"][name] = (round(precision_score(y_train, p >= 0.5), 3), round(recall_score(y_train, p >= 0.5), 3),
                                       round(average_precision_score(y_train, p), 3), weight.sort_values().head(6).index.tolist())
        print(f"  {name}: precision, recall, average precision, ham words: {FOUND['placeholders'][name]}")

    # Task 3: naive Bayes on single words and on words with pairs.
    FOUND["pairs"] = {}
    for name, vectorizer in [("single words", CountVectorizer()), ("words and pairs", CountVectorizer(ngram_range=(1, 2)))]:
        p = cross_validated(vectorizer, MultinomialNB(), text_train)
        columns = len(vectorizer.fit(text_train).vocabulary_)
        FOUND["pairs"][name] = (columns, round(average_precision_score(y_train, p), 3), int(((p >= 0.5) & (y_train == 0)).sum()),
                                int(((p < 0.5) & (y_train == 1)).sum()))
        print(f"  naive Bayes on {name}: columns, average precision, real flagged, spam missed: {FOUND['pairs'][name]}")

    # The bank questions, as in the lab.
    bank = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
    train, test = bank[bank["split"] == "train"].reset_index(drop=True), bank[bank["split"] == "test"].reset_index(drop=True)
    i_train, i_test = train["label"].to_numpy(), test["label"].to_numpy()
    vectorizer = TfidfVectorizer()
    w_train, w_test = vectorizer.fit_transform(train["text"]), vectorizer.transform(test["text"])
    model = LogisticRegression(max_iter=3000, C=10).fit(w_train, i_train)
    order = np.argsort(model.predict_proba(w_test), axis=1)

    # Task 4: the right intent among the top one, three and five.
    FOUND["top"] = {k: round(float(np.mean([truth in row[-k:] for truth, row in zip(i_test, order)])), 3) for k in (1, 3, 5)}
    print("  right intent among the top k:", FOUND["top"])

    # Task 5: the intent of the nearest stored question, by tf-idf rows and by averaged word vectors.
    analyze = vectorizer.build_analyzer()
    vocabulary, position, vectors = word_vectors([analyze(text) for text in train["text"]])
    d_train = message_vectors(train["text"], analyze, position, vectors)
    d_test = message_vectors(test["text"], analyze, position, vectors)
    by_words = i_train[np.asarray((w_test @ w_train.T).argmax(axis=1)).ravel()]
    by_vectors = i_train[(d_test @ d_train.T).argmax(axis=1)]
    FOUND["nearest"] = (round(float((by_words == i_test).mean()), 3), round(float((by_vectors == i_test).mean()), 3))
    print(f"  nearest stored question: tf-idf {FOUND['nearest'][0]}, averaged word vectors {FOUND['nearest'][1]}")

    # Task 6: a window of two words on each side.
    vocabulary2, position2, vectors2 = word_vectors([analyze(text) for text in train["text"]], window=2)
    d2_train = message_vectors(train["text"], analyze, position2, vectors2)
    d2_test = message_vectors(test["text"], analyze, position2, vectors2)
    narrow = (LogisticRegression(max_iter=3000, C=10).fit(d2_train, i_train).predict(d2_test) == i_test).mean()
    FOUND["window"] = (neighbors("pin", vocabulary2, position2, vectors2), neighbors("pin", vocabulary, position, vectors),
                       round(float(narrow), 3))
    print(f"  window of two: neighbors of 'pin' {FOUND['window'][0]} (window of four: {FOUND['window'][1]}); "
          f"averaged vectors classify at {FOUND['window'][2]}")

    assert FOUND["loose"] == (0.13, 0.969, 129, 9), FOUND["loose"]
    assert FOUND["placeholders"]["as collected"] == (0.98, 0.862, 0.973, ["my", "me", "gt", "can", "lt", "that"])
    assert FOUND["placeholders"]["placeholders removed"] == (0.98, 0.862, 0.971, ["my", "me", "that", "can", "ok", "da"])
    assert FOUND["pairs"] == {"single words": (7680, 0.955, 15, 51), "words and pairs": (42642, 0.944, 8, 62)}
    assert FOUND["top"] == {1: 0.9, 3: 0.97, 5: 0.985}
    expect("nearest stored question, tf-idf", FOUND["nearest"][0], 0.791, 0.0005)
    # The word vectors come from a randomized SVD, so results built on them get a small tolerance.
    expect("nearest stored question, word vectors", FOUND["nearest"][1], 0.769, 0.01)
    assert {"passcode", "password"} <= set(FOUND["window"][0]) and {"locked", "blocked"} <= set(FOUND["window"][1])
    expect("window of two, averaged vectors", FOUND["window"][2], 0.830, 0.01)


def lab10():
    print("Lab 10")
    project_folder = Path(__file__).resolve().parents[1] / "lab10_end_to_end_project" / "booking_project"
    sys.path.insert(0, str(project_folder))
    import bookings as project
    from train import train

    file = DATA / "supervised/hotel_bookings/hotel_bookings.zip"
    raw = pd.read_csv(file)
    table = project.read_bookings(file)
    month = table["arrival_date"].dt.to_period("M")
    live_months = pd.period_range("2017-04", "2017-08", freq="M")
    found = {}

    # Task 1: at least one adult in every booking.
    strict = {**project.CONTRACT, "adults": (1, 10)}
    adults_line = [line for line in project.validate(raw, strict) if line.startswith("adults")]
    no_adult = raw[raw["adults"] == 0]
    with_children = no_adult[(no_adult["children"].fillna(0) + no_adult["babies"]) > 0]
    found["adults"] = (adults_line, len(no_adult), len(with_children), round(float(with_children["is_canceled"].mean()), 3),
                       sorted(with_children["market_segment"].value_counts().head(2).index.tolist()))
    print("  at least one adult:", found["adults"])

    # Models used by several tasks: frozen, and retrained on the first day of each month.
    champion, _ = train(table, "2017-01-01")
    challenger, _ = train(table, "2017-01-01", make=project.make_challenger)
    monthly = {}
    for name in pd.period_range("2017-03", "2017-08", freq="M"):
        current = table[month == name]
        champion_now, _ = train(table, name.start_time)
        challenger_now, _ = train(table, name.start_time, make=project.make_challenger)
        monthly[str(name)] = {
            "cancelled": int(current["is_canceled"].sum()),
            "retrained_expected": float(champion_now.predict_proba(current[project.FEATURES])[:, 1].sum()),
            "champion_frozen": roc_auc_score(current["is_canceled"], champion.predict_proba(current[project.FEATURES])[:, 1]),
            "challenger_frozen": roc_auc_score(current["is_canceled"], challenger.predict_proba(current[project.FEATURES])[:, 1]),
            "champion_retrained": roc_auc_score(current["is_canceled"], champion_now.predict_proba(current[project.FEATURES])[:, 1]),
            "challenger_retrained": roc_auc_score(current["is_canceled"],
                                                  challenger_now.predict_proba(current[project.FEATURES])[:, 1])}
    monthly = pd.DataFrame(monthly).T
    live = monthly.loc[[str(name) for name in live_months]]

    # Task 2: a stricter promotion rule, on frozen and on retrained models.
    def promoted_after(lead):
        for i in range(1, len(lead)):
            if lead.iloc[i - 1] > 0.01 and lead.iloc[i] > 0.01:
                return lead.index[i]
        return None
    frozen_lead = (live["challenger_frozen"] - live["champion_frozen"]).round(3)
    retrained_lead = (live["challenger_retrained"] - live["champion_retrained"]).round(3)
    found["rule"] = (frozen_lead.tolist(), promoted_after(frozen_lead), retrained_lead.tolist(), promoted_after(retrained_lead))
    print("  two months ahead by more than 0.01:", found["rule"])

    # Task 3: retrain each quarter (1 April and 1 July) instead of each month.
    quarterly_expected, quarterly_auc = 0.0, []
    for name in live_months:
        start = pd.Timestamp("2017-04-01") if name.month < 7 else pd.Timestamp("2017-07-01")
        model, _ = train(table, start)
        current = table[month == name]
        risk = model.predict_proba(current[project.FEATURES])[:, 1]
        quarterly_expected += risk.sum()
        quarterly_auc.append(roc_auc_score(current["is_canceled"], risk))
    found["quarterly"] = (int(round(quarterly_expected)), round(float(np.mean(quarterly_auc)), 3),
                          int(round(live["retrained_expected"].sum())), round(float(live["champion_retrained"].mean()), 3),
                          int(live["cancelled"].sum()))
    print("  quarterly against monthly retraining (expected, mean AUC, expected, mean AUC, cancelled):", found["quarterly"])

    # Task 4: which hotel drives July? The frozen champion, hotel by hotel.
    hotels = {}
    for name in ["2017-04", "2017-07"]:
        for hotel, group in table[month == name].groupby("hotel"):
            risk = champion.predict_proba(group[project.FEATURES])[:, 1]
            hotels[(name, hotel)] = (len(group), round(float(roc_auc_score(group["is_canceled"], risk)), 3),
                                     round(float(risk.sum() / group["is_canceled"].sum() - 1), 3))
    found["hotels"] = hotels
    print("  by hotel (bookings, AUC, count error):", hotels)

    # Task 5: 600 calls a month.
    hits = {"champion": 0, "challenger": 0, "at_random": 0.0}
    for name in live_months:
        current = table[(month == name) & (table["deposit_type"] == "No Deposit")]
        cancelled = current["is_canceled"].to_numpy()
        hits["at_random"] += cancelled.mean() * 600
        for label, model in [("champion", champion), ("challenger", challenger)]:
            top = np.argsort(model.predict_proba(current[project.FEATURES])[:, 1])[::-1][:600]
            hits[label] += int(cancelled[top].sum())
    found["calls"] = {key: int(round(value)) for key, value in hits.items()}
    print("  600 calls a month, future cancellations reached in five months:", found["calls"])

    # Task 6: last month's ratio applied to the retrained model of each month.
    corrected = []
    previous = monthly.index.tolist()
    for i, name in enumerate(previous[1:], start=1):
        ratio = monthly.loc[previous[i - 1], "cancelled"] / monthly.loc[previous[i - 1], "retrained_expected"]
        corrected.append(monthly.loc[name, "retrained_expected"] * ratio)
    found["both"] = (int(round(sum(corrected))), round(float(sum(corrected) / live["cancelled"].sum() - 1), 3),
                     int(sum(abs(c / a - 1) < abs(e / a - 1) for c, e, a in zip(corrected, live["retrained_expected"],
                                                                             live["cancelled"]))))
    print("  retrained and corrected (expected, error, months better than retrained alone):", found["both"])

    # The warm-up on paper.
    then, now = np.array([0.5, 0.3, 0.2]), np.array([0.4, 0.3, 0.3])
    warm_psi = float(((now - then) * np.log(now / then)).sum())
    folds = np.array([0.830, 0.860, 0.850, 0.844])
    warm_spread = float(folds.std())
    warm_corrected = 2500 * 2450 / 2300
    print(f"  warm-up: PSI {warm_psi:.3f}; spread {warm_spread:.4f} against a gap of {folds.mean() - 0.840:.3f};"
          f" corrected May {warm_corrected:,.0f}")
    expect("warm-up PSI", warm_psi, 0.063, 0.0005)
    expect("warm-up spread", warm_spread, 0.0109, 0.00005)
    expect("warm-up correction", warm_corrected, 2663, 0.5)

    assert found["adults"] == (["adults: 415 values outside 1 to 10"], 403, 223, 0.377, ["Direct", "Online TA"])
    assert found["rule"] == ([0.006, 0.008, 0.006, 0.024, 0.006], None, [0.007, 0.008, 0.01, 0.027, 0.015], "2017-08")
    assert found["quarterly"] == (10741, 0.835, 10876, 0.837, 11464)
    assert found["hotels"] == {("2017-04", "City Hotel"): (3919, 0.859, -0.025), ("2017-04", "Resort Hotel"): (1742, 0.861, -0.189),
                               ("2017-07", "City Hotel"): (3559, 0.763, -0.003), ("2017-07", "Resort Hotel"): (1754, 0.818, -0.237)}
    assert found["calls"] == {"champion": 2240, "challenger": 2186, "at_random": 1034}
    assert found["both"] == (11284, -0.016, 2)
    return found


if __name__ == "__main__":
    labs = {name: function for name, function in sorted(globals().items()) if name.startswith("lab") and name[3:].isdigit()}
    for name in sys.argv[1:] or labs:
        labs[name]()
    print("\nEvery number above matches the book.")
