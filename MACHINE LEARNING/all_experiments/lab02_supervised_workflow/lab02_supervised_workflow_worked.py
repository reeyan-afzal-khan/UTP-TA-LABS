"""Lab 02: Supervised learning I: regression, classification, and the workflow.

The code cells of lab02_supervised_workflow_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab02_supervised_workflow/lab02_supervised_workflow_worked.py
It writes the same figures and tables as the notebook, to results/lab02/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses.
import json
import joblib                                                      # save and load fitted models
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sklearn
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LinearRegression, LogisticRegression, Ridge
from sklearn.model_selection import GridSearchCV, StratifiedKFold, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
# metrics for numbers (regression) ...
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
# ... and for classes (classification), with their plots
from sklearn.metrics import (accuracy_score, average_precision_score, classification_report, confusion_matrix,
                             precision_score, recall_score, roc_auc_score)
from sklearn.metrics import ConfusionMatrixDisplay, PrecisionRecallDisplay, RocCurveDisplay

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab02")

# 4. One helper used in every part, the same as in Lab 1.
def make_preprocess(num_cols, cat_cols):
    """Prepare a table for a model: fill and scale the number columns, fill and one-hot encode the text columns."""
    numbers = Pipeline([
        ("impute", SimpleImputer(strategy="median")),
        ("scale", StandardScaler()),
    ])
    categories = Pipeline([
        ("impute", SimpleImputer(strategy="most_frequent")),
        ("onehot", OneHotEncoder(handle_unknown="ignore")),
    ])
    return ColumnTransformer([("num", numbers, num_cols), ("cat", categories, cat_cols)])

cars = pd.read_csv(DATA / "supervised/used_cars/used_cars.zip", low_memory=False)
print("shape:", cars.shape)
print(cars["stock_type"].value_counts().to_string())

# Fixed cleaning rules, decided before any model: used cars, a believable price, a real odometer reading.
used = cars[(cars["stock_type"] == "Used")
            & cars["price_usd"].between(1_000, 200_000)
            & (cars["mileage_miles"] > 100)].copy()
print(f"used listings kept: {len(used):,} of {(cars['stock_type'] == 'Used').sum():,}")

# Sellers type the same thing many ways ("AWD", "All-wheel Drive", "All Wheel Drive" ...): map them to a few groups.
def tidy(column, groups):
    """Each group is matched by a pattern in the lower-case text; the first match wins, no match becomes a gap."""
    text = column.str.lower()
    matches = [text.str.contains(pattern, na=False) for pattern in groups.values()]
    return pd.Series(np.select(matches, list(groups), default=None), index=column.index)

print("spellings before tidying: drivetrain", used["drivetrain"].nunique(), " fuel", used["fuel"].nunique())
used["drive"] = tidy(used["drivetrain"], {"AWD": "all|awd", "4WD": "four|4wd|4x4", "FWD": "front|fwd", "RWD": "rear|rwd"})
used["fuel_type"] = tidy(used["fuel"], {"plug-in hybrid": "plug", "hybrid": "hybrid|mild", "electric": "electric",
                                        "diesel": "diesel", "flex fuel": "flex|e85", "gasoline": "gas|petrol|unleaded"})
print(used["drive"].value_counts(dropna=False).to_dict())
print(used["fuel_type"].value_counts(dropna=False).to_dict())

# Age in years when the listings were collected, October 2026; next year's models count as new.
used["age"] = (2026 - used["year"]).clip(lower=0)

num_cols = ["age", "mileage_miles"]
cat_cols = ["make", "body_type", "drive", "fuel_type"]
X = used[num_cols + cat_cols + ["model"]]            # model is kept aside for a Your-turn task
y = used["price_usd"]

# A random 80/20 split: the listings were all collected on one day, so there is no time order to respect.
X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.20, random_state=42)
print(len(X_train), "listings to train on and", len(X_valid), "to validate")

# The baseline any model must beat: predict the average training price for every car.
baseline = np.full(len(y_valid), y_train.mean())
print("always the training mean: MAE", round(mean_absolute_error(y_valid, baseline)))

# Two models, the same preparation: plain least squares, and ridge, which penalizes large coefficients.
estimators = {
    "linear regression": LinearRegression(),
    "ridge": Ridge(alpha=10.0),
}
fitted, predictions = {}, {}
for name, estimator in estimators.items():
    model = Pipeline([("preprocess", make_preprocess(num_cols, cat_cols)), ("model", estimator)])
    model.fit(X_train, y_train)
    fitted[name] = model
    predictions[name] = pred = model.predict(X_valid)
    print(f"\n{name}")
    print("MAE:", round(mean_absolute_error(y_valid, pred)))
    print("RMSE:", round(np.sqrt(mean_squared_error(y_valid, pred))))
    print("R2:", round(r2_score(y_valid, pred), 3))

# One coefficient per prepared column: the change in predicted price for a one-unit change in that column
# (one standard deviation, for the scaled number columns).
linear = fitted["linear regression"]
column_names = linear.named_steps["preprocess"].get_feature_names_out()
coefs = pd.Series(linear.named_steps["model"].coef_, index=column_names)
print("one standard deviation:", {c: round(X_train[c].std(), 1) for c in num_cols})
print(coefs[["num__age", "num__mileage_miles"]].round(0).to_string())

# One coefficient per make. How many training listings stand behind each one?
makes = coefs[coefs.index.str.startswith("cat__make_")].rename(lambda c: c.removeprefix("cat__make_"))
by_make = pd.DataFrame({"coefficient": makes.round(-2), "listings": X_train["make"].value_counts()}).sort_values("coefficient")
print("the four largest:\n", by_make.tail(4).to_string())
common = by_make[by_make["listings"] >= 500]             # makes with enough listings to trust
print(len(common), "makes have 500 listings or more, for example:",
      common.loc[["Porsche", "Toyota", "Ford", "Mitsubishi"], "coefficient"].to_dict())

plt.figure(figsize=(6, 5))
plt.barh(common.index, common["coefficient"] / 1000)
plt.axvline(0, color="grey", linewidth=0.8)
plt.xlabel("Change in predicted price ($ thousand)")
plt.title("What the linear model learned about makes")
plt.tight_layout()
plt.savefig(RESULTS / "what_the_linear_model_learned.png", dpi=160, bbox_inches="tight")
plt.show()

ridge_pred = predictions["ridge"]
residual = y_valid.to_numpy() - ridge_pred           # positive: the car is listed for more than predicted

# Split the predictions into four equal-sized groups, cheapest to dearest, and compare the misses.
quarter = pd.qcut(ridge_pred, 4, labels=["cheapest", "second", "third", "dearest"])
print("spread of the residuals (standard deviation) by quarter of predicted price:")
print(pd.Series(residual).groupby(quarter, observed=True).std().round(0).to_string())
print("predicted prices below zero:", int((ridge_pred < 0).sum()))

fig, axes = plt.subplots(1, 2, figsize=(9.5, 3.8))
axes[0].scatter(y_valid / 1e3, ridge_pred / 1e3, s=4, alpha=0.3)
axes[0].plot([0, 200], [0, 200], linestyle="--", color="grey")
axes[0].set_xlim(0, 200)
axes[0].set_ylim(-40, 200)
axes[0].set_xlabel("Asking price ($ thousand)")
axes[0].set_ylabel("Predicted price ($ thousand)")
axes[0].set_title("Ridge: actual versus predicted")
axes[1].scatter(ridge_pred / 1e3, residual / 1e3, s=4, alpha=0.3)
axes[1].axhline(0, linestyle="--", color="grey")
axes[1].set_xlabel("Predicted price ($ thousand)")
axes[1].set_ylabel("Residual ($ thousand)")
axes[1].set_title("Ridge: the residuals fan out")
plt.tight_layout()
plt.savefig(RESULTS / "ridge_residual_plot.png", dpi=160, bbox_inches="tight")
plt.show()

hotels = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
text_date = (hotels["arrival_date_year"].astype(str) + "-" + hotels["arrival_date_month"]
             + "-" + hotels["arrival_date_day_of_month"].astype(str))
hotels["arrival_date"] = pd.to_datetime(text_date, format="%Y-%B-%d")
hotels = hotels.sort_values("arrival_date", kind="stable").reset_index(drop=True)

# Lab 1's five engineered columns, and its feature lists.
children = hotels["children"].fillna(0).astype(int)
hotels["total_nights"] = hotels["stays_in_weekend_nights"] + hotels["stays_in_week_nights"]
hotels["total_guests"] = hotels["adults"] + children + hotels["babies"]
hotels["with_children"] = ((children + hotels["babies"]) > 0).astype(int)
hotels["log_lead_time"] = np.log1p(hotels["lead_time"])
hotels["cancelled_before"] = (hotels["previous_cancellations"] > 0).astype(int)
h_num = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
         "previous_cancellations", "previous_bookings_not_canceled", "adr", "required_car_parking_spaces",
         "total_of_special_requests", "total_nights", "total_guests", "with_children", "log_lead_time",
         "cancelled_before"]
h_cat = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]
X_h = hotels[h_num + h_cat]
y_h = hotels["is_canceled"]

# Split in date order: arrivals up to the end of 2016 train, arrivals in 2017 validate.
in_train = (hotels["arrival_date"] < "2017-01-01").to_numpy()
Xh_train, Xh_valid = X_h[in_train], X_h[~in_train]
yh_train, yh_valid = y_h[in_train], y_h[~in_train]
for label, part in [("train", hotels[in_train]), ("valid", hotels[~in_train])]:
    print(f"{label}: {part['arrival_date'].min().date()} to {part['arrival_date'].max().date()}, "
          f"{len(part):,} bookings, {part['is_canceled'].mean():.1%} cancelled")

def cancellation_model():
    """Lab 1's model: the preparation and a logistic regression, in one pipeline."""
    return Pipeline([("preprocess", make_preprocess(h_num, h_cat)), ("model", LogisticRegression(max_iter=3000))])

# The same model scored two ways: on a shuffled split, as in Lab 1, and on the date split.
Xr_train, Xr_valid, yr_train, yr_valid = train_test_split(X_h, y_h, test_size=0.25, random_state=42, stratify=y_h)
shuffled = cancellation_model().fit(Xr_train, yr_train)
print("shuffled split, ROC AUC:    ", round(roc_auc_score(yr_valid, shuffled.predict_proba(Xr_valid)[:, 1]), 3))

dated = cancellation_model().fit(Xh_train, yh_train)
prob_h = dated.predict_proba(Xh_valid)[:, 1]          # each 2017 booking's predicted chance of cancelling
print("date split (2017), ROC AUC: ", round(roc_auc_score(yh_valid, prob_h), 3))

# Month by month: the share of bookings that cancelled, and the share the model expected.
month = hotels["arrival_date"].dt.to_period("M")
monthly = pd.DataFrame({
    "actual": y_h.groupby(month).mean(),
    "predicted": pd.Series(dated.predict_proba(X_h)[:, 1]).groupby(month).mean(),
})
print(monthly.loc["2016-12":].round(3).T.to_string())

ax = monthly.plot(figsize=(8, 3.4), marker="o", markersize=3)
ax.axvline(pd.Period("2017-01", "M"), color="grey", linestyle="--")
ax.text(pd.Period("2017-01", "M"), 0.22, "  validation", color="grey")
ax.set_xlabel("Month of arrival")
ax.set_ylabel("Share cancelled")
ax.set_title("Trained on the past, scored on 2017")
plt.tight_layout()
plt.savefig(RESULTS / "trained_on_the_past_scored_on_2017.png", dpi=160, bbox_inches="tight")
plt.show()

print("majority-class baseline accuracy:", round(1 - yh_valid.mean(), 3))

# Two classifiers with the same preparation, trained on 2015-2016 and scored on 2017, two ways.
classifiers = {
    "logistic": LogisticRegression(max_iter=3000),
    "random_forest": RandomForestClassifier(n_estimators=300, min_samples_leaf=5, random_state=42, n_jobs=-1),
}
scores, fitted_h = {}, {}
for name, estimator in classifiers.items():
    pipe = Pipeline([("preprocess", make_preprocess(h_num, h_cat)), ("model", estimator)])
    pipe.fit(Xh_train, yh_train)
    fitted_h[name] = pipe
    accuracy = accuracy_score(yh_valid, pipe.predict(Xh_valid))                   # decisions at 0.5
    auc = roc_auc_score(yh_valid, pipe.predict_proba(Xh_valid)[:, 1])             # the ranking
    scores[name] = {"accuracy": accuracy, "roc_auc": auc}
    print(f"{name:14s} accuracy={accuracy:.3f} roc_auc={auc:.3f}")

# The logistic model, three decision rules: "will cancel" when the probability reaches the threshold.
for threshold in [0.30, 0.50, 0.70]:
    flagged = (prob_h >= threshold).astype(int)
    print(f"threshold {threshold:.2f}: precision={precision_score(yh_valid, flagged):.2f} "
          f"recall={recall_score(yh_valid, flagged):.2f}")

pd.DataFrame(scores).T.plot.bar(figsize=(5, 3.2), ylim=(0.5, 1.0), rot=0)
plt.axhline(1 - yh_valid.mean(), linestyle="--", color="grey", label="majority baseline")
plt.title("Two models, two metrics, one date split")
plt.legend(loc="lower right")
plt.tight_layout()
plt.savefig(RESULTS / "two_models_two_metrics_one_date_split.png", dpi=160, bbox_inches="tight")
plt.show()

# The logistic model's probabilities for the 2017 bookings, drawn separately for kept and cancelled ones.
uncertain = (prob_h > 0.3) & (prob_h < 0.7)
print("share of 2017 bookings scored between 0.3 and 0.7:", round(uncertain.mean(), 3))

plt.figure(figsize=(6, 3.4))
plt.hist(prob_h[yh_valid == 0], bins=40, alpha=0.6, label="kept (actual)")
plt.hist(prob_h[yh_valid == 1], bins=40, alpha=0.6, label="cancelled (actual)")
plt.axvline(0.50, color="black", linestyle="--", label="threshold 0.50")
plt.axvline(0.70, color="red", linestyle=":", label="threshold 0.70")
plt.xlabel("Predicted probability of cancelling")
plt.ylabel("Bookings")
plt.title("A threshold is a vertical line through this picture")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "a_threshold_is_a_vertical_line_through_this_picture.png", dpi=160, bbox_inches="tight")
plt.show()

for threshold in [0.50, 0.70]:
    flagged = (prob_h >= threshold).astype(int)                   # 1 = treat the booking as a likely cancellation
    print(f"\nthreshold = {threshold:.2f}")
    print(confusion_matrix(yh_valid, flagged))                    # rows: the truth; columns: the decision
    print(classification_report(yh_valid, flagged, digits=3))
    ConfusionMatrixDisplay.from_predictions(yh_valid, flagged, display_labels=["kept", "cancelled"])
    plt.title(f"Confusion matrix at threshold {threshold:.2f}")
    plt.tight_layout()
    plt.savefig(RESULTS / f"confusion_matrix_at_threshold_{threshold:.2f}.png", dpi=160, bbox_inches="tight")
    plt.show()

# Precision and recall at 19 thresholds from 0.05 to 0.95.
thresholds = np.linspace(0.05, 0.95, 19)
precisions, recalls = [], []
for t in thresholds:
    flagged = (prob_h >= t).astype(int)
    precisions.append(precision_score(yh_valid, flagged, zero_division=0))
    recalls.append(recall_score(yh_valid, flagged))

plt.figure(figsize=(6, 3.4))
plt.plot(thresholds, precisions, marker="o", label="precision")
plt.plot(thresholds, recalls, marker="o", label="recall")
plt.xlabel("Decision threshold")
plt.ylabel("Score")
plt.title("The threshold trades recall for precision")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "the_threshold_trades_recall_for_precision.png", dpi=160, bbox_inches="tight")
plt.show()

# Two summaries of the ranking that need no threshold at all.
print("ROC AUC:", round(roc_auc_score(yh_valid, prob_h), 3))
print("PR AUC (average precision):", round(average_precision_score(yh_valid, prob_h), 3),
      " against", round(yh_valid.mean(), 3), "for guessing")

fig, axes = plt.subplots(1, 2, figsize=(9, 3.6))
RocCurveDisplay.from_predictions(yh_valid, prob_h, ax=axes[0])
axes[0].set_title("ROC curve")
PrecisionRecallDisplay.from_predictions(yh_valid, prob_h, ax=axes[1])
axes[1].set_title("Precision-recall curve")
plt.tight_layout()
plt.savefig(RESULTS / "precision_recall_curve.png", dpi=160, bbox_inches="tight")
plt.show()

churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
churn["TotalCharges"] = pd.to_numeric(churn["TotalCharges"], errors="coerce").fillna(0)   # the Lab 1 repair
X_c = churn.drop(columns=["customerID", "Churn"])
y_c = (churn["Churn"] == "Yes").astype(int)
c_num = X_c.select_dtypes(include="number").columns.tolist()
c_cat = X_c.select_dtypes(exclude="number").columns.tolist()
print(len(c_num), "numeric and", len(c_cat), "text columns;", f"{y_c.mean():.1%} of customers left")

# The test rows are set aside first, and stay closed until Question 14.
Xc_train, Xc_test, yc_train, yc_test = train_test_split(X_c, y_c, test_size=0.25, random_state=42, stratify=y_c)

# Try every combination of C and class_weight with five-fold cross-validation on the training rows only.
search = GridSearchCV(
    Pipeline([("preprocess", make_preprocess(c_num, c_cat)),
              ("model", LogisticRegression(max_iter=3000))]),
    param_grid={
        "model__C": [0.01, 0.1, 1.0, 10.0, 100.0],         # smaller C = stronger regularization
        "model__class_weight": [None, "balanced"],
    },
    scoring="roc_auc",
    cv=StratifiedKFold(n_splits=5, shuffle=True, random_state=42),
    n_jobs=-1,
)
search.fit(Xc_train, yc_train)

cv_table = pd.DataFrame(search.cv_results_)                  # one row per combination
print("cross-validated ROC AUC ranges from", round(cv_table["mean_test_score"].min(), 3),
      "to", round(cv_table["mean_test_score"].max(), 3),
      "; typical fold-to-fold spread", round(cv_table["std_test_score"].mean(), 3))

plt.figure(figsize=(5.5, 3.4))
for weight, group in cv_table.groupby(cv_table["param_model__class_weight"].astype(str)):
    plt.errorbar(group["param_model__C"].astype(float), group["mean_test_score"],
                 yerr=group["std_test_score"], marker="o", capsize=3, label=f"class_weight={weight}")
plt.xscale("log")
plt.xlabel("C (weaker regularization to the right)")
plt.ylabel("Cross-validated ROC AUC")
plt.title("What the grid search saw")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "what_the_grid_search_saw.png", dpi=160, bbox_inches="tight")
plt.show()

# search now holds the best setting, refitted on all the training rows. The test set is used once.
test_prob = search.predict_proba(Xc_test)[:, 1]
test_auc = roc_auc_score(yc_test, test_prob)

print("best parameters:", search.best_params_)
print("cross-validated ROC AUC:", round(search.best_score_, 3))
print("final test ROC AUC:", round(test_auc, 3), "on", len(yc_test), "customers")

# The fitted pipeline (preparation and model together) goes to one file ...
final_model = search.best_estimator_
model_path = MODELS / "customer_churn.joblib"
joblib.dump(final_model, model_path)

# ... and a model card records what it expects and how well it tested. The typical customer (the median of each
# number column, the most common value of each text column) lets a script fill in any column it is not given.
typical = {c: float(Xc_train[c].median()) if c in c_num else str(Xc_train[c].mode()[0]) for c in X_c.columns}
card = {
    "task": "predict whether a telecom customer leaves (1 = churned) from the IBM Telco table",
    "features": X_c.columns.tolist(),
    "typical_customer": typical,
    "model": "logistic regression pipeline",
    "best_parameters": search.best_params_,
    "training_rows": int(len(Xc_train)),
    "final_test_roc_auc": round(float(test_auc), 3),
    "decision_threshold": 0.5,
    "scikit_learn_version": sklearn.__version__,
}
(MODELS / "customer_churn_card.json").write_text(json.dumps(card, indent=2))
size_kb = model_path.stat().st_size / 1024
print(f"saved: {model_path.name} ({size_kb:.1f} KB) and customer_churn_card.json")

# Load the saved model and ask it about two customers. A real customer's row is the template,
# so every column the model expects is there; only the columns that differ are changed.
loaded = joblib.load(model_path)
template = X_c.iloc[0].to_dict()
new_customers = pd.DataFrame([
    {**template, "tenure": 2, "Contract": "Month-to-month", "InternetService": "Fiber optic",
     "PaymentMethod": "Electronic check", "MonthlyCharges": 85.0, "TotalCharges": 170.0},
    {**template, "tenure": 60, "Contract": "Two year", "InternetService": "DSL",
     "PaymentMethod": "Bank transfer (automatic)", "MonthlyCharges": 60.0, "TotalCharges": 3600.0},
])
new_customers["churn_probability"] = loaded.predict_proba(new_customers)[:, 1].round(3)
print(new_customers[["tenure", "Contract", "InternetService", "PaymentMethod", "churn_probability"]].to_string())

# The same for the car-price model: one car, listed at two mileages.
joblib.dump(fitted["linear regression"], MODELS / "used_car_prices.joblib")
pricing = joblib.load(MODELS / "used_car_prices.joblib")
car = {"age": 5, "make": "Toyota", "body_type": "SUV", "drive": "AWD", "fuel_type": "gasoline"}
new_cars = pd.DataFrame([{**car, "mileage_miles": 30_000}, {**car, "mileage_miles": 90_000}])
new_cars["predicted_price"] = pricing.predict(new_cars).round(-2)
print(new_cars[["make", "body_type", "age", "mileage_miles", "predicted_price"]].to_string())

# One row per model and dataset, collected from the parts above.
rows = []
for name, pred in predictions.items():
    rows.append({"part": "A", "dataset": "used_cars", "model": name, "metric": "mae",
                 "validation": mean_absolute_error(y_valid, pred)})
rows.append({"part": "B", "dataset": "hotel_bookings", "model": "logistic (shuffled split)", "metric": "roc_auc",
             "validation": roc_auc_score(yr_valid, shuffled.predict_proba(Xr_valid)[:, 1])})
for name, s in scores.items():
    rows.append({"part": "C", "dataset": "hotel_bookings", "model": f"{name} (date split)", "metric": "roc_auc",
                 "validation": s["roc_auc"]})
rows.append({"part": "D", "dataset": "telco_customer_churn", "model": f"logistic {search.best_params_}",
             "metric": "roc_auc", "validation": search.best_score_, "test": test_auc})
pd.DataFrame(rows).round(4).to_csv(RESULTS / "metrics.csv", index=False)
monthly.round(4).to_csv(RESULTS / "monthly_cancellations.csv")

print("Saved:", sorted(p.name for p in RESULTS.iterdir()))
model_files = [p.name for p in MODELS.iterdir() if p.name.startswith(("customer_churn", "used_car_prices"))]
print("Model files:", sorted(model_files))

# Your work here

# Part A's linear regression, trained on the logarithm of the price; exp turns its predictions back into dollars.
log_model = Pipeline([("preprocess", make_preprocess(num_cols, cat_cols)), ("model", LinearRegression())])
log_model.fit(X_train, np.log(y_train))
log_pred = np.exp(log_model.predict(X_valid))

print("log-price model: MAE", round(mean_absolute_error(y_valid, log_pred)),
      " R2", round(r2_score(y_valid, log_pred), 3), " prices below zero:", int((log_pred < 0).sum()))
quarter_log = pd.qcut(log_pred, 4, labels=["cheapest", "second", "third", "dearest"])
print("spread of the residuals by quarter of predicted price:")
print((y_valid - log_pred).groupby(quarter_log, observed=True).std().round(0).to_string())

# On the log scale a coefficient is a percentage: one more year, or 10,000 more miles, multiplies the price by:
log_coefs = pd.Series(log_model.named_steps["model"].coef_,
                      index=log_model.named_steps["preprocess"].get_feature_names_out())
per_year = np.exp(log_coefs["num__age"] / X_train["age"].std())
per_10k_miles = np.exp(log_coefs["num__mileage_miles"] / X_train["mileage_miles"].std() * 10_000)
print(f"one more year: x{per_year:.3f}   10,000 more miles: x{per_10k_miles:.3f}")
