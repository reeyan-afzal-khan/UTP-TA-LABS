out = df.copy()
out["kmeans_cluster"] = k_labels
out["dbscan_cluster"] = d_labels
print(out.groupby("kmeans_cluster")[features].mean().round(1))
