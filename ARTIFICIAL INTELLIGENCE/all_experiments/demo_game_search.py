"""Chapter 11 demos: searching when someone fights back, on noughts and crosses.

Minimax plays every future to the end, alpha-beta skips futures that cannot matter, an
evaluation function stops early and guesses, and Monte Carlo Tree Search lets random
games vote. Seeds are fixed, so the same Python gives the same numbers.

Run from the course folder:      python all_experiments/demo_game_search.py
No dataset is needed.
"""
from __future__ import annotations

import math
import random
from functools import lru_cache

LINES = [(0, 1, 2), (3, 4, 5), (6, 7, 8), (0, 3, 6), (1, 4, 7), (2, 5, 8), (0, 4, 8), (2, 4, 6)]
EMPTY = "." * 9
# The halfway board the chapter traces, read left to right, top to bottom. X is to move.
HALFWAY = ".X." "O.X" "XOO"


def winner(board):
    for a, b, c in LINES:
        if board[a] != "." and board[a] == board[b] == board[c]:
            return board[a]
    return None


def score(board):
    """+1 if X (Max) has won, -1 if O (Min) has won, 0 for a draw, None if the game goes on."""
    who = winner(board)
    if who:
        return 1 if who == "X" else -1
    return 0 if "." not in board else None


def play(board, square, player):
    return board[:square] + player + board[square + 1:]


def moves(board):
    return [i for i, mark in enumerate(board) if mark == "."]


def other(player):
    return "O" if player == "X" else "X"


class Counter:
    positions = 0


def count_minimax(board, player):
    """Plain minimax with a counter: the number of positions it visits, with no shortcuts."""
    Counter.positions += 1
    result = score(board)
    if result is not None:
        return result
    values = [count_minimax(play(board, m, player), other(player)) for m in moves(board)]
    return max(values) if player == "X" else min(values)


def count_alphabeta(board, player, alpha=-2, beta=2):
    """Minimax that stops looking at a move once it cannot change the answer."""
    Counter.positions += 1
    result = score(board)
    if result is not None:
        return result
    best = -2 if player == "X" else 2
    for m in moves(board):
        value = count_alphabeta(play(board, m, player), other(player), alpha, beta)
        if player == "X":
            best, alpha = max(best, value), max(alpha, value)
        else:
            best, beta = min(best, value), min(beta, value)
        if alpha >= beta:
            break
    return best


@lru_cache(maxsize=None)
def value_of(board, player):
    """The minimax value, remembered so that a whole tournament stays fast."""
    result = score(board)
    if result is not None:
        return result
    values = [value_of(play(board, m, player), other(player)) for m in moves(board)]
    return max(values) if player == "X" else min(values)


def perfect_move(board, player, rng):
    pick = max if player == "X" else min
    values = {m: value_of(play(board, m, player), other(player)) for m in moves(board)}
    best = pick(values.values())
    return rng.choice([m for m, v in values.items() if v == best])


def random_move(board, player, rng):
    return rng.choice(moves(board))


def open_lines(board):
    """The guess: lines X could still finish minus lines O could still finish."""
    x_open = sum(all(board[i] != "O" for i in line) for line in LINES)
    o_open = sum(all(board[i] != "X" for i in line) for line in LINES)
    return x_open - o_open


def limited_value(board, player, depth, tally):
    """Look `depth` moves ahead, then trust the guess instead of playing on."""
    tally[0] += 1
    result = score(board)
    if result is not None:
        return 100 * result
    if depth == 0:
        return open_lines(board)
    values = [limited_value(play(board, m, player), other(player), depth - 1, tally) for m in moves(board)]
    return max(values) if player == "X" else min(values)


def guessing_move(board, player, rng, tally, depth=2):
    pick = max if player == "X" else min
    values = {m: limited_value(play(board, m, player), other(player), depth - 1, tally) for m in moves(board)}
    best = pick(values.values())
    return rng.choice([m for m, v in values.items() if v == best])


def play_game(x_move, o_move, rng):
    board, player = EMPTY, "X"
    while score(board) is None:
        move = (x_move if player == "X" else o_move)(board, player, rng)
        board, player = play(board, move, player), other(player)
    return score(board)


def tally_games(first, second, games, rng):
    """Half the games with `first` as X, half with `first` as O. Returns its wins, draws, losses."""
    wins = draws = losses = 0
    for game in range(games):
        if game % 2 == 0:
            outcome = play_game(first, second, rng)
        else:
            outcome = -play_game(second, first, rng)
        wins += outcome > 0
        draws += outcome == 0
        losses += outcome < 0
    return wins, draws, losses


def random_playout(board, player, rng):
    while score(board) is None:
        board, player = play(board, rng.choice(moves(board)), player), other(player)
    return score(board)


def flat_monte_carlo(board, player, games, rng):
    """Play the same number of random games after every move and count wins for `player`."""
    wins = {}
    for m in moves(board):
        results = [random_playout(play(board, m, player), other(player), rng) for _ in range(games)]
        wins[m] = sum(r == (1 if player == "X" else -1) for r in results)
    return wins


class Node:
    def __init__(self, board, player):
        self.board, self.player = board, player
        self.children, self.visits, self.total = {}, 0, 0.0


def mcts(board, player, games, rng, bonus=1.0):
    """Grow a tree game by game: walk down, add a move, play it out, pass the result back up."""
    root = Node(board, player)
    for _ in range(games):
        node, path = root, [root]
        while score(node.board) is None and len(node.children) == len(moves(node.board)):
            def appeal(child):
                won = child.total / child.visits
                won = won if node.player == "X" else -won
                return won + bonus * math.sqrt(math.log(node.visits) / child.visits)
            node = max(node.children.values(), key=appeal)
            path.append(node)
        if score(node.board) is None:
            move = rng.choice([m for m in moves(node.board) if m not in node.children])
            child = Node(play(node.board, move, node.player), other(node.player))
            node.children[move] = child
            node = child
            path.append(node)
        outcome = random_playout(node.board, node.player, rng)
        for visited in path:
            visited.visits += 1
            visited.total += outcome
    return {m: child.visits for m, child in root.children.items()}


def main():
    rng = random.Random(2026)

    Counter.positions = 0
    answer = count_minimax(EMPTY, "X")
    full = Counter.positions
    print(f"Whole game by minimax: value {answer:+d}, {full:,} positions")
    assert answer == 0 and full == 549_946

    Counter.positions = 0
    assert count_alphabeta(EMPTY, "X") == 0
    pruned = Counter.positions
    print(f"Whole game by alpha-beta: value 0, {pruned:,} positions ({pruned / full:.1%} of the work)")

    print(f"\nHalfway board {HALFWAY}, X to move")
    for m in moves(HALFWAY):
        print(f"  X in square {m}: minimax value {value_of(play(HALFWAY, m, 'X'), 'O'):+d}")

    wins, draws, losses = tally_games(perfect_move, random_move, 2000, rng)
    print(f"\nMinimax against a random player: {wins} wins, {draws} draws, {losses} losses")
    assert losses == 0
    print("Minimax against itself:", play_game(perfect_move, perfect_move, rng), "(0 is a draw)")

    tally = [0]
    def guesser(board, player, rng):
        return guessing_move(board, player, rng, tally)

    games = 200
    wins, draws, losses = tally_games(perfect_move, guesser, games, rng)
    print(f"\nFull search against a two-move guesser: {wins} wins, {draws} draws, {losses} losses")
    print(f"The guesser looked at about {tally[0] / games:.0f} positions per game")
    assert losses == 0

    print(f"\nFlat Monte Carlo on the halfway board, 100 random games per move: "
          f"{flat_monte_carlo(HALFWAY, 'X', 100, rng)}")
    visits = mcts(HALFWAY, "X", 300, rng)
    print(f"Monte Carlo Tree Search, 300 games, visits per move: {dict(sorted(visits.items()))}")
    assert max(visits, key=visits.get) == 2 and value_of(play(HALFWAY, 2, "X"), "O") == 1


if __name__ == "__main__":
    main()
