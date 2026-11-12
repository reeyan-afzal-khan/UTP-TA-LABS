#import "/.shared/typst/utp.typ": *

#strong[Program 1: All three probing methods in one program.]

#strong[File:] `hashing_collisions.cpp`.

#strong[Chapter connection:] Linear probing; Quadratic probing; Double hashing; Searching under open addressing.

Share the probe rule between insertion and search. Start with a fresh table for each method and count every inspected slot. The prime table sizes and nonnegative keys keep the double-hash step valid; insertion stops after at most m probes.

#include "../visuals/program-hashing_collisions.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`hashing_collisions.cpp` --- lines 18--34.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 18, last: 34, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement probeIndex, insertKey.]
]

`hashing_collisions.cpp` --- lines 35--63.

#include "../visuals/walk-hash.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 35, last: 63, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Implement findKey, list, printTable and helpers.]
]

`hashing_collisions.cpp` --- lines 64--92.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 64, last: 92, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`hashing_collisions.cpp` --- lines 93--126.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/probing.typ"

#strong[Trace checkpoint for the supplied main.] After inserting 10, 12 and 14 into a size-five table, slots 0, 2 and 4 are occupied. For key 15, double hashing uses step 4 and visits 0, 4, then 3. Search must reproduce that same sequence. In the crowded-table exercise, distinguish failure to reach a free slot within the probe bound from a table that has no free slot at all.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 93, last: 126, lang: "cpp")

#colbreak()

#utpsteps[
  5. #strong[Compare probe counts in a crowded table.]
]

`hashing_collisions.cpp` --- lines 127--152. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab11/hashing_collisions.cpp", first: 127, last: 152, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect hashing\_collisions.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra hashing_collisions.cpp -o hashing_collisions.exe

.\hashing_collisions.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/hashing_collisions.txt`.

#tryit[
  Use a fresh size-5 table with quadratic inserts 0,5,10,15. The final route 0,1,4,4,1 fails despite free slots. Record failure separately from the five probes and confirm the table is unchanged.
]
