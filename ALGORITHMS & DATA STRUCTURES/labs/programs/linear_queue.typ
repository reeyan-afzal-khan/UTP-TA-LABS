#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Linear array queue])

#strong[File:] `linear_queue.cpp`.

#strong[Chapter connection:] A simple linear array queue.

front advances on removal and rear advances on insertion. This deliberately simple version does not wrap. main shows why free slots at the beginning cannot be reused when rear reaches the final index.

#include "../visuals/program-linear_queue.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `linear_queue.cpp` --- lines 10--24.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 10, last: 24, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Connect the test cases in main.]
  ]

  `linear_queue.cpp` --- lines 25--61.
]

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/queue-falsefull.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 25, last: 61, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `linear_queue.cpp` --- lines 62--77. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 62, last: 77, lang: "cpp")

#strong[Full with two slots free.] Follow `front` and `rear` rather than the values: both only ever move to the right.

```terminal
== Enqueue 10, 20, 30 ==
front=0 rear=0  queue: 10
front=0 rear=1  queue: 10 20
front=0 rear=2  queue: 10 20 30
== Dequeue twice ==
dequeued 10  front=1 rear=2  queue: 20 30
dequeued 20  front=2 rear=2  queue: 30
  [ok]   FIFO: values leave in the order they arrived (10 then 20)
== Enqueue 40, 50, 60 ==
enqueue 40 -> ok      front=2 rear=3  queue: 30 40
enqueue 50 -> ok      front=2 rear=4  queue: 30 40 50
enqueue 60 -> refused front=2 rear=4  queue: 30 40 50
  [ok]   the queue reports full with only three items: slots 0 and 1 are wasted
== Dequeue until empty ==
front=5 rear=4  queue: (empty)
  [ok]   every value left in arrival order
  [ok]   dequeue on an empty queue is refused
```

Two dequeues move `front` to index 2 and leave slots 0 and 1 empty, yet `enqueue 60` is refused: `rear` has reached index 4, the end of the array, and a linear queue never returns to a slot it has passed. The final line, `front=5 rear=4`, is how this queue says empty: `front` has overtaken `rear`.

#strong[Count the wasted slots.] Enqueue five values into an empty queue, dequeue two, and try a sixth enqueue. Write down `front`, `rear` and the number of free slots before you run it: 2, 4 and two free slots, and the enqueue is still refused. Run the same eight operations with the circular queue in Program 3. There the last enqueue succeeds and lands in slot 0.
