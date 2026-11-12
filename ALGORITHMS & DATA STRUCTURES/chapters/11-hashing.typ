#import "/.shared/typst/utp.typ": *
#unit("chapters", "11-hashing")

= Hashing <ch:hashing>

#chapterguide[Know direct array indexing, searching, and why reducing search time is valuable.][explain a hash function, trace a modular hash, identify collisions, and implement the three collision-resolution techniques named in the slides: linear probing, quadratic hashing, and double hashing.]

Hashing is used for fast access to elements. The slide deck describes the core idea as converting a key into a smaller value $I$ with a #term[hash function], then using $I$ as an index where the key is stored or searched.

== Hash function and table index

A simple modular hash function has the form

$ h(k)=k mod m, $

where $m$ is the number of table slots.

The slide’s hashing example uses $H(x)=x mod 5$ for keys 10, 12, and 14.

#workedexample[
  $ 10 mod 5=0, wide 12 mod 5=2, wide 14 mod 5=4. $

  So the keys occupy indices 0, 2, and 4.
]

#utpfig([The hash function maps an unbounded key space onto a small fixed range of table indices. Because the arrow is computed rather than searched for, a lookup goes straight to the slot instead of scanning.], label: <fig:hash-map>)[
  #canvas({
    for (i, k) in range(10, 15, step: 2).enumerate() {
      node((0, -0.85 * i), [#k], name: "k" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
    }
    node((0, 0.55), [#strong[keys]], font: font("small"), ..utplabel, anchor: "south", text: navy)
    node((2.6, -0.85), [$H(x)=x mod 5$], name: "h", ..utpstep, fill: pale-teal, draw: teal, min-width: 2.1, min-height: 1.1, font: font("small", weight: "bold", fill: navy))
    for i in range(0, 3) {
      connect("k" + str(i) + ".east", "h.west", ..utpptr)
    }
    draw.scope({
      draw.translate((5.6, 0))
      draw.translate((0, 0.85))
      for i in range(0, 5) {
        node((0, -0.7 * i), [], name: "t" + str(i), font: font("small"), ..utpdim, min-width: 1.1, min-height: 0.62)
        node((-0.68, -0.7 * i), [#i], font: font("small"), ..utplabel, anchor: "east")
      }
      node((0, 0), [10], font: font("small"), ..utpcell, min-width: 1.1, min-height: 0.62)
      node((0, -1.4), [12], font: font("small"), ..utpcell, min-width: 1.1, min-height: 0.62)
      node((0, -2.8), [14], font: font("small"), ..utpcell, min-width: 1.1, min-height: 0.62)
      node((0, 0.55), [#strong[table]], font: font("small"), ..utplabel, anchor: "south", text: navy)
    })
    connect("h.east", (4.85, -0.85), ..utpptr, draw: teal)
    node((5.6, -2.6), [index computed, not searched], font: font("small"), ..utplabel, anchor: "north", align: center)
  })
]

The slides state that a simple modular hash calculation can be $O(1)$ and therefore supports very efficient storage and access in the intended hashing model.

#clarification[
  The slide’s $O(1)$ statement describes the intended constant-time hash calculation and typical fast table access. Actual access time depends on collision handling and table load; heavy collisions can require multiple probes.
]

== Collision

A #term[collision] occurs when two different keys produce the same hash value and therefore target the same table slot.

The slide example asks what happens when key 15 is inserted:

$ 15 mod 5=0, $

which conflicts with key 10 already at index 0.

#figref(<fig:collision>) shows the conflict. The hash function compresses a large key space
into $m$ slots, so once more than $m$ distinct keys are in play collisions are not merely
likely --- they are unavoidable. Every practical hash table therefore needs a rule for what
to do when the target slot is taken.

#utpfig([A collision. Keys 10 and 15 both hash to index 0, because $10 mod 5$ and $15 mod 5$ are both zero. The hash function cannot be blamed and cannot be fixed: any function mapping many keys onto five slots must send some of them to the same place.], label: <fig:collision>)[
  #canvas({
    node((0, 0.45), [10], name: "a", font: font("small"), ..utpcell, min-width: 1, min-height: 0.62)
    node((0, -0.45), [15], name: "b", font: font("small"), ..utphot, min-width: 1, min-height: 0.62)
    node((2.4, 0), [$x mod 5$], name: "h", ..utpstep, fill: pale-teal, draw: teal, min-width: 1.9, min-height: 0.95, font: font("small", weight: "bold", fill: navy))
    connect("a.east", "h.west", ..utpptr)
    connect("b.east", "h.west", ..utpptr, draw: red)
    draw.scope({
      draw.translate((5.4, 0))
      draw.translate((0, 0.7))
      for i in range(0, 5) {
        node((0, -0.66 * i), [], name: "t" + str(i), font: font("small"), ..utpdim, min-width: 1.1, min-height: 0.6)
        node((-0.68, -0.66 * i), [#i], font: font("small"), ..utplabel, anchor: "east")
      }
      node((0, 0), [10], font: font("small"), ..utphot, min-width: 1.1, min-height: 0.6)
    })
    connect("h.east", (4.65, 0.35), ..utpptr, draw: red, line-width: 0.9963pt)
    node((6.3, 0.4), [both want slot 0: \
  #strong[collision]], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
  })
]

The deck names three collision-handling techniques:

- linear probing;
- double hashing;
- quadratic hashing.

== Linear probing

Linear probing checks the next slot, then the next, wrapping around the table if required.

A probe sequence can be written as

$ (h(k)+i) mod m, wide i=0,1,2, dots.h $

#workedexample[
  With $m=5$, key 15 hashes to 0. If index 0 is occupied, linear probing tries 1, then 2, then 3, then 4 until an empty slot is found.
]

#figref(<fig:probing>) traces a sequence of insertions and shows the characteristic weakness of
linear probing: #term[clustering]. Because every displaced key lands immediately next to the
block it collided with, occupied slots grow into runs, and each new collision must walk the
whole run before finding space.

#utpfig([Inserting 10, 12, 14, 15, 20 into a five-slot table with $H(x)=x mod 5$ and linear probing. Keys 15 and 20 both hash to slot 0 and must walk forward, forming a cluster. By the last insertion a single probe has become four.], label: <fig:probing>)[
  #canvas({
    for (r, (row, hot, lbl)) in ((("10", "", "12", "", "14"), 9, [10, 12, 14 land directly: 1 probe each]), (("10", "15", "12", "", "14"), 1, [$15 mod 5=0$ taken $arrow.r$ probe 1: free]), (("10", "15", "12", "20", "14"), 3, [$20 mod 5=0$ taken $arrow.r$ probes 1, 2, 3])).enumerate() {
      draw.scope({
        draw.translate((0, -1.35 * r))
        for (i, vv) in row.enumerate() {
          node((1.2 * i, 0.58), [#i], font: font("small"), ..utplabel)
          if i == hot {
            node((1.2 * i, 0), [#vv], font: font("small"), ..utphot, min-width: 1.12, min-height: 0.72)
          } else {
            if vv == none or vv == "" {
              node((1.2 * i, 0), [], font: font("small"), ..utpdim, min-width: 1.12, min-height: 0.72)
            } else {
              node((1.2 * i, 0), [#vv], font: font("small"), ..utpcell, min-width: 1.12, min-height: 0.72)
            }
          }
        }
        node((5.4, 0), [#lbl], font: font("small"), ..utplabel, anchor: "west", align: left)
      })
    }
    brace((-0.62, -3.11), (4.42, -3.11), mirror: true, amplitude: 3.9851pt, raise: 2.9888pt, draw: red, line-width: widths.semithick)
    node((1.9, -3.55), [a cluster: no free slot until the table wraps], font: font("small"), ..utplabel, anchor: "north", text: red)
  })
]

```cpp
    int m = static_cast<int>(table.size());
    int start = key % m;

    for (int i = 0; i < m; ++i) {
        int idx = (start + i) % m;
        if (table[idx] == EMPTY) {
            table[idx] = key;
            return idx;
        }
    }
    return -1;  // no free slot
}
```

== Quadratic hashing / quadratic probing

Quadratic probing changes the step size quadratically, for example

$ (h(k)+i^2) mod m. $

```cpp
    int m = static_cast<int>(table.size());
    int h = key % m;

    for (int i = 0; i < m; ++i) {
        int idx = (h + i * i) % m;
        if (table[idx] == EMPTY) {
            table[idx] = key;
            return idx;
        }
    }
    return -1;
}
```

#clarification[
  The slide calls the technique “quadratic hashing.” In common data-structures terminology, the collision-resolution method is usually called #emph[quadratic probing]. The notes keep both labels visible.
]

== Double hashing

Double hashing uses one hash function for the initial position and another to choose the probe step.

One illustrative form is

$ op("index")_i=(h_1(k)+i thin h_2(k)) mod m. $

```cpp
    int m = static_cast<int>(table.size());
    int h1 = key % m;
    int h2 = 1 + (key % (m - 1));

    for (int i = 0; i < m; ++i) {
        int idx = (h1 + i * h2) % m;
        if (table[idx] == EMPTY) {
            table[idx] = key;
            return idx;
        }
    }
    return -1;
}
```

#clarification[
  The hashing deck names double hashing but does not specify a second hash function. The formula above is an implementation example for the lab, not a formula taken from the slide.
]

== Searching under open addressing

The probe rule used for insertion must also be used for searching. Otherwise the program may stop before reaching the slot where a collided key was placed.

#keyidea[
  A hash table does not eliminate the need for searching logic; it changes the search space from “scan the whole collection” to “calculate an index, then follow the collision-resolution probe sequence if necessary.”
]

== Separate chaining as an alternative

All three techniques above are forms of #term[open addressing]: every key lives in the table
itself, so the table can fill up and clustering degrades every probe. The main alternative
stores a linked list at each slot instead, letting colliding keys share a slot rather than
compete for others (#figref(<fig:chaining>)).

#utpfig([Separate chaining. Colliding keys are appended to a list hanging off their slot, so an insertion never disturbs another slot and the table cannot overflow. The cost is one pointer per entry and a short list walk on lookup.], label: <fig:chaining>)[
  #canvas({
    draw.scope({
      node((1.4, 1.15), [Open addressing], font: font("normal", weight: "bold", fill: navy))
      for (i, vv) in (10, 15, 12, 20, 14).enumerate() {
        node((0.7, 0.45 - 0.66 * i), [#vv], font: font("small"), ..utpcell, min-width: 1.05, min-height: 0.62)
        node((0.05, 0.45 - 0.66 * i), [#i], font: font("small"), ..utplabel, anchor: "east")
      }
      node((0.7, -3.1), [table full at 5 keys; \
  probes lengthen as it fills], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
    draw.scope({
      draw.translate((5, 0))
      node((2.2, 1.15), [Separate chaining], font: font("normal", weight: "bold", fill: navy))
      for i in range(0, 5) {
        node((0, 0.45 - 0.66 * i), [], name: "b" + str(i), font: font("small"), ..utpcell, min-width: 0.62, min-height: 0.56)
        node((-0.42, 0.45 - 0.66 * i), [#i], font: font("small"), ..utplabel, anchor: "east")
      }
      for (k, vv) in range(10, 21, step: 5).enumerate() {
        node((1.15 + 1.15 * k, 0.45), [#vv], name: "z" + str(k), font: font("small"), ..utpcell, min-width: 0.85, min-height: 0.56, fill: white)
      }
      connect("b0.east", "z0.west", ..utpptr)
      connect("z0.east", "z1.west", ..utpptr)
      connect("z1.east", "z2.west", ..utpptr)
      node((4.05, 0.45), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      node((1.15, -0.87), [12], name: "y0", font: font("small"), ..utpcell, min-width: 0.85, min-height: 0.56, fill: white)
      connect("b2.east", "y0.west", ..utpptr)
      node((1.75, -0.87), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      node((1.15, -2.19), [14], name: "x0", font: font("small"), ..utpcell, min-width: 0.85, min-height: 0.56, fill: white)
      connect("b4.east", "x0.west", ..utpptr)
      node((1.75, -2.19), [#ptrnull], font: font("small"), ..utplabel, anchor: "west")
      node((1.9, -3.1), [never full; lookup walks one short list], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

#clarification[
  Separate chaining is not named in the supplied hashing slides, which cover linear probing,
  quadratic hashing, and double hashing. It is included here because it is the standard
  alternative and because it explains the deletion problem described in the next section: a
  chained table has no tombstone issue, since removing a node from a list leaves no gap in a
  probe sequence.
]

== Deletion caution

With open addressing, simply marking a deleted slot as never-used can incorrectly terminate a later search whose probe sequence must pass through that slot.

#clarification[
  Deletion behavior and tombstone markers are not covered in the supplied hashing slides. This caution is included only to explain why a complete open-addressing implementation needs more than insertion logic.
]

#quickcheck[
  Using $H(x)=x mod 5$, where do keys 10, 12, 14, and 15 initially hash? Which pair collides? How does linear probing react?
]
