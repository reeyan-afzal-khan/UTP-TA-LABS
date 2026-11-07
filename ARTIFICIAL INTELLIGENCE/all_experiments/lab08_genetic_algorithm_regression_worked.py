# Complete executable companion to lab08_genetic_algorithm_regression_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

import time
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from IPython.display import display
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

ROOT = Path.cwd().parent
DATA = ROOT / "all_datasets"
RESULTS = ROOT / "results" / "lab08"
RESULTS.mkdir(parents=True, exist_ok=True)

def ga_scalar(seed=42, pop_size=40, generations=80, n_elite=2):
    rng = np.random.default_rng(seed)
    population = rng.uniform(-10, 10, pop_size)
    for _ in range(generations):
        fitness = (population - 3) ** 2                                  # lower is better
        elite = population[np.argsort(fitness)[:n_elite]]
        # Tournament selection: the best of three random individuals becomes a parent.
        contestants = rng.integers(0, pop_size, size=(pop_size, 3))
        parents = population[contestants[np.arange(pop_size), fitness[contestants].argmin(axis=1)]]
        # Blend crossover between consecutive parents, then Gaussian mutation.
        a, b = parents[0::2], parents[1::2]
        alpha = rng.random(len(a))
        children = np.r_[alpha * a + (1 - alpha) * b, alpha * b + (1 - alpha) * a][: pop_size - n_elite]
        children += rng.normal(0, 0.15, len(children))
        population = np.r_[elite, children]                              # elites survive unchanged
    best = population[np.argmin((population - 3) ** 2)]
    return best, (best - 3) ** 2


x_best, f_best = ga_scalar()
print(f"Best x = {x_best:.6f}   f(x) = {f_best:.8f}")

insurance = pd.read_csv(DATA / "lab08-insurance.csv")
X = insurance[["age", "bmi", "children"]].assign(smoker=(insurance.smoker == "yes").astype(float))
y = insurance.charges.to_numpy()

train, test = train_test_split(insurance.index, test_size=0.20, random_state=42)
pd.Series(np.where(insurance.index.isin(test), "test", "train"), name="split").rename_axis("row_id").to_csv(RESULTS / "split.csv")

scaler = StandardScaler().fit(X.loc[train])
X_train, X_test = scaler.transform(X.loc[train]), scaler.transform(X.loc[test])
y_train, y_test = y[train], y[test]
print({"rows": len(insurance), "train": len(train), "test": len(test), "predictors": list(X.columns)})

def run_ga(seed, pop_size=100, generations=160, mutation_rate=0.15, mutation_scale=0.25, n_elite=4):
    rng = np.random.default_rng(seed)
    n_genes = X_train.shape[1] + 1
    population = rng.normal(0, 5000, size=(pop_size, n_genes))
    population[:, 0] += y_train.mean()                                   # intercepts start near the mean charge
    gene_scale = np.r_[2000, np.repeat(1000, n_genes - 1)]               # mutation size per gene

    def training_mse(individuals):
        predictions = individuals[:, [0]] + individuals[:, 1:] @ X_train.T
        return ((predictions - y_train) ** 2).mean(axis=1)

    best, best_mse, history = None, np.inf, []
    started = time.perf_counter()
    for _ in range(generations):
        fitness = training_mse(population)
        if fitness.min() < best_mse:
            best_mse, best = fitness.min(), population[fitness.argmin()].copy()
        history.append(best_mse)

        elite = population[np.argsort(fitness)[:n_elite]]
        contestants = rng.integers(0, pop_size, size=(pop_size, 3))
        parents = population[contestants[np.arange(pop_size), fitness[contestants].argmin(axis=1)]]
        a, b = parents[0::2], parents[1::2]
        alpha = rng.uniform(-0.1, 1.1, size=(len(a), 1))
        children = np.vstack([alpha * a + (1 - alpha) * b, alpha * b + (1 - alpha) * a])[: pop_size - n_elite]
        mutate = rng.random(children.shape) < mutation_rate
        children += mutate * rng.normal(0, mutation_scale, size=children.shape) * gene_scale
        population = np.vstack([elite, children])

    test_rmse = mean_squared_error(y_test, best[0] + X_test @ best[1:]) ** 0.5
    return {"seed": seed, "train_rmse": best_mse ** 0.5, "test_rmse": test_rmse,
            "runtime_s": time.perf_counter() - started, "coefficients": best, "history": np.sqrt(history)}


trial = run_ga(seed=1)
print(f"seed 1: train RMSE {trial['train_rmse']:.1f} | test RMSE {trial['test_rmse']:.1f} | {trial['runtime_s']:.2f} s")
print("Best chromosome [intercept, age, bmi, children, smoker]:", trial["coefficients"].round(1))

def run_table(runs):
    return pd.DataFrame(runs)[["seed", "train_rmse", "test_rmse", "runtime_s"]]


runs = [run_ga(seed) for seed in range(1, 11)]
results = run_table(runs)
results.to_csv(RESULTS / "ga_10_runs.csv", index=False)
display(results.round(3))
print(f"Median test RMSE {results.test_rmse.median():.2f} | SD across seeds {results.test_rmse.std():.4f}")

ols = LinearRegression().fit(X_train, y_train)
ols_test_rmse = mean_squared_error(y_test, ols.predict(X_test)) ** 0.5
ols_train_rmse = mean_squared_error(y_train, ols.predict(X_train)) ** 0.5
print("OLS test RMSE:", round(ols_test_rmse, 2))
print("OLS coefficients:   ", ols.coef_.round(1))
print("Median GA coefficients:", np.median([r["coefficients"][1:] for r in runs], axis=0).round(1))

fig, ax = plt.subplots(figsize=(7, 4))
for r in runs[:5]:
    ax.plot(r["history"], alpha=0.75, label=f"seed {r['seed']}")
ax.axhline(ols_train_rmse, linestyle="--", color="black", label="OLS train RMSE")
ax.set(xlabel="Generation", ylabel="Best-so-far train RMSE", title="GA convergence")
ax.legend(ncol=2, fontsize=8)
plt.tight_layout()
plt.savefig(RESULTS / "convergence.png", dpi=160)

small = run_table(run_ga(seed, pop_size=40) for seed in range(1, 11))
small.to_csv(RESULTS / "ga_sensitivity_pop40.csv", index=False)

summary = pd.DataFrame([
    {"method": "GA pop=100", "median_test_rmse": results.test_rmse.median(), "sd_test_rmse": results.test_rmse.std(), "median_runtime_s": results.runtime_s.median()},
    {"method": "GA pop=40", "median_test_rmse": small.test_rmse.median(), "sd_test_rmse": small.test_rmse.std(), "median_runtime_s": small.runtime_s.median()},
    {"method": "OLS", "median_test_rmse": ols_test_rmse, "sd_test_rmse": 0.0, "median_runtime_s": np.nan},
])
summary.to_csv(RESULTS / "summary.csv", index=False)
display(summary.round(4))
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

