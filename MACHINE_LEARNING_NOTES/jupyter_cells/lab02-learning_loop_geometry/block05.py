model = Pipeline([
    ("preprocess", preprocess),
    ("regressor", LinearRegression()),
])

X_train, X_valid, y_train, y_valid = train_test_split(
    X, y, test_size=0.20, random_state=42
)
model.fit(X_train, y_train)
pred = model.predict(X_valid)
