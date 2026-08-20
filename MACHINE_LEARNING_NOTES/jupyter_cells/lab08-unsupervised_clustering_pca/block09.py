# DBSCAN can mark observations as noise (-1) instead of forcing every row into a cluster.
dbscan = DBSCAN(eps=0.75, min_samples=6)
d_labels = dbscan.fit_predict(X)
mask = d_labels != -1
n_clusters = len(set(d_labels[mask]))
print("DBSCAN clusters:", n_clusters)
print("DBSCAN noise points:", int((~mask).sum()))
if n_clusters >= 2:
    print("DBSCAN silhouette (non-noise only):",
          round(silhouette_score(X[mask], d_labels[mask]), 3))
