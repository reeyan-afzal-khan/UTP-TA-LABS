"""
AI Lab 2 --- Informed search: Greedy Best-First Search and A*.

Uninformed search (Lab 1) knows only where it has BEEN. Informed search adds
h(n), an estimate of how far a state still is from the goal, and uses it to
decide what to expand next:

    UCS    priority = g(n)           cost so far           optimal, explores widely
    GBFS   priority = h(n)           guess remaining       fast, NOT optimal
    A*     priority = g(n) + h(n)    both                  optimal if h is admissible

"Admissible" means h never OVERESTIMATES the true remaining cost. That
condition is what makes A* optimal, and Problem B below is built so you can
check it rather than assume it.

Run:  py search_informed.py
"""

import heapq

# ----------------------------------------------------------------------
# Part A --- Greedy Best-First Search
# ----------------------------------------------------------------------

GRAPH = {
    "A": ["B", "C"],
    "B": ["D", "E"],
    "C": ["F"],
    "D": [],
    "E": ["G"],
    "F": ["G"],
    "G": [],
}

HEURISTIC = {"A": 6, "B": 4, "C": 5, "D": 2, "E": 3, "F": 2, "G": 0}


def greedy_bfs(graph, heuristic, start, goal, trace=False):
    """Expands whichever frontier state LOOKS closest to the goal.

    GBFS ignores the cost already paid, so it can commit to a cheap-looking
    branch and never reconsider. It is fast because it explores few states,
    and it is not optimal for exactly the same reason.
    """
    counter = 0
    frontier = [(heuristic[start], counter, [start])]
    visited = set()

    while frontier:
        h, _, path = heapq.heappop(frontier)
        node = path[-1]

        if trace:
            print(f"      pop {node}  h={h}  path={'->'.join(path)}")

        if node == goal:
            return path
        if node in visited:
            continue
        visited.add(node)

        for neighbour in graph[node]:
            if neighbour not in visited:
                counter += 1
                heapq.heappush(frontier, (heuristic[neighbour], counter, path + [neighbour]))
    return None


GRID_MAZE = [
    [0, 0, 0, 1, 0],
    [1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0],
]


def manhattan(a, b):
    """|dx| + |dy|. On a 4-connected grid this can never overestimate the
    number of moves left, so it is admissible --- and that is why A* on a
    grid is safe to trust."""
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


def greedy_maze(maze, start, goal):
    rows, cols = len(maze), len(maze[0])
    counter = 0
    frontier = [(manhattan(start, goal), counter, [start])]
    visited = set()

    while frontier:
        _, _, path = heapq.heappop(frontier)
        x, y = path[-1]

        if (x, y) == goal:
            return path
        if (x, y) in visited:
            continue
        visited.add((x, y))

        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < rows and 0 <= ny < cols and maze[nx][ny] == 0:
                if (nx, ny) not in visited:
                    counter += 1
                    heapq.heappush(
                        frontier, (manhattan((nx, ny), goal), counter, path + [(nx, ny)])
                    )
    return None


CITY_GRAPH = {
    "S": ["A", "B"],
    "A": ["C"],
    "B": ["D", "E"],
    "C": ["G"],
    "D": [],
    "E": ["G"],
    "G": [],
}

CITY_HEURISTIC = {"S": 7, "A": 6, "B": 2, "C": 1, "D": 4, "E": 2, "G": 0}

WORDS = {
    "hit": ["hot"],
    "hot": ["dot", "lot"],
    "dot": ["dog"],
    "lot": ["log"],
    "dog": ["cog"],
    "log": ["cog"],
    "cog": [],
}


def letter_mismatch(word, goal):
    """h(w) = how many letter positions still differ from the goal word."""
    return sum(1 for a, b in zip(word, goal) if a != b)


def greedy_word_ladder(words, start, goal):
    counter = 0
    frontier = [(letter_mismatch(start, goal), counter, [start])]
    visited = set()

    while frontier:
        _, _, path = heapq.heappop(frontier)
        current = path[-1]

        if current == goal:
            return path
        if current in visited:
            continue
        visited.add(current)

        for neighbour in words.get(current, []):
            if neighbour not in visited:
                counter += 1
                heapq.heappush(
                    frontier,
                    (letter_mismatch(neighbour, goal), counter, path + [neighbour]),
                )
    return None


# ----------------------------------------------------------------------
# Part B --- A*
# ----------------------------------------------------------------------

WEIGHTED_GRAPH = {
    "A": [("B", 1), ("C", 4)],
    "B": [("D", 3), ("E", 1)],
    "C": [("F", 5)],
    "D": [],
    "E": [("G", 2)],
    "F": [("G", 1)],
    "G": [],
}

ASTAR_HEURISTIC = {"A": 7, "B": 6, "C": 4, "D": 3, "E": 2, "F": 2, "G": 0}


def astar_graph(graph, heuristic, start, goal, trace=False):
    """Priority = g + h: cost already paid plus estimated cost remaining.

    Returns (path, g_cost). Because g is included, A* cannot be fooled by a
    branch that merely looks close; and because h is included, it does not
    explore as widely as UCS.
    """
    counter = 0
    frontier = [(heuristic[start], counter, 0, [start])]
    visited = set()

    while frontier:
        f, _, g, path = heapq.heappop(frontier)
        node = path[-1]

        if trace:
            print(f"      pop {node}  g={g} h={heuristic[node]} f={f}  {'->'.join(path)}")

        if node == goal:
            return path, g
        if node in visited:
            continue
        visited.add(node)

        for neighbour, weight in graph[node]:
            if neighbour not in visited:
                counter += 1
                new_g = g + weight
                heapq.heappush(
                    frontier,
                    (new_g + heuristic[neighbour], counter, new_g, path + [neighbour]),
                )
    return None


def true_cost_to_goal(graph, goal):
    """Exact remaining cost h*(n) for every node, by working BACKWARDS from
    the goal. Used below to test whether the supplied heuristic is admissible.
    """
    reverse = {n: [] for n in graph}
    for node, edges in graph.items():
        for neighbour, weight in edges:
            reverse.setdefault(neighbour, []).append((node, weight))

    best = {goal: 0}
    frontier = [(0, goal)]
    while frontier:
        cost, node = heapq.heappop(frontier)
        if cost > best.get(node, float("inf")):
            continue
        for predecessor, weight in reverse.get(node, []):
            new = cost + weight
            if new < best.get(predecessor, float("inf")):
                best[predecessor] = new
                heapq.heappush(frontier, (new, predecessor))
    return best


ASTAR_GRID = [
    [1, 3, 1, 2, 9],
    [7, 3, 4, 9, 2],
    [1, 7, 5, 5, 3],
    [2, 3, 2, 2, 1],
    [3, 1, 4, 2, 1],
]


def astar_grid(grid, start, goal):
    """A* where entering a cell costs the number written in it.

    Manhattan distance assumes each step costs at least 1, which holds here
    because the cheapest cell is 1. If any cell cost were below 1 the
    heuristic could overestimate and the result would no longer be optimal.
    """
    rows, cols = len(grid), len(grid[0])
    counter = 0
    frontier = [(manhattan(start, goal), counter, 0, [start])]
    visited = set()

    while frontier:
        _, _, g, path = heapq.heappop(frontier)
        x, y = path[-1]

        if (x, y) == goal:
            return path, g
        if (x, y) in visited:
            continue
        visited.add((x, y))

        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < rows and 0 <= ny < cols and (nx, ny) not in visited:
                counter += 1
                new_g = g + grid[nx][ny]
                heapq.heappush(
                    frontier,
                    (new_g + manhattan((nx, ny), goal), counter, new_g, path + [(nx, ny)]),
                )
    return None


# ----------------------------------------------------------------------

def main():
    print("=" * 70)
    print("Part A --- Greedy Best-First Search (priority = h only)")
    print("=" * 70)
    print("  1. basic graph A -> G :", greedy_bfs(GRAPH, HEURISTIC, "A", "G"))
    print("     trace:")
    greedy_bfs(GRAPH, HEURISTIC, "A", "G", trace=True)
    print("  2. grid maze  (0,0) -> (0,4):")
    print("    ", greedy_maze(GRID_MAZE, (0, 0), (0, 4)))
    print("  3. city graph S -> G  :", greedy_bfs(CITY_GRAPH, CITY_HEURISTIC, "S", "G"))
    print("  4. word ladder        :", greedy_word_ladder(WORDS, "hit", "cog"))

    print()
    print("=" * 70)
    print("Part B --- A* (priority = g + h)")
    print("=" * 70)
    path, cost = astar_graph(WEIGHTED_GRAPH, ASTAR_HEURISTIC, "A", "G")
    print(f"  weighted graph : {path}  cost {cost}")
    print("     trace:")
    astar_graph(WEIGHTED_GRAPH, ASTAR_HEURISTIC, "A", "G", trace=True)

    gpath, gcost = astar_grid(ASTAR_GRID, (0, 0), (4, 4))
    print(f"\n  weighted 5x5 grid (0,0) -> (4,4): cost {gcost}")
    print(f"     {gpath}")

    print()
    print("=" * 70)
    print("Is the supplied heuristic admissible?")
    print("=" * 70)
    exact = true_cost_to_goal(WEIGHTED_GRAPH, "G")
    print("  node   h(n)   true h*(n)   admissible (h <= h*)?")
    violations = []
    for node in sorted(ASTAR_HEURISTIC):
        h = ASTAR_HEURISTIC[node]
        star = exact.get(node)
        if star is None:
            print(f"    {node}    {h:>3}      (goal unreachable)")
            continue
        ok = h <= star
        if not ok:
            violations.append((node, h, star))
        print(f"    {node}    {h:>3}       {star:>3}         {'yes' if ok else 'NO'}")

    if violations:
        print()
        print("  This heuristic is NOT admissible. For example h(A) = "
              f"{ASTAR_HEURISTIC['A']} while the")
        print(f"  true cheapest cost from A to G is {exact['A']}.")
        print("  A* only guarantees an optimal path when h never overestimates,")
        print("  so on this graph the guarantee does not hold --- the answer")
        print("  happens to be optimal, which is luck, not proof.")
        print("  Check admissibility before claiming A* found the best route.")


if __name__ == "__main__":
    main()
