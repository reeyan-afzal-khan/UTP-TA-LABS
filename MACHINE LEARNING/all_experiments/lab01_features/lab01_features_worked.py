"""Lab 01: Feature engineering and feature selection.

The code cells of lab01_features_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab01_features/lab01_features_worked.py
It writes the same figures and tables as the notebook, to results/lab01/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# %% Question 1 - Setup
# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses.
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sklearn
from sklearn.compose import ColumnTransformer                      # separate steps for numbers and text
from sklearn.feature_selection import SelectKBest, f_classif       # keep the k strongest columns
from sklearn.impute import SimpleImputer                           # fill missing values
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import average_precision_score, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.neighbors import NearestNeighbors
from sklearn.pipeline import Pipeline                              # preparation and model as one object
from sklearn.preprocessing import OneHotEncoder, StandardScaler

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab01")

# %% Question 2 - Print the package versions
print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
print("Matplotlib:", matplotlib.__version__)
print("scikit-learn:", sklearn.__version__)

# %% Question 3 - Read the data card, then the bookings
# The data card beside the data says what each column means. Its column table starts at "| `hotel`".
card = (DATA / "supervised/hotel_bookings/README.md").read_text(encoding="utf-8")
for row in card[card.index("| `hotel`"):].splitlines():
    column, meaning = row.split(" | ")[:2]
    print(f"{column.strip('| `'):32s}{meaning}")

# The bookings themselves: one row per booking.
hotels = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
print("\nshape:", hotels.shape)
print(hotels["hotel"].value_counts().to_string())

# The arrival date is spread over three columns, with the month as a word: join them into one date.
text_date = (hotels["arrival_date_year"].astype(str) + "-" + hotels["arrival_date_month"]
             + "-" + hotels["arrival_date_day_of_month"].astype(str))
hotels["arrival_date"] = pd.to_datetime(text_date, format="%Y-%B-%d")
print("arrivals from", hotels["arrival_date"].min().date(), "to", hotels["arrival_date"].max().date())

print("\nCancellation rate:\n", hotels["is_canceled"].value_counts(normalize=True).round(3))

# %% Question 4 - Chart the missing values, and date the columns
# Share of bookings missing each column, largest first; columns with no gaps are left out.
missing = hotels.isna().mean().sort_values(ascending=False)
missing = missing[missing > 0]

plt.figure(figsize=(5.5, 2.4))
plt.barh(missing.index, missing.values * 100)
plt.xlabel("Share of bookings missing (%)")
plt.title("Hotel bookings: where the gaps are")
plt.tight_layout()
plt.savefig(RESULTS / "hotel_where_the_gaps_are.png", dpi=160, bbox_inches="tight")
plt.show()
print(missing.mul(100).round(2).to_string())

# reservation_status says how the booking ended. Does it already know the answer?
print("\n", pd.crosstab(hotels["reservation_status"], hotels["is_canceled"]))

# And when was it written? Compare its date with the arrival date.
status_date = pd.to_datetime(hotels["reservation_status_date"])
written_on_or_after_arrival = (status_date >= hotels["arrival_date"]).rename(
    "status written on or after arrival")
print("\n", pd.crosstab(written_on_or_after_arrival, hotels["is_canceled"]))

# %% Question 5 - Engineer five new columns
# 1. Length of stay: weekend nights plus week nights.
hotels["total_nights"] = hotels["stays_in_weekend_nights"] + hotels["stays_in_week_nights"]

# 2-3. Size of the party, and whether children or babies come along.
#      Four bookings have no children count: a blank is read as none.
children = hotels["children"].fillna(0).astype(int)
hotels["total_guests"] = hotels["adults"] + children + hotels["babies"]
hotels["with_children"] = ((children + hotels["babies"]) > 0).astype(int)

# 4. Lead time is skewed: most bookings are made weeks ahead, a few up to two years ahead.
#    ln(1 + days) spreads the short lead times and squeezes the long ones.
hotels["log_lead_time"] = np.log1p(hotels["lead_time"])

# 5. Has this customer cancelled a booking before?
hotels["cancelled_before"] = (hotels["previous_cancellations"] > 0).astype(int)

new = ["total_nights", "total_guests", "with_children", "log_lead_time", "cancelled_before"]
inputs = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
          "previous_cancellations"]
two_bookings = [14876, 40060]                # a family at the resort hotel; the first city-hotel booking
print(hotels.loc[two_bookings, ["hotel"] + inputs + new].round(3).T.to_string())

# %% Question 6 - Check the new columns for signal
# Cancellation rate by how far ahead the booking was made, and by the length of the stay.
lead_band = pd.cut(hotels["lead_time"], [-1, 7, 30, 90, 180, 365, 800],
                   labels=["0-7", "8-30", "31-90", "91-180", "181-365", "366+"])
by_lead = hotels.groupby(lead_band, observed=True)["is_canceled"].mean()
by_nights = hotels.groupby(hotels["total_nights"].clip(upper=8))["is_canceled"].mean()   # 8 = 8 or more

fig, axes = plt.subplots(1, 2, figsize=(9.5, 3.4))
by_lead.plot.bar(ax=axes[0], rot=0)
axes[0].set_xlabel("Days booked ahead")
axes[0].set_ylabel("Cancellation rate")
axes[0].set_title("Bookings made far ahead cancel most")
by_nights.plot.bar(ax=axes[1], rot=0)
axes[1].set_xlabel("Nights booked (8 = eight or more)")
axes[1].set_title("Zero-night bookings almost never cancel")
plt.tight_layout()
plt.savefig(RESULTS / "far_ahead_bookings_cancel_most.png", dpi=160, bbox_inches="tight")
plt.show()

print("by days ahead:    ", by_lead.round(3).to_dict())
print("by nights:        ", by_nights.round(3).to_dict())
print("with children:    ", hotels.groupby("with_children")["is_canceled"].mean().round(3).to_dict())
print("cancelled before: ", hotels.groupby("cancelled_before")["is_canceled"].mean().round(3).to_dict())

# %% Question 7 - Test the new columns on a model
def make_preprocess(num_cols, cat_cols):
    """Prepare a table: fill and scale the number columns, fill and one-hot encode the text columns."""
    numbers = Pipeline([
        ("impute", SimpleImputer(strategy="median")),
        ("scale", StandardScaler()),
    ])
    categories = Pipeline([
        ("impute", SimpleImputer(strategy="most_frequent")),
        ("onehot", OneHotEncoder(handle_unknown="ignore")),
    ])
    return ColumnTransformer([("num", numbers, num_cols), ("cat", categories, cat_cols)])

y = hotels["is_canceled"]
raw_num = ["lead_time", "stays_in_weekend_nights", "stays_in_week_nights", "adults", "children", "babies",
           "previous_cancellations", "previous_bookings_not_canceled", "adr",
           "required_car_parking_spaces", "total_of_special_requests"]
raw_cat = ["hotel", "meal", "market_segment", "deposit_type", "customer_type"]
feature_sets = {
    "raw columns": (raw_num, raw_cat),
    "raw + engineered": (raw_num + new, raw_cat),
}

# The same split and the same model for both sets, so only the columns differ.
for name, (num_cols, cat_cols) in feature_sets.items():
    X = hotels[num_cols + cat_cols]
    X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.25, random_state=42,
                                                          stratify=y)
    model = Pipeline([
        ("preprocess", make_preprocess(num_cols, cat_cols)),
        ("model", LogisticRegression(max_iter=3000)),
    ])
    model.fit(X_train, y_train)
    auc = roc_auc_score(y_valid, model.predict_proba(X_valid)[:, 1])
    print(f"{name:18s} validation ROC AUC = {auc:.3f}")
print("validation bookings:", len(y_valid))

# %% Question 8 - Fix the types, then see the units
churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
print("shape:", churn.shape, " TotalCharges is stored as:", churn["TotalCharges"].dtype)

# Convert the text to numbers; anything that is not a number becomes NaN, so it can be found.
total = pd.to_numeric(churn["TotalCharges"], errors="coerce")
not_numbers = total.isna()
print("rows that are not numbers:", not_numbers.sum(),
      " their tenure:", churn.loc[not_numbers, "tenure"].unique())
churn["TotalCharges"] = total.fillna(0)      # brand-new customers: nothing billed yet

money = ["tenure", "MonthlyCharges", "TotalCharges"]
print(churn[money].describe().loc[["mean", "std"]].round(2))

# %% Question 9 - Compare neighbors before and after scaling
X_raw = churn[money].to_numpy()
X_std = StandardScaler().fit_transform(X_raw)          # every column now: mean 0, standard deviation 1

def neighbors(X, row, k=10):
    """The k rows of X closest to `row`, not counting the row itself."""
    finder = NearestNeighbors(n_neighbors=k + 1).fit(X)
    found = finder.kneighbors(X[[row]], return_distance=False)[0]
    return found[found != row][:k]

customer = 3                                 # 7795-CFOCW: 45 months at $42.30 a month
near_raw = neighbors(X_raw, customer)
near_std = neighbors(X_std, customer)
for label, rows in [("raw units", near_raw), ("standardized", near_std)]:
    n = churn.loc[rows]
    print(f"{label:12s}  tenure {n.tenure.min()}-{n.tenure.max()} months   "
          f"monthly ${n.MonthlyCharges.min():.2f}-{n.MonthlyCharges.max():.2f}   "
          f"total ${n.TotalCharges.min():,.0f}-{n.TotalCharges.max():,.0f}")
print("customers in both lists:", len(set(near_raw) & set(near_std)))

fig, ax = plt.subplots(figsize=(6, 4))
ax.scatter(churn["tenure"], churn["MonthlyCharges"], s=5, color="lightgrey", label="other customers")
ax.scatter(X_raw[near_raw, 0], X_raw[near_raw, 1], s=45, marker="s", label="10 nearest, raw units")
ax.scatter(X_raw[near_std, 0], X_raw[near_std, 1], s=45, marker="^", label="10 nearest, standardized")
ax.scatter(X_raw[customer, 0], X_raw[customer, 1], s=160, marker="*", color="black",
           label="customer 7795-CFOCW")
ax.set_xlim(20, 60)
ax.set_ylim(30, 70)
ax.set_xlabel("tenure (months)")
ax.set_ylabel("monthly charge ($)")
ax.set_title("One customer, two sets of neighbors")
ax.legend(fontsize=8, loc="upper left")
plt.tight_layout()
plt.savefig(RESULTS / "one_customer_two_sets_of_neighbors.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 10 - Define the bank-call task
bank = pd.read_csv(DATA / "supervised/bank_marketing/bank_marketing.csv", sep=";")  # columns split on ;
print("shape:", bank.shape, " missing:", bank.isna().sum().sum(), " duplicates:", bank.duplicated().sum())
bank = bank.drop_duplicates().reset_index(drop=True)

said_yes = (bank["y"] == "yes").mean()
unknown_cells = (bank == "unknown").sum().sum()
never_called = (bank["pdays"] == 999).mean()           # 999 is a code for "never called before"
print("said yes:", round(said_yes, 3),
      " 'unknown' cells:", int(unknown_cells),
      " pdays = 999:", round(never_called, 3))

# The label, and the features known before the call. duration is known only once the call has ended.
y_b = (bank["y"] == "yes").astype(int)
X_b = bank.drop(columns=["y", "duration"])
b_num = X_b.select_dtypes(include="number").columns.tolist()
b_cat = X_b.select_dtypes(exclude="number").columns.tolist()
print(len(b_num), "numeric and", len(b_cat), "text features known before the call")

Xb_train, Xb_valid, yb_train, yb_valid = train_test_split(X_b, y_b, test_size=0.25, random_state=42,
                                                          stratify=y_b)

# %% Question 11 - Compare feature sets, and see leakage
def evaluate(pipeline, X_train, X_valid, label):
    """Fit on the training calls, score the validation calls, print both metrics, return the ROC AUC."""
    pipeline.fit(X_train, yb_train)
    prob = pipeline.predict_proba(X_valid)[:, 1]
    auc = roc_auc_score(yb_valid, prob)
    ap = average_precision_score(yb_valid, prob)
    print(f"{label:28s} ROC AUC = {auc:.3f}   average precision = {ap:.3f}")
    return auc

results = {}

# A. Every feature known before the call.
all_features = Pipeline([
    ("preprocess", make_preprocess(b_num, b_cat)),
    ("model", LogisticRegression(max_iter=2000)),
])
results["all 19 features"] = evaluate(all_features, Xb_train, Xb_valid, "all 19 features")

# B. Only the 10 columns with the strongest single-column link to the label.
best_ten = Pipeline([
    ("preprocess", make_preprocess(b_num, b_cat)),
    ("select", SelectKBest(f_classif, k=10)),
    ("model", LogisticRegression(max_iter=2000)),
])
results["SelectKBest, k=10"] = evaluate(best_ten, Xb_train, Xb_valid, "SelectKBest, k=10")

# C. An L1 penalty, which sets the weights of unhelpful columns to exactly zero.
l1 = Pipeline([
    ("preprocess", make_preprocess(b_num, b_cat)),
    ("model", LogisticRegression(penalty="l1", C=0.03, solver="liblinear", random_state=42)),
])
results["L1 penalty (selects itself)"] = evaluate(l1, Xb_train, Xb_valid, "L1 penalty (selects itself)")

# D. The leakage test: the same model as A, also given the call's duration.
leaky_train = Xb_train.assign(duration=bank.loc[Xb_train.index, "duration"])
leaky_valid = Xb_valid.assign(duration=bank.loc[Xb_valid.index, "duration"])
with_duration = Pipeline([
    ("preprocess", make_preprocess(b_num + ["duration"], b_cat)),
    ("model", LogisticRegression(max_iter=2000)),
])
results["all 19 + duration (leakage)"] = evaluate(with_duration, leaky_train, leaky_valid,
                                                  "all 19 + duration (leakage)")

# %% Question 12 - Read what the L1 penalty kept
# One weight per encoded column; the L1 penalty set most of them to zero.
column_names = l1.named_steps["preprocess"].get_feature_names_out()
coefs = pd.Series(l1.named_steps["model"].coef_[0], index=column_names)
kept = coefs[coefs != 0].sort_values()
print(f"the L1 penalty kept {len(kept)} of {len(coefs)} encoded columns")
strongest = kept.reindex(kept.abs().sort_values(ascending=False).index)
print(strongest.head(6).round(3).to_string())

fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
axes[0].barh(list(results), list(results.values()))
axes[0].set_xlim(0.5, 1.0)
axes[0].set_xlabel("Validation ROC AUC")
axes[0].set_title("Fewer columns, same score; a leaked column, a false jump")
axes[1].barh(kept.index, kept.values)
axes[1].axvline(0, color="grey", linewidth=0.8)
axes[1].set_title("What the L1 penalty kept")
plt.tight_layout()
plt.savefig(RESULTS / "what_the_l1_penalty_kept.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 13 - Save the evidence
environment = pd.DataFrame({
    "package": ["numpy", "pandas", "matplotlib", "scikit-learn"],
    "version": [np.__version__, pd.__version__, matplotlib.__version__, sklearn.__version__],
})
environment.to_csv(RESULTS / "environment.csv", index=False)
missing.rename("share_missing").round(4).to_csv(RESULTS / "missing_values.csv")
by_lead.rename("cancellation_rate").round(3).rename_axis("days_ahead").to_csv(
    RESULTS / "cancellation_by_days_ahead.csv")
pd.Series(results, name="validation_roc_auc").rename_axis("feature_set").round(3).to_csv(
    RESULTS / "feature_selection.csv")
kept.rename("l1_coefficient").round(3).to_csv(RESULTS / "l1_coefficients.csv")

# The customer and both neighbor lists, in one table.
rows = np.r_[customer, near_raw, near_std]
neighbor_table = churn.loc[rows, ["customerID"] + money].copy()
neighbor_table["neighbors"] = ["the customer"] + ["raw units"] * 10 + ["standardized"] * 10
neighbor_table.to_csv(RESULTS / "neighbors_raw_and_scaled.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 14 - Try it yourself
# Your work here

# %% Question 15 - One solution
# Part 1: the weekday of arrival, from the date built in Question 3.
hotels["arrival_weekday"] = hotels["arrival_date"].dt.day_name()
days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
print("cancellation rate by arrival day:",
      hotels.groupby("arrival_weekday")["is_canceled"].mean().reindex(days).round(3).to_dict())

num_cols, cat_cols = feature_sets["raw + engineered"]
for label, cats in {"raw + engineered": cat_cols,
                    "raw + engineered + weekday": cat_cols + ["arrival_weekday"]}.items():
    X = hotels[num_cols + cats]
    X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.25, random_state=42,
                                                          stratify=y)
    model = Pipeline([
        ("preprocess", make_preprocess(num_cols, cats)),
        ("model", LogisticRegression(max_iter=3000)),
    ])
    model.fit(X_train, y_train)
    auc = roc_auc_score(y_valid, model.predict_proba(X_valid)[:, 1])
    print(f"{label:26s} validation ROC AUC = {auc:.3f}")

# Part 2: other selection sizes for the bank calls.
for k in [5, 10, 20]:
    selected = Pipeline([
        ("preprocess", make_preprocess(b_num, b_cat)),
        ("select", SelectKBest(f_classif, k=k)),
        ("model", LogisticRegression(max_iter=2000)),
    ])
    evaluate(selected, Xb_train, Xb_valid, f"SelectKBest, k={k}")
