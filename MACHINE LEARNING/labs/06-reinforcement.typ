#import "/.shared/typst/utp.typ": *
#import "/MACHINE LEARNING/course-tools.typ": *
#unit("labs", "06-reinforcement")

#labsection(6, label: <sec:lab06-reinforcement>)[Reinforcement learning]

#labproject[Learn a policy by interacting, then save it][
  #strong[Read first.] Chapter~#ref(<ch:rl>). \

  #strong[Goal.] Train a tabular Q-learning agent on a small grid, evaluate its greedy policy separately from the exploratory training, draw the policy and the values it learned, and save the Q-table as the model. \

  #strong[Scenario.] A small robot must cross a grid to a goal without falling into a trap. Nobody can show it the correct move in each cell. It can only act, and notice what happens. \

  #strong[Data.] None: the $4 times 4$ GridWorld is defined in the notebook, and the agent creates its own experience. \

  #strong[Notebook.] `all_experiments/lab06_reinforcement/lab06_reinforcement_worked.ipynb`, with a README beside it. \

  #strong[Hand in.] The executed notebook, `results/lab06/`, the saved Q-table and a short conclusion, as listed in the checklist at the end of this sheet.
]

#labroadmap([Your map of this lab],
  [A],
  [Define the grid world, train the Q-table and evaluate the policy],
  [2--5],
  [B],
  [Save the Q-table, read the policy and its values],
  [6--7],
  [Finish],
  [Save the evidence; then move the trap],
  [8--10],
  [After],
  [Exercises, answers, troubleshooting tips and the two checklists],
  [---],
)

#labsetup[
  + Activate your course environment. This lab reads no data file.
  + Check the worked numbers of Chapter~@ch:rl, including the grid’s exact values. The last line must read `Every number above matches the book.`
  + From the course folder, start Jupyter, open the notebook, and choose #strong[Restart Kernel and Run All Cells]. It takes a few seconds.

  ```terminal
  python all_experiments/book_checks/demo_advanced.py
  jupyter lab
  ```

  Prefer a plain script? From the course folder, `python all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py` runs the same code and writes the same evidence.
]

#labroutine

#exercises[
  #strong[Warm-up on paper.] Do these before opening the notebook.

  + The shortest route takes six moves: five ordinary steps at $-0.04$, and a sixth into the goal for $+1$. What is the plain return? ($0.80$.)
  + One update with $alpha =0.15$ and $gamma =0.95$: $Q(s,a)=0$, reward $-0.04$, and the best Q-value in the next cell is 0.6. What is the new $Q(s,a)$? (Backup 0.53; new value 0.0795.)
  + What is the backup when the move lands on the goal, and why is there no future term? (Just the reward, 1. The episode ends, so there is no next state.)
]

#labquestion(1)[Setup][
  Run this first, and keep this kernel for the later questions. Every lab starts the same way. `start_lab()`, from `all_experiments/course_setup.py`, finds the course folder and returns the three folders the lab uses: `DATA` to read from, `RESULTS` and `MODELS` to write to. The imports in between are grouped by what they are for.
]

#labanswer[
  #labcode("lab06_reinforcement", 1)

  #readcode[
    - This lab needs no dataset and no scikit-learn: the agent's world is a few lines of Python, and the learning is NumPy arithmetic.
    - `re` is used once, to turn a chart's title into a file name.
  ]

  #refoutput[
    ```terminal
    course folder: MACHINE LEARNING
    reads all_datasets/, writes results/lab06/ and models/
    ```
  ]
]

#labpartopen([Part A], [Tabular Q-learning in a $4 times 4$ GridWorld], [Questions 2--5 • Data: none: the notebook defines the grid world], [Define a small grid world and let an agent learn, from rewards alone, how to reach the goal.])

#labquestion(2)[Define the world][
  The world is a $4 times 4$ grid. The agent starts top-left and must reach the goal bottom-right while avoiding a trap at row 1, column 3. Each move costs a little ($-0.04$), reaching the goal pays $+1$, and falling into the trap costs $-1$ and ends the episode. Walking into a wall leaves the agent where it is. That is the whole environment: a `step` function that takes a state and an action, and returns the next state, the reward, and whether the episode is over.
]

#labanswer[
  #include "visuals/06-trace.typ"

  #labcode("lab06_reinforcement", 2)

  #readcode[
    - `np.random.default_rng(42)` creates one seeded random generator, so every run explores in the same order.
    - A state is a tuple `(row, column)`. `ACTIONS` lists how each of the four moves changes the row and the column.
    - `step` is the whole environment. `min(max(r + dr, 0), ROWS - 1)` keeps the row inside the grid, so a move into a wall leaves the agent where it is.
    - `step` returns three things: the next state, the reward, and whether the episode is over. The goal pays +1, the trap -1, and any other move -0.04.
  ]

  #strong[What it means.] There is no dataset, no label and no train/test split. The data the agent sees depends on the policy it is learning.
]

#labquestion(3)[Train the Q-table][
  The Q-table has one number per (cell, action): the agent’s current estimate of the long-run return from taking that action there. It starts at zero. Each step, the estimate is nudged toward what actually happened: the reward received plus the discounted value of the best move from the next cell. The nudge size is $alpha$, and the discount $gamma$ says how much future reward is worth today. Early on the agent explores at random ($epsilon =1$), and as $epsilon$ decays it exploits what it has learned.
]

#labanswer[
  #include "visuals/06-worked-case.typ"

  #labcode("lab06_reinforcement", 3)

  #readcode[
    - `Q = np.zeros((ROWS, COLS, len(ACTIONS)))` holds one number for each cell and action. `Q[state]`, with a tuple such as `(2, 1)`, picks the four values of that cell.
    - `choose_action` is epsilon-greedy. `rng.random() < epsilon` is true with probability epsilon, and then the move is random; otherwise `np.argmax(Q[state])` picks the best known move.
    - The inner loop plays one episode of at most 100 moves.
    - `target` is the reward plus `gamma` times the best value of the next cell, or the reward alone when the episode has ended.
    - `Q[state][action] += alpha * (target - Q[state][action])` moves the old value a fraction `alpha` of the way towards the target.
    - `epsilon = max(min_epsilon, epsilon * 0.9985)` shrinks the exploration a little after every episode, down to a floor of 0.05.
  ]

  #strong[What it means.] The line `target = reward if done else ...` is the warm-up’s third question. With a decay of 0.9985, $epsilon$ reaches its floor of 0.05 after 1,996 of the 5,000 episodes.
]

#labquestion(4)[Read the training curve][
  The training curve is the return per episode, smoothed over 100 episodes. Early returns are negative because a random walker wanders into the trap or times out; as exploration decays the curve rises towards the best achievable return.
]

#labanswer[
  #labcode("lab06_reinforcement", 4)

  #readcode[
    - `np.convolve(training_returns, np.ones(window) / window, mode="valid")` is a moving average: each point is the mean of 100 episodes in a row.
    - `np.arange(window - 1, len(training_returns))` places each mean at the last episode of its window.
    - `plt.axhline(0.8, ...)` marks the best possible return. The shortest route takes six moves: five of them cost 0.04 each, and the sixth earns 1.
  ]

  #labvisual[Reference plot from the supplied notebook][
    #fitted-image("/MACHINE LEARNING/labs/visuals/06-notebook-reference.png", width: 88%, height: 5cm)
  ]

  #strong[What it means.] The first 100 episodes average a return of $-0.914$, and the last 100 average 0.788. That is just under the best possible 0.80, because 5% of moves are still random.
]

#labquestion(5)[Evaluate the greedy policy][
  Training returns mix learning with random moves, so they are not a fair measure of the policy. Evaluation switches exploration off and follows the greedy policy: in each cell, take the action with the highest Q-value.
]

#labanswer[
  #labcode("lab06_reinforcement", 5)

  #readcode[
    - `choose_action(state, explore=False)` always returns the best known move, so the 200 runs test what was learned and nothing else.
    - `successes += int(state == GOAL)` counts an episode only if it ended on the goal.
    - This world has no randomness of its own, so the 200 runs are identical. The loop is written this way because the same code also evaluates worlds that do have randomness.
  ]

  #refoutput[
    ```terminal
    success rate: 1.0
    mean return: 0.8
    learned action at start: down
    ```
  ]

  #strong[What it means.] The goal is reached 200 times out of 200, with the best possible return. A mean of exactly 0.8 means the agent found a six-move route and never deviates from it.
]

#strong[Connect it to the chapter.] You have now run this loop 5,000 times.

#include "visuals/06-reinforcement-chapter.typ"

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The first 100 episodes average a return of $-0.914$, and the last 100 average 0.788.
    - The greedy policy reaches the goal 200 times out of 200, with a return of 0.8.
  ]
]

#labpartopen([Part B], [The Q-table is the model: save it and read the policy], [Questions 6--7 • Data: the learned Q-table], [Save the learned table, read the policy from it, and compare its values with the exact ones.])

#labquestion(6)[Save the table and read the policy][
  Everything the agent learned is in the Q-table, so saving it is saving the model. Anyone with the file can act without retraining: in each cell, pick the action with the largest value.
]

#labanswer[
  #labcode("lab06_reinforcement", 6)

  #readcode[
    - `np.save` writes the table to a `.npy` file, and `np.load` reads it back: the table is the entire model.
    - `np.full((ROWS, COLS), "", dtype=object)` makes an empty grid of text cells.
    - `np.argmax(Q_table[r, c])` is the position of the largest of a cell's four values, and `ACTION_NAMES[...]` turns it into a word.
    - The `trap` argument lets the same function describe a grid whose trap is somewhere else, which the Try-it uses.
  ]

  #refoutput[
    ```terminal
    [['down' 'down' 'down' 'left']
     ['down' 'down' 'down' 'TRAP']
     ['right' 'down' 'down' 'down']
     ['right' 'right' 'right' 'GOAL']]
    ```
  ]

  #strong[What it means.] From the start the route is down, down, right, down, right, right: six moves. A shortest route is not unique on a grid, so a different seed may pick another of the same length. The file is 640 bytes.
]

#labquestion(7)[Draw the policy and the values][
  The policy is easier to read as arrows on the grid, drawn over a heat map of each cell’s value (the best Q-value available there). Values rise towards the goal.
]

#labanswer[
  #labcode("lab06_reinforcement", 7)

  #readcode[
    - `Q_table.max(axis=2)` keeps the best of the four values in each cell: a 4 x 4 grid of state values, which `plt.imshow` colours.
    - `plt.text(c, r, ...)` writes at column `c`, row `r`: the horizontal coordinate comes first.
    - `plt.arrow(c, r, 0.3 * dx, -0.3 * dy, ...)` draws the best move. The minus sign is there because `imshow` numbers its rows downwards.
    - `re.sub(r"[^a-z0-9]+", "_", title.lower())` replaces every run of characters that are not letters or digits by an underscore, which turns the title into a file name.
  ]

  #refoutput[
    ```terminal
    Best value in each cell (Q.max(axis=2)):
    0.593  0.666  0.743  0.666
    0.666  0.743  0.824  0.000
    0.743  0.824  0.910  1.000
    0.824  0.910  1.000  0.000
    ```
  ]

  #strong[What it means.] These equal the exact values in #figref(<fig:grid-values>), computed there without any trial and error. The agent learned them from rewards alone. The cell above the trap is worth 0.666, less than its left neighbor’s 0.743, because the way out from there starts by stepping back left. The goal and trap cells are zero because no action is ever taken from them.
]

#labcheckpoint[
  #listopts(leftmargin: 1.2em, itemsep: 1.9925pt, topsep: 0.9963pt)[
    - The route from the start takes six moves.
    - The first row of values reads 0.593, 0.666, 0.743, 0.666, the exact values of the chapter.
  ]
]

#labpartopen([Finish], [Save the evidence, then try it yourself], [Questions 8--10], [Write the results folder, then extend the lab yourself before reading one worked solution.])

#labquestion(8)[Save the evidence][
  Write the numbers above to the results folder. These files are regenerated on every run, so do not edit them by hand.
]

#labanswer[
  #labcode("lab06_reinforcement", 8)

  #readcode[
    - `pd.DataFrame(policy, index=..., columns=...)` labels the rows and the columns of the policy grid before saving it.
    - The second table keeps the return of every training episode, so the curve can be redrawn without retraining.
    - The metrics table has one row, written as a list that holds one dictionary.
  ]

  #refoutput[
    ```terminal
    Saved: ['greedy_policy.csv', 'greedy_policy_and_state_values.png', 'metrics.csv',
     'q_learning_training_curve.png', 'training_returns.csv']
    ```
  ]
]

#labquestion(9)[Try it yourself][
  Change one thing: the step cost, the trap location, the exploration schedule, or the discount factor. Write down what you expect the greedy policy to do differently before retraining, then check with `plot_policy`. Attempt it in this empty cell before reading the solution.
]

#labquestion(10)[One solution][
  Move the trap onto the bottom row, at (3, 1). Prediction before retraining: the learned route runs through (3, 1), straight into the new trap, so the route has to change, for the same six-move length.
]

#labanswer[
  #labcode("lab06_reinforcement", 10)

  #readcode[
    - `train_q` repeats Questions~2 and 3 inside one function, with the trap, the step cost and the discount as arguments. It has its own random generator, table and epsilon, so calling it does not disturb the first agent.
    - `step_new` is defined inside `train_q`, so it can read `trap` and `step_cost` from the function around it.
    - `greedy_policy(Q_moved, trap=moved_trap)` and `plot_policy(..., trap=moved_trap)` reuse the functions of Questions~6 and 7.
    - `name.ljust(7)` pads each word to seven characters, so the grid prints in aligned columns.
  ]

  #refoutput[
    ```terminal
    Greedy policy with the trap at (3, 1):
    down   down   right  down
    right  down   down   down
    right  right  right  down
    up     TRAP   right  GOAL
    ```
  ]

  #strong[What it means.] The route is now down, right, down, right, right, down: still six moves, so the return is still 0.8. The cell beside the new trap, (3, 0), points up and away from it. The right-hand column, which the original policy avoided, is now safe, and its arrows point down. The agent was never told the trap had moved; it relearned from the rewards alone.
]

#labpartopen([After the lab], [Exercises, troubleshooting and hand-in], [Exercises • Answers • Troubleshooting • Checklists], [Extend the lab with the exercises, compare with the answers, and check your work against the two checklists before you hand it in.])

#exercises[
  Add new cells at the end of the notebook for these tasks, using `train_q` as a starting point. Write your prediction first, then run it.

  + #strong[No step cost.] Retrain with a step cost of 0. With no charge per move, does the agent still take a short route? Why, or why not?
  + #strong[A high step cost.] Retrain with a step cost of $-0.5$. Does the route change? What is its return?
  + #strong[Never explore.] Set $epsilon$ to 0 from the start. Predict whether the agent finds the goal. Then explain the result, thinking about what a $-0.04$ reward does to a Q-table that starts at zero.
  + #strong[Always explore.] Keep $epsilon$ at 1 throughout, so every training move is random. Does the #emph[greedy] policy read from the table still work?
]

#answers[
  + It still takes six moves, with a return of 1.00. With $gamma =0.95$ a goal reached later is worth less, so the discount alone favors the short route.
  + Still six moves, with a return of $5 times (-0.5)+1=-1.50$. Six moves is already the minimum, and the trap costs $-1$ at once, so the costly route is still best from the start.
  + It reaches the goal in six moves with a return of 0.80, which may surprise you. Every tried action soon has a negative Q-value while untried ones stay at 0, so the greedy agent keeps trying whatever it has not tried. Starting at zero with negative step costs is accidental optimistic initialization. The food-stall student in Chapter~@ch:rl had no such luck, because every meal there could pay.
  + Yes: six moves and a return of 0.80. Q-learning’s backup uses the #emph[best] next action, whatever the agent actually did next, so it can learn the greedy policy’s values while behaving randomly. Training returns would look terrible throughout, which is another reason to evaluate separately.
]

#tip[
  / The route differs from the sheet: Check whether you ran cells out of order: `rng` is shared, so rerunning a cell continues the random stream. Restart and run all. Any six-move route with return 0.8 is equally correct.
  / Return far below 0.8 in evaluation: Check that evaluation passes `explore=False`, and that you are not evaluating a half-trained table.
  / Arrows look upside down: `plt.imshow` puts row 0 at the top, so $y$ grows downward on this plot, which is why the code draws $-0.3 thin d y$. Keep that sign.
  / The trap label is in the wrong place after the Try-it: The solution restores `TRAP` at the end of its cell. If you stopped midway, reset it to `(1, 3)`.
]

#labchecklists[
  #checklist[
    - The greedy policy reaches the goal in six moves, for a return of $0.80$, and you can read that route from the printed policy.
    - The success rate is reported over episodes run without exploration.
    - `models/gridworld_q_table.npy` is saved, and the policy is read from the reloaded table.
    - The first row of values matches 0.593, 0.666, 0.743, 0.666, and you can explain why the last is lower than the one before it.
  ]
]
