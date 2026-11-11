#import "/.shared/typst/utp.typ": *
#unit("labs", "01-search-foundations")

#lab("1")[Search Foundations on an Airline Network] <sec:lab01-search>

#callout("labproject", title: [Build and compare BFS, DFS, and Uniform-Cost Search])[#strong[Read first.] Chapter~#ref(label("ch:uninformed"), supplement: none). Chapter~#ref(label("ch:toolkit"), supplement: none) sets up the project folders and Python environment. \
#strong[Goal.] Run BFS, DFS and UCS on one cleaned graph, verify every path, and explain why the algorithms disagree. \
#strong[Scenario.] Build a route planner over real airline connections and compare route quality with search effort. \
#strong[Data.] `all_datasets/lab01-03_airports.csv` and `lab01-03_routes.csv`. \
#strong[Notebook.] `all_experiments/lab01_search_foundations_worked.ipynb`; Labs 1--3 share `all_experiments/utils/`. \
#strong[Hand in.] The executed notebook, the `results/lab01/` folder and a short conclusion, as listed in the checklist at the end of this sheet.]

#callout("labmode", title: [Lab setup])[+ Activate your course environment (Chapter~#ref(label("ch:toolkit"), supplement: none)) and confirm that both data files are in `all_datasets/`.

+ Warm up on the robot's maze, which needs no data. From the course folder, run the command below. Its last line must read `Every number above matches the book.`

+ Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

#code-block("python all_experiments/demo_robot_maze.py\ncd all_experiments\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/lab01_search_foundations_worked.py` runs the same code and writes the same evidence.]


#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/01-flow.typ"


#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Before touching the airline data, trace BFS and UCS by hand on the seven-node graph of #ref(label("fig:ucs-vs-bfs"), supplement: [Figure]), writing out the frontier after each expansion. You will check your trace with code at the end of this sheet.]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory, so that relative paths resolve. #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 1, last: 7, lang: "python") #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 8, last: 19, lang: "python")

#callout("labquestion", title: [Question 1 --- Load and validate the graph])[Load the airport and route files, keep only airports with a valid IATA code and coordinates, drop routes whose endpoints are unusable, and collapse duplicate routes. Report how many rows survive each step and show the three standard queries.] #callout("labanswer", title: [Worked answer])[
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/01-trace.typ"
 #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 21, last: 25, lang: "python") *Reference output.*

#code-block("airport_rows         10668      valid_airports        6464\nroute_rows           67663      unique_valid_routes  37337\nremoved_route_rows   30326\nQueries:  Q1 KUL -> KEF     Q2 SIN -> EZE     Q3 NRT -> CPT", lang: "text")

#strong[What it means.] Of 10,668 airport rows, 6,464 have a usable code and coordinates; of 67,663 route rows, 37,337 unique directed routes connect two usable airports. Every algorithm below runs on this same graph, so their results can be compared.]

#callout("labquestion", title: [Question 2 --- Define the edge cost])[BFS and DFS count every route as one step. UCS needs a number: the great-circle (Haversine) distance in kilometres between the two airports. Show the first five routes out of KUL with their distances, and the straight-line distance from KUL to KEF.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 27, last: 33, lang: "python") *Reference output.*

#code-block("KUL has 112 outgoing routes\nGreat-circle distance KUL -> KEF: 11,316 km (no direct route exists)", lang: "text")

#strong[What it means.] Each edge carries the distance between its endpoints, computed once when the graph is built. Counting steps (BFS, DFS) and summing kilometres (UCS) are two different questions asked of the same graph.]

#strong[Connect it to the chapter.] The next question runs the loop below three times. Only the highlighted box differs between the three algorithms. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/01-search-foundations-chapter.typ"


#callout("labquestion", title: [Question 3 --- Run BFS, DFS and UCS on the three standard queries])[Record path, hops, distance, expanded nodes, maximum frontier and runtime for every algorithm and query, and save the table as `metrics.csv`. #emph[Predict first:] which algorithm will expand the most airports, and which will use the most legs?] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 35, last: 44, lang: "python") *Reference output.*

#code-block("query algorithm hops        km expanded max_frontier\nQ1    BFS          2  12274.32      284         1679\nQ1    DFS         23  41767.82     2112          859\nQ1    UCS          4  11461.35     1851          616\nQ2    BFS          2  21976.11      233         1629\nQ2    DFS         39  65213.84      904          858\nQ2    UCS          3  17817.36     3002          620\nQ3    BFS          2  19005.89      173         1727\nQ3    DFS         64  91541.43     1414          785\nQ3    UCS          3  14813.32     3042         1018", lang: "text")

#strong[What it means.] BFS always returns the fewest hops (two legs on every query), UCS always returns the shortest distance, and DFS returns a long, winding route because it follows the first neighbour deeply. Expanded-node counts are the stable measure of effort; runtimes vary from machine to machine.]

#callout("labquestion", title: [Question 4 --- Verify every path independently])[A reported path is only evidence if it can be checked. Confirm that every consecutive pair of airports in every path is a real route, and recompute each path cost by summing the edge distances.] #callout("labanswer", title: [Worked answer])[Here is what the verification loop does for one path: 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/01-worked-case.typ"


#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 46, last: 54, lang: "python") *Reference output.*

#code-block("Verified 9 paths: every leg exists and every cost matches its edge sum", lang: "text")

#strong[What it means.] All nine paths use real routes and their costs equal the sum of their edge distances, so the metrics table can be trusted. The loader already removed unusable endpoints, yet verification still checks the returned edges: a bug in the search would show up here.]

#callout("labquestion", title: [Question 5 --- Compare the objectives])[Show hops and distance side by side for the three algorithms. Then run DFS again with every neighbour list reversed, to show that its answer depends on neighbour order.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 56, last: 62, lang: "python") *Reference output.*

#code-block("Q1 DFS: 23 hops with the original order, 8 with the reversed order\nQ2 DFS: 39 hops with the original order, 41 with the reversed order\nQ3 DFS: 64 hops with the original order, 39 with the reversed order", lang: "text")

#strong[What it means.] BFS minimises the number of legs, so a two-leg route through a distant hub (KUL $arrow.r$ AMS $arrow.r$ KEF) wins even though UCS finds a four-leg route that is over 800~km shorter. Fewest legs and fewest kilometres are different objectives. DFS changes its answer as soon as the neighbour order changes, because it commits to the first branch it sees; it guarantees neither objective.]

#callout("labquestion", title: [Question 6 --- Save the evidence])[Plot the three KUL $arrow.r$ KEF routes and save the figure next to `metrics.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab01_search_foundations_worked.py", first: 64, last: 68, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/ARTIFICIAL INTELLIGENCE/labs/visuals/01-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("Saved: ['metrics.csv', 'route_comparison.png']", lang: "text")

#strong[Read the result.] Regenerate this plot rather than copying it. Check the axes and the three routes; this saved figure is a reference, not evidence of your own run.]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these three tasks, and record your numbers before reading the expected findings.

+ #strong[Try a new query.] Run all three algorithms from `JFK` to `SYD` and record hops, kilometres and expansions.

+ #strong[Does direction matter?] Run BFS and UCS from `KEF` back to `KUL` and compare with the outward results. Is the best route back the same route reversed?

+ #strong[Check your warm-up.] Type in the graph of #ref(label("fig:ucs-vs-bfs"), supplement: [Figure]) and compare with your hand trace. Then remove the edge from D to G and predict what BFS returns.

#code-block("tiny = {\"A\": [(\"B\", 1.0), (\"C\", 4.0)], \"B\": [(\"D\", 3.0), (\"E\", 2.0)], \"C\": [(\"F\", 5.0)],\n        \"D\": [(\"G\", 4.0)], \"E\": [(\"G\", 1.0)], \"F\": [(\"G\", 2.0)], \"G\": []}\nprint(bfs(tiny, \"A\", \"G\").path, ucs(tiny, \"A\", \"G\").path)", lang: "python")]

#callout("expectedfindings", title: [Expected findings])[+ BFS: 2 hops, 23,093~km via AUH, 537 expanded. DFS: 45 hops, 64,251~km. UCS: 2 hops, 16,035~km via LAX, 3,097 expanded. BFS stops at the first two-leg route it meets, 7,000~km too long.

+ BFS: 2 hops via AMS, 12,274~km. UCS: 4 hops via HEL, LED and TAS, 11,478~km, which is not the outward UCS route reversed. Routes are directed, so a route out does not guarantee the same route back.

+ BFS returns A--B--D--G at cost 8 and UCS returns A--B--E--G at cost 4. With the edge from D to G removed, BFS also returns A--B--E--G, because that is now the first three-edge route it reaches.]

#callout("troubleshoot", title: [Troubleshooting])[/ `ModuleNotFoundError: utils`: #block[
Jupyter was not started from `all_experiments/`. Restart it from there, or run the script from the course folder.
]

/ `FileNotFoundError`: #block[
A data file is missing or misnamed. Match Chapter~#ref(label("ch:toolkit"), supplement: none)'s names, capitals too.
]

/ Different counts from the reference: #block[
Use the supplied data files and an unedited `utils/core.py`. Runtimes vary by machine; hops, kilometres and expansions should not.
]]

#callout("verification", title: [Verification checklist])[- The cleaned graph has 6,464 usable airports and 37,337 unique directed routes.

- Every BFS, DFS and UCS path uses real routes, and its cost is the sum of its legs.

- BFS returns the fewest hops and UCS the shortest distance on every query; UCS finds the 11,461~km KUL$arrow.r$KEF route.

- Reversing the neighbour order changes the DFS route, and you can explain why.

- `results/lab01/` holds `metrics.csv` and `route_comparison.png`.]

#callout("labdeliverable", title: [Submission checklist])[- Restart the kernel and run all cells without errors.

- Submit the executed notebook, including your #emph[Your turn] cells, and the generated `results/lab01/` folder.

- Add a short conclusion: which method minimises hops, which minimises distance, why DFS changes with neighbour order, and which effort measure is comparable across computers.]
