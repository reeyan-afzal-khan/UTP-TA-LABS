from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler

PROJECT_ROOT = Path.cwd().parent
train_path = PROJECT_ROOT / "all_datasets" / "mall_customers_dataset" / "Mall_Customers.csv"
df = pd.read_csv(train_path)

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

plt.figure(figsize=(6, 4))
plt.plot(ks, inertias, marker="o")
plt.xlabel("Number of clusters k")
plt.ylabel("Inertia")
plt.title("K-means elbow diagnostic")
plt.tight_layout()
plt.show()

plt.figure(figsize=(6, 4))
plt.plot(ks, silhouettes, marker="o")
plt.xlabel("Number of clusters k")
plt.ylabel("Silhouette score")
plt.title("K-means silhouette diagnostic")
plt.tight_layout()
plt.show()
