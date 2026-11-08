"""Lab 06: Reinforcement learning.

The code cells of lab06_reinforcement_worked.ipynb, in notebook order, as one script. From the course folder:
    python all_experiments/lab06_reinforcement/lab06_reinforcement_worked.py
It writes the same figures and tables as the notebook, to results/lab06/.
"""
from pathlib import Path
import os
os.chdir(Path(__file__).resolve().parent)

# 1. The course helper: finds the course folder and prepares the output folders.
import sys
sys.path.insert(0, "..")                     # all_experiments/, where course_setup.py lives
from course_setup import start_lab

# 2. The libraries this lab uses. Reinforcement learning here needs only NumPy: no dataset, no scikit-learn.
import re
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# 3. Where this lab reads and writes (it reads no data file).
DATA, RESULTS, MODELS = start_lab("lab06")

rng = np.random.default_rng(42)              # one random generator, so every run explores the same way

# The world: a 4 x 4 grid. Cells are (row, column), with (0, 0) at the top left.
ROWS, COLS = 4, 4
START, GOAL, TRAP = (0, 0), (3, 3), (1, 3)
ACTIONS = [(-1, 0), (1, 0), (0, -1), (0, 1)]        # how each move changes (row, column)
ACTION_NAMES = ["up", "down", "left", "right"]
ARROWS = {"up": (0, 1), "down": (0, -1), "left": (-1, 0), "right": (1, 0)}   # for drawing the policy

def step(state, action):
    """Apply one action. Returns (next_state, reward, done)."""
    r, c = state
    dr, dc = ACTIONS[action]
    # A move into the wall leaves the agent where it is.
    next_state = (min(max(r + dr, 0), ROWS - 1), min(max(c + dc, 0), COLS - 1))
    if next_state == GOAL:
        return next_state, 1.0, True
    if next_state == TRAP:
        return next_state, -1.0, True
    return next_state, -0.04, False          # every ordinary move costs a little, so shorter routes are better

Q = np.zeros((ROWS, COLS, len(ACTIONS)))     # Q[row, col, action]: the value of each move from each cell
alpha, gamma = 0.15, 0.95                    # learning rate, and how much a later reward is worth
epsilon, min_epsilon = 1.0, 0.05             # chance of a random move: starts at 1, shrinks to 0.05

def choose_action(state, explore=True):
    """Epsilon-greedy: a random move with probability epsilon, otherwise the best known move."""
    if explore and rng.random() < epsilon:
        return int(rng.integers(len(ACTIONS)))       # explore: random move
    return int(np.argmax(Q[state]))                  # exploit: best known move

training_returns = []
for episode in range(5000):
    state, episode_return = START, 0.0
    for _ in range(100):                             # at most 100 moves per episode
        action = choose_action(state)
        next_state, reward, done = step(state, action)
        episode_return += reward
        # The Q-learning update: move Q towards the reward plus the best value of the next cell.
        target = reward if done else reward + gamma * np.max(Q[next_state])
        Q[state][action] += alpha * (target - Q[state][action])
        state = next_state
        if done:
            break
    training_returns.append(episode_return)
    epsilon = max(min_epsilon, epsilon * 0.9985)     # explore a little less after every episode

# The return of a single episode is noisy, so plot the mean over a sliding window of 100 episodes.
window = 100
moving = np.convolve(training_returns, np.ones(window) / window, mode="valid")
plt.figure(figsize=(6, 3.6))
plt.plot(np.arange(window - 1, len(training_returns)), moving)
plt.axhline(0.8, linestyle="--", color="grey", label="best possible return (6 moves)")
plt.xlabel("Episode")
plt.ylabel("Mean return over last 100 episodes")
plt.title("Q-learning training curve")
plt.legend()
plt.tight_layout()
plt.savefig(RESULTS / "q_learning_training_curve.png", dpi=160, bbox_inches="tight")
plt.show()

# Run the learned policy 200 times without exploring: always the best known move.
successes, returns = 0, []
for _ in range(200):
    state, total = START, 0.0
    for _ in range(100):
        state, reward, done = step(state, choose_action(state, explore=False))
        total += reward
        if done:
            successes += int(state == GOAL)
            break
    returns.append(total)

print("success rate:", successes / 200)
print("mean return:", round(float(np.mean(returns)), 3))
print("learned action at start:", ACTION_NAMES[choose_action(START, explore=False)])

# The Q-table is the whole model: save it, load it back, and read the best move in every cell.
q_path = MODELS / "gridworld_q_table.npy"
np.save(q_path, Q)
Q_loaded = np.load(q_path)

def greedy_policy(Q_table, trap=TRAP):
    """The name of the best move in every cell, with the goal and the trap marked."""
    policy = np.full((ROWS, COLS), "", dtype=object)
    for r in range(ROWS):
        for c in range(COLS):
            if (r, c) == GOAL:
                policy[r, c] = "GOAL"
            elif (r, c) == trap:
                policy[r, c] = "TRAP"
            else:
                policy[r, c] = ACTION_NAMES[int(np.argmax(Q_table[r, c]))]
    return policy

policy = greedy_policy(Q_loaded)
print(policy)

def plot_policy(Q_table, title, trap=TRAP):
    """Color each cell by its best value, and draw an arrow for its best move."""
    values = Q_table.max(axis=2)
    plt.figure(figsize=(4.4, 4.2))
    plt.imshow(values, cmap="YlGn")
    plt.colorbar(label="value of the best action")
    for r in range(ROWS):
        for c in range(COLS):
            if (r, c) == GOAL:
                plt.text(c, r, "GOAL", ha="center", va="center", fontweight="bold")
            elif (r, c) == trap:
                plt.text(c, r, "TRAP", ha="center", va="center", color="red", fontweight="bold")
            else:
                dx, dy = ARROWS[ACTION_NAMES[int(np.argmax(Q_table[r, c]))]]
                plt.arrow(c, r, 0.3 * dx, -0.3 * dy, head_width=0.15, color="black")
    plt.xticks(range(COLS))
    plt.yticks(range(ROWS))
    plt.title(title)
    plt.tight_layout()
    file_name = re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_") + ".png"   # the title, as a file name
    plt.savefig(RESULTS / file_name, dpi=160, bbox_inches="tight")
    plt.show()

plot_policy(Q_loaded, "Greedy policy and state values")

policy_table = pd.DataFrame(policy, index=[f"row{r}" for r in range(ROWS)], columns=[f"col{c}" for c in range(COLS)])
policy_table.to_csv(RESULTS / "greedy_policy.csv")
returns_table = pd.DataFrame({"episode": np.arange(1, len(training_returns) + 1), "return": training_returns})
returns_table.to_csv(RESULTS / "training_returns.csv", index=False)
metrics = pd.DataFrame([{
    "environment": "gridworld_4x4", "algorithm": "tabular_q_learning", "episodes": len(training_returns),
    "success_rate": successes / 200, "mean_greedy_return": float(np.mean(returns)),
    "start_action": ACTION_NAMES[choose_action(START, explore=False)],
}])
metrics.round(4).to_csv(RESULTS / "metrics.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# Your work here

def train_q(trap, step_cost=-0.04, gamma_=0.95, episodes=5000, seed=42):
    """Retrain from scratch on a grid with the given trap position and step cost; returns the new Q-table."""
    r = np.random.default_rng(seed)
    Q_new = np.zeros((ROWS, COLS, len(ACTIONS)))
    eps = 1.0

    def step_new(state, action):
        rr, cc = state
        dr, dc = ACTIONS[action]
        nxt = (min(max(rr + dr, 0), ROWS - 1), min(max(cc + dc, 0), COLS - 1))
        if nxt == GOAL:
            return nxt, 1.0, True
        if nxt == trap:
            return nxt, -1.0, True
        return nxt, step_cost, False

    for _ in range(episodes):
        state = START
        for _ in range(100):
            if r.random() < eps:
                action = int(r.integers(len(ACTIONS)))
            else:
                action = int(np.argmax(Q_new[state]))
            nxt, reward, done = step_new(state, action)
            target = reward if done else reward + gamma_ * np.max(Q_new[nxt])
            Q_new[state][action] += alpha * (target - Q_new[state][action])
            state = nxt
            if done:
                break
        eps = max(min_epsilon, eps * 0.9985)
    return Q_new

moved_trap = (3, 1)
Q_moved = train_q(trap=moved_trap)
print(f"Greedy policy with the trap at {moved_trap}:")
for row in greedy_policy(Q_moved, trap=moved_trap):
    print("".join(name.ljust(7) for name in row).rstrip())
plot_policy(Q_moved, "Trap moved to (3, 1)", trap=moved_trap)
