#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-robotics-scenarios")

= Robotics: From Sensor Readings to Actions <ch:robotics>

#chapterguide[Know what a classifier is, what a train/test split is for, and how to read a confusion matrix.][describe the sense--think--act loop; explain wall following as a reactive policy; turn logged sensor data into a supervised control problem; read a decision tree as a set of threshold rules; evaluate a controller with the right metrics; and state why offline accuracy is not the same as safe control.]

The maze robot of Chapter~@ch:uninformed had a perfect map and all the time it wanted to plan. A real robot often has neither. Lab~5 studies the decision stage of one: a SCITOS G5 robot logged 5,456 readings from 24 ultrasonic sensors alongside the actions of a wall-following controller. The lab learns readable if--then rules from that log and compares them with a more powerful, opaque model.

== The sense--think--act loop

Every robot runs some version of the same cycle. Sensors measure the world, a controller selects a command, and actuators change what the sensors will see next (#figref(<fig:sta-loop>)). The “think” box can be simple rules, a lookup table, a classifier, or a planner such as A$""^(star.op)$ (#chapref(<ch:informed>)).

#utpfig([Lab~5 learns the “think” stage from sensor--action pairs. The dashed feedback arrow, actions changing future readings, is not tested offline.], label: <fig:sta-loop>)[
  #canvas({
    node((0, 0), [#strong[Sense] \
  24 ultrasonic distances], name: "sense", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1)
    node((4.6, 0), [#strong[Think] \
  readings $arrow.r$ action], name: "think", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1, fill: pale-orange, draw: orange, line-width: 0.9963pt)
    node((9.2, 0), [#strong[Act] \
  one of four motions], name: "act", font: font("small"), ..utpbox, min-width: 2.9, min-height: 1.1)
    node((4.6, -2.2), [the room: walls, corners, doorways], name: "world", font: font("small"), ..utpbox, min-width: 3.4, min-height: 0.9, fill: pale-gray, draw: muted)
    connect("sense", "think", ..utparrow)
    connect("think", "act", ..utparrow)
    connect("act.south", "|-", "world.east", ..utparrow)
    connect("world.west", "-|", "sense.south", ..utparrow, dash: "dashed")
    node((4.6, 0.75), [Lab~5: this box is learned from 5,456 logged pairs], font: font("small"), ..utplabel, anchor: "south", text: orange)
    node((4.6, -2.72), [dashed arrow: feedback, the next reading depends on this action], font: font("small"), ..utplabel, anchor: "north", text: muted)
  })
]

#intuition[
  Offline control looks like classification: 24 readings in, one of four actions out. On a real robot, however, a wrong action can lead to situations the training data never contained.
]

== Wall following as a reactive policy

#term[Wall following] keeps a robot moving along a wall at a fixed distance. In this dataset the robot circled the room clockwise, so the wall stayed on its left. Sensors on the wall side read short distances, and the others read open space, corners and doorways (#figref(<fig:sensor-ring>)).

#analogy[
  Walk down a dark corridor with one hand on the wall. You need no map and no memory of how far you have come. If your hand presses hard, you edge away; if it loses contact, you edge back. That is a #term[reactive] controller: every decision comes from the current reading alone.
]

#utpfig([The SCITOS robot from above, moving to the right with the wall on its left. Its 24 sensors are numbered clockwise from US00 at the front. The four that Lab~5 selects (orange) sit on the rear-left arc, where they measure the wall from slightly different angles.], label: <fig:sensor-ring>)[
  #canvas({
    connect((-4.6, 3.15), (4.6, 3.15), line-width: 2.1918pt, draw: muted)
    node((-3.9, 3.2), [wall, on the robot’s left], font: font("small"), ..utplabel, anchor: "south", text: muted)
    circle-at((0, 0), 1.25, fill: pale-blue, draw: blue, line-width: 0.9963pt)
    node((0, 0.15), [SCITOS], font: font("script", weight: "bold", fill: navy))
    node((0, -0.2), [24 sensors], font: font("script", fill: muted))
    for i in range(0, 24) {
      let ang = -i * 15
      connect((1.25 * calc.cos((ang) * 1deg), 1.25 * calc.sin((ang) * 1deg)), (1.5 * calc.cos((ang) * 1deg), 1.5 * calc.sin((ang) * 1deg)), draw: blue, line-width: widths.thick)
    }
    for (i, lbl) in ((13, "US13"), (14, "US14"), (17, "US17"), (18, "US18")) {
      let ang = -i * 15
      connect((1.25 * calc.cos((ang) * 1deg), 1.25 * calc.sin((ang) * 1deg)), (1.62 * calc.cos((ang) * 1deg), 1.62 * calc.sin((ang) * 1deg)), draw: orange, line-width: 1.7933pt)
      node((1.98 * calc.cos((ang) * 1deg), 1.92 * calc.sin((ang) * 1deg)), [#lbl], font: font("tiny", weight: "bold", fill: mix(orange, 85%, other: black)))
    }
    connect((0, 2.1), (0, 3.08), ..utpptr, draw: orange)
    connect((-0.56, 2.05), (-0.82, 3.08), ..utpptr, draw: orange)
    node((0.2, 2.6), [short readings on the wall side], font: font("small"), ..utplabel, anchor: "west", align: left, text: mix(orange, 85%, other: black))
    node((1.55, 0), [US00], font: font("tiny", weight: "bold", fill: navy), anchor: "west")
    connect((2.15, 0), (3.45, 0), ..utparrow, draw: green, line-width: 1.1955pt)
    node((1.65, -0.12), [heading; turning right \
  moves away from the wall], font: font("small"), ..utplabel, anchor: "north-west", align: left, text: mix(green, 80%, other: black))
    node((0, -1.6), [the four actions: Move-Forward, Slight-Left-Turn, \
  Slight-Right-Turn, Sharp-Right-Turn], font: font("small"), ..utplabel, anchor: "north", align: center, text: muted)
  })
]

Written as rules, the natural controller for this task is short:

- If the wall-side distance is very short, turn sharply away from the wall.
- If it is a little short, turn slightly away; if a little long, turn slightly towards.
- Otherwise, move forward.

These rules are cheap and auditable, but they need thresholds. What counts as “very short”? Lab~5 learns the answer from data.

== Learning a controller from logged behaviour

Ask one question of any dataset: #emph[does your log hold the answers?] Here it does. Each row records what the sensors read and what the controller did, so this is #term[supervised] learning. Ask a second question: #emph[is the answer a number or a category?] Here it is one of four actions, so the job is #term[classification] rather than regression. Learning a policy from such demonstrations has a name, #term[behavioural cloning]: supervised classification with 24 features and four classes.

#analogy[
  Think of learning to drive by watching an instructor. You see thousands of moments of good driving and copy them. That works until you drift a little off-centre, because the instructor never drifted, so you have never seen what to do from there.
]

Three properties of the data shape what we do next.

/ The classes are imbalanced.: Move-Forward accounts for 40 % of rows, Sharp-Right-Turn 38 %, Slight-Right-Turn 15 % and Slight-Left-Turn 6 %. A controller that never turned slightly left could still reach 94 % accuracy. So report #term[macro F1], which weights classes equally, and train with `class_weight="balanced"`.
/ Consecutive rows are not independent.: Neighbouring readings resemble each other, which makes the lab’s random-split test score optimistic. The noise experiment probes robustness beyond this split.
/ Test rows are held back.: Save a seeded, stratified 70/30 split first. Select features, tune depth and fit the reference model on training rows, and evaluate on test rows only in Question~5.

=== Choosing the sensors

Not all 24 sensors matter equally. Rank them by #term[mutual information] with the action, using training rows only, and keep the top four: US14, US17, US18 and US13, a cluster on the wall side. Mutual information measures how much knowing a reading reduces your uncertainty about the action. A sensor pointing into open space tells you little; a sensor watching the wall tells you a lot.

== An interpretable controller: the decision tree

A #term[decision tree] applies feature thresholds one at a time until it reaches a class, like a game of twenty questions. Each path from the root to a leaf reads as one if--then rule learned from the demonstrations (#figref(<fig:tree-rules>)).

#utpfig([The learned tree\'s top three levels and three example rules. Nodes test sensor thresholds; leaves select actions. Limiting depth keeps the rules readable.], label: <fig:tree-rules>)[
  #canvas({
    let q = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 2.3, min-height: 0.7, align: center, font: font("script", fill: navy))
    let a = (draw: green, fill: pale-teal, rounded: 1.5mm, min-width: 2.2, min-height: 0.6, align: center, font: font("script", weight: "bold", fill: navy))
    let m = (draw: mix(muted, 60%), fill: pale-gray, rounded: 1.5mm, min-width: 2.2, min-height: 0.6, align: center, font: font("script", fill: muted))
    node((0, 0), [US14 $<=$ 0.90?], name: "r", font: font("small"), ..q)
    node((-2.4, -1.3), [Sharp-Right-Turn], name: "l1", font: font("small"), ..a)
    node((2.4, -1.3), [US18 $<=$ 1.00?], name: "n1", font: font("small"), ..q)
    node((0.6, -2.6), [US18 $<=$ 0.50?], name: "n2", font: font("small"), ..q)
    node((4.2, -2.6), [US17 $<=$ 0.90?], name: "n3", font: font("small"), ..q)
    node((0.3, -3.95), [$dots.c$ turns or \
  forward], name: "l2", font: font("small"), ..m)
    node((2.95, -3.95), [$dots.c$ forward or \
  slight right], name: "l3", font: font("small"), ..m)
    node((5.55, -3.95), [$dots.c$ mostly \
  Slight-Left-Turn], name: "l4", font: font("small"), ..m)
    connect("r", "l1", ..utpptr)
    node(along("r", "l1", t: 50%), [yes], font: font("small"), ..utplabel, anchor: "east")
    connect("r", "n1", ..utpptr)
    node(along("r", "n1", t: 50%), [no], font: font("small"), ..utplabel, anchor: "west")
    connect("n1", "n2", ..utpptr)
    node(along("n1", "n2", t: 50%), [yes], font: font("small"), ..utplabel, anchor: "east")
    connect("n1", "n3", ..utpptr)
    node(along("n1", "n3", t: 50%), [no], font: font("small"), ..utplabel, anchor: "west")
    connect("n2", "l2", ..utpptr)
    connect("n3", "l3", ..utpptr)
    node(along("n3", "l3", t: 50%), [yes], font: font("small"), ..utplabel, anchor: "east")
    connect("n3", "l4", ..utpptr)
    node(along("n3", "l4", t: 50%), [no], font: font("small"), ..utplabel, anchor: "west")
    node((7, -2), [#strong[Three paths as rules] \ #v(2.9888pt)
   IF US14 $<=$ 0.90 m THEN Sharp-Right-Turn \ #v(1.9925pt)
   IF US14 $>$ 0.90 AND US18 $>$ 1.00 AND US17 $<=$ 0.79 THEN Move-Forward \ #v(1.9925pt)
   IF US14 $>$ 0.90 AND US18 $>$ 1.00 AND $0.79<$ US17 $<= 0.90$ THEN Slight-Right-Turn \ #v(2.9888pt)
   14 leaves in total at depth~5; the full list is `rule_controller.txt`.], font: font("small"), ..utplabel, anchor: "west", align: left, text-width: 5.2)
  })
]

The first split is the wall-following reflex itself: #emph[if the wall-side sensor reads less than 0.9 m, turn sharply right, away from the wall]. Nobody typed that threshold. It was found in the demonstrations.

=== Choosing the depth

A deeper tree fits the training rows better and reads worse. The lab treats depth as a hyperparameter and picks it without touching the test rows: it carves a validation set out of the training rows, trains trees of depth 2 to 6 on the remainder, and scores each on the validation set. Macro F1 climbs steeply from depth~2 ($0.46$) to depth~4 ($0.87$), reaches $0.89$ at depth~5 and stops improving. Depth~5 is selected, the tree is refitted on all training rows, and `export_text` writes it out as the rule list saved in `rule_controller.txt`.

#keyidea[
  Interpretability is a design constraint, not a by-product. The lab fixes the number of sensors and caps the tree depth #emph[before] training, then measures what those constraints cost. Loosening either would raise the score and lose the ability to read the controller.
]

== A reference model and a fair comparison

The reference #term[random forest] uses 200 trees, each trained on a bootstrap sample of the rows, with all 24 sensors. Instead of one readable note, you consult two hundred advisers and take a vote. It shows what the compact rule tree gives up. Evaluate both on the same held-out rows.

#utptable[
  #tabularx(
    columns: (30%, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Model], [Accuracy], [Macro precision], [Macro recall], [Macro F1]),
    [Rule tree, 4 sensors, depth 5], [0.923], [0.879], [0.921], [0.895],
    [Random forest, 24 sensors], [0.995], [0.993], [0.992], [0.992],
  )
]

The readable controller sacrifices seven percentage points of accuracy and ten of macro F1. Whether that is acceptable depends on how much you need to audit its behaviour.

=== Reading the confusion matrix

A headline score does not tell you which mistakes a controller makes, and on a robot some mistakes are worse than others. #figref(<fig:confusion-rule>) gives the rule tree’s test results. Read along a row to see what happened to one true action, and down a column to see what one predicted action really was.

#utpfig([The rule tree on 1,637 test rows. Rows are the true action and columns the prediction, so the diagonal counts correct decisions. Recall reads along a row and precision down a column.], label: <fig:confusion-rule>)[
  #canvas({
    let hit = (draw: green, fill: mix(green, 28%), min-width: 1.55, min-height: 0.72, font: font("small", weight: "bold", fill: navy))
    let miss = (draw: mix(muted, 30%), fill: white, min-width: 1.55, min-height: 0.72, font: font("small", fill: muted))
    let bad = (draw: red, fill: pale-red, min-width: 1.55, min-height: 0.72, font: font("small", weight: "bold", fill: red))
    let rowlab = (anchor: "east", font: font("script", fill: navy))
    let collab = (anchor: "south", font: font("script", fill: navy), align: center)
    let cw = 1.6
    let ch = 0.76
    for (i, name) in ([Move- \
  Forward], [Sharp \
  Right], [Slight \
  Right], [Slight \
  Left]).enumerate() {
      node((cw * i, 0.42), [#name], font: font("small"), ..collab)
    }
    for (i, name) in ("true Move-Forward", "true Sharp-Right", "true Slight-Right", "true Slight-Left").enumerate() {
      node((-0.9, -ch * i), [#name], font: font("small"), ..rowlab)
    }
    node((0, 0), [624], font: font("small"), ..hit)
    node((cw, 0), [0], font: font("small"), ..miss)
    node((2 * cw, 0), [12], font: font("small"), ..miss)
    node((3 * cw, 0), [26], font: font("small"), ..miss)
    node((0, -ch), [36], font: font("small"), ..bad)
    node((cw, -ch), [574], font: font("small"), ..hit)
    node((2 * cw, -ch), [11], font: font("small"), ..miss)
    node((3 * cw, -ch), [8], font: font("small"), ..miss)
    node((0, -2 * ch), [22], font: font("small"), ..miss)
    node((cw, -2 * ch), [0], font: font("small"), ..miss)
    node((2 * cw, -2 * ch), [221], font: font("small"), ..hit)
    node((3 * cw, -2 * ch), [5], font: font("small"), ..miss)
    node((0, -3 * ch), [6], font: font("small"), ..miss)
    node((cw, -3 * ch), [0], font: font("small"), ..miss)
    node((2 * cw, -3 * ch), [0], font: font("small"), ..miss)
    node((3 * cw, -3 * ch), [92], font: font("small"), ..hit)
    for (r, y) in ((0.94, 0), (0.91, -1), (0.89, -2), (0.94, -3)) {
      node((3 * cw + 0.9, ch * y), [#r], font: font("script", fill: navy), anchor: "west")
    }
    node((3 * cw + 1.2, 0.42), [recall], font: font("script", weight: "bold", fill: navy), anchor: "south")
    for (p, x) in ((0.91, 0), (1, 1), (0.91, 2), (0.7, 3)) {
      node((cw * x, -3 * ch - 0.4), [#p], font: font("script", fill: navy), anchor: "north")
    }
    node((-0.9, -3 * ch - 0.57), [precision], font: font("script", weight: "bold", fill: navy), anchor: "east")
  })
]

Three things stand out. Slight-Right-Turn has the lowest recall, $0.89$, and 22 of its 27 misses were called Move-Forward: the line between “keep going” and “nudge right” sits on thresholds such as US17 at 0.79 m and 0.90 m, and a reading a few centimetres away flips the action. Slight-Left-Turn has the lowest precision, $0.70$, because balanced class weights push the tree towards this rare action, so 39 of its 131 predictions were wrong. And the red cell deserves the most attention. In 36 test rows the robot should have turned sharply away from the wall and was told to carry on forward. Accuracy counts that the same as any other miss, but an engineer would not.

== Robustness: what noise does to thresholds

Ultrasonic readings are noisy, and noise can move a reading across a threshold: 0.90 m may become 0.87 or 0.93 m. Lab~5 adds Gaussian noise at 2, 5 and 10 % of each selected sensor’s training standard deviation to the test readings. Test macro F1 falls quickly.

#utptable[
  #tabularx(
    columns: (34%, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    styles: (navy-bold,),
    header: ([Noise, as a fraction of training SD], [0], [2 %], [5 %], [10 %]),
    [Rule-tree macro F1], [0.895], [0.858], [0.787], [0.706],
  )
]

Possible responses all trade simplicity for robustness: more sensors provide redundancy, deeper trees allow finer partitions, and ensembles combine many decisions. For a 5 % noise budget, you should be able to justify one choice and state its cost.

#pitfall[
  Noise added only to #emph[test] readings measures the robustness of a controller trained on clean data. Training on noisy data is a different experiment. State which one you ran.
]

== From offline accuracy to safe control

Four factors separate evaluation on a fixed table from a running robot:

/ Feedback.: A wrong action changes the readings that follow and may lead outside the training distribution, where errors compound (#figref(<fig:drift>)).
/ Timing.: Sensor, computation and motor delays can make a correct decision act on an outdated reading.
/ Failure modes.: Sensor failures or sound-absorbing walls can produce unfamiliar readings that the classifier still labels confidently.
/ Safety limits.: Minimum distances, speed caps and emergency stops must constrain the learned policy. Accuracy does not measure them.

#utpfig([The shaded band is what the demonstrations covered. The learned controller makes a small mistake, drifts to the edge of that band, and then meets readings it was never trained on, so its next mistakes grow. A table of logged rows cannot show this, because the table never changes in response to a prediction.], label: <fig:drift>)[
  #canvas({
    rectangle((0, -0.5), (10.5, 0.5), fill: mix(teal, 16%), draw: none)
    node((0.1, 0.72), [states seen in the demonstrations], font: font("small"), ..utplabel, anchor: "west", text: mix(teal, 70%, other: black))
    connect((0, 1.35), (10.5, 1.35), line-width: 2.1918pt, draw: muted)
    node((8.9, 1.52), [wall], font: font("small"), ..utplabel, anchor: "west", text: muted)
    connect((0, 0), (10.4, 0), draw: green, line-width: 1.2951pt, end: tip("Stealth", length: 2mm, line: 1.2951pt))
    node((10.4, -0.05), [the demonstrated path], font: font("small"), ..utplabel, anchor: "north-east", text: mix(green, 80%, other: black))
    smooth-path((0, 0), (2, 0.02), (3.5, 0.14), (5, 0.42), (6.2, 0.72), (7.2, 1.02), (7.9, 1.28), draw: red, line-width: 1.2951pt, end: tip("Stealth", length: 2mm, line: 1.2951pt))
    node((5.6, -0.6), [learned controller: one small error, then unfamiliar readings], font: font("small"), ..utplabel, anchor: "north", align: center, text: red)
    node((3.5, 0.14), [], font: font("small"), shape: "circle", fill: red, inner-sep: 1.2951pt)
    node((3.25, 0.2), [first error], font: font("small"), ..utplabel, anchor: "south", text: red)
  })
]

The rule tree is an offline #emph[perception-to-action prototype], not a validated robot controller. Its readability is what supports the closed-loop testing it would need next.

#chapterrecap[
  - Robots repeat sense, think, act, and actions change what is sensed next.
  - Wall following is a reactive policy, and behavioural cloning learns one from logged demonstrations as a classification problem.
  - A shallow decision tree is a readable list of threshold rules; a random forest shows what readability costs.
  - Macro F1 and the confusion matrix say which actions fail, and that matters more than overall accuracy when errors differ in danger.
  - Offline accuracy cannot see feedback, delays, sensor failure or safety limits.
]

#quickcheck[
  + Why does Lab~5 report macro F1 rather than accuracy, and what accuracy could a controller that never predicts Slight-Left-Turn achieve?
  + Feature selection and depth tuning both use only the training rows. What would be wrong with the test score if the four sensors had been chosen on all rows?
  + Write the first rule of the learned tree in plain English and say what physical situation it responds to.
  + Which action has the lowest recall for the rule tree, and what does #figref(<fig:confusion-rule>) say about where its misses go?
  + Name one reason a controller with 92 % offline accuracy could still drive a robot into a wall.
]
