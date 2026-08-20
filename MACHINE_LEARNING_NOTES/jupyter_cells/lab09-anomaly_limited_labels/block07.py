rng = np.random.default_rng(42)
rng_random = np.random.default_rng(123)
PROJECT_ROOT = Path.cwd()

train_path = PROJECT_ROOT / "all_datasets" / "breast_cancer_dataset" / "data.csv"
df = pd.read_csv(train_path)
X = df.drop(columns=["id", "diagnosis", "Unnamed: 32"], errors="ignore")
y = (df["diagnosis"] == "M").astype(int).to_numpy()
