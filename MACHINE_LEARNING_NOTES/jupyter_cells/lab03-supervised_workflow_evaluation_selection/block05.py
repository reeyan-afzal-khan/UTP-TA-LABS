for name, estimator in models.items():
    pipe = Pipeline([("preprocess", preprocess), ("model", estimator)])
    pipe.fit(X_train, y_train)
    pred = pipe.predict(X_valid)
    prob = pipe.predict_proba(X_valid)[:, 1]
    print(name, "accuracy=", round(accuracy_score(y_valid, pred), 3),
          "roc_auc=", round(roc_auc_score(y_valid, prob), 3))
