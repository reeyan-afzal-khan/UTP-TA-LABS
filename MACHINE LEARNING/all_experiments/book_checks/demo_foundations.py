"""The small worked numbers of Chapters 4, 6 and 10 to 13: data, statistics, losses, metrics, training.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/book_checks/demo_foundations.py
It takes about half a minute.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression, LogisticRegression, Ridge
from sklearn.metrics import average_precision_score, mean_absolute_error, precision_score, r2_score, recall_score, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, learning_curve, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.tree import DecisionTreeClassifier

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check


def make_preprocess(num_cols, cat_cols):
    return ColumnTransformer([
        ("num", Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), num_cols),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ])


# ---------------------------------------------------------------- Chapter 4: data
def clean_messy_table():
    """Fixed, label-blind rules that may run before the split, each one logged."""
    raw = pd.DataFrame({
        "student_id": [101, 102, 102, 103, 104, 105],
        "age":        ["19", "20", "20", "-1", "22", None],
        "hours":      ["6", "8 ", "8 ", "30", "4", "five"],
        "programme":  ["CS", "cs", "cs", "IT ", "IT", "CS"],
        "mark":       [58, 64, 64, 71, 49, 66],
    })
    log = {"rows in": len(raw)}
    table = raw.drop_duplicates(subset="student_id").copy()               # one row per student
    log["duplicate rows dropped"] = len(raw) - len(table)
    table["programme"] = table["programme"].str.strip().str.upper()       # one spelling per programme
    table["age"] = pd.to_numeric(table["age"], errors="coerce")           # a bad value becomes missing
    table["hours"] = pd.to_numeric(table["hours"].str.strip(), errors="coerce")
    log["hours that would not parse"] = int(table["hours"].isna().sum())
    impossible = table["age"] < 0                                         # a domain rule, not a statistic
    log["impossible ages set to missing"] = int(impossible.sum())
    table.loc[impossible, "age"] = np.nan
    table["hours_suspicious"] = table["hours"] > 25                       # unusual, not impossible: flag it
    log["unusual hours flagged"] = int(table["hours_suspicious"].sum())
    log["rows out"] = len(table)
    return table, log


def chapter04():
    print("Chapter 4")
    table, log = clean_messy_table()
    print(table.to_string(index=False))
    print(log)
    FOUND["log"] = log

    ages = np.array([19, 20, 22, 21, 58, np.nan, np.nan, 23])
    train_ages = ages[~np.isnan(ages)]
    print(f"Training ages: mean {train_ages.mean():.1f}, median {np.median(train_ages):.1f}")
    FOUND["age_mean"], FOUND["age_median"] = train_ages.mean(), np.median(train_ages)

    # Two rulers: the nearest neighbor of customer A depends on the units.
    customers = np.array([[30, 50_000], [40, 90_000], [60, 52_000]], dtype=float)
    sd = np.array([20, 100_000.0])
    raw_ab, raw_ac = np.linalg.norm(customers[0] - customers[1]), np.linalg.norm(customers[0] - customers[2])
    scaled = customers / sd
    z_ab, z_ac = np.linalg.norm(scaled[0] - scaled[1]), np.linalg.norm(scaled[0] - scaled[2])
    print(f"Raw distance A-B {raw_ab:,.2f}, A-C {raw_ac:,.2f}. Scaled A-B {z_ab:.2f}, A-C {z_ac:.2f}")
    FOUND["raw_ab"], FOUND["raw_ac"], FOUND["z_ab"], FOUND["z_ac"] = raw_ab, raw_ac, z_ab, z_ac

    values = np.array([2400, 36, 23075, 70, 1, 905], dtype=float)
    minmax = (values - values.min()) / (values.max() - values.min())
    q1, median, q3 = np.percentile(values, [25, 50, 75])
    robust = (values - median) / (q3 - q1)
    print("Values", values.tolist())
    print("Min-max", minmax.round(4).tolist())
    print(f"Median {median}, Q1 {q1}, Q3 {q3}, IQR {q3 - q1}")
    print("Robust", robust.round(2).tolist())
    FOUND["minmax"], FOUND["robust"] = minmax, robust

    lead = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")["lead_time"]     # Lab 1's hotel bookings
    print(f"Lead time: skew {lead.skew():.2f}, median {lead.median():.0f}, mean {lead.mean():.1f}, max {lead.max()}; "
          f"log(1+lead time) skew {np.log1p(lead).skew():.2f}")
    FOUND["lead_skew"], FOUND["loglead_skew"] = lead.skew(), np.log1p(lead).skew()

    # Leakage on pure noise: the labels are coin flips, so honest accuracy must be near 0.5.
    rng = np.random.default_rng(7)
    X = rng.normal(size=(100, 1000))
    y = rng.integers(0, 2, size=100)
    folds = StratifiedKFold(5, shuffle=True, random_state=0)
    picked = SelectKBest(f_classif, k=20).fit_transform(X, y)                   # sees every label: leak
    leaky = cross_val_score(LogisticRegression(max_iter=1000), picked, y, cv=folds).mean()
    honest = cross_val_score(Pipeline([("pick", SelectKBest(f_classif, k=20)),  # refit inside each fold
                                       ("model", LogisticRegression(max_iter=1000))]), X, y, cv=folds).mean()
    print(f"Noise features, coin-flip labels: select then CV {leaky:.2f}, select inside CV {honest:.2f}")
    FOUND["leaky"], FOUND["honest"] = leaky, honest


# ---------------------------------------------------------- Chapter 6: statistics
def chapter06():
    print("\nChapter 6")
    pay = np.array([30, 32, 35, 38, 500], dtype=float)
    print(f"Pay: mean {pay.mean():.0f}, median {np.median(pay):.0f}")
    marks = np.array([47, 50, 59, 65, 68, 77, 62, 52, 43, 38], dtype=float)
    q1, q2, q3 = np.percentile(marks, [25, 50, 75])
    s, se = marks.std(ddof=1), marks.std(ddof=1) / np.sqrt(len(marks))
    print(f"Marks: median {q2}, Q1 {q1}, Q3 {q3}, IQR {q3 - q1}")
    print(f"Sample sd {s:.2f}, standard error {se:.2f}, interval {marks.mean() - 1.96 * se:.1f} to {marks.mean() + 1.96 * se:.1f}")
    rng = np.random.default_rng(11)
    medians = [np.median(rng.choice(marks, size=len(marks), replace=True)) for _ in range(5000)]
    low, high = np.percentile(medians, [2.5, 97.5])
    print(f"Bootstrap of the median, 5000 resamples: {low:.1f} to {high:.1f}")
    FOUND.update(iqr=q3 - q1, sd=s, se=se, boot=(low, high))

    bars = np.repeat(np.arange(1, 8), [18, 13, 8, 5, 3, 2, 1])
    print(f"Skewed bars of the figure: mean {bars.mean():.2f}, median {np.median(bars):.0f}")
    FOUND["bars"] = (bars.mean(), np.median(bars))

    population = 10_000
    sick = population // 100
    true_pos, false_pos = sick * 0.90, (population - sick) * 0.05
    print(f"Bayes in people: {sick} sick, {true_pos:.0f} flagged; {population - sick} healthy, {false_pos:.0f} flagged; "
          f"chance {true_pos / (true_pos + false_pos):.3f}")
    FOUND["bayes"] = true_pos / (true_pos + false_pos)

    prices, basket = np.array([3.5, 1.2, 2.0]), np.array([2, 3, 1])
    print(f"Receipt: {prices @ basket:.2f}")
    X, beta = np.array([[1, 2], [1, 4], [1, 6]], dtype=float), np.array([40.0, 3.0])
    print(f"Matrix times vector: {(X @ beta).tolist()}")
    a, b, c = np.array([2, 1, 0.0]), np.array([4, 2, 0.0]), np.array([0, 1, 3.0])
    cosine = lambda u, v: u @ v / (np.linalg.norm(u) * np.linalg.norm(v))
    print(f"Cosine a-b {cosine(a, b):.2f}, a-c {cosine(a, c):.2f}; Euclidean a-b {np.linalg.norm(a - b):.2f}, a-c {np.linalg.norm(a - c):.2f}")
    FOUND["receipt"], FOUND["cos_ac"], FOUND["dist_ab"], FOUND["dist_ac"] = prices @ basket, cosine(a, c), np.linalg.norm(a - b), np.linalg.norm(a - c)


# ---------------------------------------------------------------- Chapter 10: losses
def chapter10():
    print("\nChapter 10")
    one_big, four_small = np.array([8.0]), np.array([2.0, 2, 2, 2])
    print(f"One miss of 8: absolute {one_big.sum():.0f}, squared {(one_big ** 2).sum():.0f}. "
          f"Four misses of 2: absolute {four_small.sum():.0f}, squared {(four_small ** 2).sum():.0f}")
    huber = lambda e, d=1.0: np.where(np.abs(e) <= d, 0.5 * e ** 2, d * (np.abs(e) - 0.5 * d))
    print("Error 0.5, 2, 8: squared", [0.25, 4, 64], " absolute", [0.5, 2, 8], " Huber", huber(np.array([0.5, 2.0, 8.0])).tolist())

    # Baselines against the labs' models, on the labs' own splits.
    cars = used_cars()
    c_tr, c_va = train_test_split(cars, test_size=0.20, random_state=42)
    base_car = mean_absolute_error(c_va["price_usd"], np.full(len(c_va), c_tr["price_usd"].mean()))
    ols_car = mean_absolute_error(c_va["price_usd"], Pipeline([("p", make_preprocess(CAR_NUM, CAR_CAT)), ("m", LinearRegression())])
                                  .fit(c_tr, c_tr["price_usd"]).predict(c_va))
    h_tr, h_va, yh_tr, yh_va = hotel_date_split()
    base_hotel = 1 - yh_va.mean()
    acc_hotel = (Pipeline([("p", make_preprocess(HOTEL_NUM, HOTEL_CAT)), ("m", LogisticRegression(max_iter=3000))])
                 .fit(h_tr, yh_tr).predict(h_va) == yh_va).mean()
    # Lab 1's bank calls, with the duration left out because it is known only after the call.
    bank = pd.read_csv(DATA / "supervised/bank_marketing/bank_marketing.csv", sep=";").drop_duplicates().reset_index(drop=True)
    X_b, y_b = bank.drop(columns=["y", "duration"]), (bank["y"] == "yes").astype(int)
    b_tr, b_va, yb_tr, yb_va = train_test_split(X_b, y_b, test_size=0.25, random_state=42, stratify=y_b)
    num_b = X_b.select_dtypes(include="number").columns.tolist()
    cat_b = X_b.select_dtypes(exclude="number").columns.tolist()
    calls = Pipeline([("p", make_preprocess(num_b, cat_b)), ("m", LogisticRegression(max_iter=2000))]).fit(b_tr, yb_tr)
    base_bank, acc_bank = 1 - yb_va.mean(), (calls.predict(b_va) == yb_va).mean()
    print(f"Always-the-mean MAE: used-car prices {base_car:,.0f} (linear regression {ols_car:,.0f}); "
          f"hotel cancellations in 2017: always 'kept' {base_hotel:.3f} (logistic regression {acc_hotel:.3f}); "
          f"bank calls: always 'no' {base_bank:.3f}, logistic regression {acc_bank:.3f}")
    FOUND.update(base_car=base_car, ols_car=ols_car, base_hotel=base_hotel, acc_hotel=acc_hotel,
                 base_bank=base_bank, acc_bank=acc_bank)


# ------------------------------------------------- the labs' datasets, prepared as the labs prepare them
CAR_NUM, CAR_CAT = ["age", "mileage_miles"], ["make", "body_type", "drive", "fuel_type"]
HOTEL_NUM = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
             "previous_cancellations", "previous_bookings_not_canceled", "adr", "required_car_parking_spaces",
             "total_of_special_requests", "total_nights", "total_guests", "with_children", "log_lead_time",
             "cancelled_before"]
HOTEL_CAT = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]


def used_cars():
    """Lab 2's used-car listings after its fixed cleaning rules."""
    cars = pd.read_csv(DATA / "supervised/used_cars/used_cars.zip", low_memory=False)
    used = cars[(cars["stock_type"] == "Used") & cars["price_usd"].between(1_000, 200_000) & (cars["mileage_miles"] > 100)].copy()

    def tidy(column, groups):
        text = column.str.lower()
        return pd.Series(np.select([text.str.contains(p, na=False) for p in groups.values()], list(groups), default=None),
                         index=column.index)

    used["drive"] = tidy(used["drivetrain"], {"AWD": "all|awd", "4WD": "four|4wd|4x4", "FWD": "front|fwd", "RWD": "rear|rwd"})
    used["fuel_type"] = tidy(used["fuel"], {"plug-in hybrid": "plug", "hybrid": "hybrid|mild", "electric": "electric",
                                            "diesel": "diesel", "flex fuel": "flex|e85", "gasoline": "gas|petrol|unleaded"})
    used["age"] = (2026 - used["year"]).clip(lower=0)
    return used


def hotel_date_split():
    """Lab 2's hotel bookings with Lab 1's engineered columns: arrivals to 2016 train, arrivals in 2017 validate."""
    h = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
    text_date = h["arrival_date_year"].astype(str) + "-" + h["arrival_date_month"] + "-" + h["arrival_date_day_of_month"].astype(str)
    h["arrival_date"] = pd.to_datetime(text_date, format="%Y-%B-%d")
    h = h.sort_values("arrival_date", kind="stable").reset_index(drop=True)
    children = h["children"].fillna(0).astype(int)
    h["total_nights"] = h["stays_in_weekend_nights"] + h["stays_in_week_nights"]
    h["total_guests"] = h["adults"] + children + h["babies"]
    h["with_children"] = ((children + h["babies"]) > 0).astype(int)
    h["log_lead_time"] = np.log1p(h["lead_time"])
    h["cancelled_before"] = (h["previous_cancellations"] > 0).astype(int)
    train = (h["arrival_date"] < "2017-01-01").to_numpy()
    X, y = h[HOTEL_NUM + HOTEL_CAT], h["is_canceled"]
    return X[train], X[~train], y[train], y[~train]


def churn_data():
    """Lab 2's telecom customers, with Lab 1's repair of TotalCharges."""
    churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
    churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)
    X, y = churn.drop(columns=["customerID", "Churn"]), (churn["Churn"] == "Yes").astype(int)
    return X, y, X.select_dtypes(include="number").columns.tolist(), X.select_dtypes(exclude="number").columns.tolist()


def loan_sample():
    """Lab 3's 20,000 loans and thirteen numbers known at application, split 75/25."""
    loans = pd.read_csv(DATA / "supervised/lending_club/lending_club_2014_2015.zip", low_memory=False)
    issued = pd.to_datetime(loans["issue_d"], format="%b-%Y")
    first_credit = pd.to_datetime(loans["earliest_cr_line"], format="%b-%Y")
    X = pd.DataFrame({
        "loan_amnt": loans["loan_amnt"], "term_months": loans["term"].str.extract(r"(\d+)")[0].astype(int),
        "int_rate": loans["int_rate"], "log_income": np.log1p(loans["annual_inc"]), "dti": loans["dti"],
        "fico": (loans["fico_range_low"] + loans["fico_range_high"]) / 2, "revol_util": loans["revol_util"],
        "inquiries_6m": loans["inq_last_6mths"], "delinq_2y": loans["delinq_2yrs"], "open_acc": loans["open_acc"],
        "mort_acc": loans["mort_acc"],
        "emp_years": loans["emp_length"].replace({"< 1 year": "0 years"}).str.extract(r"(\d+)")[0].astype(float),
        "credit_years": (issued - first_credit).dt.days / 365.25,
    }).sample(20_000, random_state=42)
    y = (loans.loc[X.index, "loan_status"] == "Charged Off").astype(int)
    return train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)


# ---------------------------------------------------------- Chapter 11: evaluation
def chapter11():
    print("\nChapter 11")
    scores = np.array([0.95, 0.85, 0.70, 0.60, 0.55, 0.40, 0.30, 0.10])
    labels = np.array([1, 1, 0, 1, 0, 1, 0, 0])
    pos, neg = scores[labels == 1], scores[labels == 0]
    wins = sum(p > n for p in pos for n in neg)
    print(f"Eight scored cases: {wins} of {len(pos) * len(neg)} pairs ranked correctly, AUC {wins / (len(pos) * len(neg)):.4f}, "
          f"sklearn {roc_auc_score(labels, scores):.4f}")
    print("threshold  TP FP FN TN  precision recall  FPR")
    table = {}
    for t in (0.9, 0.65, 0.5, 0.35, 0.05):
        pred = scores >= t
        tp, fp, fn, tn = (pred & (labels == 1)).sum(), (pred & (labels == 0)).sum(), (~pred & (labels == 1)).sum(), (~pred & (labels == 0)).sum()
        table[t] = (int(tp), int(fp), int(fn), int(tn))
        print(f"  {t:.2f}     {tp} {fp}  {fn}  {tn}    {tp / (tp + fp):.2f}     {tp / (tp + fn):.2f}   {fp / (fp + tn):.2f}")
    FOUND.update(wins=wins, table=table)

    right, sizes = np.array([90, 5, 1]), np.array([100, 10, 2])
    print(f"Three classes: micro {right.sum() / sizes.sum():.3f}, macro {(right / sizes).mean():.3f}")
    FOUND["micro"], FOUND["macro"] = right.sum() / sizes.sum(), (right / sizes).mean()

    # Lab 2's churn model: the setting it chose (C = 10), on its own split, and its uncertainty.
    X, y, num, cat = churn_data()
    churn_model = lambda: Pipeline([("preprocess", make_preprocess(num, cat)), ("model", LogisticRegression(C=10, max_iter=3000))])
    X_tr, X_te, y_tr, y_te = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    prob = churn_model().fit(X_tr, y_tr).predict_proba(X_te)[:, 1]
    auc = roc_auc_score(y_te, prob)
    print(f"Churn logistic (C=10): test AUC {auc:.3f} on {len(y_te)} customers")
    FOUND["churn_auc"] = auc
    rng = np.random.default_rng(3)
    y_arr = y_te.to_numpy()
    boot = []
    for _ in range(2000):
        pick = rng.integers(0, len(y_arr), len(y_arr))
        boot.append(roc_auc_score(y_arr[pick], prob[pick]))
    low, high = np.percentile(boot, [2.5, 97.5])
    print(f"Bootstrap interval for that AUC: {low:.3f} to {high:.3f}")
    FOUND["churn_boot"] = (low, high)
    folds = cross_val_score(churn_model(), X_tr, y_tr, cv=StratifiedKFold(5, shuffle=True, random_state=42), scoring="roc_auc")
    print("Five-fold AUC on the training rows:", folds.round(3).tolist(), f"mean {folds.mean():.3f}, sd {folds.std():.3f}")
    FOUND["folds"] = folds
    seeds = []
    for seed in range(5):
        a, b, ya, yb = train_test_split(X, y, test_size=0.25, random_state=seed, stratify=y)
        seeds.append(roc_auc_score(yb, churn_model().fit(a, ya).predict_proba(b)[:, 1]))
    print("Same model, five other split seeds, AUC:", np.round(seeds, 3).tolist())
    FOUND["seed_aucs"] = seeds

    # Points for the ROC and precision-recall figure: Lab 2's hotel model on 2017, and Lab 3's loan model.
    h_tr, h_va, yh_tr, yh_va = hotel_date_split()
    ph = Pipeline([("p", make_preprocess(HOTEL_NUM, HOTEL_CAT)), ("m", LogisticRegression(max_iter=3000))]).fit(h_tr, yh_tr).predict_proba(h_va)[:, 1]
    l_tr, l_va, yl_tr, yl_va = loan_sample()
    pl = Pipeline([("i", SimpleImputer(strategy="median")), ("s", StandardScaler()),
                   ("m", LogisticRegression(max_iter=2000))]).fit(l_tr, yl_tr).predict_proba(l_va)[:, 1]
    print(f"Hotel logistic on 2017: AUC {roc_auc_score(yh_va, ph):.3f}, average precision {average_precision_score(yh_va, ph):.3f}")
    print(f"Loan logistic: AUC {roc_auc_score(yl_va, pl):.3f}, average precision {average_precision_score(yl_va, pl):.3f}")
    FOUND["h_auc"], FOUND["l_auc"] = roc_auc_score(yh_va, ph), roc_auc_score(yl_va, pl)
    for name, truth, p in [("hotel", yh_va.to_numpy(), ph), ("loans", yl_va.to_numpy(), pl)]:
        roc, pr = [], []
        for t in np.linspace(1, 0, 21):
            yes = p >= t
            tp, fp = (yes & (truth == 1)).sum(), (yes & (truth == 0)).sum()
            roc.append((round(fp / (truth == 0).sum(), 3), round(tp / (truth == 1).sum(), 3)))
            if tp + fp:
                pr.append((round(tp / (truth == 1).sum(), 3), round(tp / (tp + fp), 3)))
        print(f"{name} ROC", " ".join(f"({a},{b})" for a, b in roc))
        print(f"{name} PR ", " ".join(f"({a},{b})" for a, b in pr))
        print(f"{name} positive rate {truth.mean():.3f}")
    # Lab 2's threshold table for the hotel model, quoted in the chapter on linear classifiers.
    print("Hotel thresholds: flagged, precision, recall, cancellations missed")
    hotel_table = {}
    for t in (0.30, 0.50, 0.70):
        yes = ph >= t
        hotel_table[t] = (int(yes.sum()), precision_score(yh_va, yes), recall_score(yh_va, yes), int((~yes & (yh_va == 1)).sum()))
        print(f"  {t:.2f}  {hotel_table[t][0]}  {hotel_table[t][1]:.2f}  {hotel_table[t][2]:.2f}  {hotel_table[t][3]}")
    FOUND["hotel_table"] = hotel_table


# ------------------------------------------------------------ Chapter 12: training
def chapter12():
    print("\nChapter 12")
    predictions = {"rigid": [2.6, 3.0, 3.4], "balanced": [1.0, 2.0, 3.0], "wild": [-1.0, 2.0, 5.0]}
    for name, p in predictions.items():
        p = np.array(p)
        print(f"  {name}: bias^2 {(p.mean() - 2) ** 2:.3f} variance {p.var():.3f} total {(p.mean() - 2) ** 2 + p.var() + 1:.3f}")

    X, y, num, cat = churn_data()
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    sizes = [50, 200, 500, 1000, 2000, 5634]
    for name, estimator in [("logistic", LogisticRegression(max_iter=3000)),
                            ("unrestricted tree", DecisionTreeClassifier(random_state=42))]:
        pipe = Pipeline([("preprocess", make_preprocess(num, cat)), ("model", estimator)])
        got, train, valid = learning_curve(pipe, X, y, train_sizes=sizes, cv=folds, scoring="accuracy", shuffle=True, random_state=0)
        print(f"Learning curve, {name}: rows {got.tolist()}")
        print("  training error  ", (1 - train.mean(axis=1)).round(3).tolist())
        print("  validation error", (1 - valid.mean(axis=1)).round(3).tolist())
        FOUND[f"lc_{name}"] = (1 - train.mean(axis=1), 1 - valid.mean(axis=1))

    cards = pd.read_csv(DATA / "unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip")         # Lab 5's card transactions
    Xf = cards[[f"V{i}" for i in range(1, 29)]].assign(log_amount=np.log1p(cards["Amount"]))
    Xf_tr, Xf_va, yf_tr, yf_va = train_test_split(Xf, cards["Class"], test_size=0.30, random_state=42, stratify=cards["Class"])
    print(f"Fraud rate {yf_va.mean():.4f} in {len(yf_va)} held-out transactions ({int(yf_va.sum())} frauds); "
          f"always-no accuracy {1 - yf_va.mean():.4f}")
    FOUND["fraud_rate"] = (yf_va.mean(), len(yf_va), int(yf_va.sum()))
    for name, weight, t in [("plain, 0.50", None, 0.5), ("plain, 0.10", None, 0.1), ("balanced, 0.50", "balanced", 0.5)]:
        m = Pipeline([("scale", StandardScaler()), ("model", LogisticRegression(max_iter=2000, class_weight=weight))]).fit(Xf_tr, yf_tr)
        pred = m.predict_proba(Xf_va)[:, 1] >= t
        print(f"  {name}: flagged {pred.sum()}, precision {precision_score(yf_va, pred, zero_division=0):.3f}, "
              f"recall {recall_score(yf_va, pred):.3f}, accuracy {(pred == yf_va).mean():.4f}")
        FOUND[f"fraud_{name}"] = (int(pred.sum()), precision_score(yf_va, pred, zero_division=0), recall_score(yf_va, pred))


# ---------------------------------------------------- Chapter 13: linear regression
def chapter13():
    print("\nChapter 13")
    cars = used_cars()
    train, valid = train_test_split(cars, test_size=0.20, random_state=42)
    plain = Pipeline([("preprocess", make_preprocess(CAR_NUM, CAR_CAT)), ("model", LinearRegression())])
    plain.fit(train, train["price_usd"])
    pred_plain = plain.predict(valid)
    r2_plain, mae_plain = r2_score(valid["price_usd"], pred_plain), mean_absolute_error(valid["price_usd"], pred_plain)

    names = plain.named_steps["preprocess"].get_feature_names_out()
    coefficients = pd.Series(plain.named_steps["model"].coef_, index=names)
    gap = coefficients["cat__make_Porsche"] - coefficients["cat__make_Toyota"]
    print(f"Car-price coefficients: one standard deviation of mileage {coefficients['num__mileage_miles']:,.0f}, "
          f"of age {coefficients['num__age']:,.0f}; Porsche minus Toyota {gap:,.0f}")
    FOUND.update(gap=gap, mile_coef=coefficients["num__mileage_miles"], age_coef=coefficients["num__age"])

    # The missing idea is which car it is: the model, as a category.
    richer = Pipeline([("preprocess", make_preprocess(CAR_NUM, CAR_CAT + ["model"])), ("model", LinearRegression())])
    pred = richer.fit(train, train["price_usd"]).predict(valid)
    r2_rich, mae_rich = r2_score(valid["price_usd"], pred), mean_absolute_error(valid["price_usd"], pred)
    print(f"Car prices: plain R2 {r2_plain:.3f} MAE {mae_plain:,.0f}; with the model R2 {r2_rich:.3f} MAE {mae_rich:,.0f}; "
          f"{cars['model'].nunique()} models")
    FOUND.update(r2_plain=r2_plain, mae_plain=mae_plain, r2_rich=r2_rich, mae_rich=mae_rich)
    ridge_pred = Pipeline([("preprocess", make_preprocess(CAR_NUM, CAR_CAT)), ("model", Ridge(alpha=10.0))]).fit(train, train["price_usd"]).predict(valid)
    spread = pd.Series(valid["price_usd"].to_numpy() - ridge_pred).groupby(pd.qcut(ridge_pred, 4, labels=False)).std()
    corr = cars["age"].corr(cars["mileage_miles"])
    print(f"  ridge residual spread, cheapest to dearest quarter: {spread.round(0).tolist()}; age vs mileage r = {corr:.2f}")
    FOUND.update(spread_low=spread.iloc[0], spread_high=spread.iloc[-1], age_corr=corr)

    # Ridge rescues the overfitted degree-7 curve from the study log.
    hours = np.arange(2, 21, 2, dtype=float)
    mark = np.array([47, 50, 59, 65, 68, 77, 62, 52, 43, 38], dtype=float)
    z = (hours - hours.mean()) / hours.std()
    powers = np.column_stack([z ** d for d in range(1, 8)])

    def ridge_predict(train_x, train_y, test_x, lam):
        mean_x, mean_y = train_x.mean(axis=0), train_y.mean()
        a = (train_x - mean_x).T @ (train_x - mean_x) + lam * np.eye(train_x.shape[1])
        beta = np.linalg.solve(a, (train_x - mean_x).T @ (train_y - mean_y))
        return (test_x - mean_x) @ beta + mean_y, beta

    print("Ridge on degree 7: lambda, training MSE, leave-one-out MSE, largest coefficient")
    table = {}
    for lam in (0.0, 0.01, 0.1, 1.0, 10.0):
        fit, beta = ridge_predict(powers, mark, powers, lam + 1e-12)
        errors = []
        for i in range(10):
            keep = np.arange(10) != i
            p, _ = ridge_predict(powers[keep], mark[keep], powers[[i]], lam + 1e-12)
            errors.append((p[0] - mark[i]) ** 2)
        table[lam] = (((fit - mark) ** 2).mean(), np.mean(errors), np.abs(beta).max())
        print(f"  {lam:>5}: {table[lam][0]:8.2f} {table[lam][1]:10.2f} {table[lam][2]:9.2f}")
    FOUND["ridge"] = table


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert f["log"] == {"rows in": 6, "duplicate rows dropped": 1, "hours that would not parse": 1,
                        "impossible ages set to missing": 1, "unusual hours flagged": 1, "rows out": 5}
    assert close(f["age_mean"], 27.17) and f["age_median"] == 21.5
    assert close(f["raw_ab"], 40000.0) and close(f["raw_ac"], 2000.22) and close(f["z_ab"], 0.64) and close(f["z_ac"], 1.50)
    assert close(f["minmax"][0], 0.104, 0.001) and close(f["minmax"][5], 0.0392, 0.001)
    assert close(f["robust"][2], 11.40) and close(f["robust"][4], -0.25)
    assert close(f["lead_skew"], 1.35) and close(f["loglead_skew"], -0.87)
    assert close(f["leaky"], 0.80, 0.03) and close(f["honest"], 0.52, 0.03)
    assert close(f["bars"][0], 2.44) and f["bars"][1] == 2
    assert f["iqr"] == 16.5 and close(f["sd"], 12.19) and close(f["se"], 3.85)
    assert close(f["boot"][0], 46.5, 1.5) and close(f["boot"][1], 65.0, 1.5)
    assert close(f["bayes"], 0.154, 0.001) and close(f["receipt"], 12.6)
    assert close(f["cos_ac"], 0.14) and close(f["dist_ab"], 2.24) and close(f["dist_ac"], 3.61)
    assert close(f["base_car"], 15408, 1) and close(f["ols_car"], 9009, 2)
    assert close(f["base_hotel"], 0.613, 0.001) and close(f["acc_hotel"], 0.764, 0.001)
    assert close(f["base_bank"], 0.887, 0.001) and close(f["acc_bank"], 0.899, 0.001)
    assert f["wins"] == 13 and f["table"][0.5] == (3, 2, 1, 2) and f["table"][0.35] == (4, 2, 0, 2)
    assert close(f["micro"], 0.857, 0.001) and close(f["macro"], 0.633, 0.001)
    assert close(f["churn_auc"], 0.846, 0.002) and close(f["churn_boot"][0], 0.826, 0.005) and close(f["churn_boot"][1], 0.866, 0.005)
    assert close(f["h_auc"], 0.824, 0.002) and close(f["l_auc"], 0.731, 0.002)
    assert close(f["folds"].mean(), 0.844, 0.002) and close(f["folds"].std(), 0.015, 0.002)
    assert f["hotel_table"][0.3][0] == 20052 and f["hotel_table"][0.5][0] == 11095 and f["hotel_table"][0.7][0] == 4822
    assert [f["hotel_table"][t][3] for t in (0.3, 0.5, 0.7)] == [3558, 7129, 11117]
    train, valid = f["lc_logistic"]
    assert close(train[-1], 0.194, 0.005) and close(valid[-1], 0.195, 0.005)
    train, valid = f["lc_unrestricted tree"]
    assert close(train[-1], 0.002, 0.005) and close(valid[-1], 0.274, 0.01)
    assert close(min(f["seed_aucs"]), 0.838, 0.003) and close(max(f["seed_aucs"]), 0.855, 0.003)
    assert f["fraud_rate"][1:] == (85443, 148)
    assert f["fraud_plain, 0.50"][0] == 106 and close(f["fraud_plain, 0.50"][1], 0.858, 0.001) and close(f["fraud_plain, 0.50"][2], 0.615, 0.001)
    assert f["fraud_plain, 0.10"][0] == 141 and close(f["fraud_plain, 0.10"][1], 0.752, 0.001) and close(f["fraud_plain, 0.10"][2], 0.716, 0.001)
    assert f["fraud_balanced, 0.50"][0] == 2051 and close(f["fraud_balanced, 0.50"][1], 0.063, 0.001) and close(f["fraud_balanced, 0.50"][2], 0.878, 0.001)
    assert close(f["gap"], 37920, 5) and close(f["mile_coef"], -8553, 2) and close(f["age_coef"], -3302, 2)
    assert close(f["spread_low"], 9172, 2) and close(f["spread_high"], 23079, 2) and close(f["age_corr"], 0.61)
    assert close(f["r2_plain"], 0.575, 0.001) and close(f["r2_rich"], 0.792, 0.001) and close(f["mae_rich"], 5754, 2)
    assert close(f["ridge"][0.0][1], 3907.53, 1) and close(f["ridge"][0.1][1], 101.01, 0.5) and close(f["ridge"][0.1][0], 7.50, 0.02)
    print("\nEvery number above matches the book.")


def main():
    chapter04()
    chapter06()
    chapter10()
    chapter11()
    chapter12()
    chapter13()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
