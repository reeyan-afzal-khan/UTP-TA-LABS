#import "/.shared/typst/utp.typ": *
#unit("labs", "02-informed-search")

#lab("2")[Heuristic Search on the Airline Network] <sec:lab02-informed>

#callout("labproject", title: [Compare UCS, Greedy Best-First Search, and A$""^star.op$])[#strong[Read first.] Chapter~#ref(label("ch:informed"), supplement: none). \
#strong[Goal.] Run GBFS and A$""^star.op$ with a Haversine heuristic, check admissibility, and measure quality against search effort. \
#strong[Scenario.] Improve the Lab~1 planner by adding geographic knowledge while keeping a clear quality baseline. \
#strong[Data.] The Lab~1 OpenFlights files. \
#strong[Notebook.] `all_experiments/lab02_informed_search_worked.ipynb` and the shared `all_experiments/utils/`. \
#strong[Hand in.] The executed notebook, the `results/lab02/` folder and a short conclusion, as listed in the checklist at the end of this sheet.]

#callout("labmode", title: [Lab setup])[+ Activate your course environment and confirm that Lab~1 ran on this machine.

+ Start Jupyter from `all_experiments/`, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. Everything runs in a few seconds.

#code-block("cd all_experiments\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/lab02_informed_search_worked.py` runs the same code and writes the same evidence.]


#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/02-flow.typ"


#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] On the rainy maze of Chapter~#ref(label("ch:informed"), supplement: none), work out $g$, $h$ and $f$ for the cells $\( 6 \, 4 \)$ and $\( 3 \, 4 \)$, using #ref(label("fig:rain-routes"), supplement: [Figure]) for $g$ and #ref(label("fig:manhattan"), supplement: [Figure]) for $h$. Which of the two would A$""^star.op$ expand first, and why does the second one never get its turn?

#emph[Answer.] $\( 6 \, 4 \)$ has $g = 4$, $h = 9$, $f = 13$. $\( 3 \, 4 \)$ has $g = 13$, $h = 6$, $f = 19$. A$""^star.op$ reaches the charger at $f = 13$ long before $f = 19$ comes up.]

#strong[Setup.] Run the imports and path setup first, and keep this kernel state for the later questions. In the script version the first seven lines also set the working directory. #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 1, last: 7, lang: "python") #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 8, last: 25, lang: "python")

#callout("labquestion", title: [Question 1 --- Establish the baseline])[Run UCS for the three standard queries. UCS is exact for non-negative costs, so its cost is the reference every informed method is judged against.] #callout("labanswer", title: [Worked answer])[
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/02-trace.typ"
 #source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 27, last: 34, lang: "python") *Reference output.*

#code-block("Q1 UCS    11,461.3 km   1851 expanded   KUL -> HKT -> LED -> HEL -> KEF\nQ2 UCS    17,817.4 km   3002 expanded   SIN -> JNB -> GRU -> EZE\nQ3 UCS    14,813.3 km   3042 expanded   NRT -> HKG -> MRU -> CPT", lang: "text")

#strong[What it means.] UCS reproduces the Lab~1 distances. These are the optimal costs, so an informed method that returns more has traded quality for speed.]

#callout("labquestion", title: [Question 2 --- Implement the heuristic and run GBFS and A$""^star.op$])[Use the great-circle distance from the current airport to the goal as $h \( n \)$. GBFS orders the frontier by $h$ alone; A$""^star.op$ by $g + h$. Write the heuristic as a function that fixes the goal, then run both algorithms. #emph[Predict first:] on which queries, if any, will GBFS match the UCS cost?] #callout("labanswer", title: [Worked answer])[Read the heuristic factory first. Changing the goal requires a new heuristic, because each one remembers its own goal: 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/02-worked-case.typ"


#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 36, last: 50, lang: "python") *Reference output.*

#code-block("Q1 GBFS   12,500.5 km      2 expanded   KUL -> LHR -> KEF\nQ1 A*     11,461.3 km     69 expanded   KUL -> HKT -> LED -> HEL -> KEF\nQ2 GBFS   17,817.4 km      3 expanded   SIN -> JNB -> GRU -> EZE\nQ2 A*     17,817.4 km    151 expanded   SIN -> JNB -> GRU -> EZE\nQ3 GBFS   15,811.3 km      3 expanded   NRT -> DOH -> JNB -> CPT\nQ3 A*     14,813.3 km     63 expanded   NRT -> HKG -> MRU -> CPT", lang: "text")

#strong[What it means.] A$""^star.op$ returns exactly the UCS cost on every query while expanding far fewer states. GBFS expands only a handful of states, but two of its three routes are longer because it ignores the distance already travelled.]

#strong[Connect it to the chapter.] Keep this picture in mind for the next three questions: $g$ is known, $h$ is estimated. 
#include "/ARTIFICIAL INTELLIGENCE/labs/visuals/02-informed-search-chapter.typ"


#callout("labquestion", title: [Question 3 --- Check admissibility empirically])[An admissible heuristic never overestimates the true remaining cost. Run Dijkstra once on the reversed graph to get the exact cost from every airport #emph[to] the goal, then compare $h$ with that exact cost for ten airports spread across the range. Save `heuristic_check.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 52, last: 90, lang: "python") *Reference output.*

#code-block("Admissibility violations: 0 of 30", lang: "text")

#strong[What it means.] Zero violations in thirty checks: the slack column is never negative, and it runs from 0 up to about 26,000~km. A straight-line distance can never exceed the length of any actual route between the same two points, so Haversine is admissible and consistent by the triangle inequality. The table is an empirical check; the geometry is the guarantee.]

#callout("labquestion", title: [Question 4 --- Compare the methods])[Put cost, hops, expanded nodes, maximum frontier and runtime for UCS, GBFS and A$""^star.op$ in one table, add the optimality gap relative to UCS, and save `metrics.csv`.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 92, last: 105, lang: "python") *Reference output.*

#code-block("A* matches UCS on every query: True\nMean A* expansion reduction vs UCS: 96.4", lang: "text")

#strong[What it means.] A$""^star.op$ keeps the UCS cost (gap 0 %) while expanding roughly 96 % fewer states. GBFS is the cheapest to run but returns routes up to 9 % longer. The consistent Haversine heuristic buys speed without giving up optimality; greed buys more speed by giving it up.]

#callout("labquestion", title: [Question 5 --- Stress the guarantee])[Repeat the queries with the inflated heuristic $1.5 thin h$ (weighted A$""^star.op$). Explain when the returned cost changes.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 107, last: 117, lang: "python")

#strong[What it means.] Multiplying $h$ by 1.5 makes it inadmissible: it can now overestimate the remaining distance, so a route that #emph[looks] closer to the goal is expanded first and returned. The cost changes when the optimal route detours through airports that are geographically further from the goal than a rival hop (Q1 and Q3). When the optimal route already heads straight for the goal (Q2) nothing changes. Expansions fall to a handful, and the price is a route up to 7 % longer.]

#callout("labquestion", title: [Question 6 --- Save the evidence])[Save an expanded-nodes figure for UCS, GBFS and A$""^star.op$. The two tables were saved above.] #callout("labanswer", title: [Worked answer])[#source-code("/ARTIFICIAL INTELLIGENCE/all_experiments/lab02_informed_search_worked.py", first: 119, last: 125, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/ARTIFICIAL INTELLIGENCE/labs/visuals/02-notebook-reference.png", width: 90%)] *Reference output.*

#code-block("Saved: ['expanded_nodes.png', 'heuristic_check.csv', 'metrics.csv']", lang: "text")

#strong[Read the result.] Regenerate this plot rather than copying it. The vertical axis is logarithmic, so equal gaps mean equal ratios.]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these three tasks. All of them use functions already defined above.

+ #strong[Turn the guess off.] Run A$""^star.op$ with $h = 0$ on the three standard queries and compare with UCS. What do you predict for cost and for expansions?

+ #strong[Sweep the weight.] For KUL$arrow.r$KEF, run A$""^star.op$ with weights 0, 0.5, 0.9, 1, 1.1, 1.2, 1.5, 2 and 5, and tabulate cost, hops and expansions. Where does the cost first change, and what happens to expansions on each side of that point?

+ #strong[A units bug.] Express $h$ in miles (weight 0.621) and then in metres (weight 1000), still adding it to $g$ in kilometres. Which one breaks the guarantee, and why?

#code-block("for w in [0, 0.5, 0.9, 1, 1.1, 1.2, 1.5, 2, 5]:\n    r = astar(graph, \"KUL\", \"KEF\", heuristic_to(\"KEF\", weight=w))\n    print(f\"w={w:<4} {r.path_cost_km:>9,.0f} km  {r.hops} hops  {r.expanded:>5} expanded\")", lang: "python")]

#callout("expectedfindings", title: [Expected findings])[+ Exactly the UCS results: same cost and same expansions (1,851, 3,002 and 3,042). A$""^star.op$ with $h = 0$ #emph[is] UCS.

+ Cost stays 11,461~km up to $w = 1$, while expansions fall from 1,851 to 1,210, 399 and 69. At $w = 1.1$ the cost rises to 11,483~km with 4 expansions, at $w = 1.2$ to 11,584~km, at $w = 1.5$ and $w = 2$ to 12,274~km, and at $w = 5$ to 12,500~km with 2 expansions, the same route as GBFS. A larger admissible guess saves work for free; beyond $w = 1$ the saving starts to cost quality.

+ Miles keep the guarantee, because $h$ only got smaller (same route, 1,001 expansions). Metres break it, because $h$ is now 1,000 times too large and swamps $g$ (the 12,500~km GBFS route, 2 expansions).]

#callout("troubleshoot", title: [Troubleshooting])[/ `KeyError` on an airport code: #block[
An endpoint was removed during cleaning. Check that the code is in `coords` before searching.
]

/ A$""^star.op$ returns a costlier route than UCS: #block[
Check that $h$ is in kilometres and that you did not leave a weight above 1 in `heuristic_to`.
]

/ Violations in the admissibility check: #block[
The reversed graph must reverse every edge. If you edited `reverse`, compare with the listing above.
]]

#callout("verification", title: [Verification checklist])[- UCS reproduces the Lab~1 costs for the three standard queries.

- A$""^star.op$ returns the UCS cost on every query (gap 0 %) while expanding far fewer states; GBFS returns at least one longer route.

- The admissibility check finds no negative slack: the Haversine heuristic never overestimates.

- With the inflated heuristic $1.5 thin h$ you can say which queries change cost, and why.

- `results/lab02/` holds `metrics.csv`, `heuristic_check.csv` and `expanded_nodes.png`.]

#callout("labdeliverable", title: [Submission checklist])[- Restart the kernel and run all cells without errors.

- Submit the executed notebook, including your #emph[Your turn] cells, and the generated `results/lab02/` folder.

- Add a short conclusion: why A$""^star.op$ matches UCS, why GBFS can return a longer route, and what guarantee is lost when the heuristic is multiplied by 1.5.]
