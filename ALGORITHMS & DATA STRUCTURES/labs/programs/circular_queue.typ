#import "/.shared/typst/utp.typ": *

#strong[Program 3: Circular queue and wrap-around.]

#strong[File:] `circular_queue.cpp`.

#strong[Chapter connection:] Circular queue implementation pattern.

Keep front as the next read position and rear as the next write position. count distinguishes full from empty even when the indexes match. display shows active slots so old bytes are not mistaken for queued values.

#include "../visuals/program-circular_queue.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`circular_queue.cpp` --- lines 13--25.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 13, last: 25, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isEmpty, isFull, frontIndex and helpers.]
]

`circular_queue.cpp` --- lines 26--61.

#include "../visuals/walk-queue.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 26, last: 61, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`circular_queue.cpp` --- lines 62--98.

#strong[Trace checkpoint for the supplied main.] rear is the next insertion position in this implementation. After enqueueing 50 it wraps to 0; enqueueing 60 writes slot 0 and advances rear to 1. Later front equals rear both when full and when empty, so count decides which state applies. Compare the complete removal sequence with 10, 20, 30, 40, 50, 60, 70; physical slot order is not queue order.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/circular_queue.cpp", first: 62, last: 98, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect circular\_queue.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra circular_queue.cpp -o circular_queue.exe

.\circular_queue.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/circular_queue.txt`.

#tryit[
  After the printed wrap-around trace, fill all five active slots and refuse one more enqueue. Drain in FIFO order; front and rear may match when count is zero or full.
]
