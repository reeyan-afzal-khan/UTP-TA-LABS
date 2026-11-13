"""The data toolkit of Chapter 3: NumPy, pandas and Matplotlib on the study log and one real table.

The chapter prints these blocks and their output. Each block is a few lines you can paste into
a notebook cell; the asserts at the end tie the printed book to this code.

Run from the course folder:      python all_experiments/book_checks/demo_data_toolkit.py
It reads all_datasets/supervised/telco_customer_churn/ and takes a few seconds.
"""
from pathlib import Path
import time

import numpy as np
import pandas as pd

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
np.set_printoptions(precision=2, suppress=True, linewidth=110)
pd.set_option("display.width", 110)

# ------------------------------------------------------------------ NumPy: arrays
# A list holds the marks; an array holds them and can do arithmetic on all of them at once.
marks_list = [47, 50, 59, 65, 68, 77, 62, 52, 43, 38]
mark = np.array(marks_list)
print("list * 2 repeats the list:", len(marks_list * 2), "items")
print("array * 2 doubles each mark:", mark * 2)
print("marks above the mean:", mark - mark.mean())

# One million numbers, squared and summed: a Python loop against one array expression.
big = np.arange(1_000_000, dtype=float)
start = time.perf_counter()
total_loop = 0.0
for value in big:
    total_loop += value * value
loop_seconds = time.perf_counter() - start
start = time.perf_counter()
total_array = (big * big).sum()
array_seconds = time.perf_counter() - start
print(f"loop {loop_seconds:.3f}s, array {array_seconds:.4f}s, same answer: {np.isclose(total_loop, total_array)}")

# Ways to make an array.
print(np.zeros(3), np.ones(3), np.arange(0, 10, 2), np.linspace(0, 1, 5))
rng = np.random.default_rng(42)              # a seeded generator: the same "random" numbers on every run
print("three random draws:", rng.normal(size=3).round(3))

# The whole study log as one array: ten rows (students), four columns.
LOG = np.array([
    [ 2,  8, 8, 47], [ 4,  6, 8, 50], [ 6,  7, 7, 59], [ 8,  9, 7, 65], [10, 11, 7, 68],
    [12, 13, 6, 77], [14, 12, 5, 62], [16, 10, 4, 52], [18,  5, 3, 43], [20,  3, 2, 38],
])
print("shape:", LOG.shape, " dimensions:", LOG.ndim, " type of each number:", LOG.dtype)

# Indexing is [row, column], counting from 0. A colon means "all of them".
print("student F:", LOG[5])
print("F's mark:", LOG[5, 3])
print("everyone's hours:", LOG[:, 0])
print("first three students, hours and mark:", LOG[:3, [0, 3]].tolist())

# A condition gives one True or False per row: a mask. A mask picks rows.
hours, lectures, sleep, mark = LOG.T          # .T swaps rows and columns, so this unpacks the four columns
long_hours = hours > 10
print("mask:", long_hours)
print("marks of those who studied more than 10 hours:", mark[long_hours], " mean:", mark[long_hours].mean())
print("how many passed:", (mark >= 50).sum(), " share:", (mark >= 50).mean())

# axis=0 runs down the rows and leaves one answer per column; axis=1 leaves one per row.
print("column means:", LOG.mean(axis=0))
print("best mark is in row", mark.argmax(), " rows from lowest to highest mark:", mark.argsort())

# Broadcasting: a (10, 4) table minus a (4,) row of means subtracts each column's own mean.
z = (LOG - LOG.mean(axis=0)) / LOG.std(axis=0)
print("standardized F:", z[5])
print("every column now has mean", z.mean(axis=0).round(10).tolist(), "and sd", z.std(axis=0).tolist())

# A slice is a view of the same memory, not a copy.
first_three = LOG[:3, 3]
safe = LOG[:3, 3].copy()
first_three[0] = 99                          # this writes into LOG as well
print("LOG changed too:", LOG[0, 3], " the copy did not:", safe[0])
LOG[0, 3] = 47                               # put student A's mark back

# ------------------------------------------------------------------ pandas: tables with names
log = pd.DataFrame(LOG, columns=["hours", "lectures", "sleep", "mark"], index=list("ABCDEFGHIJ"))
log["passed"] = log["mark"] >= 50            # a new column from a condition
print(log.head(3))
print(log.describe().loc[["mean", "std", "min", "max"]].round(2))

# One column is a Series; a list of columns is a smaller table.
print(type(log["mark"]).__name__, type(log[["hours", "mark"]]).__name__)

# Rows by condition, rows by label (loc), rows by position (iloc).
print(log[(log["hours"] > 10) & (log["mark"] >= 50)])
print(log.loc["F", "mark"], log.iloc[5, 3], log.loc[["A", "J"], ["hours", "mark"]].to_dict("index"))

# Sorting, and the top rows.
print(log.sort_values("mark", ascending=False).head(3).index.tolist(), log.nlargest(2, "sleep").index.tolist())

# Split the rows into groups, summarize each group, combine the answers.
by_result = log.groupby("passed")[["hours", "lectures", "sleep"]].mean().round(2)
print(by_result)

# ------------------------------------------------------------------ a real table
churn = pd.read_csv(DATA / "supervised/telco_customer_churn/telco_customer_churn.csv")
print(churn.shape)
print(churn[["tenure", "Contract", "MonthlyCharges", "TotalCharges", "Churn"]].head(3))
print(churn["Contract"].value_counts())

# Text that should be a number: convert, and see what would not convert.
total = pd.to_numeric(churn["TotalCharges"], errors="coerce")
print("cells that are not numbers:", total.isna().sum())
churn["TotalCharges"] = total.fillna(0)
churn["left"] = (churn["Churn"] == "Yes").astype(int)

# One number per group, then several numbers per group.
rate_by_contract = churn.groupby("Contract")["left"].mean().round(3)
print(rate_by_contract)
summary = churn.groupby("Contract").agg(customers=("left", "size"), churn_rate=("left", "mean"),
                                        median_tenure=("tenure", "median"), mean_monthly=("MonthlyCharges", "mean"))
print(summary.round(2))

# Two grouping columns at once: rows are one, columns are the other.
table = churn.pivot_table(index="Contract", columns="InternetService", values="left", aggfunc="mean").round(3)
print(table)

# Cut a number into bands, then group by the bands.
bands = pd.cut(churn["tenure"], [-1, 12, 24, 48, 72], labels=["0-12", "13-24", "25-48", "49-72"])
rate_by_band = churn.groupby(bands, observed=True)["left"].mean().round(3)
print(rate_by_band)

# transform() gives every row its own group's answer, so a row can be compared with its group.
churn["contract_mean_charge"] = churn.groupby("Contract")["MonthlyCharges"].transform("mean")
churn["above_contract_mean"] = churn["MonthlyCharges"] > churn["contract_mean_charge"]
print(churn["above_contract_mean"].mean().round(3))

# A histogram is a count per band: here, customers per $10 of monthly charge, from $15 to $125.
counts, edges = np.histogram(churn["MonthlyCharges"], bins=np.arange(15, 126, 10))
print("customers per $10 band:", counts.tolist())

# Joining two tables on a shared column. The lookup has one row per contract type.
notice = pd.DataFrame({"Contract": ["Month-to-month", "One year", "Two year"], "notice_days": [30, 60, 90]})
joined = churn.merge(notice, on="Contract", how="left")
print(len(churn), len(joined), joined["notice_days"].isna().sum())

# The join that goes wrong: a lookup with a repeated key multiplies the rows.
bad_lookup = pd.concat([notice, notice.iloc[[0]]])          # "Month-to-month" appears twice
print(len(churn.merge(bad_lookup, on="Contract", how="left")))

# ------------------------------------------------------------------ from a table to a model
from sklearn.linear_model import LinearRegression

X = log.loc["A":"F", ["hours"]]              # features: a table, even with one column
y = log.loc["A":"F", "mark"]                 # target: one column
model = LinearRegression().fit(X, y)         # fit learns the numbers
print("slope", model.coef_[0].round(2), "intercept", model.intercept_.round(2))
print("mark expected after 9 hours:", model.predict(pd.DataFrame({"hours": [9]}))[0].round(1))

# ------------------------------------------------------------------ the chart of the chapter
def draw_charts(folder):
    """The five everyday charts, on the Telco table. Saves one PNG; nothing in the book depends on it."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(1, 5, figsize=(17, 3.2))
    axes[0].hist(churn["MonthlyCharges"], bins=30)
    axes[0].set_title("histogram: one number's shape")
    rate_by_contract.plot.bar(ax=axes[1], rot=20)
    axes[1].set_title("bar: one number per group")
    churn.boxplot(column="MonthlyCharges", by="Contract", ax=axes[2], rot=20)
    axes[2].set_title("box: spread within groups")
    axes[3].scatter(churn["tenure"], churn["TotalCharges"], s=3)
    axes[3].set_title("scatter: two numbers together")
    churn.groupby("tenure")["left"].mean().plot(ax=axes[4])
    axes[4].set_title("line: a number along an order")
    fig.suptitle("")
    fig.tight_layout()
    fig.savefig(Path(folder) / "five_everyday_charts.png", dpi=120)


if CHECK_BOOK_NUMBERS:
    assert mark[long_hours].tolist() == [77, 62, 52, 43, 38] and np.isclose(mark[long_hours].mean(), 54.4)
    assert (mark >= 50).sum() == 7 and LOG.mean(axis=0).tolist() == [11.0, 8.4, 5.7, 56.1]
    assert mark.argmax() == 5 and mark.argsort().tolist() == [9, 8, 0, 1, 7, 2, 6, 3, 4, 5]
    assert np.allclose(z[5], [0.17, 1.51, 0.15, 1.81], atol=0.005)
    assert array_seconds * 10 < loop_seconds and np.isclose(total_loop, total_array)
    assert log[(log["hours"] > 10) & (log["mark"] >= 50)].index.tolist() == ["F", "G", "H"]
    assert by_result.loc[True].tolist() == [10.0, 9.71, 6.29] and by_result.loc[False].tolist() == [13.33, 5.33, 4.33]
    assert churn.shape[0] == 7043 and total.isna().sum() == 11
    assert rate_by_contract.tolist() == [0.427, 0.113, 0.028]
    assert summary["customers"].tolist() == [3875, 1473, 1695] and summary["median_tenure"].tolist() == [12.0, 44.0, 64.0]
    assert np.allclose(summary["mean_monthly"], [66.40, 65.05, 60.77], atol=0.005)
    assert table.loc["Month-to-month", "Fiber optic"] == 0.546 and table.loc["Two year", "No"] == 0.008
    assert rate_by_band.tolist() == [0.474, 0.287, 0.204, 0.095]
    assert counts.tolist() == [1389, 342, 288, 601, 519, 776, 932, 888, 782, 461, 65] and counts.sum() == 7043
    assert len(joined) == 7043 and len(churn.merge(bad_lookup, on="Contract", how="left")) == 7043 + 3875
    assert model.coef_[0].round(2) == 3.0 and model.intercept_.round(2) == 40.0
    assert churn["above_contract_mean"].mean().round(3) == 0.557
    print("\nEvery number above matches the book.")
