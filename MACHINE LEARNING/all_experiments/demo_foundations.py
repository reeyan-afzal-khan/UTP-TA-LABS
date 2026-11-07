"""The small worked numbers of Chapters 3 and 5 to 9: data, statistics, metrics, training.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/demo_foundations.py
It takes about half a minute.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.metrics import average_precision_score, mean_absolute_error, precision_score, r2_score, recall_score, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, learning_curve, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.tree import DecisionTreeClassifier

DATA = Path(__file__).resolve().parent.parent / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check


def make_preprocess(num_cols, cat_cols):
    return ColumnTransformer([
        ("num", Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), num_cols),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ])


# ---------------------------------------------------------------- Chapter 3: data
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


def chapter03():
    print("Chapter 3")
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

    fare = pd.read_csv(DATA / "titanic_dataset.csv")["Fare"]
    print(f"Fare: skew {fare.skew():.2f}, median {fare.median():.2f}, mean {fare.mean():.2f}, max {fare.max():.2f}; "
          f"log(1+fare) skew {np.log1p(fare).skew():.2f}")
    FOUND["fare_skew"], FOUND["logfare_skew"] = fare.skew(), np.log1p(fare).skew()

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


# ---------------------------------------------------------- Chapter 5: statistics
def chapter05():
    print("\nChapter 5")
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


# ---------------------------------------------------------------- Chapter 6: losses
def chapter06():
    print("\nChapter 6")
    one_big, four_small = np.array([8.0]), np.array([2.0, 2, 2, 2])
    print(f"One miss of 8: absolute {one_big.sum():.0f}, squared {(one_big ** 2).sum():.0f}. "
          f"Four misses of 2: absolute {four_small.sum():.0f}, squared {(four_small ** 2).sum():.0f}")
    huber = lambda e, d=1.0: np.where(np.abs(e) <= d, 0.5 * e ** 2, d * (np.abs(e) - 0.5 * d))
    print("Error 0.5, 2, 8: squared", [0.25, 4, 64], " absolute", [0.5, 2, 8], " Huber", huber(np.array([0.5, 2.0, 8.0])).tolist())

    # Baselines against the labs' models, on the labs' own splits.
    insurance = pd.read_csv(DATA / "medical_cost_personal_dataset.csv")
    _, _, y_tr, y_va = train_test_split(insurance.drop(columns="charges"), insurance["charges"], test_size=0.20, random_state=42)
    base_ins = mean_absolute_error(y_va, np.full(len(y_va), y_tr.mean()))
    bikes = pd.read_csv(DATA / "bike_sharing_dataset_day.csv").sort_values("dteday")
    cut = int(len(bikes) * 0.80)
    base_day = mean_absolute_error(bikes["cnt"].iloc[cut:], np.full(len(bikes) - cut, bikes["cnt"].iloc[:cut].mean()))
    students = pd.read_csv(DATA / "student_performance_dataset.csv")
    _, _, s_tr, s_va = train_test_split(students.drop(columns="G3"), students["G3"], test_size=0.25, random_state=42)
    base_stu = mean_absolute_error(s_va, np.full(len(s_va), s_tr.mean()))
    titanic = pd.read_csv(DATA / "titanic_dataset.csv")
    print(f"Always-the-mean MAE: insurance {base_ins:,.0f}, daily bikes {base_day:,.0f}, student grade {base_stu:.2f}; "
          f"Titanic majority accuracy {1 - titanic['Survived'].mean():.3f}")
    FOUND.update(base_ins=base_ins, base_day=base_day, base_stu=base_stu, base_tit=1 - titanic["Survived"].mean())


# ---------------------------------------------------------- Chapter 7: evaluation
def titanic_split():
    titanic = pd.read_csv(DATA / "titanic_dataset.csv")
    features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked"]
    return titanic[features], titanic["Survived"], ["Age", "SibSp", "Parch", "Fare"], ["Pclass", "Sex", "Embarked"]


def chapter07():
    print("\nChapter 7")
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

    X, y, num, cat = titanic_split()
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    model = Pipeline([("preprocess", make_preprocess(num, cat)), ("model", LogisticRegression(max_iter=1000))]).fit(X_tr, y_tr)
    prob = model.predict_proba(X_va)[:, 1]
    auc = roc_auc_score(y_va, prob)
    print(f"Titanic logistic: validation AUC {auc:.3f}, average precision {average_precision_score(y_va, prob):.3f}")
    print("threshold TP FP FN TN precision recall")
    for t in (0.30, 0.50, 0.70):
        pred = prob >= t
        tp, fp, fn, tn = (pred & (y_va == 1)).sum(), (pred & (y_va == 0)).sum(), (~pred & (y_va == 1)).sum(), (~pred & (y_va == 0)).sum()
        print(f"  {t:.2f}  {tp} {fp} {fn} {tn}  {tp / (tp + fp):.3f}  {tp / (tp + fn):.3f}")
    FOUND["t_auc"] = auc
    rng = np.random.default_rng(3)
    y_arr = y_va.to_numpy()
    boot = []
    for _ in range(2000):
        pick = rng.integers(0, len(y_arr), len(y_arr))
        if y_arr[pick].min() != y_arr[pick].max():
            boot.append(roc_auc_score(y_arr[pick], prob[pick]))
    low, high = np.percentile(boot, [2.5, 97.5])
    print(f"Bootstrap interval for that AUC: {low:.3f} to {high:.3f}")
    FOUND["t_boot"] = (low, high)
    folds = cross_val_score(Pipeline([("preprocess", make_preprocess(num, cat)), ("model", LogisticRegression(max_iter=1000))]),
                            X_tr, y_tr, cv=StratifiedKFold(5, shuffle=True, random_state=42), scoring="roc_auc")
    print("Five-fold AUC on the training rows:", folds.round(3).tolist(), f"mean {folds.mean():.3f}, sd {folds.std():.3f}")
    FOUND["folds"] = folds

    # Points for the ROC and precision-recall figure: Titanic, and breast cancer from Lab 2.
    cancer = pd.read_csv(DATA / "breast_cancer_dataset.csv")
    Xc = cancer.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
    yc = (cancer["diagnosis"] == "M").astype(int)
    Xc_tr, Xc_va, yc_tr, yc_va = train_test_split(Xc, yc, test_size=0.25, random_state=42, stratify=yc)
    pc = Pipeline([("scale", StandardScaler()), ("model", LogisticRegression(max_iter=2000))]).fit(Xc_tr, yc_tr).predict_proba(Xc_va)[:, 1]
    for name, truth, p in [("titanic", y_va.to_numpy(), prob), ("cancer", yc_va.to_numpy(), pc)]:
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
    print("Cancer sweep: threshold, precision, recall")
    for t in (0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9):
        print(f"  {t:.2f}  {precision_score(yc_va, pc >= t):.3f}  {recall_score(yc_va, pc >= t):.3f}")


# ------------------------------------------------------------ Chapter 8: training
def chapter08():
    print("\nChapter 8")
    predictions = {"rigid": [2.6, 3.0, 3.4], "balanced": [1.0, 2.0, 3.0], "wild": [-1.0, 2.0, 5.0]}
    for name, p in predictions.items():
        p = np.array(p)
        print(f"  {name}: bias^2 {(p.mean() - 2) ** 2:.3f} variance {p.var():.3f} total {(p.mean() - 2) ** 2 + p.var() + 1:.3f}")

    X, y, num, cat = titanic_split()
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    sizes = [50, 100, 200, 400, 712]
    for name, estimator in [("logistic", LogisticRegression(max_iter=1000)),
                            ("unrestricted tree", DecisionTreeClassifier(random_state=42))]:
        pipe = Pipeline([("preprocess", make_preprocess(num, cat)), ("model", estimator)])
        got, train, valid = learning_curve(pipe, X, y, train_sizes=sizes, cv=folds, scoring="accuracy", shuffle=True, random_state=0)
        print(f"Learning curve, {name}: rows {got.tolist()}")
        print("  training error  ", (1 - train.mean(axis=1)).round(3).tolist())
        print("  validation error", (1 - valid.mean(axis=1)).round(3).tolist())
        FOUND[f"lc_{name}"] = (1 - train.mean(axis=1), 1 - valid.mean(axis=1))

    aucs = []
    for seed in range(5):
        X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=seed, stratify=y)
        m = Pipeline([("preprocess", make_preprocess(num, cat)), ("model", LogisticRegression(max_iter=1000))]).fit(X_tr, y_tr)
        aucs.append(roc_auc_score(y_va, m.predict_proba(X_va)[:, 1]))
    print("Same model, five split seeds, validation AUC:", np.round(aucs, 3).tolist())
    FOUND["seed_aucs"] = aucs

    fraud = pd.read_csv(DATA / "credit_card_fraud_dataset.csv")
    cols = ["amount", "transaction_hour", "foreign_transaction", "location_mismatch", "device_trust_score", "velocity_last_24h", "cardholder_age"]
    Xf_tr, Xf_va, yf_tr, yf_va = train_test_split(fraud[cols], fraud["is_fraud"], test_size=0.30, random_state=42, stratify=fraud["is_fraud"])
    print(f"Fraud rate {yf_va.mean():.3f}; always-no accuracy {1 - yf_va.mean():.3f}")
    for name, weight, t in [("plain, 0.50", None, 0.5), ("plain, 0.10", None, 0.1), ("balanced, 0.50", "balanced", 0.5)]:
        m = Pipeline([("scale", StandardScaler()), ("model", LogisticRegression(max_iter=2000, class_weight=weight))]).fit(Xf_tr, yf_tr)
        pred = m.predict_proba(Xf_va)[:, 1] >= t
        print(f"  {name}: flagged {pred.sum()}, precision {precision_score(yf_va, pred, zero_division=0):.3f}, "
              f"recall {recall_score(yf_va, pred):.3f}, accuracy {(pred == yf_va).mean():.3f}")
        FOUND[f"fraud_{name}"] = (int(pred.sum()), precision_score(yf_va, pred, zero_division=0), recall_score(yf_va, pred))


# ---------------------------------------------------- Chapter 9: linear regression
def chapter09():
    print("\nChapter 9")
    insurance = pd.read_csv(DATA / "medical_cost_personal_dataset.csv")
    train, valid = train_test_split(insurance, test_size=0.20, random_state=42)
    num, cat = ["age", "bmi", "children"], ["sex", "smoker", "region"]
    plain = Pipeline([("preprocess", make_preprocess(num, cat)), ("model", LinearRegression())])
    plain.fit(train[num + cat], train["charges"])
    r2_plain = r2_score(valid["charges"], plain.predict(valid[num + cat]))
    mae_plain = mean_absolute_error(valid["charges"], plain.predict(valid[num + cat]))

    names = plain.named_steps["preprocess"].get_feature_names_out()
    coefficients = pd.Series(plain.named_steps["model"].coef_, index=names)
    print("Insurance coefficients:", coefficients.round(0).to_dict())
    gap = coefficients["cat__smoker_yes"] - coefficients["cat__smoker_no"]
    print(f"  smoker gap {gap:,.0f}; one standard deviation of age adds {coefficients['num__age']:,.0f}")
    FOUND.update(gap=gap, age_coef=coefficients["num__age"], bmi_coef=coefficients["num__bmi"])

    def with_interaction(frame):
        frame = frame.copy()
        frame["smoker_bmi"] = (frame["smoker"] == "yes") * frame["bmi"]
        return frame

    richer = Pipeline([("preprocess", make_preprocess(num + ["smoker_bmi"], cat)), ("model", LinearRegression())])
    richer.fit(with_interaction(train)[num + ["smoker_bmi"] + cat], train["charges"])
    pred = richer.predict(with_interaction(valid)[num + ["smoker_bmi"] + cat])
    r2_rich, mae_rich = r2_score(valid["charges"], pred), mean_absolute_error(valid["charges"], pred)
    print(f"Insurance: plain R2 {r2_plain:.3f} MAE {mae_plain:,.0f}; with smoker x BMI R2 {r2_rich:.3f} MAE {mae_rich:,.0f}")
    FOUND.update(r2_plain=r2_plain, r2_rich=r2_rich, mae_rich=mae_rich)

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
    assert close(f["fare_skew"], 4.79) and close(f["logfare_skew"], 0.39)
    assert close(f["leaky"], 0.80, 0.03) and close(f["honest"], 0.52, 0.03)
    assert close(f["bars"][0], 2.44) and f["bars"][1] == 2
    assert f["iqr"] == 16.5 and close(f["sd"], 12.19) and close(f["se"], 3.85)
    assert close(f["boot"][0], 46.5, 1.5) and close(f["boot"][1], 65.0, 1.5)
    assert close(f["bayes"], 0.154, 0.001) and close(f["receipt"], 12.6)
    assert close(f["cos_ac"], 0.14) and close(f["dist_ab"], 2.24) and close(f["dist_ac"], 3.61)
    assert close(f["base_ins"], 9593, 1) and close(f["base_day"], 2290, 1)
    assert close(f["base_stu"], 2.37) and close(f["base_tit"], 0.616, 0.001)
    assert f["wins"] == 13 and f["table"][0.5] == (3, 2, 1, 2) and f["table"][0.35] == (4, 2, 0, 2)
    assert close(f["micro"], 0.857, 0.001) and close(f["macro"], 0.633, 0.001)
    assert close(f["t_auc"], 0.842, 0.002) and close(f["t_boot"][0], 0.781, 0.01) and close(f["t_boot"][1], 0.893, 0.01)
    assert close(f["folds"].mean(), 0.849, 0.002) and close(f["folds"].std(), 0.025, 0.002)
    train, valid = f["lc_logistic"]
    assert close(train[-1], 0.195, 0.01) and close(valid[-1], 0.201, 0.01)
    train, valid = f["lc_unrestricted tree"]
    assert close(train[-1], 0.019, 0.01) and close(valid[-1], 0.217, 0.02)
    assert close(min(f["seed_aucs"]), 0.828, 0.003) and close(max(f["seed_aucs"]), 0.925, 0.003)
    assert f["fraud_plain, 0.50"][0] == 38 and close(f["fraud_plain, 0.50"][2], 0.556, 0.002)
    assert f["fraud_balanced, 0.50"][0] == 170 and close(f["fraud_balanced, 0.50"][2], 0.933, 0.002)
    assert close(f["gap"], 23651, 1) and close(f["age_coef"], 3615, 1) and close(f["bmi_coef"], 2036, 1)
    assert close(f["r2_plain"], 0.784, 0.001) and close(f["r2_rich"], 0.865, 0.001) and close(f["mae_rich"], 2757, 1)
    assert close(f["ridge"][0.0][1], 3907.53, 1) and close(f["ridge"][0.1][1], 101.01, 0.5) and close(f["ridge"][0.1][0], 7.50, 0.02)
    print("\nEvery number above matches the book.")


def main():
    chapter03()
    chapter05()
    chapter06()
    chapter07()
    chapter08()
    chapter09()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
