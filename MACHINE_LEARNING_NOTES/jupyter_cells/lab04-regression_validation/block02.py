PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "medical_cost_personal_dataset" / "insurance.csv"
df = pd.read_csv(train_path)
