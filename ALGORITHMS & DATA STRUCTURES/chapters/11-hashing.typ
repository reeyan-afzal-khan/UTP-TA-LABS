#import "/.shared/typst/utp.typ": *
#unit("chapters", "11-hashing")


#heading(level: 1)[Hashing]
<ch:hashing>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know direct array indexing, searching, and why reducing search time is valuable.

*By the end, you can:* explain a hash function, trace a modular hash, identify collisions, and implement the three collision-resolution techniques named in the slides: linear probing, quadratic hashing, and double hashing.]

Hashing is used for fast access to elements. The slide deck describes the core idea as converting a key into a smaller value $I$ with a #strong[hash function], then using $I$ as an index where the key is stored or searched.


#heading(level: 2)[Hash function and table index]


A simple modular hash function has the form $ h \( k \) = k med mod med m \, $ where $m$ is the number of table slots.

The slide's hashing example uses $H \( x \) = x med mod med 5$ for keys 10, 12, and 14.

#callout("workedexample", title: [Worked example])[$ 10 med mod med 5 = 0 \, #h(2em) 12 med mod med 5 = 2 \, #h(2em) 14 med mod med 5 = 4 . $ So the keys occupy indices 0, 2, and 4.]

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/0b74e763428eb55a.cetz.json")], caption: [The hash function maps an unbounded key space onto a small fixed range of table indices. Because the arrow is computed rather than searched for, a lookup goes straight to the slot instead of scanning.]) <fig:hash-map>

The slides state that a simple modular hash calculation can be $O \( 1 \)$ and therefore supports very efficient storage and access in the intended hashing model.

#callout("clarification", title: [Clarification])[The slide's $O \( 1 \)$ statement describes the intended constant-time hash calculation and typical fast table access. Actual access time depends on collision handling and table load; heavy collisions can require multiple probes.]


#heading(level: 2)[Collision]


A #strong[collision] occurs when two different keys produce the same hash value and therefore target the same table slot.

The slide example asks what happens when key 15 is inserted: $ 15 med mod med 5 = 0 \, $ which conflicts with key 10 already at index 0.

#ref(label("fig:collision"), supplement: [Figure]) shows the conflict. The hash function compresses a large key space into $m$ slots, so once more than $m$ distinct keys are in play collisions are not merely likely --- they are unavoidable. Every practical hash table therefore needs a rule for what to do when the target slot is taken.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/ee623e6ac4838a45.cetz.json")], caption: [A collision. Keys 10 and 15 both hash to index 0, because $10 med mod med 5$ and $15 med mod med 5$ are both zero. The hash function cannot be blamed and cannot be fixed: any function mapping many keys onto five slots must send some of them to the same place.]) <fig:collision>

The deck names three collision-handling techniques:

- linear probing;

- double hashing;

- quadratic hashing.


#heading(level: 2)[Linear probing]


Linear probing checks the next slot, then the next, wrapping around the table if required.

A probe sequence can be written as $ \( h \( k \) + i \) med mod med m \, #h(2em) i = 0 \, 1 \, 2 \, dots.h $

#callout("workedexample", title: [Worked example])[With $m = 5$, key 15 hashes to 0. If index 0 is occupied, linear probing tries 1, then 2, then 3, then 4 until an empty slot is found.]

#ref(label("fig:probing"), supplement: [Figure]) traces a sequence of insertions and shows the characteristic weakness of linear probing: #strong[clustering]. Because every displaced key lands immediately next to the block it collided with, occupied slots grow into runs, and each new collision must walk the whole run before finding space.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/332d91316954b93f.cetz.json")], caption: [Inserting 10, 12, 14, 15, 20 into a five-slot table with $H \( x \) = x med mod med 5$ and linear probing. Keys 15 and 20 both hash to slot 0 and must walk forward, forming a cluster. By the last insertion a single probe has become four.]) <fig:probing>

#code-block("int insertLinear(vector<int>& table, int key, int EMPTY) {\n    int m = static_cast<int>(table.size());\n    int start = key \n\n    for (int i = 0; i < m; ++i) {\n        int idx = (start + i) \n        if (table[idx] == EMPTY) {\n            table[idx] = key;\n            return idx;\n        }\n    }\n    return -1;  // no free slot\n}", lang: "text")


#heading(level: 2)[Quadratic hashing / quadratic probing]


Quadratic probing changes the step size quadratically, for example $ \( h \( k \) + i^2 \) med mod med m . $

#code-block("int insertQuadratic(vector<int>& table, int key, int EMPTY) {\n    int m = static_cast<int>(table.size());\n    int h = key \n\n    for (int i = 0; i < m; ++i) {\n        int idx = (h + i * i) \n        if (table[idx] == EMPTY) {\n            table[idx] = key;\n            return idx;\n        }\n    }\n    return -1;\n}", lang: "text")

#callout("clarification", title: [Clarification])[The slide calls the technique "quadratic hashing." In common data-structures terminology, the collision-resolution method is usually called #emph[quadratic probing]. The notes keep both labels visible.]


#heading(level: 2)[Double hashing]


Double hashing uses one hash function for the initial position and another to choose the probe step.

One illustrative form is $ "index"_i = \( h_1 \( k \) + i thin h_2 \( k \) \) med mod med m . $

#code-block("int insertDoubleHash(vector<int>& table, int key, int EMPTY) {\n    int m = static_cast<int>(table.size());\n    int h1 = key \n    int h2 = 1 + (key \n\n    for (int i = 0; i < m; ++i) {\n        int idx = (h1 + i * h2) \n        if (table[idx] == EMPTY) {\n            table[idx] = key;\n            return idx;\n        }\n    }\n    return -1;\n}", lang: "text")

#callout("clarification", title: [Clarification])[The hashing deck names double hashing but does not specify a second hash function. The formula above is an implementation example for the lab, not a formula taken from the slide.]


#heading(level: 2)[Searching under open addressing]


The probe rule used for insertion must also be used for searching. Otherwise the program may stop before reaching the slot where a collided key was placed.

#callout("keyidea", title: [Key idea])[A hash table does not eliminate the need for searching logic; it changes the search space from "scan the whole collection" to "calculate an index, then follow the collision-resolution probe sequence if necessary."]


#heading(level: 2)[Separate chaining as an alternative]


All three techniques above are forms of #strong[open addressing]: every key lives in the table itself, so the table can fill up and clustering degrades every probe. The main alternative stores a linked list at each slot instead, letting colliding keys share a slot rather than compete for others (#ref(label("fig:chaining"), supplement: [Figure])).

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-drawing("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/64a02bcc2f9c5050.cetz.json")], caption: [Separate chaining. Colliding keys are appended to a list hanging off their slot, so an insertion never disturbs another slot and the table cannot overflow. The cost is one pointer per entry and a short list walk on lookup.]) <fig:chaining>

#callout("clarification", title: [Clarification])[Separate chaining is not named in the supplied hashing slides, which cover linear probing, quadratic hashing, and double hashing. It is included here because it is the standard alternative and because it explains the deletion problem described in the next section: a chained table has no tombstone issue, since removing a node from a list leaves no gap in a probe sequence.]


#heading(level: 2)[Deletion caution]


With open addressing, simply marking a deleted slot as never-used can incorrectly terminate a later search whose probe sequence must pass through that slot.

#callout("clarification", title: [Clarification])[Deletion behavior and tombstone markers are not covered in the supplied hashing slides. This caution is included only to explain why a complete open-addressing implementation needs more than insertion logic.]

#callout("quickcheck", title: [Check your understanding])[Using $H \( x \) = x med mod med 5$, where do keys 10, 12, 14, and 15 initially hash? Which pair collides? How does linear probing react?]
