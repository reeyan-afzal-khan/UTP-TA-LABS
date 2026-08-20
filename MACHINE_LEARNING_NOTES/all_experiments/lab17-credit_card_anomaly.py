from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.ensemble import IsolationForest
from sklearn.metrics import average_precision_score, roc_auc_score
from sklearn.model_selection import train_test_split

df = pd.read_csv(Path("all_datasets/credit_card_fraud_dataset") / "credit_card_fraud_10k.csv")

# Use only behavior/risk features. The transaction ID is an identifier, not a signal.
feature_cols = [
    "amount",
    "transaction_hour",
    "foreign_transaction",
    "location_mismatch",
    "device_trust_score",
    "velocity_last_24h",
    "cardholder_age",
]
X = df[feature_cols]
y = df["is_fraud"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.30, random_state=42, stratify=y
)

# The fraud labels are deliberately NOT passed to fit.
model = IsolationForest(
    n_estimators=300, contamination="auto", random_state=42, n_jobs=-1
)
model.fit(X_train)
anomaly_score = -model.decision_function(X_test)

prevalence = y_test.mean()
ap = average_precision_score(y_test, anomaly_score)
print("fraud prevalence:", round(prevalence, 4))
print("ROC AUC:", round(roc_auc_score(y_test, anomaly_score), 4))
print("average precision:", round(ap, 4))
print("AP / prevalence:", round(ap / prevalence, 2))

ranked = X_test.copy()
ranked["fraud_label"] = y_test.to_numpy()
ranked["anomaly_score"] = anomaly_score
ranked = ranked.sort_values("anomaly_score", ascending=False)
review_budget = min(100, len(ranked))
top_k_precision = ranked.head(review_budget)["fraud_label"].mean()
print(f"precision among top {review_budget}:", round(top_k_precision, 4))
print(ranked[["fraud_label", "anomaly_score", "amount"]].head(20))

plt.figure(figsize=(6, 4))
plt.hist(anomaly_score[y_test.to_numpy() == 0], bins=30, alpha=0.65, label="non-fraud")
plt.hist(anomaly_score[y_test.to_numpy() == 1], bins=30, alpha=0.65, label="fraud")
plt.xlabel("Anomaly score")
plt.ylabel("Transactions")
plt.title("Isolation Forest score distribution")
plt.legend()
plt.tight_layout()
plt.show()
