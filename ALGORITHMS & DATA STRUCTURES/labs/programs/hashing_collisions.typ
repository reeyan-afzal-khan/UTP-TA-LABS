#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: All three probing methods in one program])

#strong[File:] `hashing_collisions.cpp`.

#strong[Chapter connection:] Linear probing; Quadratic probing; Double hashing; Searching under open addressing.

Share the probe rule between insertion and search. Start with a fresh table for each method and count every inspected slot. The prime table sizes and nonnegative keys keep the double-hash step valid; insertion stops after at most m probes.

#include "../visuals/program-hashing_collisions.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `hashing_collisions.cpp` --- lines 18--34.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 18, last: 34, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement probeIndex, insertKey.]
  ]

  `hashing_collisions.cpp` --- lines 35--63.
]

#include "../visuals/walk-hash.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 35, last: 63, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Implement findKey, list, printTable and helpers.]
  ]

  `hashing_collisions.cpp` --- lines 64--92.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 64, last: 92, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `hashing_collisions.cpp` --- lines 93--126.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/probing.typ"

#strong[Trace checkpoint for the supplied main.] After inserting 10, 12 and 14 into a size-five table, slots 0, 2 and 4 are occupied. For key 15, double hashing uses step 4 and visits 0, 4, then 3. Search must reproduce that same sequence. In the crowded-table exercise, distinguish failure to reach a free slot within the probe bound from a table that has no free slot at all.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 93, last: 126, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    5. #strong[Compare probe counts in a crowded table.]
  ]

  `hashing_collisions.cpp` --- lines 127--152. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 127, last: 152, lang: "cpp")

#strong[One collision, three detours.] Only key 15 collides, so the three methods differ in one respect: where 15 ends up.

```terminal
== H(x) = x mod 5, keys 10 12 14 15 ==
linear probing:
  key 10  home 0  probes 0               -> slot 0
  key 12  home 2  probes 2               -> slot 2
  key 14  home 4  probes 4               -> slot 4
  key 15  home 0  probes 0 -> 1          -> slot 1
  table: [0:10] [1:15] [2:12] [3:-] [4:14]
  [ok]   every key is found again with the same probe rule
  [ok]   every probe index stayed inside the table
quadratic probing:
  key 10  home 0  probes 0               -> slot 0
  key 12  home 2  probes 2               -> slot 2
  key 14  home 4  probes 4               -> slot 4
  key 15  home 0  probes 0 -> 1          -> slot 1
  table: [0:10] [1:15] [2:12] [3:-] [4:14]
  [ok]   every key is found again with the same probe rule
  [ok]   every probe index stayed inside the table
double hashing:
  key 10  home 0  probes 0               -> slot 0
  key 12  home 2  probes 2               -> slot 2
  key 14  home 4  probes 4               -> slot 4
  key 15  home 0  probes 0 -> 4 -> 3     -> slot 3
  table: [0:10] [1:-] [2:12] [3:15] [4:14]
  [ok]   every key is found again with the same probe rule
  [ok]   every probe index stayed inside the table
The collision: 15 mod 5 = 0, already holding 10. Linear probing steps
to slot 1; quadratic probing also tries 0 + 1*1 = 1; double hashing
steps by h2(15) = 1 + (15 mod 4) = 4, trying 0, then 4 (taken by 14),
then 3.
  [ok]   the double-hash step 1 + (k mod 4) is never 0
== Try it: a crowded table (m = 11) ==
  inserting 10 keys that pile up on slots 10 and 3: 10 12 14 15 21 32 43 54 25 36
  method                10  12  14  15  21  32  43  54  25  36   total
  linear probing         1   1   1   1   2   4   7   8   5   6      36
  quadratic probing      1   1   1   1   2   4   6   x   3   6      36
  double hashing         1   1   1   1   4   2   3   3   6   3      25
  (probes needed per key; x = no free slot reached within m probes)
  Linear probing builds one long cluster, so later keys walk further.
  Quadratic probing jumps out of the cluster but only ever visits about
  half of the slots, so a crowded table can refuse a key with room left.
  Double hashing gives each key its own step and spreads the probes.
```

Linear and quadratic probing both send 15 to slot 1, because their first step is the same, +1. Double hashing computes the step from the key, 1~+~(15~mod~4)~=~4, so it tries slot 4 next, finds 14 there, and settles in slot 3. The crowded table at the end shows why the choice matters once a table fills up: for ten keys in eleven slots, linear probing needs 36 probes and double hashing 25, and quadratic probing cannot place 54 at all, although free slots remain.

#strong[Make quadratic probing give up.] Insert 0, 5, 10 and 15 into a fresh table of size 5 with quadratic probing. All four keys hash to slot 0, so predict each landing slot first: 0 stays in slot 0, 5 goes to 1 and 10 to 4. Then 15 tries slots 0, 1, 4, 4 and 1 and gives up after five probes, although slots 2 and 3 are free. Check that `insertKey` reports the failure with -1, separately from its probe list, and that the table is exactly as it was before.
