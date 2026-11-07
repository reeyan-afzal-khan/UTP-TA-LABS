"""The robot-and-battery maze of Chapters 2-4, solved with the code the airline labs use.

The maze is only another graph, so utils.core searches it unchanged. Every number
quoted for the maze in the book is printed here and checked by an assert, so the
text and the code cannot drift apart. To experiment with your own maze, edit MAZE
and set CHECK_BOOK_NUMBERS to False.

Run from the course folder:      python all_experiments/demo_robot_maze.py
No dataset is needed.
"""
from __future__ import annotations

import random
from collections import deque

from utils import astar, bfs, dfs, gbfs, ucs

# R is the robot, C its charger, P a puddle, # a wall and . dry floor.
MAZE = [
    ".........#",
    "..###.##.#",
    "..###.#..C",
    "#.P.P....#",
    "..###.#...",
    ".R.#.#...#",
    "#........#",
]
BATTERY = 15
PUDDLE_COST = 5
CHECK_BOOK_NUMBERS = True


def locate(symbol):
    return [(r, c) for r, row in enumerate(MAZE) for c, ch in enumerate(row) if ch == symbol]


ROBOT, CHARGER = locate("R")[0], locate("C")[0]
PUDDLES = set(locate("P"))
FLOOR = {(r, c) for r, row in enumerate(MAZE) for c, ch in enumerate(row) if ch != "#"}


def build_graph(rain=False, order=("up", "right", "down", "left")):
    """Return {cell: [(neighbour, battery cost), ...]}, the format utils.core expects."""
    steps = {"up": (-1, 0), "right": (0, 1), "down": (1, 0), "left": (0, -1)}
    graph = {}
    for r, c in FLOOR:
        graph[r, c] = []
        for name in order:
            cell = (r + steps[name][0], c + steps[name][1])
            if cell in FLOOR:
                wet = rain and cell in PUDDLES
                graph[r, c].append((cell, float(PUDDLE_COST if wet else 1)))
    return graph


def manhattan(cell):
    """Rows apart plus columns apart: the guess that ignores walls and puddles."""
    return abs(cell[0] - CHARGER[0]) + abs(cell[1] - CHARGER[1])


def bidirectional_bfs(graph, start, goal):
    """Two BFS ripples taking turns, one ring each, until they touch."""
    parents = ({start: None}, {goal: None})
    frontiers = (deque([start]), deque([goal]))
    expanded = [0, 0]
    side = 0
    while frontiers[0] and frontiers[1]:
        for _ in range(len(frontiers[side])):                # grow this ripple by one ring
            state = frontiers[side].popleft()
            expanded[side] += 1
            for neighbour, _cost in graph[state]:
                if neighbour not in parents[side]:
                    parents[side][neighbour] = state
                    frontiers[side].append(neighbour)
                    if neighbour in parents[1 - side]:       # the ripples have touched
                        return join(parents, neighbour), expanded
        side = 1 - side
    return [], expanded


def join(parents, meeting):
    """Stitch the robot's half and the charger's half into one route."""
    half = []
    state = meeting
    while state is not None:
        half.append(state)
        state = parents[0][state]
    path = half[::-1]
    state = parents[1][meeting]
    while state is not None:
        path.append(state)
        state = parents[1][state]
    return path


def route_cost(graph, path):
    edges = {state: dict(neighbours) for state, neighbours in graph.items()}
    return sum(edges[a][b] for a, b in zip(path, path[1:]))


def plans_without_memory(graph, start, goal):
    """BFS with the memory removed: count the plans looked at before the goal comes up."""
    frontier, plans = deque([start]), 0
    while frontier:
        state = frontier.popleft()
        plans += 1
        if state == goal:
            return plans
        frontier.extend(neighbour for neighbour, _cost in graph[state])
    return plans


def mean_random_walk(graph, start, goal, walks=10_000, seed=2026):
    """How long does a robot that never plans take to stumble onto the charger?"""
    rng = random.Random(seed)
    total = 0
    for _ in range(walks):
        state = start
        while state != goal:
            state = rng.choice(graph[state])[0]
            total += 1
    return total / walks


def hill_climb(graph, start, guess):
    """Always step to the neighbour with the smallest guess; stop when none is smaller."""
    path = [start]
    while True:
        best = min((n for n, _cost in graph[path[-1]]), key=guess)
        if guess(best) >= guess(path[-1]):
            return path
        path.append(best)


def report(name, result):
    verdict = "reaches the charger" if result.path_cost_km <= BATTERY else "battery runs out"
    print(f"  {name:<14} steps {result.hops:>3}   battery {result.path_cost_km:>4.0f}   "
          f"expanded {result.expanded:>3}   peak frontier {result.max_frontier:>2}   {verdict}")


def main():
    dry, wet = build_graph(rain=False), build_graph(rain=True)
    print(f"Floor cells (states): {len(FLOOR)}   battery: {BATTERY}   puddle: {PUDDLE_COST}")
    print(f"Robot {ROBOT}, charger {CHARGER}, Manhattan guess from the robot: {manhattan(ROBOT)}")

    walk = mean_random_walk(dry, ROBOT, CHARGER)
    plans = plans_without_memory(dry, ROBOT, CHARGER)
    print(f"\nNo planning: a random walk needs {walk:.0f} steps on average.")
    print(f"Planning without memory: {plans:,} plans looked at. With memory: see BFS below.")

    print("\nDry maze")
    results = {"BFS": bfs(dry, ROBOT, CHARGER), "DFS": dfs(dry, ROBOT, CHARGER)}
    for name, result in results.items():
        report(name, result)
    other = dfs(build_graph(order=("left", "down", "right", "up")), ROBOT, CHARGER)
    report("DFS, reversed", other)
    path, (robot_side, charger_side) = bidirectional_bfs(dry, ROBOT, CHARGER)
    print(f"  Bidirectional  steps {len(path) - 1:>3}   expanded {robot_side} + {charger_side} "
          f"= {robot_side + charger_side}")

    print("\nRainy maze")
    guess = manhattan
    rainy = {
        "BFS": bfs(wet, ROBOT, CHARGER),
        "DFS": dfs(wet, ROBOT, CHARGER),
        "UCS": ucs(wet, ROBOT, CHARGER),
        "Greedy": gbfs(wet, ROBOT, CHARGER, guess),
        "A*": astar(wet, ROBOT, CHARGER, guess),
        "A* with 3h": astar(wet, ROBOT, CHARGER, lambda cell: 3 * guess(cell)),
    }
    for name, result in rainy.items():
        report(name, result)
    print(f"  Bidirectional  steps {len(path) - 1:>3}   battery {route_cost(wet, path):>4.0f}   "
          f"expanded {robot_side + charger_side}")

    stuck = hill_climb(dry, ROBOT, guess)
    print(f"\nHill climbing on the maze: {' -> '.join(map(str, stuck))}")
    print(f"It stops with guess {guess(stuck[-1])}, because no neighbour looks closer.")

    if CHECK_BOOK_NUMBERS:
        assert len(FLOOR) == 48 and manhattan(ROBOT) == 11
        assert (results["BFS"].hops, results["BFS"].expanded) == (11, 45)
        assert (results["DFS"].hops, results["DFS"].expanded) == (15, 15)
        assert (other.hops, other.expanded) == (33, 36)
        assert len(path) - 1 == 11 and robot_side + charger_side == 31
        costs = {name: result.path_cost_km for name, result in rainy.items()}
        assert costs == {"BFS": 19, "DFS": 15, "UCS": 13, "Greedy": 19, "A*": 13, "A* with 3h": 19}
        expansions = {name: result.expanded for name, result in rainy.items()}
        assert expansions == {"BFS": 45, "DFS": 15, "UCS": 47, "Greedy": 13, "A*": 28, "A* with 3h": 16}
        assert stuck[-1] == (2, 1) and guess(stuck[-1]) == 8
        print("\nEvery number above matches the book.")


if __name__ == "__main__":
    main()
