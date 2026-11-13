#import "/.shared/typst/utp.typ": *
#import "study-log-figures.typ": *
#unit("chapters", "25-reinforcement-learning")

= Reinforcement Learning Basics <ch:rl>

#chapterguide[Probability, expected value, optimization, and the idea of sequential decisions.][describe a problem as states, actions and rewards; balance exploring with exploiting; compute a discounted return; run Q-learning updates by hand; read a policy from a Q-table; and evaluate a greedy policy separately from training.]

Nobody hands a puppy a table of correct actions. It sits, and it gets a treat. It chews a shoe, and it does not. Reinforcement learning (RL) learns the same way: there is no answer column at all, only a score that arrives after the learner acts, sometimes much later. Because actions change what happens next, the goal is not one good move but a good long run.

#coursechoice[
  Lab~6 implements tabular RL. Neural function approximation for deep RL lies beyond this course.
]

== The agent-environment loop

At time $t$:

#utpsteps[
  + The agent observes a state $s_t$.
  + It chooses an action $a_t$.
  + The environment returns a reward $r_(t+1)$ and a new state $s_(t+1)$.
  + The agent updates what it believes about the action.
]

#utpfig([The agent-environment loop. The agent chooses an action; the environment changes state and returns a reward and the new state.], label: <fig:agent-environment>)[
  #canvas({
    let box-style = (draw: blue, fill: pale-blue, rounded: 2mm, min-width: 3, min-height: 1.2, align: center, font: font("normal", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2.4mm, line: widths.thick))
    node((0, 0), [Agent \
  chooses an action], name: "agent", ..box-style)
    node(right-of("agent", 3.5), [Environment \
  changes state], name: "env", ..box-style)
    connect("agent.north-east", "env.north-west", bend: 18deg, ..arr, name: "curve-1")
    node((name: "curve-1", anchor: 50%), [action $a_t$], font: font("small"), anchor: "south")
    connect("env.south-west", "agent.south-east", bend: 18deg, ..arr, name: "curve-2")
    node((name: "curve-2", anchor: 50%), [state $s_(t+1)$, reward $r_(t+1)$], font: font("small"), anchor: "north")
  })
]

#workedexample[
  A warehouse robot tracks location and battery, chooses movement or charging, and balances time and collision costs against delivery rewards.
]

== A simpler case: which food stall?

#analogy[
  Three stalls near campus serve lunch. You have a favorite. Tomorrow you could go back to it, or try the one you have never tried, which might be better or might waste a lunch. Every choice both feeds you and teaches you, and you cannot do both fully at once.
]

This creates the central RL problem:

#describe-nextline(1.35in)[
  / Exploration: Try uncertain actions to learn more about them.
  / Exploitation: Choose the action currently believed to be best.
]

An $epsilon$-greedy strategy explores with probability $epsilon$ and otherwise exploits.

#workedexample[
  Three stalls give a good meal with hidden chances 0.2, 0.5 and 0.8. A student keeps a running average for each stall, and eats 1,000 lunches. Averaged over 500 students:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto, auto),
    align: (left, center, center, center, center),
    header: ([Strategy], [Visits: stall 1], [Stall 2], [Stall 3], [Good meals per lunch]),
    [$epsilon =0$: never explore], [1000], [0], [0], [0.199],
    [$epsilon =0.1$: explore one lunch in ten], [54], [57], [889], [0.750],
    [$epsilon =0.5$: explore half the time], [168], [170], [662], [0.648],
  )

  #raggedright[
  #v(6pt)
  With no exploration, the student goes to the first stall, finds it acceptable, and never learns that a better one exists. Too much exploration keeps paying to learn something already known. The best possible rate is 0.8, and a little exploration gets close.
  ]]]
]

== Markov decision processes

A classical RL problem is often written as a Markov decision process (MDP) with:

- a set of states $cal(S)$;
- a set of actions $cal(A)$;
- transition probabilities $P(s' mid s,a)$;
- a reward rule;
- a discount factor $gamma in [0,1)$.

Under the Markov assumption, the current state and action contain the information needed for the next-state distribution.

== Return and discounting

A reward now is worth more than the same reward later, and the #term[discount factor] $gamma$ says by how much. The #term[return] from time $t$ is the discounted sum of future rewards:

$ G_t=r_(t+1)+ gamma r_(t+2)+ gamma ^2 r_(t+3)+ dots.c . $

#workedexample[
  Future rewards are $5,4,3$. With $gamma =0.9$, $G_t=5+0.9(4)+0.81(3)=11.03$. With $gamma =0.5$ the return is 7.75. With $gamma =0$ only the next reward counts, giving 5, and with $gamma =1$ all count equally, giving 12.
]

== Policies and value functions

A #term[policy] $pi (a mid s)$ describes how the agent chooses actions in each state.

The state-value function is

$ V^pi(s)=bb(E)_pi[G_t mid s_t=s], $

the expected return from state $s$ while following policy $pi$.

The action-value function is

$ Q^pi(s,a)=bb(E)_pi[G_t mid s_t=s,a_t=a], $

the expected return from taking action $a$ in state $s$ and then following $pi$.

#intuition[
  $V(s)$ asks, “How good is this situation?” $Q(s,a)$ asks, “How good is this particular move from this situation?”
]

== The Bellman idea

A long-term value can be broken into two parts:

$ "value now"="reward next"+"discounted value later". $

For an optimal action-value function,

$ Q^*(s,a)=bb(E)[r_(t+1)+ gamma max_(a')Q^*(s_(t+1),a') divides s_t=s,a_t=a]. $

This recursive relationship is the basis of Q-learning.

== Tabular Q-learning

When the state and action spaces are small, store one Q-value for every state-action pair in a table. After observing the transition $(s_t,a_t,r_(t+1),s_(t+1))$, update

$ Q(s_t,a_t) arrow.l Q(s_t,a_t)+ alpha [r_(t+1)+ gamma max_(a')Q(s_(t+1),a')-Q(s_t,a_t)]. $

The quantity in brackets is the #term[temporal-difference error]: what just happened, plus the best you now expect from where you landed, minus what you believed. The estimate moves a fraction $alpha$ of the way towards that new evidence.

#utpsteps[
  + Initialize the Q-table, often with zeros.
  + Observe the current state.
  + Choose an action using an exploration strategy such as $epsilon$-greedy.
  + Perform the action and observe reward and next state.
  + Update the chosen Q-table entry.
  + Repeat over many episodes, gradually reducing exploration when appropriate.
]

#workedexample[
  #strong[One update.] With $Q(s,a)=2$, $r=1$, $gamma =0.9$, next-state maximum 4 and $alpha =0.5$: the backup is $1+0.9 times 4=4.6$, the TD error is $2.6$, and $Q(s,a) arrow.l 2+0.5(2.6)=3.3$.

  #strong[Value walks backwards.] A corridor of cells 0, 1, 2, then a goal worth $+1$. The agent always walks right, with $alpha =0.5$ and $gamma =0.9$, and all Q-values start at zero. Here is $Q("cell","right")$ after each trip:

  #v(6pt)
  #align(center)[#fsize("small")[

  #tabularx(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    header: ([Episode], [Cell 0], [Cell 1], [Cell 2]),
    [1], [0.0000], [0.0000], [0.5000],
    [2], [0.0000], [0.2250], [0.7500],
    [3], [0.1013], [0.4500], [0.8750],
    [4], [0.2531], [0.6188], [0.9375],
  )

  #raggedright[
  #v(6pt)
  In episode 1 only the cell beside the goal learns anything. In episode 2 its value reaches the next cell back: $0.5 times (0+0.9 times 0.5)=0.225$. News of the reward spreads backward, one cell per trip. That is why tabular RL needs so many episodes.
  ]]]
]

== One Q-learning update, drawn

The diagram separates a Q-update into its current estimate, backup value, and step size.

#utpfig([One Q-learning update. The new estimate moves the old one a step of size $alpha$ towards the backup value: what actually happened nudges what you believed.], label: <fig:q-update>)[
  #canvas({
    let bx = (draw: blue, fill: pale-blue, rounded: 1.5mm, min-width: 2.5, min-height: 0.85, align: center, font: font("script", weight: "bold", fill: navy))
    let gd = (draw: green, fill: pale-teal, rounded: 1.5mm, min-width: 2.5, min-height: 0.85, align: center, font: font("script", weight: "bold", fill: navy))
    let op = (draw: orange, fill: pale-orange, rounded: 1.5mm, min-width: 3.6, min-height: 0.82, align: center, font: font("script", weight: "bold", fill: navy))
    let arr = (line-width: widths.thick, draw: teal, end: tip("Stealth", length: 2mm, line: widths.thick))
    node((-2.35, 1.55), [Old estimate \
  $Q(s,a)$], name: "old", ..bx)
    node((2.35, 1.55), [Backup value \
  $r+ gamma max_(a')Q(s',a')$], name: "backup", ..gd)
    node((0, 0.3), [Move a fraction $alpha$ toward the backup value \
  $Q+ alpha ("backup"-Q)$], name: "update", ..op)
    node((0, -1.05), [New estimate \
  $Q(s,a)$], name: "new", ..bx)
    connect("old.south", "update.north-west", ..arr)
    connect("backup.south", "update.north-east", ..arr)
    connect("update.south", "new.north", ..arr)
    node(below-of("new", 0.25), [what actually happened \
  nudges what you believed], font: font("script", style: "italic", fill: muted), align: center)
  })
]

== Lab~6’s grid, solved

Lab~6 trains on a $4 times 4$ grid: start top-left, goal bottom-right worth $+1$, a trap at row 1, column 3 worth $-1$, and $-0.04$ per step, with $gamma =0.95$. The shortest route takes six moves, so its plain return is $5 times (-0.04)+1=0.80$, and its discounted return from the start is 0.593.

We can compute the best possible value of every cell directly, by repeating the Bellman idea until nothing changes. #figref(<fig:grid-values>) shows the result. Lab~6’s table, trained only from its own trial and error, reaches these same values to three decimals.

#utpfig([Best possible values on Lab~6’s grid, with the policy the lab’s agent learns. Values rise towards the goal. The cell above the trap is worth only 0.666, less than its left neighbor’s 0.743, because it has to step back left to get round the trap.], label: <fig:grid-values>)[
  #canvas(x: 1.15cm, y: 1.15cm, {
    let gv = (draw: mix(blue, 55%), min-size: 1.15, inner-sep: 0pt, align: center, font: font("script", fill: navy))
    for (r, c, vv, a, t) in ((0, 0, 0.593, [$arrow.b$], 18), (0, 1, 0.666, [$arrow.b$], 24), (0, 2, 0.743, [$arrow.b$], 32), (0, 3, 0.666, [$arrow.l$], 24), (1, 0, 0.666, [$arrow.b$], 24), (1, 1, 0.743, [$arrow.b$], 32), (1, 2, 0.824, [$arrow.b$], 40), (2, 0, 0.743, [$arrow.r$], 32), (2, 1, 0.824, [$arrow.b$], 40), (2, 2, 0.91, [$arrow.b$], 50), (2, 3, 1, [$arrow.b$], 60), (3, 0, 0.824, [$arrow.r$], 40), (3, 1, 0.91, [$arrow.r$], 50), (3, 2, 1, [$arrow.r$], 60)) {
      node((c, -r), [#vv \
  #a], ..gv, fill: mix(teal, t * 1%))
    }
    node((3, -1), [TRAP], ..gv, fill: pale-red, draw: red, font: font("script", weight: "bold", fill: red))
    node((3, -3), [GOAL], ..gv, fill: pale-orange, draw: orange, font: font("script", weight: "bold", fill: navy))
    connect((-0.4, 0.2), (-0.4, -2.4), (0.6, -2.4), (0.6, -3.4), (2.75, -3.4), line-width: widths.very-thick, draw: orange, end: tip("Stealth", length: 2mm, line: widths.very-thick))
    node((3.6, -3.4), [the greedy route: six moves], font: font("script", fill: mix(orange, 85%, other: black)), anchor: "west")
  })
]

#recipecard([Q-learning], [A table with one number for each pair of state and action.], [The squared temporal-difference error, in effect: how far the estimate is from reward plus discounted best next value.], [A small step towards that target after every move.])

== Exploration strategies

#utptable[
  #tabularx(
    columns: (27%, 1fr),
    styles: (navy-bold,),
    header: ([Exploration strategy], [How it encourages exploration]),
    [$epsilon$-greedy], [Usually chooses the best-known action, but chooses a random action with probability $epsilon$.],
    [Optimistic initialization], [Starts Q-values high so untried actions look attractive.],
    [Upper confidence methods], [Prefer actions with either strong estimated reward or high uncertainty.],
  )
]

Too little exploration can trap the agent in a poor policy. Too much exploration wastes reward and may be unsafe.

== Evaluation and responsible use

Training returns mix learning with random moves, so they are not a fair measure of the policy. Evaluate with exploration switched off. Lab~6’s first 100 episodes average a return of $-0.914$, its last 100 average 0.788 (still 5% random moves), and the greedy policy scores exactly 0.800 on 200 out of 200 episodes.

Policies change the data they encounter. Evaluate across seeds and report mean return and variation.

Important concerns include:

- reward design that accidentally encourages unwanted behavior;
- unsafe exploration in physical, medical, financial, or public systems;
- changing environments that make past experience unreliable;
- delayed rewards that make credit assignment difficult;
- simulation assumptions that do not match the real world.

For high-stakes applications, exploration should occur in a safe simulator or under strict constraints before real-world use.

#modelcard[Classical Reinforcement Learning - Quick Guide][
  #tabularx(
    columns: (14%, 1fr),
    valign: (top, horizon),
    styles: (navy-bold,),
    rules: "none",
    [Best when], [Actions affect future states and rewards, and interaction or a realistic simulator is available.],
    [Start with], [A bandit or small tabular MDP before moving to larger problems.],
    [Main controls], [Learning rate $alpha$, discount factor $gamma$, exploration rate $epsilon$, state representation, reward design.],
    [Main risks], [Unsafe exploration, reward hacking, unstable estimates, poor state definition, unrealistic simulation.],
  )
]

#keyidea[
  Reinforcement learning does not learn from a correct answer for every action. It learns from consequences, balancing immediate reward, future reward, and the need to explore.
]

== Exploration schedules

#utpfig([Exploration schedules for $epsilon$ over training episodes: a constant rate of $0.1$, and linear and exponential decays that level off at $0.05$.], label: <fig:epsilon-schedules>)[
  #canvas({
    axis(width: 10.5996cm, height: 4.3cm, axis-lines: "left", title-style: font("small", weight: "bold", fill: navy), title: [Decaying $epsilon$: curious early, decisive later], xlabel: [Episode], ylabel: [$epsilon$], label-style: font("script", fill: muted), tick-label-style: font("script", fill: muted), domain: (0, 1000), samples: 100, xmin: 0, xmax: 1000, ymin: 0, ymax: 1.05, legend-style: (size: font("script").size, draw: none, fill: none, at: (0.98, 0.96), anchor: "north-east"),
      addplot(draw: blue, line-width: widths.very-thick, x => calc.max(0.05, calc.exp(-x / 250)), legend: [exponential decay]),
      addplot(draw: teal, line-width: widths.very-thick, dash: "dashed", x => calc.max(0.05, 1 - x / 800), legend: [linear decay]),
      addplot(draw: muted, line-width: widths.thick, dash: "dotted", x => 0.1, legend: [fixed $epsilon =0.1$]),
    )
  })
]

Lab~6 multiplies $epsilon$ by 0.9985 per episode from a start of 1, so it reaches its floor of 0.05 after 1,996 of the 5,000 episodes.

== Tabular Q-learning dynamics

#utptable[
  #tabularx(
    columns: (15%, 16%, 1fr),
    styles: ((weight: "bold", fill: navy, font: "Source Code Pro", size: 0.88em),),
    header: ([Symbol], [Typical value], [What raising it does]),
    [alpha], [0.01--0.2], [Learn faster from each experience, but more erratically],
    [gamma], [0.9--0.99], [Care more about distant future rewards],
    [epsilon], [1.0 down to 0.05], [Explore more; too high and the agent never commits],
    [episodes], [thousands], [More practice; tabular methods need a lot],
  )
]

#pitfall[
  Continuing tasks generally use $gamma <1$ for a finite discounted return; finite episodes can allow $gamma =1$. Fixed exploration can help in changing environments but costs reward. Evaluate exploratory and greedy policies separately.
]

#libnote[
  #lib("gymnasium") (the maintained successor to OpenAI Gym) provides ready-made environments with a uniform interface, so you can practice without writing the environment mechanics yourself. For problems beyond small tables --- for example, image observations or continuous state spaces --- #lib("stable-baselines3") provides implementations of standard deep-RL algorithms on top of PyTorch.
]

#chapterrecap[
  - RL learns from rewards that arrive after actions. There is no answer column, and actions change the data you see next.
  - Exploring teaches and exploiting earns. On the food stalls, $epsilon =0$ got 0.199 and $epsilon =0.1$ got 0.750 of a possible 0.8.
  - The return discounts future rewards by $gamma$. A value function is an expected return.
  - Q-learning nudges each estimate towards reward plus discounted best next value, so news of a reward walks backward through the table.
  - Evaluate the greedy policy separately from training. In high-stakes settings, explore in a simulator first.
]

#quickcheck[
  + What are the state, action, reward, and transition in a reinforcement-learning formulation?
  + What two pieces of information appear in the tabular Q-learning backup value?
  + With $Q(s,a)=0$, $r=-0.04$, $gamma =0.95$, next-state maximum 0.6 and $alpha =0.15$, what is the new $Q(s,a)$?
  + In the corridor, what is $Q("cell 1","right")$ after episode 2, and why was it zero after episode 1?
  + Why should the exploratory training policy be evaluated separately from the final greedy policy?
  + A student with $epsilon =0$ ate at the first stall forever. Which step of the loop was missing?
]
