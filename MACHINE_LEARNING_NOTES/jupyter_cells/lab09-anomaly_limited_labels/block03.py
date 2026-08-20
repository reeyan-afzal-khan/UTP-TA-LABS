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
