#import "/.shared/typst/utp.typ": *
#unit("labs", "05-visualization")

#labsection(5, label: <sec:lab05>)[Design graphics that answer a question]

#labproject[Visual communication: turn analysis into evidence][
  #strong[Coverage.] Chapter~#ref(<ch:visualization>). \

  #strong[Goal.] You should be able to map analytical questions to chart forms, identify misleading encodings, write evidence-focused captions, and distinguish information revealed by raw and aggregated views. \

  #strong[Datasets.] `red_wine_quality_dataset.csv`; Bike Sharing hourly data are used for the extension. \

  #strong[Scenario.] You are preparing figures for an analytical report. The objective is not decoration: each chart must answer a specific question, use an appropriate visual encoding, and make the intended comparison easy to see.

  #include "visuals/05-flow.typ"

  #strong[Run the complete script.] Start a clean R session in the course folder. Each step continues the same file; comment headings identify the operation performed by the next block.

  ```terminal
  Rscript all_experiments/lab05_visualization.R
  ```

  #strong[Step 1.] Load, validate and prepare the data

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 1, last: 8, lang: "r")

  #strong[Step 2.] Figure 1 - Distribution question: how common is each discrete quality score?

  #include "visuals/05-trace.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 9, last: 13, lang: "r")

  #strong[Step 3.] Figure 2 - Comparison question: how does alcohol content vary by quality score?

  #strong[Use the chapter while coding.] Revisit #link(<ch:visualization>)[the earlier chapter explanation]; match its operation to the variables and state changes below.

  #strong[Follow the supplied implementation.] Use the same quality order across charts. The bar chart answers how common each score is; the alcohol comparison answers how measurements differ within those scores. Keep those denominators and questions distinct.

  #include "visuals/05-worked-case.typ"

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 14, last: 22, lang: "r")

  #strong[Step 4.] Figure 3 - Relationship question: how do two chemical measurements co-vary?

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 23, last: 30, lang: "r")

  #strong[Step 5.] Redesign example: change the question rather than the styling.

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 31, last: 36, lang: "r")

  #strong[Step 6.] Extension - hour-by-weekday heatmap with Bike Sharing.

  #lstinput("/DATA SCIENCE/all_experiments/lab05_visualization.R", first: 37, last: 51, lang: "r")

  #strong[Chapter connection.] Revisit #link(<ch:visualization>)[the chapter explanation] and map its states to the steps below.

  #include "visuals/05-visualization-chapter.typ"

  #verification[
    #strong[Explain and extend your result.] Revise one chart for one explicit audience question. Keep the data unchanged and explain how the axis, ordering or annotation improves the comparison.

    #strong[Required evidence.] Submit a three-figure mini-report. Each figure must have a one-sentence question above it and a two-to-three sentence evidence caption below it. A reader should understand the analytical claim without seeing the R code.

    #strong[Professional standard.] Prefer the simplest chart that makes the required comparison accurately. Visual complexity is justified only when it reveals additional structure.
  ]
]
