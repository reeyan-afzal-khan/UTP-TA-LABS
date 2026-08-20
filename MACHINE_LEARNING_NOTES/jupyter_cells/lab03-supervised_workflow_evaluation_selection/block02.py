PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "titanic_dataset" / "Titanic-Dataset.csv"
df = pd.read_csv(train_path)
