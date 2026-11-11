#import "/.shared/typst/utp.typ": *


#heading(level: 1, numbering: none)[Course Map]


The course moves from searching a graph to learning from data and back to search in new forms. Chapter~#ref(label("ch:toolkit"), supplement: none) sets up the project folders and Python environment. After that, each chapter builds an idea and each lab sheet right after it puts that idea to work, following the same steps: define the task, validate the data, run a controlled experiment, interpret the results, and submit the executed notebook with its generated evidence.

#callout("utpfigure", title: [])[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/4a4e1f06a50ba420.svg")]

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Stage], [Focus], [Key question],),
    table.hline(),
    [1], [Uninformed and informed search], [How is a good route found, and what does finding it cost?],
    [2], [Fuzzy systems and robot sensing], [How can imprecise readings drive a sound decision?],
    [3], [OCR and text classification], [How is text turned into evidence a model can use?],
    [4], [Local search and evolutionary optimization], [What if only the final answer counts, and how can a population of candidates find it?],
    [5], [Adversarial search], [What if someone fights back?],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[Datasets and what each stage builds]
 Stages 1 to 4 work on public Kaggle datasets, listed with download links in Chapter~#ref(label("ch:toolkit"), supplement: none). Stage~5, and the local search of Stage~4, run on small puzzles that need no data.

#figure(
  align(center)[#table(
    columns: 4,
    align: (left,left,left,left,),
    table.header([Stage], [Labs], [Dataset], [What you build],),
    table.hline(),
    [1], [1--3], [OpenFlights routes and airports], [BFS, DFS, UCS, GBFS, and A$""^star.op$, then a tested command-line toolkit.],
    [2], [4--5], [UCI Air Quality; SCITOS wall-following sensor readings], [Fuzzy and ANFIS models, and an interpretable sensor-to-action controller.],
    [3], [6--7], [Doctor Handwriting Recognition; Twitter Airline Sentiment], [A handwriting OCR evaluation and a three-class airline sentiment benchmark.],
    [4], [8], [Medical Cost Personal Dataset], [A repeated-run GA regression compared with least squares.],
    [5], [none], [No data: noughts and crosses], [A reading chapter with a runnable demo, closing the five questions of search.],
  )]
  , kind: table
  )


#heading(level: 2, numbering: none)[How to use this book]


Every chapter builds one idea, starting from a small example you can check by hand and ending on the real data of the lab that follows it. A good route through one lab session looks like this:

+ #strong[Read the chapter with a pen.] Work the worked examples yourself instead of only reading them, and try the practice boxes.

+ #strong[Answer the check.] Write down your answers to #emph[Check your understanding] before you read the answers below it.

+ #strong[Do the lab sheet.] Each question has the same number in the sheet and in its notebook. Predict, run, compare with the reference output, and explain.

+ #strong[Finish with #emph[Your turn].] These tasks go beyond the worked answers. Record your own numbers first, then read the expected findings.

+ #strong[Hand in.] Work through the verification and submission checklists at the end of the sheet.

The coloured boxes each have one job:

#figure(
  align(center)[#table(
    columns: 2,
    align: (left,left,),
    table.header([Box], [What it is for],),
    table.hline(),
    [Analogy, Conceptual intuition], [The everyday picture, before the formal version. Every analogy breaks down somewhere, so use it to get started and then trust the definition.],
    [Key idea], [The one sentence to carry away from a section.],
    [Worked example], [A calculation or trace to follow with a pen.],
    [Common mistake], [What reliably goes wrong here, and why.],
    [Practice, Your turn], [Something for you to do. Predict first, then run it.],
    [Chapter recap], [What a reader should carry forward from the chapter.],
    [Reference note], [History or background you can read past without losing the thread.],
  )]
  , kind: table
  )

#callout("sourcebasis", title: [Source basis])[The robot-and-maze storyline of the search chapters, and several analogies across the book (the ripple, the line at a shop, the pile of plates, the foggy hillside, the dimmer switch, breeding boards), are adapted from two video lectures: #link("https://www.youtube.com/watch?v=fCEvvkAbJOs")[an hour on search] and #link("https://www.youtube.com/watch?v=42IVf4m-5fk")[an hour on machine learning]. The maze, puzzles, game positions, code and all numbers in this book are our own, and every one can be reproduced by running the programs in `all_experiments/`.]
