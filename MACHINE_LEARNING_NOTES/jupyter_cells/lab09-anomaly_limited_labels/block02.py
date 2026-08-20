PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "credit_card_fraud_dataset" / "credit_card_fraud_10k.csv"
df = pd.read_csv(train_path)
