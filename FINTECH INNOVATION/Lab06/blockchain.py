"""
FinTech Innovation --- Lab 6: Build a blockchain from first principles.

Implements the structure described in Chapter 6: hashing, Merkle roots,
block chaining, and proof of work. Standard library only --- no packages
to install, no network access, no cryptocurrency involved.

Run:
    python blockchain.py
"""

from __future__ import annotations

import hashlib
import time
from dataclasses import dataclass, field


# --------------------------------------------------------------------------
# Part A --- Hashing
# --------------------------------------------------------------------------

def sha256(data: str) -> str:
    """Hex digest of a string.

    Four properties make this useful for a blockchain:

    deterministic  the same input always hashes identically, so any node
                   can independently verify any block
    fixed length   a megabyte of transactions and one character both
                   produce 64 hex characters
    avalanche      one changed bit flips roughly half the output bits, so
                   tampering is never subtle
    one-way        given a hash you cannot compute the input, which is why
                   mining has to proceed by trial and error
    """
    return hashlib.sha256(data.encode()).hexdigest()


# --------------------------------------------------------------------------
# Part B --- Merkle root
# --------------------------------------------------------------------------

def merkle_root(transactions: list[str]) -> str:
    """Reduce a list of transactions to a single committing hash.

    Hash each transaction, then repeatedly hash adjacent pairs until one
    value remains. Changing any transaction changes the root, so a
    fixed-size block header can commit to unlimited transaction data.
    """
    if not transactions:
        # An empty block still needs a well-defined root rather than a crash.
        return sha256("")

    level = [sha256(tx) for tx in transactions]

    while len(level) > 1:
        # An odd node is paired with itself so every level halves cleanly.
        if len(level) % 2 == 1:
            level.append(level[-1])
        level = [sha256(level[i] + level[i + 1]) for i in range(0, len(level), 2)]

    return level[0]


# --------------------------------------------------------------------------
# Part C --- Blocks and chaining
# --------------------------------------------------------------------------

@dataclass
class Block:
    index: int
    transactions: list[str]
    previous_hash: str
    nonce: int = 0
    timestamp: float = field(default_factory=time.time)

    def header(self) -> str:
        """Everything the block's hash commits to.

        previous_hash is what makes this a chain rather than a list: each
        block's identity depends on the one before it.
        """
        return (
            f"{self.index}"
            f"{self.timestamp}"
            f"{self.previous_hash}"
            f"{merkle_root(self.transactions)}"
            f"{self.nonce}"
        )

    def hash(self) -> str:
        return sha256(self.header())


# --------------------------------------------------------------------------
# Part D --- Proof of work
# --------------------------------------------------------------------------

def mine(block: Block, difficulty: int) -> Block:
    """Search for a nonce making the block hash start with `difficulty` zeros.

    There is no shortcut. Because the hash is one-way, the only method is
    to try nonces until one works. Each extra required zero multiplies the
    expected number of attempts by 16, since a hex digit has 16 values.
    """
    target = "0" * difficulty
    while not block.hash().startswith(target):
        block.nonce += 1
    return block


def build_chain(blocks_of_transactions: list[list[str]], difficulty: int) -> list[Block]:
    """Mine a genesis block plus one block per transaction list."""
    genesis = mine(Block(0, ["genesis"], "0" * 64), difficulty)
    chain = [genesis]

    for i, txs in enumerate(blocks_of_transactions, start=1):
        block = Block(i, txs, chain[-1].hash())
        chain.append(mine(block, difficulty))

    return chain


# --------------------------------------------------------------------------
# Part E --- Validation
# --------------------------------------------------------------------------

def validate(chain: list[Block], difficulty: int) -> list[str]:
    """Return a list of every problem found, in block order.

    Two independent things can be wrong, and the distinction matters:
      * proof of work invalid            -> this block's own data changed
      * previous_hash no longer matches  -> an EARLIER block's data changed

    Collecting all failures rather than returning at the first one is what
    makes the tamper cascade visible: editing one block produces a proof-of-
    work failure in that block AND a broken link in the block after it.
    """
    problems: list[str] = []

    for i in range(1, len(chain)):
        current, previous = chain[i], chain[i - 1]

        if not current.hash().startswith("0" * difficulty):
            problems.append(f"block {i}: proof of work invalid (its own data changed)")

        if current.previous_hash != previous.hash():
            problems.append(
                f"block {i}: previous_hash does not match block {i - 1} "
                f"(block {i - 1} was altered)"
            )

    return problems


def is_valid(chain: list[Block], difficulty: int) -> bool:
    return not validate(chain, difficulty)


# --------------------------------------------------------------------------
# Demonstration
# --------------------------------------------------------------------------

def demo_hashing() -> None:
    print("=" * 68)
    print("Part A --- hashing: one character changes everything")
    print("=" * 68)
    a, b = "Alice pays Bob 10", "Alice pays Bob 11"
    print(f"  {a!r}\n    -> {sha256(a)}")
    print(f"  {b!r}\n    -> {sha256(b)}")

    # Count differing hex characters to make the avalanche property concrete.
    differing = sum(x != y for x, y in zip(sha256(a), sha256(b)))
    print(f"\n  {differing} of 64 hex characters differ from a 1-character change")


def demo_merkle() -> None:
    print("\n" + "=" * 68)
    print("Part B --- Merkle root")
    print("=" * 68)
    txs = ["alice->bob 10", "bob->carol 3", "carol->dave 7"]
    print(f"  3 transactions (odd count, so the last is paired with itself)")
    print(f"  root: {merkle_root(txs)}")

    tampered = list(txs)
    tampered[1] = "bob->carol 30"
    print(f"\n  after altering one transaction:")
    print(f"  root: {merkle_root(tampered)}")
    print("  -> the block header no longer matches its own contents")


def demo_difficulty() -> None:
    print("\n" + "=" * 68)
    print("Part D --- proof of work: cost grows ~16x per extra zero")
    print("=" * 68)
    # A single mining run is extremely noisy --- the nonce found is a draw
    # from a geometric distribution, so one sample can be 3x or 30x the
    # previous row by luck alone. Averaging several trials is what makes the
    # underlying 16x scaling visible.
    TRIALS = 8
    print(f"  mean of {TRIALS} trials per difficulty\n")
    print(f"  {'difficulty':>10}  {'mean attempts':>14}  {'mean seconds':>13}  {'ratio':>7}")

    previous_mean = None
    for d in range(1, 6):
        attempts, elapsed = [], []
        for trial in range(TRIALS):
            # Vary the transaction so each trial is an independent search.
            block = Block(1, [f"a pays b {trial}"], "0" * 64)
            start = time.time()
            mine(block, d)
            elapsed.append(time.time() - start)
            attempts.append(block.nonce)

        mean_attempts = sum(attempts) / TRIALS
        mean_seconds = sum(elapsed) / TRIALS

        ratio = f"{mean_attempts / previous_mean:6.1f}x" if previous_mean else "     --"
        print(f"  {d:>10}  {mean_attempts:>14,.0f}  {mean_seconds:>13.3f}  {ratio:>7}")
        previous_mean = max(mean_attempts, 1)

    print("\n  Expected ratio is 16x --- each extra required zero is one more")
    print("  hex digit to match, and a hex digit has 16 possible values.")


def demo_tampering() -> None:
    print("\n" + "=" * 68)
    print("Part E --- immutability: altering history breaks everything after it")
    print("=" * 68)

    difficulty = 4
    chain = build_chain(
        [
            ["alice->bob 10", "bob->carol 3"],
            ["carol->dave 7"],
            ["dave->erin 2", "erin->alice 1"],
            ["alice->frank 5"],
        ],
        difficulty,
    )

    print(f"  built a {len(chain)}-block chain at difficulty {difficulty}")
    print(f"  valid: {is_valid(chain, difficulty)}")

    print("\n  now altering one transaction in block 2...")
    chain[2].transactions[0] = "carol->mallory 1000"

    problems = validate(chain, difficulty)
    print(f"  valid: {not problems}  ({len(problems)} problems found)")
    for problem in problems:
        print(f"    - {problem}")

    print(
        "\n  One edit, two distinct failures. The altered Merkle root changed\n"
        "  block 2's own hash, so its proof of work no longer holds; and that\n"
        "  same changed hash is what block 3 stored as previous_hash, so the\n"
        "  link breaks too.\n"
        "\n"
        "  To repair the chain an attacker must re-mine block 2 and every\n"
        "  block after it, faster than the honest network extends the real one.\n"
        "\n"
        "  That is what immutability means here: not that data cannot be\n"
        "  altered, but that altering it costs more than it is worth."
    )


if __name__ == "__main__":
    demo_hashing()
    demo_merkle()
    demo_difficulty()
    demo_tampering()
