# Only after selection is complete do we evaluate once on the untouched test set.
test_prob = search.predict_proba(X_test)[:, 1]
print("best parameters:", search.best_params_)
print("training-CV ROC AUC:", round(search.best_score_, 3))
print("final test ROC AUC:", round(roc_auc_score(y_test, test_prob), 3))
