from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import GradientBoostingRegressor, RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.model_selection import KFold, cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

data_path = Path("all_datasets/ames_housing_dataset") / "AmesHousing.csv"
df = pd.read_csv(data_path)

# Order and PID are identifiers, not useful house characteristics for this lesson.
X = df.drop(columns=["SalePrice", "Order", "PID"], errors="ignore")
y = np.log1p(df["SalePrice"])

num_cols = X.select_dtypes(include="number").columns
cat_cols = X.select_dtypes(exclude="number").columns
preprocess = ColumnTransformer([
    ("num", SimpleImputer(strategy="median"), num_cols),
    ("cat", Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("onehot", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
    ]), cat_cols),
])

models = {
    "random_forest": RandomForestRegressor(
        n_estimators=300, max_features=0.8, min_samples_leaf=1,
        random_state=42, n_jobs=-1
    ),
    "gradient_boosting": GradientBoostingRegressor(
        n_estimators=350, learning_rate=0.04, max_depth=3,
        loss="huber", random_state=42
    ),
}
cv = KFold(n_splits=5, shuffle=True, random_state=42)

for name, estimator in models.items():
    pipe = Pipeline([("preprocess", preprocess), ("model", estimator)])
    neg_mse = cross_val_score(
        pipe, X, y, cv=cv, scoring="neg_mean_squared_error", n_jobs=-1
    )
    rmse = np.sqrt(-neg_mse)
    print(name, "CV log-RMSE:", round(rmse.mean(), 4),
          "+/-", round(rmse.std(), 4))
