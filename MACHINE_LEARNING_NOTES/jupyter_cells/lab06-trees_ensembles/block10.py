for name, estimator in models.items():
    pipe = Pipeline([("preprocess", preprocess), ("model", estimator)])
    neg_mse = cross_val_score(
        pipe, X, y, cv=cv, scoring="neg_mean_squared_error", n_jobs=1
    )
    rmse = np.sqrt(-neg_mse)
    print(name, "CV log-RMSE:", round(rmse.mean(), 4),
          "+/-", round(rmse.std(), 4))
