"""A tutor's study log: the four core methods of the book, on ten students.

Every number the book quotes for the study log (Chapters 2, 4, 9, 10, 16 and 17) is printed
here and checked by an assert, so the text and the code cannot drift apart. To try a log of
your own, edit LOG and set CHECK_BOOK_NUMBERS to False.

Run from the course folder:      python all_experiments/book_checks/demo_study_log.py
No dataset is needed, and NumPy is the only package it imports.
"""
from __future__ import annotations

from itertools import combinations

import numpy as np

# One row per student: hours studied in the final week, lectures attended (of 14),
# hours slept the night before the exam, and the exam mark out of 100.
LOG = np.array([
    [ 2,  8, 8, 47],   # A
    [ 4,  6, 8, 50],   # B
    [ 6,  7, 7, 59],   # C
    [ 8,  9, 7, 65],   # D
    [10, 11, 7, 68],   # E
    [12, 13, 6, 77],   # F
    [14, 12, 5, 62],   # G
    [16, 10, 4, 52],   # H
    [18,  5, 3, 43],   # I
    [20,  3, 2, 38],   # J
], dtype=float)
NAMES = "ABCDEFGHIJ"
COLUMNS = ["hours", "lectures", "sleep", "mark"]
hours, lectures, sleep, mark = LOG.T
passed = (mark >= 50).astype(float)
CHECK_BOOK_NUMBERS = True


# ------------------------------------------------------------- 1. a straight line
def mse(w, b, x, y):
    """Mean squared error of the line y = w*x + b: the loss the line is judged by."""
    errors = y - (w * x + b)
    return (errors ** 2).mean()


def best_line(x, y):
    """Least squares for one feature: the slope and intercept at the bottom of the bowl."""
    X = np.column_stack([np.ones_like(x), x])       # a column of ones carries the intercept
    b, w = np.linalg.solve(X.T @ X, X.T @ y)        # solve the normal equations
    return w, b


# -------------------------------------------------------------- 2. walking downhill
def walk(slope, start, learning_rate, steps):
    """Gradient descent on one number: step against the slope, again and again."""
    path = [start]
    for _ in range(steps):
        path.append(path[-1] - learning_rate * slope(path[-1]))
    return path


# ------------------------------------------------------------------- 3. the S-curve
def sigmoid(z):
    """The dimmer switch: any score in, a value strictly between 0 and 1 out."""
    return 1 / (1 + np.exp(-z))


def log_loss(p, y):
    """The fee for the chance p given to what actually happened, averaged over the rows."""
    return -(y * np.log(p) + (1 - y) * np.log(1 - p)).mean()


def fit_logistic(x, y, learning_rate=0.1, steps=2000, report=()):
    """Gradient descent on w and b. There is no exact formula, so the model has to walk."""
    w, b = 0.0, 0.0
    for step in range(1, steps + 1):
        p = sigmoid(w * x + b)
        w, b = w - learning_rate * ((p - y) * x).mean(), b - learning_rate * (p - y).mean()
        if step in report:
            print(f"  step {step:>5}: w = {w:.4f}  b = {b:.4f}  "
                  f"log loss = {log_loss(sigmoid(w * x + b), y):.4f}")
    return w, b


# -------------------------------------------------------------------- 4. landmarks
def kmeans(points, start):
    """Assign, move, repeat, until no point changes its group. Returns the whole history."""
    centers = points[list(start)].copy()
    history, labels = [], None
    while True:
        squared = ((points[:, None] - centers[None]) ** 2).sum(axis=2)   # every point to every center
        new_labels = squared.argmin(axis=1)                              # assign: nearest center wins
        if labels is not None and (new_labels == labels).all():
            return labels, centers, history
        labels = new_labels
        history.append((labels.copy(), centers.copy()))
        centers = np.array([points[labels == g].mean(axis=0) if (labels == g).any() else centers[g]
                            for g in range(len(centers))])               # move: mean of its members


def total_squared_distance(points, labels, centers):
    return ((points - centers[labels]) ** 2).sum()


def group_text(labels, k):
    return " | ".join("".join(NAMES[i] for i in np.flatnonzero(labels == g)) for g in range(k))


# ----------------------------------------------------------------------- 5. shadows
def pca(table):
    """Scale the columns, build the correlation table, and rank its directions by spread."""
    scaled = (table - table.mean(axis=0)) / table.std(axis=0)
    correlation = scaled.T @ scaled / len(scaled)
    spreads, directions = np.linalg.eigh(correlation)        # eigh sorts smallest first
    order = np.argsort(spreads)[::-1]
    return scaled, correlation, spreads[order], directions[:, order]


# ---------------------------------------------------------------------------- main
def main():
    np.set_printoptions(precision=3, suppress=True, linewidth=110)
    print("The log: hours, lectures, sleep, mark")
    for name, row, ok in zip(NAMES, LOG, passed):
        print(f"  {name}  {row[0]:>3.0f} {row[1]:>3.0f} {row[2]:>3.0f} {row[3]:>4.0f}   {'pass' if ok else 'fail'}")

    # ----- regression on the first six students
    x, y = hours[:6], mark[:6]
    print(f"\nFirst six students: mean hours {x.mean():.0f}, mean mark {y.mean():.0f}")
    guess_a, guess_b = (2.0, y.mean() - 2 * x.mean()), (5.0, y.mean() - 5 * x.mean())
    for label, (w, b) in [("A", guess_a), ("B", guess_b)]:
        errors = y - (w * x + b)
        print(f"  guess {label}: mark = {w:.0f}*hours + {b:.0f}  errors {errors}  "
              f"mean error {errors.mean():.2f}  MSE {mse(w, b, x, y):.2f}")
    errors_a = y - (guess_a[0] * x + guess_a[1])
    gradient_a = (-2 * (errors_a * x).mean(), -2 * errors_a.mean())
    print(f"  gradient of the loss at guess A: d/dw = {gradient_a[0]:.2f}, d/db = {gradient_a[1]:.2f}")
    print("The bowl, with each line through the average student:")
    bowl = {w: mse(w, y.mean() - w * x.mean(), x, y) for w in range(0, 7)}
    print("  ", {w: round(v, 2) for w, v in bowl.items()})
    w_fit, b_fit = best_line(x, y)
    errors = y - (w_fit * x + b_fit)
    X = np.column_stack([np.ones_like(x), x])
    print(f"Best line: mark = {w_fit:.0f}*hours + {b_fit:.0f}, errors {errors}, MSE {mse(w_fit, b_fit, x, y):.2f}, "
          f"RMSE {np.sqrt(mse(w_fit, b_fit, x, y)):.2f}")
    print("  X'X =", (X.T @ X).tolist(), " X'y =", (X.T @ y).tolist())
    print(f"  prediction for 9 hours: {w_fit * 9 + b_fit:.0f}")
    print(f"  numpy.polyfit agrees: {np.polyfit(x, y, 1).round(6).tolist()}")

    # ----- the arch: all ten students
    w_all, b_all = best_line(hours, mark)
    r_all = np.corrcoef(hours, mark)[0, 1]
    print(f"\nAll ten students: mark = {w_all:.2f}*hours + {b_all:.2f}, r = {r_all:.2f}")
    centered = (hours - hours.mean()) / hours.std()
    print("Polynomial degree: training MSE and leave-one-out MSE")
    capacity = {}
    for degree in range(0, 8):
        coefficients = np.polyfit(centered, mark, degree)
        train = ((np.polyval(coefficients, centered) - mark) ** 2).mean()
        held_out = []
        for i in range(len(mark)):
            keep = np.arange(len(mark)) != i
            c = np.polyfit(centered[keep], mark[keep], degree)
            held_out.append((np.polyval(c, centered[i]) - mark[i]) ** 2)
        capacity[degree] = (train, np.mean(held_out))
        print(f"  degree {degree}: train {train:8.2f}   left-out {np.mean(held_out):9.2f}")
    without_j = np.arange(len(mark)) != 9
    hidden_j = np.polyval(np.polyfit(centered[without_j], mark[without_j], 7), centered[9])
    print(f"  degree 7 fitted without student J predicts {hidden_j:.0f} for J, whose mark was {mark[9]:.0f}")
    seven = np.polyfit(centered, mark, 7)
    grid = np.arange(2, 20.01, 0.5)
    curve = np.polyval(seven, (grid - hours.mean()) / hours.std())
    print("  degree 7 curve for the figure:", " ".join(f"({g:g},{v:.1f})" for g, v in zip(grid, curve)))
    quadratic = np.polyfit(hours, mark, 2)
    print(f"  degree 2 in hours: {quadratic.round(3).tolist()}, peak at {-quadratic[1] / (2 * quadratic[0]):.1f} hours")

    # ----- walking downhill on a practice bowl
    slope = lambda v: 2 * (v - 4)
    print("\nPractice bowl (v - 4)^2, starting at 0")
    nudge = ((0.001 - 4) ** 2 - (0 - 4) ** 2) / 0.001
    print(f"  nudge test at 0: {nudge:.3f}  formula: {slope(0):.0f}")
    steady = walk(slope, 0.0, 0.1, 5)
    print("  rate 0.1 :", np.round(steady, 4).tolist())
    print("  height   :", np.round([(v - 4) ** 2 for v in steady], 4).tolist())
    timid = walk(slope, 0.0, 0.01, 5)
    print("  rate 0.01:", np.round(timid, 4).tolist())
    wild = walk(slope, 0.0, 1.1, 5)
    print("  rate 1.1 :", np.round(wild, 4).tolist())
    far = walk(slope, 0.0, 0.1, 30)
    print(f"  rate 0.1 after 30 steps: {far[-1]:.4f}")

    # ----- walking to the best line instead of solving for it
    w, b = 0.0, 0.0
    center = x - x.mean()
    for step in range(1, 1001):
        residual = y - (w * center + b)
        w, b = w + 0.01 * 2 * (residual * center).mean(), b + 0.01 * 2 * residual.mean()
    print(f"Walking to the line (hours centered on 7): w = {w:.3f}, b = {b:.3f} after 1000 steps")

    # ----- a straight line on yes/no labels fails
    line = np.polyfit(lectures, passed, 1)
    print(f"\nLine on pass/fail against lectures: {line.round(3).tolist()}")
    print(f"  at 0 lectures: {np.polyval(line, 0):.3f}   at 13 lectures: {np.polyval(line, 13):.3f}")

    # ----- logistic regression on the lectures column
    print("Dimmer: sigmoid(-2), sigmoid(0), sigmoid(2) =", np.round(sigmoid(np.array([-2.0, 0.0, 2.0])), 3))
    centered_lectures = lectures - 8
    print("Log-loss walk, lectures centered on 8:")
    w_log, b_log = fit_logistic(centered_lectures, passed, report=(1, 10, 100, 500, 2000))
    p = sigmoid(w_log * centered_lectures + b_log)
    print(f"  slope check at the start: formula {((0.5 - passed) * centered_lectures).mean():.4f}  "
          f"nudge {(log_loss(sigmoid(0.001 * centered_lectures), passed) - log_loss(sigmoid(0 * centered_lectures), passed)) / 0.001:.4f}")
    print("  student lectures passed  score    chance  verdict")
    order = np.argsort(lectures)
    for i in order:
        z = w_log * centered_lectures[i] + b_log
        print(f"     {NAMES[i]}      {lectures[i]:>3.0f}     {passed[i]:.0f}   {z:>6.3f}   {p[i]:.3f}   "
              f"{'pass' if p[i] >= 0.5 else 'fail'}")
    verdict = (p >= 0.5).astype(float)
    print(f"  right on {int((verdict == passed).sum())} of 10; boundary at {8 - b_log / w_log:.2f} lectures")
    fees_wrong = -np.log(1 - p[0])
    print(f"  student A was given {p[0]:.3f} and failed: squared error {p[0] ** 2:.3f}, log-loss fee {fees_wrong:.3f}")
    print("  a failing student given chance p: p, squared error, fee")
    for q in (0.6, 0.9, 0.99):
        print(f"    {q:.2f}   {q ** 2:.3f}   {-np.log(1 - q):.3f}")
    print(f"  a fifty-fifty call costs {-np.log(0.5):.3f} whichever way it goes")
    print(f"  thirteen lectures: score {w_log * 5 + b_log:.2f}, chance {sigmoid(w_log * 5 + b_log):.3f}")
    print(f"  each extra lecture multiplies the odds by {np.exp(w_log):.2f}")
    print(f"  student B was given {p[1]:.3f} and passed: fee {-np.log(p[1]):.3f}")

    # ----- K-means on hours and mark
    points = LOG[:, [0, 3]]
    print("\nK-means on hours and mark, starting from D, F and J")
    start = [NAMES.index(c) for c in "DFJ"]
    labels, centers, history = kmeans(points, start)
    for round_no, (assigned, used) in enumerate(history, 1):
        print(f"  round {round_no}: centers {used.round(2).tolist()}  groups {group_text(assigned, 3)}")
    print(f"  final centers {centers.round(2).tolist()}")
    score = total_squared_distance(points, labels, centers)
    print(f"  total squared distance {score:.2f}, rounds until nothing changed: {len(history)}")
    subtotals = [((points[labels == g] - centers[g]) ** 2).sum() for g in range(3)]
    print("  subtotals by group", np.round(subtotals, 2).tolist())
    probe = ((points[0] - np.array([8, 65])) ** 2).sum()
    print(f"  squared distance from A to a landmark at (8, 65): {probe:.0f}")
    print("Every possible start of three students:")
    outcomes = {}
    for triple in combinations(range(10), 3):
        lab, cen, _ = kmeans(points, triple)
        outcomes.setdefault(round(total_squared_distance(points, lab, cen), 2), []).append(triple)
    ranked = sorted(outcomes.items())
    print("  ", [(s, len(v)) for s, v in ranked])
    worst_start = "".join(NAMES[i] for i in ranked[-1][1][0])
    print(f"  best {ranked[0][0]} from {len(ranked[0][1])} of 120 starts; worst {ranked[-1][0]} from {worst_start}")
    print("Best total for each k (trying every start):")
    elbow = {}
    for k in range(1, 7):
        elbow[k] = min(total_squared_distance(points, *kmeans(points, s)[:2]) for s in combinations(range(10), k))
    print("  ", {k: round(v, 2) for k, v in elbow.items()})
    print("   savings:", [round(elbow[k] - elbow[k + 1], 1) for k in range(1, 6)])

    # ----- PCA on all four columns
    print(f"\nSpread: mark mean {mark.mean():.1f}, variance {mark.var():.2f}, standard deviation {mark.std():.2f}")
    steady_marks = np.array([54, 55, 56, 56, 56, 57, 57, 57, 56, 57], dtype=float)
    print(f"  a steady group of ten: mean {steady_marks.mean():.1f}, variance {steady_marks.var():.2f}, "
          f"standard deviation {steady_marks.std():.2f}")
    scaled, correlation, spreads, directions = pca(LOG)
    print("Means", LOG.mean(axis=0).round(2).tolist(), " standard deviations", LOG.std(axis=0).round(2).tolist())
    print("Student F in steps:", scaled[5].round(2).tolist())
    print("Correlation table:\n", correlation.round(2))
    shadow_a = scaled[:, [0, 2]] @ (np.array([1, -1]) / np.sqrt(2))
    shadow_b = scaled[:, [0, 2]] @ (np.array([1, 1]) / np.sqrt(2))
    print(f"Hours and sleep: spread along (0.71, -0.71) = {shadow_a.var():.3f}, along (0.71, 0.71) = {shadow_b.var():.3f}")
    print(f"  student J: scaled {scaled[9, [0, 2]].round(2).tolist()}  shadow {shadow_a[9]:.2f}")
    shares = spreads / spreads.sum()
    print("Direction spreads", spreads.round(3).tolist(), " shares", shares.round(3).tolist(),
          " first two", round(shares[:2].sum(), 3))
    flip = np.sign(directions[np.argmax(np.abs(directions), axis=0), range(4)])   # a fixed sign, for printing
    directions = directions * flip
    print("Direction 1:", dict(zip(COLUMNS, directions[:, 0].round(2).tolist())))
    print("Direction 2:", dict(zip(COLUMNS, directions[:, 1].round(2).tolist())))
    coordinates = scaled @ directions[:, :2]
    print("Map coordinates:")
    for name, row in zip(NAMES, coordinates):
        print(f"  {name}  {row[0]:>6.2f}  {row[1]:>6.2f}")

    if CHECK_BOOK_NUMBERS:
        close = lambda a, b, tol=0.006: abs(a - b) <= tol
        assert (x.mean(), y.mean()) == (7, 61)
        assert close(mse(*guess_a, x, y), 13.67) and close(mse(*guess_b, x, y), 48.67)
        assert close(bowl[3], 2.0) and close(bowl[0], 107.0) and close(bowl[6], 107.0)
        assert close(gradient_a[0], -23.33) and close(gradient_a[1], 0.0)
        assert close(w_fit, 3) and close(b_fit, 40) and close(mse(w_fit, b_fit, x, y), 2.0)
        assert (X.T @ X).tolist() == [[6, 42], [42, 364]] and (X.T @ y).tolist() == [366, 2772]
        assert close(w_all, -0.5) and close(b_all, 61.6) and close(r_all, -0.25)
        assert close(capacity[1][0], 125.44) and close(capacity[1][1], 206.83)
        assert close(capacity[2][0], 18.34) and close(capacity[2][1], 43.48)
        assert close(capacity[4][0], 6.22) and close(capacity[4][1], 20.21)
        assert close(capacity[7][0], 3.48) and close(capacity[7][1], 3907.53, 0.1)
        assert close(steady[1], 0.8) and close(steady[5], 2.6893) and close(timid[5], 0.3843)
        assert close(wild[1], 8.8) and close(wild[2], -1.76) and close(far[-1], 3.9950)
        assert close(np.polyval(line, 0), -0.136) and close(np.polyval(line, 13), 1.158)
        assert close(w_log, 0.7886, 0.001) and close(b_log, 1.3364, 0.002)
        assert int((verdict == passed).sum()) == 8 and close(p[0], 0.792, 0.001) and close(p[1], 0.44, 0.002)
        assert close(fees_wrong, 1.57, 0.01) and close(-np.log(0.5), 0.693)
        assert close(np.exp(w_log), 2.20, 0.01) and close(-np.log(p[1]), 0.821, 0.005)
        assert close(hidden_j, -149, 1)
        assert len(history) == 4 and group_text(labels, 3) == "ABC | DEFG | HIJ"
        assert close(score, 340.67) and ranked[0][0] == 340.67 and len(ranked[0][1]) == 25 and ranked[-1][0] == 778.5
        assert len(ranked) == 12 and worst_start == "DGJ"
        assert close(elbow[1], 1666.9, 0.01) and close(elbow[2], 636.8, 0.01) and close(elbow[3], 340.67)
        assert close(elbow[4], 195.17) and close(elbow[5], 101.0) and close(elbow[6], 57.67)
        assert close(mark.mean(), 56.1) and close(mark.var(), 133.69) and close(mark.std(), 11.56)
        assert close(steady_marks.mean(), 56.1) and close(steady_marks.var(), 0.89) and close(w, 3) and close(b, 61)
        assert close(correlation[0, 2], -0.965, 0.002) and close(correlation[1, 3], 0.864, 0.002)
        assert close(shadow_a.var(), 1.965, 0.002) and close(shadow_b.var(), 0.035, 0.002)
        assert close(shares[0], 0.633, 0.002) and close(shares[1], 0.332, 0.002) and close(shares[:2].sum(), 0.965, 0.002)
        print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
