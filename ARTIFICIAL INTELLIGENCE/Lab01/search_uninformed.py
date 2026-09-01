"""
AI Lab 1 --- Uninformed search: BFS, DFS, and Uniform-Cost Search.

All three algorithms are the SAME loop. Only one line differs --- how the
next state is taken out of the frontier --- and that single choice decides
everything else about the algorithm:

    BFS  frontier = queue (FIFO)      -> fewest EDGES      complete, optimal on unweighted
    DFS  frontier = stack (LIFO)      -> deepest first     complete on finite graphs, NOT optimal
    UCS  frontier = priority queue    -> lowest COST       complete, optimal on non-negative weights

Read the three problems in each part as the same question asked about four
different representations: a graph, a grid, a word list, and a tree. Once
the state and the neighbour function are defined, the search never changes.

Run:  py search_uninformed.py
"""

import heapq
from collections import deque

# ----------------------------------------------------------------------
# Part A --- BFS
# ----------------------------------------------------------------------

GRAPH = {
    "A": ["B", "C"],
    "B": ["D", "E"],
    "C": ["F"],
    "D": ["G"],
    "E": ["G"],
    "F": ["G"],
    "G": [],
}


def bfs(graph, start, goal):
    """Shortest path by EDGE COUNT. Returns a list of nodes, or None."""
    queue = deque([[start]])
    visited = set()

    while queue:
        path = queue.popleft()          # FIFO: the oldest path expands first
        node = path[-1]

        if node == goal:
            return path

        # Marking on POP (rather than on push) is simpler to reason about,
        # at the cost of letting duplicates sit in the queue.
        if node not in visited:
            visited.add(node)
            for neighbour in graph[node]:
                queue.append(path + [neighbour])
    return None


MAZE = [
    ["S", ".", ".", "#", "G"],
    ["#", "#", ".", "#", "."],
    [".", ".", ".", ".", "."],
    [".", "#", "#", "#", "."],
    [".", ".", ".", ".", "."],
]


def find_cell(maze, marker):
    for i, row in enumerate(maze):
        for j, cell in enumerate(row):
            if cell == marker:
                return (i, j)
    return None


def maze_neighbours(maze, x, y):
    """Four-connected moves that stay in bounds and off walls."""
    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
        nx, ny = x + dx, y + dy
        if 0 <= nx < len(maze) and 0 <= ny < len(maze[0]) and maze[nx][ny] != "#":
            yield (nx, ny)


def bfs_maze(maze):
    start, goal = find_cell(maze, "S"), find_cell(maze, "G")
    queue = deque([[start]])
    visited = set()

    while queue:
        path = queue.popleft()
        cell = path[-1]

        if cell == goal:
            return path

        if cell not in visited:
            visited.add(cell)
            for neighbour in maze_neighbours(maze, *cell):
                queue.append(path + [neighbour])
    return None


WORD_LIST = ["hit", "hot", "dot", "dog", "lot", "log", "cog"]


def differs_by_one(a, b):
    return sum(x != y for x, y in zip(a, b)) == 1


def word_bfs(start, end, word_list):
    """Shortest word ladder. Each word is a state; neighbours differ by one letter."""
    unused = set(word_list)
    queue = deque([[start]])

    while queue:
        path = queue.popleft()
        word = path[-1]

        if word == end:
            return path

        # Claim each word the FIRST time it is reached. Because BFS explores
        # in order of increasing length, that first arrival is already on a
        # shortest ladder, so no later branch needs the word.
        for candidate in list(unused):
            if differs_by_one(word, candidate):
                unused.remove(candidate)
                queue.append(path + [candidate])
    return None


class Node:
    """Binary tree node used by both the BFS and DFS tree problems."""

    def __init__(self, value):
        self.val = value
        self.left = None
        self.right = None


def build_tree():
    r"""
            1
          /   \
         2     3
        / \   / \
       4   5 6   7
    """
    root = Node(1)
    root.left, root.right = Node(2), Node(3)
    root.left.left, root.left.right = Node(4), Node(5)
    root.right.left, root.right.right = Node(6), Node(7)
    return root


def level_order_bfs(root):
    """Level by level, left to right --- BFS on a tree needs no visited set,
    because a tree has no cycles and every node has exactly one parent."""
    if not root:
        return []
    result, queue = [], deque([root])
    while queue:
        node = queue.popleft()
        result.append(node.val)
        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)
    return result


# ----------------------------------------------------------------------
# Part B --- DFS
# ----------------------------------------------------------------------


def dfs(graph, start, goal, path=None, visited=None):
    """Follows one branch to its end before backtracking.

    Note what DFS does NOT promise: the path it returns is the first one it
    stumbles into, not the shortest. On this graph it happens to match BFS;
    on the maze below it does not, and that contrast is the lesson.
    """
    if path is None:
        path = [start]
    if visited is None:
        visited = set()
    visited.add(start)

    if start == goal:
        return path

    for neighbour in graph[start]:
        if neighbour not in visited:
            found = dfs(graph, neighbour, goal, path + [neighbour], visited)
            if found:
                return found
    return None


def dfs_maze(maze, x, y, path, visited):
    if maze[x][y] == "G":
        return path
    visited.add((x, y))

    for nx, ny in maze_neighbours(maze, x, y):
        if (nx, ny) not in visited:
            found = dfs_maze(maze, nx, ny, path + [(nx, ny)], visited)
            if found:
                return found
    return None


def dfs_words(current, target, word_list, path, visited):
    if current == target:
        return path
    visited.add(current)
    for word in word_list:
        if word not in visited and differs_by_one(current, word):
            found = dfs_words(word, target, word_list, path + [word], visited)
            if found:
                return found
    return None


def dfs_preorder(node):
    """Node, then left subtree, then right subtree."""
    if not node:
        return []
    return [node.val] + dfs_preorder(node.left) + dfs_preorder(node.right)


# ----------------------------------------------------------------------
# Part C --- Uniform-Cost Search
# ----------------------------------------------------------------------

WEIGHTED_GRAPH = {
    "A": [("B", 1), ("C", 4)],
    "B": [("D", 3), ("E", 2)],
    "C": [("F", 5)],
    "D": [("G", 4)],
    "E": [("G", 1)],
    "F": [("G", 2)],
    "G": [],
}

# Same shape, but with edges in both directions and therefore cycles.
LOOPED_GRAPH = {
    "A": [("B", 2), ("C", 5)],
    "B": [("A", 2), ("D", 1)],
    "C": [("A", 5), ("D", 2)],
    "D": [("B", 1), ("C", 2), ("G", 3)],
    "G": [],
}


def ucs(graph, start, goal):
    """Cheapest path by total WEIGHT. Returns (path, cost) or None.

    The counter in each heap entry is a tie-breaker. Without it, two entries
    with equal cost make Python compare the next element --- the path list ---
    and comparing lists of different types raises TypeError. Adding a unique
    increasing integer makes ties resolve by insertion order instead, which
    is both deterministic and safe.
    """
    counter = 0
    frontier = [(0, counter, [start])]
    visited = set()

    while frontier:
        cost, _, path = heapq.heappop(frontier)   # always the cheapest so far
        node = path[-1]

        # Goal test on POP, not on push. UCS may find the goal via an
        # expensive path early; only when the goal comes off the frontier is
        # it certain that no cheaper route remains.
        if node == goal:
            return path, cost

        if node not in visited:
            visited.add(node)
            for neighbour, weight in graph[node]:
                counter += 1
                heapq.heappush(frontier, (cost + weight, counter, path + [neighbour]))
    return None


WEIGHTED_GRID = [
    [1, 1, 1, 99, 1],
    [99, 99, 1, 99, 1],
    [1, 1, 1, 1, 1],
    [1, 99, 99, 99, 1],
    [1, 1, 1, 1, 1],
]


def ucs_grid(grid, start, goal):
    """Cheapest path where each cell costs the value written in it.

    99 is not a wall; it is simply very expensive. UCS will still cross one
    if every alternative costs more, which is exactly how a real route
    planner treats a toll road.
    """
    rows, cols = len(grid), len(grid[0])
    counter = 0
    frontier = [(0, counter, [start])]
    visited = set()

    while frontier:
        cost, _, path = heapq.heappop(frontier)
        x, y = path[-1]

        if (x, y) == goal:
            return path, cost

        if (x, y) not in visited:
            visited.add((x, y))
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nx, ny = x + dx, y + dy
                if 0 <= nx < rows and 0 <= ny < cols:
                    counter += 1
                    heapq.heappush(
                        frontier,
                        (cost + grid[nx][ny], counter, path + [(nx, ny)]),
                    )
    return None


# ----------------------------------------------------------------------

def main():
    print("=" * 66)
    print("Part A --- Breadth-First Search (frontier = FIFO queue)")
    print("=" * 66)
    print("  graph  A -> G :", bfs(GRAPH, "A", "G"))
    print("  maze   S -> G :", bfs_maze(MAZE))
    print("  ladder hit->cog:", word_bfs("hit", "cog", WORD_LIST))
    print("  tree level-order:", level_order_bfs(build_tree()))

    print()
    print("=" * 66)
    print("Part B --- Depth-First Search (frontier = LIFO stack / recursion)")
    print("=" * 66)
    maze_path = dfs_maze(MAZE, 0, 0, [(0, 0)], set())
    print("  graph  A -> G :", dfs(GRAPH, "A", "G"))
    print("  maze   S -> G :", maze_path)
    print("  ladder hit->cog:", dfs_words("hit", "cog", WORD_LIST, ["hit"], set()))
    print("  tree preorder  :", dfs_preorder(build_tree()))

    bfs_len = len(bfs_maze(MAZE))
    print(f"\n  Maze: BFS found {bfs_len} cells, DFS found {len(maze_path)}.")
    print("  Same maze, same start and goal. BFS is shortest by construction;")
    print("  DFS returned the first path it happened to reach, which is longer.")

    print()
    print("=" * 66)
    print("Part C --- Uniform-Cost Search (frontier = priority queue on cost)")
    print("=" * 66)
    path, cost = ucs(WEIGHTED_GRAPH, "A", "G")
    print(f"  weighted graph : {path}  cost {cost}")
    gpath, gcost = ucs_grid(WEIGHTED_GRID, (0, 0), (0, 4))
    print(f"  weighted grid  : cost {gcost}, {len(gpath)} cells")
    print(f"                   {gpath}")
    lpath, lcost = ucs(LOOPED_GRAPH, "A", "G")
    print(f"  graph w/ loops : {lpath}  cost {lcost}")
    print("                   The visited set is what stops A -> B -> A -> B ...")

    print()
    # BFS takes plain adjacency lists, so drop the weights to run it on the
    # same graph. That is the comparison: same edges, different question.
    unweighted = {n: [nb for nb, _ in edges] for n, edges in WEIGHTED_GRAPH.items()}
    bfs_path = bfs(unweighted, "A", "G")
    bfs_cost = sum(
        w
        for u, v in zip(bfs_path, bfs_path[1:])
        for nb, w in WEIGHTED_GRAPH[u]
        if nb == v
    )
    print(f"  Same weighted graph, two questions:")
    print(f"    BFS (fewest edges) : {bfs_path}  {len(bfs_path) - 1} edges, cost {bfs_cost}")
    print(f"    UCS (cheapest)     : {path}  {len(path) - 1} edges, cost {cost}")
    print("  Both paths use the same number of edges, but they are not the")
    print("  same path and they do not cost the same. BFS never looked at a")
    print("  weight; it cannot answer the cost question even by accident.")


if __name__ == "__main__":
    main()
