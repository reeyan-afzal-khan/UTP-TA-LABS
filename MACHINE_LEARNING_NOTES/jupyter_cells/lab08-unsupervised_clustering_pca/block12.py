plt.figure(figsize=(6, 4))
plt.scatter(
    df["Annual Income (k$)"],
    df["Spending Score (1-100)"],
    c=d_labels,
    alpha=0.75,
)
plt.xlabel("Annual income (k$)")
plt.ylabel("Spending score")
plt.title("DBSCAN labels; noise has label -1")
plt.tight_layout()
plt.show()
