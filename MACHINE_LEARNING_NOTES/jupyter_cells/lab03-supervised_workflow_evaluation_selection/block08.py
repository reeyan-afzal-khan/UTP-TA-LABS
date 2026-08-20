X = df.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
y = (df["diagnosis"] == "M").astype(int)

X_train, X_valid, y_train, y_valid = train_test_split(
    X, y, test_size=0.25, random_state=42, stratify=y
)
model = Pipeline([
    ("scale", StandardScaler()),
    ("model", LogisticRegression(max_iter=2000)),
])
model.fit(X_train, y_train)
prob = model.predict_proba(X_valid)[:, 1]
