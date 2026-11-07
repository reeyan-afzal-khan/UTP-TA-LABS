"""The small worked numbers of Chapters 10 to 14: neighbors, naive Bayes, trees, ensembles, SVMs.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/demo_model_families.py
It takes about half a minute.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import accuracy_score
from sklearn.model_selection import KFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor

DATA = Path(__file__).resolve().parent.parent / "all_datasets"
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

    # Naive Bayes by hand on real Titanic counts.
    titanic = pd.read_csv(DATA / "titanic_dataset.csv")
    lived, died = titanic[titanic["Survived"] == 1], titanic[titanic["Survived"] == 0]
    n = len(titanic)
    counts = {"lived": len(lived), "died": len(died),
              "female_lived": int((lived["Sex"] == "female").sum()), "female_died": int((died["Sex"] == "female").sum()),
              "first_lived": int((lived["Pclass"] == 1).sum()), "first_died": int((died["Pclass"] == 1).sum())}
    print("Titanic counts:", counts)
    score_lived = len(lived) / n * counts["female_lived"] / len(lived) * counts["first_lived"] / len(lived)
    score_died = len(died) / n * counts["female_died"] / len(died) * counts["first_died"] / len(died)
    posterior = score_lived / (score_lived + score_died)
    group = titanic[(titanic["Sex"] == "female") & (titanic["Pclass"] == 1)]
    print(f"  scores {score_lived:.4f} and {score_died:.4f}: naive Bayes says {posterior:.3f}; "
          f"actually {int(group['Survived'].sum())} of {len(group)} = {group['Survived'].mean():.3f}")
    FOUND["nb"] = (counts, score_lived, score_died, posterior, group["Survived"].mean())


# ------------------------------------------------------------- Chapter 12: decision trees
def gini(counts):
    counts = np.asarray(counts, dtype=float)
    return 1 - ((counts / counts.sum()) ** 2).sum()


def split_gain(left, right):
    parent = np.add(left, right)
    n, nl, nr = parent.sum(), np.sum(left), np.sum(right)
    return gini(parent) - nl / n * gini(left) - nr / n * gini(right)


def titanic_tree_data():
    titanic = pd.read_csv(DATA / "titanic_dataset.csv")
    features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked"]
    num, cat = ["Age", "SibSp", "Parch", "Fare"], ["Pclass", "Sex", "Embarked"]
    preprocess = ColumnTransformer([
        ("num", SimpleImputer(strategy="median"), num),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), cat)])
    return titanic, titanic[features], titanic["Survived"], preprocess


def chapter12():
    print("\nChapter 12")
    titanic, X, y, preprocess = titanic_tree_data()
    print(f"Whole table: died {(y == 0).sum()}, lived {(y == 1).sum()}, Gini {gini([(y == 0).sum(), (y == 1).sum()]):.3f}")
    candidates = {"Sex is female": titanic["Sex"] == "female", "Pclass is 3": titanic["Pclass"] == 3,
                  "Fare at most 15": titanic["Fare"] <= 15, "Embarked at C": titanic["Embarked"] == "C"}
    FOUND["splits"] = {}
    for name, mask in candidates.items():
        left = [int(((y == 0) & mask).sum()), int(((y == 1) & mask).sum())]
        right = [int(((y == 0) & ~mask).sum()), int(((y == 1) & ~mask).sum())]
        gain = split_gain(left, right)
        print(f"  {name:<16} yes {left} Gini {gini(left):.3f}   no {right} Gini {gini(right):.3f}   gain {gain:.3f}")
        FOUND["splits"][name] = (left, right, gain)

    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    train_curve, valid_curve = [], []
    for depth in range(1, 13):
        t = Pipeline([("preprocess", preprocess), ("tree", DecisionTreeClassifier(max_depth=depth, random_state=42))]).fit(X_tr, y_tr)
        train_curve.append(accuracy_score(y_tr, t.predict(X_tr)))
        valid_curve.append(accuracy_score(y_va, t.predict(X_va)))
    print("Depth 1..12 training:  ", np.round(train_curve, 3).tolist())
    print("Depth 1..12 validation:", np.round(valid_curve, 3).tolist())
    FOUND["tree_curves"] = (train_curve, valid_curve)

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

    titanic, X, y_t, preprocess = titanic_tree_data()
    folds = KFold(5, shuffle=True, random_state=42)
    single = cross_val_score(Pipeline([("preprocess", preprocess), ("model", DecisionTreeClassifier(random_state=42))]), X, y_t, cv=folds)
    forest = cross_val_score(Pipeline([("preprocess", preprocess), ("model", RandomForestClassifier(n_estimators=300, random_state=42, n_jobs=-1))]), X, y_t, cv=folds)
    print(f"Titanic five folds: one tree {single.mean():.3f} (sd {single.std():.3f}), forest of 300 {forest.mean():.3f} (sd {forest.std():.3f})")
    FOUND["tree_forest"] = (single.mean(), forest.mean())


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


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert close(f["softmax"][0], 0.082, 0.001) and close(f["softmax"][1], 0.737, 0.001) and close(f["softmax"][2], 0.182, 0.001)
    assert f["perceptron"] == ([1.0, 3.0], 0.0, 2)
    assert close(f["lda"][0], 9.71) and close(f["lda"][1], 5.33) and close(f["lda"][2], 6.51) and close(f["lda"][3], 6.26)
    assert [r[1] for r in f["knn"]] == ["B", "A", "C", "D"] and close(f["knn_reg"], 69.0)
    assert close(f["contrast"][2], 35.61, 1.5) and close(f["contrast"][1000], 1.11, 0.02)
    counts, lived, died, posterior, actual = f["nb"]
    assert counts["female_lived"] == 233 and counts["first_died"] == 80
    assert close(lived, 0.1040, 0.0005) and close(died, 0.0132, 0.0005) and close(posterior, 0.887, 0.001) and close(actual, 0.968, 0.001)
    assert close(f["splits"]["Sex is female"][2], 0.140, 0.001) and close(f["splits"]["Pclass is 3"][2], 0.049, 0.001)
    assert close(f["splits"]["Fare at most 15"][2], 0.039, 0.001) and close(f["splits"]["Embarked at C"][2], 0.013, 0.001)
    train, valid = f["tree_curves"]
    assert close(train[11], 0.954, 0.002) and close(valid[2], 0.785, 0.002) and close(valid[11], 0.731, 0.002)
    assert f["stump"][0] == 17.0 and close(f["stump"][1], 60.0) and close(f["stump"][2], 40.5)
    assert close(f["jar"][0], 31.6, 1) and close(f["jar"][1], 6.4, 0.3) and close(f["jar"][2], 8.0, 0.3) and close(f["jar"][3], 30.3, 1)
    assert close(f["oob"], 0.368, 0.003)
    assert close(f["ada"][0], 0.2) and close(f["ada"][1], 0.693) and close(f["ada"][2][4], 0.5)
    assert np.allclose(f["boost"][1], [5.25, 5.25, 7.75, 7.75]) and close(((np.array([3, 5, 8, 10]) - f["boost"][6]) ** 2).mean(), 0.029, 0.002)
    assert close(f["tree_forest"][0], 0.786, 0.01) and close(f["tree_forest"][1], 0.816, 0.01)
    w, b, margin, support = f["svm"]
    assert close(w[0], 2 / 3, 0.002) and close(w[1], 2 / 3, 0.002) and close(b, -3, 0.002) and close(margin, 2.121, 0.002)
    assert sorted(support) == [[1.0, 2.0], [2.0, 1.0], [3.0, 3.0]]
    assert close(f["kernel"][0], 25.0) and close(f["kernel"][1], 25.0) and close(f["rbf"][1], 0.368, 0.001)
    print("\nEvery number above matches the book.")


def main():
    chapter10()
    chapter11()
    chapter12()
    chapter13()
    chapter14()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
