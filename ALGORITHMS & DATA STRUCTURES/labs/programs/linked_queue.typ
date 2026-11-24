#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 2: Linked queue with two endpoints])

#strong[File:] `linked_queue.cpp`.

#strong[Chapter connection:] Linked-list queue.

Insert through rear and remove through front. When the final node is removed, reset rear as well. The destructor releases any nodes left when the queue object goes out of scope.

#include "../visuals/program-linked_queue.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `linked_queue.cpp` --- lines 10--17.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 10, last: 17, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isEmpty, enqueue, dequeue.]
  ]

  `linked_queue.cpp` --- lines 18--51.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/queue-fifo.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 18, last: 51, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `linked_queue.cpp` --- lines 52--91.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 52, last: 91, lang: "cpp")

#strong[The last node is the special case.] Six values go in with no capacity check. Every dequeue then moves `front` one node along while `rear` stays on 60, until the very last one.

```terminal
== Enqueue 10, 20, 30, 40, 50, 60 (no capacity limit) ==
front->10 rear->60  queue: 10 20 30 40 50 60
== Dequeue everything ==
dequeued 10  front->20 rear->60  queue: 20 30 40 50 60
dequeued 20  front->30 rear->60  queue: 30 40 50 60
dequeued 30  front->40 rear->60  queue: 40 50 60
dequeued 40  front->50 rear->60  queue: 50 60
dequeued 50  front->60 rear->60  queue: 60
dequeued 60  front->null rear->null  queue: (empty)
  [ok]   FIFO: values left in arrival order
  [ok]   dequeuing the final node reset both front and rear to null
  [ok]   dequeue on an empty queue is refused
== The queue is usable again after emptying ==
front->70 rear->70  queue: 70
  [ok]   a new node becomes both front and rear
```

Only the sixth dequeue touches `rear`. When the node that leaves is also the last one, `front` becomes `nullptr` and `rear` must be reset with it; skip that line and `rear` keeps pointing at freed memory, which the next enqueue would write through. The last section shows the reset working: 70 becomes both `front` and `rear` of a queue that starts again from nothing.

#strong[Empty it twice.] Extend `main`: after 70 goes in, dequeue it, enqueue 80 and 90, and dequeue both, printing `front` and `rear` after every call. Both must read `null` exactly twice in this sequence, once after 70 leaves and once after 90 leaves.
