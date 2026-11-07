"""The Your-turn tasks of all eight lab sheets, solved, so their expected findings can be checked.

Try each task yourself first. The lab sheets ask for these in new notebook cells; this file is
the record of how the numbers under "Expected findings" were produced.

Run from the course folder:
    python all_experiments/check_your_turn.py            every lab, a few minutes on a CPU
    python all_experiments/check_your_turn.py lab03      one lab
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
from sklearn.ensemble import IsolationForest, RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.linear_model import Lasso, LogisticRegression, Ridge
from sklearn.metrics import accuracy_score, average_precision_score, mean_absolute_error, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import Pipeline
from sklearn.semi_supervised import SelfTrainingClassifier
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.svm import SVC

DATA = Path(__file__).resolve().parent.parent / "all_datasets"


def expect(name, value, target, tolerance):
    """Stop if a number has drifted from the one printed on the lab sheet or in a chapter."""
    assert abs(value - target) <= tolerance, f"{name}: got {value}, the book says {target}"



def make_preprocess(num_cols, cat_cols):
    return ColumnTransformer([
        ("num", Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), num_cols),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="ignore"))]), cat_cols),
    ])


def lab01():
    print("Lab 1")
    df = pd.read_csv(DATA / "titanic_dataset.csv")
    df["FamilySize"] = df["SibSp"] + df["Parch"] + 1
    df["IsAlone"] = (df["FamilySize"] == 1).astype(int)
    df["Title"] = df["Name"].str.extract(r",\s*([^\.]+)\.")[0].str.strip()
    df["Title"] = df["Title"].where(df["Title"].isin(["Mr", "Mrs", "Miss", "Master"]), "Other")
    df["LogFare"] = np.log1p(df["Fare"])
    df["FarePerPerson"] = np.log1p(df["Fare"] / df["FamilySize"])
    y = df["Survived"]
    base_num = ["Age", "SibSp", "Parch", "LogFare", "FamilySize", "IsAlone"]
    cat = ["Pclass", "Sex", "Embarked", "Title"]
    for label, num in [("engineered", base_num), ("engineered + fare per person", base_num + ["FarePerPerson"])]:
        X = df[num + cat]
        X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
        m = Pipeline([("p", make_preprocess(num, cat)), ("m", LogisticRegression(max_iter=2000))]).fit(X_tr, y_tr)
        auc = roc_auc_score(y_va, m.predict_proba(X_va)[:, 1])
        print(f"  {label:<30} ROC AUC {auc:.3f}")
        expect(label, auc, 0.872, 0.002)
    # Fitting the preprocessing on every row, the mistake the lab warns about, on this table.
    X = df[base_num + cat]
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    all_rows = make_preprocess(base_num, cat).fit(X)
    leaky = LogisticRegression(max_iter=2000).fit(all_rows.transform(X_tr), y_tr)
    auc = roc_auc_score(y_va, leaky.predict_proba(all_rows.transform(X_va))[:, 1])
    print(f"  preprocessing fitted on all rows  ROC AUC {auc:.3f}")
    expect("all-rows preprocessing", auc, 0.872, 0.002)
    # Which earlier grade leaks more? G1 is the first term, G2 the second.
    students = pd.read_csv(DATA / "student_performance_dataset.csv")
    X_s = students.drop(columns=["G1", "G2", "G3"])
    num_s = X_s.select_dtypes(include="number").columns.tolist()
    cat_s = X_s.select_dtypes(exclude="number").columns.tolist()
    train, valid = train_test_split(students, test_size=0.25, random_state=42)
    for extra, target in (([], 2.181), (["G1"], 1.246), (["G2"], 0.762)):
        m = Pipeline([("p", make_preprocess(num_s + extra, cat_s)), ("m", Ridge(alpha=1.0))]).fit(train, train["G3"])
        mae = mean_absolute_error(valid["G3"], m.predict(valid))
        print(f"  ridge with {extra or 'no earlier grade'}: MAE {mae:.3f}")
        expect(f"ridge {extra}", mae, target, 0.002)
    # The lasso penalty: stronger means fewer columns.
    for alpha, columns, target in ((0.01, 43, 2.159), (0.1, 19, 2.077), (0.5, 4, 2.151)):
        m = Pipeline([("p", make_preprocess(num_s, cat_s)), ("m", Lasso(alpha=alpha, max_iter=10000))]).fit(train, train["G3"])
        kept = int((m.named_steps["m"].coef_ != 0).sum())
        mae = mean_absolute_error(valid["G3"], m.predict(valid))
        print(f"  lasso alpha {alpha}: kept {kept} of 56 columns, MAE {mae:.3f}")
        expect(f"lasso {alpha}", mae, target, 0.002)
        assert kept == columns, f"lasso {alpha} kept {kept}"


def lab02():
    print("\nLab 2")
    bikes = pd.read_csv(DATA / "bike_sharing_dataset_day.csv").sort_values("dteday").reset_index(drop=True)
    cat = ["season", "yr", "mnth", "holiday", "weekday", "workingday", "weathersit"]
    num = ["temp", "atemp", "hum", "windspeed"]
    forest = lambda: Pipeline([
        ("p", ColumnTransformer([("cat", OneHotEncoder(handle_unknown="ignore"), cat), ("num", "passthrough", num)])),
        ("m", RandomForestRegressor(n_estimators=400, min_samples_leaf=2, random_state=42, n_jobs=-1))])
    cut = int(len(bikes) * 0.80)
    dated = forest().fit(bikes.iloc[:cut], bikes["cnt"].iloc[:cut])
    mae_dated = mean_absolute_error(bikes["cnt"].iloc[cut:], dated.predict(bikes.iloc[cut:]))
    print(f"  daily bikes, date-order split:  MAE {mae_dated:.0f}")
    expect("bikes in date order", mae_dated, 1040, 3)
    months = pd.to_datetime(bikes["dteday"].iloc[cut:]).dt.month.to_numpy()
    gaps = {m: (bikes["cnt"].iloc[cut:].to_numpy() - dated.predict(bikes.iloc[cut:]))[months == m].mean() for m in (9, 10, 11)}
    print("  under-forecast by month:", {m: round(float(g)) for m, g in gaps.items()})
    assert all(650 <= g <= 1000 for g in gaps.values())
    tr, va = train_test_split(bikes, test_size=0.20, random_state=42)
    shuffled = forest().fit(tr, tr["cnt"])
    mae_shuffled = mean_absolute_error(va["cnt"], shuffled.predict(va))
    print(f"  daily bikes, random split:      MAE {mae_shuffled:.0f}")
    expect("bikes shuffled", mae_shuffled, 451, 3)
    # Choosing a threshold from costs: a miss costs ten false alarms.
    cancer = pd.read_csv(DATA / "breast_cancer_dataset.csv")
    X = cancer.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
    y = (cancer["diagnosis"] == "M").astype(int)
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    prob = Pipeline([("s", StandardScaler()), ("m", LogisticRegression(max_iter=2000))]).fit(X_tr, y_tr).predict_proba(X_va)[:, 1]
    print("  threshold  misses  false alarms  cost = 10*misses + false alarms")
    best = None
    for t in np.round(np.arange(0.05, 0.96, 0.05), 2):
        fn, fp = int(((prob < t) & (y_va == 1)).sum()), int(((prob >= t) & (y_va == 0)).sum())
        cost = 10 * fn + fp
        if best is None or cost < best[0]:
            best = (cost, t, fn, fp)
        if t in (0.05, 0.1, 0.2, 0.3, 0.5, 0.7):
            print(f"    {t:.2f}      {fn}        {fp}         {cost}")
    print("  cheapest:", (best[0], float(best[1]), best[2], best[3]))
    assert best[1] == 0.05 and best[0] == 11
    # Is Part D's test set really new? Same seed and same fraction as Part C.
    titanic = pd.read_csv(DATA / "titanic_dataset.csv")
    features = ["Pclass", "Sex", "Age", "SibSp", "Parch", "Fare", "Embarked"]
    a = train_test_split(titanic[features], titanic["Survived"], test_size=0.25, random_state=42, stratify=titanic["Survived"])[1]
    b = train_test_split(titanic[features], titanic["Survived"], test_size=0.25, random_state=42, stratify=titanic["Survived"])[1]
    print(f"  Part C validation rows equal Part D test rows: {a.index.equals(b.index)}")
    assert a.index.equals(b.index)
    # A split that really is untouched: three parts.
    tr, rest = train_test_split(titanic, test_size=0.4, random_state=1, stratify=titanic["Survived"])
    va, te = train_test_split(rest, test_size=0.5, random_state=1, stratify=rest["Survived"])
    print(f"  a three-way split of Titanic has {len(tr)}, {len(va)} and {len(te)} rows")
    assert (len(tr), len(va), len(te)) == (534, 178, 179)


def lab03():
    print("\nLab 3")
    cancer = pd.read_csv(DATA / "breast_cancer_dataset.csv")
    X = cancer.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
    y = (cancer["diagnosis"] == "M").astype(int)
    X_tr, X_va, y_tr, y_va = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    for label, steps, target_cv, target_acc in [("scaled", [("s", StandardScaler())], 0.988, 0.958), ("raw units", [], 0.965, 0.930)]:
        m = Pipeline(steps + [("m", KNeighborsClassifier(n_neighbors=11, weights="distance"))])
        cv = cross_val_score(m, X_tr, y_tr, cv=folds, scoring="roc_auc").mean()
        m.fit(X_tr, y_tr)
        acc = accuracy_score(y_va, m.predict(X_va))
        print(f"  KNN k=11, {label:<10} CV ROC AUC {cv:.3f}  validation accuracy {acc:.3f}")
        expect(f"knn {label}", cv, target_cv, 0.002)
        expect(f"knn {label}", acc, target_acc, 0.002)
    svm = Pipeline([("s", StandardScaler()), ("m", SVC(kernel="rbf", C=10, gamma=0.01))]).fit(X_tr, y_tr)
    print(f"  tuned SVM keeps {svm.named_steps['m'].n_support_.sum()} of {len(X_tr)} rows as support vectors")
    assert svm.named_steps["m"].n_support_.sum() == 51
    wine = pd.read_csv(DATA / "red_wine_quality_dataset.csv")
    X_w, y_w = wine.drop(columns="quality"), wine["quality"]
    Xw_tr, Xw_va, yw_tr, yw_va = train_test_split(X_w, y_w, test_size=0.25, random_state=42)
    for trees, target in ((1, 0.539), (10, 0.456), (50, 0.431), (150, 0.432), (400, 0.432), (1000, 0.431)):
        m = RandomForestRegressor(n_estimators=trees, min_samples_leaf=2, random_state=42, n_jobs=-1).fit(Xw_tr, yw_tr)
        mae = mean_absolute_error(yw_va, m.predict(Xw_va))
        print(f"  wine forest of {trees:>4} trees: MAE {mae:.3f}")
        expect(f"forest {trees}", mae, target, 0.003)
    mae = mean_absolute_error(yw_va, np.full(len(yw_va), yw_tr.mean()))
    print(f"  wine, always the training mean: MAE {mae:.3f}")
    expect("wine mean", mae, 0.669, 0.001)


def lab04():
    print("\nLab 4")
    customers = pd.read_csv(DATA / "mall_customers_dataset.csv")
    cols = ["Age", "Annual Income (k$)", "Spending Score (1-100)"]
    X = StandardScaler().fit_transform(customers[cols])
    inertia = [KMeans(5, n_init=1, random_state=seed).fit(X).inertia_ for seed in range(8)]
    print("  one start, seeds 0-7:", np.round(inertia, 1).tolist())
    assert sum(abs(v - 168.2) < 0.1 for v in inertia) == 6
    for k in (5, 6):
        labels = KMeans(k, n_init=30, random_state=42).fit_predict(X)
        profile = customers[cols].groupby(labels).mean().round(1)
        profile["customers"] = np.bincount(labels)
        print(f"  k = {k}\n{profile.to_string()}")
    columns = [f"pixel_{i}" for i in range(64)] + ["label"]
    with zipfile.ZipFile(DATA / "optical_recognition_handwritten_digits.zip") as archive:
        members = {Path(name).name: name for name in archive.namelist()}
        train = pd.read_csv(archive.open(members["optdigits.tra"]), header=None, names=columns)
    X_dev, y_dev = train.drop(columns="label") / 16.0, train["label"]
    X_fit, X_val, y_fit, y_val = train_test_split(X_dev, y_dev, test_size=0.25, random_state=42, stratify=y_dev)
    for n, target in ((2, 0.608), (5, 0.868), (10, 0.934), (29, 0.954), (64, 0.955)):
        m = Pipeline([("pca", PCA(n_components=n, svd_solver="full")), ("m", LogisticRegression(max_iter=2000))]).fit(X_fit, y_fit)
        kept = m.named_steps["pca"].explained_variance_ratio_.sum()
        acc = accuracy_score(y_val, m.predict(X_val))
        print(f"  {n:>2} components: variance kept {kept:.3f}, validation accuracy {acc:.3f}")
        expect(f"pca {n}", acc, target, 0.003)


def lab05():
    print("\nLab 5")
    fraud = pd.read_csv(DATA / "credit_card_fraud_dataset.csv")
    cols = ["amount", "transaction_hour", "foreign_transaction", "location_mismatch", "device_trust_score", "velocity_last_24h", "cardholder_age"]
    X_tr, X_te, y_tr, y_te = train_test_split(fraud[cols], fraud["is_fraud"], test_size=0.30, random_state=42, stratify=fraud["is_fraud"])
    forest = IsolationForest(n_estimators=300, contamination="auto", random_state=42, n_jobs=-1).fit(X_tr)
    anomaly = -forest.decision_function(X_te)
    supervised = Pipeline([("s", StandardScaler()), ("m", LogisticRegression(max_iter=2000))]).fit(X_tr, y_tr)
    chance = supervised.predict_proba(X_te)[:, 1]
    truth = y_te.to_numpy()
    for label, score in [("isolation forest, no labels", anomaly), ("logistic regression, all labels", chance)]:
        top = truth[np.argsort(score)[::-1]]
        print(f"  {label:<32} ROC AUC {roc_auc_score(truth, score):.3f}  average precision {average_precision_score(truth, score):.3f}  "
              f"frauds in top 100: {int(top[:100].sum())} of {int(truth.sum())}")
        if label.startswith("isolation"):
            print("   frauds found in the top k:", {k: int(top[:k].sum()) for k in (10, 50, 100, 200, 300, 500, 1000)})
            assert {k: int(top[:k].sum()) for k in (10, 50, 100, 200, 300, 500, 1000)} == {10: 3, 50: 14, 100: 20, 200: 32, 300: 37, 500: 42, 1000: 45}
        else:
            assert int(top[:100].sum()) == 39
    # Did the unlabeled rows help? The same 89 labels with and without self-training.
    cancer = pd.read_csv(DATA / "breast_cancer_dataset.csv")
    X_c = cancer.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
    y_c = (cancer["diagnosis"] == "M").astype(int).to_numpy()
    X_dev, _, y_dev, _ = train_test_split(X_c, y_c, test_size=0.25, random_state=42, stratify=y_c)
    X_pool, X_val, y_pool, y_val = train_test_split(X_dev, y_dev, test_size=0.25, random_state=7, stratify=y_dev)
    rng = np.random.default_rng(42)
    hide = rng.random(len(y_pool)) < 0.70
    labeled = Pipeline([("s", StandardScaler()), ("m", LogisticRegression(max_iter=2000))]).fit(X_pool[~hide], y_pool[~hide])
    acc = accuracy_score(y_val, labeled.predict(X_val))
    print(f"  labels kept {int((~hide).sum())}: labels only, validation accuracy {acc:.3f}")
    expect("labels only", acc, 0.972, 0.002)
    full = Pipeline([("s", StandardScaler()), ("m", LogisticRegression(max_iter=2000))]).fit(X_pool, y_pool)
    acc = accuracy_score(y_val, full.predict(X_val))
    print(f"  all {len(y_pool)} pool labels: validation accuracy {acc:.3f}")
    expect("all labels", acc, 0.972, 0.002)
    semi = Pipeline([("s", StandardScaler()), ("m", SelfTrainingClassifier(LogisticRegression(max_iter=2000), threshold=0.90))])
    masked = y_pool.copy()
    masked[hide] = -1
    semi.fit(X_pool, masked)
    acc = accuracy_score(y_val, semi.predict(X_val))
    added = int((semi.named_steps["m"].labeled_iter_ > 0).sum())
    print(f"  self-training: validation accuracy {acc:.3f}, {added} pseudo-labels, {semi.named_steps['m'].n_iter_} rounds")
    expect("self-training", acc, 0.963, 0.002)
    assert added == 201 and int((semi.named_steps["m"].labeled_iter_ == -1).sum()) == 29


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
    columns = [f"pixel_{i}" for i in range(64)] + ["label"]
    with zipfile.ZipFile(DATA / "optical_recognition_handwritten_digits.zip") as archive:
        members = {Path(name).name: name for name in archive.namelist()}
        train = pd.read_csv(archive.open(members["optdigits.tra"]), header=None, names=columns)
        test = pd.read_csv(archive.open(members["optdigits.tes"]), header=None, names=columns)

    def tensors(frame):
        X = torch.tensor(frame.drop(columns="label").to_numpy(), dtype=torch.float32).reshape(-1, 1, 8, 8) / 16.0
        return X, torch.tensor(frame["label"].to_numpy(), dtype=torch.long)

    X_dev, y_dev = tensors(train)
    X_test, y_test = tensors(test)
    perm = torch.randperm(len(X_dev), generator=torch.Generator().manual_seed(42))
    n_val = len(X_dev) // 4
    X_val, y_val = X_dev[perm[:n_val]], y_dev[perm[:n_val]]
    X_fit, y_fit = X_dev[perm[n_val:]], y_dev[perm[n_val:]]

    def accuracy(model, X, y):
        model.eval()
        with torch.no_grad():
            return (model(X).argmax(dim=1) == y).float().mean().item()

    def fit(model, epochs=20, lr=3e-3, batch_size=32):
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
            nn.Conv2d(1, 16, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(16, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Flatten(), nn.Linear(128, 64), nn.ReLU(), nn.Dropout(dropout), nn.Linear(64, 10))

    torch.manual_seed(42)
    linear = nn.Sequential(nn.Flatten(), nn.Linear(64, 128), nn.Linear(128, 10))
    scores = fit(linear)
    print("  dense network without ReLU: validation %.4f, test %.4f" % scores)
    expect("no ReLU", scores[1], 0.9405, 0.02)
    torch.manual_seed(42)
    scores = fit(nn.Sequential(nn.Flatten(), nn.Linear(64, 128), nn.ReLU(), nn.Linear(128, 10)))
    print("  dense network with ReLU:    validation %.4f, test %.4f" % scores)
    expect("ReLU", scores[1], 0.9566, 0.02)
    for lr, target in ((3e-4, 0.9332), (3e-3, 0.9694), (3e-2, 0.9121), (3e-1, 0.1002)):
        torch.manual_seed(42)
        scores = fit(cnn(), lr=lr)
        print(f"  CNN, learning rate {lr:<7}: validation %.4f, test %.4f" % scores)
        expect(f"lr {lr}", scores[1], target, 0.05)
    torch.manual_seed(42)
    scores = fit(cnn(0.0))
    print("  CNN without dropout:        validation %.4f, test %.4f" % scores)
    expect("no dropout", scores[1], 0.9750, 0.02)


def lab08():
    print("\nLab 8")
    import torch
    from torch import nn
    hourly = pd.read_csv(DATA / "bike_sharing_dataset_hour.csv")
    hourly["dteday"] = pd.to_datetime(hourly["dteday"])
    hourly = hourly.sort_values(["dteday", "hr"]).reset_index(drop=True)
    series = hourly["cnt"].to_numpy(dtype=np.float32)
    scale = float(series[: int(len(series) * 0.80)].max())
    scaled = series / scale
    hour_angle = hourly["hr"].to_numpy(dtype=np.float32) / 23.0
    lookback = 24
    stamps = hourly["dteday"] + pd.to_timedelta(hourly["hr"], unit="h")
    missing = int((stamps.iloc[-1] - stamps.iloc[0]).total_seconds() / 3600) + 1 - len(hourly)
    span = ((stamps.shift(-lookback) - stamps).dt.total_seconds() / 3600).iloc[:-lookback]
    first_valid = int(len(span) * 0.80)
    print(f"  hours with no row: {missing}; windows spanning exactly 24 hours: {(span == lookback).mean():.3f}, in validation {(span.iloc[first_valid:] == lookback).mean():.3f}")
    assert missing == 165
    expect("windows of exactly a day", (span == lookback).mean(), 0.90, 0.005)
    expect("validation windows of exactly a day", (span.iloc[first_valid:] == lookback).mean(), 0.966, 0.005)

    def data(channels):
        stack = np.stack(channels, axis=-1)
        windows = np.stack([stack[i:i + lookback] for i in range(len(scaled) - lookback)])
        targets = scaled[lookback:]
        cut = int(len(windows) * 0.80)
        return (torch.tensor(windows[:cut]), torch.tensor(targets[:cut]), torch.tensor(windows[cut:]), torch.tensor(targets[cut:]))

    class Forecaster(nn.Module):
        def __init__(self, inputs):
            super().__init__()
            self.lstm = nn.LSTM(input_size=inputs, hidden_size=32, batch_first=True)
            self.head = nn.Linear(32, 1)

        def forward(self, x):
            states, _ = self.lstm(x)
            return self.head(states[:, -1, :]).squeeze(-1)

    snapshot = {}

    def fit(channels, epochs):
        Xtr, ytr, Xva, yva = data(channels)
        torch.manual_seed(42)
        model = Forecaster(len(channels))
        optimizer = torch.optim.Adam(model.parameters(), lr=3e-3)
        loss_fn = nn.MSELoss()
        curve = []
        for _ in range(epochs):
            model.train()
            order = torch.randperm(len(Xtr))
            for start in range(0, len(Xtr), 64):
                batch = order[start:start + 64]
                optimizer.zero_grad()
                loss_fn(model(Xtr[batch]), ytr[batch]).backward()
                optimizer.step()
            model.eval()
            with torch.no_grad():
                curve.append((model(Xva) - yva).abs().mean().item() * scale)
                if len(curve) == 8 and len(channels) == 1:
                    snapshot["forecast"] = model(Xva).numpy() * scale
                    snapshot["actual"] = yva.numpy() * scale
        return curve

    curve = fit([scaled], 16)
    print("  demand only, 16 epochs:", np.round(curve, 1).tolist())
    expect("eight epochs", curve[7], 41.9, 3)
    expect("sixteen epochs", curve[15], 37.7, 4)
    richer = fit([scaled, hour_angle], 8)
    print("  demand plus hour of day, 8 epochs:", np.round(richer, 1).tolist())
    expect("hour of day", richer[7], 35.1, 4)
    forecast, actual = snapshot["forecast"], snapshot["actual"]
    hours = hourly["hr"].to_numpy()[lookback:][-len(actual):]
    by_hour = pd.Series(np.abs(actual - forecast)).groupby(hours).mean()
    print("  mean absolute error by hour:", by_hour.round(0).astype(int).to_dict())
    busy = actual > 500
    print(f"  above 500 rentals: MAE {np.abs(actual - forecast)[busy].mean():.1f}, mean shortfall {(actual - forecast)[busy].mean():.1f}")
    expect("8 a.m.", by_hour[8], 109, 15)
    expect("10 a.m.", by_hour[10], 77, 15)
    expect("5 p.m.", by_hour[17], 69, 15)
    expect("6 p.m.", by_hour[18], 66, 15)
    assert by_hour[1:6].between(10, 30).all()
    expect("overnight", by_hour[4], 18, 8)
    expect("busy MAE", np.abs(actual - forecast)[busy].mean(), 81, 15)
    expect("busy shortfall", (actual - forecast)[busy].mean(), 41, 20)


if __name__ == "__main__":
    labs = {f"lab0{i}": globals()[f"lab0{i}"] for i in range(1, 9)}
    for name in sys.argv[1:] or labs:
        labs[name]()
    print("\nEvery number above matches the book.")
