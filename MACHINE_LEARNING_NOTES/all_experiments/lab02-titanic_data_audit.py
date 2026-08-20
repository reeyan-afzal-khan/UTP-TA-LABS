from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path.cwd().parent
train_path = PROJECT_ROOT / "all_datasets\\titanic_dataset\\Titanic-Dataset.csv"
df = pd.read_csv(train_path)

# Keep the audit explicit: rows, columns, types, missingness, and target balance.
print("shape:", df.shape)
print(df.head())
print("\nData types:\n", df.dtypes)
print("\nMissing values:\n", df.isna().sum().sort_values(ascending=False))
print("\nSurvival rate:\n", df["Survived"].value_counts(normalize=True))

# A few simple, interpretable features used later in the course.
df["FamilySize"] = df["SibSp"] + df["Parch"] + 1
df["IsAlone"] = (df["FamilySize"] == 1).astype(int)

summary = (
    df.groupby(["Sex", "Pclass"], dropna=False)["Survived"]
          .agg(["count", "mean"])
                .rename(columns={"mean": "survival_rate"})
                )
                print("\nSurvival by sex and class:\n", summary)
