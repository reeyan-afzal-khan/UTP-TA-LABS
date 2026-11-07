# Complete executable companion to lab06_reinforcement_worked.ipynb
# Code cells are kept in notebook order, including worked extensions.
from pathlib import Path
import os
from IPython.display import display
os.chdir(Path(__file__).resolve().parent)

import re
import pandas as pd
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

PROJECT_ROOT = Path.cwd().parent
MODELS = PROJECT_ROOT / "models"
MODELS.mkdir(exist_ok=True)

RESULTS = PROJECT_ROOT / "results" / "lab06"
RESULTS.mkdir(parents=True, exist_ok=True)
print("course folder:", PROJECT_ROOT.name)

rng = np.random.default_rng(42)

ROWS, COLS = 4, 4
START, GOAL, TRAP = (0, 0), (3, 3), (1, 3)
ACTIONS = [(-1, 0), (1, 0), (0, -1), (0, 1)]        # up, down, left, right
ACTION_NAMES = ["up", "down", "left", "right"]
ARROWS = {"up": (0, 1), "down": (0, -1), "left": (-1, 0), "right": (1, 0)}

def step(state, action):
    """Apply one action. Returns (next_state, reward, done)."""
    r, c = state
    dr, dc = ACTIONS[action]
    next_state = (min(max(r + dr, 0), ROWS - 1), min(max(c + dc, 0), COLS - 1))
    if next_state == GOAL:
        return next_state, 1.0, True
    if next_state == TRAP:
        return next_state, -1.0, True
    return next_state, -0.04, False

Q = np.zeros((ROWS, COLS, len(ACTIONS)))
alpha, gamma = 0.15, 0.95
epsilon, min_epsilon = 1.0, 0.05

def choose_action(state, explore=True):
    if explore and rng.random() < epsilon:
        return int(rng.integers(len(ACTIONS)))       # explore: random move
    return int(np.argmax(Q[state]))                  # exploit: best known move

training_returns = []
for episode in range(5000):
    state, episode_return = START, 0.0
    for _ in range(100):
        action = choose_action(state)
        next_state, reward, done = step(state, action)
        episode_return += reward
        target = reward if done else reward + gamma * np.max(Q[next_state])
        Q[state][action] += alpha * (target - Q[state][action])
        state = next_state
        if done:
            break
    training_returns.append(episode_return)
    epsilon = max(min_epsilon, epsilon * 0.9985)

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

q_path = MODELS / "gridworld_q_table.npy"
np.save(q_path, Q)

Q_loaded = np.load(q_path)
policy = np.full((ROWS, COLS), "", dtype=object)
for r in range(ROWS):
    for c in range(COLS):
        policy[r, c] = "GOAL" if (r, c) == GOAL else "TRAP" if (r, c) == TRAP \
            else ACTION_NAMES[int(np.argmax(Q_loaded[r, c]))]
print(policy)

def plot_policy(Q_table, title):
    values = Q_table.max(axis=2)
    plt.figure(figsize=(4.4, 4.2))
    plt.imshow(values, cmap="YlGn")
    plt.colorbar(label="value of the best action")
    for r in range(ROWS):
        for c in range(COLS):
            if (r, c) == GOAL:
                plt.text(c, r, "GOAL", ha="center", va="center", fontweight="bold")
            elif (r, c) == TRAP:
                plt.text(c, r, "TRAP", ha="center", va="center", color="red", fontweight="bold")
            else:
                dx, dy = ARROWS[ACTION_NAMES[int(np.argmax(Q_table[r, c]))]]
                plt.arrow(c, r, 0.3 * dx, -0.3 * dy, head_width=0.15, color="black")
    plt.xticks(range(COLS))
    plt.yticks(range(ROWS))
    plt.title(title)
    plt.tight_layout()
    plt.savefig(RESULTS / (re.sub(r"[^a-z0-9]+", "_", title.lower()).strip("_") + ".png"), dpi=160, bbox_inches="tight")
    plt.show()

plot_policy(Q_loaded, "Greedy policy and state values")

pd.DataFrame(policy, index=[f"row{r}" for r in range(ROWS)],
             columns=[f"col{c}" for c in range(COLS)]).to_csv(RESULTS / "greedy_policy.csv")
pd.DataFrame({"episode": np.arange(1, len(training_returns) + 1), "return": training_returns}).to_csv(
    RESULTS / "training_returns.csv", index=False)
pd.DataFrame([{"environment": "gridworld_4x4", "algorithm": "tabular_q_learning", "episodes": len(training_returns),
               "success_rate": successes / 200, "mean_greedy_return": float(np.mean(returns)),
               "start_action": ACTION_NAMES[choose_action(START, explore=False)]}]).round(4).to_csv(
    RESULTS / "metrics.csv", index=False)
print("Saved:", sorted(p.name for p in RESULTS.iterdir()))

# Your work here

def train_q(trap, step_cost=-0.04, gamma_=0.95, episodes=5000, seed=42):
    """Retrain from scratch on a grid with the given trap position and step cost."""
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
            action = int(r.integers(len(ACTIONS))) if r.random() < eps else int(np.argmax(Q_new[state]))
            nxt, reward, done = step_new(state, action)
            target = reward if done else reward + gamma_ * np.max(Q_new[nxt])
            Q_new[state][action] += alpha * (target - Q_new[state][action])
            state = nxt
            if done:
                break
        eps = max(min_epsilon, eps * 0.9985)
    return Q_new

Q_moved = train_q(trap=(3, 1))
TRAP = (3, 1)                      # so plot_policy labels the new trap cell
plot_policy(Q_moved, "Trap moved to (3, 1)")
TRAP = (1, 3)                      # restore the lab's environment

