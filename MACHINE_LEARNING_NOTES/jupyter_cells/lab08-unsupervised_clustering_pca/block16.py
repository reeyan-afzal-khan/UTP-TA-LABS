# Compare compression budgets only on development validation data.
for retained_variance in [0.90, 0.95, 0.99]:
    candidate = Pipeline([
        ("pca", PCA(n_components=retained_variance, svd_solver="full")),
        ("model", LogisticRegression(max_iter=2000)),
    ])
    candidate.fit(X_fit, y_fit)
    valid_pred = candidate.predict(X_valid)
    pca = candidate.named_steps["pca"]
    print(
        f"{retained_variance:.0%} variance:",
        "components=", pca.n_components_,
        "validation accuracy=", round(accuracy_score(y_valid, valid_pred), 4),
    )
