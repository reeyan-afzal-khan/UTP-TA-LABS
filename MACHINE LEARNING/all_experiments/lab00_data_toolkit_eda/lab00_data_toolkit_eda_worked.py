"""Lab 00: Python data toolkit and exploratory data analysis.

The code cells of lab00_data_toolkit_eda_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab00_data_toolkit_eda/lab00_data_toolkit_eda_worked.py
It writes the same figures and tables as the notebook, to results/lab00/.
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
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer                      # different steps per kind of column
from sklearn.impute import SimpleImputer                           # fill missing values
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline                              # chain preparation and model together
from sklearn.preprocessing import OneHotEncoder, StandardScaler

# 3. Where this lab reads and writes.
DATA, RESULTS, MODELS = start_lab("lab00")

# %% Question 2 - Read the data card, then the table
# The data card beside the data says what each column means. Its column table starts at "| `Age`".
card = (DATA / "supervised/heart_disease/README.md").read_text(encoding="utf-8")
for row in card[card.index("| `Age`"):].splitlines():
    column, meaning = row.split(" | ")[:2]
    print(f"{column.strip('| `'):16s}{meaning}")

# The table itself: one row per patient.
heart = pd.read_csv(DATA / "supervised/heart_disease/heart_disease.csv")
print("\nshape:", heart.shape)
print(heart.head(3).T)

# %% Question 3 - Types, blanks, repeats and distinct values
# One line per column: its type, how many cells are blank, and how many different values it takes.
overview = pd.DataFrame({
    "type": heart.dtypes.astype(str),
    "blank": heart.isna().sum(),
    "distinct": heart.nunique(),
})
print(overview)
print("\nrepeated rows:", heart.duplicated().sum())

# A column with only a few distinct values is a category, whatever its type says.
target = "HeartDisease"
categories = [c for c in heart.columns if heart[c].nunique() <= 4 and c != target]
numbers = [c for c in heart.columns if c not in categories and c != target]
print("numbers:   ", numbers)
print("categories:", categories)
print("share with heart disease:", round(heart[target].mean(), 3))

# %% Question 4 - Could every value be real?
# The smallest, middle and largest value of every number column.
print(heart[numbers].describe().loc[["min", "50%", "max"]].round(1))

# A comparison gives one True or False per row: a mask.
# The sum of a mask counts the rows; inside loc[] a mask selects them.
no_pressure = heart["RestingBP"] == 0
no_cholesterol = heart["Cholesterol"] == 0
print("\nblood pressure of 0:", no_pressure.sum(), "  cholesterol of 0:", no_cholesterol.sum(),
      f"({no_cholesterol.mean():.1%} of the patients)",
      "  negative Oldpeak:", (heart["Oldpeak"] < 0).sum())
print(heart.loc[no_pressure, ["Age", "Sex", "RestingBP", "Cholesterol", "MaxHR", "HeartDisease"]])

# %% Question 5 - See the zeros, then mark them as missing
raw = heart.copy()                           # the table as it arrived, kept for comparison

# The repair is a fixed rule from the data card, so it may run before any split.
# NaN is the marker for "missing".
for column in ["RestingBP", "Cholesterol"]:
    heart[column] = heart[column].replace(0, np.nan)

fig, axes = plt.subplots(1, 2, figsize=(10, 3.2), sharey=True)
axes[0].hist(raw["Cholesterol"], bins=np.arange(0, 651, 25))
axes[0].set_title("As it arrived: a spike at exactly 0")
axes[1].hist(heart["Cholesterol"].dropna(), bins=np.arange(0, 651, 25))
axes[1].set_title("Zeros marked as missing")
for ax in axes:
    ax.set_xlabel("Cholesterol (mg/dl)")
axes[0].set_ylabel("Patients")
plt.tight_layout()
plt.savefig(RESULTS / "cholesterol_before_and_after.png", dpi=160, bbox_inches="tight")
plt.show()

cleaning_log = {
    "rows": len(heart),
    "RestingBP zeros marked missing": int(no_pressure.sum()),
    "Cholesterol zeros marked missing": int(no_cholesterol.sum()),
    "rows dropped": 0,
}
print(cleaning_log)
blanks = heart.isna().sum()
print("blank cells now:", blanks[blanks > 0].to_dict())

# %% Question 6 - Seal a test set
# stratify keeps the share of heart disease equal on both sides; random_state makes the split repeatable.
train, test = train_test_split(heart, test_size=0.2, random_state=42, stratify=heart[target])
raw_train = raw.loc[train.index]             # the same training patients, with the zeros still in
print("training patients:", len(train), "  test patients:", len(test))
print("share with heart disease: training", round(train[target].mean(), 3),
      "  test", round(test[target].mean(), 3))

# %% Question 7 - The shape of each number column
fig, axes = plt.subplots(1, 5, figsize=(16, 2.9))
for ax, column in zip(axes, numbers):
    ax.hist(train[column].dropna(), bins=25)
    ax.set_title(f"{column} (skew {train[column].skew():.2f})")
axes[0].set_ylabel("Training patients")
plt.tight_layout()
plt.savefig(RESULTS / "the_shape_of_each_number_column.png", dpi=160, bbox_inches="tight")
plt.show()

shape_table = train[numbers].describe().loc[["count", "mean", "50%"]].T
shape_table["skew"] = train[numbers].skew()
print(shape_table.round(2))
print("\ncholesterol with the zeros left in: mean", round(raw_train["Cholesterol"].mean(), 1),
      " skew", round(raw_train["Cholesterol"].skew(), 2))
print("share of Oldpeak that is exactly 0:", round((train["Oldpeak"] == 0).mean(), 3))
round_readings = (train["RestingBP"] % 10 == 0).mean()
print("share of blood pressures that are a multiple of 10:", round(round_readings, 3))

# %% Question 8 - Five numbers, fences and box plots
def five_numbers(values):
    """The five-number summary, the fences 1.5 IQR beyond the box, and how many values lie outside them."""
    values = values.dropna()
    q1, median, q3 = values.quantile([0.25, 0.50, 0.75])
    iqr = q3 - q1
    low_fence, high_fence = q1 - 1.5 * iqr, q3 + 1.5 * iqr
    outside = ((values < low_fence) | (values > high_fence)).sum()
    return pd.Series({"min": values.min(), "Q1": q1, "median": median, "Q3": q3, "max": values.max(),
                      "low fence": low_fence, "high fence": high_fence, "outside": outside})

summaries = train[numbers].apply(five_numbers).T
print(summaries)

# The rival rule: more than 3 standard deviations from the mean.
z = (train[numbers] - train[numbers].mean()) / train[numbers].std()
print("\nbeyond 3 standard deviations:", (z.abs() > 3).sum().to_dict())

fig, axes = plt.subplots(1, 5, figsize=(16, 2.2))
for ax, column in zip(axes, numbers):
    ax.boxplot(train[column].dropna(), vert=False, widths=0.6)
    ax.set_yticks([])
    ax.set_title(column)
plt.tight_layout()
plt.savefig(RESULTS / "box_plots_of_the_number_columns.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 9 - Count the categories
fig, axes = plt.subplots(1, 6, figsize=(17, 2.7))
for ax, column in zip(axes, categories):
    counts = train[column].value_counts()
    counts.plot.bar(ax=ax, rot=0)
    ax.set_title(column)
    ax.set_xlabel("")
    print(f"{column:15s}", counts.to_dict())
axes[0].set_ylabel("Training patients")
plt.tight_layout()
plt.savefig(RESULTS / "how_often_each_category_occurs.png", dpi=160, bbox_inches="tight")
plt.show()

smallest = min((train[c].value_counts().min(), c, train[c].value_counts().idxmin()) for c in categories)
size, column, value = smallest
print(f"\nsmallest group: {value} in {column}, {size} patients ({size / len(train):.1%})")

# %% Question 10 - Numbers against the target
print(train.groupby(target)[numbers].mean().round(2))

fig, axes = plt.subplots(1, 3, figsize=(13, 3.2))
for ax, column in zip(axes, ["MaxHR", "Age", "Oldpeak"]):
    for label, name in [(0, "no heart disease"), (1, "heart disease")]:
        ax.hist(train.loc[train[target] == label, column], bins=20, alpha=0.6, label=name)
    ax.set_xlabel(column)
axes[0].set_ylabel("Training patients")
axes[0].legend(fontsize=8)
axes[0].set_title("Shifted, but overlapping")
plt.tight_layout()
plt.savefig(RESULTS / "numbers_against_the_target.png", dpi=160, bbox_inches="tight")
plt.show()

low, high = train["MaxHR"] < 120, train["MaxHR"] >= 150
print("\ndisease rate when the highest heart rate is under 120:", round(train.loc[low, target].mean(), 3),
      " at 150 or more:", round(train.loc[high, target].mean(), 3))

# %% Question 11 - Categories against the target: a rate and a count
def rate_table(column):
    """The disease rate in each group of a column, the group's size, and how far the rate could be off."""
    table = train.groupby(column)[target].agg(patients="size", disease_rate="mean")
    rate, n = table["disease_rate"], table["patients"]
    table["give_or_take"] = 1.96 * np.sqrt(rate * (1 - rate) / n)
    return table.round(3)

rates = pd.concat({column: rate_table(column) for column in categories}, names=["column", "value"])
print(rates)

fig, axes = plt.subplots(1, 6, figsize=(17, 2.9), sharey=True)
for ax, column in zip(axes, categories):
    table = rates.loc[column]
    ax.bar(table.index.astype(str), table["disease_rate"], yerr=table["give_or_take"], capsize=3)
    ax.axhline(train[target].mean(), color="grey", linestyle="--", linewidth=0.8)
    ax.set_title(column)
axes[0].set_ylabel("Share with heart disease")
plt.tight_layout()
plt.savefig(RESULTS / "disease_rate_in_each_category.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 12 - A gap against the target
not_measured = train["Cholesterol"].isna().rename("cholesterol not measured")
print(pd.crosstab(not_measured, train[target]))
print("\ndisease rate when cholesterol was not measured:",
      round(train.loc[not_measured, target].mean(), 3),
      "  when it was:", round(train.loc[~not_measured, target].mean(), 3))

# %% Question 13 - Correlations, computed twice
with_zeros = raw_train[numbers + [target]].corr()
as_missing = train[numbers + [target]].corr()
cholesterol_pairs = pd.DataFrame({"zeros left in": with_zeros["Cholesterol"],
                                  "zeros as missing": as_missing["Cholesterol"]}).round(2)
print(cholesterol_pairs)

fig, axes = plt.subplots(1, 2, figsize=(11.5, 4.3))
panels = [(axes[0], with_zeros, "Zeros left in"), (axes[1], as_missing, "Zeros marked as missing")]
for ax, table, title in panels:
    ax.imshow(table, cmap="RdBu_r", vmin=-1, vmax=1)
    ax.set_xticks(range(len(table)), table.columns, rotation=45, ha="right")
    ax.set_yticks(range(len(table)), table.index)
    for i in range(len(table)):
        for j in range(len(table)):
            value = table.iloc[i, j]
            ax.text(j, i, f"{value:.2f}", ha="center", va="center", fontsize=8,
                    color="white" if abs(value) > 0.6 else "black")
    ax.set_title(title)
plt.tight_layout()
plt.savefig(RESULTS / "correlations_with_and_without_the_zeros.png", dpi=160, bbox_inches="tight")
plt.show()

# %% Question 14 - Two numbers and the target on one chart
fig, axes = plt.subplots(1, 2, figsize=(12.5, 3.9))
for label, name in [(0, "no heart disease"), (1, "heart disease")]:
    group = train[train[target] == label]
    axes[0].scatter(group["Age"], group["MaxHR"], s=10, alpha=0.6, label=name)
axes[0].set_xlabel("Age (years)")
axes[0].set_ylabel("Highest heart rate (beats per minute)")
axes[0].set_title("Older patients reach lower heart rates")
axes[0].legend(fontsize=8)

# melt() stacks the five columns into one long table: one row per patient and column.
standard = (train[numbers] - train[numbers].mean()) / train[numbers].std()
long = standard.assign(HeartDisease=train[target]).melt(
    id_vars=target, var_name="column", value_name="standard units")
print(long.head(3))
print("rows:", len(train), "patients x", len(numbers), "columns =", len(long))

positions = np.arange(len(numbers))
for label, shift, colour in [(0, -0.2, "tab:blue"), (1, 0.2, "tab:orange")]:
    groups = [long.loc[(long["column"] == c) & (long[target] == label), "standard units"].dropna()
              for c in numbers]
    axes[1].boxplot(groups, positions=positions + shift, widths=0.35, patch_artist=True,
                    boxprops={"facecolor": colour, "alpha": 0.5}, flierprops={"markersize": 2})
axes[1].set_xticks(positions, numbers)
axes[1].set_ylabel("Standard deviations from the mean")
axes[1].set_title("Blue: no heart disease. Orange: heart disease")
plt.tight_layout()
plt.savefig(RESULTS / "two_numbers_and_the_target.png", dpi=160, bbox_inches="tight")
plt.show()
print("correlation of age with highest heart rate:", round(train["Age"].corr(train["MaxHR"]), 2))

# %% Question 15 - Two baselines that need no fitting
y_train, y_test = train[target], test[target]

always_disease = np.ones(len(train), dtype=int)                    # the majority class, for everyone
one_rule = (train["ST_Slope"] != "Up").astype(int)                 # "disease unless the ST slope is Up"
print("always say disease:", round(accuracy_score(y_train, always_disease), 3))
print("one rule on ST_Slope:", round(accuracy_score(y_train, one_rule), 3))
print(pd.crosstab(train["ST_Slope"], y_train))

# %% Question 16 - A pipeline, scored by cross-validation
def make_model(flag_missing):
    """Fill gaps with the median, scale the numbers, one-hot encode the categories, fit the model."""
    number_steps = Pipeline([
        ("impute", SimpleImputer(strategy="median", add_indicator=flag_missing)),
        ("scale", StandardScaler()),
    ])
    prepare = ColumnTransformer([
        ("num", number_steps, numbers),
        ("cat", OneHotEncoder(handle_unknown="ignore"), categories),
    ])
    return Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=2000))])

folds = StratifiedKFold(5, shuffle=True, random_state=42)
versions = {
    "zeros left in": (raw_train, False),
    "zeros as missing": (train, False),
    "zeros as missing + flag": (train, True),
}
comparison = []
for name, (table, flag_missing) in versions.items():
    X = table[numbers + categories]
    accuracy = cross_val_score(make_model(flag_missing), X, y_train, cv=folds, scoring="accuracy")
    auc = cross_val_score(make_model(flag_missing), X, y_train, cv=folds, scoring="roc_auc")
    fitted = make_model(flag_missing).fit(X, y_train)
    weights = pd.Series(fitted.named_steps["model"].coef_[0],
                        index=fitted.named_steps["prepare"].get_feature_names_out())
    cholesterol = weights.filter(like="Cholesterol").rename(lambda name: name.replace("num__", ""))
    comparison.append({"version": name, "accuracy": accuracy.mean(), "spread": accuracy.std(),
                       "roc_auc": auc.mean()})
    print(f"{name:24s} accuracy {accuracy.mean():.3f} (+/- {accuracy.std():.3f})  "
          f"ROC AUC {auc.mean():.3f}  {cholesterol.round(2).to_dict()}")

# %% Question 17 - Open the test set, once
final = make_model(flag_missing=True).fit(train[numbers + categories], y_train)
chance = final.predict_proba(test[numbers + categories])[:, 1]      # probability of heart disease
predicted = (chance >= 0.5).astype(int)

test_accuracy = accuracy_score(y_test, predicted)
test_auc = roc_auc_score(y_test, chance)
matrix = confusion_matrix(y_test, predicted)
print("test accuracy:", round(test_accuracy, 3), "  test ROC AUC:", round(test_auc, 3))
print(pd.DataFrame(matrix, index=["no disease", "disease"], columns=["predicted no", "predicted yes"]))

# The exploration found that men are four patients in five, so report the two groups separately.
for sex, name in [("M", "men"), ("F", "women")]:
    rows = (test["Sex"] == sex).to_numpy()
    group_accuracy = accuracy_score(y_test[rows], predicted[rows])
    print(f"{name:6s} {rows.sum():3d} test patients  accuracy {group_accuracy:.3f}  "
          f"disease rate {y_test[rows].mean():.3f}")

# %% Question 18 - Save the evidence
overview.to_csv(RESULTS / "column_overview.csv")
pd.Series(cleaning_log, name="count").rename_axis("step").to_csv(RESULTS / "cleaning_log.csv")
summaries.round(2).to_csv(RESULTS / "five_number_summaries.csv")
rates.to_csv(RESULTS / "disease_rate_by_category.csv")
cholesterol_pairs.to_csv(RESULTS / "cholesterol_correlations.csv")
pd.DataFrame(comparison).round(3).to_csv(RESULTS / "model_comparison.csv", index=False)
metrics = pd.DataFrame([{
    "test_accuracy": test_accuracy, "test_roc_auc": test_auc,
    "true_negatives": matrix[0, 0], "false_alarms": matrix[0, 1],
    "misses": matrix[1, 0], "true_positives": matrix[1, 1],
}])
metrics.round(3).to_csv(RESULTS / "metrics.csv", index=False)

# The exploration log: what was seen, and what the pipeline does about it.
exploration_log = pd.DataFrame([
    ("two columns hold zeros that mean 'not measured'", "mark as missing", "before the split"),
    ("the cholesterol gap goes with the disease", "fill with the median, add a flag", "pipeline"),
    ("FastingBS is 0/1", "treat as a category", "pipeline"),
    ("cholesterol and Oldpeak are right-skewed, with extremes", "keep every patient, scale", "pipeline"),
    ("categories separate the patients better than numbers", "one-hot encode all six", "pipeline"),
    ("typical angina has only 40 training patients", "keep it, read its effect with caution", "report"),
    ("men are four patients in five", "report results for women separately", "evaluation"),
], columns=["observation", "decision", "where"])
exploration_log.to_csv(RESULTS / "exploration_log.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# %% Question 19 - Try it yourself
# Your work here

# %% Question 20 - One solution
# Part 1: the same rate table, once for women and once for men.
for sex, name in [("F", "women"), ("M", "men")]:
    group = train[train["Sex"] == sex]
    table = group.groupby("ChestPainType")[target].agg(patients="size", disease_rate="mean").round(3)
    print(name, "- overall disease rate", round(group[target].mean(), 3))
    print(table, "\n")

# Part 2: split Oldpeak into "was there any drop?" and keep the size, then score the model again.
def with_drop_flag(table):
    return table.assign(any_drop=(table["Oldpeak"] > 0).astype(int))

def make_model_with(extra):
    number_steps = Pipeline([("impute", SimpleImputer(strategy="median", add_indicator=True)),
                             ("scale", StandardScaler())])
    prepare = ColumnTransformer([("num", number_steps, numbers + extra),
                                 ("cat", OneHotEncoder(handle_unknown="ignore"), categories)])
    return Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=2000))])

candidates = [("as in Question 16", [], train),
              ("with any_drop added", ["any_drop"], with_drop_flag(train))]
for label, extra, table in candidates:
    X = table[numbers + extra + categories]
    scores = cross_val_score(make_model_with(extra), X, y_train, cv=folds, scoring="accuracy")
    print(f"{label:22s} accuracy {scores.mean():.3f} (+/- {scores.std():.3f})")
print("disease rate with no drop:", round(train.loc[train["Oldpeak"] <= 0, target].mean(), 3),
      "  with a drop:", round(train.loc[train["Oldpeak"] > 0, target].mean(), 3))
