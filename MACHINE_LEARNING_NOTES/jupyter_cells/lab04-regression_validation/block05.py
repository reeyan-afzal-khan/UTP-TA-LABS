# Visual diagnostics for the regularized model.
ridge_pred = predictions["ridge"]
plt.figure(figsize=(6, 4))
plt.scatter(y_valid, ridge_pred, alpha=0.65)
lims = [min(y_valid.min(), ridge_pred.min()), max(y_valid.max(), ridge_pred.max())]
plt.plot(lims, lims, linestyle="--")
plt.xlabel("Actual charges")
plt.ylabel("Predicted charges")
plt.title("Ridge validation: actual versus predicted")
plt.tight_layout()
plt.show()
