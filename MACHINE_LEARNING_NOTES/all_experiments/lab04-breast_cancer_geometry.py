from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.metrics import pairwise_distances
from sklearn.preprocessing import StandardScaler

PROJECT_ROOT = Path.cwd().parent
train_path = PROJECT_ROOT / "all_datasets\\breast_cancer_dataset\\data.csv"
df = pd.read_csv(train_path)

feature_cols = [c for c in df.columns if c not in {"id", "diagnosis", "Unnamed: 32"}]
X = df[feature_cols]

# Compare raw Euclidean distance with distance after standardization.
raw = pairwise_distances(X.iloc[:5], metric="euclidean")
X_scaled = StandardScaler().fit_transform(X)
scaled = pairwise_distances(X_scaled[:5], metric="euclidean")

np.set_printoptions(precision=2, suppress=True)
print("Raw distances among first five rows:\n", raw)
print("\nScaled distances among first five rows:\n", scaled)

# Cosine similarity answers a different question: direction rather than magnitude.
cosine_distance = pairwise_distances(X_scaled[:5], metric="cosine")
print("\nCosine similarities:\n", 1 - cosine_distance)
