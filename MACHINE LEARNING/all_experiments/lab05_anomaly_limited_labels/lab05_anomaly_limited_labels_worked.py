"""Lab 05: Unsupervised learning II: anomaly detection and limited labels.

The code cells of lab05_anomaly_limited_labels_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab05_anomaly_limited_labels/lab05_anomaly_limited_labels_worked.py
It writes the same figures and tables as the notebook, to results/lab05/.
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
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest                       # an anomaly detector that needs no labels
from sklearn.feature_extraction.text import TfidfVectorizer        # messages -> word weights
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, average_precision_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.semi_supervised import SelfTrainingClassifier         # learns from its own confident guesses

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab05")

# %% Question 2 - Fit an Isolation Forest without labels
cards = pd.read_csv(DATA / "unsupervised/creditcard_fraud_ulb/creditcard_fraud_ulb.zip")
hours = cards["Time"].max() / 3600                                 # Time is in seconds
print("transactions:", len(cards), " over", round(hours), "hours;", int(cards["Class"].sum()), "frauds")

# V1-V28 are anonymized principal components; the amount gets a log for its long tail.
X = cards[[f"V{i}" for i in range(1, 29)]].copy()
X["log_amount"] = np.log1p(cards["Amount"])
y = cards["Class"]

# The labels are used only to split fairly (the same fraud rate on both sides) and, later, to score.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.30, random_state=42, stratify=y)

forest = IsolationForest(n_estimators=300, random_state=42, n_jobs=-1)
forest.fit(X_train)                                   # no labels passed
anomaly_score = -forest.decision_function(X_test)     # higher = more unusual

# %% Question 3 - Score the ranking
prevalence = y_test.mean()                            # the fraud rate: what random guessing would achieve
ap = average_precision_score(y_test, anomaly_score)
print("test transactions:", len(y_test), " frauds:", int(y_test.sum()), " prevalence:", round(prevalence, 5))
print("ROC AUC:", round(roc_auc_score(y_test, anomaly_score), 3))
print("average precision:", round(ap, 3), " (", round(ap / prevalence), "x prevalence)")

# The review list: every test transaction, most unusual first.
ranked = pd.DataFrame({
    "fraud_label": y_test.to_numpy(),
    "anomaly_score": anomaly_score,
    "amount": cards.loc[X_test.index, "Amount"].to_numpy(),
}).sort_values("anomaly_score", ascending=False)

review_budget = 100
found = int(ranked.head(review_budget)["fraud_label"].sum())
print(f"frauds in the top {review_budget} alerts: {found}")
print(ranked.head(10).round(3).to_string(index=False))

# %% Question 4 - Plot the scores and precision at k
# Precision at k: the fraud rate among the k most unusual transactions, for k = 10, 20, ..., 2000.
hits = ranked["fraud_label"].to_numpy()
k_values = np.arange(10, 2001, 10)
precision_at_k = [hits[:k].mean() for k in k_values]
is_fraud = y_test.to_numpy() == 1

fig, axes = plt.subplots(1, 2, figsize=(10, 3.6))
axes[0].hist(anomaly_score[~is_fraud], bins=50, alpha=0.65, density=True, label="genuine")
axes[0].hist(anomaly_score[is_fraud], bins=50, alpha=0.65, density=True, label="fraud")
axes[0].set_xlabel("Anomaly score")
axes[0].set_ylabel("Share of transactions")
axes[0].set_title("Frauds sit to the right, with overlap")
axes[0].legend()
axes[1].plot(k_values, precision_at_k)
axes[1].axhline(prevalence, linestyle="--", color="grey", label=f"prevalence {prevalence:.2%}")
axes[1].set_xlabel("Number of top-ranked cases reviewed (k)")
axes[1].set_ylabel("Fraud rate among those k")
axes[1].set_title("Precision falls as the review budget grows")
axes[1].legend()
plt.tight_layout()
plt.savefig(RESULTS / "precision_falls_as_the_review_budget_grows.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 5 - Split the messages three ways
messages = pd.read_csv(DATA / "advanced/banking77/banking77.csv")
intents = messages.drop_duplicates("label").sort_values("label")["intent"].tolist()      # label 0 to 76

# Three sets: a pool whose labels stay hidden until bought, a validation set, and the official test set.
train_part = messages[messages["split"] == "train"]
test = messages[messages["split"] == "test"]
val = train_part.sample(2000, random_state=42)
pool = train_part.drop(val.index)
print("pool:", len(pool), " validation:", len(val), " test:", len(test), " intents:", len(intents))
print(pool[["text", "intent"]].head(3).to_string(index=False))

# The vocabulary (single words and word pairs) is learned from the pool's text, which needs no labels.
vectorizer = TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True).fit(pool["text"])
X_pool = vectorizer.transform(pool["text"])
X_val = vectorizer.transform(val["text"])
X_msg_test = vectorizer.transform(test["text"])
y_pool = pool["label"].to_numpy()
y_val = val["label"].to_numpy()
y_msg_test = test["label"].to_numpy()
print("vocabulary:", len(vectorizer.vocabulary_), "words and word pairs")

def make_model():
    """The one classifier used throughout Part B, so only the labels differ between methods."""
    return LogisticRegression(max_iter=2000, C=10)

# %% Question 6 - Self-train from 1,000 labels
# 1. The baseline: a model trained on 1,000 randomly chosen labeled messages, an eighth of the pool.
rng = np.random.default_rng(42)
labeled = rng.choice(len(y_pool), 1000, replace=False)
labels_only = make_model().fit(X_pool[labeled], y_pool[labeled])
print("labels only (1,000 messages): validation accuracy", round(accuracy_score(y_val, labels_only.predict(X_val)), 3))

# 2. Self-training: the same 1,000 labels, plus its own guesses on the rest when it is at least 80% sure.
y_partial = np.full(len(y_pool), -1)                                    # -1 means unlabeled
y_partial[labeled] = y_pool[labeled]
semi = SelfTrainingClassifier(make_model(), threshold=0.80).fit(X_pool, y_partial)
pseudo = semi.labeled_iter_ > 0                                         # rows it labeled itself
adopted = int(pseudo.sum())
right = np.mean(semi.transduction_[pseudo] == y_pool[pseudo])
print(f"self-training adopted {adopted} pseudo-labels, {right:.1%} of them right")
print("self-training: validation accuracy", round(accuracy_score(y_val, semi.predict(X_val)), 3))

# 3. The ceiling: every one of the pool's labels.
ceiling = make_model().fit(X_pool, y_pool)
print(f"all {len(y_pool):,} labels (the ceiling):", round(accuracy_score(y_val, ceiling.predict(X_val)), 3))

# %% Question 7 - Simulate active learning
# Both policies start from the same 154 labels, 2 per intent, and buy 100 more labels in each round.
start = np.concatenate([rng.choice(np.where(y_pool == c)[0], 2, replace=False) for c in range(len(intents))])
active_set, random_set = list(start), list(start)
rng_random = np.random.default_rng(123)

query_batch, rounds = 100, 10
label_counts, active_scores, random_scores = [], [], []
for round_no in range(rounds):
    # Train on the labels bought so far, and score both models on validation.
    active = make_model().fit(X_pool[active_set], y_pool[active_set])
    random_model = make_model().fit(X_pool[random_set], y_pool[random_set])
    label_counts.append(len(active_set))
    active_scores.append(accuracy_score(y_val, active.predict(X_val)))
    random_scores.append(accuracy_score(y_val, random_model.predict(X_val)))
    print(f"round {round_no + 1:2d}: labels={label_counts[-1]:4d}  "
          f"uncertainty={active_scores[-1]:.3f}  random={random_scores[-1]:.3f}")
    if round_no == rounds - 1:
        break

    # Uncertainty sampling buys the 100 messages with the smallest margin between their top two intents.
    unlabeled = np.setdiff1d(np.arange(len(y_pool)), active_set)
    probs = np.sort(active.predict_proba(X_pool[unlabeled]), axis=1)
    margin = probs[:, -1] - probs[:, -2]
    active_set += unlabeled[np.argsort(margin)[:query_batch]].tolist()

    # Random querying buys 100 messages at random.
    unlabeled = np.setdiff1d(np.arange(len(y_pool)), random_set)
    random_set += rng_random.choice(unlabeled, query_batch, replace=False).tolist()

# %% Question 8 - Plot label efficiency
plt.figure(figsize=(6, 3.6))
plt.plot(label_counts, active_scores, marker="o", label="uncertainty sampling")
plt.plot(label_counts, random_scores, marker="o", label="random querying")
plt.xlabel("Number of labeled messages")
plt.ylabel("Validation accuracy")
plt.title("Label efficiency during development")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "label_efficiency_during_development.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 9 - Open the test set once for each policy
# One final model per policy, on all the labels it bought, scored once on the official test messages.
active_final = make_model().fit(X_pool[active_set], y_pool[active_set])
random_final = make_model().fit(X_pool[random_set], y_pool[random_set])
print(f"final test accuracy with {len(active_set)} labels, uncertainty sampling:",
      round(accuracy_score(y_msg_test, active_final.predict(X_msg_test)), 3))
print(f"final test accuracy with {len(random_set)} labels, random querying:    ",
      round(accuracy_score(y_msg_test, random_final.predict(X_msg_test)), 3))

# %% Question 10 - Save the evidence
metrics = pd.DataFrame([
    {"part": "A", "dataset": "creditcard_fraud_ulb", "model": "isolation_forest",
     "prevalence": prevalence, "roc_auc": roc_auc_score(y_test, anomaly_score),
     "average_precision": ap, f"frauds_in_top_{review_budget}": found},
    {"part": "B", "dataset": "banking77", "model": "labels only (1,000)",
     "validation_accuracy": accuracy_score(y_val, labels_only.predict(X_val))},
    {"part": "B", "dataset": "banking77", "model": "self_training (1,000 labels)",
     "validation_accuracy": accuracy_score(y_val, semi.predict(X_val))},
    {"part": "B", "dataset": "banking77", "model": "active (uncertainty)",
     "test_accuracy": accuracy_score(y_msg_test, active_final.predict(X_msg_test))},
    {"part": "B", "dataset": "banking77", "model": "active (random)",
     "test_accuracy": accuracy_score(y_msg_test, random_final.predict(X_msg_test))},
])
metrics.round(4).to_csv(RESULTS / "metrics.csv", index=False)
ranked.head(review_budget).to_csv(RESULTS / "top_ranked_transactions.csv", index=False)
curve = pd.DataFrame({"labels": label_counts, "uncertainty_sampling": active_scores, "random_querying": random_scores})
curve.round(4).to_csv(RESULTS / "active_learning_curve.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 11 - Try it yourself
# Your work here

# %% Question 12 - One solution
# Part 1: what each review budget finds, from the ranked list of Question 3.
for budget in [50, 100, 300, 1000]:
    print(f"top {budget:4d} reviewed: fraud rate = {hits[:budget].mean():.1%}  ({int(hits[:budget].sum())} frauds found)")

# Part 2: what did the active learner ask about? The messages its final model is least sure of.
unlabeled = np.setdiff1d(np.arange(len(y_pool)), active_set)
probs = active_final.predict_proba(X_pool[unlabeled])
top_two = active_final.classes_[np.argsort(probs, axis=1)[:, -2:]]      # its two most likely intents
sorted_probs = np.sort(probs, axis=1)
margin = sorted_probs[:, -1] - sorted_probs[:, -2]
for i in np.argsort(margin)[:4]:
    text = pool["text"].iloc[unlabeled[i]]
    first, second, truth = intents[top_two[i, 1]], intents[top_two[i, 0]], intents[y_pool[unlabeled[i]]]
    print(f"{text[:75]}")
    print(f"    {first} or {second}?  truly {truth}")
