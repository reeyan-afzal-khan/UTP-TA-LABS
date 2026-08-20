# Chronological development holdout: earlier dates train, later dates validate.
cut = int(len(df) * 0.80)
X_train, X_valid = X.iloc[:cut], X.iloc[cut:]
y_train, y_valid = y.iloc[:cut], y.iloc[cut:]
dates_valid = df["dteday"].iloc[cut:]

cat_cols = ["season", "yr", "mnth", "holiday", "weekday", "workingday", "weathersit"]
num_cols = ["temp", "atemp", "hum", "windspeed"]
preprocess = ColumnTransformer([
    ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
    ("num", "passthrough", num_cols),
])
model = Pipeline([
    ("preprocess", preprocess),
    ("model", RandomForestRegressor(
        n_estimators=400, min_samples_leaf=2, random_state=42, n_jobs=-1
    )),
])
model.fit(X_train, y_train)
pred = model.predict(X_valid)

print("MAE:", round(mean_absolute_error(y_valid, pred), 1))
print("RMSE:", round(np.sqrt(mean_squared_error(y_valid, pred)), 1))
