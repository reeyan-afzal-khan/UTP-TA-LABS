for threshold in [0.30, 0.50, 0.70]:
    pred = (prob >= threshold).astype(int)
    print(
        threshold,
        "precision=", round(precision_score(y_valid, pred, zero_division=0), 3),
        "recall=", round(recall_score(y_valid, pred, zero_division=0), 3),
    )

thresholds = np.linspace(0.10, 0.90, 17)
precisions, recalls = [], []
for threshold in thresholds:
    pred = (prob >= threshold).astype(int)
    precisions.append(precision_score(y_valid, pred, zero_division=0))
    recalls.append(recall_score(y_valid, pred))
