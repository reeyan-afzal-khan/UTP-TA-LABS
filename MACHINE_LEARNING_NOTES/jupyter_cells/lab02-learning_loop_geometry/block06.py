print("Validation MAE:", round(mean_absolute_error(y_valid, pred), 2))
print("Validation RMSE:", round(np.sqrt(mean_squared_error(y_valid, pred)), 2))
