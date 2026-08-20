plt.figure(figsize=(6, 4))
plt.scatter(
    df["Annual Income (k$)"],
    df["Spending Score (1-100)"],
    c=k_labels,
    alpha=0.75,
)
plt.xlabel("Annual income (k$)")
plt.ylabel("Spending score")
plt.title("K-means labels in two original features")
plt.tight_layout()
plt.show()
