rng = np.random.default_rng(42)

# A tiny 4x4 GridWorld. Start at the top-left, reach the goal at bottom-right,
# and avoid the trap. No external environment package is required.
ROWS, COLS = 4, 4
START = (0, 0)
GOAL = (3, 3)
TRAP = (1, 3)
ACTIONS = [(-1, 0), (1, 0), (0, -1), (0, 1)]  # up, down, left, right
ACTION_NAMES = ["up", "down", "left", "right"]

Q = np.zeros((ROWS, COLS, len(ACTIONS)), dtype=float)
alpha = 0.15
gamma = 0.95
epsilon = 1.0
min_epsilon = 0.05
