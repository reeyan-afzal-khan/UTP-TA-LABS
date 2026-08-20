PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "heart_failure_dataset" / "heart.csv"
df = pd.read_csv(train_path)
