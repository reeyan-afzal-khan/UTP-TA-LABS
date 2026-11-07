"""The small worked numbers of Chapters 15 to 19: clusters, shadows, anomalies, limited labels.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. Pieces that need a course dataset read it from all_datasets/.

Run from the course folder:      python all_experiments/demo_unsupervised.py
It takes a few seconds.
"""
from __future__ import annotations

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")   # avoids a known K-means warning on Windows
import zipfile
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.cluster import DBSCAN, KMeans
from sklearn.datasets import make_moons
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import adjusted_rand_score, silhouette_samples
from sklearn.neighbors import LocalOutlierFactor, NearestNeighbors
from sklearn.preprocessing import StandardScaler

DATA = Path(__file__).resolve().parent.parent / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}


def chapter15():
    print("Chapter 15")
    customers = pd.read_csv(DATA / "mall_customers_dataset.csv")
    cols = ["Age", "Annual Income (k$)", "Spending Score (1-100)"]
    raw = customers[cols].to_numpy(dtype=float)
    scaled = StandardScaler().fit_transform(raw)
    raw_labels = KMeans(5, n_init=30, random_state=42).fit_predict(raw)
    scaled_labels = KMeans(5, n_init=30, random_state=42).fit_predict(scaled)
    agreement = adjusted_rand_score(raw_labels, scaled_labels)
    print(f"Mall customers, k = 5: raw units against standardized, adjusted Rand index {agreement:.3f}")
    print("Column standard deviations:", customers[cols].std().round(1).to_dict())
    FOUND["ari_scale"] = agreement

    # A second chance to check: income in ringgit per year instead of thousands of dollars.
    ringgit = raw.copy()
    ringgit[:, 1] *= 4400
    ringgit_labels = KMeans(5, n_init=30, random_state=42).fit_predict(ringgit)
    by_income = adjusted_rand_score(ringgit_labels, KMeans(5, n_init=30, random_state=42).fit_predict(ringgit[:, [1]]))
    print(f"Income rescaled by 4400: clusters agree {by_income:.3f} with clustering on income alone")
    FOUND["ari_income"] = by_income


def chapter16():
    print("\nChapter 16")
    # Silhouette by hand on six numbers in two groups.
    x = np.array([1, 2, 3, 10, 11, 12], dtype=float).reshape(-1, 1)
    labels = np.array([0, 0, 0, 1, 1, 1])
    a3, b3 = np.mean([2, 1]), np.mean([7, 8, 9])
    print(f"Silhouette of the point 3: a = {a3}, b = {b3}, s = {(b3 - a3) / max(a3, b3):.4f}")
    s = silhouette_samples(x, labels)
    print("  all six:", s.round(3).tolist(), f"mean {s.mean():.3f}")
    FOUND["sil"] = (s[2], s.mean())

    # One random start or many: the mall customers of Lab 4.
    customers = pd.read_csv(DATA / "mall_customers_dataset.csv")
    X = StandardScaler().fit_transform(customers[["Age", "Annual Income (k$)", "Spending Score (1-100)"]])
    inertia = [KMeans(5, n_init=1, random_state=seed).fit(X).inertia_ for seed in range(8)]
    print("Mall, k = 5, one random start, seeds 0-7:", np.round(inertia, 1).tolist())
    FOUND["restarts"] = inertia

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


def chapter17():
    print("\nChapter 17")
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

    columns = [f"pixel_{i}" for i in range(64)] + ["label"]
    with zipfile.ZipFile(DATA / "optical_recognition_handwritten_digits.zip") as archive:
        members = {Path(name).name: name for name in archive.namelist()}
        train = pd.read_csv(archive.open(members["optdigits.tra"]), header=None, names=columns)
    digits = train.drop(columns="label") / 16.0
    full = PCA(svd_solver="full").fit(digits)
    share, cumulative = full.explained_variance_ratio_, np.cumsum(full.explained_variance_ratio_)
    print("Digits, first ten shares:", share[:10].round(3).tolist())
    picks = [1, 2, 3, 4, 5, 8, 10, 15, 21, 29, 41, 50, 64]
    print("Digits cumulative:", " ".join(f"({k},{cumulative[k - 1]:.3f})" for k in picks))
    FOUND["digits"] = (share, cumulative)
    print(f"Components for 90, 95, 99 percent: {[int(np.searchsorted(cumulative, t) + 1) for t in (0.90, 0.95, 0.99)]}")


def chapter18():
    print("\nChapter 18")
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


def chapter19():
    print("\nChapter 19")
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


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert close(f["ari_scale"], 0.602, 0.01) and close(f["ari_income"], 1.0, 0.01)
    assert close(f["sil"][0], 0.8125) and close(f["sil"][1], 0.85)
    assert close(min(f["restarts"]), 168.2, 0.1) and close(max(f["restarts"]), 194.4, 0.3)
    assert close(f["resp"], 0.881, 0.001) and close(f["fcm"], 0.9)
    assert f["dbscan"] == ["core", "core", "core", "core", "core", "border", "noise", "noise"]
    assert close(f["moons"][0], 0.24, 0.03) and close(f["moons"][1], 1.0, 0.01)
    assert close(f["pca_raw"][0], 0.802, 0.002) and close(f["pca_scaled"][0], 0.633, 0.002)
    share, cumulative = f["digits"]
    assert close(cumulative[20], 0.904, 0.002) and close(cumulative[28], 0.954, 0.002) and close(cumulative[40], 0.990, 0.002)
    mean, sd, z, median, mad, robust, low, high = f["mask"]
    assert close(mean, 16.62) and close(sd, 17.55) and close(z, 2.47) and median == 10.5 and mad == 0.5
    assert close(robust, 66.8, 0.1) and low == 8.125 and high == 13.125
    assert close(f["cuts"][0], 1.6, 0.3) and close(f["cuts"][1], 9.6, 0.7)
    assert close(f["lof"][0], 0.20, 0.01) and close(f["lof"][1], 2.0, 0.01) and close(f["lof"][2], 1.2, 0.01)
    assert close(f["lof"][3], 1.0, 0.05) and close(f["lof"][4], 4.71, 0.3)
    assert f["self"] == [4.0, 5.0, 6.0] and np.allclose(f["chain"], [1, 0.8, 0.6, 0.4, 0.2, 0], atol=0.001)
    assert sorted(f["picks"]) == [1, 4]
    print("\nEvery number above matches the book.")


def main():
    chapter15()
    chapter16()
    chapter17()
    chapter18()
    chapter19()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
