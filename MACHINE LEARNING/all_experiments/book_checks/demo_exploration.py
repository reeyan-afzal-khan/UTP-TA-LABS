"""Exploring a table before modelling it: the worked numbers of Chapters 7, 8 and 9.

Chapter 7 explores the heart-disease table, Chapter 8 tests whether its patterns could be chance,
and Chapter 9 engineers features. Each function prints what its chapter quotes, and
check_book_numbers() at the end ties the printed book to this code.

Run from the course folder:      python all_experiments/book_checks/demo_exploration.py
It reads all_datasets/supervised/ and takes under a minute.
"""
from math import comb
from pathlib import Path

import numpy as np
import pandas as pd
from scipy import stats
from sklearn.compose import ColumnTransformer
from sklearn.feature_selection import f_classif
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression, Ridge
from sklearn.metrics import accuracy_score, confusion_matrix, log_loss, mean_absolute_error, roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, PowerTransformer, StandardScaler, TargetEncoder
from sklearn.tree import DecisionTreeClassifier

DATA = Path(__file__).resolve().parents[2] / "all_datasets"
CHECK_BOOK_NUMBERS = True
FOUND = {}          # every value the asserts below check
NUMBERS = ["Age", "RestingBP", "Cholesterol", "MaxHR", "Oldpeak"]
CATEGORIES = ["Sex", "ChestPainType", "FastingBS", "RestingECG", "ExerciseAngina", "ST_Slope"]
pd.set_option("display.width", 120)


# ------------------------------------------------------- Chapter 7: exploratory data analysis
def first_look(heart):
    """Size, types, and the two summaries that expose a column lying about itself."""
    print("shape:", heart.shape, " blank cells:", int(heart.isna().sum().sum()),
          " repeated rows:", int(heart.duplicated().sum()))
    print("distinct values:", heart.nunique().to_dict())
    print(heart[NUMBERS].describe().loc[["min", "50%", "max"]].round(1))
    zeros = (heart[["RestingBP", "Cholesterol"]] == 0).sum()
    print("zeros:", zeros.to_dict(), " negative Oldpeak:", int((heart["Oldpeak"] < 0).sum()))
    FOUND["zeros"] = zeros.to_dict()


def mark_missing(heart):
    """A fixed rule from the data card: a blood pressure or cholesterol of 0 was never measured."""
    cleaned = heart.copy()
    for column in ["RestingBP", "Cholesterol"]:
        cleaned[column] = cleaned[column].replace(0, np.nan)
    return cleaned


def five_numbers(values):
    """Minimum, quartiles and maximum, the fences 1.5 IQR beyond the box, and how many values lie outside."""
    values = values.dropna()
    q1, median, q3 = values.quantile([0.25, 0.50, 0.75])
    low_fence, high_fence = q1 - 1.5 * (q3 - q1), q3 + 1.5 * (q3 - q1)
    outside = int(((values < low_fence) | (values > high_fence)).sum())
    return {"min": values.min(), "q1": q1, "median": median, "q3": q3, "max": values.max(),
            "low_fence": low_fence, "high_fence": high_fence, "outside": outside}


def one_column_at_a_time(raw, train):
    print("\nCholesterol with the zeros:   ", raw["Cholesterol"].describe().loc[["mean", "50%", "min"]].round(1).to_dict(),
          " skew", round(raw["Cholesterol"].skew(), 2))
    print("Cholesterol, zeros as missing:", train["Cholesterol"].describe().loc[["count", "mean", "50%", "min"]].round(1).to_dict(),
          " skew", round(train["Cholesterol"].skew(), 2))
    print("patients per 50 mg/dl, from 0:", np.histogram(raw["Cholesterol"], bins=np.arange(0, 651, 50))[0].tolist())
    FOUND["chol_hist"] = np.histogram(raw["Cholesterol"], bins=np.arange(0, 651, 50))[0].tolist()
    FOUND["chol_skew"] = (raw["Cholesterol"].skew(), train["Cholesterol"].skew())
    FOUND["chol_mean"] = (raw["Cholesterol"].mean(), train["Cholesterol"].mean())
    for column in NUMBERS:
        summary = five_numbers(train[column])
        z = (train[column] - train[column].mean()) / train[column].std()
        summary["beyond_3_sd"] = int((z.abs() > 3).sum())
        print(f"{column:12s}", {key: round(float(value), 2) for key, value in summary.items()})
        FOUND["five_" + column] = summary
    print("skew:", train[NUMBERS].skew().round(2).to_dict(), " share of Oldpeak that is exactly 0:",
          round((train["Oldpeak"] == 0).mean(), 3))
    FOUND["skew"], FOUND["oldpeak_zero"] = train[NUMBERS].skew(), (train["Oldpeak"] == 0).mean()
    # A box plot's whiskers stop at the last measured values inside the fences.
    cholesterol, box = train["Cholesterol"].dropna(), FOUND["five_Cholesterol"]
    inside = cholesterol[(cholesterol >= box["low_fence"]) & (cholesterol <= box["high_fence"])]
    FOUND["whiskers"] = (inside.min(), inside.max(), int((cholesterol < box["low_fence"]).sum()),
                         int((cholesterol > box["high_fence"]).sum()))
    print("cholesterol whiskers end at", FOUND["whiskers"][:2], " values below and above the fences:", FOUND["whiskers"][2:])
    outside = cholesterol[(cholesterol < box["low_fence"]) | (cholesterol > box["high_fence"])]
    FOUND["chol_outside"] = sorted(outside.astype(int).tolist())
    print("the values outside:", FOUND["chol_outside"])


def against_the_target(train):
    """One feature at a time against the label: averages for numbers, rates with counts for categories."""
    means = train.groupby("HeartDisease")[NUMBERS].mean().round(2)
    print("\n", means)
    FOUND["means"] = means
    for column in CATEGORIES:
        table = train.groupby(column)["HeartDisease"].agg(patients="size", disease_rate="mean").round(3)
        print(column, table.to_dict("index"))
        FOUND["rate_" + column] = table
    # How far could a rate measured on 40 patients be from the truth? Two standard errors either way.
    typical = FOUND["rate_ChestPainType"].loc["TA"]
    margin = 1.96 * np.sqrt(typical["disease_rate"] * (1 - typical["disease_rate"]) / typical["patients"])
    print(f"typical angina: {typical['disease_rate']:.2f} on {typical['patients']:.0f} patients, give or take {margin:.2f}")
    FOUND["ta_margin"] = margin
    for label in (0, 1):
        counts = np.histogram(train.loc[train["HeartDisease"] == label, "MaxHR"], bins=np.arange(60, 211, 15))[0]
        print("MaxHR per 15 beats, disease =", label, counts.tolist())
        FOUND[f"maxhr_{label}"] = counts.tolist()
    unmeasured = train["Cholesterol"].isna()
    rates = (train.loc[unmeasured, "HeartDisease"].mean(), train.loc[~unmeasured, "HeartDisease"].mean())
    print(f"disease rate when cholesterol was not measured {rates[0]:.3f}, when it was {rates[1]:.3f}")
    FOUND["unmeasured"] = (int(unmeasured.sum()), *rates)


def between_columns(raw, train):
    """Correlations with the zeros left in, and with the zeros marked as missing."""
    with_zeros = raw[NUMBERS + ["HeartDisease"]].corr().round(2)
    as_missing = train[NUMBERS + ["HeartDisease"]].corr().round(2)
    print("\nwith the zeros left in:\n", with_zeros)
    print("zeros marked as missing:\n", as_missing)
    FOUND["corr_zero"], FOUND["corr_nan"] = with_zeros, as_missing


def make_model(indicator):
    """Fill gaps with the median, scale the numbers, one-hot encode the categories, fit a logistic regression."""
    numbers = Pipeline([("impute", SimpleImputer(strategy="median", add_indicator=indicator)),
                        ("scale", StandardScaler())])
    prepare = ColumnTransformer([("num", numbers, NUMBERS),
                                 ("cat", OneHotEncoder(handle_unknown="ignore"), CATEGORIES)])
    return Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=2000))])


def first_models(raw_train, train, test):
    y = train["HeartDisease"]
    majority = max(y.mean(), 1 - y.mean())
    one_rule = ((train["ST_Slope"] != "Up").astype(int) == y).mean()       # "disease unless the slope is Up"
    print(f"\nalways say disease: {majority:.3f}   one rule on ST_Slope: {one_rule:.3f}")
    FOUND["majority"], FOUND["one_rule"] = majority, one_rule

    folds = StratifiedKFold(5, shuffle=True, random_state=42)
    versions = {"zeros left in": (raw_train, False), "zeros as missing": (train, False),
                "zeros as missing + flag": (train, True)}
    for name, (table, indicator) in versions.items():
        X = table.drop(columns="HeartDisease")
        accuracy = cross_val_score(make_model(indicator), X, y, cv=folds, scoring="accuracy")
        auc = cross_val_score(make_model(indicator), X, y, cv=folds, scoring="roc_auc")
        fitted = make_model(indicator).fit(X, y)
        names = fitted.named_steps["prepare"].get_feature_names_out()
        weights = pd.Series(fitted.named_steps["model"].coef_[0], index=names)
        cholesterol = weights.filter(like="Cholesterol").round(2).to_dict()
        print(f"{name:24s} accuracy {accuracy.mean():.3f} (+/- {accuracy.std():.3f})  ROC AUC {auc.mean():.3f}  "
              f"weights {cholesterol}")
        FOUND[name] = (accuracy.mean(), accuracy.std(), auc.mean(), cholesterol)

    final = make_model(True).fit(train.drop(columns="HeartDisease"), y)
    chance = final.predict_proba(test.drop(columns="HeartDisease"))[:, 1]
    matrix = confusion_matrix(test["HeartDisease"], chance >= 0.5)
    print(f"sealed test set: accuracy {accuracy_score(test['HeartDisease'], chance >= 0.5):.3f}, "
          f"ROC AUC {roc_auc_score(test['HeartDisease'], chance):.3f}, confusion matrix {matrix.tolist()}")
    FOUND["test"] = (accuracy_score(test["HeartDisease"], chance >= 0.5), roc_auc_score(test["HeartDisease"], chance),
                     matrix.tolist())


def chapter07():
    print("Chapter 7")
    heart = pd.read_csv(DATA / "supervised/heart_disease/heart_disease.csv")
    first_look(heart)
    cleaned = mark_missing(heart)
    # Seal a test set before looking at any relationship with the label.
    train_rows, test_rows = train_test_split(heart.index, test_size=0.2, random_state=42, stratify=heart["HeartDisease"])
    raw_train, train, test = heart.loc[train_rows], cleaned.loc[train_rows], cleaned.loc[test_rows]
    print("training rows:", len(train), " test rows:", len(test), " disease rate in training:", round(train["HeartDisease"].mean(), 3))
    FOUND["split"] = (len(train), len(test), train["HeartDisease"].mean())
    one_column_at_a_time(raw_train, train)
    against_the_target(train)
    between_columns(raw_train, train)
    first_models(raw_train, train, test)


# ------------------------------------------------------- Chapter 8: distributions and hypothesis tests
def heart_training_rows():
    """The 734 training patients of Chapter 7, with the impossible zeros marked as missing."""
    heart = mark_missing(pd.read_csv(DATA / "supervised/heart_disease/heart_disease.csv"))
    rows, _ = train_test_split(heart.index, test_size=0.2, random_state=42, stratify=heart["HeartDisease"])
    return heart.loc[rows]


def shuffle_test(values, labels, shuffles=10_000, seed=42):
    """How often does shuffling the labels give a gap between the two group means as large as the real one?"""
    rng = np.random.default_rng(seed)
    measured = ~np.isnan(values)
    values, labels = values[measured], labels[measured]
    real_gap = values[labels == 1].mean() - values[labels == 0].mean()
    gaps = np.empty(shuffles)
    for i in range(shuffles):
        mixed = rng.permutation(labels)                    # the sceptic's world: the labels mean nothing
        gaps[i] = values[mixed == 1].mean() - values[mixed == 0].mean()
    p_value = (np.abs(gaps) >= abs(real_gap)).mean()
    return real_gap, gaps, p_value


def welch_by_hand(values, labels):
    """The two-sample t statistic: the gap between the means, counted in standard errors."""
    a, b = values[labels == 1], values[labels == 0]
    a, b = a[~np.isnan(a)], b[~np.isnan(b)]
    gap = a.mean() - b.mean()
    standard_error = np.sqrt(a.var(ddof=1) / len(a) + b.var(ddof=1) / len(b))
    return gap, standard_error, gap / standard_error


def chi_square_by_hand(observed):
    """Expected counts if the two columns were unrelated, and the total of (observed - expected)^2 / expected."""
    observed = np.asarray(observed, dtype=float)
    row_totals, column_totals = observed.sum(axis=1, keepdims=True), observed.sum(axis=0, keepdims=True)
    expected = row_totals * column_totals / observed.sum()
    terms = (observed - expected) ** 2 / expected
    return expected, terms, terms.sum()


def anova_by_hand(groups):
    """F: how far the group means are from each other, compared with how far the values are from their own group mean."""
    everything = np.concatenate(groups)
    between = sum(len(g) * (g.mean() - everything.mean()) ** 2 for g in groups)
    within = sum(((g - g.mean()) ** 2).sum() for g in groups)
    mean_between, mean_within = between / (len(groups) - 1), within / (len(everything) - len(groups))
    return between, within, mean_between, mean_within, mean_between / mean_within


def chapter08():
    print("\nChapter 8")
    # A coin lands heads 8 times in 10. In a fair-coin world, how often would it do at least that?
    at_least_8 = sum(comb(10, k) for k in (8, 9, 10)) / 2 ** 10
    print(f"fair coin, 8 or more heads in 10: {at_least_8:.4f}; that far from 5 in either direction: {2 * at_least_8:.4f}")
    FOUND["coin"] = at_least_8

    train = heart_training_rows()
    labels = train["HeartDisease"].to_numpy()
    for column in ["MaxHR", "RestingBP", "Cholesterol"]:
        values = train[column].to_numpy(dtype=float)
        gap, gaps, p_shuffle = shuffle_test(values, labels)
        _, standard_error, t = welch_by_hand(values, labels)
        p_formula = stats.ttest_ind(values[labels == 1], values[labels == 0], equal_var=False, nan_policy="omit").pvalue
        low, high = gap - 1.96 * standard_error, gap + 1.96 * standard_error
        print(f"{column:12s} gap {gap:7.2f}  largest shuffled gap {np.abs(gaps).max():5.2f}  shuffle p {p_shuffle:.4f}  "
              f"SE {standard_error:.3f}  t {t:6.2f}  formula p {p_formula:.2g}  95% interval {low:.1f} to {high:.1f}")
        FOUND["test_" + column] = (gap, np.abs(gaps).max(), p_shuffle, standard_error, t, p_formula, low, high)
        if column == "Cholesterol":
            counts = np.histogram(gaps, bins=np.arange(-18, 18.1, 3))[0].tolist()
            print("   shuffled cholesterol gaps, in bands of 3 from -18:", counts, " spread", round(gaps.std(), 2))
            FOUND["shuffled_gaps"] = counts

    # The central limit theorem on a skewed column: lead times of 119,390 hotel bookings.
    lead = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")["lead_time"].to_numpy(dtype=float)
    rng = np.random.default_rng(7)
    print(f"lead time: mean {lead.mean():.1f}, sd {lead.std():.1f}, skew {stats.skew(lead):.2f}")
    FOUND["lead"] = (lead.mean(), lead.std())
    for n in (1, 10, 50):
        means = rng.choice(lead, size=(10_000, n)).mean(axis=1)             # 10,000 samples of n bookings each
        counts = np.histogram(means, bins=np.arange(0, 401, 25))[0].tolist()
        print(f"  means of {n:2d} bookings: spread {means.std():6.2f}  sd/sqrt(n) {lead.std() / np.sqrt(n):6.2f}  "
              f"skew {stats.skew(means):.2f}  per 25 days {counts}")
        FOUND[f"clt_{n}"] = (means.std(), lead.std() / np.sqrt(n), stats.skew(means), counts)

    # Chi-square: are sex and heart disease related?
    observed = pd.crosstab(train["Sex"], train["HeartDisease"])
    expected, terms, chi_square = chi_square_by_hand(observed)
    library = stats.chi2_contingency(observed, correction=False)
    print("observed:", observed.to_numpy().tolist(), " expected:", expected.round(1).tolist(),
          " terms:", terms.round(2).tolist(), f" chi-square {chi_square:.2f}, p {library.pvalue:.1e}")
    FOUND["chi"] = (observed.to_numpy().tolist(), expected.round(1).tolist(), terms.round(2).tolist(), chi_square, library.statistic)
    others = {c: stats.chi2_contingency(pd.crosstab(train[c], train["HeartDisease"]), correction=False)
              for c in ["ST_Slope", "ChestPainType", "ExerciseAngina", "FastingBS", "RestingECG"]}
    print("chi-square of the other categories:", {c: (round(r.statistic, 1), r.dof, float(f"{r.pvalue:.2g}")) for c, r in others.items()})
    FOUND["chi_others"] = {c: round(r.statistic, 1) for c, r in others.items()}
    FOUND["chi_ecg_p"] = others["RestingECG"].pvalue

    # ANOVA: does the highest heart rate differ between the four chest pain types?
    by_pain = {name: group["MaxHR"].to_numpy(dtype=float) for name, group in train.groupby("ChestPainType")}
    between, within, mean_between, mean_within, f = anova_by_hand(list(by_pain.values()))
    print("MaxHR by chest pain:", {name: (len(g), round(g.mean(), 1)) for name, g in by_pain.items()},
          f" between {between:,.0f}  within {within:,.0f}  F = {mean_between:,.1f} / {mean_within:.1f} = {f:.2f}  "
          f"p {stats.f_oneway(*by_pain.values()).pvalue:.1e}")
    FOUND["anova"] = ({name: (len(g), round(g.mean(), 1)) for name, g in by_pain.items()}, between, within, mean_between, mean_within, f)
    # The F score scikit-learn's f_classif gives a feature is this same ANOVA, with the target's classes as the groups.
    scores, _ = f_classif(train[["Age", "MaxHR", "Oldpeak"]], labels)
    print("f_classif scores against the target:", dict(zip(["Age", "MaxHR", "Oldpeak"], scores.round(1))))
    FOUND["f_classif"] = scores.round(1).tolist()

    # Significant is not the same as large: 119,390 bookings make tiny gaps "significant".
    hotel = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
    for column in ["stays_in_week_nights", "arrival_date_day_of_month"]:
        kept, cancelled = hotel.loc[hotel["is_canceled"] == 0, column], hotel.loc[hotel["is_canceled"] == 1, column]
        result = stats.ttest_ind(cancelled, kept, equal_var=False)
        size = (cancelled.mean() - kept.mean()) / hotel[column].std()
        print(f"{column}: kept {kept.mean():.3f}, cancelled {cancelled.mean():.3f}, p {result.pvalue:.1e}, "
              f"gap in standard deviations {size:.3f}")
        FOUND["big_" + column] = (kept.mean(), cancelled.mean(), result.pvalue, size)

    # Test enough columns and some will pass by luck: 1,000 columns of noise against coin-flip labels.
    rng = np.random.default_rng(7)
    noise, flips = rng.normal(size=(100, 1000)), rng.integers(0, 2, size=100)
    p_values = np.array([stats.ttest_ind(noise[flips == 1, j], noise[flips == 0, j]).pvalue for j in range(1000)])
    print(f"noise columns with p < 0.05: {(p_values < 0.05).sum()}, smallest p {p_values.min():.4f}, "
          f"below 0.05/1000: {(p_values < 0.05 / 1000).sum()}")
    FOUND["noise"] = (int((p_values < 0.05).sum()), p_values.min(), int((p_values < 0.05 / 1000).sum()))

    # The four distributions drawn in the chapter.
    binomial = [comb(10, k) / 2 ** 10 for k in range(11)]
    poisson = [float(stats.poisson.pmf(k, 3)) for k in range(10)]
    print("binomial(10, 0.5):", np.round(binomial, 4).tolist())
    print("Poisson(3):", np.round(poisson, 4).tolist())
    FOUND["binomial"], FOUND["poisson"] = binomial, poisson


# ------------------------------------------------------- Chapter 9: feature engineering
def one_feature_model(train_columns, valid_columns, y_train, y_valid, categories=False):
    """A logistic regression on the given columns: validation ROC AUC and log loss."""
    prepare = OneHotEncoder(handle_unknown="ignore") if categories else StandardScaler()
    model = Pipeline([("prepare", prepare), ("model", LogisticRegression(max_iter=3000))]).fit(train_columns, y_train)
    chance = model.predict_proba(valid_columns)[:, 1]
    return roc_auc_score(y_valid, chance), log_loss(y_valid, chance)


def used_car_listings():
    """Lab 2's used cars: the same fixed cleaning rules, the same split."""
    cars = pd.read_csv(DATA / "supervised/used_cars/used_cars.zip", low_memory=False)
    used = cars[(cars["stock_type"] == "Used") & cars["price_usd"].between(1_000, 200_000)
                & (cars["mileage_miles"] > 100)].copy()

    def tidy(column, groups):
        text = column.str.lower()
        matches = [text.str.contains(pattern, na=False) for pattern in groups.values()]
        return pd.Series(np.select(matches, list(groups), default=None), index=column.index)

    used["drive"] = tidy(used["drivetrain"], {"AWD": "all|awd", "4WD": "four|4wd|4x4", "FWD": "front|fwd", "RWD": "rear|rwd"})
    used["fuel_type"] = tidy(used["fuel"], {"plug-in hybrid": "plug", "hybrid": "hybrid|mild", "electric": "electric",
                                            "diesel": "diesel", "flex fuel": "flex|e85", "gasoline": "gas|petrol|unleaded"})
    used["age"] = (2026 - used["year"]).clip(lower=0)
    features = used[["age", "mileage_miles", "make", "body_type", "drive", "fuel_type", "model"]]
    return train_test_split(features, used["price_usd"], test_size=0.20, random_state=42)


CAR_NUMBERS, CAR_CATEGORIES = ["age", "mileage_miles"], ["make", "body_type", "drive", "fuel_type"]


def car_preparation(numbers, categories, extra_steps=()):
    """Median fill and scaling for numbers, most-frequent fill and one-hot for categories, plus any extra steps."""
    number_steps = Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())])
    category_steps = Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                               ("onehot", OneHotEncoder(handle_unknown="ignore"))])
    return ColumnTransformer([("num", number_steps, numbers), ("cat", category_steps, categories), *extra_steps])


def price_model(prepare, X_train, y_train, X_valid, y_valid, log_target=True):
    """Ridge on the price or on its logarithm. Returns the validation MAE in dollars and the predictions."""
    model = Pipeline([("prepare", prepare), ("model", Ridge(alpha=10.0))])
    model.fit(X_train, np.log(y_train) if log_target else y_train)
    predicted = model.predict(X_valid)
    predicted = np.exp(predicted) if log_target else predicted
    return mean_absolute_error(y_valid, predicted), predicted, model


def add_car_features(table):
    """Three engineered columns, each computed from the listing's own fields."""
    return table.assign(age_squared=table["age"] ** 2,
                        miles_per_year=table["mileage_miles"] / (table["age"] + 1),
                        log_mileage=np.log(table["mileage_miles"]))


def chapter09():
    print("\nChapter 9")
    # --- hotel bookings: what a linear model can and cannot use
    hotel = pd.read_csv(DATA / "supervised/hotel_bookings/hotel_bookings.zip")
    hotel["total_nights"] = hotel["stays_in_weekend_nights"] + hotel["stays_in_week_nights"]
    months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
              "November", "December"]
    hotel["month"] = hotel["arrival_date_month"].map({name: i + 1 for i, name in enumerate(months)})
    cancelled = hotel["is_canceled"]
    train, valid = train_test_split(hotel.index, test_size=0.25, random_state=42, stratify=cancelled)
    y_train, y_valid = cancelled.loc[train], cancelled.loc[valid]

    by_nights = hotel.groupby(hotel["total_nights"].clip(upper=8))["is_canceled"].mean().round(3)
    print("cancellation rate by nights (8 = eight or more):", by_nights.to_dict())
    FOUND["by_nights"] = by_nights.tolist()
    nights = hotel[["total_nights"]]
    bands = nights.clip(upper=8).astype(str)
    as_number = one_feature_model(nights.loc[train], nights.loc[valid], y_train, y_valid)
    as_bands = one_feature_model(bands.loc[train], bands.loc[valid], y_train, y_valid, categories=True)
    tree = DecisionTreeClassifier(max_depth=4, random_state=0).fit(nights.loc[train], y_train)
    as_tree = roc_auc_score(y_valid, tree.predict_proba(nights.loc[valid])[:, 1])
    print(f"nights in a logistic model: as a number AUC {as_number[0]:.3f}, as bands {as_bands[0]:.3f}; "
          f"a small tree on the number {as_tree:.3f}")
    FOUND["nights"] = (as_number[0], as_bands[0], as_tree)

    lead = hotel[["lead_time"]]
    log_lead = np.log1p(lead)
    raw_score = one_feature_model(lead.loc[train], lead.loc[valid], y_train, y_valid)
    log_score = one_feature_model(log_lead.loc[train], log_lead.loc[valid], y_train, y_valid)
    print(f"lead time: raw AUC {raw_score[0]:.3f} log loss {raw_score[1]:.4f}; log AUC {log_score[0]:.3f} log loss {log_score[1]:.4f}")
    FOUND["lead_model"] = (*raw_score, *log_score)

    by_month = hotel.groupby("month")["is_canceled"].mean().round(3)
    print("cancellation rate by month:", by_month.to_dict())
    month = hotel[["month"]]
    circle = pd.DataFrame({"sin": np.sin(2 * np.pi * hotel["month"] / 12), "cos": np.cos(2 * np.pi * hotel["month"] / 12)})
    scores = {"number": one_feature_model(month.loc[train], month.loc[valid], y_train, y_valid)[0],
              "circle": one_feature_model(circle.loc[train], circle.loc[valid], y_train, y_valid)[0],
              "one-hot": one_feature_model(month.astype(str).loc[train], month.astype(str).loc[valid], y_train, y_valid, True)[0]}
    print("month in a logistic model, AUC:", {k: round(v, 3) for k, v in scores.items()})
    FOUND["month"] = scores
    position = lambda m: np.array([np.sin(2 * np.pi * m / 12), np.cos(2 * np.pi * m / 12)])
    december_january = np.linalg.norm(position(12) - position(1))
    december_june = np.linalg.norm(position(12) - position(6))
    print(f"on the circle: December to January {december_january:.3f}, December to June {december_june:.3f}; "
          f"as numbers: {12 - 1} and {12 - 6}")
    FOUND["circle"] = (december_january, december_june)
    agents = hotel["agent"].value_counts()
    print(f"agent: {hotel['agent'].nunique()} distinct values, {(agents < 20).sum()} of them with fewer than 20 bookings")
    FOUND["agent"] = (hotel["agent"].nunique(), int((agents < 20).sum()))

    # --- used cars: the target, the shape of a number, new columns, and a category with a thousand values
    X_train, X_valid, y_train, y_valid = used_car_listings()
    print(f"used cars: {len(X_train):,} to train on, {len(X_valid):,} to validate; price skew {y_train.skew():.2f}, "
          f"log price skew {np.log(y_train).skew():.2f}; median ${y_train.median():,.0f}, mean ${y_train.mean():,.0f}")
    FOUND["cars"] = (len(X_train), len(X_valid), y_train.skew(), np.log(y_train).skew())

    plain = car_preparation(CAR_NUMBERS, CAR_CATEGORIES)
    raw_mae, raw_predicted, _ = price_model(plain, X_train, y_train, X_valid, y_valid, log_target=False)
    log_mae, log_predicted, _ = price_model(plain, X_train, y_train, X_valid, y_valid)
    percent = lambda predicted: np.median(np.abs(y_valid - predicted) / y_valid) * 100
    print(f"ridge on the price: MAE ${raw_mae:,.0f}, {int((raw_predicted < 0).sum())} prices below zero, typical miss {percent(raw_predicted):.1f}%")
    print(f"ridge on log price: MAE ${log_mae:,.0f}, {int((log_predicted < 0).sum())} prices below zero, typical miss {percent(log_predicted):.1f}%")
    FOUND["target"] = (raw_mae, int((raw_predicted < 0).sum()), percent(raw_predicted), log_mae, percent(log_predicted))

    mileage = X_train[["mileage_miles"]]
    power = PowerTransformer().fit(mileage)
    shapes = {"raw": mileage["mileage_miles"].skew(), "square root": np.sqrt(mileage["mileage_miles"]).skew(),
              "log": np.log(mileage["mileage_miles"]).skew(), "fitted power": pd.Series(power.transform(mileage).ravel()).skew()}
    print("skew of mileage:", {k: round(v, 2) for k, v in shapes.items()}, " fitted power", round(power.lambdas_[0], 2))
    FOUND["mileage"] = (shapes, power.lambdas_[0])

    extended_train, extended_valid = add_car_features(X_train), add_car_features(X_valid)
    ledger = {"age, mileage and four categories": log_mae}
    for column in ["age_squared", "miles_per_year", "log_mileage"]:
        prepare = car_preparation(CAR_NUMBERS + [column], CAR_CATEGORIES)
        ledger["+ " + column] = price_model(prepare, extended_train, y_train, extended_valid, y_valid)[0]
    print("validation MAE:", {k: round(v) for k, v in ledger.items()})
    FOUND["ledger"] = ledger

    # A category with over a thousand values: the car's model.
    counts = X_train["model"].value_counts()
    unseen = int((~X_valid["model"].isin(counts.index)).sum())
    print(f"model: {len(counts):,} distinct values, {(counts == 1).sum()} seen once, {unseen} validation listings of a model never seen")
    FOUND["models"] = (len(counts), int((counts == 1).sum()), unseen)

    numbers = CAR_NUMBERS + ["age_squared"]
    one_hot = car_preparation(numbers, CAR_CATEGORIES + ["model"])
    one_hot_mae, _, one_hot_model = price_model(one_hot, extended_train, y_train, extended_valid, y_valid)
    grouped = ColumnTransformer([
        ("num", Pipeline([("impute", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), numbers),
        ("cat", Pipeline([("impute", SimpleImputer(strategy="most_frequent")),
                          ("onehot", OneHotEncoder(handle_unknown="infrequent_if_exist", min_frequency=20))]),
         CAR_CATEGORIES + ["model"])])
    grouped_mae, _, grouped_model = price_model(grouped, extended_train, y_train, extended_valid, y_valid)
    encoder = Pipeline([("encode", TargetEncoder(target_type="continuous", random_state=42)), ("scale", StandardScaler())])
    encoded = car_preparation(numbers, CAR_CATEGORIES, [("model", encoder, ["model"])])
    encoded_mae, _, encoded_model = price_model(encoded, extended_train, y_train, extended_valid, y_valid)
    width = lambda fitted: fitted.named_steps["prepare"].transform(extended_train.head(2)).shape[1]
    print(f"model one-hot: MAE ${one_hot_mae:,.0f} with {width(one_hot_model):,} columns; rare models grouped: "
          f"${grouped_mae:,.0f} with {width(grouped_model)}; target-encoded: ${encoded_mae:,.0f} with {width(encoded_model)}")
    FOUND["model_column"] = (one_hot_mae, width(one_hot_model), grouped_mae, width(grouped_model), encoded_mae, width(encoded_model))
    # Frequency encoding: each model replaced by the number of training listings that carry it.
    with_count = lambda table: table.assign(model_count=table["model"].map(counts).fillna(0))
    counted = car_preparation(numbers + ["model_count"], CAR_CATEGORIES)
    counted_mae, _, counted_model = price_model(counted, with_count(extended_train), y_train, with_count(extended_valid), y_valid)
    print(f"model as a count of its listings: MAE ${counted_mae:,.0f} with {counted_model.named_steps['prepare'].transform(with_count(extended_train).head(2)).shape[1]} columns")
    FOUND["model_count"] = counted_mae

    # Smoothing: a category's own mean is trusted in proportion to how many rows stand behind it.
    overall = y_train.mean()
    smooth = lambda rows, mean, strength=20: (rows * mean + strength * overall) / (rows + strength)
    print(f"mean price ${overall:,.0f}; a model seen once at $150,000 is encoded as ${smooth(1, 150_000):,.0f}, "
          f"one seen 500 times at $30,000 as ${smooth(500, 30_000):,.0f}")
    FOUND["smooth"] = (overall, smooth(1, 150_000), smooth(500, 30_000))

    # The leak: encode a meaningless column by the label, on the same rows the model then trains on.
    rng = np.random.default_rng(0)
    log_price = np.log(y_train)
    group = pd.Series(rng.integers(0, 20_000, size=len(X_train)), index=X_train.index)        # about 3 listings per group
    valid_group = pd.Series(rng.integers(0, 20_000, size=len(X_valid)), index=X_valid.index)
    own_mean = log_price.groupby(group).transform("mean")                                      # includes each row's own label
    fair = TargetEncoder(target_type="continuous", random_state=0).fit_transform(group.to_frame(), log_price).ravel()
    on_new_rows = valid_group.map(log_price.groupby(group).mean()).fillna(log_price.mean())
    leak = (np.corrcoef(own_mean, log_price)[0, 1], np.corrcoef(fair, log_price)[0, 1],
            np.corrcoef(on_new_rows, np.log(y_valid))[0, 1])
    print(f"a random group, encoded by its mean log price: correlation with the label {leak[0]:.2f} on the rows that "
          f"built it, {leak[1]:.2f} when each row is encoded from other rows, {leak[2]:.2f} on new rows")
    FOUND["leak"] = leak


def check_book_numbers():
    f = FOUND
    assert f["zeros"] == {"RestingBP": 1, "Cholesterol": 172} and f["split"][:2] == (734, 184)
    assert round(f["split"][2], 3) == 0.553
    assert f["chol_hist"] == [129, 1, 16, 92, 236, 170, 67, 12, 4, 4, 1, 1, 1]
    assert np.allclose(f["chol_skew"], (-0.64, 1.24), atol=0.005) and np.allclose(f["chol_mean"], (203.23, 246.56), atol=0.005)
    assert f["five_Cholesterol"]["outside"] == 20 and f["five_RestingBP"]["outside"] == 20
    assert f["five_Oldpeak"]["outside"] == 13 and f["five_MaxHR"]["outside"] == 2 and f["five_Age"]["outside"] == 0
    assert (f["five_Oldpeak"]["low_fence"], f["five_Oldpeak"]["high_fence"]) == (-2.25, 3.75)
    assert (f["five_Cholesterol"]["q1"], f["five_Cholesterol"]["median"], f["five_Cholesterol"]["q3"]) == (210.0, 238.0, 277.0)
    assert (f["five_Cholesterol"]["low_fence"], f["five_Cholesterol"]["high_fence"]) == (109.5, 377.5)
    assert [f["five_" + c]["beyond_3_sd"] for c in NUMBERS] == [0, 6, 7, 0, 6]
    assert f["whiskers"] == (113.0, 369.0, 3, 17) and round(f["ta_margin"], 2) == 0.15
    assert f["skew"].round(2).tolist() == [-0.21, 0.63, 1.24, -0.19, 0.95] and round(f["oldpeak_zero"], 3) == 0.414
    assert f["chol_outside"] == [85, 100, 100, 384, 385, 392, 393, 394, 394, 407, 409, 412, 417, 458, 466, 468, 491,
                                 529, 564, 603]
    assert f["means"].loc[0].tolist() == [51.28, 130.82, 241.91, 148.07, 0.42]
    assert f["means"].loc[1].tolist() == [55.92, 134.53, 251.61, 126.93, 1.22]
    assert f["rate_ChestPainType"]["disease_rate"].to_dict() == {"ASY": 0.787, "ATA": 0.14, "NAP": 0.335, "TA": 0.45}
    assert f["rate_ChestPainType"]["patients"].to_dict() == {"ASY": 403, "ATA": 136, "NAP": 155, "TA": 40}
    assert f["rate_ST_Slope"]["disease_rate"].to_dict() == {"Down": 0.83, "Flat": 0.832, "Up": 0.179}
    assert f["rate_Sex"]["disease_rate"].to_dict() == {"F": 0.284, "M": 0.625}
    assert f["rate_ExerciseAngina"]["disease_rate"].to_dict() == {"N": 0.35, "Y": 0.847}
    assert f["rate_FastingBS"]["disease_rate"].to_dict() == {0: 0.482, 1: 0.792}
    assert f["maxhr_0"] == [1, 2, 11, 25, 42, 74, 87, 62, 23, 1] and f["maxhr_1"] == [8, 14, 45, 82, 108, 67, 54, 24, 4, 0]
    assert f["unmeasured"][0] == 129 and np.allclose(f["unmeasured"][1:], (0.899, 0.479), atol=0.0005)
    assert f["corr_zero"].loc["Cholesterol", "HeartDisease"] == -0.24 and f["corr_nan"].loc["Cholesterol", "HeartDisease"] == 0.08
    assert f["corr_zero"].loc["Cholesterol", "MaxHR"] == 0.26 and f["corr_nan"].loc["Cholesterol", "MaxHR"] == 0.0
    assert f["corr_nan"].loc["Age", "MaxHR"] == -0.4 and f["corr_nan"].loc["MaxHR", "HeartDisease"] == -0.41
    assert round(f["majority"], 3) == 0.553 and round(f["one_rule"], 3) == 0.827
    assert [round(f[k][0], 3) for k in ("zeros left in", "zeros as missing", "zeros as missing + flag")] == [0.853, 0.847, 0.857]
    assert [round(f[k][2], 3) for k in ("zeros left in", "zeros as missing", "zeros as missing + flag")] == [0.925, 0.922, 0.928]
    assert f["zeros left in"][3]["num__Cholesterol"] < 0 < f["zeros as missing + flag"][3]["num__missingindicator_Cholesterol"]
    assert round(f["test"][0], 3) == 0.897 and round(f["test"][1], 3) == 0.932 and f["test"][2] == [[71, 11], [8, 94]]

    # Chapter 8
    assert round(f["coin"], 4) == 0.0547
    gap, largest, p_shuffle, se, t, p_formula, low, high = f["test_MaxHR"]
    assert (round(gap, 2), round(largest, 2), p_shuffle, round(se, 3), round(t, 2)) == (-21.14, 7.45, 0.0, 1.745, -12.12)
    assert (round(low, 1), round(high, 1)) == (-24.6, -17.7) and p_formula < 1e-30
    gap, largest, p_shuffle, se, t, p_formula, low, high = f["test_RestingBP"]
    assert (round(gap, 2), round(largest, 2), round(p_shuffle, 4), round(t, 2), round(p_formula, 3)) == (
        3.71, 4.94, 0.0061, 2.81, 0.005) and (round(low, 1), round(high, 1)) == (1.1, 6.3)
    gap, largest, p_shuffle, se, t, p_formula, low, high = f["test_Cholesterol"]
    assert (round(gap, 2), round(largest, 2), round(p_shuffle, 4), round(se, 3), round(t, 2), round(p_formula, 3)) == (
        9.70, 18.20, 0.0455, 4.858, 2.0, 0.046)
    assert (round(low, 1), round(high, 1)) == (0.2, 19.2)
    assert f["shuffled_gaps"] == [18, 69, 228, 739, 1635, 2253, 2385, 1666, 708, 236, 57, 5]
    assert np.allclose(f["lead"], (104.0, 106.9), atol=0.05)
    assert [round(f[f"clt_{n}"][0], 2) for n in (1, 10, 50)] == [105.71, 33.93, 15.13]
    assert [round(f[f"clt_{n}"][1], 2) for n in (1, 10, 50)] == [106.86, 33.79, 15.11]
    assert [round(f[f"clt_{n}"][2], 2) for n in (1, 10, 50)] == [1.37, 0.42, 0.23]
    assert f["clt_1"][3] == [2877, 1398, 1013, 797, 635, 544, 586, 472, 355, 223, 235, 224, 200, 141, 70, 57]
    assert f["clt_10"][3] == [20, 419, 1603, 2838, 2581, 1574, 712, 195, 42, 15, 1, 0, 0, 0, 0, 0]
    assert f["clt_50"][3] == [0, 0, 182, 3919, 5027, 843, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    observed, expected, terms, chi_square, library = f["chi"]
    assert observed == [[111, 44], [217, 362]] and expected == [[69.3, 85.7], [258.7, 320.3]]
    assert terms == [[25.15, 20.32], [6.73, 5.44]] and round(chi_square, 2) == 57.64 and np.isclose(chi_square, library)
    assert f["chi_others"] == {"ST_Slope": 309.2, "ChestPainType": 214.3, "ExerciseAngina": 176.9, "FastingBS": 50.2,
                               "RestingECG": 9.8} and round(f["chi_ecg_p"], 4) == 0.0076
    groups, between, within, mean_between, mean_within, f_value = f["anova"]
    assert groups == {"ASY": (403, 128.5), "ATA": (136, 150.6), "NAP": (155, 141.9), "TA": (40, 145.8)}
    assert (round(between), round(within), round(mean_between, 1), round(mean_within, 1), round(f_value, 2)) == (
        60466, 428671, 20155.2, 587.2, 34.32)
    assert f["f_classif"] == [46.6, 145.5, 121.0]
    kept, cancelled, p, size = f["big_stays_in_week_nights"]
    assert (round(kept, 3), round(cancelled, 3), round(size, 3)) == (2.464, 2.562, 0.051) and p < 1e-16
    kept, cancelled, p, size = f["big_arrival_date_day_of_month"]
    assert (round(kept, 2), round(cancelled, 2), round(p, 3), round(size, 3)) == (15.84, 15.73, 0.034, -0.013)
    assert f["noise"][0] == 43 and round(f["noise"][1], 4) == 0.0003 and f["noise"][2] == 0
    assert np.allclose(f["binomial"][:6], [0.001, 0.0098, 0.0439, 0.1172, 0.2051, 0.2461], atol=5e-5)
    assert np.allclose(f["poisson"][:5], [0.0498, 0.1494, 0.224, 0.224, 0.168], atol=5e-5)

    # Chapter 9
    assert f["by_nights"] == [0.049, 0.251, 0.44, 0.419, 0.366, 0.342, 0.398, 0.343, 0.357]
    assert [round(v, 3) for v in f["nights"]] == [0.519, 0.582, 0.581]
    raw_auc, raw_loss, log_auc, log_loss_value = f["lead_model"]
    assert (round(raw_auc, 3), round(raw_loss, 4), round(log_auc, 3), round(log_loss_value, 4)) == (0.69, 0.6163, 0.69, 0.6015)
    assert {k: round(v, 3) for k, v in f["month"].items()} == {"number": 0.508, "circle": 0.532, "one-hot": 0.546}
    assert np.allclose(f["circle"], (0.518, 2.0), atol=0.0005) and f["agent"] == (333, 152)
    assert f["cars"][:2] == (62116, 15530) and np.allclose(f["cars"][2:], (2.28, -0.40), atol=0.005)
    raw_mae, negative, raw_percent, log_mae, log_percent = f["target"]
    assert (round(raw_mae), negative, round(raw_percent, 1), round(log_mae), round(log_percent, 1)) == (9062, 377, 22.3, 7759, 17.8)
    shapes, power = f["mileage"]
    assert {k: round(v, 2) for k, v in shapes.items()} == {"raw": 2.37, "square root": 0.42, "log": -0.99, "fitted power": -0.06}
    assert round(power, 2) == 0.29
    assert [round(v) for v in f["ledger"].values()] == [7759, 7527, 7709, 7798]
    assert f["models"] == (1102, 191, 50)
    assert [round(v) for v in f["model_column"]] == [4822, 1195, 5086, 469, 5751, 94] and round(f["model_count"]) == 7520
    assert [round(v) for v in f["smooth"]] == [32892, 38469, 30111]
    assert round(f["leak"][0], 2) == 0.55 and abs(f["leak"][1]) < 0.01 and abs(f["leak"][2]) < 0.01
    print("\nEvery number above matches the book.")


if __name__ == "__main__":
    chapter07()
    chapter08()
    chapter09()
    if CHECK_BOOK_NUMBERS:
        check_book_numbers()
