# Keep the audit explicit: rows, columns, types, missingness, and target balance.
print("shape:", df.shape)
print(df.head())
print("\nData types:\n", df.dtypes)
print("\nMissing values:\n", df.isna().sum().sort_values(ascending=False))
print("\nSurvival rate:\n", df["Survived"].value_counts(normalize=True))
