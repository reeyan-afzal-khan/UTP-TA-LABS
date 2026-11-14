"""The small worked numbers of Chapters 20 to 23 and 25: clusters, shadows, anomalies, limited labels.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/book_checks/demo_unsupervised.py
It takes about two minutes; Lab 4's invoices, PCA on the wood images and Lab 5's self-training take most of it.
"""
from __future__ import annotations

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")   # avoids a known K-means warning on Windows
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.cluster import DBSCAN, KMeans
from sklearn.datasets import make_moons
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import IsolationForest
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import (accuracy_score, adjusted_rand_score, average_precision_score, roc_auc_score,
                             silhouette_samples, silhouette_score)
from sklearn.semi_supervised import SelfTrainingClassifier
from sklearn.model_selection import GroupShuffleSplit, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.neighbors import LocalOutlierFactor, NearestNeighbors
from sklearn.preprocessing import StandardScaler

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}


def retail_customers():
    """Lab 4's cleaning rules and RFM table: one row per customer."""
    lines = pd.read_csv(DATA / "unsupervised/online_retail_ii/online_retail_ii.zip", dtype={"Invoice": str, "StockCode": str},
                        parse_dates=["InvoiceDate"])
    sales = lines.dropna(subset=["Customer ID"])
    sales = sales[~sales["Invoice"].str.startswith("C") & (sales["Quantity"] > 0) & (sales["Price"] > 0)].drop_duplicates()
    sales = sales.assign(revenue=sales["Quantity"] * sales["Price"])
    day_after = sales["InvoiceDate"].max().normalize() + pd.Timedelta(days=1)
    return sales.groupby("Customer ID").agg(recency_days=("InvoiceDate", lambda d: (day_after - d.max()).days),
                                            orders=("Invoice", "nunique"), spend=("revenue", "sum"))


CUSTOMERS = None


def customers_table():
    global CUSTOMERS
    if CUSTOMERS is None:
        CUSTOMERS = retail_customers()
    return CUSTOMERS


def chapter20():
    print("Chapter 20")
    customers = customers_table()
    cols = ["recency_days", "orders", "spend"]
    logged = KMeans(4, n_init=20, random_state=42).fit_predict(StandardScaler().fit_transform(np.log1p(customers[cols])))
    scaled_only = KMeans(4, n_init=20, random_state=42).fit_predict(StandardScaler().fit_transform(customers[cols]))
    agreement = adjusted_rand_score(logged, scaled_only)
    print(f"Lab 4 customers, k = 4: logged and scaled against scaled only, adjusted Rand index {agreement:.3f}")
    print("Column standard deviations:", customers[cols].std().round(1).to_dict())
    FOUND["ari_scale"] = agreement

    # Raw units, no logs and no scaling: does spend in pounds decide everything?
    raw_labels = KMeans(4, n_init=20, random_state=42).fit_predict(customers[cols].to_numpy(dtype=float))
    by_spend = adjusted_rand_score(raw_labels, KMeans(4, n_init=20, random_state=42).fit_predict(customers[["spend"]].to_numpy(dtype=float)))
    print(f"Raw units: clusters agree {by_spend:.3f} with clustering on spend alone")
    FOUND["ari_spend"] = by_spend


def chapter21():
    print("\nChapter 21")
    # Silhouette by hand on six numbers in two groups.
    x = np.array([1, 2, 3, 10, 11, 12], dtype=float).reshape(-1, 1)
    labels = np.array([0, 0, 0, 1, 1, 1])
    a3, b3 = np.mean([2, 1]), np.mean([7, 8, 9])
    print(f"Silhouette of the point 3: a = {a3}, b = {b3}, s = {(b3 - a3) / max(a3, b3):.4f}")
    s = silhouette_samples(x, labels)
    print("  all six:", s.round(3).tolist(), f"mean {s.mean():.3f}")
    FOUND["sil"] = (s[2], s.mean())

    # One start or many: Lab 4's customers and Lab 4's wood-defect images.
    X = StandardScaler().fit_transform(np.log1p(customers_table()))
    inertia = [KMeans(4, n_init=1, random_state=seed).fit(X).inertia_ for seed in range(8)]
    print("Customers, k = 4, one start, seeds 0-7:", np.round(inertia, 1).tolist())
    X_fit = wood_splits()[0]
    codes = PCA(n_components=50, random_state=42).fit_transform(X_fit)
    image_inertia = [KMeans(7, n_init=1, random_state=seed).fit(codes).inertia_ for seed in range(8)]
    print("Images, k = 7, one start, seeds 0-7:", np.round(image_inertia, 0).tolist())
    FOUND["restarts"] = (inertia, image_inertia)
    curve = {}
    for k in range(2, 9):
        km = KMeans(k, n_init=20, random_state=42).fit(X)
        curve[k] = (km.inertia_, silhouette_score(X, km.labels_))
    print("Customers, elbow and silhouette:", {k: (round(a, 1), round(b, 3)) for k, (a, b) in curve.items()})
    FOUND["elbow"] = curve

    # Soft membership: a Gaussian mixture with known parts, and fuzzy C-means.
    normal = lambda v, m, sd: np.exp(-0.5 * ((v - m) / sd) ** 2) / (sd * np.sqrt(2 * np.pi))
    for v in (0.0, 1.5, 2.0, 3.0):
        a, b = 0.5 * normal(v, 0, 1), 0.5 * normal(v, 4, 1)
        print(f"  mixture of N(0,1) and N(4,1) at {v}: responsibility of the first part {a / (a + b):.3f}")
    FOUND["resp"] = 0.5 * normal(1.5, 0, 1) / (0.5 * normal(1.5, 0, 1) + 0.5 * normal(1.5, 4, 1))
    d1, d2 = 1.0, 3.0
    u = (1 / d1 ** 2) / (1 / d1 ** 2 + 1 / d2 ** 2)
    print(f"  fuzzy C-means, m = 2, distances 1 and 3: memberships {u:.2f} and {1 - u:.2f}")
    FOUND["fcm"] = u

    # DBSCAN roles on eight points.
    points = np.array([[0, 0], [1, 0], [0, 1], [1, 1], [2, 1], [3, 2], [6, 6], [1, 3.2]], dtype=float)
    model = DBSCAN(eps=1.5, min_samples=4).fit(points)
    core = set(model.core_sample_indices_.tolist())
    roles = ["core" if i in core else ("border" if model.labels_[i] != -1 else "noise") for i in range(len(points))]
    within = (np.linalg.norm(points[:, None] - points[None], axis=2) <= 1.5).sum(axis=1)
    for p, c, r in zip(points.tolist(), within.tolist(), roles):
        print(f"  point {p}: {c} within 1.5 (counting itself) -> {r}")
    FOUND["dbscan"] = roles

    # Shapes K-means cannot follow.
    moons, truth = make_moons(n_samples=300, noise=0.05, random_state=0)
    km = adjusted_rand_score(truth, KMeans(2, n_init=20, random_state=0).fit_predict(moons))
    db = adjusted_rand_score(truth, DBSCAN(eps=0.2, min_samples=5).fit_predict(moons))
    print(f"Two crescents: K-means agrees {km:.2f} with the true shapes, DBSCAN {db:.2f}")
    FOUND["moons"] = (km, db)


def chapter22():
    print("\nChapter 22")
    line = np.array([[-2, -2], [-1, -1], [0, 0], [1, 1], [2, 2]], dtype=float)
    pca = PCA().fit(line)
    print(f"Five points on a line: variances {pca.explained_variance_.round(3).tolist()}, scores {np.abs(pca.transform(line)[:, 0]).round(2).tolist()}")

    # Units decide the winner: PCA on the study log without and with scaling.
    log = np.array([[2, 8, 8, 47], [4, 6, 8, 50], [6, 7, 7, 59], [8, 9, 7, 65], [10, 11, 7, 68],
                    [12, 13, 6, 77], [14, 12, 5, 62], [16, 10, 4, 52], [18, 5, 3, 43], [20, 3, 2, 38]], dtype=float)
    raw = PCA().fit(log)
    scaled = PCA().fit(StandardScaler().fit_transform(log))
    print("Raw units: shares", raw.explained_variance_ratio_.round(3).tolist(), " direction 1", np.abs(raw.components_[0]).round(2).tolist())
    print("Scaled:    shares", scaled.explained_variance_ratio_.round(3).tolist())
    FOUND["pca_raw"] = raw.explained_variance_ratio_
    FOUND["pca_scaled"] = scaled.explained_variance_ratio_

    X_fit, X_valid, y_fit, y_valid, X_dev = wood_splits()
    full = PCA(svd_solver="full").fit(X_dev)                         # Lab 4's Question 10 curve
    share, cumulative = full.explained_variance_ratio_, np.cumsum(full.explained_variance_ratio_)
    print("Wood images, first ten shares:", share[:10].round(3).tolist())
    picks = [1, 2, 3, 5, 10, 21, 51, 100, 253, 500, 1000, 3072]
    print("Wood cumulative:", " ".join(f"({k},{cumulative[k - 1]:.3f})" for k in picks))
    counts = [int(np.searchsorted(cumulative, t) + 1) for t in (0.50, 0.90, 0.95, 0.99)]
    print(f"Components for 50, 90, 95, 99 percent: {counts}")
    FOUND["wood"] = (share, cumulative, counts)
    scores = {}
    for n in (2, 10, 50):
        m = Pipeline([("pca", PCA(n_components=n, random_state=42)), ("m", LogisticRegression(max_iter=1000))]).fit(X_fit, y_fit)
        scores[n] = accuracy_score(y_valid, m.predict(X_valid))
    budget = Pipeline([("pca", PCA(n_components=0.99, svd_solver="full")), ("m", LogisticRegression(max_iter=1000))]).fit(X_fit, y_fit)
    scores[budget.named_steps["pca"].n_components_] = accuracy_score(y_valid, budget.predict(X_valid))
    scores[3072] = accuracy_score(y_valid, LogisticRegression(max_iter=3000).fit(X_fit, y_fit).predict(X_valid))
    print("Validation accuracy by number of components:", {k: round(v, 4) for k, v in scores.items()})
    FOUND["components"] = scores

def chapter23():
    print("\nChapter 23")
    readings = np.array([10, 11, 9, 10, 12, 11, 10, 60], dtype=float)
    mean, sd = readings.mean(), readings.std(ddof=1)
    z = (60 - mean) / sd
    median = np.median(readings)
    mad = np.median(np.abs(readings - median))
    robust = 0.6745 * (60 - median) / mad
    q1, q3 = np.percentile(readings, [25, 75])
    print(f"Readings {readings.tolist()}: mean {mean:.2f}, sd {sd:.2f}, z of 60 = {z:.2f}")
    print(f"  median {median}, MAD {mad}, robust z of 60 = {robust:.1f}")
    print(f"  Q1 {q1}, Q3 {q3}, IQR {q3 - q1}, fences {q1 - 1.5 * (q3 - q1)} and {q3 + 1.5 * (q3 - q1)}")
    FOUND["mask"] = (mean, sd, z, median, mad, robust, q1 - 1.5 * (q3 - q1), q3 + 1.5 * (q3 - q1))

    # Random cuts isolate a stranger quickly.
    rng = np.random.default_rng(13)
    values = np.concatenate([rng.normal(0, 1, 99), [8.0]])

    def cuts_to_isolate(index, values, rng):
        cuts = 0
        alive = values.copy()
        target = values[index]
        while len(alive) > 1:
            cut = rng.uniform(alive.min(), alive.max())
            alive = alive[alive < cut] if target < cut else alive[alive >= cut]
            cuts += 1
        return cuts

    stranger = np.mean([cuts_to_isolate(99, values, rng) for _ in range(500)])
    usual = np.mean([cuts_to_isolate(i, values, rng) for i in range(0, 99, 3) for _ in range(40)])
    print(f"Random cuts to isolate: the stranger {stranger:.1f}, an ordinary value {usual:.1f}")
    FOUND["cuts"] = (stranger, usual)

    # Distance to a neighbor against local density.
    dense = np.column_stack([np.linspace(0, 0.9, 10), np.zeros(10)])
    sparse = np.column_stack([np.linspace(20, 29, 10), np.zeros(10)])
    stranger_point = np.array([[1.9, 0.0]])
    points = np.vstack([dense, sparse, stranger_point])
    distances, _ = NearestNeighbors(n_neighbors=4).fit(points).kneighbors(points)
    lof = LocalOutlierFactor(n_neighbors=3).fit(points)
    print(f"Third-neighbor distance: dense member {distances[5, 3]:.2f}, sparse member {distances[15, 3]:.2f}, stranger {distances[20, 3]:.2f}")
    print(f"Local outlier factor:     dense member {-lof.negative_outlier_factor_[5]:.2f}, sparse member {-lof.negative_outlier_factor_[15]:.2f}, stranger {-lof.negative_outlier_factor_[20]:.2f}")
    FOUND["lof"] = (distances[5, 3], distances[15, 3], distances[20, 3], -lof.negative_outlier_factor_[15], -lof.negative_outlier_factor_[20])


def chapter25():
    print("\nChapter 25")
    # Self-training on one column. Two labels on each side, six rows without one.
    x_l, y_l = [1.0, 2.0, 8.0, 9.0], [0, 0, 1, 1]
    x_u = [3.0, 4.0, 5.0, 6.0, 7.0, 10.0]
    labeled_x, labeled_y, remaining = list(x_l), list(y_l), list(x_u)
    for round_no in range(1, 6):
        model = LogisticRegression(C=1.0).fit(np.array(labeled_x).reshape(-1, 1), labeled_y)
        if not remaining:
            break
        p = model.predict_proba(np.array(remaining).reshape(-1, 1))[:, 1]
        sure = [i for i, q in enumerate(p) if q >= 0.8 or q <= 0.2]
        print(f"  round {round_no}: chance for {remaining} = {p.round(2).tolist()}; adopted {[remaining[i] for i in sure]}")
        if not sure:
            break
        for i in sure:
            labeled_x.append(remaining[i])
            labeled_y.append(int(p[i] >= 0.5))
        remaining = [v for i, v in enumerate(remaining) if i not in sure]
    print(f"  still unlabeled: {remaining}")
    FOUND["self"] = remaining

    # Label propagation along a chain: each unlabeled node takes the mean of its neighbors.
    chain = np.array([1.0, 0.5, 0.5, 0.5, 0.5, 0.0])
    history = []
    for sweep in range(200):
        chain[1:-1] = (chain[:-2] + chain[2:]) / 2
        if sweep in (0, 1, 2):
            history.append(chain.copy())
    print("Chain after 1, 2, 3 sweeps:", [h.round(3).tolist() for h in history])
    print("Chain at rest:", chain.round(3).tolist())
    FOUND["chain"] = chain.copy()

    probabilities = np.array([0.97, 0.52, 0.10, 0.61, 0.48, 0.88])
    picks = np.argsort(np.abs(probabilities - 0.5))[:2]
    print(f"Uncertainty sampling on {probabilities.tolist()}: rows {picks.tolist()} are nearest 0.5")
    FOUND["picks"] = picks.tolist()


def wood_splits():
    """Lab 4's wood images split board by board: fitting and validation rows, and all development rows."""
    wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
    X = wood["x"].reshape(len(wood["x"]), -1) / 255.0
    y, boards = wood["y"], wood["board"]
    dev, _ = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42).split(X, y, boards))
    fit, valid = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42).split(X[dev], y[dev], boards[dev]))
    return X[dev][fit], X[dev][valid], y[dev][fit], y[dev][valid], X[dev]

# --------------------------------------------- Lab 5's numbers, as Chapters 23 and 25 quote them
def lab5_numbers():
    print("\nLab 5, as quoted in Chapters 23 and 25")
    cards = pd.read_csv(DATA / "unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip")
    X = cards[[f"V{i}" for i in range(1, 29)]].assign(log_amount=np.log1p(cards["Amount"]))
    X_tr, X_te, y_tr, y_te = train_test_split(X, cards["Class"], test_size=0.30, random_state=42, stratify=cards["Class"])
    score = -IsolationForest(n_estimators=300, random_state=42, n_jobs=-1).fit(X_tr).decision_function(X_te)
    hits = y_te.to_numpy()[np.argsort(-score)]
    table = {k: int(hits[:k].sum()) for k in (10, 50, 100, 200, 300, 500, 1000)}
    auc, ap = roc_auc_score(y_te, score), average_precision_score(y_te, score)
    print(f"  isolation forest on {len(y_te)} transactions, {int(y_te.sum())} frauds: ROC AUC {auc:.3f}, AP {ap:.3f}")
    print("  frauds found at each review size:", table)
    FOUND["fraud_rank"] = (auc, ap, table, int(y_te.sum()), len(y_te))

    messages = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
    train_part = messages[messages["split"] == "train"]
    val = train_part.sample(2000, random_state=42)
    pool = train_part.drop(val.index)
    vectorizer = TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True).fit(pool["text"])
    X_pool, X_val = vectorizer.transform(pool["text"]), vectorizer.transform(val["text"])
    y_pool, y_val = pool["label"].to_numpy(), val["label"].to_numpy()
    make = lambda: LogisticRegression(max_iter=2000, C=10)
    rng = np.random.default_rng(42)
    labeled = rng.choice(len(y_pool), 1000, replace=False)
    alone = accuracy_score(y_val, make().fit(X_pool[labeled], y_pool[labeled]).predict(X_val))
    partial = np.full(len(y_pool), -1)
    partial[labeled] = y_pool[labeled]
    semi = SelfTrainingClassifier(make(), threshold=0.80).fit(X_pool, partial)
    pseudo = semi.labeled_iter_ > 0
    together = accuracy_score(y_val, semi.predict(X_val))
    right = np.mean(semi.transduction_[pseudo] == y_pool[pseudo])
    ceiling = accuracy_score(y_val, make().fit(X_pool, y_pool).predict(X_val))
    print(f"  Banking77, 1,000 labels: alone {alone:.3f}; self-training {together:.3f} after {int(pseudo.sum())} pseudo-labels, "
          f"{right:.1%} right; every label {ceiling:.3f}")
    FOUND["self_msgs"] = (alone, together, int(pseudo.sum()), right, ceiling)
    start = np.concatenate([rng.choice(np.where(y_pool == c)[0], 2, replace=False) for c in range(77)])
    active_set, random_set = list(start), list(start)
    rng_random = np.random.default_rng(123)
    curve = []
    for round_no in range(10):
        active = make().fit(X_pool[active_set], y_pool[active_set])
        randomly = make().fit(X_pool[random_set], y_pool[random_set])
        curve.append((len(active_set), accuracy_score(y_val, active.predict(X_val)), accuracy_score(y_val, randomly.predict(X_val))))
        if round_no == 9:
            break
        unlabeled = np.setdiff1d(np.arange(len(y_pool)), active_set)
        probs = np.sort(active.predict_proba(X_pool[unlabeled]), axis=1)
        active_set += unlabeled[np.argsort(probs[:, -1] - probs[:, -2])[:100]].tolist()
        unlabeled = np.setdiff1d(np.arange(len(y_pool)), random_set)
        random_set += rng_random.choice(unlabeled, 100, replace=False).tolist()
    print("  active-learning curve (labels, uncertainty, random):", [(n, round(a, 3), round(r, 3)) for n, a, r in curve])
    FOUND["active_msgs"] = curve

def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert close(f["ari_scale"], 0.172, 0.001) and close(f["ari_spend"], 1.0, 0.0005)
    assert close(f["sil"][0], 0.8125) and close(f["sil"][1], 0.85)
    customer_starts, image_starts = f["restarts"]
    assert close(min(customer_starts), 4963.7, 0.05) and close(max(customer_starts), 4964.0, 0.05)
    assert close(min(image_starts), 248598, 1) and close(max(image_starts), 251895, 1)
    assert close(f["elbow"][2][1], 0.439, 0.001) and close(f["elbow"][4][1], 0.365, 0.001) and close(f["elbow"][8][0], 2919.8, 0.1)
    assert close(f["resp"], 0.881, 0.001) and close(f["fcm"], 0.9)
    assert f["dbscan"] == ["core", "core", "core", "core", "core", "border", "noise", "noise"]
    assert close(f["moons"][0], 0.24, 0.03) and close(f["moons"][1], 1.0, 0.01)
    assert close(f["pca_raw"][0], 0.802, 0.002) and close(f["pca_scaled"][0], 0.633, 0.002)
    share, cumulative, counts = f["wood"]
    assert counts == [2, 21, 51, 253] and close(share[0], 0.391, 0.001) and close(cumulative[9], 0.839, 0.001) and close(cumulative[20], 0.902, 0.001)
    # PCA plus logistic regression moves by a few images out of 5,000 between runs (threaded BLAS rounding),
    # so these are checked to within 0.002, as check_your_turn.py checks them.
    printed = {2: 0.420, 10: 0.538, 50: 0.591, 248: 0.608, 3072: 0.618}
    assert sorted(f["components"]) == sorted(printed)
    assert all(close(f["components"][k], v, 0.002) for k, v in printed.items()), f["components"]
    mean, sd, z, median, mad, robust, low, high = f["mask"]
    assert close(mean, 16.62) and close(sd, 17.55) and close(z, 2.47) and median == 10.5 and mad == 0.5
    assert close(robust, 66.8, 0.1) and low == 8.125 and high == 13.125
    assert close(f["cuts"][0], 1.6, 0.3) and close(f["cuts"][1], 9.6, 0.7)
    assert close(f["lof"][0], 0.20, 0.01) and close(f["lof"][1], 2.0, 0.01) and close(f["lof"][2], 1.2, 0.01)
    assert close(f["lof"][3], 1.0, 0.05) and close(f["lof"][4], 4.71, 0.3)
    assert f["self"] == [4.0, 5.0, 6.0] and np.allclose(f["chain"], [1, 0.8, 0.6, 0.4, 0.2, 0], atol=0.001)
    assert sorted(f["picks"]) == [1, 4]
    auc, ap, table, frauds, rows = f["fraud_rank"]
    assert (frauds, rows) == (148, 85443) and close(auc, 0.950, 0.001) and close(ap, 0.219, 0.001)
    assert table == {10: 7, 50: 25, 100: 39, 200: 50, 300: 63, 500: 69, 1000: 99}, table
    alone, together, adopted, right, ceiling = f["self_msgs"]
    assert close(alone, 0.638, 0.001) and close(together, 0.632, 0.001) and adopted == 486 and close(right, 0.988, 0.001)
    assert close(ceiling, 0.882, 0.001)
    expected = [(154, 0.319, 0.319), (254, 0.36, 0.368), (354, 0.464, 0.438), (454, 0.532, 0.505), (554, 0.594, 0.546),
                (654, 0.616, 0.579), (754, 0.653, 0.606), (854, 0.674, 0.631), (954, 0.7, 0.648), (1054, 0.712, 0.679)]
    assert all(n == m and close(a, b, 0.001) and close(c, d, 0.001) for (n, a, c), (m, b, d) in zip(f["active_msgs"], expected))
    print("\nEvery number above matches the book.")


def main():
    chapter20()
    chapter21()
    chapter22()
    chapter23()
    chapter25()
    lab5_numbers()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
