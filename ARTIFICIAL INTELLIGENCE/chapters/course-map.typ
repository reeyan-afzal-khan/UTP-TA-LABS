#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

The course moves from searching a graph to learning from data and back to search in new forms. Chapter~@ch:toolkit sets up the project folders and Python environment. After that, each chapter builds an idea and each lab sheet right after it puts that idea to work, following the same steps: define the task, validate the data, run a controlled experiment, interpret the results, and submit the executed notebook with its generated evidence.

#utpfigure[
  #canvas({
    node((0, 0), [#coursemapcard([STAGE 01], [Route search], [BFS, DFS, UCS, and A$""^(star.op)$ on a maze and airline data])], name: "a", ..card)
    node(right-of("a", 0.66), [#coursemapcard([STAGE 02], [Reasoning], [Fuzzy logic, ANFIS, and robot sensing])], name: "b", ..card)
    node(right-of("b", 0.66), [#coursemapcard([STAGE 03], [Language], [Handwriting OCR and sentiment])], name: "c", ..card)
    node(below-of("c", 0.58), [#coursemapcard([STAGE 04], [Optimization], [Local search and genetic algorithms])], name: "d", ..card)
    node(left-of("d", 0.66), [#coursemapcard([STAGE 05], [Games], [Minimax and Monte Carlo Tree Search])], name: "e", ..finalcard)
    connect("a", "b", ..arr)
    connect("b", "c", ..arr)
    connect("c", "d", ..arr)
    connect("d", "e", ..arr)
  })
]

#utptable[
  #tabularx(
    columns: (8%, 31%, 1fr),
    align: (center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Focus], [Key question]),
    [1], [Uninformed and informed search], [How is a good route found, and what does finding it cost?],
    [2], [Fuzzy systems and robot sensing], [How can imprecise readings drive a sound decision?],
    [3], [OCR and text classification], [How is text turned into evidence a model can use?],
    [4], [Local search and evolutionary optimization], [What if only the final answer counts, and how can a population of candidates find it?],
    [5], [Adversarial search], [What if someone fights back?],
  )
]

#heading(depth: 2, numbering: none)[Datasets and what each stage builds]

Stages 1 to 4 work on public Kaggle datasets, listed with download links in Chapter~#ref(<ch:toolkit>). Stage~5, and the local search of Stage~4, run on small puzzles that need no data.

#utptable[
  #tabularx(
    columns: (8%, 9%, 30%, 1fr),
    align: (center, center, left, left),
    styles: (navy-bold,),
    header: ([Stage], [Labs], [Dataset], [What you build]),
    [1], [1--3], [OpenFlights routes and airports], [BFS, DFS, UCS, GBFS, and A$""^(star.op)$, then a tested command-line toolkit.],
    [2], [4--5], [UCI Air Quality; SCITOS wall-following sensor readings], [Fuzzy and ANFIS models, and an interpretable sensor-to-action controller.],
    [3], [6--7], [Doctor Handwriting Recognition; Twitter Airline Sentiment], [A handwriting OCR evaluation and a three-class airline sentiment benchmark.],
    [4], [8], [Medical Cost Personal Dataset], [A repeated-run GA regression compared with least squares.],
    [5], [none], [No data: noughts and crosses], [A reading chapter with a runnable demo, closing the five questions of search.],
  )
]

#heading(depth: 2, numbering: none)[How to use this book]

Every chapter builds one idea, starting from a small example you can check by hand and ending on the real data of the lab that follows it. A good route through one lab session looks like this:

#utpsteps[
  + #strong[Read the chapter with a pen.] Work the worked examples yourself instead of only reading them, and try the practice boxes.
  + #strong[Answer the check.] Write down your answers to #emph[Check your understanding] before you read the answers below it.
  + #strong[Do the lab sheet.] Each question has the same number in the sheet and in its notebook. Predict, run, compare with the reference output, and explain.
  + #strong[Finish with #emph[Your turn].] These tasks go beyond the worked answers. Record your own numbers first, then read the expected findings.
  + #strong[Hand in.] Work through the verification and submission checklists at the end of the sheet.
]

The coloured boxes each have one job:

#utptable[
  #tabularx(
    columns: (32%, 1fr),
    styles: (navy-bold,),
    header: ([Box], [What it is for]),
    [Analogy, Conceptual intuition], [The everyday picture, before the formal version. Every analogy breaks down somewhere, so use it to get started and then trust the definition.],
    [Key idea], [The one sentence to carry away from a section.],
    [Worked example], [A calculation or trace to follow with a pen.],
    [Common mistake], [What reliably goes wrong here, and why.],
    [Practice, Your turn], [Something for you to do. Predict first, then run it.],
    [Chapter recap], [What a reader should carry forward from the chapter.],
    [Reference note], [History or background you can read past without losing the thread.],
  )
]

#sourcebasis[
  The robot-and-maze storyline of the search chapters, and several analogies across the book (the ripple, the line at a shop, the pile of plates, the foggy hillside, the dimmer switch, breeding boards), are adapted from two video lectures: #link("https://www.youtube.com/watch?v=fCEvvkAbJOs")[an hour on search] and #link("https://www.youtube.com/watch?v=42IVf4m-5fk")[an hour on machine learning]. The maze, puzzles, game positions, code and all numbers in this book are our own, and every one can be reproduced by running the programs in `all_experiments/`.
]
