"""Lab 03: Supervised learning II: model families.

The code cells of lab03_supervised_models_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab03_supervised_models/lab03_supervised_models_worked.py
It writes the same figures and tables as the notebook, to results/lab03/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses.
import joblib                                                      # save and load fitted models
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.inspection import DecisionBoundaryDisplay, permutation_importance
from sklearn.metrics import (accuracy_score, average_precision_score, mean_absolute_error, precision_score,
                             recall_score, roc_auc_score)
from sklearn.model_selection import GridSearchCV, KFold, StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OrdinalEncoder, StandardScaler
# the model families compared in this lab
from sklearn.ensemble import HistGradientBoostingRegressor, RandomForestRegressor
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB, MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier, export_text, plot_tree
# turning text into word counts, for the Try-it
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab03")

loans = pd.read_csv(DATA / "supervised/lending_club/lending_club_2014_2015.zip", low_memory=False)
print("shape:", loans.shape)
print(loans["loan_status"].value_counts().to_string())

# Thirteen numbers the lender knew when it approved the loan. The eight columns written after
# the loan was issued (payments, recoveries, the latest credit score) never enter a model.
issued = pd.to_datetime(loans["issue_d"], format="%b-%Y")
first_credit = pd.to_datetime(loans["earliest_cr_line"], format="%b-%Y")
X_all = pd.DataFrame({
    "loan_amnt": loans["loan_amnt"],
    "term_months": loans["term"].str.extract(r"(\d+)")[0].astype(int),          # " 36 months" -> 36
    "int_rate": loans["int_rate"],
    "log_income": np.log1p(loans["annual_inc"]),                                # incomes run into the millions
    "dti": loans["dti"],
    "fico": (loans["fico_range_low"] + loans["fico_range_high"]) / 2,
    "revol_util": loans["revol_util"],
    "inquiries_6m": loans["inq_last_6mths"],
    "delinq_2y": loans["delinq_2yrs"],
    "open_acc": loans["open_acc"],
    "mort_acc": loans["mort_acc"],
    "emp_years": loans["emp_length"].replace({"< 1 year": "0 years"}).str.extract(r"(\d+)")[0].astype(float),
    "credit_years": (issued - first_credit).dt.days / 365.25,                   # length of the credit history
})
y_all = (loans["loan_status"] == "Charged Off").astype(int)
print("missing values:", X_all.isna().sum()[lambda s: s > 0].to_dict())

# A random 20,000 loans keep nearest neighbors and SVMs fast on a laptop; the other 80,000 wait for Part D.
X = X_all.sample(20_000, random_state=42)
y = y_all.loc[X.index]
X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
print(len(X_train), "training and", len(X_valid), "validation loans;", int(y_valid.sum()), "validation defaults")

# Every model below fills the few gaps with the training median, then scales: one shared first half.
def prepare():
    return [("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]

# Score each k with five-fold cross-validation on the training loans only.
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
k_values = [1, 5, 25, 101, 201, 401, 801, 1601, 3201]
cv_scores = {}
for k in k_values:
    candidate = Pipeline(prepare() + [("model", KNeighborsClassifier(n_neighbors=k))])
    scores = cross_val_score(candidate, X_train, y_train, cv=cv, scoring="roc_auc")
    cv_scores[k] = scores.mean()
    print(f"k={k:4d}  cross-validated ROC AUC = {scores.mean():.3f}")

best_k = max(cv_scores, key=cv_scores.get)                       # the k with the highest score
print("selected k:", best_k)

plt.figure(figsize=(5, 3.2))
plt.plot(k_values, [cv_scores[k] for k in k_values], marker="o")
plt.xscale("log")
plt.axvline(best_k, linestyle="--", color="grey")
plt.xlabel("k (number of neighbors)")
plt.ylabel("Cross-validated ROC AUC")
plt.title("Choosing k on training data only")
plt.tight_layout()
plt.savefig(RESULTS / "choosing_k_on_training_data_only.png", dpi=160, bbox_inches="tight")
plt.show()

models = {
    "KNN": Pipeline(prepare() + [("model", KNeighborsClassifier(n_neighbors=best_k))]),
    "GaussianNB": Pipeline(prepare() + [("model", GaussianNB())]),
    "logistic": Pipeline(prepare() + [("model", LogisticRegression(max_iter=2000))]),
}

print("always 'repaid' would be", round(1 - y_valid.mean(), 3), "accurate")
for name, model in models.items():
    model.fit(X_train, y_train)
    prob = model.predict_proba(X_valid)[:, 1]                     # each loan's predicted chance of default
    accuracy = accuracy_score(y_valid, prob >= 0.5)
    auc = roc_auc_score(y_valid, prob)
    ap = average_precision_score(y_valid, prob)
    print(f"{name:10s} accuracy={accuracy:.3f} roc_auc={auc:.3f} average_precision={ap:.3f}")

# Three model families on just two columns, so their decision boundaries can be drawn.
two = ["int_rate", "dti"]
families = {
    "Logistic regression": LogisticRegression(max_iter=2000),
    f"KNN (k={best_k})": KNeighborsClassifier(n_neighbors=best_k),
    "Gaussian naive Bayes": GaussianNB(),
}
repaid = (y_valid == 0).to_numpy()
shown = X_valid[two].fillna(X_train[two].median())                # the plot needs every point filled

fig, axes = plt.subplots(1, 3, figsize=(12, 3.8))
for ax, (name, estimator) in zip(axes, families.items()):
    small = Pipeline(prepare() + [("model", estimator)])
    small.fit(X_train[two], y_train)
    auc = roc_auc_score(y_valid, small.predict_proba(X_valid[two])[:, 1])
    print(f"{name:22s} on interest rate and DTI only: ROC AUC {auc:.3f}")
    # Shade each point of the plane by its predicted chance of default, then add the real loans on top.
    DecisionBoundaryDisplay.from_estimator(small, shown, ax=ax, response_method="predict_proba",
                                           cmap="coolwarm", alpha=0.6, vmin=0, vmax=0.6)
    ax.scatter(shown.loc[repaid, two[0]], shown.loc[repaid, two[1]], s=2, color="grey", alpha=0.3)
    ax.scatter(shown.loc[~repaid, two[0]], shown.loc[~repaid, two[1]], s=5, color="black", marker="x", alpha=0.5)
    ax.set_title(f"{name}: ROC AUC {auc:.2f}")
    ax.set_xlabel("interest rate (%)")
    ax.set_ylabel("debt-to-income ratio (%)")
plt.tight_layout()
plt.savefig(RESULTS / "three_boundaries_on_rate_and_dti.png", dpi=160, bbox_inches="tight")
plt.show()

# Trees need no scaling, but scikit-learn's trees need every gap filled: the training median again.
filler = SimpleImputer(strategy="median").set_output(transform="pandas").fit(X_train)
Xt_train, Xt_valid = filler.transform(X_train), filler.transform(X_valid)

tree = DecisionTreeClassifier(max_depth=3, random_state=42)
tree.fit(Xt_train, y_train)
prob_tree = tree.predict_proba(Xt_valid)[:, 1]
print("validation ROC AUC:", round(roc_auc_score(y_valid, prob_tree), 3),
      " average precision:", round(average_precision_score(y_valid, prob_tree), 3))
print("loans flagged at 0.5:", int((prob_tree >= 0.5).sum()))
leaf_rates = np.unique(prob_tree.round(3))
print("default rate in each leaf:", leaf_rates.tolist())

# The fitted tree as if-then rules; weights are the training loans in each leaf: [repaid, defaulted].
feature_names = list(Xt_train.columns)
rules = export_text(tree, feature_names=feature_names, show_weights=True, decimals=1)
print(rules)

plt.figure(figsize=(13, 5.5))
plot_tree(tree, feature_names=feature_names, class_names=["repaid", "defaulted"], filled=True, fontsize=8,
          proportion=True, precision=2)
plt.title("The fitted loan tree: samples = share of training loans, value = [repaid, defaulted] shares")
plt.tight_layout()
plt.savefig(RESULTS / "the_fitted_loan_tree.png", dpi=160, bbox_inches="tight")
plt.show()

# Grow the same tree deeper and deeper; None means "no limit".
depths = [1, 2, 3, 4, 5, 6, 8, 10, 15, None]
train_ap, valid_ap = [], []
for depth in depths:
    t = DecisionTreeClassifier(max_depth=depth, random_state=42)
    t.fit(Xt_train, y_train)
    train_ap.append(average_precision_score(y_train, t.predict_proba(Xt_train)[:, 1]))
    valid_ap.append(average_precision_score(y_valid, t.predict_proba(Xt_valid)[:, 1]))
    print(f"max_depth={str(depth):>4}  leaves={t.get_n_leaves():4d}  "
          f"training AP={train_ap[-1]:.3f}  validation AP={valid_ap[-1]:.3f}")

labels = [str(d) if d else "none" for d in depths]
plt.figure(figsize=(6, 3.6))
plt.plot(labels, train_ap, marker="o", label="training")
plt.plot(labels, valid_ap, marker="o", label="validation")
plt.axhline(y_valid.mean(), linestyle="--", color="grey", label="guessing")
plt.xlabel("max_depth")
plt.ylabel("Average precision")
plt.title("Deeper trees memorize; validation peaks and falls")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "deeper_trees_memorize_validation_peaks_and_falls.png", dpi=160, bbox_inches="tight")
plt.show()

cars = pd.read_csv(DATA / "supervised/used_cars/used_cars.zip", low_memory=False)

# Lab 2's fixed rules: used cars, a believable price, a real odometer reading, tidy spellings.
used = cars[(cars["stock_type"] == "Used") & cars["price_usd"].between(1_000, 200_000)
            & (cars["mileage_miles"] > 100)].copy()

def tidy(column, groups):
    """Each group is matched by a pattern in the lower-case text; the first match wins, no match becomes a gap."""
    text = column.str.lower()
    matches = [text.str.contains(pattern, na=False) for pattern in groups.values()]
    return pd.Series(np.select(matches, list(groups), default=None), index=column.index)

used["drive"] = tidy(used["drivetrain"], {"AWD": "all|awd", "4WD": "four|4wd|4x4", "FWD": "front|fwd", "RWD": "rear|rwd"})
used["fuel_type"] = tidy(used["fuel"], {"plug-in hybrid": "plug", "hybrid": "hybrid|mild", "electric": "electric",
                                        "diesel": "diesel", "flex fuel": "flex|e85", "gasoline": "gas|petrol|unleaded"})
used["age"] = (2026 - used["year"]).clip(lower=0)

# Trees split on numbers, so each category becomes a code (Toyota = 68, say); a gap gets the code -1.
c_num = ["age", "mileage_miles", "cpo"]
c_cat = ["make", "model", "body_type", "drive", "fuel_type"]
codes = OrdinalEncoder(handle_unknown="use_encoded_value", unknown_value=-1, encoded_missing_value=-1)
X_c = pd.concat([used[c_num].reset_index(drop=True),
                 pd.DataFrame(codes.fit_transform(used[c_cat]), columns=c_cat)], axis=1)
y_c = np.log(used["price_usd"]).reset_index(drop=True)      # the log price, as in Lab 2's Try-it

ensembles = {
    "random_forest": RandomForestRegressor(n_estimators=150, max_features=0.5, min_samples_leaf=2,
                                           random_state=42, n_jobs=-1),
    "gradient_boosting": HistGradientBoostingRegressor(max_iter=300, learning_rate=0.1, random_state=42),
}

# Three folds; scikit-learn reports the negative mean squared error, so flip the sign and take the root.
cv3 = KFold(n_splits=3, shuffle=True, random_state=42)
cv_rmse = {}
for name, estimator in ensembles.items():
    neg_mse = cross_val_score(estimator, X_c, y_c, cv=cv3, scoring="neg_mean_squared_error")
    cv_rmse[name] = np.sqrt(-neg_mse)
    print(f"{name:18s} CV log-RMSE = {cv_rmse[name].mean():.4f} +/- {cv_rmse[name].std():.4f}"
          f"   folds {np.round(cv_rmse[name], 4)}")

plt.figure(figsize=(5, 3.4))
for i, (name, values) in enumerate(cv_rmse.items()):
    plt.scatter([i] * len(values), values, s=60, label="fold scores" if i == 0 else None)
    plt.hlines(values.mean(), i - 0.2, i + 0.2, color="black", label="mean" if i == 0 else None)
plt.xticks(range(len(cv_rmse)), list(cv_rmse))
plt.ylabel("log-RMSE per fold (lower is better)")
plt.title("Fold-by-fold: is the gap bigger than the spread?")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "fold_by_fold_is_the_gap_bigger_than_the_spread.png", dpi=160, bbox_inches="tight")
plt.show()

Xc_train, Xc_valid, yc_train, yc_valid = train_test_split(X_c, y_c, test_size=0.25, random_state=42)
booster = ensembles["gradient_boosting"].fit(Xc_train, yc_train)

# Back from log prices to dollars, then score the predictions in dollars.
price_pred = np.exp(booster.predict(Xc_valid))
price_true = np.exp(yc_valid)
squared_misses = ((price_true - price_pred) ** 2).sum()
squared_spread = ((price_true - price_true.mean()) ** 2).sum()
r2_dollars = 1 - squared_misses / squared_spread
print("validation MAE in dollars:", round(mean_absolute_error(price_true, price_pred)),
      " R2 in dollars:", round(r2_dollars, 3))

# Shuffle one column at a time and measure how much worse the predictions get.
importance = permutation_importance(booster, Xc_valid, yc_valid, n_repeats=5, random_state=42, n_jobs=-1)
ranked = pd.Series(importance.importances_mean, index=X_c.columns).sort_values()
print(ranked.sort_values(ascending=False).round(3).to_string())

fig, axes = plt.subplots(1, 2, figsize=(11, 4.2))
axes[0].barh(ranked.index, ranked.values)
axes[0].set_xlabel("Increase in squared log error when the column is shuffled")
axes[0].set_title("Permutation importance (gradient boosting)")
axes[1].scatter(price_true / 1e3, price_pred / 1e3, s=3, alpha=0.3)
axes[1].plot([0, 200], [0, 200], linestyle="--", color="grey")
axes[1].set_xlim(0, 200)
axes[1].set_ylim(0, 200)
axes[1].set_xlabel("Asking price ($ thousand)")
axes[1].set_ylabel("Predicted price ($ thousand)")
axes[1].set_title("Gradient boosting on the validation listings")
plt.tight_layout()
plt.savefig(RESULTS / "what_the_boosted_trees_used.png", dpi=160, bbox_inches="tight")
plt.show()

# Parts A and B compared models on the validation loans, so the test set must be loans no part has seen:
# 20,000 of the 80,000 loans outside the sample. The SVM trains on Part A's training loans.
outside = X_all.drop(X.index)
X_test = outside.sample(20_000, random_state=1)
y_test = y_all.loc[X_test.index]

# Two dials: C (how hard to fit the training loans) and gamma (how local the RBF kernel is).
# Balanced class weights stop the SVM from simply calling every loan "repaid".
svm_pipe = Pipeline(prepare() + [("model", SVC(class_weight="balanced"))])
search = GridSearchCV(
    svm_pipe,
    param_grid=[
        {"model__kernel": ["linear"], "model__C": [0.1, 1]},
        {"model__kernel": ["rbf"], "model__C": [0.1, 1, 10], "model__gamma": ["scale", 0.01, 0.1]},
    ],
    cv=StratifiedKFold(3, shuffle=True, random_state=42),
    scoring="roc_auc",
    n_jobs=-1,
)
search.fit(X_train, y_train)

score = search.decision_function(X_test)          # distance from the boundary: higher means more likely to default
pred = search.predict(X_test)                     # the decision at the boundary itself
print("best parameters:", search.best_params_)
print("cross-validated ROC AUC:", round(search.best_score_, 3))
print("test ROC AUC:", round(roc_auc_score(y_test, score), 3),
      " test average precision:", round(average_precision_score(y_test, score), 3))
print("at the default boundary: precision", round(precision_score(y_test, pred), 3),
      " recall", round(recall_score(y_test, pred), 3))

# The RBF rows of the search, as a table of C against gamma.
results = pd.DataFrame(search.cv_results_)
rbf = results[results["param_model__kernel"] == "rbf"].copy()
rbf["gamma"] = rbf["param_model__gamma"].astype(str)
grid = rbf.pivot(index="param_model__C", columns="gamma", values="mean_test_score")
print(grid.round(3).to_string())

fig, axes = plt.subplots(1, 3, figsize=(13, 3.8))
axes[0].imshow(grid.values, cmap="viridis", aspect="auto")
axes[0].set_xticks(range(len(grid.columns)), grid.columns)
axes[0].set_yticks(range(len(grid.index)), grid.index)
axes[0].set_xlabel("gamma")
axes[0].set_ylabel("C")
for i in range(grid.shape[0]):
    for j in range(grid.shape[1]):
        axes[0].text(j, i, f"{grid.values[i, j]:.3f}", ha="center", va="center", color="white", fontsize=8)
axes[0].set_title("RBF kernel: CV ROC AUC by C and gamma")

# Two-column versions, drawn so the difference between the kernels is visible.
kernels = {
    "Linear kernel": SVC(kernel="linear", C=1, class_weight="balanced"),
    "RBF kernel (gamma = 1)": SVC(kernel="rbf", C=1, gamma=1.0, class_weight="balanced"),
}
defaulted = (y_test == 1).to_numpy()
drawn = X_test[two].fillna(X_train[two].median()).iloc[:4000]          # 4,000 test loans keep the plot readable
for ax, (title, estimator) in zip(axes[1:], kernels.items()):
    small = Pipeline(prepare() + [("model", estimator)])
    small.fit(X_train[two], y_train)
    auc = roc_auc_score(y_test, small.decision_function(X_test[two]))
    DecisionBoundaryDisplay.from_estimator(small, drawn, ax=ax, alpha=0.3, response_method="predict", cmap="coolwarm")
    ax.scatter(drawn.loc[~defaulted[:4000], two[0]], drawn.loc[~defaulted[:4000], two[1]], s=2, color="grey", alpha=0.3)
    ax.scatter(drawn.loc[defaulted[:4000], two[0]], drawn.loc[defaulted[:4000], two[1]], s=5, color="black",
               marker="x", alpha=0.5)
    ax.set_title(f"{title}: test ROC AUC {auc:.2f}")
    ax.set_xlabel("interest rate (%)")
    ax.set_ylabel("debt-to-income ratio (%)")
plt.tight_layout()
plt.savefig(RESULTS / "two_dials_and_two_kernels.png", dpi=160, bbox_inches="tight")
plt.show()

# Save the tuned pipeline (imputer, scaler and SVM together), load it back, and check it predicts the same.
model_path = MODELS / "loan_default_svm.joblib"
joblib.dump(search.best_estimator_, model_path)
loaded = joblib.load(model_path)
same = np.array_equal(loaded.predict(X_test), pred)
print("file size (KB):", round(model_path.stat().st_size / 1024, 1))
print("reloaded model reproduces the test predictions:", same)

pd.Series(cv_scores, name="cv_roc_auc").rename_axis("k").round(4).to_csv(RESULTS / "knn_selection.csv")
(RESULTS / "loan_tree_rules.txt").write_text(rules)
pd.DataFrame(cv_rmse).round(4).to_csv(RESULTS / "car_price_fold_scores.csv", index=False)
grid_columns = ["param_model__kernel", "param_model__C", "param_model__gamma", "mean_test_score", "std_test_score",
                "rank_test_score"]
results[grid_columns].sort_values("rank_test_score").round(4).to_csv(RESULTS / "svm_grid_search.csv", index=False)

# One row per model, collected from the parts above.
rows = []
for name, m in models.items():
    rows.append({"part": "A", "dataset": "lending_club", "model": name, "metric": "roc_auc",
                 "validation": roc_auc_score(y_valid, m.predict_proba(X_valid)[:, 1])})
rows.append({"part": "B", "dataset": "lending_club", "model": "decision_tree(depth=3)", "metric": "average_precision",
             "validation": average_precision_score(y_valid, prob_tree)})
for name, values in cv_rmse.items():
    rows.append({"part": "C", "dataset": "used_cars", "model": name, "metric": "cv_log_rmse",
                 "validation": values.mean()})
rows.append({"part": "D", "dataset": "lending_club", "model": f"svc {search.best_params_}", "metric": "roc_auc",
             "validation": search.best_score_, "test": roc_auc_score(y_test, score)})
pd.DataFrame(rows).round(4).to_csv(RESULTS / "metrics.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# Your work here

sms = pd.read_csv(DATA / "supervised/sms_spam/sms_spam.csv")
y_s = (sms["label"] == "spam").astype(int)
print("messages:", len(sms), " spam share:", round(y_s.mean(), 3),
      " repeated messages:", int(sms["message"].duplicated().sum()))
Xs_train, Xs_valid, ys_train, ys_valid = train_test_split(sms["message"], y_s, test_size=0.25, random_state=42,
                                                          stratify=y_s)

# Each pipeline turns the messages into word columns first, then classifies them.
text_models = {
    "naive Bayes on word counts": Pipeline([
        ("words", CountVectorizer()),                     # one column per word: how often it appears
        ("model", MultinomialNB()),
    ]),
    "KNN (k=5) on tf-idf, cosine": Pipeline([
        ("words", TfidfVectorizer()),                     # word counts, down-weighting very common words
        ("model", KNeighborsClassifier(5, metric="cosine")),
    ]),
}
for name, model in text_models.items():
    model.fit(Xs_train, ys_train)
    p = model.predict_proba(Xs_valid)[:, 1]
    print(f"{name:28s} ROC AUC={roc_auc_score(ys_valid, p):.3f}  precision={precision_score(ys_valid, p >= 0.5):.3f}  "
          f"recall={recall_score(ys_valid, p >= 0.5):.3f}")

# Which words push a message towards spam? Compare each word's log probability in spam and in ham.
nb = text_models["naive Bayes on word counts"]
vocab = nb.named_steps["words"].get_feature_names_out()
word_log_prob = nb.named_steps["model"].feature_log_prob_          # row 0: ham, row 1: spam
log_ratio = word_log_prob[1] - word_log_prob[0]
top_ten = np.argsort(log_ratio)[-10:][::-1]
print("words that most raise the spam odds:", list(vocab[top_ten]))
