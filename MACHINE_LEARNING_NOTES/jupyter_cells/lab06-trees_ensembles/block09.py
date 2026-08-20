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
        n_estimators=150, max_features=0.8, min_samples_leaf=2,
        random_state=42, n_jobs=-1
    ),
    "gradient_boosting": GradientBoostingRegressor(
        n_estimators=150, learning_rate=0.05, max_depth=3,
        loss="huber", random_state=42
    ),
}
cv = KFold(n_splits=3, shuffle=True, random_state=42)
