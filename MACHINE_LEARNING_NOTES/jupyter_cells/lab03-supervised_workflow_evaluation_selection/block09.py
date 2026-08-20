# Explore threshold policies on development validation data, not a final test set.
for threshold in [0.50, 0.30]:
    pred = (prob >= threshold).astype(int)
    print(f"\nthreshold={threshold:.2f}")
    print(confusion_matrix(y_valid, pred))
    print(classification_report(y_valid, pred, digits=3))
    ConfusionMatrixDisplay.from_predictions(y_valid, pred)
    plt.title(f"Confusion matrix at threshold {threshold:.2f}")
    plt.tight_layout()
    plt.show()

print("ROC AUC:", round(roc_auc_score(y_valid, prob), 3))
print("PR AUC:", round(average_precision_score(y_valid, prob), 3))
