"""The small worked numbers of Chapters 26, 27, 29 and 30: rewards, values, weights, filters, memory.

Each function prints what one chapter quotes, and check_book_numbers() at the end ties the
printed book to this code. NumPy is the only package it imports, so it runs without
PyTorch.

Run from the course folder:      python all_experiments/book_checks/demo_advanced.py
It takes a few seconds.
"""
from __future__ import annotations

import numpy as np

CHECK_BOOK_NUMBERS = True
FOUND = {}


# ---------------------------------------------------------- Chapter 26: learning by acting
def bandit(epsilon, rounds=1000, runs=500, seed=4):
    """Three food stalls with hidden chances of a good meal. Average over many hungry students."""
    rng = np.random.default_rng(seed)
    means = np.array([0.2, 0.5, 0.8])
    pulls_total, reward_total, stuck = np.zeros(3), 0.0, 0
    for _ in range(runs):
        estimate, pulls = np.zeros(3), np.zeros(3)
        for _ in range(rounds):
            arm = rng.integers(3) if rng.random() < epsilon else int(np.argmax(estimate))
            reward = float(rng.random() < means[arm])
            pulls[arm] += 1
            estimate[arm] += (reward - estimate[arm]) / pulls[arm]    # a running average
            reward_total += reward
        pulls_total += pulls
        stuck += int(np.argmax(pulls) != 2)
    return pulls_total / runs, reward_total / (runs * rounds), stuck / runs


def corridor_trace():
    """Q-learning by hand: cells 0 to 3, goal at 3 worth +1, always walking right."""
    alpha, gamma = 0.5, 0.9
    q_right = np.zeros(4)
    rows = []
    for episode in range(1, 5):
        for cell in range(3):
            reward = 1.0 if cell + 1 == 3 else 0.0
            future = 0.0 if cell + 1 == 3 else q_right[cell + 1]
            backup = reward + gamma * future
            q_right[cell] += alpha * (backup - q_right[cell])
        rows.append(q_right[:3].round(4).tolist())
    return rows


def gridworld_values(trap=(1, 3), gamma=0.95, cost=-0.04):
    """Value iteration on Lab 6's grid: the numbers its Q-table should learn on its own."""
    goal = (3, 3)
    values = np.zeros((4, 4))
    moves = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for _ in range(200):
        updated = values.copy()
        for r in range(4):
            for c in range(4):
                if (r, c) in (goal, trap):
                    continue
                candidates = []
                for dr, dc in moves:
                    nr, nc = min(max(r + dr, 0), 3), min(max(c + dc, 0), 3)
                    if (nr, nc) == goal:
                        candidates.append(1.0)
                    elif (nr, nc) == trap:
                        candidates.append(-1.0)
                    else:
                        candidates.append(cost + gamma * values[nr, nc])
                updated[r, c] = max(candidates)
        values = updated
    return values


def chapter26():
    print("Chapter 26")
    rewards = [5, 4, 3]
    for gamma in (0.0, 0.5, 0.9, 1.0):
        print(f"  return of 5, 4, 3 with gamma {gamma}: {sum(r * gamma ** i for i, r in enumerate(rewards)):.2f}")
    FOUND["ret"] = sum(r * 0.9 ** i for i, r in enumerate(rewards))
    print(f"  gridworld, six moves: undiscounted {5 * -0.04 + 1:.2f}, discounted {sum(-0.04 * 0.95 ** i for i in range(5)) + 0.95 ** 5:.3f}")

    print("Food stalls with hidden chances 0.2, 0.5, 0.8, 1000 meals, 500 students:")
    table = {}
    for epsilon in (0.0, 0.1, 0.5):
        pulls, reward, stuck = bandit(epsilon)
        table[epsilon] = (pulls, reward, stuck)
        print(f"  epsilon {epsilon}: visits {pulls.round(0).tolist()}, mean reward {reward:.3f}, ended favouring a worse stall {stuck:.1%}")
    FOUND["bandit"] = table

    rows = corridor_trace()
    print("Corridor, Q(cell, right) for cells 0, 1, 2 after each episode:")
    for episode, row in enumerate(rows, 1):
        print(f"  episode {episode}: {row}")
    FOUND["corridor"] = rows

    values = gridworld_values()
    print("Best possible values on Lab 6's grid (value iteration):")
    print(values.round(3))
    FOUND["values"] = values
    print(f"  epsilon reaches 0.05 after {next(i for i in range(10_000) if 0.9985 ** i < 0.05)} episodes of decay 0.9985")


# ------------------------------------------ Chapters 27, 29 and 30: networks, filters, memory
def relu(z):
    return np.maximum(0.0, z)


def sigmoid(z):
    return 1 / (1 + np.exp(-z))


def convolve(image, kernel):
    """Slide the filter over every position where it fits, without padding."""
    rows, cols = image.shape[0] - kernel.shape[0] + 1, image.shape[1] - kernel.shape[1] + 1
    out = np.zeros((rows, cols))
    for r in range(rows):
        for c in range(cols):
            out[r, c] = (image[r:r + kernel.shape[0], c:c + kernel.shape[1]] * kernel).sum()
    return out


def chapter27():
    print("\nChapters 27, 29 and 30")
    # XOR: no straight line works, and two ReLU units do.
    inputs = np.array([[0, 0], [1, 0], [0, 1], [1, 1]], dtype=float)
    target = np.array([0.0, 1, 1, 0])
    design = np.column_stack([np.ones(4), inputs])
    best_line = design @ np.linalg.lstsq(design, target, rcond=None)[0]
    print("XOR, best straight-line fit predicts:", best_line.round(3).tolist())
    h1, h2 = relu(inputs[:, 0] - inputs[:, 1]), relu(inputs[:, 1] - inputs[:, 0])
    print("XOR, hidden units:", h1.tolist(), h2.tolist(), " output:", (h1 + h2).tolist())
    FOUND["xor"] = (best_line, h1 + h2)

    # A forward pass through a small network.
    x = np.array([2.0, 1.0])
    w1, w2, out = np.array([1.0, -1.0]), np.array([0.5, 0.5]), np.array([1.0, -2.0])
    h = relu(np.array([w1 @ x, w2 @ x]))
    print(f"Forward pass: hidden {h.tolist()}, score {out @ h:.1f}, chance {sigmoid(out @ h):.3f}")
    x2 = np.array([1.0, 2.0])
    h2b = relu(np.array([w1 @ x2, w2 @ x2]))
    print(f"  swapped inputs: hidden {h2b.tolist()}, score {out @ h2b:.1f}, chance {sigmoid(out @ h2b):.3f}")
    FOUND["forward"] = (out @ h, sigmoid(out @ h), out @ h2b)

    # One backward pass through two weights, checked by nudging.
    def loss(a, b, x=1.0, y=2.0):
        return (y - b * relu(a * x)) ** 2

    a, b = 2.0, 0.5
    hidden = relu(a * 1.0)
    prediction = b * hidden
    d_b = -2 * (2.0 - prediction) * hidden
    d_a = -2 * (2.0 - prediction) * b * 1.0
    nudge = 1e-5
    print(f"Two weights: hidden {hidden}, prediction {prediction}, loss {loss(a, b)}")
    print(f"  chain rule: d/da = {d_a}, d/db = {d_b}; nudge: {(loss(a + nudge, b) - loss(a, b)) / nudge:.3f}, {(loss(a, b + nudge) - loss(a, b)) / nudge:.3f}")
    a2, b2 = a - 0.1 * d_a, b - 0.1 * d_b
    print(f"  after one step of 0.1: a = {a2:.3f}, b = {b2:.3f}, prediction {b2 * relu(a2):.3f}, loss {loss(a2, b2):.4f}")
    FOUND["backprop"] = (d_a, d_b, a2, b2, loss(a2, b2))

    # Counting weights, the same way Labs 7 and 8 report them.
    dense = (3 * 32 * 32 * 128 + 128) + (128 * 7 + 7)                  # Lab 7: 32 x 32 colour images, seven types
    conv1, conv2 = 3 * 16 * 3 * 3 + 16, 16 * 32 * 3 * 3 + 32
    fc1, fc2 = 32 * 8 * 8 * 64 + 64, 64 * 7 + 7
    lstm = 4 * (1 * 32 + 32 * 32 + 32 + 32)
    print(f"Weights: dense {dense}; CNN {conv1} + {conv2} + {fc1} + {fc2} = {conv1 + conv2 + fc1 + fc2}; LSTM {lstm} + 33 = {lstm + 33}")
    FOUND["weights"] = (dense, conv1 + conv2 + fc1 + fc2, lstm + 33)

    # A filter sliding over a small image.
    image = np.array([[0, 0, 0, 9, 9],
                      [0, 0, 0, 9, 9],
                      [0, 0, 0, 9, 9],
                      [0, 0, 0, 9, 9],
                      [0, 0, 0, 9, 9]], dtype=float)
    vertical = np.array([[-1, 0, 1], [-1, 0, 1], [-1, 0, 1]], dtype=float)
    horizontal = vertical.T
    print("Vertical-edge filter on the image:\n", convolve(image, vertical))
    print("Horizontal-edge filter on the image:\n", convolve(image, horizontal))
    FOUND["conv"] = convolve(image, vertical)
    # The chapter's figure: a stroke two cells wide on an 8x8 grid, filtered with padding.
    stroke = np.zeros((8, 8))
    stroke[1:7, 3:5] = 1.0
    stroke_map = convolve(np.pad(stroke, 1), vertical)
    print("Vertical-edge filter on the 8x8 stroke, with padding:\n", stroke_map.astype(int))
    FOUND["stroke"] = stroke_map
    feature = np.array([[1, 3, 2, 0], [4, 2, 0, 1], [0, 0, 5, 6], [1, 2, 3, 0]], dtype=float)
    pooled = np.array([[feature[r:r + 2, c:c + 2].max() for c in (0, 2)] for r in (0, 2)])
    print("Max pooling a 4x4 map:\n", pooled)
    FOUND["pool"] = pooled

    # Memory by hand: a recurrent unit with fixed weights, and a tiny gated note.
    state, states = 0.0, []
    for value in (1.0, 2.0, 3.0):
        state = 0.5 * state + value
        states.append(state)
    print("Recurrent state, 0.5*previous + input, for inputs 1, 2, 3:", states)
    note = 10.0
    keep, write, new = 0.8, 0.5, 4.0
    print(f"Gated note: keep {keep} of {note} and write {write} of {new}: {keep * note + write * new}")
    FOUND["memory"] = (states, keep * note + write * new)
    faded = [0.5 ** i for i in range(0, 25, 8)]
    print("Plain RNN: weight of an input after 0, 8, 16, 24 steps at 0.5 per step:", np.round(faded, 8).tolist())

    series = np.array([16, 40, 32, 13, 1, 1, 2, 3], dtype=float)
    lookback = 3
    windows = [series[i:i + lookback].tolist() for i in range(len(series) - lookback)]
    print(f"Windows of 3 from 8 values: {windows} -> targets {series[lookback:].tolist()}")
    print(f"Persistence absolute errors: {np.abs(series[lookback:] - series[lookback - 1:-1]).tolist()}")
    FOUND["windows"] = (len(windows),)


def close(a, b, tol=0.006):
    return abs(a - b) <= tol


def check_book_numbers():
    f = FOUND
    assert close(f["ret"], 11.03)
    assert close(f["bandit"][0.0][1], 0.2, 0.02) and close(f["bandit"][0.1][1], 0.75, 0.01) and close(f["bandit"][0.5][1], 0.648, 0.01)
    assert close(f["bandit"][0.1][0][2], 889, 15)
    assert f["corridor"][0] == [0.0, 0.0, 0.5] and f["corridor"][1] == [0.0, 0.225, 0.75]
    assert close(f["values"][0, 0], 0.593, 0.001) and close(f["values"][0, 3], 0.666, 0.001) and close(f["values"][2, 3], 1.0)
    assert np.allclose(f["xor"][0], 0.5) and f["xor"][1].tolist() == [0.0, 1.0, 1.0, 0.0]
    assert close(f["forward"][0], -2.0) and close(f["forward"][1], 0.119, 0.001) and close(f["forward"][2], -3.0)
    d_a, d_b, a2, b2, new_loss = f["backprop"]
    assert (d_a, d_b) == (-1.0, -4.0) and close(a2, 2.1) and close(b2, 0.9) and close(new_loss, 0.0121, 0.0001)
    assert f["weights"] == (394247, 136679, 4513)
    assert f["conv"].tolist() == [[0, 27, 27], [0, 27, 27], [0, 27, 27]] and f["pool"].tolist() == [[4, 2], [2, 6]]
    assert f["stroke"].shape == (8, 8) and f["stroke"][3].tolist() == [0, 0, 3, 3, -3, -3, 0, 0]
    assert f["stroke"][:, 2].tolist() == [1, 2, 3, 3, 3, 3, 2, 1] and f["stroke"][:, 5].tolist() == [-1, -2, -3, -3, -3, -3, -2, -1]
    assert f["memory"][0] == [1.0, 2.5, 4.25] and close(f["memory"][1], 10.0) and f["windows"][0] == 5
    print("\nEvery number above matches the book.")


def main():
    chapter26()
    chapter27()

    if CHECK_BOOK_NUMBERS:
        check_book_numbers()


if __name__ == "__main__":
    main()
