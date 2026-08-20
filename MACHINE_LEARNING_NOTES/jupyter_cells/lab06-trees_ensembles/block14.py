results = {}
for name, model in models.items():
    model.fit(X_train, y_train)
    pred = model.predict(X_valid)
    results[name] = pred
    print(name)
    print(" MAE:", round(mean_absolute_error(y_valid, pred), 3))
    print(" RMSE:", round(np.sqrt(mean_squared_error(y_valid, pred)), 3))
