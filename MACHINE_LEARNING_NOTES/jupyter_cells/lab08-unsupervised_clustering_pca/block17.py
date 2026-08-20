# Course policy: 95% retained variance is locked before the official test is opened.
locked_variance = 0.95
final_baseline = LogisticRegression(max_iter=2000)
final_baseline.fit(X_dev, y_dev)

final_model = Pipeline([
    ("pca", PCA(n_components=locked_variance, svd_solver="full")),
    ("model", LogisticRegression(max_iter=2000)),
])
final_model.fit(X_dev, y_dev)

baseline_test_pred = final_baseline.predict(X_test)
pca_test_pred = final_model.predict(X_test)
pca = final_model.named_steps["pca"]

print("\nFINAL LOCKED TEST")
print("full 64-feature accuracy:", round(accuracy_score(y_test, baseline_test_pred), 4))
print("PCA components kept:", pca.n_components_)
print("PCA variance retained:", round(pca.explained_variance_ratio_.sum(), 4))
print("PCA-to-logistic accuracy:", round(accuracy_score(y_test, pca_test_pred), 4))
