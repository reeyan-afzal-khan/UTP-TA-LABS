# Complete executable companion to lab01_search_foundations_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

from pathlib import Path

import numpy as np
import pandas as pd
from IPython.display import display

from utils import bfs, dfs, ucs, haversine_km, load_openflights, plot_route_paths, route_is_valid

ROOT = Path.cwd().parent                     # the course folder
DATA = ROOT / "all_datasets"
RESULTS = ROOT / "results" / "lab01"
RESULTS.mkdir(parents=True, exist_ok=True)

airports, routes, coords, graph, stats = load_openflights(DATA / "lab01-03_airports.csv", DATA / "lab01-03_routes.csv")
queries = pd.read_csv("utils/search_queries.csv").head(3)

display(pd.Series(stats, name="count").to_frame())
display(queries)

sample = pd.DataFrame(graph["KUL"][:5], columns=["destination", "distance_km"])
display(sample.round(1))

direct_km = haversine_km(coords["KUL"]["latitude"], coords["KUL"]["longitude"],
                         coords["KEF"]["latitude"], coords["KEF"]["longitude"])
print(f"KUL has {len(graph['KUL'])} outgoing routes")
print(f"Great-circle distance KUL -> KEF: {direct_km:,.0f} km (no direct route exists)")

rows = []
for query in queries.itertuples():
    for name, algorithm in [("BFS", bfs), ("DFS", dfs), ("UCS", ucs)]:
        result = algorithm(graph, query.start, query.goal)
        rows.append({"query_id": query.query_id, "start": query.start, "goal": query.goal,
                     "algorithm": name, **result.as_dict(), "path": " -> ".join(result.path)})

metrics = pd.DataFrame(rows).drop(columns="found")
metrics.to_csv(RESULTS / "metrics.csv", index=False)
display(metrics.drop(columns=["start", "goal", "path"]).round(2))

edge_km = {airport: dict(neighbours) for airport, neighbours in graph.items()}

for row in metrics.itertuples():
    path = row.path.split(" -> ")
    assert route_is_valid(path, graph), f"{row.algorithm} {row.query_id}: a leg is not a real route"
    recomputed = sum(edge_km[a][b] for a, b in zip(path, path[1:]))
    assert np.isclose(recomputed, row.path_cost_km), f"{row.algorithm} {row.query_id}: cost mismatch"

print(f"Verified {len(metrics)} paths: every leg exists and every cost matches its edge sum")

display(metrics.pivot(index="query_id", columns="algorithm", values=["hops", "path_cost_km"]).round(0))

reversed_graph = {airport: neighbours[::-1] for airport, neighbours in graph.items()}
for query in queries.itertuples():
    original = dfs(graph, query.start, query.goal).hops
    reordered = dfs(reversed_graph, query.start, query.goal).hops
    print(f"{query.query_id} DFS: {original} hops with the original order, {reordered} with the reversed order")

q1 = metrics[metrics.query_id == "Q1"]
paths = {row.algorithm: row.path.split(" -> ") for row in q1.itertuples()}
figure, _ = plot_route_paths(paths, coords, title="Route comparison: KUL to KEF")
figure.savefig(RESULTS / "route_comparison.png", dpi=160, bbox_inches="tight")
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

