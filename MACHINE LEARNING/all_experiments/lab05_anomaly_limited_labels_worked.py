# Complete executable companion to lab05_anomaly_limited_labels_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, average_precision_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.semi_supervised import SelfTrainingClassifier

PROJECT_ROOT = Path.cwd().parent
DATA = PROJECT_ROOT / "all_datasets"

RESULTS = PROJECT_ROOT / "results" / "lab05"
RESULTS.mkdir(parents=True, exist_ok=True)
print("course folder:", PROJECT_ROOT.name)

fraud = pd.read_csv(DATA / "credit_card_fraud_dataset.csv")
print(fraud.head())

feature_cols = [
    "amount", "transaction_hour", "foreign_transaction", "location_mismatch",
    "device_trust_score", "velocity_last_24h", "cardholder_age",
]
X = fraud[feature_cols]
y = fraud["is_fraud"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.30, random_state=42, stratify=y
)

forest = IsolationForest(n_estimators=300, contamination="auto", random_state=42, n_jobs=-1)
forest.fit(X_train)                                   # no labels passed
anomaly_score = -forest.decision_function(X_test)     # higher = more unusual

prevalence = y_test.mean()
ap = average_precision_score(y_test, anomaly_score)
print("fraud prevalence:", round(prevalence, 4))
print("ROC AUC:", round(roc_auc_score(y_test, anomaly_score), 4))
print("average precision:", round(ap, 4), " (", round(ap / prevalence, 1), "x prevalence)")

ranked = X_test.copy()
ranked["fraud_label"] = y_test.to_numpy()
ranked["anomaly_score"] = anomaly_score
ranked = ranked.sort_values("anomaly_score", ascending=False)
review_budget = 100
top_k_precision = ranked.head(review_budget)["fraud_label"].mean()
print(f"fraud found in the top {review_budget}: {top_k_precision:.0%}")
print(ranked[["fraud_label", "anomaly_score", "amount"]].head(10))

hits = ranked["fraud_label"].to_numpy()
k_values = np.arange(10, 1001, 10)
precision_at_k = [hits[:k].mean() for k in k_values]

fig, axes = plt.subplots(1, 2, figsize=(10, 3.6))
axes[0].hist(anomaly_score[y_test.to_numpy() == 0], bins=30, alpha=0.65, label="non-fraud")
axes[0].hist(anomaly_score[y_test.to_numpy() == 1], bins=30, alpha=0.65, label="fraud")
axes[0].set_xlabel("Anomaly score")
axes[0].set_ylabel("Transactions")
axes[0].set_title("Isolation Forest score distribution")
axes[0].legend()
axes[1].plot(k_values, precision_at_k)
axes[1].axhline(prevalence, linestyle="--", color="grey", label=f"prevalence {prevalence:.1%}")
axes[1].set_xlabel("Number of top-ranked cases reviewed (k)")
axes[1].set_ylabel("Fraud rate among those k")
axes[1].set_title("Precision falls as the review budget grows")
axes[1].legend()
plt.tight_layout()
plt.savefig(RESULTS / "precision_falls_as_the_review_budget_grows.png", dpi=160, bbox_inches="tight")
plt.show()

rng = np.random.default_rng(42)

cancer = pd.read_csv(DATA / "breast_cancer_dataset.csv")
X_c = cancer.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
y_c = (cancer["diagnosis"] == "M").astype(int).to_numpy()

X_dev, Xc_test, y_dev, yc_test = train_test_split(
    X_c, y_c, test_size=0.25, random_state=42, stratify=y_c
)
X_pool, X_val, y_pool, y_val = train_test_split(
    X_dev, y_dev, test_size=0.25, random_state=7, stratify=y_dev
)
X_pool = X_pool.reset_index(drop=True)
y_pool = np.asarray(y_pool)
print("pool:", len(X_pool), " validation:", len(X_val), " test:", len(Xc_test))

def make_model():
    return Pipeline([
        ("scale", StandardScaler()),
        ("model", LogisticRegression(max_iter=2000)),
    ])

y_partial = y_pool.copy()
y_partial[rng.random(len(y_partial)) < 0.70] = -1
print("labels kept:", int((y_partial != -1).sum()), "of", len(y_partial))

semi = Pipeline([
    ("scale", StandardScaler()),
    ("model", SelfTrainingClassifier(LogisticRegression(max_iter=2000), threshold=0.90)),
])
semi.fit(X_pool, y_partial)
print("self-training validation accuracy:",
      round(accuracy_score(y_val, semi.predict(X_val)), 3))

class0 = np.where(y_pool == 0)[0]
class1 = np.where(y_pool == 1)[0]
initial = np.concatenate([rng.choice(class0, 20, replace=False),
                          rng.choice(class1, 20, replace=False)])
active_labeled = set(initial.tolist())
random_labeled = set(initial.tolist())
rng_random = np.random.default_rng(123)

query_batch, rounds = 15, 8
label_counts, active_scores, random_scores = [], [], []

for round_no in range(rounds):
    active_idx, random_idx = sorted(active_labeled), sorted(random_labeled)
    active = make_model().fit(X_pool.iloc[active_idx], y_pool[active_idx])
    random_model = make_model().fit(X_pool.iloc[random_idx], y_pool[random_idx])

    label_counts.append(len(active_labeled))
    active_scores.append(accuracy_score(y_val, active.predict(X_val)))
    random_scores.append(accuracy_score(y_val, random_model.predict(X_val)))
    print(f"round {round_no + 1}: labels={label_counts[-1]:3d}  "
          f"uncertainty={active_scores[-1]:.3f}  random={random_scores[-1]:.3f}")
    if round_no == rounds - 1:
        break

    unlabeled = np.array([i for i in range(len(X_pool)) if i not in active_labeled])
    uncertainty = np.abs(active.predict_proba(X_pool.iloc[unlabeled])[:, 1] - 0.5)
    active_labeled.update(unlabeled[np.argsort(uncertainty)[:query_batch]].tolist())

    unlabeled = np.array([i for i in range(len(X_pool)) if i not in random_labeled])
    random_labeled.update(rng_random.choice(unlabeled, query_batch, replace=False).tolist())

plt.figure(figsize=(6, 3.6))
plt.plot(label_counts, active_scores, marker="o", label="uncertainty sampling")
plt.plot(label_counts, random_scores, marker="o", label="random querying")
plt.xlabel("Number of labelled pool examples")
plt.ylabel("Validation accuracy")
plt.title("Label efficiency during development")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "label_efficiency_during_development.png", dpi=160, bbox_inches="tight")
plt.show()

active_idx, random_idx = sorted(active_labeled), sorted(random_labeled)
active_final = make_model().fit(X_pool.iloc[active_idx], y_pool[active_idx])
random_final = make_model().fit(X_pool.iloc[random_idx], y_pool[random_idx])
print("final test accuracy, uncertainty sampling:",
      round(accuracy_score(yc_test, active_final.predict(Xc_test)), 3))
print("final test accuracy, random querying:    ",
      round(accuracy_score(yc_test, random_final.predict(Xc_test)), 3))

pd.DataFrame([{"part": "A", "dataset": "credit_card_fraud", "model": "isolation_forest",
               "prevalence": prevalence, "roc_auc": roc_auc_score(y_test, anomaly_score),
               "average_precision": ap, f"precision_at_{review_budget}": top_k_precision},
              {"part": "B", "dataset": "breast_cancer", "model": "self_training (30% labels)",
               "validation_accuracy": accuracy_score(y_val, semi.predict(X_val))},
              {"part": "B", "dataset": "breast_cancer", "model": "active (uncertainty)",
               "test_accuracy": accuracy_score(yc_test, active_final.predict(Xc_test))},
              {"part": "B", "dataset": "breast_cancer", "model": "active (random)",
               "test_accuracy": accuracy_score(yc_test, random_final.predict(Xc_test))}]).round(4).to_csv(
    RESULTS / "metrics.csv", index=False)
ranked.head(review_budget).to_csv(RESULTS / "top_ranked_transactions.csv")
pd.DataFrame({"labels": label_counts, "uncertainty_sampling": active_scores,
              "random_querying": random_scores}).round(4).to_csv(RESULTS / "active_learning_curve.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# Your work here

for budget in [50, 100, 300]:
    print(f"top {budget:3d} reviewed: fraud rate = {hits[:budget].mean():.1%}  ({int(hits[:budget].sum())} frauds found)")

def run_active_learning(n_per_class, rounds=8, query_batch=15, seed=42):
    r = np.random.default_rng(seed)
    r_random = np.random.default_rng(seed + 1)
    start = np.concatenate([r.choice(class0, n_per_class, replace=False),
                            r.choice(class1, n_per_class, replace=False)])
    active_set, random_set = set(start.tolist()), set(start.tolist())
    counts, act, rnd = [], [], []
    for round_no in range(rounds):
        a_idx, r_idx = sorted(active_set), sorted(random_set)
        a_model = make_model().fit(X_pool.iloc[a_idx], y_pool[a_idx])
        r_model = make_model().fit(X_pool.iloc[r_idx], y_pool[r_idx])
        counts.append(len(active_set))
        act.append(accuracy_score(y_val, a_model.predict(X_val)))
        rnd.append(accuracy_score(y_val, r_model.predict(X_val)))
        if round_no == rounds - 1:
            break
        unl = np.array([i for i in range(len(X_pool)) if i not in active_set])
        unc = np.abs(a_model.predict_proba(X_pool.iloc[unl])[:, 1] - 0.5)
        active_set.update(unl[np.argsort(unc)[:query_batch]].tolist())
        unl = np.array([i for i in range(len(X_pool)) if i not in random_set])
        random_set.update(r_random.choice(unl, query_batch, replace=False).tolist())
    return counts, act, rnd

counts10, act10, rnd10 = run_active_learning(n_per_class=10)
plt.figure(figsize=(6, 3.6))
plt.plot(counts10, act10, marker="o", label="uncertainty sampling")
plt.plot(counts10, rnd10, marker="o", label="random querying")
plt.xlabel("Number of labelled pool examples")
plt.ylabel("Validation accuracy")
plt.title("Starting from 20 labels instead of 40")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "active_learning_from_20_labels.png", dpi=160, bbox_inches="tight")
plt.show()
for c, a, r_ in zip(counts10, act10, rnd10):
    print(f"labels={c:3d}  uncertainty={a:.3f}  random={r_:.3f}")

