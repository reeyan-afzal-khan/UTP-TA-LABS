"""The small worked numbers of Chapters 10 to 14: neighbors, naive Bayes, trees, ensembles, SVMs.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/book_checks/demo_model_families.py
It takes two to three minutes; Lab 3's neighbor search and SVM grid take most of it.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import (HistGradientBoostingClassifier, HistGradientBoostingRegressor, RandomForestClassifier,
                              RandomForestRegressor)
from sklearn.impute import SimpleImputer
from sklearn.metrics import accuracy_score, average_precision_score, roc_auc_score
from sklearn.model_selection import GridSearchCV, KFold, StratifiedKFold, cross_val_score, train_test_split
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder, StandardScaler
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}


# ------------------------------------------------------ Chapter 10: linear classifiers
def chapter10():
    print("Chapter 10")
    scores = np.array([1.2, 3.4, 2.0])
    probabilities = np.exp(scores) / np.exp(scores).sum()
    print("Softmax of 1.2, 3.4, 2.0:", probabilities.round(3).tolist())
    FOUND["softmax"] = probabilities

    # One perceptron run: a mistake moves the line, a correct answer changes nothing.
    data = [((2.0, 2.0), +1), ((-1.0, -1.0), -1), ((1.0, -1.0), -1), ((0.0, 2.0), +1)]
    w, b, rate, trace = np.zeros(2), 0.0, 1.0, []
    for epoch in range(1, 6):
        mistakes = 0
        for x, y in data:
            x = np.array(x)
            score = w @ x + b
            if y * score <= 0:
                w, b = w + rate * y * x, b + rate * y
                mistakes += 1
                trace.append((epoch, x.tolist(), y, w.tolist(), b))
        if mistakes == 0:
            print(f"  clean pass in epoch {epoch}")
            break
    for row in trace:
        print("  mistake:", row)
    FOUND["perceptron"] = (w.tolist(), b, epoch)

    # Linear discriminant on the lectures column of the study log.
    lectures = np.array([8, 6, 7, 9, 11, 13, 12, 10, 5, 3], dtype=float)
    passed = np.array([0, 1, 1, 1, 1, 1, 1, 1, 0, 0])
    m1, m0 = lectures[passed == 1].mean(), lectures[passed == 0].mean()
    pooled = (((lectures[passed == 1] - m1) ** 2).sum() + ((lectures[passed == 0] - m0) ** 2).sum()) / (len(lectures) - 2)
    prior = passed.mean()
    boundary = (m1 + m0) / 2 - pooled / (m1 - m0) * np.log(prior / (1 - prior))
    print(f"LDA: means {m1:.2f} and {m0:.2f}, pooled variance {pooled:.2f}, midpoint {(m1 + m0) / 2:.2f}, boundary {boundary:.2f}")
    FOUND["lda"] = (m1, m0, pooled, boundary)


# --------------------------------------------- Chapter 11: neighbors and naive Bayes
def chapter11():
    print("\nChapter 11")
    train = {"A": ((1, 1), "Red"), "B": ((2, 1), "Red"), "C": ((4, 4), "Blue"), "D": ((5, 4), "Blue")}
    query = np.array([2, 2])
    ranked = sorted((np.linalg.norm(np.array(p) - query), name, label) for name, (p, label) in train.items())
    print("Distances:", [(round(d, 2), n, c) for d, n, c in ranked])
    FOUND["knn"] = ranked

    # Regression by neighbors: the mean of the three nearest marks in the study log.
    hours = np.arange(2, 21, 2, dtype=float)
    mark = np.array([47, 50, 59, 65, 68, 77, 62, 52, 43, 38], dtype=float)
    order = np.argsort(np.abs(hours - 12.5), kind="stable")[:3]
    print(f"Three nearest to 12.5 hours: hours {hours[order].tolist()}, marks {mark[order].tolist()}, mean {mark[order].mean():.1f}")
    FOUND["knn_reg"] = mark[order].mean()

    # The curse of dimensionality: the nearest point stops being much nearer than the farthest.
    rng = np.random.default_rng(5)
    contrast = {}
    for d in (2, 10, 100, 1000):
        points = rng.uniform(size=(500, d))
        distances = np.linalg.norm(points[1:] - points[0], axis=1)
        contrast[d] = distances.max() / distances.min()
        print(f"  {d:>4} dimensions: farthest / nearest = {contrast[d]:.2f}")
    FOUND["contrast"] = contrast

    a, b = np.array([1.0, 2.0]), np.array([3.0, 6.0])
    print("SMOTE point at 0.25 of the way:", (a + 0.25 * (b - a)).tolist())

    # Naive Bayes by hand on real churn counts (Lab 1 and Lab 2's telecom customers).
    churn = churn_table()
    left, stayed = churn[churn["Churn"] == "Yes"], churn[churn["Churn"] == "No"]
    n = len(churn)
    monthly = lambda frame: int((frame["Contract"] == "Month-to-month").sum())
    fibre = lambda frame: int((frame["InternetService"] == "Fiber optic").sum())
    counts = {"left": len(left), "stayed": len(stayed), "monthly_left": monthly(left), "monthly_stayed": monthly(stayed),
              "fibre_left": fibre(left), "fibre_stayed": fibre(stayed)}
    print("Churn counts:", counts)
    score_left = len(left) / n * counts["monthly_left"] / len(left) * counts["fibre_left"] / len(left)
    score_stayed = len(stayed) / n * counts["monthly_stayed"] / len(stayed) * counts["fibre_stayed"] / len(stayed)
    posterior = score_left / (score_left + score_stayed)
    group = churn[(churn["Contract"] == "Month-to-month") & (churn["InternetService"] == "Fiber optic")]
    actual = (group["Churn"] == "Yes").mean()
    print(f"  scores {score_left:.4f} and {score_stayed:.4f}: naive Bayes says {posterior:.3f}; "
          f"actually {int((group['Churn'] == 'Yes').sum())} of {len(group)} = {actual:.3f}")
    FOUND["nb"] = (counts, score_left, score_stayed, posterior, actual)

# ------------------------------------------------------------- Chapter 12: decision trees
def gini(counts):
    counts = np.asarray(counts, dtype=float)
    return 1 - ((counts / counts.sum()) ** 2).sum()


def split_gain(left, right):
    parent = np.add(left, right)
    n, nl, nr = parent.sum(), np.sum(left), np.sum(right)
    return gini(parent) - nl / n * gini(left) - nr / n * gini(right)


def churn_table():
    """Lab 2's telecom customers, with Lab 1's repair of TotalCharges."""
    churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
    churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)
    return churn


def churn_tree_data():
    churn = churn_table()
    X = churn.drop(columns=["customerID", "Churn"])
    num = X.select_dtypes(include="number").columns.tolist()
    cat = X.select_dtypes(exclude="number").columns.tolist()
    preprocess = ColumnTransformer([("num", "passthrough", num),
                                    ("cat", OneHotEncoder(handle_unknown="ignore"), cat)])
    return churn, X, (churn["Churn"] == "Yes").astype(int), preprocess


def chapter12():
    print("\nChapter 12")
    churn, X, y, preprocess = churn_tree_data()
    print(f"Whole table: stayed {(y == 0).sum()}, left {(y == 1).sum()}, Gini {gini([(y == 0).sum(), (y == 1).sum()]):.3f}")
    candidates = {"Month-to-month": churn["Contract"] == "Month-to-month", "Fibre internet": churn["InternetService"] == "Fiber optic",
                  "Tenure at most 12": churn["tenure"] <= 12, "Electronic check": churn["PaymentMethod"] == "Electronic check"}
    FOUND["splits"] = {}
    for name, mask in candidates.items():
        yes = [int(((y == 0) & mask).sum()), int(((y == 1) & mask).sum())]
        no = [int(((y == 0) & ~mask).sum()), int(((y == 1) & ~mask).sum())]
        gain = split_gain(yes, no)
        print(f"  {name:<18} yes {yes} Gini {gini(yes):.3f}   no {no} Gini {gini(no):.3f}   gain {gain:.3f}")
        FOUND["splits"][name] = (yes, no, gain)

    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    train_curve, valid_curve = [], []
    for depth in range(1, 13):
        t = Pipeline([("preprocess", preprocess), ("tree", DecisionTreeClassifier(max_depth=depth, random_state=42))]).fit(X_tr, y_tr)
        train_curve.append(accuracy_score(y_tr, t.predict(X_tr)))
        valid_curve.append(accuracy_score(y_va, t.predict(X_va)))
    print("Depth 1..12 training:  ", np.round(train_curve, 3).tolist())
    print("Depth 1..12 validation:", np.round(valid_curve, 3).tolist())
    FOUND["tree_curves"] = (train_curve, valid_curve)
    deep = Pipeline([("preprocess", preprocess), ("tree", DecisionTreeClassifier(random_state=42))]).fit(X_tr, y_tr)
    deep_scores = (deep.named_steps["tree"].get_depth(), deep.named_steps["tree"].get_n_leaves(),
                   accuracy_score(y_tr, deep.predict(X_tr)), accuracy_score(y_va, deep.predict(X_va)))
    print("Unrestricted tree: depth {}, leaves {}, training {:.3f}, validation {:.3f}".format(*deep_scores))
    FOUND["deep_tree"] = deep_scores

    labels = np.array([2.0, 3, 10, 11])
    weighted = (labels[:2].var() * 2 + labels[2:].var() * 2) / 4
    print(f"Regression tree: variance {labels.var():.2f} becomes {weighted:.2f}; leaves {labels[:2].mean()} and {labels[2:].mean()}")
    stump = DecisionTreeRegressor(max_depth=1).fit(np.arange(2, 21, 2).reshape(-1, 1), [47, 50, 59, 65, 68, 77, 62, 52, 43, 38])
    print(f"One-split tree on the study log: split at {stump.tree_.threshold[0]:.1f} hours, leaves {stump.tree_.value[1][0][0]:.1f} and {stump.tree_.value[2][0][0]:.1f}")
    FOUND["stump"] = (stump.tree_.threshold[0], stump.tree_.value[1][0][0], stump.tree_.value[2][0][0])
    extrapolate = stump.predict([[100]])[0]
    print(f"  it predicts {extrapolate:.1f} at 100 hours: a tree cannot leave the range of its labels")


# ------------------------------------------------------------------ Chapter 13: ensembles
def chapter13():
    print("\nChapter 13")
    rng = np.random.default_rng(21)
    truth = 200
    guesses = truth + rng.normal(0, 40, size=(10_000, 25))               # independent guessers
    shared = rng.normal(0, 30, size=(10_000, 1))                         # a bias the whole room shares
    swayed = truth + shared + rng.normal(0, 26.5, size=(10_000, 25))
    one = np.abs(guesses[:, 0] - truth).mean()
    crowd = np.abs(guesses.mean(axis=1) - truth).mean()
    crowd_sd = guesses.mean(axis=1).std()
    swayed_sd = swayed.mean(axis=1).std()
    print(f"Jar of sweets: one guesser misses by {one:.1f}; a crowd of 25 by {crowd:.1f}. "
          f"Standard deviations: one {guesses[:, 0].std():.1f}, crowd {crowd_sd:.1f}, swayed crowd {swayed_sd:.1f}")
    FOUND["jar"] = (one, crowd, crowd_sd, swayed_sd)
    for rho, b in [(0.0, 25), (0.5, 25), (0.5, 1000)]:
        print(f"  rho {rho}, B {b}: variance of the average = {rho + (1 - rho) / b:.3f} of one model's")

    n = 1000
    picks = rng.integers(0, n, size=(2000, n))
    unseen = np.mean([1 - len(np.unique(p)) / n for p in picks[:200]])
    print(f"Rows a bootstrap sample misses: {unseen:.3f}, formula {(1 - 1 / n) ** n:.3f}, e^-1 {np.exp(-1):.3f}")
    FOUND["oob"] = unseen

    # One round of AdaBoost by hand: five rows, the weak rule gets row 5 wrong.
    y = np.array([1, 1, -1, -1, 1])
    h = np.array([1, 1, -1, -1, -1])
    weights = np.full(5, 0.2)
    error = weights[y != h].sum()
    alpha = 0.5 * np.log((1 - error) / error)
    updated = weights * np.exp(-alpha * y * h)
    print(f"AdaBoost: error {error:.2f}, say {alpha:.3f}, raw {updated.round(3).tolist()}, sum {updated.sum():.3f}, new weights {(updated / updated.sum()).round(3).tolist()}")
    FOUND["ada"] = (error, alpha, (updated / updated.sum()).tolist())
    print(f"  a learner with error 0.3 gets say {0.5 * np.log(0.7 / 0.3):.3f}, multiplier {np.exp(0.5 * np.log(0.7 / 0.3)):.3f}")

    # Gradient boosting on four rows, several rounds, learning rate 0.5.
    target = np.array([3.0, 5, 8, 10])
    x = np.arange(4).reshape(-1, 1)
    prediction = np.full(4, target.mean())
    rows = [prediction.copy()]
    print("Boosting rounds (predictions, then squared error):")
    print(f"  round 0: {prediction.tolist()}  MSE {((target - prediction) ** 2).mean():.3f}")
    for round_no in range(1, 7):
        residual = target - prediction
        stump = DecisionTreeRegressor(max_depth=1).fit(x, residual)
        prediction = prediction + 0.5 * stump.predict(x)
        rows.append(prediction.copy())
        print(f"  round {round_no}: {np.round(prediction, 3).tolist()}  MSE {((target - prediction) ** 2).mean():.3f}")
    FOUND["boost"] = rows

    churn, X, y_c, preprocess = churn_tree_data()
    folds = KFold(5, shuffle=True, random_state=42)
    single = cross_val_score(Pipeline([("preprocess", preprocess), ("model", DecisionTreeClassifier(random_state=42))]), X, y_c, cv=folds)
    forest = cross_val_score(Pipeline([("preprocess", preprocess), ("model", RandomForestClassifier(n_estimators=300, random_state=42, n_jobs=-1))]), X, y_c, cv=folds)
    print(f"Churn five folds: one tree {single.mean():.3f} (sd {single.std():.3f}), forest of 300 {forest.mean():.3f} (sd {forest.std():.3f})")
    FOUND["tree_forest"] = (single.mean(), forest.mean(), single.std(), forest.std())

# ----------------------------------------------------------------------- Chapter 14: SVMs
def chapter14():
    print("\nChapter 14")
    X = np.array([[1, 1], [2, 1], [1, 2], [3, 3], [4, 3], [3, 4]], dtype=float)
    y = np.array([-1, -1, -1, 1, 1, 1])
    model = SVC(kernel="linear", C=1e6).fit(X, y)
    w, b = model.coef_[0], model.intercept_[0]
    print(f"Six points: w = {w.round(3).tolist()}, b = {b:.3f}, margin width {2 / np.linalg.norm(w):.3f}, "
          f"support vectors {X[model.support_].tolist()}")
    print("  scores y*(w.x+b):", np.round(y * (X @ w + b), 3).tolist())
    FOUND["svm"] = (w, b, 2 / np.linalg.norm(w), X[model.support_].tolist())

    scores = np.array([2.0, 1.0, 0.4, -0.5])
    print("Hinge loss for y*score =", scores.tolist(), ":", np.maximum(0, 1 - scores).tolist())

    x, z = np.array([1.0, 2.0]), np.array([3.0, 1.0])
    phi = lambda v: np.array([v[0] ** 2, np.sqrt(2) * v[0] * v[1], v[1] ** 2])
    print(f"Kernel check: (x.z)^2 = {(x @ z) ** 2:.1f}, phi(x).phi(z) = {phi(x) @ phi(z):.1f}")
    FOUND["kernel"] = ((x @ z) ** 2, phi(x) @ phi(z))
    for gamma in (0.1, 1.0, 10.0):
        print(f"  gamma {gamma:>4}: similarity at distance 0.5, 1, 2 =", np.round(np.exp(-gamma * np.array([0.25, 1.0, 4.0])), 3).tolist())
    FOUND["rbf"] = np.exp(-1.0 * np.array([0.25, 1.0, 4.0]))


# ------------------------------------------------- Lab 3's numbers, as the chapters quote them
def loan_features():
    """Lab 3's thirteen numbers known at application, for all 100,000 loans, and the default label."""
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
    })
    return X, (loans["loan_status"] == "Charged Off").astype(int)


def lab3_numbers():
    print("\nLab 3, as quoted in Chapters 11 to 14")
    X_all, y_all = loan_features()
    X = X_all.sample(20_000, random_state=42)
    y = y_all.loc[X.index]
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    filled = lambda: ("i", SimpleImputer(strategy="median"))
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    curve = {}
    for k in (1, 5, 25, 101, 201, 401, 801, 1601, 3201):
        knn = Pipeline([filled(), ("s", StandardScaler()), ("m", KNeighborsClassifier(n_neighbors=k))])
        curve[k] = cross_val_score(knn, X_tr, y_tr, cv=folds, scoring="roc_auc").mean()
    print("  KNN cross-validated ROC AUC by k:", {k: round(v, 3) for k, v in curve.items()})
    scores = {}
    for name, model in [("knn", Pipeline([filled(), ("s", StandardScaler()), ("m", KNeighborsClassifier(801))])),
                        ("knn raw", Pipeline([filled(), ("m", KNeighborsClassifier(801))])),
                        ("nb", Pipeline([filled(), ("s", StandardScaler()), ("m", GaussianNB())])),
                        ("forest", Pipeline([filled(), ("m", RandomForestClassifier(n_estimators=300, min_samples_leaf=20, random_state=42, n_jobs=-1))])),
                        ("boosting", HistGradientBoostingClassifier(max_iter=200, learning_rate=0.05, random_state=42))]:
        p = model.fit(X_tr, y_tr).predict_proba(X_va)[:, 1]
        scores[name] = (roc_auc_score(y_va, p), average_precision_score(y_va, p))
    print("  validation ROC AUC and average precision:", {k: (round(a, 3), round(b, 3)) for k, (a, b) in scores.items()})
    X_te = X_all.drop(X.index).sample(20_000, random_state=1)
    y_te = y_all.loc[X_te.index]
    svm = lambda: Pipeline([filled(), ("s", StandardScaler()), ("m", SVC(class_weight="balanced"))])
    grid = GridSearchCV(svm(), [{"m__kernel": ["linear"], "m__C": [0.1, 1]},
                                {"m__kernel": ["rbf"], "m__C": [0.1, 1, 10], "m__gamma": ["scale", 0.01, 0.1]}],
                        cv=StratifiedKFold(3, shuffle=True, random_state=42), scoring="roc_auc", n_jobs=-1).fit(X_tr, y_tr)
    cv = pd.DataFrame(grid.cv_results_)
    rbf_rows = cv[cv["param_m__kernel"] == "rbf"].copy()
    rbf_rows["gamma"] = rbf_rows["param_m__gamma"].astype(str)
    rbf = rbf_rows.pivot(index="param_m__C", columns="gamma", values="mean_test_score")
    print("  RBF grid, cross-validated ROC AUC:\n", rbf.round(3).to_string())
    linear_rows = cv[cv["param_m__kernel"] == "linear"]
    best_linear_C = float(linear_rows.sort_values("rank_test_score").iloc[0]["param_m__C"])
    svm_test = roc_auc_score(y_te, grid.decision_function(X_te))
    linear = svm().set_params(m__kernel="linear", m__C=best_linear_C).fit(X_tr, y_tr)
    linear_test = roc_auc_score(y_te, linear.decision_function(X_te))
    kept = grid.best_estimator_.named_steps["m"].n_support_
    print(f"  tuned SVM {grid.best_params_}: CV {grid.best_score_:.3f}, test {svm_test:.3f}; "
          f"best linear SVM (C={best_linear_C}) CV {linear_rows['mean_test_score'].max():.3f}, test {linear_test:.3f}; "
          f"support vectors {kept.sum()} of {len(X_tr)} ({kept[1]} defaults)")
    cars = used_car_codes()
    car_folds = KFold(3, shuffle=True, random_state=42)
    rmse = {}
    for name, model in [("forest", RandomForestRegressor(n_estimators=150, max_features=0.5, min_samples_leaf=2, random_state=42, n_jobs=-1)),
                        ("boosting", HistGradientBoostingRegressor(max_iter=300, learning_rate=0.1, random_state=42))]:
        rmse[name] = np.sqrt(-cross_val_score(model, cars[0], cars[1], cv=car_folds, scoring="neg_mean_squared_error"))
    print("  used-car prices, log-RMSE per fold:", {k: np.round(v, 4).tolist() for k, v in rmse.items()})
    FOUND["lab3"] = dict(curve=curve, scores=scores, rbf=rbf, svm=(grid.best_score_, svm_test, linear_test),
                         kept=(int(kept.sum()), int(kept[1])), rmse=rmse)


def used_car_codes():
    """Lab 3's car table: Lab 2's cleaning, the categories as codes, and the log price."""
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
    cat = ["make", "model", "body_type", "drive", "fuel_type"]
    codes = OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1, encoded_missing_value=-1)
    X = pd.concat([used[["age", "mileage_miles", "cpo"]].reset_index(drop=True),
                   pd.DataFrame(codes.fit_transform(used[cat]), columns=cat)], axis=1)
    return X, np.log(used["price_usd"]).reset_index(drop=True)


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert close(f["softmax"][0], 0.082, 0.001) and close(f["softmax"][1], 0.737, 0.001) and close(f["softmax"][2], 0.182, 0.001)
    assert f["perceptron"] == ([1.0, 3.0], 0.0, 2)
    assert close(f["lda"][0], 9.71) and close(f["lda"][1], 5.33) and close(f["lda"][2], 6.51) and close(f["lda"][3], 6.26)
    assert [r[1] for r in f["knn"]] == ["B", "A", "C", "D"] and close(f["knn_reg"], 69.0)
    assert close(f["contrast"][2], 35.61, 1.5) and close(f["contrast"][1000], 1.11, 0.02)
    counts, left, stayed, posterior, actual = f["nb"]
    assert counts == {"left": 1869, "stayed": 5174, "monthly_left": 1655, "monthly_stayed": 2220, "fibre_left": 1297, "fibre_stayed": 1799}
    assert close(left, 0.1631, 0.0005) and close(stayed, 0.1096, 0.0005) and close(posterior, 0.598, 0.001) and close(actual, 0.546, 0.001)
    assert close(f["splits"]["Month-to-month"][2], 0.064, 0.001) and close(f["splits"]["Tenure at most 12"][2], 0.039, 0.001)
    assert close(f["splits"]["Fibre internet"][2], 0.037, 0.001) and close(f["splits"]["Electronic check"][2], 0.036, 0.001)
    train, valid = f["tree_curves"]
    assert close(train[11], 0.922, 0.002) and close(valid[3], 0.793, 0.002) and close(valid[11], 0.750, 0.002)
    depth, leaves, deep_train, deep_valid = f["deep_tree"]
    assert (depth, leaves) == (25, 1004) and close(deep_train, 0.998, 0.001) and close(deep_valid, 0.741, 0.001)
    assert f["stump"][0] == 17.0 and close(f["stump"][1], 60.0) and close(f["stump"][2], 40.5)
    assert close(f["jar"][0], 31.6, 1) and close(f["jar"][1], 6.4, 0.3) and close(f["jar"][2], 8.0, 0.3) and close(f["jar"][3], 30.3, 1)
    assert close(f["oob"], 0.368, 0.003)
    assert close(f["ada"][0], 0.2) and close(f["ada"][1], 0.693) and close(f["ada"][2][4], 0.5)
    assert np.allclose(f["boost"][1], [5.25, 5.25, 7.75, 7.75]) and close(((np.array([3, 5, 8, 10]) - f["boost"][6]) ** 2).mean(), 0.029, 0.002)
    assert close(f["tree_forest"][0], 0.731, 0.002) and close(f["tree_forest"][1], 0.793, 0.002)
    assert close(f["tree_forest"][2], 0.010, 0.002) and close(f["tree_forest"][3], 0.009, 0.002)
    w, b, margin, support = f["svm"]
    assert close(w[0], 2 / 3, 0.002) and close(w[1], 2 / 3, 0.002) and close(b, -3, 0.002) and close(margin, 2.121, 0.002)
    assert sorted(support) == [[1.0, 2.0], [2.0, 1.0], [3.0, 3.0]]
    assert close(f["kernel"][0], 25.0) and close(f["kernel"][1], 25.0) and close(f["rbf"][1], 0.368, 0.001)
    lab3 = f["lab3"]
    expected_curve = {1: 0.552, 5: 0.632, 25: 0.692, 101: 0.710, 201: 0.716, 401: 0.717, 801: 0.719, 1601: 0.718, 3201: 0.717}
    assert all(close(lab3["curve"][k], v, 0.001) for k, v in expected_curve.items())
    expected_scores = {"knn": (0.723, 0.379), "nb": (0.716, 0.350), "forest": (0.733, 0.393), "boosting": (0.728, 0.389)}
    assert all(close(lab3["scores"][k][0], a, 0.001) and close(lab3["scores"][k][1], b, 0.001) for k, (a, b) in expected_scores.items())
    assert close(lab3["scores"]["knn raw"][0], 0.586, 0.001)
    assert close(lab3["rbf"].values.max(), 0.718, 0.001) and close(lab3["rbf"].values.min(), 0.647, 0.001)
    assert close(lab3["svm"][0], 0.718, 0.001) and close(lab3["svm"][1], 0.716, 0.001) and close(lab3["svm"][2], 0.713, 0.001)
    assert lab3["kept"] == (11478, 2205)
    forest, boosting = lab3["rmse"]["forest"], lab3["rmse"]["boosting"]
    assert close(forest.mean(), 0.2083, 0.0001) and close(boosting.mean(), 0.1941, 0.0001) and (boosting < forest).all()
    print("\nEvery number above matches the book.")


def main():
    chapter10()
    chapter11()
    chapter12()
    chapter13()
    chapter14()
    lab3_numbers()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
