# ----- Active-learning simulation -----
# Start from the same small class-balanced labeled set for both policies.
class0 = np.where(y_pool == 0)[0]
class1 = np.where(y_pool == 1)[0]
initial = np.concatenate([
    rng.choice(class0, size=20, replace=False),
    rng.choice(class1, size=20, replace=False),
])
active_labeled = set(initial.tolist())
random_labeled = set(initial.tolist())

label_counts = []
active_val_scores = []
random_val_scores = []
query_batch = 15
rounds = 8

def make_model():
    return Pipeline([
        ("scale", StandardScaler()),
        ("model", LogisticRegression(max_iter=2000)),
    ])
