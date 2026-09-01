"""
AI Lab 3 --- One search toolkit behind all five strategies.

Labs 1 and 2 wrote the same loop nine times. This module writes it ONCE and
lets the caller supply the two things that actually differ:

    * how the next state leaves the frontier   (the priority rule)
    * what the neighbours of a state are       (the problem)

Every algorithm below is then a two-line wrapper around `best_first`:

    algorithm   priority(g, h)      needs weights?   needs h?   optimal?
    ---------   ----------------    --------------   --------   -----------------
    BFS         path length              no            no       yes (unweighted)
    DFS         negative depth           no            no       no
    UCS         g                        yes           no       yes (w >= 0)
    GBFS        h                        no            yes      no
    A*          g + h                    yes           yes      yes if h admissible

Import it:  from search_toolkit import ucs, astar_graph, ...
Self-test:  py search_toolkit.py
"""

import heapq
from collections import deque

__all__ = [
    "SearchResult",
    "best_first",
    "bfs_graph",
    "bfs_grid",
    "dfs_maze",
    "dfs_graph",
    "ucs",
    "bfs_tree",
    "dfs_preorder",
    "greedy_bfs",
    "astar_graph",
    "astar_grid",
    "greedy_word_ladder",
    "manhattan",
    "grid_neighbours",
    "TreeNode",
]


class SearchResult:
    """What every search returns: the path, its cost, and how much work it did.

    `expanded` is the number of states actually taken off the frontier. It is
    the honest measure of search effort --- comparing two algorithms on path
    quality alone hides the fact that one may have looked at ten times as
    many states to get there.
    """

    def __init__(self, path, cost, expanded):
        self.path = path
        self.cost = cost
        self.expanded = expanded

    def __bool__(self):
        return self.path is not None

    def __repr__(self):
        return f"SearchResult(path={self.path}, cost={self.cost}, expanded={self.expanded})"


def best_first(start, is_goal, neighbours, priority, trace=False):
    """The one search loop.

    start       : the initial state
    is_goal     : state -> bool
    neighbours  : state -> iterable of (next_state, step_cost)
    priority    : (g, state, depth) -> sort key; this is the whole algorithm
    trace       : print each pop

    The tie-breaking counter matters. Heap entries are compared element by
    element, so two equal priorities would send Python on to compare the
    states themselves --- which raises TypeError the moment states are not
    mutually comparable. A unique increasing integer settles ties by
    insertion order and never compares the payload at all.
    """
    counter = 0
    frontier = [(priority(0, start, 0), counter, 0, 0, [start])]
    visited = set()
    expanded = 0

    while frontier:
        prio, _, g, depth, path = heapq.heappop(frontier)
        state = path[-1]

        if state in visited:
            continue
        visited.add(state)
        expanded += 1

        if trace:
            print(f"      pop {state!s:<8} priority={prio:<6} g={g:<4} "
                  f"visited={len(visited)}")

        # Goal test on POP, never on push. For any cost-ordered search,
        # reaching the goal is not the same as reaching it cheapest; only
        # removal from the frontier proves nothing better remains.
        if is_goal(state):
            return SearchResult(path, g, expanded)

        for nxt, step in neighbours(state):
            if nxt not in visited:
                counter += 1
                new_g = g + step
                heapq.heappush(
                    frontier,
                    (priority(new_g, nxt, depth + 1), counter, new_g, depth + 1,
                     path + [nxt]),
                )

    return SearchResult(None, None, expanded)


# ----------------------------------------------------------------------
# Adapters: turn each representation into a neighbours() function
# ----------------------------------------------------------------------

def unweighted_neighbours(graph):
    """{node: [node, ...]} -> neighbours function with unit step cost."""
    return lambda s: [(n, 1) for n in graph.get(s, [])]


def weighted_neighbours(graph):
    """{node: [(node, weight), ...]} -> neighbours function."""
    return lambda s: list(graph.get(s, []))


def grid_neighbours(grid, blocked=None, cost_from_cell=True):
    """4-connected moves on a rectangular grid.

    blocked         : a value meaning "wall" (e.g. '#' or 1), or None
    cost_from_cell  : True  -> entering a cell costs the number in it
                      False -> every move costs 1
    """
    rows, cols = len(grid), len(grid[0])

    def neighbours(state):
        x, y = state
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < rows and 0 <= ny < cols:
                if blocked is not None and grid[nx][ny] == blocked:
                    continue
                step = grid[nx][ny] if cost_from_cell else 1
                yield (nx, ny), step

    return neighbours


def manhattan(a, b):
    """|dx| + |dy| --- admissible on a 4-connected grid whose cheapest step
    costs at least 1."""
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


# ----------------------------------------------------------------------
# Part A --- uninformed strategies
# ----------------------------------------------------------------------

def bfs_graph(graph, start, goal, trace=False):
    """Fewest edges. Priority = depth, so shallower paths always win."""
    return best_first(
        start,
        lambda s: s == goal,
        unweighted_neighbours(graph),
        lambda g, s, depth: depth,
        trace,
    )


def bfs_grid(grid, start, goal, blocked="#", trace=False):
    """Fewest moves through a grid, ignoring cell costs."""
    return best_first(
        start,
        lambda s: s == goal,
        grid_neighbours(grid, blocked=blocked, cost_from_cell=False),
        lambda g, s, depth: depth,
        trace,
    )


def dfs_graph(graph, start, goal, trace=False):
    """Deepest first. Priority = -depth inverts BFS, and that one sign is
    the entire difference between the two algorithms."""
    return best_first(
        start,
        lambda s: s == goal,
        unweighted_neighbours(graph),
        lambda g, s, depth: -depth,
        trace,
    )


def dfs_maze(maze, start, goal, blocked="#", trace=False):
    return best_first(
        start,
        lambda s: s == goal,
        grid_neighbours(maze, blocked=blocked, cost_from_cell=False),
        lambda g, s, depth: -depth,
        trace,
    )


def ucs(graph, start, goal, trace=False):
    """Cheapest total weight. Priority = g."""
    return best_first(
        start,
        lambda s: s == goal,
        weighted_neighbours(graph),
        lambda g, s, depth: g,
        trace,
    )


class TreeNode:
    def __init__(self, value):
        self.val = value
        self.left = None
        self.right = None


def bfs_tree(root):
    """Level order. A tree has no cycles, so no visited set is needed ---
    which is why this one is a plain queue rather than a call to best_first."""
    if not root:
        return []
    out, queue = [], deque([root])
    while queue:
        node = queue.popleft()
        out.append(node.val)
        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)
    return out


def dfs_preorder(node):
    """Node, left subtree, right subtree."""
    if not node:
        return []
    return [node.val] + dfs_preorder(node.left) + dfs_preorder(node.right)


# ----------------------------------------------------------------------
# Part B --- informed strategies
# ----------------------------------------------------------------------

def greedy_bfs(graph, heuristic, start, goal, weighted=False, trace=False):
    """Priority = h only. Ignores the cost already paid, so it is fast and
    not optimal."""
    nbrs = weighted_neighbours(graph) if weighted else unweighted_neighbours(graph)
    return best_first(
        start,
        lambda s: s == goal,
        nbrs,
        lambda g, s, depth: heuristic[s],
        trace,
    )


def astar_graph(graph, heuristic, start, goal, trace=False):
    """Priority = g + h."""
    return best_first(
        start,
        lambda s: s == goal,
        weighted_neighbours(graph),
        lambda g, s, depth: g + heuristic[s],
        trace,
    )


def astar_grid(grid, start, goal, blocked=None, trace=False):
    """A* on a grid where entering a cell costs the number written in it."""
    return best_first(
        start,
        lambda s: s == goal,
        grid_neighbours(grid, blocked=blocked, cost_from_cell=True),
        lambda g, s, depth: g + manhattan(s, goal),
        trace,
    )


def greedy_word_ladder(words, start, goal, trace=False):
    """Priority = number of letters still differing from the goal word."""
    return best_first(
        start,
        lambda s: s == goal,
        unweighted_neighbours(words),
        lambda g, s, depth: sum(1 for a, b in zip(s, goal) if a != b),
        trace,
    )


# ----------------------------------------------------------------------

def _self_test():
    """Confirms the toolkit reproduces the Lab 1 and Lab 2 answers."""
    graph = {"A": ["B", "C"], "B": ["D", "E"], "C": ["F"],
             "D": ["G"], "E": ["G"], "F": ["G"], "G": []}
    weighted = {"A": [("B", 1), ("C", 4)], "B": [("D", 3), ("E", 2)],
                "C": [("F", 5)], "D": [("G", 4)], "E": [("G", 1)],
                "F": [("G", 2)], "G": []}
    astar_g = {"A": [("B", 1), ("C", 4)], "B": [("D", 3), ("E", 1)],
               "C": [("F", 5)], "D": [], "E": [("G", 2)],
               "F": [("G", 1)], "G": []}
    h = {"A": 7, "B": 6, "C": 4, "D": 3, "E": 2, "F": 2, "G": 0}

    checks = [
        ("bfs_graph  A->G", bfs_graph(graph, "A", "G").path, ["A", "B", "D", "G"]),
        ("ucs        A->G", ucs(weighted, "A", "G").path, ["A", "B", "E", "G"]),
        ("ucs        cost", ucs(weighted, "A", "G").cost, 4),
        ("astar      A->G", astar_graph(astar_g, h, "A", "G").path, ["A", "B", "E", "G"]),
        ("astar      cost", astar_graph(astar_g, h, "A", "G").cost, 4),
    ]

    root = TreeNode(1)
    root.left, root.right = TreeNode(2), TreeNode(3)
    root.left.left, root.left.right = TreeNode(4), TreeNode(5)
    root.right.left, root.right.right = TreeNode(6), TreeNode(7)
    checks.append(("bfs_tree       ", bfs_tree(root), [1, 2, 3, 4, 5, 6, 7]))
    checks.append(("dfs_preorder   ", dfs_preorder(root), [1, 2, 4, 5, 3, 6, 7]))

    ok = True
    for name, got, want in checks:
        status = "ok " if got == want else "FAIL"
        if got != want:
            ok = False
        print(f"  [{status}] {name}: {got}")
    print("\n  self-test:", "all checks passed" if ok else "FAILURES ABOVE")
    return ok


if __name__ == "__main__":
    print("search_toolkit self-test")
    print("=" * 60)
    _self_test()
