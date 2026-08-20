PROJECT_ROOT = Path.cwd()
data_dir = PROJECT_ROOT / "all_datasets" / "optical_recognition_dataset"
columns = [f"pixel_{i}" for i in range(64)] + ["label"]
train = pd.read_csv(data_dir / "optdigits.tra", header=None, names=columns)
test = pd.read_csv(data_dir / "optdigits.tes", header=None, names=columns)
