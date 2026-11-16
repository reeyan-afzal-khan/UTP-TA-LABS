#import "/.shared/typst/utp.typ": *
#unit("labs", "03-search-consolidation")

#labsection(3, label: <sec:lab03-search-code>)[Search Engineering: Package, Tests, CLI, and Benchmark]

#labproject[Turn Labs 1--2 into a reproducible Python toolkit][
  #strong[Read first.] Chapter~#ref(<ch:searchpatterns>). \

  #strong[Goal.] Standardise five algorithms, verify them with dataset-free tests, expose a command-line interface, and benchmark ten route queries. \

  #strong[Scenario.] Convert notebook logic into reusable, testable software. \

  #strong[Data.] The OpenFlights files and `all_experiments/utils/search_queries.csv`; unit tests use hand-made graphs. \

  #strong[Notebook.] `all_experiments/lab03_search_engineering_worked.ipynb`; implementation and tests are in `all_experiments/utils/`. \

  #strong[Hand in.] The executed notebook, the `results/lab03/` folder and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labsetup[
  + Activate your course environment.
  + From `all_experiments/`, run the tests and one route search in a terminal. These two commands should work before you open the notebook.
  + Start Jupyter from the same folder, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

  ```terminal
  cd all_experiments
  python -m pytest utils -q
  python -m utils --algorithm astar --start KUL --goal KEF
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab03_search_engineering_worked.py` runs the same code and writes the same evidence.
]

#include "visuals/03-flow.typ"

#labroutine

#exercises[
  #strong[Warm-up on paper.] The notebook’s tiny graph is below. Before running anything, write down the path and cost you expect from each of BFS, DFS, UCS, GBFS and A$""^(star.op)$. The heuristic is $h(S)=5$, $h(A)=4$, $h(B)=1$, $h(G)=0$.

  ```python
  toy = {"S": [("A", 2.0), ("B", 5.0)], "A": [("G", 5.0)], "B": [("G", 1.0)], "G": []}
  ```
]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory.

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 1, last: 7, lang: "python")

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 8, last: 23, lang: "python")

#strong[Read the shared search engine.] Labs~1 and~2 used this module without looking inside. Read it now, in five parts, before running the engineering checks. It lives at `all_experiments/utils/core.py`, and the package initialiser exposes these functions to every notebook.

#strong[Result record and path reconstruction.]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 1, last: 42, lang: "python")

#strong[Cost accounting and BFS.]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 43, last: 74, lang: "python")

#strong[DFS and the priority-frontier interface.]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 75, last: 106, lang: "python")

#strong[Priority search, stale entries and termination.]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 107, last: 135, lang: "python")

#strong[UCS, greedy and A$""^(star.op)$ entry points.]

#lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 136, last: 148, lang: "python")

#labquestion(1)[Standardise the interface][
  Every algorithm must return the same fields. Show the fields of `SearchResult`, then run all five algorithms on the small hand-made graph and display the results as one table.
]

#labanswer[
  #include "visuals/03-trace.typ"

  Use this fixture before the airline benchmark. A hop-minimising algorithm can choose either two-hop route according to its neighbour order, because it does not look at their weights.

  #include "visuals/03-worked-case.typ"

  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 25, last: 39, lang: "python")

  #refoutput[
    ```terminal
    SearchResult fields: ['found', 'path', 'hops', 'path_cost_km', 'expanded', 'max_frontier', 'runtime_ms']
          path          hops  cost  expanded  max_frontier
    BFS   S -> A -> G      2   7.0         3             2
    DFS   S -> A -> G      2   7.0         2             2
    UCS   S -> B -> G      2   6.0         3             2
    GBFS  S -> B -> G      2   6.0         2             2
    A*    S -> B -> G      2   6.0         3             2
    ```
  ]

  #strong[What it means.] All five functions return a `SearchResult` with identical fields, so one loop can benchmark them. BFS and DFS return the two-edge route through A at cost 7, while UCS and A$""^(star.op)$ return the cheaper route through B at cost 6. GBFS also picks B, because $h(B) < h(A)$.
]

#labquestion(2)[Separate responsibilities][
  Search logic, data loading, plotting and the command line must live in separate modules. List the package’s modules with their one-line purpose, and the names it exports.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 41, last: 45, lang: "python")

  #refoutput[
    ```terminal
    __init__.py      Helper code for the AI course notebooks.
    __main__.py      Command-line route search (Lab 3).
    core.py          Graph-search algorithms shared by Labs 1-3: BFS, DFS, UCS, GBFS and A*.
    openflights.py   Load the OpenFlights airport and route files into a weighted graph.
    plotting.py      Plot airport routes on longitude/latitude axes (Labs 1-3).
    test_search.py   Unit tests for utils.core on tiny hand-made graphs (no dataset needed).

    Exported names: SearchResult, astar, best_first, bfs, dfs, gbfs, ucs, haversine_km, load_openflights, route_is_valid, plot_route_paths
    ```
  ]

  #strong[What it means.] `core.py` holds the five algorithms and knows nothing about airports; `openflights.py` cleans the CSV files and computes distances; `plotting.py` draws routes; `__main__.py` is the command line; `test_search.py` holds the tests. Each module can be changed and tested on its own.
]

#strong[Connect it to the chapter.] The module split is the same boundary as this picture: everything above the frontier policy belongs to the problem, and the policy names the algorithm.

#include "visuals/03-search-consolidation-chapter.typ"

#labquestion(3)[Run the automated tests][
  The tests use tiny hand-made graphs and cover start = goal, unreachable goal, cycles, different objectives, frontier updates, consistent A$""^(star.op)$, non-optimal GBFS and negative costs. Run them with pytest from inside the notebook.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 47, last: 49, lang: "python")

  #refoutput[
    ```terminal
    ........                                                                 [100%]
    8 passed in 0.71s
    ```
  ]

  #strong[What it means.] All eight tests pass in under a second. They need no dataset, so they run anywhere, including on a continuous-integration server. A harmless `PytestCacheWarning` may also appear if the folder is read-only or synced by a cloud drive.
]

#labquestion(4)[Exercise the command-line interface][
  Run `python -m utils --algorithm astar --start KUL --goal KEF` as a subprocess and show its output.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 51, last: 54, lang: "python")

  #refoutput[
    ```terminal
    ASTAR: found=True, hops=4, cost_km=11461.3, expanded=69, runtime_ms=3.75
    KUL -> HKT -> LED -> HEL -> KEF
    ```
  ]

  #strong[What it means.] The command line prints the same route and 11,461~km that Lab~2 found, because the notebook and the terminal share one implementation.
]

#labquestion(5)[Benchmark ten route pairs][
  Run BFS, UCS, GBFS and A$""^(star.op)$ on the ten queries in `utils/search_queries.csv` and summarise success rate, mean cost, mean hops, expanded nodes and runtime per algorithm. Save `benchmark.csv` and `benchmark_summary.csv`.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 56, last: 83, lang: "python")

  #refoutput[
    ```terminal
    A* cost equals UCS on all 10 queries: True
    GBFS is costlier than UCS on 7 of 10 queries
    ```
  ]

  #strong[What it means.] Every algorithm succeeds on all ten queries. A$""^(star.op)$ matches the UCS cost on every query with a fraction of the expansions; BFS has the highest mean cost because it optimises hops; GBFS expands the fewest states but returns a costlier route on seven queries. For distance-based routing, A$""^(star.op)$ is the best default among the exact methods.
]

#labquestion(6)[Save the evidence][
  Save a bar chart of mean expansions per algorithm. Then note the one-line terminal command that runs the same tests outside the notebook.
]

#labanswer[
  #lstinput("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 85, last: 91, lang: "python")

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/ARTIFICIAL INTELLIGENCE/labs/visuals/03-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #refoutput[
    ```terminal
    Saved: ['benchmark.csv', 'benchmark_expansions.png', 'benchmark_summary.csv']
    Terminal command (from all_experiments):  python -m pytest utils -q
    ```
  ]

  #strong[Read the result.] Regenerate this plot rather than copying it. The vertical axis is logarithmic, so the gap between A$""^(star.op)$ and UCS is much larger than it looks.
]

#exercises[
  + #strong[Add two tests.] Append the two tests below to `utils/test_search.py`, then rerun `python -m pytest utils -q`. The first checks a boundary case for the informed searches. The second pins down what happens when two routes cost the same. Check the result contract, not only the `found` flag.
  + #strong[Use the command line.] Run `ucs`, `gbfs` and `astar` from `DOH` to `LIM`. Record cost, route and expansions for each.
  + #strong[Find the boundary.] Open `demo_robot_maze.py` and answer: which function plays the role that `openflights.py` plays for airports, and which lines of `core.py` had to change for the maze to work?

  ```python
  def test_start_equals_goal_informed():
      h = {"A": 0.0}.get
      for algorithm in (gbfs, astar):
          result = algorithm({"A": []}, "A", "A", h)
          assert result.found and result.path == ["A"]
          assert result.hops == 0 and result.path_cost_km == 0

  def test_equal_cost_routes_keep_the_minimum_cost():
      graph = {"S": [("A", 1.0), ("B", 1.0)], "A": [("G", 1.0)], "B": [("G", 1.0)], "G": []}
      assert ucs(graph, "S", "G").path_cost_km == pytest.approx(2.0)
  ```
]

#answers[
  + `10 passed`. Question~3’s reference output will now read 10 instead of 8, which is correct. If you remove the tests again, it returns to 8.
  + UCS: 14,856~km via MAD, 3,046 expanded. GBFS: 15,333~km via GRU, 2 expanded. A$""^(star.op)$: 14,856~km via MAD, 112 expanded.
  + `build_graph` is the maze’s loader, and no line of `core.py` changed. That is the domain boundary of #figref(<fig:domains>): a new domain needs a new loader and nothing else.
]

#tip[
  / `No module named pytest`: Your environment is not active, or the requirements were not installed in it. Activate it and run `pip install -r requirements.txt`.
  / `No module named utils`: Run `python -m utils` and `python -m pytest utils` from inside `all_experiments/`.
  / A test fails after you edited `core.py`: Good: that is what the tests are for. Read which test failed; each one names one way a search can break.
]

#checklist[
  - All five algorithms return a `SearchResult` with identical fields.
  - All tests pass with `python -m pytest utils -q`, without any dataset.
  - The command line prints the KUL$arrow.r$HKT$arrow.r$LED$arrow.r$HEL$arrow.r$KEF route and 11,461~km, as Lab~2 found.
  - Every algorithm succeeds on all ten benchmark queries, and A$""^(star.op)$ matches the UCS cost on each.
  - `results/lab03/` holds `benchmark.csv`, `benchmark_summary.csv` and `benchmark_expansions.png`.
]

#submission[
  - Restart the kernel and run all cells without errors.
  - Submit the executed notebook, your edited `test_search.py` and the generated `results/lab03/` folder.
  - Add a short conclusion: recommend a default method for distance-based routing, and explain which module would change for a different graph domain.
]
