residual = y_valid.to_numpy() - ridge_pred
plt.figure(figsize=(6, 4))
plt.scatter(ridge_pred, residual, alpha=0.65)
plt.axhline(0, linestyle="--")
plt.xlabel("Predicted charges")
plt.ylabel("Residual")
plt.title("Ridge validation residual plot")
plt.tight_layout()
plt.show()
