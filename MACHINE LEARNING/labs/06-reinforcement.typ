#import "/.shared/typst/utp.typ": *
#unit("labs", "06-reinforcement")

#lab("6")[Reinforcement learning] <sec:lab06-reinforcement>

#callout("labproject", title: [Learn a policy by interacting, then save it])[#strong[Read first.] Chapter~#ref(label("ch:rl"), supplement: none). \
#strong[Goal.] Train a tabular Q-learning agent on a small grid, evaluate its greedy policy separately from the exploratory training, draw the policy and the values it learned, and save the Q-table as the model. \
#strong[Scenario.] A small robot must cross a grid to a goal without falling into a trap. Nobody can show it the correct move in each cell. It can only act, and notice what happens. \
#strong[Data.] None: the $4 times 4$ GridWorld is defined in the notebook, and the agent creates its own experience. \
#strong[Notebook.] `all_experiments/ lab06_reinforcement/ lab06_reinforcement_worked.ipynb`, with a README beside it. \
#strong[Hand in.] The executed notebook, `results/lab06/`, the saved Q-table and a short conclusion, as listed in the checklist at the end of this sheet.]

#heading(level: 2, numbering: none)[Your map of this lab]
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    [Part], [What you do], [Questions],
    [A], [Define the grid world, train the Q-table and evaluate the policy], [2--5],
    [B], [Save the Q-table, read the policy and its values], [6--7],
    [Finish], [Save the evidence; then move the trap], [8--10],
    [After], [Your-turn tasks, expected findings, troubleshooting and the two checklists], [---],
  )]
  , kind: table
  )

#callout("labmode", title: [Lab setup])[+ Activate your course environment. This lab reads no data file.

+ Check the worked numbers of Chapter~#ref(label("ch:rl"), supplement: none), including the grid's exact values. The last line must read `Every number above matches the book.`

+ From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes a few seconds.

#code-block("python all_experiments/book_checks/demo_advanced.py\njupyter lab", lang: "text") Prefer a plain script? From the course folder, `python all_experiments/ lab06_reinforcement/ lab06_reinforcement_worked.py` runs the same code and writes the same evidence.]

#strong[How to work through this sheet.] Predict the result, run the matching notebook cell, compare with the reference output, and explain the result in your own words.

#callout("yourturn", title: [Your turn])[#strong[Warm-up on paper.] Do these before opening the notebook.

+ The shortest route takes six moves: five ordinary steps at $- 0.04$, and a sixth into the goal for $+ 1$. What is the plain return? ($0.80$.)

+ One update with $alpha = 0.15$ and $gamma = 0.95$: $Q \( s \, a \) = 0$, reward $- 0.04$, and the best Q-value in the next cell is 0.6. What is the new $Q \( s \, a \)$? (Backup 0.53; new value 0.0795.)

+ What is the backup when the move lands on the goal, and why is there no future term? (Just the reward, 1. The episode ends, so there is no next state.)]

#callout("labquestion", title: [Question 1 --- Setup])[Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/ course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 11, last: 23, lang: "python") *Reference output.*

#code-block("course folder: MACHINE LEARNING\nreads all_datasets/, writes results/lab06/ and models/", lang: "text")]

#callout("labpart", title: [Part A --- Tabular Q-learning in a $4 times 4$ GridWorld])[*Goal.* Define a small grid world and let an agent learn, from rewards alone, how to reach the goal.

Questions 2--5 •~Data: none: the notebook defines the grid world]

#callout("labquestion", title: [Question 2 --- Define the world])[The world is a $4 times 4$ grid. The agent starts top-left and must reach the goal bottom-right while avoiding a trap at row 1, column 3. Each move costs a little ($- 0.04$), reaching the goal pays $+ 1$, and falling into the trap costs $- 1$ and ends the episode. Walking into a wall leaves the agent where it is. That is the whole environment: a `step` function that takes a state and an action, and returns the next state, the reward, and whether the episode is over.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/06-trace.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 25, last: 44, lang: "python")

#strong[What it means.] There is no dataset, no label and no train/test split. The data the agent sees depends on the policy it is learning.]

#callout("labquestion", title: [Question 3 --- Train the Q-table])[The Q-table has one number per (cell, action): the agent's current estimate of the long-run return from taking that action there. It starts at zero. Each step, the estimate is nudged toward what actually happened: the reward received plus the discounted value of the best move from the next cell. The nudge size is $alpha$, and the discount $gamma$ says how much future reward is worth today. Early on the agent explores at random ($epsilon = 1$), and as $epsilon$ decays it exploits what it has learned.] #callout("labanswer", title: [Worked answer])[
#include "/MACHINE LEARNING/labs/visuals/06-worked-case.typ"
 #source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 46, last: 70, lang: "python")

#strong[What it means.] The line `target = reward if done else ...` is the warm-up's third question. With a decay of 0.9985, $epsilon$ reaches its floor of 0.05 after 1,996 of the 5,000 episodes.]

#callout("labquestion", title: [Question 4 --- Read the training curve])[The training curve is the return per episode, smoothed over 100 episodes. Early returns are negative because a random walker wanders into the trap or times out; as exploration decays the curve rises towards the best achievable return.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 72, last: 84, lang: "python") #callout("labvisual", title: [Reference plot from the supplied notebook])[#image("/MACHINE LEARNING/labs/visuals/06-notebook-reference.png", width: 90%)]

#strong[What it means.] The first 100 episodes average a return of $- 0.914$, and the last 100 average 0.788. That is just under the best possible 0.80, because 5% of moves are still random.]

#callout("labquestion", title: [Question 5 --- Evaluate the greedy policy])[Training returns mix learning with random moves, so they are not a fair measure of the policy. Evaluation switches exploration off and follows the greedy policy: in each cell, take the action with the highest Q-value.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 86, last: 100, lang: "python") *Reference output.*

#code-block("success rate: 1.0\nmean return: 0.8\nlearned action at start: down", lang: "text")

#strong[What it means.] The goal is reached 200 times out of 200, with the best possible return. A mean of exactly 0.8 means the agent found a six-move route and never deviates from it.]

#strong[Connect it to the chapter.] You have now run this loop 5,000 times. 
#include "/MACHINE LEARNING/labs/visuals/06-reinforcement-chapter.typ"


#callout("labcheckpoint", title: [Checkpoint: before you move on])[- The first 100 episodes average a return of $- 0.914$, and the last 100 average 0.788.

- The greedy policy reaches the goal 200 times out of 200, with a return of 0.8.]

#callout("labpart", title: [Part B --- The Q-table is the model: save it and read the policy])[*Goal.* Save the learned table, read the policy from it, and compare its values with the exact ones.

Questions 6--7 •~Data: the learned Q-table]

#callout("labquestion", title: [Question 6 --- Save the table and read the policy])[Everything the agent learned is in the Q-table, so saving it is saving the model. Anyone with the file can act without retraining: in each cell, pick the action with the largest value.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 102, last: 121, lang: "python") *Reference output.*

#code-block("[['down' 'down' 'down' 'left']\n ['down' 'down' 'down' 'TRAP']\n ['right' 'down' 'down' 'down']\n ['right' 'right' 'right' 'GOAL']]", lang: "text")

#strong[What it means.] From the start the route is down, down, right, down, right, right: six moves. A shortest route is not unique on a grid, so a different seed may pick another of the same length. The file is 640 bytes.]

#callout("labquestion", title: [Question 7 --- Draw the policy and the values])[The policy is easier to read as arrows on the grid, drawn over a heat map of each cell's value (the best Q-value available there). Values rise towards the goal.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 123, last: 146, lang: "python") *Reference output.*

#code-block("Best value in each cell (Q.max(axis=2)):\n0.593  0.666  0.743  0.666\n0.666  0.743  0.824  0.000\n0.743  0.824  0.910  1.000\n0.824  0.910  1.000  0.000", lang: "text")

#strong[What it means.] These equal the exact values in #ref(label("fig:grid-values"), supplement: [Figure]), computed there without any trial and error. The agent learned them from rewards alone. The cell above the trap is worth 0.666, less than its left neighbor's 0.743, because the way out from there starts by stepping back left. The goal and trap cells are zero because no action is ever taken from them.]

#callout("labcheckpoint", title: [Checkpoint: before you move on])[- The route from the start takes six moves.

- The first row of values reads 0.593, 0.666, 0.743, 0.666, the exact values of the chapter.]

#callout("labpart", title: [Finish --- Save the evidence, then try it yourself])[*Goal.* Write the results folder, then extend the lab yourself before reading one worked solution.

Questions 8--10]

#callout("labquestion", title: [Question 8 --- Save the evidence])[Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 148, last: 158, lang: "python") *Reference output.*

#code-block("Saved: ['greedy_policy.csv', 'greedy_policy_and_state_values.png', 'metrics.csv',\n 'q_learning_training_curve.png', 'training_returns.csv']", lang: "text")]

#heading(level: 2, numbering: none)[Try it yourself]
#callout("labquestion", title: [Question 9 --- Try it yourself])[Change one thing: the step cost, the trap location, the exploration schedule, or the discount factor. Write down what you expect the greedy policy to do differently before retraining, then check with `plot_policy`. Attempt it in this empty cell before reading the solution.]

#callout("labquestion", title: [Question 10 --- One solution])[Move the trap onto the bottom row, at (3, 1). Prediction before retraining: the learned route runs through (3, 1), straight into the new trap, so the route has to change, for the same six-move length.] #callout("labanswer", title: [Worked answer])[#source-code("/MACHINE LEARNING/all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py", first: 162, last: 199, lang: "python") *Reference output.*

#code-block("Greedy policy with the trap at (3, 1):\ndown   down   right  down\nright  down   down   down\nright  right  right  down\nup     TRAP   right  GOAL", lang: "text")

#strong[What it means.] The route is now down, right, down, right, right, down: still six moves, so the return is still 0.8. The cell beside the new trap, (3, 0), points up and away from it. The right-hand column, which the original policy avoided, is now safe, and its arrows point down. The agent was never told the trap had moved; it relearned from the rewards alone.]

#callout("labpart", title: [After the lab --- Your turn, troubleshooting and hand-in])[*Goal.* Extend the lab with the Your-turn tasks, compare with the expected findings, and check your work against the two checklists before you hand it in.

Your-turn tasks •~Expected findings •~Troubleshooting •~Checklists]

#callout("yourturn", title: [Your turn])[Add new cells at the end of the notebook for these tasks, using `train_q` as a starting point. Write your prediction first, then run it.

+ #strong[No step cost.] Retrain with a step cost of 0. With no charge per move, does the agent still take a short route? Why, or why not?

+ #strong[A high step cost.] Retrain with a step cost of $- 0.5$. Does the route change? What is its return?

+ #strong[Never explore.] Set $epsilon$ to 0 from the start. Predict whether the agent finds the goal. Then explain the result, thinking about what a $- 0.04$ reward does to a Q-table that starts at zero.

+ #strong[Always explore.] Keep $epsilon$ at 1 throughout, so every training move is random. Does the #emph[greedy] policy read from the table still work?]

#callout("expectedfindings", title: [Expected findings])[+ It still takes six moves, with a return of 1.00. With $gamma = 0.95$ a goal reached later is worth less, so the discount alone favors the short route.

+ Still six moves, with a return of $5 times \( - 0.5 \) + 1 = - 1.50$. Six moves is already the minimum, and the trap costs $- 1$ at once, so the costly route is still best from the start.

+ It reaches the goal in six moves with a return of 0.80, which may surprise you. Every tried action soon has a negative Q-value while untried ones stay at 0, so the greedy agent keeps trying whatever it has not tried. Starting at zero with negative step costs is accidental optimistic initialization. The food-stall student in Chapter~#ref(label("ch:rl"), supplement: none) had no such luck, because every meal there could pay.

+ Yes: six moves and a return of 0.80. Q-learning's backup uses the #emph[best] next action, whatever the agent actually did next, so it can learn the greedy policy's values while behaving randomly. Training returns would look terrible throughout, which is another reason to evaluate separately.]

#callout("troubleshoot", title: [Troubleshooting])[/ The route differs from the sheet: #block[
Check whether you ran cells out of order: `rng` is shared, so rerunning a cell continues the random stream. Restart and run all. Any six-move route with return 0.8 is equally correct.
]

/ Return far below 0.8 in evaluation: #block[
Check that evaluation passes `explore=False`, and that you are not evaluating a half-trained table.
]

/ Arrows look upside down: #block[
`plt.imshow` puts row 0 at the top, so $y$ grows downward on this plot, which is why the code draws $- 0.3 thin d y$. Keep that sign.
]

/ The trap label is in the wrong place after the Try-it: #block[
The solution restores `TRAP` at the end of its cell. If you stopped midway, reset it to `(1, 3)`.
]]

#callout("verification", title: [Verification checklist])[- The greedy policy reaches the goal in six moves, for a return of $0.80$, and you can read that route from the printed policy.

- The success rate is reported over episodes run without exploration.

- `models/gridworld_q_table.npy` is saved, and the policy is read from the reloaded table.

- The first row of values matches 0.593, 0.666, 0.743, 0.666, and you can explain why the last is lower than the one before it.]
