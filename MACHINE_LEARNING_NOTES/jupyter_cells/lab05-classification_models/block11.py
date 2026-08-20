# Validation compares the locked KNN choice with the alternative model family.
for name, model in models.items():
    model.fit(X_train, y_train)
    pred = model.predict(X_valid)
    prob = model.predict_proba(X_valid)[:, 1]
    print(
        name,
        "validation accuracy=", round(accuracy_score(y_valid, pred), 3),
        "validation ROC AUC=", round(roc_auc_score(y_valid, prob), 3),
    )
