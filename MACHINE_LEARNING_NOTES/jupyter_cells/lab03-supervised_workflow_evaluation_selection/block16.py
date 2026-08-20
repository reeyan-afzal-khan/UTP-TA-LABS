ConfusionMatrixDisplay.from_predictions(y_valid, pred)
plt.title("Heart-disease confusion matrix")
plt.tight_layout()
plt.show()
