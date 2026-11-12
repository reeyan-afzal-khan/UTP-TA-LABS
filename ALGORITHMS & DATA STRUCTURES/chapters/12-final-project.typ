#import "/.shared/typst/utp.typ": *
#unit("chapters", "12-final-project")

= Final Project: Algorithm Comparison <ch:final-project>

#chapterguide[Know how to trace algorithms, state time/space complexity, and implement representative course algorithms in C++.][choose a valid pair of related algorithms, design a fair comparison, instrument operation counts and runtime, build the required interactive app, and structure the written report around evidence rather than claims.]

The final-project guideline turns the course into a small comparative experiment. The required deliverable is not only a written report: the group must also build an interactive web or mobile application that demonstrates two algorithms from the #emph[same category] side by side.

#projectrequirement[
  Choose two related algorithms or operations, explain how both work, and compare their time complexity, space complexity, number of steps or operations, use cases, and practicality. The application must accept sample input, execute both choices, show the results, report steps and measurable time, provide visual output, and present a side-by-side comparison.
]

== What counts as a valid comparison?

The project guideline explicitly requires algorithms from the same category. It gives the following examples.

#utptable[
  #tabularx(
    columns: (24%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Category], [Example pair], [Course connection]),
    [Sorting], [Bubble Sort vs Merge Sort], [Chapter~@ch:search-sort],
    [Searching], [Linear Search vs Binary Search], [Chapter~@ch:search-sort],
    [Data-structure operations], [Array insertion vs linked-list insertion], [Chapters~@ch:arrays and~@ch:linked-lists],
    [Graph traversal], [BFS vs DFS], [Chapter~@ch:graphs],
    [Recursion vs iteration], [Factorial or Fibonacci implemented both ways], [General algorithm-design comparison],
  )
]

The guideline also permits other pairs, provided the two choices are genuinely related. A comparison such as Bubble Sort vs Binary Search is invalid because the algorithms solve different problems.

#recommendedworkflow[
  A strong pair has one shared task and one clear independent variable: the algorithm. Keep the input, hardware, programming language, output requirement, and measurement method the same. That makes the comparison easier to explain and more defensible.
]

== Required comparison dimensions

For each algorithm, the report is expected to cover how it works, a step-by-step example, best/average/worst time complexity, space complexity, and pros/cons. The comparison itself should also discuss step counts, use cases, and practicality.

#utptable[
  #tabularx(
    columns: (23%, 1fr),
    styles: (navy-bold,),
    header: ([Dimension], [What to collect]),
    [Working principle], [A concise description of the rule each algorithm follows.],
    [Correctness evidence], [Identical expected output for the same valid input, or an explanation of why outputs differ.],
    [Time complexity], [Best, average, and worst cases where meaningful. State assumptions.],
    [Space complexity], [Auxiliary memory and any important representation cost.],
    [Operation count], [Comparisons, swaps, probes, node visits, queue/stack operations, or another pair-specific count.],
    [Measured runtime], [Repeated timing under the same conditions; treat small-input timings cautiously.],
    [Practicality], [Input constraints, setup cost, ease of implementation, and when one method is a better fit.],
    [Use cases], [One or two scenarios where the trade-off matters.],
  )
]

== Counting operations in C++

An operation counter makes the comparison visible even when runtime is too small or noisy to interpret. The exact counter should match the algorithm.

```cpp
    long long comparisons = 0;
    long long swaps = 0;
    long long visits = 0;
};

void bubbleSortMeasured(vector<int>& a, Metrics& m) {
    int n = static_cast<int>(a.size());
    for (int pass = 0; pass < n - 1; ++pass) {
        for (int i = 0; i < n - 1 - pass; ++i) {
            ++m.comparisons;
            if (a[i] > a[i + 1]) {
                swap(a[i], a[i + 1]);
                ++m.swaps;
            }
        }
    }
}
```

#keyidea[
  Do not force every algorithm into the same notion of a “step.” Define the metric before the experiment. For sorting, comparisons and swaps are natural. For searching, comparisons are natural. For graphs, visited vertices/edges and queue/stack operations may be more meaningful.
]

== Measuring runtime fairly

The project asks for time taken #emph[if measurable]. C++ can use `std::chrono`; however, one very short execution can be dominated by timer resolution, process scheduling, caching, or startup effects.

```cpp
using namespace std::chrono;

auto start = high_resolution_clock::now();
algorithm(input);
auto stop = high_resolution_clock::now();

auto elapsed = duration_cast<microseconds>(stop - start).count();
cout << elapsed << " microseconds\n";
```

#recommendedworkflow[
  Run each algorithm multiple times on copied input and report a median or average. For sorting, never let Algorithm 2 receive the already-sorted output produced by Algorithm 1 unless “sorted input” is intentionally the scenario being tested. Preserve an untouched master input and copy it before each run.
]

== Application requirements

The final-project guideline requires a web or mobile application before report submission. The interface should help even a non-computer-science user interpret the comparison.

#projectrequirement[
  The app must allow sample-data input, execute both algorithms, display results, show step counts, show time taken when measurable, include visual outputs, and provide a side-by-side comparison. The guideline specifically encourages interactive elements such as dropdowns and buttons.
]

A practical screen flow is:

#utpsteps[
  + Choose the algorithm pair or open the fixed project pair.
  + Enter or generate the input dataset.
  + Validate the input and show any precondition, such as “binary search requires sorted data.”
  + Run Algorithm 1 and Algorithm 2 on equivalent copies of the input.
  + Display result, operation count, elapsed time, and a compact visual trace.
  + Show a comparison table and one plain-language interpretation.
]

#utpfig([Screen flow for the comparison application. The two algorithms must receive equivalent copies of the same input, or the measured difference reflects the data rather than the algorithms.], label: <fig:app-flow>)[
  #canvas({
    let stage = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3, min-height: 1, align: center, font: font("small", weight: "bold", fill: navy), inner-sep: 1.8mm)
    let result = (draw: green, fill: pale-teal, rounded: 2mm, min-width: 7.7, min-height: 1.2, align: center, font: font("small", weight: "bold", fill: navy), inner-sep: 1.8mm)
    let flow = (line-width: 0.9465pt, draw: teal, rounded: 1.5mm, end: tip("Stealth", length: 2.3mm, line: 0.9465pt))
    node((1.75, 2.25), [#strong[1\. Input / generate] \ #v(-0.12em)
  #fsize("script")[dataset]], name: "input", font: font("small"), ..stage)
    node((5.75, 2.25), [#strong[2\. Validate input] \ #v(-0.12em)
   #fsize("script")[e.g. sorted-data requirement]], name: "validate", font: font("small"), ..stage, draw: orange, fill: pale-orange, min-width: 3.35)
    connect("input.east", "validate.west", ..flow)
    coordinate("fork", (rel: (0, -0.55), to: "validate.south"))
    connect("validate.south", "fork", ..flow)
    circle-at("fork", 1.2951pt, fill: teal, draw: none)
    node((rel: (0, 0.12), to: "fork"), [equivalent input copies], font: font("small"), ..utplabel, anchor: "south", fill: white, inner-sep: 0.797pt, text: teal)
    node((3.65, 0.35), [#strong[3A. Run Algorithm 1]], name: "a1", font: font("small"), ..stage)
    node((7.85, 0.35), [#strong[3B. Run Algorithm 2]], name: "a2", font: font("small"), ..stage)
    connect("fork", "-|", "a1.north", ..flow)
    connect("fork", "-|", "a2.north", ..flow)
    node((5.75, -1.55), [#strong[4\. Side-by-side comparison] \ #v(-0.12em)
   #fsize("script")[result • operations • time • visual trace] \ #v(-0.12em)
   #fsize("script")[#text(fill: mix(green, 45%, other: black))[same input $arrow.r$ the measured difference belongs to the algorithm]]], name: "out", font: font("small"), ..result)
    connect("a1.south", (rel: (0, -0.38), to: "a1.south"), "-|", (rel: (-1.65, 0), to: "out.north"), ..flow)
    connect("a2.south", (rel: (0, -0.38), to: "a2.south"), "-|", (rel: (1.65, 0), to: "out.north"), ..flow)
  })
]

== Report structure required by the guideline

The written report is organized into six main parts.

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    header: ([Report section], [Required content]),
    [Introduction], [Identify the algorithms and explain why the comparison is useful or interesting.],
    [Algorithm Explanation], [Explain each method, give a step-by-step example, state best/average/worst time and space complexity, and discuss pros/cons.],
    [Comparison Table], [Compare working principle, time, space, number of steps, and best use cases side by side.],
    [Use Case Comparison], [Give one or two real-world scenarios and explain why one algorithm is more suitable in each.],
    [Visual Aid (optional)], [Add flowcharts, diagrams, operation-count graphs, or screenshots from the application.],
    [Conclusion], [Summarize where each algorithm is more efficient or practical and state the group’s takeaways.],
  )
]

== Team and repository requirements

#projectrequirement[
  Teams may contain a maximum of four students. Each group submits one report and one application. The team leader should upload the code to a GitHub repository, give other team members access, reference members there, and include the repository in the report so the code can be accessed.
]

#recommendedworkflow[
  Use a simple repository structure such as `/app`, `/algorithm-core`, `/tests`, `/docs`, and a clear `README`. Keep algorithm logic separate from UI code so the same functions can be tested independently and then called by the web/mobile interface.
]

== Project pair ideas from this course

The following pairs stay within the same problem category and have useful trade-offs to visualize.

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    styles: (navy-bold,),
    header: ([Pair], [Useful evidence to visualize]),
    [Linear vs binary search], [Comparisons as $n$ grows; binary-search precondition; target position.],
    [Bubble vs insertion sort], [Comparisons and swaps for random, sorted, and nearly sorted input.],
    [Bubble vs merge sort], [Quadratic growth vs divide-and-conquer behavior; extra merge storage.],
    [BFS vs DFS], [Visit order, frontier data structure, discovered path behavior.],
    [Array vs linked-list insertion], [Shifts vs pointer updates, plus the cost of locating the insertion position.],
    [Linear vs quadratic probing], [Probe sequences and clustering after the same collisions.],
    [Min-heap vs max-heap operations], [Heap restoration path and which extreme is available at the root.],
  )
]

== Submission checklist

#verification[
  Before submission, verify that the package contains:

  - project title and complete group details;
  - introduction to the selected pair;
  - detailed explanation and code for both algorithms;
  - step-by-step examples and complexity analysis;
  - a comprehensive side-by-side comparison table;
  - real-world use-case analysis;
  - a conclusion supported by the collected evidence;
  - the functioning web/mobile application;
  - the GitHub repository reference in the report;
  - optional diagrams, graphs, and application screenshots where they improve interpretation.
]
