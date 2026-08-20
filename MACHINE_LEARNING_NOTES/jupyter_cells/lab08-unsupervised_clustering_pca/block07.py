PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "mall_customers_dataset" / "Mall_Customers.csv"
df = pd.read_csv(train_path)
