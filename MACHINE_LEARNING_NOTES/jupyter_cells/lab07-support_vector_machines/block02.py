PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "breast_cancer_dataset" / "data.csv"
df = pd.read_csv(train_path)
