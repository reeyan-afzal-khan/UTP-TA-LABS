#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-robotics-scenarios")


#heading(level: 1)[Robotics: From Sensor Readings to Actions]
 <ch:robotics>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know what a classifier is, what a train/test split is for, and how to read a confusion matrix.

*By the end, you can:* describe the sense--think--act loop; explain wall following as a reactive policy; turn logged sensor data into a supervised control problem; read a decision tree as a set of threshold rules; evaluate a controller with the right metrics; and state why offline accuracy is not the same as safe control.]

The maze robot of Chapter~#ref(label("ch:uninformed"), supplement: none) had a perfect map and all the time it wanted to plan. A real robot often has neither. Lab~5 studies the decision stage of one: a SCITOS G5 robot logged 5,456 readings from 24 ultrasonic sensors alongside the actions of a wall-following controller. The lab learns readable if--then rules from that log and compares them with a more powerful, opaque model.


#heading(level: 2)[The sense--think--act loop]


Every robot runs some version of the same cycle. Sensors measure the world, a controller selects a command, and actuators change what the sensors will see next (#ref(label("fig:sta-loop"), supplement: [Figure])). The "think" box can be simple rules, a lookup table, a classifier, or a planner such as A$""^star.op$ (#ref(label("ch:informed"), supplement: [Chapter])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/e3c3dd6fd4566794.svg")], caption: [Lab~5 learns the "think" stage from sensor--action pairs. The dashed feedback arrow, actions changing future readings, is not tested offline.]) <fig:sta-loop>

#callout("intuition", title: [Conceptual intuition])[Offline control looks like classification: 24 readings in, one of four actions out. On a real robot, however, a wrong action can lead to situations the training data never contained.]


#heading(level: 2)[Wall following as a reactive policy]


#strong[Wall following] keeps a robot moving along a wall at a fixed distance. In this dataset the robot circled the room clockwise, so the wall stayed on its left. Sensors on the wall side read short distances, and the others read open space, corners and doorways (#ref(label("fig:sensor-ring"), supplement: [Figure])).

#callout("analogy", title: [Analogy])[Walk down a dark corridor with one hand on the wall. You need no map and no memory of how far you have come. If your hand presses hard, you edge away; if it loses contact, you edge back. That is a #strong[reactive] controller: every decision comes from the current reading alone.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/75932f12a73910ac.svg")], caption: [The SCITOS robot from above, moving to the right with the wall on its left. Its 24 sensors are numbered clockwise from US00 at the front. The four that Lab~5 selects (orange) sit on the rear-left arc, where they measure the wall from slightly different angles.]) <fig:sensor-ring>

Written as rules, the natural controller for this task is short:

- If the wall-side distance is very short, turn sharply away from the wall.

- If it is a little short, turn slightly away; if a little long, turn slightly towards.

- Otherwise, move forward.

These rules are cheap and auditable, but they need thresholds. What counts as "very short"? Lab~5 learns the answer from data.


#heading(level: 2)[Learning a controller from logged behaviour]


Ask one question of any dataset: #emph[does your log hold the answers?] Here it does. Each row records what the sensors read and what the controller did, so this is #strong[supervised] learning. Ask a second question: #emph[is the answer a number or a category?] Here it is one of four actions, so the job is #strong[classification] rather than regression. Learning a policy from such demonstrations has a name, #strong[behavioural cloning]: supervised classification with 24 features and four classes.

#callout("analogy", title: [Analogy])[Think of learning to drive by watching an instructor. You see thousands of moments of good driving and copy them. That works until you drift a little off-centre, because the instructor never drifted, so you have never seen what to do from there.]

Three properties of the data shape what we do next.

/ The classes are imbalanced.: #block[
Move-Forward accounts for 40 % of rows, Sharp-Right-Turn 38 %, Slight-Right-Turn 15 % and Slight-Left-Turn 6 %. A controller that never turned slightly left could still reach 94 % accuracy. So report #strong[macro F1], which weights classes equally, and train with `class_weight="balanced"`.
]

/ Consecutive rows are not independent.: #block[
Neighbouring readings resemble each other, which makes the lab's random-split test score optimistic. The noise experiment probes robustness beyond this split.
]

/ Test rows are held back.: #block[
Save a seeded, stratified 70/30 split first. Select features, tune depth and fit the reference model on training rows, and evaluate on test rows only in Question~5.
]


#heading(level: 3)[Choosing the sensors]


Not all 24 sensors matter equally. Rank them by #strong[mutual information] with the action, using training rows only, and keep the top four: US14, US17, US18 and US13, a cluster on the wall side. Mutual information measures how much knowing a reading reduces your uncertainty about the action. A sensor pointing into open space tells you little; a sensor watching the wall tells you a lot.


#heading(level: 2)[An interpretable controller: the decision tree]


A #strong[decision tree] applies feature thresholds one at a time until it reaches a class, like a game of twenty questions. Each path from the root to a leaf reads as one if--then rule learned from the demonstrations (#ref(label("fig:tree-rules"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/3c8b0107747430ee.svg")], caption: [The learned tree\'s top three levels and three example rules. Nodes test sensor thresholds; leaves select actions. Limiting depth keeps the rules readable.]) <fig:tree-rules>

The first split is the wall-following reflex itself: #emph[if the wall-side sensor reads less than 0.9 m, turn sharply right, away from the wall]. Nobody typed that threshold. It was found in the demonstrations.


#heading(level: 3)[Choosing the depth]


A deeper tree fits the training rows better and reads worse. The lab treats depth as a hyperparameter and picks it without touching the test rows: it carves a validation set out of the training rows, trains trees of depth 2 to 6 on the remainder, and scores each on the validation set. Macro F1 climbs steeply from depth~2 ($0.46$) to depth~4 ($0.87$), reaches $0.89$ at depth~5 and stops improving. Depth~5 is selected, the tree is refitted on all training rows, and `export_text` writes it out as the rule list saved in `rule_controller.txt`.

#callout("keyidea", title: [Key idea])[Interpretability is a design constraint, not a by-product. The lab fixes the number of sensors and caps the tree depth #emph[before] training, then measures what those constraints cost. Loosening either would raise the score and lose the ability to read the controller.]


#heading(level: 2)[A reference model and a fair comparison]


The reference #strong[random forest] uses 200 trees, each trained on a bootstrap sample of the rows, with all 24 sensors. Instead of one readable note, you consult two hundred advisers and take a vote. It shows what the compact rule tree gives up. Evaluate both on the same held-out rows.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Model], [Accuracy], [Macro precision], [Macro recall], [Macro F1],),
    table.hline(),
    [Rule tree, 4 sensors, depth 5], [0.923], [0.879], [0.921], [0.895],
    [Random forest, 24 sensors], [0.995], [0.993], [0.992], [0.992],
  )]
  , kind: table
  )

The readable controller sacrifices seven percentage points of accuracy and ten of macro F1. Whether that is acceptable depends on how much you need to audit its behaviour.


#heading(level: 3)[Reading the confusion matrix]


A headline score does not tell you which mistakes a controller makes, and on a robot some mistakes are worse than others. #ref(label("fig:confusion-rule"), supplement: [Figure]) gives the rule tree's test results. Read along a row to see what happened to one true action, and down a column to see what one predicted action really was.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/8c5c8363c5139539.svg")], caption: [The rule tree on 1,637 test rows. Rows are the true action and columns the prediction, so the diagonal counts correct decisions. Recall reads along a row and precision down a column.]) <fig:confusion-rule>

Three things stand out. Slight-Right-Turn has the lowest recall, $0.89$, and 22 of its 27 misses were called Move-Forward: the line between "keep going" and "nudge right" sits on thresholds such as US17 at 0.79 m and 0.90 m, and a reading a few centimetres away flips the action. Slight-Left-Turn has the lowest precision, $0.70$, because balanced class weights push the tree towards this rare action, so 39 of its 131 predictions were wrong. And the red cell deserves the most attention. In 36 test rows the robot should have turned sharply away from the wall and was told to carry on forward. Accuracy counts that the same as any other miss, but an engineer would not.


#heading(level: 2)[Robustness: what noise does to thresholds]


Ultrasonic readings are noisy, and noise can move a reading across a threshold: 0.90 m may become 0.87 or 0.93 m. Lab~5 adds Gaussian noise at 2, 5 and 10 % of each selected sensor's training standard deviation to the test readings. Test macro F1 falls quickly.

#figure(
  align(center)[#table(
    columns: 5,
    align: (left,left,left,left,left,),
    table.header([Noise, as a fraction of training SD], [0], [2 %], [5 %], [10 %],),
    table.hline(),
    [Rule-tree macro F1], [0.895], [0.858], [0.787], [0.706],
  )]
  , kind: table
  )

Possible responses all trade simplicity for robustness: more sensors provide redundancy, deeper trees allow finer partitions, and ensembles combine many decisions. For a 5 % noise budget, you should be able to justify one choice and state its cost.

#callout("pitfall", title: [Common mistake])[Noise added only to #emph[test] readings measures the robustness of a controller trained on clean data. Training on noisy data is a different experiment. State which one you ran.]


#heading(level: 2)[From offline accuracy to safe control]


Four factors separate evaluation on a fixed table from a running robot:

/ Feedback.: #block[
A wrong action changes the readings that follow and may lead outside the training distribution, where errors compound (#ref(label("fig:drift"), supplement: [Figure])).
]

/ Timing.: #block[
Sensor, computation and motor delays can make a correct decision act on an outdated reading.
]

/ Failure modes.: #block[
Sensor failures or sound-absorbing walls can produce unfamiliar readings that the classifier still labels confidently.
]

/ Safety limits.: #block[
Minimum distances, speed caps and emergency stops must constrain the learned policy. Accuracy does not measure them.
]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ARTIFICIAL INTELLIGENCE/figures/diagrams/c782cd9c3ef77eb1.svg")], caption: [The shaded band is what the demonstrations covered. The learned controller makes a small mistake, drifts to the edge of that band, and then meets readings it was never trained on, so its next mistakes grow. A table of logged rows cannot show this, because the table never changes in response to a prediction.]) <fig:drift>

The rule tree is an offline #emph[perception-to-action prototype], not a validated robot controller. Its readability is what supports the closed-loop testing it would need next.

#callout("chapterrecap", title: [Chapter recap])[- Robots repeat sense, think, act, and actions change what is sensed next.

- Wall following is a reactive policy, and behavioural cloning learns one from logged demonstrations as a classification problem.

- A shallow decision tree is a readable list of threshold rules; a random forest shows what readability costs.

- Macro F1 and the confusion matrix say which actions fail, and that matters more than overall accuracy when errors differ in danger.

- Offline accuracy cannot see feedback, delays, sensor failure or safety limits.]

#callout("quickcheck", title: [Check your understanding])[+ Why does Lab~5 report macro F1 rather than accuracy, and what accuracy could a controller that never predicts Slight-Left-Turn achieve?

+ Feature selection and depth tuning both use only the training rows. What would be wrong with the test score if the four sensors had been chosen on all rows?

+ Write the first rule of the learned tree in plain English and say what physical situation it responds to.

+ Which action has the lowest recall for the rule tree, and what does #ref(label("fig:confusion-rule"), supplement: [Figure]) say about where its misses go?

+ Name one reason a controller with 92 % offline accuracy could still drive a robot into a wall.]
