"""The 8-puzzle of Chapters 2 and 3: why two ripples and a sharper guess save so much work.

Each arrangement of the tiles is a state and each slide costs 1, so the puzzle is one
more graph for utils.core. The whole puzzle is built first (181,440 reachable states),
which takes a few seconds.

Run from the course folder:      python all_experiments/demo_sliding_puzzle.py
No dataset is needed.
"""
from __future__ import annotations

from collections import deque

from demo_robot_maze import bidirectional_bfs
from utils import astar, bfs

GOAL = (1, 2, 3, 4, 5, 6, 7, 8, 0)            # 0 is the gap
SCRAMBLE = (8, 2, 0, 6, 1, 7, 4, 3, 5)        # the board the book traces: 22 slides from the goal


def slides(board):
    """Every board one slide away. A tile next to the gap moves into it."""
    gap = board.index(0)
    row, col = divmod(gap, 3)
    result = []
    for dr, dc in [(-1, 0), (0, 1), (1, 0), (0, -1)]:
        r, c = row + dr, col + dc
        if 0 <= r < 3 and 0 <= c < 3:
            swap = list(board)
            swap[gap], swap[3 * r + c] = swap[3 * r + c], swap[gap]
            result.append(tuple(swap))
    return result


def build_graph():
    graph, frontier = {GOAL: []}, deque([GOAL])
    while frontier:
        board = frontier.popleft()
        for neighbour in slides(board):
            graph[board].append((neighbour, 1.0))
            if neighbour not in graph:
                graph[neighbour] = []
                frontier.append(neighbour)
    return graph


def misplaced(board):
    """Weak guess: how many tiles are not on their home square?"""
    return sum(tile != 0 and tile != home for tile, home in zip(board, GOAL))


def tile_distance(board):
    """Sharper guess: Manhattan distance of every tile from its home square, added up."""
    total = 0
    for position, tile in enumerate(board):
        if tile:
            row, col = divmod(position, 3)
            home_row, home_col = divmod(tile - 1, 3)
            total += abs(row - home_row) + abs(col - home_col)
    return total


def ring_sizes(graph, start, last_ring):
    """How many boards sit exactly 0, 1, 2, ... slides away from the start?"""
    depth = {start: 0}
    frontier = deque([start])
    while frontier:
        board = frontier.popleft()
        for neighbour, _cost in graph[board]:
            if neighbour not in depth:
                depth[neighbour] = depth[board] + 1
                frontier.append(neighbour)
    sizes = [0] * (last_ring + 1)
    for d in depth.values():
        if d <= last_ring:
            sizes[d] += 1
    return sizes


def main():
    graph = build_graph()
    print(f"Reachable boards: {len(graph):,}")
    assert len(graph) == 181_440

    board = SCRAMBLE
    print(f"\nTraced board: {board}")
    print(f"Weak guess {misplaced(board)}, sharper guess {tile_distance(board)}")

    one = bfs(graph, board, GOAL)
    path, (near, far) = bidirectional_bfs(graph, board, GOAL)
    weak = astar(graph, board, GOAL, misplaced)
    sharp = astar(graph, board, GOAL, tile_distance)
    print(f"True solution length: {one.hops} slides")
    print(f"BFS, one ripple         expanded {one.expanded:>7,}")
    print(f"BFS, two ripples        expanded {near + far:>7,}")
    print(f"A*, misplaced tiles     expanded {weak.expanded:>7,}")
    print(f"A*, tile distance       expanded {sharp.expanded:>7,}")
    assert one.hops == weak.hops == sharp.hops == len(path) - 1 == 22
    assert sharp.expanded < weak.expanded < one.expanded

    sizes = ring_sizes(graph, board, one.hops)
    print("\nBoards in each ring:", sizes)
    growth = (sizes[one.hops] / sizes[1]) ** (1 / (one.hops - 1))
    print(f"Average growth per ring: {growth:.2f}")
    half = sum(sizes[: one.hops // 2 + 1])
    print(f"Boards in rings 0-{one.hops // 2}: {half:,}; all rings up to {one.hops}: {sum(sizes):,}")


if __name__ == "__main__":
    main()
