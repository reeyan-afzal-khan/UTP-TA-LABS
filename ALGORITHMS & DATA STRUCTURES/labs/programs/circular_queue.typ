#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 3: Circular queue and wrap-around])

#strong[File:] `circular_queue.cpp`.

#strong[Chapter connection:] Circular queue implementation pattern.

Keep front as the next read position and rear as the next write position. count distinguishes full from empty even when the indexes match. display shows active slots so old bytes are not mistaken for queued values.

#include "../visuals/program-circular_queue.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `circular_queue.cpp` --- lines 13--25.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 13, last: 25, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement isEmpty, isFull, frontIndex and helpers.]
  ]

  `circular_queue.cpp` --- lines 26--61.
]

#include "../visuals/walk-queue.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 26, last: 61, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `circular_queue.cpp` --- lines 62--98.
]

#strong[Trace checkpoint for the supplied main.] rear is the next insertion position in this implementation. After enqueueing 50 it wraps to 0; enqueueing 60 writes slot 0 and advances rear to 1. Later front equals rear both when full and when empty, so count decides which state applies. Compare the complete removal sequence with 10, 20, 30, 40, 50, 60, 70; physical slot order is not queue order.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 62, last: 98, lang: "cpp")

#strong[The wrap-around, line by line.] Here `rear` is the next free slot, and both indexes move on with `(i + 1) % 5`.

```terminal
== The lab trace (capacity 5) ==
start           front=0 rear=0 count=0   slots: [- - - - -]  EMPTY
enqueue 10      front=0 rear=1 count=1   slots: [10 - - - -]
enqueue 20      front=0 rear=2 count=2   slots: [10 20 - - -]
enqueue 30      front=0 rear=3 count=3   slots: [10 20 30 - -]
enqueue 40      front=0 rear=4 count=4   slots: [10 20 30 40 -]
dequeue -> 10   front=1 rear=4 count=3   slots: [- 20 30 40 -]
dequeue -> 20   front=2 rear=4 count=2   slots: [- - 30 40 -]
enqueue 50      front=2 rear=0 count=3   slots: [- - 30 40 50]
  [ok]   rear wrapped from index 4 back to index 0
enqueue 60      front=2 rear=1 count=4   slots: [60 - 30 40 50]
  [ok]   60 was stored in slot 0, a slot freed by an earlier dequeue
== Fill to capacity, then empty it ==
enqueue 70      front=2 rear=2 count=5   slots: [60 70 30 40 50]  FULL
  [ok]   full: count == 5 even though front == rear
  [ok]   an enqueue into a full queue is refused
dequeue -> 30   front=3 rear=2 count=4   slots: [60 70 - 40 50]
dequeue -> 40   front=4 rear=2 count=3   slots: [60 70 - - 50]
dequeue -> 50   front=0 rear=2 count=2   slots: [60 70 - - -]
dequeue -> 60   front=1 rear=2 count=1   slots: [- 70 - - -]
dequeue -> 70   front=2 rear=2 count=0   slots: [- - - - -]  EMPTY
  [ok]   empty: count == 0 with front == rear again, so count separates the two
  [ok]   FIFO order kept across the wrap: 10 20 30 40 50 60 70
  [ok]   a dequeue from an empty queue is refused
```

Enqueueing 50 fills slot 4 and sends `rear` round to 0, so 60 lands in slot 0, freed earlier by the dequeue of 10. That is the step the linear queue could not take. Compare `front` and `rear` in the `FULL` line and in the final `EMPTY` line: both read 2 and 2. Equal indexes cannot tell full from empty, which is why the queue also keeps `count`.

#strong[Go round again.] Continue `main` after the final `EMPTY` line: enqueue 1 to 7, then dequeue everything. Predict before you run it. 1 lands in slot 2, where `front` and `rear` both point; 6 and 7 are refused; the values leave as 1 2 3 4 5; and `front` finishes one full lap later, back at index 2.
