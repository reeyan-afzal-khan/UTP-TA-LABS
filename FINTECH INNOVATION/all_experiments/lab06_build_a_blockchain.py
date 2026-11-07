# Educational synthetic example: not measured financial or customer data.
from pathlib import Path
import csv
import random

OUT = Path(__file__).resolve().parents[1] / "results" / "lab06"
OUT.mkdir(parents=True, exist_ok=True)
random.seed(42)
print("SYNTHETIC TEACHING EXAMPLE -- replace assumptions with sourced evidence")

# %% Hash unambiguous serialised data
import hashlib
import json
from dataclasses import dataclass

def sha256(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()

def merkle_root(transactions):
    level = [sha256(tx) for tx in transactions] or [sha256("")]
    while len(level) > 1:
        if len(level) % 2:
            level.append(level[-1])
        level = [sha256(level[i] + level[i + 1]) for i in range(0, len(level), 2)]
    return level[0]

assert sha256("Alice pays Bob 10") != sha256("Alice pays Bob 11")

# %% Define the block and bounded proof of work
@dataclass
class Block:
    index: int
    transactions: list
    previous_hash: str
    nonce: int = 0

    def hash(self):
        header = [self.index, self.previous_hash, merkle_root(self.transactions), self.nonce]
        return sha256(json.dumps(header, separators=(",", ":")))

def mine(block, difficulty=2):
    for nonce in range(2_000_000):
        block.nonce = nonce
        if block.hash().startswith("0" * difficulty):
            return block
    raise RuntimeError("Search bound exceeded; lower the classroom difficulty")

# %% Build the complete chain, including genesis
difficulty = 2
chain = [mine(Block(0, ["genesis"], "0" * 64), difficulty)]
for tx in ["alice->bob 10", "bob->carol 4", "carol->dana 2"]:
    chain.append(mine(Block(len(chain), [tx], chain[-1].hash()), difficulty))
for block in chain:
    print(block.index, block.nonce, block.hash()[:16])

# %% Verify every block, then deliberately tamper
def validate(blocks, difficulty):
    problems = []
    if not blocks:
        return ["empty chain"]
    for index, block in enumerate(blocks):
        expected_previous = "0" * 64 if index == 0 else blocks[index - 1].hash()
        if block.index != index:
            problems.append(f"block {index}: incorrect index")
        if block.previous_hash != expected_previous:
            problems.append(f"block {index}: broken previous-hash link")
        if not block.hash().startswith("0" * difficulty):
            problems.append(f"block {index}: invalid proof of work")
    return problems

assert validate(chain, difficulty) == []
chain[2].transactions[0] = "bob->mallory 1000"
problems = validate(chain, difficulty)
assert any("block 3: broken" in problem for problem in problems)
print("After tampering:"); print("\n".join(problems))
(OUT / "tamper_report.txt").write_text("\n".join(problems), encoding="utf-8")
# Tampering does not automatically recompute later stored links.
# This toy has no signatures, balances, peers or consensus; it is not a currency.
