"""
AI Lab 3 driver --- runs every Lab 1 and Lab 2 example through the single
toolkit and prints the cross-algorithm comparison table (Part C).

Run:  py run_all.py
"""

from search_toolkit import (
    TreeNode,
    astar_graph,
    astar_grid,
    bfs_graph,
    bfs_grid,
    bfs_tree,
    dfs_graph,
    dfs_maze,
    dfs_preorder,
    greedy_bfs,
    greedy_word_ladder,
    ucs,
)

# ---------------------------------------------------------------- data

GRAPH = {"A": ["B", "C"], "B": ["D", "E"], "C": ["F"],
         "D": ["G"], "E": ["G"], "F": ["G"], "G": []}

WEIGHTED_GRAPH = {"A": [("B", 1), ("C", 4)], "B": [("D", 3), ("E", 2)],
                  "C": [("F", 5)], "D": [("G", 4)], "E": [("G", 1)],
                  "F": [("G", 2)], "G": []}

# Same edges as WEIGHTED_GRAPH but with weights stripped, so BFS/DFS/GBFS
# can be run on the identical topology for a fair comparison.
UNWEIGHTED_VIEW = {n: [nb for nb, _ in e] for n, e in WEIGHTED_GRAPH.items()}

GBFS_HEURISTIC = {"A": 6, "B": 4, "C": 5, "D": 2, "E": 3, "F": 2, "G": 0}

ASTAR_GRAPH = {"A": [("B", 1), ("C", 4)], "B": [("D", 3), ("E", 1)],
               "C": [("F", 5)], "D": [], "E": [("G", 2)],
               "F": [("G", 1)], "G": []}
ASTAR_H = {"A": 7, "B": 6, "C": 4, "D": 3, "E": 2, "F": 2, "G": 0}

MAZE = [["S", ".", ".", "#", "G"],
        ["#", "#", ".", "#", "."],
        [".", ".", ".", ".", "."],
        [".", "#", "#", "#", "."],
        [".", ".", ".", ".", "."]]

WEIGHTED_GRID = [[1, 1, 1, 99, 1],
                 [99, 99, 1, 99, 1],
                 [1, 1, 1, 1, 1],
                 [1, 99, 99, 99, 1],
                 [1, 1, 1, 1, 1]]

ASTAR_GRID = [[1, 3, 1, 2, 9],
              [7, 3, 4, 9, 2],
              [1, 7, 5, 5, 3],
              [2, 3, 2, 2, 1],
              [3, 1, 4, 2, 1]]

WORDS = {"hit": ["hot"], "hot": ["dot", "lot"], "dot": ["dog"],
         "lot": ["log"], "dog": ["cog"], "log": ["cog"], "cog": []}


def build_tree():
    root = TreeNode(1)
    root.left, root.right = TreeNode(2), TreeNode(3)
    root.left.left, root.left.right = TreeNode(4), TreeNode(5)
    root.right.left, root.right.right = TreeNode(6), TreeNode(7)
    return root


def path_cost(graph, path):
    """Total weight of a path, so unweighted searches can still be priced."""
    return sum(w for u, v in zip(path, path[1:])
               for nb, w in graph[u] if nb == v)


def rule(char="-", width=78):
    print(char * width)


def main():
    # ------------------------------------------------------------------
    rule("=")
    print("Part A --- uninformed functions from the toolkit")
    rule("=")
    print("  bfs_graph    A -> G :", bfs_graph(GRAPH, "A", "G").path)
    print("  dfs_graph    A -> G :", dfs_graph(GRAPH, "A", "G").path)
    r = ucs(WEIGHTED_GRAPH, "A", "G")
    print(f"  ucs          A -> G : {r.path}  cost {r.cost}")
    print("  bfs_grid     S -> G :", bfs_grid(MAZE, (0, 0), (0, 4)).path)
    print("  dfs_maze     S -> G :", dfs_maze(MAZE, (0, 0), (0, 4)).path)
    print("  bfs_tree            :", bfs_tree(build_tree()))
    print("  dfs_preorder        :", dfs_preorder(build_tree()))

    # ------------------------------------------------------------------
    print()
    rule("=")
    print("Part B --- informed functions from the toolkit")
    rule("=")
    print("  greedy_bfs   A -> G :",
          greedy_bfs(GRAPH, GBFS_HEURISTIC, "A", "G").path)
    r = astar_graph(ASTAR_GRAPH, ASTAR_H, "A", "G")
    print(f"  astar_graph  A -> G : {r.path}  cost {r.cost}")
    r = astar_grid(WEIGHTED_GRID, (0, 0), (0, 4))
    print(f"  astar_grid   weighted maze : cost {r.cost}, {len(r.path)} cells")
    r = astar_grid(ASTAR_GRID, (0, 0), (4, 4))
    print(f"  astar_grid   5x5 cost grid : cost {r.cost}, {len(r.path)} cells")
    print("  greedy_word_ladder  :", greedy_word_ladder(WORDS, "hit", "cog").path)

    # ------------------------------------------------------------------
    print()
    rule("=")
    print("Part C --- five algorithms, ONE graph, same start and goal")
    rule("=")
    print("  Graph: A->B(1) A->C(4) B->D(3) B->E(2) C->F(5)")
    print("         D->G(4) E->G(1) F->G(2)        heuristic h shown per node")
    print()

    runs = [
        ("BFS   (fewest edges)", "depth",
         bfs_graph(UNWEIGHTED_VIEW, "A", "G")),
        ("DFS   (deepest first)", "-depth",
         dfs_graph(UNWEIGHTED_VIEW, "A", "G")),
        ("UCS   (cheapest)", "g",
         ucs(WEIGHTED_GRAPH, "A", "G")),
        ("GBFS  (looks closest)", "h",
         greedy_bfs(WEIGHTED_GRAPH, GBFS_HEURISTIC, "A", "G", weighted=True)),
        ("A*    (cost + estimate)", "g+h",
         astar_graph(WEIGHTED_GRAPH, GBFS_HEURISTIC, "A", "G")),
    ]

    print(f"  {'algorithm':<24} {'priority':<9} {'path':<18} {'cost':>5} {'expanded':>9}")
    rule()
    for name, priority, res in runs:
        path_txt = "->".join(res.path) if res.path else "none"
        cost = res.cost if res.cost is not None else 0
        # Price every path with the real weights, even the ones whose search
        # never consulted them --- otherwise the costs are not comparable.
        real = path_cost(WEIGHTED_GRAPH, res.path) if res.path else 0
        print(f"  {name:<24} {priority:<9} {path_txt:<18} {real:>5} {res.expanded:>9}")

    rule()
    print("""
  Reading the table:

  * BFS and DFS return 3-edge paths costing 8. Neither ever looked at a
    weight, so neither could have found the cheap one. Fewest edges and
    cheapest are different questions.

  * GBFS also lands on the cost-8 path, and this is the important row.
    It is not "unlucky": at A it compared h(B)=4 against h(C)=5, took B,
    then compared h(D)=2 against h(E)=3 and took D --- while D->G costs 4
    and E->G costs 1. GBFS never looks at what it has already spent, so a
    node that merely LOOKS closer wins even when the road there is dear.
    That is precisely why greedy search is not optimal.

  * UCS pays 4, the true minimum, and expands the most states to prove it.
    Optimality is bought with work.

  * A* matches UCS's cost while expanding fewer states. Adding g to the
    priority is the single change that repairs GBFS: once the 3 already
    spent to reach D is counted, D stops looking attractive.

  The pairing to remember: GBFS (h alone) is fast and wrong here; UCS
  (g alone) is right and slower; A* (g+h) is right and faster than UCS.
  A*'s guarantee holds only while h is admissible --- check it, do not
  assume it.
""")

    # ------------------------------------------------------------------
    rule("=")
    print("Trace: A* on the weighted graph, one line per state expanded")
    rule("=")
    astar_graph(WEIGHTED_GRAPH, GBFS_HEURISTIC, "A", "G", trace=True)


if __name__ == "__main__":
    main()
