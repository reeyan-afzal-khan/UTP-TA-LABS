PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "bike_sharing_dataset" / "day.csv"
df = pd.read_csv(train_path)
df["dteday"] = pd.to_datetime(df["dteday"])
df = df.sort_values("dteday").reset_index(drop=True)
