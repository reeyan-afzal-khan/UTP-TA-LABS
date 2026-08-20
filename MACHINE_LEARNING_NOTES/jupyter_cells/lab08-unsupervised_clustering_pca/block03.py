features = ["Age", "Annual Income (k$)", "Spending Score (1-100)"]
X = df[features]
X_scaled = StandardScaler().fit_transform(X)

ks, inertias, silhouettes = [], [], []

for k in range(2, 9):
    model = KMeans(n_clusters=k, n_init=20, random_state=42)
    labels = model.fit_predict(X_scaled)
    sil = silhouette_score(X_scaled, labels)
    ks.append(k)
    inertias.append(model.inertia_)
    silhouettes.append(sil)
    print("k=", k, "inertia=", round(model.inertia_, 2),
          "silhouette=", round(sil, 3))
