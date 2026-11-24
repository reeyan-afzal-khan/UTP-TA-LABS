#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 4: Stable priority queue])

#strong[File:] `priority_queue.cpp`.

#strong[Chapter connection:] Linear, circular, and priority queues.

Keep the array ordered on insertion. Shift only strictly lower priorities so equal-priority arrivals remain in FIFO order. dequeue removes the first item and closes the gap. main uses six labelled arrivals to verify both rules.

#include "../visuals/program-priority_queue.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `priority_queue.cpp` --- lines 17--24.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 17, last: 24, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isEmpty, isFull, enqueue and helpers.]
  ]

  `priority_queue.cpp` --- lines 25--55.
]

#include "../visuals/complete-priority.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 25, last: 55, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `priority_queue.cpp` --- lines 56--95.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 56, last: 95, lang: "cpp")

#strong[Sorted on the way in.] This queue does its work in `enqueue`: each arrival slides back past every item with a strictly lower priority, so `dequeue` simply takes the front.

```terminal
== Arrivals (value, priority) ==
enqueue A (priority 2)
  queue (front first): A/p2
enqueue B (priority 5)
  queue (front first): B/p5 A/p2
enqueue C (priority 2)
  queue (front first): B/p5 A/p2 C/p2
enqueue D (priority 5)
  queue (front first): B/p5 D/p5 A/p2 C/p2
enqueue E (priority 1)
  queue (front first): B/p5 D/p5 A/p2 C/p2 E/p1
enqueue F (priority 3)
  queue (front first): B/p5 D/p5 F/p3 A/p2 C/p2 E/p1
== Processing order ==
  process B (priority 5)
  process D (priority 5)
  process F (priority 3)
  process A (priority 2)
  process C (priority 2)
  process E (priority 1)
order: BDFACE
  [ok]   rule 1: higher priorities first (B, D at 5 before F at 3 before A, C at 2 before E)
  [ok]   rule 2: equal priorities keep arrival order (B before D, A before C)
  [ok]   dequeue from an empty priority queue is refused
```

D shows rule 2 at work. It has the same priority as B but arrived later, so it stops behind B and ahead of A: an arrival never moves past an equal priority. F, priority 3, settles between the 5s and the 2s. The processing order, BDFACE, is therefore fixed by the data alone, with no tie left for chance to break.

#strong[Add a third five.] Enqueue G with priority 5 after F has arrived, and predict the new order before you run it: BDGFACE, since G ties with B and D but came after both. Then keep enqueueing until the array of 10 is full, and check that the eleventh enqueue is refused without moving any item.
