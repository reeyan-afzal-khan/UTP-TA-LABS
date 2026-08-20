# A few simple, interpretable features used later in the course.
df["FamilySize"] = df["SibSp"] + df["Parch"] + 1
df["IsAlone"] = (df["FamilySize"] == 1).astype(int)

summary = (
    df.groupby(["Sex", "Pclass"], dropna=False)["Survived"]
      .agg(["count", "mean"])
      .rename(columns={"mean": "survival_rate"})
)
print("\nSurvival by sex and class:\n", summary)
