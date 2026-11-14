"""Lab 04: Unsupervised learning I: clustering and PCA.

The code cells of lab04_clustering_pca_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab04_clustering_pca/lab04_clustering_pca_worked.py
It writes the same figures and tables as the notebook, to results/lab04/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses.
import joblib                                                      # save and load fitted models
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.cluster import DBSCAN, KMeans                         # two ways to find groups
from sklearn.decomposition import PCA                              # compress many columns into a few
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, adjusted_rand_score, recall_score, silhouette_score
from sklearn.model_selection import GroupShuffleSplit                # each board stays on one side
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab04")

# %% Question 2 - Build one row per customer
# Every invoice line of the shop. Invoice and StockCode are read as text: some codes carry letters.
lines = pd.read_csv(DATA / "unsupervised/online_retail_ii/online_retail_ii.zip",
                    dtype={"Invoice": str, "StockCode": str}, parse_dates=["InvoiceDate"])
print("invoice lines:", len(lines),
      " from", lines["InvoiceDate"].min().date(), "to", lines["InvoiceDate"].max().date())
print("no customer ID:", round(lines["Customer ID"].isna().mean(), 3),
      " cancellations:", round(lines["Invoice"].str.startswith("C").mean(), 3),
      " exact duplicates:", int(lines.duplicated().sum()))

# Fixed cleaning rules: known customers, real sales (no cancellations, returns or free items),
# no repeated lines.
sales = lines.dropna(subset=["Customer ID"])
real_sale = ~sales["Invoice"].str.startswith("C") & (sales["Quantity"] > 0) & (sales["Price"] > 0)
sales = sales[real_sale].drop_duplicates()
sales = sales.assign(revenue=sales["Quantity"] * sales["Price"])

# One row per customer: recency, frequency and monetary value (RFM),
# counted from the day after the last sale.
day_after = sales["InvoiceDate"].max().normalize() + pd.Timedelta(days=1)
customers = sales.groupby("Customer ID").agg(
    recency_days=("InvoiceDate", lambda dates: (day_after - dates.max()).days),   # days since last order
    orders=("Invoice", "nunique"),                                                # separate orders
    spend=("revenue", "sum"),                                                     # total spent, in pounds
)
print(len(sales), "clean lines from", len(customers), "customers")
print(customers.describe().loc[["50%", "mean", "max"]].round(1).to_string())

# Logs tame the long tails (a few customers spend thousands of times more), and scaling puts the three
# columns on one ruler, so each counts equally in a distance.
features = ["recency_days", "orders", "spend"]
X = StandardScaler().fit_transform(np.log1p(customers[features]))

# %% Question 3 - Score k from 2 to 8
# Fit K-means for k = 2 to 8, and score each split two ways.
ks, inertias, silhouettes = [], [], []
for k in range(2, 9):
    kmeans = KMeans(n_clusters=k, n_init=20, random_state=42)       # 20 random starts; keep the best
    labels = kmeans.fit_predict(X)
    ks.append(k)
    inertias.append(kmeans.inertia_)                                # total squared distance to the centers
    silhouettes.append(silhouette_score(X, labels))                 # +1 well separated, 0 overlapping
    print(f"k={k}  inertia={kmeans.inertia_:.1f}  silhouette={silhouettes[-1]:.3f}")

fig, axes = plt.subplots(1, 2, figsize=(9.5, 3.4))
axes[0].plot(ks, inertias, marker="o")
axes[0].set_xlabel("Number of clusters k")
axes[0].set_ylabel("Inertia")
axes[0].set_title("Elbow: look for the bend")
axes[1].plot(ks, silhouettes, marker="o")
axes[1].set_xlabel("Number of clusters k")
axes[1].set_ylabel("Silhouette score")
axes[1].set_title("Silhouette: look for the peak")
plt.tight_layout()
plt.savefig(RESULTS / "elbow_and_silhouette.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 4 - Compare K-means with DBSCAN
# K-means with four segments: every customer is placed in one of them.
kmeans = KMeans(n_clusters=4, n_init=20, random_state=42)
k_labels = kmeans.fit_predict(X)
print("K-means (k=4) silhouette:", round(silhouette_score(X, k_labels), 3))

# DBSCAN: dense groups only. A customer with fewer than 10 others within 0.5 is labeled -1, noise.
dbscan = DBSCAN(eps=0.5, min_samples=10)
d_labels = dbscan.fit_predict(X)
is_noise = d_labels == -1
noise_revenue = customers.loc[is_noise, "spend"].sum() / customers["spend"].sum()
print("DBSCAN clusters:", len(set(d_labels[~is_noise])), " noise customers:", int(is_noise.sum()),
      " their share of revenue:", round(noise_revenue, 3))
print("noise customers' median orders and spend:",
      customers.loc[is_noise, ["orders", "spend"]].median().round(0).to_dict())

# %% Question 5 - Describe the segments
# Describe each K-means segment by its typical customer, and its share of all revenue.
segments = customers.assign(kmeans_cluster=k_labels, dbscan_cluster=d_labels)
profile = segments.groupby("kmeans_cluster").agg(
    customers=("orders", "size"),
    recency_days=("recency_days", "median"),
    orders=("orders", "median"),
    spend=("spend", "median"),
    revenue=("spend", "sum"),
)
profile["revenue_share"] = (profile.pop("revenue") / customers["spend"].sum()).round(3)
print(profile.round({"recency_days": 0, "orders": 0, "spend": 0, "revenue_share": 3}).to_string())

# %% Question 6 - Plot both clusterings
fig, axes = plt.subplots(1, 2, figsize=(10, 3.9))
clusterings = [(axes[0], k_labels, "K-means, k = 4"),
               (axes[1], d_labels, "DBSCAN, eps = 0.5 (noise = -1)")]
for ax, labels, title in clusterings:
    scatter = ax.scatter(customers["orders"], customers["spend"], c=labels, cmap="tab10", s=6, alpha=0.7)
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("orders (log scale)")
    ax.set_ylabel("spend in pounds (log scale)")
    ax.set_title(title)
    ax.legend(*scatter.legend_elements(), title="cluster", fontsize=8, loc="lower right")
plt.tight_layout()
plt.savefig(RESULTS / "kmeans_and_dbscan_segments.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 7 - Load the images
wood = np.load(DATA / "unsupervised/wood_surface_defects/wood_defects.npz")
images, labels, boards = wood["x"], wood["y"], wood["board"]
class_names = [str(name) for name in wood["classes"]]
print("images:", images.shape, " boards:", len(np.unique(boards)))
print("per defect type:", dict(zip(class_names, np.bincount(labels).tolist())))

# Each 32 x 32 colour image becomes one row of 32 * 32 * 3 = 3,072 numbers, and 0-255 becomes 0-1.
X_all = images.reshape(len(images), -1) / 255.0

# Most boards have several defects, so whole boards go to one side of each split: no board is in both.
dev_rows, test_rows = next(GroupShuffleSplit(n_splits=1, test_size=0.20, random_state=42)
                           .split(X_all, labels, boards))
X_dev, y_dev, b_dev = X_all[dev_rows], labels[dev_rows], boards[dev_rows]
X_test, y_test = X_all[test_rows], labels[test_rows]
print(len(X_dev), "development and", len(X_test), "test images; boards in both:",
      len(set(b_dev) & set(boards[test_rows])))

fig, axes = plt.subplots(1, 7, figsize=(10, 1.9))
for ax, k in zip(axes, range(7)):
    first = np.flatnonzero(labels == k)[0]                  # the first image of each defect type
    ax.imshow(images[first])
    ax.set_title(class_names[k], fontsize=8)
    ax.axis("off")
plt.suptitle("One image of each defect type (32 x 32 colour pixels)", y=1.08)
plt.savefig(RESULTS / "one_image_of_each_defect_type.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 8 - Choose a PCA budget on validation
# Choose the budget on a split of the development images, again board by board.
fit_rows, valid_rows = next(GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=42)
                            .split(X_dev, y_dev, b_dev))
X_fit, y_fit = X_dev[fit_rows], y_dev[fit_rows]
X_valid, y_valid = X_dev[valid_rows], y_dev[valid_rows]

baseline = LogisticRegression(max_iter=3000)              # 3,072 inputs need more steps to converge
baseline.fit(X_fit, y_fit)
print("all 3,072 pixels: validation accuracy =",
      round(accuracy_score(y_valid, baseline.predict(X_valid)), 4))

# PCA keeps as many components as it needs to hold the given share of the variance.
for retained_variance in [0.90, 0.95, 0.99]:
    candidate = Pipeline([
        ("pca", PCA(n_components=retained_variance, svd_solver="full")),
        ("model", LogisticRegression(max_iter=1000)),
    ])
    candidate.fit(X_fit, y_fit)
    n_kept = candidate.named_steps["pca"].n_components_
    accuracy = accuracy_score(y_valid, candidate.predict(X_valid))
    print(f"{retained_variance:.0%} variance: {n_kept:3d} components, "
          f"validation accuracy = {accuracy:.4f}")

# %% Question 9 - Open the test images once
# The chosen budget, 99%, refitted on all the development images; the plain model too, for comparison.
final_model = Pipeline([
    ("pca", PCA(n_components=0.99, svd_solver="full")),
    ("model", LogisticRegression(max_iter=1000)),
])
final_model.fit(X_dev, y_dev)
full_model = LogisticRegression(max_iter=3000)
full_model.fit(X_dev, y_dev)
pca = final_model.named_steps["pca"]

print(f"FINAL TEST ({len(X_test):,} images from boards never seen in development)")
print("all 3,072 pixels accuracy:", round(accuracy_score(y_test, full_model.predict(X_test)), 4))
print("PCA components kept:", pca.n_components_,
      " variance retained:", round(pca.explained_variance_ratio_.sum(), 4))
print("PCA -> logistic accuracy:", round(accuracy_score(y_test, final_model.predict(X_test)), 4))
recall_by_type = recall_score(y_test, final_model.predict(X_test), average=None).round(2).tolist()
print("recall per defect type:", dict(zip(class_names, recall_by_type)))

# %% Question 10 - See what 99% looks like
# Compress eight test images to a few components and to the kept ones,
# then expand them back to 3,072 numbers.
few = PCA(n_components=0.90, svd_solver="full").fit(X_dev)
rows = [("original", X_test[:8]),
        (f"{few.n_components_} components (90%)", few.inverse_transform(few.transform(X_test[:8]))),
        (f"{pca.n_components_} components (99%)", pca.inverse_transform(pca.transform(X_test[:8])))]

fig, axes = plt.subplots(3, 8, figsize=(9, 3.6))
for i, (title, batch) in enumerate(rows):
    for j in range(8):
        axes[i, j].imshow(np.clip(batch[j].reshape(32, 32, 3), 0, 1))
        axes[i, j].axis("off")
    axes[i, 0].set_title(title, fontsize=8, loc="left")
plt.savefig(RESULTS / "originals_and_rebuilt_images.png", dpi=160, bbox_inches="tight")
plt.show()

# All components on the development images: how many are needed for each share of the variance?
all_components = PCA(svd_solver="full").fit(X_dev)
cumulative = np.cumsum(all_components.explained_variance_ratio_)
needed = [int(np.searchsorted(cumulative, share) + 1) for share in (0.50, 0.80, 0.90, 0.95, 0.99)]
print("components for 50%, 80%, 90%, 95% and 99% of the variance:", needed)
print("the first three components hold", round(cumulative[2], 3), "of the variance")

plt.figure(figsize=(5.5, 3.4))
plt.plot(np.arange(1, len(cumulative) + 1), cumulative)
plt.xscale("log")
plt.axhline(0.99, linestyle="--", color="grey")
plt.axvline(pca.n_components_, linestyle="--", color="grey")
plt.xlabel("Number of principal components (log scale)")
plt.ylabel("Cumulative explained variance")
plt.title("A few directions hold the light; the defect needs many more")
plt.tight_layout()
plt.savefig(RESULTS / "cumulative_explained_variance.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 11 - Save and reload the model
# Save the PCA and the classifier together, load them back, and predict five test images.
model_path = MODELS / "wood_pca_logistic.joblib"
joblib.dump(final_model, model_path)

loaded = joblib.load(model_path)
print("file size (MB):", round(model_path.stat().st_size / 1e6, 2))
print("predicted:", [class_names[i] for i in loaded.predict(X_test[:5])])
print("actual:   ", [class_names[i] for i in y_test[:5]])

# %% Question 12 - Save the evidence
diagnostics = pd.DataFrame({"k": ks, "inertia": inertias, "silhouette": silhouettes})
diagnostics.round(4).to_csv(RESULTS / "kmeans_diagnostics.csv", index=False)
profile.to_csv(RESULTS / "customer_segments.csv")
variance_table = pd.DataFrame({"component": np.arange(1, len(cumulative) + 1),
                               "cumulative_variance": cumulative})
variance_table.round(4).to_csv(RESULTS / "pca_cumulative_variance.csv", index=False)
metrics = pd.DataFrame([
    {"dataset": "wood_surface_defects (test boards)", "model": "logistic, 3,072 pixels",
     "test_accuracy": accuracy_score(y_test, full_model.predict(X_test))},
    {"dataset": "wood_surface_defects (test boards)", "model": f"PCA({pca.n_components_}) -> logistic",
     "test_accuracy": accuracy_score(y_test, final_model.predict(X_test))},
])
metrics.round(4).to_csv(RESULTS / "metrics.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 13 - Try it yourself
# Your work here

# %% Question 14 - One solution
# Cluster the development images without their labels, then ask what the clusters contain.
codes = PCA(n_components=50, random_state=42).fit_transform(X_fit)          # 50 numbers per image
image_clusters = KMeans(n_clusters=7, n_init=10, random_state=42).fit_predict(codes)
print("adjusted Rand index against the true defect types:",
      round(adjusted_rand_score(y_fit, image_clusters), 3))

# Count the true types inside each cluster; purity is the share of its most common type.
table = pd.crosstab(pd.Series(image_clusters, name="cluster"),
                    pd.Categorical.from_codes(y_fit, class_names))
summary = pd.DataFrame({
    "images": table.sum(axis=1),
    "most common type": table.idxmax(axis=1),
    "purity": (table.max(axis=1) / table.sum(axis=1)).round(2),
})
print(summary.sort_values("purity", ascending=False).to_string())

# What does each cluster look like? Its average image.
fig, axes = plt.subplots(1, 7, figsize=(10, 1.9))
for ax, c in zip(axes, range(7)):
    ax.imshow(X_fit[image_clusters == c].mean(axis=0).reshape(32, 32, 3))
    ax.set_title(f"cluster {c}", fontsize=8)
    ax.axis("off")
plt.suptitle("The average image of each cluster", y=1.08)
plt.savefig(RESULTS / "the_average_image_of_each_cluster.png", dpi=160, bbox_inches="tight")
plt.show()
