# ----- Semi-supervised self-training -----
# Pretend only 30% of the pool labels are initially available.
y_partial = y_pool.copy()
hide = rng.random(len(y_partial)) < 0.70
y_partial[hide] = -1

semi = Pipeline([
    ("scale", StandardScaler()),
    ("model", SelfTrainingClassifier(
        LogisticRegression(max_iter=2000), threshold=0.90
    )),
])
semi.fit(X_pool, y_partial)
print("self-training validation accuracy:",
      round(accuracy_score(y_val, semi.predict(X_val)), 3))
