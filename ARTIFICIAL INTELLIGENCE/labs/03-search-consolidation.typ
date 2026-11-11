#import "/.shared/typst/utp.typ": *
#unit("labs", "03-search-consolidation")

#lab("3")[Search Engineering: Package, Tests, CLI, and Benchmark] <sec:lab03-search-code>

#callout("labproject", title: [Turn Labs 1--2 into a reproducible Python toolkit])[#strong[Read first.] Chapter~#ref(label("ch:searchpatterns"), supplement: none). \
#strong[Goal.] Standardise five algorithms, verify them with dataset-free tests, expose a command-line interface, and benchmark ten route queries. \
#strong[Scenario.] Convert notebook logic into reusable, testable software. \
#strong[Data.] The OpenFlights files and `all_experiments/utils/search_queries.csv`; unit tests use hand-made graphs. \
#strong[Notebook.] `all_experiments/lab03_search_engineering_worked.ipynb`; implementation and tests are in `all_experiments/utils/`. \
#strong[Hand in.] The executed notebook, the `results/lab03/` folder and a short conclusion, as listed in the checklist at the end of this sheet.]

#callout("labmode", title: [Lab setup])[+ Activate your course environment.

+ From `all_experiments/`, run the tests and one route search in a terminal. These two commands should work before you open the notebook.

+ Start Jupyter from the same folder, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

#code-block("cd all_experiments\npython -m pytest utils -q\npython -m utils --algorithm astar --start KUL --goal KEF\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/lab03_search_engineering_worked.py` runs the same code and writes the same evidence.]


#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/03-flow.typ"


#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] The notebook's tiny graph is below. Before running anything, write down the path and cost you expect from each of BFS, DFS, UCS, GBFS and A$""^star.op$. The heuristic is $h \( S \) = 5$, $h \( A \) = 4$, $h \( B \) = 1$, $h \( G \) = 0$. #code-block("toy = {\"S\": [(\"A\", 2.0), (\"B\", 5.0)], \"A\": [(\"G\", 5.0)], \"B\": [(\"G\", 1.0)], \"G\": []}", lang: "python")]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory. #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 1, last: 7, lang: "python") #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 8, last: 23, lang: "python")

#strong[Read the shared search engine.] Labs~1 and~2 used this module without looking inside. Read it now, in five parts, before running the engineering checks. It lives at `all_experiments/utils/core.py`, and the package initialiser exposes these functions to every notebook.

#strong[Result record and path reconstruction.] #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 1, last: 42, lang: "python") #strong[Cost accounting and BFS.] #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 43, last: 74, lang: "python") #strong[DFS and the priority-frontier interface.] #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 75, last: 106, lang: "python") #strong[Priority search, stale entries and termination.] #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 107, last: 135, lang: "python") #strong[UCS, greedy and A$""^star.op$ entry points.] #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/utils/core.py", first: 136, last: 148, lang: "python")

#callout("labquestion", title: [Question 1 --- Standardise the interface])[Every algorithm must return the same fields. Show the fields of `SearchResult`, then run all five algorithms on the small hand-made graph and display the results as one table.] #callout("labanswer", title: [Worked answer])[
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/03-trace.typ"
 Use this fixture before the airline benchmark. A hop-minimising algorithm can choose either two-hop route according to its neighbour order, because it does not look at their weights. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/03-worked-case.typ"


#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 25, last: 39, lang: "python") *Reference output.*

#code-block("SearchResult fields: ['found', 'path', 'hops', 'path_cost_km', 'expanded', 'max_frontier', 'runtime_ms']\n      path          hops  cost  expanded  max_frontier\nBFS   S -> A -> G      2   7.0         3             2\nDFS   S -> A -> G      2   7.0         2             2\nUCS   S -> B -> G      2   6.0         3             2\nGBFS  S -> B -> G      2   6.0         2             2\nA*    S -> B -> G      2   6.0         3             2", lang: "text")

#strong[What it means.] All five functions return a `SearchResult` with identical fields, so one loop can benchmark them. BFS and DFS return the two-edge route through A at cost 7, while UCS and A$""^star.op$ return the cheaper route through B at cost 6. GBFS also picks B, because $h \( B \) < h \( A \)$.]

#callout("labquestion", title: [Question 2 --- Separate responsibilities])[Search logic, data loading, plotting and the command line must live in separate modules. List the package's modules with their one-line purpose, and the names it exports.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 41, last: 45, lang: "python") *Reference output.*

#code-block("__init__.py      Helper code for the AI course notebooks.\n__main__.py      Command-line route search (Lab 3).\ncore.py          Graph-search algorithms shared by Labs 1-3: BFS, DFS, UCS, GBFS and A*.\nopenflights.py   Load the OpenFlights airport and route files into a weighted graph.\nplotting.py      Plot airport routes on longitude/latitude axes (Labs 1-3).\ntest_search.py   Unit tests for utils.core on tiny hand-made graphs (no dataset needed).\n\nExported names: SearchResult, astar, best_first, bfs, dfs, gbfs, ucs, haversine_km, load_openflights, route_is_valid, plot_route_paths", lang: "text")

#strong[What it means.] `core.py` holds the five algorithms and knows nothing about airports; `openflights.py` cleans the CSV files and computes distances; `plotting.py` draws routes; `__main__.py` is the command line; `test_search.py` holds the tests. Each module can be changed and tested on its own.]

#strong[Connect it to the chapter.] The module split is the same boundary as this picture: everything above the frontier policy belongs to the problem, and the policy names the algorithm. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/03-search-consolidation-chapter.typ"


#callout("labquestion", title: [Question 3 --- Run the automated tests])[The tests use tiny hand-made graphs and cover start = goal, unreachable goal, cycles, different objectives, frontier updates, consistent A$""^star.op$, non-optimal GBFS and negative costs. Run them with pytest from inside the notebook.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 47, last: 49, lang: "python") *Reference output.*

#code-block("........                                                                 [100\n8 passed in 0.71s", lang: "text")

#strong[What it means.] All eight tests pass in under a second. They need no dataset, so they run anywhere, including on a continuous-integration server. A harmless `PytestCacheWarning` may also appear if the folder is read-only or synced by a cloud drive.]

#callout("labquestion", title: [Question 4 --- Exercise the command-line interface])[Run `python -m utils --algorithm astar --start KUL --goal KEF` as a subprocess and show its output.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 51, last: 54, lang: "python") *Reference output.*

#code-block("ASTAR: found=True, hops=4, cost_km=11461.3, expanded=69, runtime_ms=3.75\nKUL -> HKT -> LED -> HEL -> KEF", lang: "text")

#strong[What it means.] The command line prints the same route and 11,461~km that Lab~2 found, because the notebook and the terminal share one implementation.]

#callout("labquestion", title: [Question 5 --- Benchmark ten route pairs])[Run BFS, UCS, GBFS and A$""^star.op$ on the ten queries in `utils/search_queries.csv` and summarise success rate, mean cost, mean hops, expanded nodes and runtime per algorithm. Save `benchmark.csv` and `benchmark_summary.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 56, last: 83, lang: "python") *Reference output.*

#code-block("A* cost equals UCS on all 10 queries: True\nGBFS is costlier than UCS on 7 of 10 queries", lang: "text")

#strong[What it means.] Every algorithm succeeds on all ten queries. A$""^star.op$ matches the UCS cost on every query with a fraction of the expansions; BFS has the highest mean cost because it optimises hops; GBFS expands the fewest states but returns a costlier route on seven queries. For distance-based routing, A$""^star.op$ is the best default among the exact methods.]

#callout("labquestion", title: [Question 6 --- Save the evidence])[Save a bar chart of mean expansions per algorithm. Then note the one-line terminal command that runs the same tests outside the notebook.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab03_search_engineering_worked.py", first: 85, last: 91, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/ARTIFICIAL INTELLIGENCE/labs/visuals/03-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("Saved: ['benchmark.csv', 'benchmark_expansions.png', 'benchmark_summary.csv']\nTerminal command (from all_experiments):  python -m pytest utils -q", lang: "text")

#strong[Read the result.] Regenerate this plot rather than copying it. The vertical axis is logarithmic, so the gap between A$""^star.op$ and UCS is much larger than it looks.]

#callout("yourturn", title: [Your turn])[+ #strong[Add two tests.] Append the two tests below to `utils/test_search.py`, then rerun `python -m pytest utils -q`. The first checks a boundary case for the informed searches. The second pins down what happens when two routes cost the same. Check the result contract, not only the `found` flag.

+ #strong[Use the command line.] Run `ucs`, `gbfs` and `astar` from `DOH` to `LIM`. Record cost, route and expansions for each.

+ #strong[Find the boundary.] Open `demo_robot_maze.py` and answer: which function plays the role that `openflights.py` plays for airports, and which lines of `core.py` had to change for the maze to work?

#code-block("def test_start_equals_goal_informed():\n    h = {\"A\": 0.0}.get\n    for algorithm in (gbfs, astar):\n        result = algorithm({\"A\": []}, \"A\", \"A\", h)\n        assert result.found and result.path == [\"A\"]\n        assert result.hops == 0 and result.path_cost_km == 0\n\n\ndef test_equal_cost_routes_keep_the_minimum_cost():\n    graph = {\"S\": [(\"A\", 1.0), (\"B\", 1.0)], \"A\": [(\"G\", 1.0)], \"B\": [(\"G\", 1.0)], \"G\": []}\n    assert ucs(graph, \"S\", \"G\").path_cost_km == pytest.approx(2.0)", lang: "python")]

#callout("expectedfindings", title: [Expected findings])[+ `10 passed`. Question~3's reference output will now read 10 instead of 8, which is correct. If you remove the tests again, it returns to 8.

+ UCS: 14,856~km via MAD, 3,046 expanded. GBFS: 15,333~km via GRU, 2 expanded. A$""^star.op$: 14,856~km via MAD, 112 expanded.

+ `build_graph` is the maze's loader, and no line of `core.py` changed. That is the domain boundary of #ref(label("fig:domains"), supplement: [Figure]): a new domain needs a new loader and nothing else.]

#callout("troubleshoot", title: [Troubleshooting])[/ `No module named pytest`: #block[
Your environment is not active, or the requirements were not installed in it. Activate it and run `pip install -r requirements.txt`.
]

/ `No module named utils`: #block[
Run `python -m utils` and `python -m pytest utils` from inside `all_experiments/`.
]

/ A test fails after you edited `core.py`: #block[
Good: that is what the tests are for. Read which test failed; each one names one way a search can break.
]]

#callout("verification", title: [Verification checklist])[- All five algorithms return a `SearchResult` with identical fields.

- All tests pass with `python -m pytest utils -q`, without any dataset.

- The command line prints the KUL$arrow.r$HKT$arrow.r$LED$arrow.r$HEL$arrow.r$KEF route and 11,461~km, as Lab~2 found.

- Every algorithm succeeds on all ten benchmark queries, and A$""^star.op$ matches the UCS cost on each.

- `results/lab03/` holds `benchmark.csv`, `benchmark_summary.csv` and `benchmark_expansions.png`.]

#callout("labdeliverable", title: [Submission checklist])[- Restart the kernel and run all cells without errors.

- Submit the executed notebook, your edited `test_search.py` and the generated `results/lab03/` folder.

- Add a short conclusion: recommend a default method for distance-based routing, and explain which module would change for a different graph domain.]
