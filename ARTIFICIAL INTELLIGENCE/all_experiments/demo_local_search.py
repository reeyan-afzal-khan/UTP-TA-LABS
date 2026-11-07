"""Chapter 9 and 10 demos: searches for when only the final answer counts.

Part 1 races hill climbing, random restarts, simulated annealing and a genetic
algorithm on the eight-queens puzzle. Part 2 shows why beam search keeps more than
one option. Seeds are fixed, so the same Python gives the same numbers.

Run from the course folder:      python all_experiments/demo_local_search.py
No dataset is needed.
"""
from __future__ import annotations

import math
import random
from collections import deque
from statistics import mean, median

SIZE = 8
PAIRS = SIZE * (SIZE - 1) // 2                # 28 pairs of queens
BOARDS = 1000


def attacks(board):
    """How many pairs of queens attack each other? board[c] is the row of column c's queen."""
    return sum(
        board[a] == board[b] or abs(board[a] - board[b]) == b - a
        for a in range(SIZE) for b in range(a + 1, SIZE)
    )


def random_board(rng):
    return tuple(rng.randrange(SIZE) for _ in range(SIZE))


def neighbours(board):
    """Every board reached by sliding one queen within its column: 8 x 7 = 56 boards."""
    return [board[:c] + (r,) + board[c + 1:] for c in range(SIZE) for r in range(SIZE) if r != board[c]]


def hill_climb(board, rng):
    """Move to the best neighbour until none is better. Returns (final board, boards looked at)."""
    looked_at = 0
    while True:
        options = neighbours(board)
        looked_at += len(options)
        scores = [attacks(option) for option in options]
        best = min(scores)
        if best >= attacks(board):
            return board, looked_at
        board = rng.choice([option for option, score in zip(options, scores) if score == best])


def random_restarts(rng):
    """Climb, and when stuck throw the board away and climb a fresh one."""
    tries, looked_at = 0, 0
    while True:
        tries += 1
        board, cost = hill_climb(random_board(rng), rng)
        looked_at += cost
        if attacks(board) == 0:
            return tries, looked_at


def simulated_annealing(board, rng, start_temperature=1.0, cooling=0.999, stop_temperature=0.01):
    """Take one random move each step; accept a worse move with a chance that shrinks as it cools."""
    temperature, looked_at, current = start_temperature, 0, attacks(board)
    while temperature > stop_temperature and current > 0:
        column, row = rng.randrange(SIZE), rng.randrange(SIZE - 1)
        row += row >= board[column]                  # any row except the one it is on
        candidate = board[:column] + (row,) + board[column + 1:]
        looked_at += 1
        score = attacks(candidate)
        extra = score - current
        if extra <= 0 or rng.random() < math.exp(-extra / temperature):
            board, current = candidate, score
        temperature *= cooling
    return board, looked_at


def genetic_algorithm(rng, population_size=50, mutation_rate=0.2, generations=1000):
    """Breed boards. A board holds one ticket per pair of queens that does not attack."""
    population = [random_board(rng) for _ in range(population_size)]
    looked_at = 0
    for generation in range(generations):
        tickets = [PAIRS - attacks(board) for board in population]
        looked_at += population_size
        if max(tickets) == PAIRS:
            return generation, looked_at
        children = []
        for _ in range(population_size):
            mum, dad = rng.choices(population, weights=tickets, k=2)
            cut = rng.randrange(1, SIZE)
            child = mum[:cut] + dad[cut:]
            if rng.random() < mutation_rate:
                column = rng.randrange(SIZE)
                child = child[:column] + (rng.randrange(SIZE),) + child[column + 1:]
            children.append(child)
        population = children
    return None, looked_at


def race(seed=2026):
    rng = random.Random(seed)
    boards = [random_board(rng) for _ in range(BOARDS)]

    climbs = [hill_climb(board, rng) for board in boards]
    solved = sum(attacks(board) == 0 for board, _ in climbs)
    work = sum(cost for _, cost in climbs)
    print(f"Hill climbing       solved {solved:>4} of {BOARDS}   boards looked at per solved board {work / solved:>8,.0f}")

    restarts = [random_restarts(rng) for _ in range(BOARDS)]
    print(f"Random restarts     solved {BOARDS:>4} of {BOARDS}   boards looked at per solved board "
          f"{mean(c for _, c in restarts):>8,.0f}   mean tries {mean(t for t, _ in restarts):.1f}")

    annealed = [simulated_annealing(board, rng) for board in boards]
    solved = sum(attacks(board) == 0 for board, _ in annealed)
    work = sum(cost for _, cost in annealed)
    print(f"Simulated annealing solved {solved:>4} of {BOARDS}   boards looked at per solved board {work / solved:>8,.0f}")

    runs = [genetic_algorithm(rng) for _ in range(BOARDS // 5)]
    finished = [(g, c) for g, c in runs if g is not None]
    work = sum(c for _, c in runs)
    print(f"Genetic algorithm   solved {len(finished):>4} of {len(runs)}    boards looked at per solved board "
          f"{work / len(finished):>8,.0f}   median generations {median(g for g, _ in finished):.0f}")


# ---------------------------------------------------------------- beam search
# A toy phone keyboard. Each entry lists the chance of the next word after these words.
NEXT_WORD = {
    "the flight": {"is": 0.5, "was": 0.4, "left": 0.1},
    "the flight is": {"late": 0.45, "full": 0.35, "here": 0.20},
    "the flight was": {"cancelled": 0.80, "late": 0.15, "full": 0.05},
    "the flight left": {"early": 0.6, "late": 0.4},
}


def beam_search(start, width):
    """Grow every sentence held, keep the best `width`, and repeat until none can grow."""
    beam = [(start, 1.0)]
    while any(sentence in NEXT_WORD for sentence, _ in beam):
        grown = [(f"{sentence} {word}", chance * p)
                 for sentence, chance in beam if sentence in NEXT_WORD
                 for word, p in NEXT_WORD[sentence].items()]
        beam = sorted(grown, key=lambda item: -item[1])[:width]
    return beam


def breadth_first_boards(board):
    """The search loop of Chapter 2 run on boards: the memory bill local search avoids."""
    frontier, seen = deque([board]), {board}
    expanded, peak = 0, 1
    while frontier:
        state = frontier.popleft()
        if attacks(state) == 0:
            return expanded, peak
        expanded += 1
        for neighbour in neighbours(state):
            if neighbour not in seen:
                seen.add(neighbour)
                frontier.append(neighbour)
        peak = max(peak, len(frontier))
    return expanded, peak


def main():
    expanded, peak = breadth_first_boards((3, 1, 7, 0, 6, 6, 0, 7))
    print(f"Breadth-first on one board with 5 attacks: expanded {expanded:,}, frontier peak {peak:,}\n")
    race()
    print()
    for width in (1, 2, 3):
        sentence, chance = beam_search("the flight", width)[0]
        print(f"Beam width {width}: '{sentence}' with chance {chance:.3f}")
    assert beam_search("the flight", 1)[0][0] == "the flight is late"
    assert beam_search("the flight", 2)[0][0] == "the flight was cancelled"


if __name__ == "__main__":
    main()
