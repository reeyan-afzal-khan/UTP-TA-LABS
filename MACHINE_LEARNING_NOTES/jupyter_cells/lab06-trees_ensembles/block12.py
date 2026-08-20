PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "red_wine_quality_dataset" / "winequality-red.csv"
df = pd.read_csv(train_path)
