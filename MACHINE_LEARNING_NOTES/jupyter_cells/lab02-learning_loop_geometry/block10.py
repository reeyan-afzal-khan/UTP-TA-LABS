# Compare raw Euclidean distance with distance after standardization.
raw = pairwise_distances(X.iloc[:5], metric="euclidean")
X_scaled = StandardScaler().fit_transform(X)
scaled = pairwise_distances(X_scaled[:5], metric="euclidean")
