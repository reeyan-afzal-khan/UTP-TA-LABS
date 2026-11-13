"""Choosing features: the worked numbers of Chapter 19, on 20,000 Lending Club loans.

Twenty-five candidate columns that a lender knows when it approves a loan, plus three columns of
pure noise, go through every kind of selection method: filters, wrappers, embedded methods and
shuffling. The noise columns are the test: a method that keeps them has been fooled.

Run from the course folder:      python all_experiments/book_checks/demo_selection.py
It reads all_datasets/supervised/lending_club/ and takes about two minutes.
"""
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import RFE, f_classif, mutual_info_classif
from sklearn.impute import SimpleImputer
from sklearn.inspection import permutation_importance
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
FOLDS = StratifiedKFold(5, shuffle=True, random_state=42)
pd.set_option("display.width", 160)


def candidate_table():
    """Twenty-five columns known when the loan is approved, three columns of noise, and the label."""
    loans = pd.read_csv(DATA / "supervised/lending_club/lending_club_2014_2015.zip", low_memory=False)
    issued = pd.to_datetime(loans["issue_d"], format="%b-%Y")
    first_credit = pd.to_datetime(loans["earliest_cr_line"], format="%b-%Y")
    grade_order = {grade: i + 1 for i, grade in enumerate(sorted(loans["sub_grade"].unique()))}       # A1 = 1 ... G5 = 35
    table = pd.DataFrame({
        "loan_amnt": loans["loan_amnt"],
        "installment": loans["installment"],
        "term_months": loans["term"].str.extract(r"(\d+)")[0].astype(int),
        "int_rate": loans["int_rate"],
        "sub_grade": loans["sub_grade"].map(grade_order),
        "log_income": np.log1p(loans["annual_inc"]),
        "dti": loans["dti"],
        "fico_low": loans["fico_range_low"],
        "fico_high": loans["fico_range_high"],
        "revol_util": loans["revol_util"],
        "revol_bal": loans["revol_bal"],
        "inquiries_6m": loans["inq_last_6mths"],
        "delinq_2y": loans["delinq_2yrs"],
        "never_late": loans["mths_since_last_delinq"].isna().astype(int),
        "open_acc": loans["open_acc"],
        "total_acc": loans["total_acc"],
        "mort_acc": loans["mort_acc"],
        "pub_rec": loans["pub_rec"],
        "bankruptcies": loans["pub_rec_bankruptcies"],
        "emp_years": loans["emp_length"].replace({"< 1 year": "0 years"}).str.extract(r"(\d+)")[0].astype(float),
        "credit_years": (issued - first_credit).dt.days / 365.25,
        "renter": (loans["home_ownership"] == "RENT").astype(int),
        "income_verified": (loans["verification_status"] != "Not Verified").astype(int),
        "joint_application": (loans["application_type"] != "Individual").astype(int),
        "small_business": (loans["purpose"] == "small_business").astype(int),
    })
    rng = np.random.default_rng(0)
    for i in (1, 2, 3):
        table[f"noise_{i}"] = rng.normal(size=len(table))                     # columns that mean nothing at all
    defaulted = (loans["loan_status"] == "Charged Off").astype(int)
    X = table.sample(20_000, random_state=42)                                # the same 20,000 loans as Lab 3
    y = defaulted.loc[X.index]
    written_later = loans.loc[X.index, ["last_fico_range_high", "recoveries", "total_rec_prncp", "last_pymnt_amnt"]]
    return (*train_test_split(X, y, test_size=0.25, random_state=42, stratify=y), written_later, y)


def logistic():
    """Fill gaps with the median, scale, and fit a logistic regression: the model every method below serves."""
    return Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler()),
                     ("model", LogisticRegression(max_iter=2000))])


def cv_auc(X, y, columns):
    """Five-fold cross-validated ROC AUC of the logistic model on the given columns."""
    return cross_val_score(logistic(), X[list(columns)], y, cv=FOLDS, scoring="roc_auc").mean()


def alone(column, y):
    """How well one column ranks the loans by itself: its ROC AUC, whichever direction it points."""
    auc = roc_auc_score(y, column.fillna(column.median()))
    return max(auc, 1 - auc)


def quasi_constant(X, share=0.99):
    """Columns in which one value fills at least `share` of the rows."""
    top = X.apply(lambda column: column.value_counts(normalize=True).iloc[0])
    return top[top >= share]


def twins(X, limit=0.9):
    """Pairs of columns whose correlation is beyond the limit in either direction."""
    r = X.corr().abs()
    names = list(r.columns)
    return [(a, b, r.loc[a, b]) for i, a in enumerate(names) for b in names[i + 1:] if r.loc[a, b] > limit]


def forward_selection(X, y, steps):
    """Start with nothing; at each step add the column that raises the cross-validated score most."""
    chosen, remaining, path = [], list(X.columns), []
    for _ in range(steps):
        scores = {column: cv_auc(X, y, chosen + [column]) for column in remaining}
        best = max(scores, key=scores.get)
        chosen.append(best)
        remaining.remove(best)
        path.append((best, scores[best]))
    return path


def main():
    X_train, X_valid, y_train, y_valid, written_later, y_sample = candidate_table()
    columns = list(X_train.columns)
    print(f"{len(X_train):,} training loans, {len(X_valid):,} validation loans, {len(columns)} candidate columns, "
          f"default rate {y_train.mean():.3f}")
    FOUND["shape"] = (len(X_train), len(X_valid), len(columns), y_train.mean())

    # 1. Before any method: what must not be a feature at all.
    leaks = {name: alone(written_later[name], y_sample) for name in written_later}
    best_honest = max(alone(X_train[c], y_train) for c in columns)
    print("columns written after the loan was issued, each alone:", {k: round(v, 3) for k, v in leaks.items()},
          f" best honest column alone: {best_honest:.3f}")
    FOUND["leaks"], FOUND["best_honest"] = leaks, best_honest

    # 2. Filters that need no label: nearly constant columns, and twins.
    constant = quasi_constant(X_train)
    pairs = twins(X_train)
    print("one value in 99% of rows or more:", constant.round(4).to_dict())
    print("twins:", [(a, b, round(r, 3)) for a, b, r in pairs])
    FOUND["constant"], FOUND["twins"] = constant.round(4).to_dict(), [(a, b, round(r, 3)) for a, b, r in pairs]

    # 3. Filters that score each column against the label, one at a time.
    filled = X_train.fillna(X_train.median())
    f_scores, p_values = f_classif(filled, y_train)
    information = mutual_info_classif(filled, y_train, random_state=0)
    scores = pd.DataFrame({"F": f_scores, "p": p_values, "mutual_information": information,
                           "auc_alone": [alone(X_train[c], y_train) for c in columns]}, index=columns)
    scores = scores.sort_values("F", ascending=False)
    print(scores.round({"F": 1, "p": 4, "mutual_information": 4, "auc_alone": 3}).to_string())
    FOUND["scores"] = scores

    everything = cv_auc(X_train, y_train, columns)
    without_twins = cv_auc(X_train, y_train, [c for c in columns if c not in ("fico_high", "installment", "int_rate")])
    print(f"logistic model on all {len(columns)} columns: cross-validated AUC {everything:.4f}; "
          f"without one twin of each pair: {without_twins:.4f}")
    FOUND["all"], FOUND["without_twins"] = everything, without_twins

    # 4. A wrapper: forward selection.
    path = forward_selection(X_train, y_train, steps=12)
    for step, (column, score) in enumerate(path, start=1):
        print(f"  step {step:2d}: add {column:16s} cross-validated AUC {score:.4f}")
    spread = cross_val_score(logistic(), X_train[[c for c, _ in path[:6]]], y_train, cv=FOLDS, scoring="roc_auc").std()
    fits = sum(len(columns) - step for step in range(12)) * FOLDS.get_n_splits()
    print(f"models fitted: {fits:,}; spread between folds with six columns: {spread:.4f}")
    FOUND["path"], FOUND["fits"], FOUND["spread"] = path, fits, spread

    # 5. Embedded: an L1 penalty sets weights to exactly zero; a smaller C is a stronger penalty.
    l1 = {}
    for C in (0.001, 0.003, 0.01, 0.03, 1.0):
        model = Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler()),
                          ("model", LogisticRegression(penalty="l1", C=C, solver="liblinear", random_state=0))])
        model.fit(X_train, y_train)
        weights = pd.Series(model.named_steps["model"].coef_[0], index=columns)
        kept = weights[weights != 0]
        auc = roc_auc_score(y_valid, model.predict_proba(X_valid)[:, 1])
        noise = [c for c in kept.index if c.startswith("noise")]
        l1[C] = (len(kept), auc, noise, kept.abs().sort_values(ascending=False).index.tolist())
        print(f"  C = {C:<5}: {len(kept):2d} columns kept, validation AUC {auc:.4f}, noise kept: {noise}")
    print("  the five kept at C = 0.003:", l1[0.003][3])
    FOUND["l1"] = l1

    # 6. Embedded, by a forest: its built-in importances against shuffling on validation loans.
    filled_valid = X_valid.fillna(X_train.median())
    forest = RandomForestClassifier(n_estimators=300, min_samples_leaf=5, random_state=0, n_jobs=-1).fit(filled, y_train)
    built_in = pd.Series(forest.feature_importances_, index=columns).sort_values(ascending=False)
    shuffled = permutation_importance(forest, filled_valid, y_valid, scoring="roc_auc", n_repeats=10, random_state=0, n_jobs=-1)
    by_shuffling = pd.Series(shuffled.importances_mean, index=columns).sort_values(ascending=False)
    rank = lambda series: {c: int(series.index.get_loc(c)) + 1 for c in columns if c.startswith("noise")}
    print("forest validation AUC:", round(roc_auc_score(y_valid, forest.predict_proba(filled_valid)[:, 1]), 4))
    print("built-in importance, top eight:", built_in.head(8).round(3).to_dict())
    print("drop in AUC when shuffled, top eight:", by_shuffling.head(8).round(4).to_dict())
    print("rank of the noise columns: built-in", rank(built_in), " shuffling", rank(by_shuffling))
    FOUND["built_in"], FOUND["by_shuffling"] = built_in, by_shuffling
    FOUND["noise_ranks"] = (rank(built_in), rank(by_shuffling))

    # 7. Recursive feature elimination: drop the smallest weight, refit, repeat.
    scaled = pd.DataFrame(StandardScaler().fit_transform(filled), columns=columns, index=filled.index)
    eliminated = RFE(LogisticRegression(max_iter=2000), n_features_to_select=5).fit(scaled, y_train)
    survivors = [c for c, keep in zip(columns, eliminated.support_) if keep]
    forward_five = [c for c, _ in path[:5]]
    print(f"five columns by elimination: {survivors}, AUC {cv_auc(X_train, y_train, survivors):.4f}")
    print(f"five columns by forward selection: {forward_five}, AUC {path[4][1]:.4f}")
    FOUND["rfe"] = (survivors, cv_auc(X_train, y_train, survivors))

    # 8. How stable is a selection? Forward selection of six columns on five resamples of the training loans.
    counts = {}
    for seed in range(5):
        resample = X_train.sample(frac=1, replace=True, random_state=seed)
        chosen, remaining = [], list(columns)
        for _ in range(6):
            trial = {c: cross_val_score(logistic(), resample[chosen + [c]], y_train.loc[resample.index], cv=3,
                                        scoring="roc_auc").mean() for c in remaining}
            best = max(trial, key=trial.get)
            chosen.append(best)
            remaining.remove(best)
        for column in chosen:
            counts[column] = counts.get(column, 0) + 1
    counts = dict(sorted(counts.items(), key=lambda item: -item[1]))
    print("times chosen in five resamples:", counts)
    FOUND["stability"] = counts

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


def check_book_numbers():
    f = FOUND
    assert f["shape"][:3] == (15000, 5000, 28) and round(f["shape"][3], 3) == 0.192
    assert {k: round(v, 3) for k, v in f["leaks"].items()} == {"last_fico_range_high": 0.933, "recoveries": 0.859,
                                                               "total_rec_prncp": 0.859, "last_pymnt_amnt": 0.781}
    assert round(f["best_honest"], 3) == 0.703
    assert f["constant"] == {"joint_application": 0.9995, "small_business": 0.9917}
    assert f["twins"] == [("loan_amnt", "installment", 0.952), ("int_rate", "sub_grade", 0.991), ("fico_low", "fico_high", 1.0)]
    s = f["scores"]
    assert s.index[:3].tolist() == ["sub_grade", "int_rate", "term_months"] and set(s.index[3:5]) == {"fico_high", "fico_low"}
    assert s["F"].round(1).loc[["sub_grade", "int_rate", "term_months", "fico_low", "dti", "installment", "noise_1",
                                "emp_years", "total_acc"]].tolist() == [1310.3, 1228.5, 854.8, 241.2, 179.1, 5.5, 2.4, 0.2, 0.0]
    assert s["auc_alone"].round(3).loc[["sub_grade", "int_rate", "term_months", "fico_low", "dti", "installment"]].tolist() == [
        0.703, 0.697, 0.627, 0.591, 0.576, 0.523]
    assert s["mutual_information"].round(4).loc[["int_rate", "sub_grade", "term_months", "installment"]].tolist() == [
        0.0415, 0.0374, 0.0263, 0.0214]
    assert (round(f["all"], 4), round(f["without_twins"], 4)) == (0.7265, 0.7251)
    assert [c for c, _ in f["path"]] == ["sub_grade", "term_months", "renter", "dti", "fico_low", "revol_util", "mort_acc",
                                         "income_verified", "int_rate", "noise_1", "inquiries_6m", "pub_rec"]
    assert [round(v, 4) for _, v in f["path"]] == [0.7027, 0.7132, 0.7175, 0.7201, 0.7221, 0.7237, 0.725, 0.7259, 0.7267,
                                                   0.7271, 0.7274, 0.7276]
    assert f["fits"] == 1350 and 0.005 < f["spread"] < 0.02
    assert {C: (kept, round(auc, 4), noise) for C, (kept, auc, noise, _) in f["l1"].items()} == {
        0.001: (2, 0.719, []), 0.003: (5, 0.7282, []), 0.01: (13, 0.7347, []),
        0.03: (20, 0.7345, ["noise_1", "noise_2"]), 1.0: (28, 0.7344, ["noise_1", "noise_2", "noise_3"])}
    assert sorted(f["l1"][0.003][3]) == sorted(["sub_grade", "term_months", "renter", "dti", "fico_low"])
    assert f["noise_ranks"] == ({"noise_1": 5, "noise_2": 8, "noise_3": 6}, {"noise_1": 12, "noise_2": 26, "noise_3": 22})
    assert f["built_in"].index[:4].tolist() == ["int_rate", "sub_grade", "dti", "revol_bal"]
    assert f["by_shuffling"].index[:4].tolist() == ["term_months", "sub_grade", "int_rate", "dti"]
    assert f["rfe"][0] == ["loan_amnt", "installment", "term_months", "int_rate", "sub_grade"] and round(f["rfe"][1], 4) == 0.716
    assert f["stability"] == {"sub_grade": 5, "term_months": 5, "dti": 5, "fico_low": 4, "renter": 3, "mort_acc": 3,
                              "income_verified": 3, "revol_bal": 1, "fico_high": 1}
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
