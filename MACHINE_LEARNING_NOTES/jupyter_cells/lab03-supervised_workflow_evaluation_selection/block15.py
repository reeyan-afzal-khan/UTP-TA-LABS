X_train, X_valid, y_train, y_valid = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)
model = Pipeline([
    ("preprocess", preprocess),
    ("model", LogisticRegression(max_iter=2000)),
])
model.fit(X_train, y_train)
prob = model.predict_proba(X_valid)[:, 1]
pred = (prob >= 0.50).astype(int)

print(classification_report(y_valid, pred, digits=3))
print("ROC AUC:", round(roc_auc_score(y_valid, prob), 3))
print("PR AUC:", round(average_precision_score(y_valid, prob), 3))
