#import "/.shared/typst/utp.typ": *

#chapter-star[Course Map]

// One full-width stage: a title line with the chapters at the right, then two short lines.
#let stagehead(title, colour, chapters) = [#text(size: 1.32em, weight: "bold", fill: colour)[#title]#h(1fr)#text(size: 1.12em, weight: "bold")[#chapters]]

#utpfig([How the stages connect. After the shared foundations, labeled data leads to the supervised branch and unlabeled data to the unsupervised branch; both feed the later stages, then the capstone. Each stage names its chapters, its labs, and the checkpoint to reach before moving on.], label: <fig:course-stages>)[
  #canvas(y: 1.17cm, {
    let stage = (draw: blue, fill: pale-blue, rounded: 2mm, text-width: 12.75, min-height: 1.2, align: left, inner-xsep: 4mm, inner-ysep: 2.1mm, font: font("script", fill: navy))
    let gate = (draw: navy, fill: navy, text: white, rounded: 2mm, text-width: 6.8, min-height: 0.78, align: center, font: font("small", weight: "bold"))
    let branch = (rounded: 2mm, text-width: 5.9, min-height: 2.35, align: left, inner-xsep: 3.4mm, inner-ysep: 2.5mm, font: font("script", fill: navy))
    let sup = (..branch, draw: blue, fill: pale-blue)
    let unsup = (..branch, draw: teal, fill: pale-teal)
    let other = (..stage, draw: orange, fill: pale-orange)
    let finish = (..stage, draw: green, fill: pale-teal)
    let branchlabel = (fill: white, inner-xsep: 1.9925pt, inner-ysep: 0.9963pt, font: font("script", weight: "bold", fill: muted))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    let flow = (line-width: widths.thick, draw: teal)
    let junction = (shape: "circle", fill: teal, inner-sep: 1.1955pt)
    node((0, 9.0), [#stagehead([Stage 1: Orientation and tools], blue, [Chapters #ref(<ch:toolkit>)--@ch:pydata]) \
      Set up Python, meet the study log and the recipe, follow the workflow, and learn NumPy, pandas and plots. \
      #strong[Checkpoint:] run the environment and name the model, loss, and optimizer of a method.], name: "a", ..stage)
    node((0, 7.25), [#stagehead([Stage 2: Shared foundations], blue, [Chapters #ref(<ch:data>)--@ch:feature-engineering]) \
      Data quality and splits; gradient descent; statistics and geometry; exploration, tests, and features. \
      #strong[Labs 0--1:] a first look at a table; features. #strong[Checkpoint:] separate fixed rules from fitted choices.], name: "b", ..stage)
    node((0, 5.75), [Does your log hold the answers?], name: "g", ..gate)
    node((-3.45, 3.45), [#align(center)[#strong[#text(fill: blue)[Stage 3A: Supervised workflow #parbreak() ]]]#align(center)[#strong[Chapters #ref(<ch:supervised>)--@ch:training #parbreak() ]]#v(3pt)Losses and baselines; metrics, validation, regularization, and tuning. #parbreak() #strong[Checkpoint:] choose models without using the final test set.], name: "s1", ..sup)
    node((-3.45, 0.75), [#align(center)[#strong[#text(fill: blue)[Stage 3B: Supervised models #parbreak() ]]]#align(center)[#strong[Chapters #ref(<ch:regression>)--@ch:feature-selection #parbreak() ]]#v(3pt)Linear/logistic models, KNN, naive Bayes, trees, ensembles, SVMs, and feature selection. #parbreak() #strong[Labs 2--3:] apply the workflow, compare families, and save a fitted model.], name: "s2", ..sup)
    node((3.45, 3.45), [#align(center)[#strong[#text(fill: teal)[Stage 4A: Unsupervised workflow #parbreak() ]]]#align(center)[#strong[Chapter @ch:unsupervised #parbreak() ]]#v(3pt)Define structure and assess stability, geometry, reconstruction, and domain evidence. #parbreak() #strong[Checkpoint:] evaluate without assuming a single correct answer.], name: "u1", ..unsup)
    node(below-of("u1", distance-y("s2.north", "s1.south")), [#align(center)[#strong[#text(fill: teal)[Stage 4B: Unsupervised models #parbreak() ]]]#align(center)[#strong[Chapters #ref(<ch:clustering>)--@ch:recommenders #parbreak() ]]#v(3pt)Clustering, dimensionality reduction, anomaly detection, and recommender systems. #parbreak() #strong[Lab 4:] clustering and PCA. #strong[Checkpoint:] defend a structure with evidence.], name: "u2", ..unsup)
    node((0, -1.85), [#stagehead([Stage 5: Limited labels and rewards], orange, [Chapters #ref(<ch:semi-supervised>)--@ch:rl]) \
      Use a few labels well, ask for the right ones, and learn by acting. #strong[Labs 5--6:] limited labels; a Q-learner. \
      #strong[Checkpoint:] say what feedback a problem offers before choosing a method.], name: "c5", ..other)
    node((0, -3.6), [#stagehead([Stage 6: Deep learning], orange, [Chapters #ref(<ch:deep>)--@ch:sequence]) \
      Networks and how to train them; CNNs for images; recurrent networks and attention. #strong[Labs 7--8:] CNN, LSTM. \
      #strong[Checkpoint:] beat a classical baseline by more than the spread between runs.], name: "c6", ..other)
    node((0, -5.35), [#stagehead([Stage 7: Language and products], orange, [Chapters #ref(<ch:text>)--@ch:serving]) \
      Text as data; one project from question to tested model; serving and monitoring it. #strong[Labs 9--10.] \
      #strong[Checkpoint:] a model that is tested, served, monitored, and retrained on evidence.], name: "c7", ..other)
    node((0, -7.1), [#text(size: 1.32em, weight: "bold", fill: green)[Capstone: integrate and defend] \
      Compare at least three model families, add one extension, evaluate fairly, and save the model with its card. \
      #strong[Checkpoint:] explain the model choice, reproduce the results, and state the limitations.], name: "d", ..finish)
    connect("a.south", "b.north", ..arr)
    connect("b.south", "g.north", ..arr)
    coordinate("split", (rel: (0, -0.4), to: "g.south"))
    connect("g.south", "split", ..flow)
    node("split", [], ..junction)
    connect("split", "-|", "s1.north", ..arr)
    node(along("split", ("split", "-|", "s1.north"), t: 100%), [labeled data], ..branchlabel, anchor: "south")
    connect("split", "-|", "u1.north", ..arr)
    node(along("split", ("split", "-|", "u1.north"), t: 100%), [unlabeled data], ..branchlabel, anchor: "south")
    connect("s1.south", "s2.north", ..arr)
    connect("u1.south", "u2.north", ..arr)
    coordinate("merge", (rel: (0, 0.42), to: "c5.north"))
    connect("s2.south", "|-", "merge", ..flow)
    connect("u2.south", "|-", "merge", ..flow)
    node("merge", [], ..junction)
    connect("merge", "c5.north", ..arr, shorten-end: 1.4944pt)
    connect("c5.south", "c6.north", ..arr)
    connect("c6.south", "c7.north", ..arr)
    connect("c7.south", "d.north", ..arr)
  })
]
