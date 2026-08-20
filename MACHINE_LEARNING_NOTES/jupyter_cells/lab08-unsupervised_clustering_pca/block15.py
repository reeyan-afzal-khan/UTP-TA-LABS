# The dataset ships with an official training file and an official test file.
# Keep the official test file untouched while exploring the compression choice.
X_dev = train.drop(columns="label") / 16.0
y_dev = train["label"]
X_test = test.drop(columns="label") / 16.0
y_test = test["label"]

X_fit, X_valid, y_fit, y_valid = train_test_split(
    X_dev, y_dev, test_size=0.25, random_state=42, stratify=y_dev
)

# Development baseline: all 64 features, evaluated on validation data.
baseline = LogisticRegression(max_iter=2000)
baseline.fit(X_fit, y_fit)
baseline_valid = baseline.predict(X_valid)
print(
    "64-feature validation accuracy:",
    round(accuracy_score(y_valid, baseline_valid), 4),
)
