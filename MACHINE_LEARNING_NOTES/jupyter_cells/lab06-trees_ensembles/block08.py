PROJECT_ROOT = Path.cwd()
train_path = PROJECT_ROOT / "all_datasets" / "ames_housing_dataset" / "AmesHousing.csv"
df = pd.read_csv(train_path)
