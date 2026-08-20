feature_cols = [c for c in df.columns if c not in {"id", "diagnosis", "Unnamed: 32"}]
X = df[feature_cols]
