#import "/.shared/typst/utp.typ": *
#unit("chapters", "12-final-project")


#heading(level: 1)[Final Project: Algorithm Comparison]
<ch:final-project>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know how to trace algorithms, state time/space complexity, and implement representative course algorithms in C++.

*By the end, you can:* choose a valid pair of related algorithms, design a fair comparison, instrument operation counts and runtime, build the required interactive app, and structure the written report around evidence rather than claims.]

The final-project guideline turns the course into a small comparative experiment. The required deliverable is not only a written report: the group must also build an interactive web or mobile application that demonstrates two algorithms from the #emph[same category] side by side.

#callout("projectrequirement", title: [Project requirement])[Choose two related algorithms or operations, explain how both work, and compare their time complexity, space complexity, number of steps or operations, use cases, and practicality. The application must accept sample input, execute both choices, show the results, report steps and measurable time, provide visual output, and present a side-by-side comparison.]


#heading(level: 2)[What counts as a valid comparison?]


The project guideline explicitly requires algorithms from the same category. It gives the following examples.

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Category], [Example pair], [Course connection],),
    table.hline(),
    [Sorting], [Bubble Sort vs Merge Sort], [Chapter~#ref(label("ch:search-sort"), supplement: none)],
    [Searching], [Linear Search vs Binary Search], [Chapter~#ref(label("ch:search-sort"), supplement: none)],
    [Data-structure operations], [Array insertion vs linked-list insertion], [Chapters~#ref(label("ch:arrays"), supplement: none) and~#ref(label("ch:linked-lists"), supplement: none)],
    [Graph traversal], [BFS vs DFS], [Chapter~#ref(label("ch:graphs"), supplement: none)],
    [Recursion vs iteration], [Factorial or Fibonacci implemented both ways], [General algorithm-design comparison],
  )]
  , kind: table
  )

The guideline also permits other pairs, provided the two choices are genuinely related. A comparison such as Bubble Sort vs Binary Search is invalid because the algorithms solve different problems.

#callout("recommendedworkflow", title: [Recommended workflow])[A strong pair has one shared task and one clear independent variable: the algorithm. Keep the input, hardware, programming language, output requirement, and measurement method the same. That makes the comparison easier to explain and more defensible.]


#heading(level: 2)[Required comparison dimensions]


For each algorithm, the report is expected to cover how it works, a step-by-step example, best/average/worst time complexity, space complexity, and pros/cons. The comparison itself should also discuss step counts, use cases, and practicality.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Dimension], [What to collect],),
    table.hline(),
    [Working principle], [A concise description of the rule each algorithm follows.],
    [Correctness evidence], [Identical expected output for the same valid input, or an explanation of why outputs differ.],
    [Time complexity], [Best, average, and worst cases where meaningful. State assumptions.],
    [Space complexity], [Auxiliary memory and any important representation cost.],
    [Operation count], [Comparisons, swaps, probes, node visits, queue/stack operations, or another pair-specific count.],
    [Measured runtime], [Repeated timing under the same conditions; treat small-input timings cautiously.],
    [Practicality], [Input constraints, setup cost, ease of implementation, and when one method is a better fit.],
    [Use cases], [One or two scenarios where the trade-off matters.],
  )]
  , kind: table
  )


#heading(level: 2)[Counting operations in C++]


An operation counter makes the comparison visible even when runtime is too small or noisy to interpret. The exact counter should match the algorithm.

#code-block("struct Metrics {\n    long long comparisons = 0;\n    long long swaps = 0;\n    long long visits = 0;\n};\n\nvoid bubbleSortMeasured(vector<int>& a, Metrics& m) {\n    int n = static_cast<int>(a.size());\n    for (int pass = 0; pass < n - 1; ++pass) {\n        for (int i = 0; i < n - 1 - pass; ++i) {\n            ++m.comparisons;\n            if (a[i] > a[i + 1]) {\n                swap(a[i], a[i + 1]);\n                ++m.swaps;\n            }\n        }\n    }\n}", lang: "text")

#callout("keyidea", title: [Key idea])[Do not force every algorithm into the same notion of a "step." Define the metric before the experiment. For sorting, comparisons and swaps are natural. For searching, comparisons are natural. For graphs, visited vertices/edges and queue/stack operations may be more meaningful.]


#heading(level: 2)[Measuring runtime fairly]


The project asks for time taken #emph[if measurable]. C++ can use `std::chrono`; however, one very short execution can be dominated by timer resolution, process scheduling, caching, or startup effects.

#code-block("#include <chrono>\nusing namespace std::chrono;\n\nauto start = high_resolution_clock::now();\nalgorithm(input);\nauto stop = high_resolution_clock::now();\n\nauto elapsed = duration_cast<microseconds>(stop - start).count();\ncout << elapsed << \" microseconds\\n\";", lang: "text")

#callout("recommendedworkflow", title: [Recommended workflow])[Run each algorithm multiple times on copied input and report a median or average. For sorting, never let Algorithm 2 receive the already-sorted output produced by Algorithm 1 unless "sorted input" is intentionally the scenario being tested. Preserve an untouched master input and copy it before each run.]


#heading(level: 2)[Application requirements]


The final-project guideline requires a web or mobile application before report submission. The interface should help even a non-computer-science user interpret the comparison.

#callout("projectrequirement", title: [Project requirement])[The app must allow sample-data input, execute both algorithms, display results, show step counts, show time taken when measurable, include visual outputs, and provide a side-by-side comparison. The guideline specifically encourages interactive elements such as dropdowns and buttons.]

A practical screen flow is:

+ Choose the algorithm pair or open the fixed project pair.

+ Enter or generate the input dataset.

+ Validate the input and show any precondition, such as "binary search requires sorted data."

+ Run Algorithm 1 and Algorithm 2 on equivalent copies of the input.

+ Display result, operation count, elapsed time, and a compact visual trace.

+ Show a comparison table and one plain-language interpretation.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/f0d807f825deea83.svg")], caption: [Screen flow for the comparison application. The two algorithms must receive equivalent copies of the same input, or the measured difference reflects the data rather than the algorithms.]) <fig:app-flow>


#heading(level: 2)[Report structure required by the guideline]


The written report is organized into six main parts.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Report section], [Required content],),
    table.hline(),
    [Introduction], [Identify the algorithms and explain why the comparison is useful or interesting.],
    [Algorithm Explanation], [Explain each method, give a step-by-step example, state best/average/worst time and space complexity, and discuss pros/cons.],
    [Comparison Table], [Compare working principle, time, space, number of steps, and best use cases side by side.],
    [Use Case Comparison], [Give one or two real-world scenarios and explain why one algorithm is more suitable in each.],
    [Visual Aid (optional)], [Add flowcharts, diagrams, operation-count graphs, or screenshots from the application.],
    [Conclusion], [Summarize where each algorithm is more efficient or practical and state the group's takeaways.],
  )]
  , kind: table
  )


#heading(level: 2)[Team and repository requirements]


#callout("projectrequirement", title: [Project requirement])[Teams may contain a maximum of four students. Each group submits one report and one application. The team leader should upload the code to a GitHub repository, give other team members access, reference members there, and include the repository in the report so the code can be accessed.]

#callout("recommendedworkflow", title: [Recommended workflow])[Use a simple repository structure such as `/app`, `/algorithm-core`, `/tests`, `/docs`, and a clear `README`. Keep algorithm logic separate from UI code so the same functions can be tested independently and then called by the web/mobile interface.]


#heading(level: 2)[Project pair ideas from this course]


The following pairs stay within the same problem category and have useful trade-offs to visualize.

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Pair], [Useful evidence to visualize],),
    table.hline(),
    [Linear vs binary search], [Comparisons as $n$ grows; binary-search precondition; target position.],
    [Bubble vs insertion sort], [Comparisons and swaps for random, sorted, and nearly sorted input.],
    [Bubble vs merge sort], [Quadratic growth vs divide-and-conquer behavior; extra merge storage.],
    [BFS vs DFS], [Visit order, frontier data structure, discovered path behavior.],
    [Array vs linked-list insertion], [Shifts vs pointer updates, plus the cost of locating the insertion position.],
    [Linear vs quadratic probing], [Probe sequences and clustering after the same collisions.],
    [Min-heap vs max-heap operations], [Heap restoration path and which extreme is available at the root.],
  )]
  , kind: table
  )


#heading(level: 2)[Submission checklist]


#callout("verification", title: [Verification checklist])[Before submission, verify that the package contains:

- project title and complete group details;

- introduction to the selected pair;

- detailed explanation and code for both algorithms;

- step-by-step examples and complexity analysis;

- a comprehensive side-by-side comparison table;

- real-world use-case analysis;

- a conclusion supported by the collected evidence;

- the functioning web/mobile application;

- the GitHub repository reference in the report;

- optional diagrams, graphs, and application screenshots where they improve interpretation.]
