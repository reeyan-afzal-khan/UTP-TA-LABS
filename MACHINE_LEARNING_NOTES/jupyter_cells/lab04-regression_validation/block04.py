for name, estimator in {
    "ordinary least squares": LinearRegression(),
    "ridge": Ridge(alpha=10.0),
}.items():
    model = Pipeline([("preprocess", preprocess), ("model", estimator)])
    model.fit(X_train, y_train)
    pred = model.predict(X_valid)
    predictions[name] = pred
    print("\n", name)
    print("MAE:", round(mean_absolute_error(y_valid, pred), 2))
    print("RMSE:", round(np.sqrt(mean_squared_error(y_valid, pred)), 2))
    print("R2:", round(r2_score(y_valid, pred), 3))
