#import "/.shared/typst/utp.typ": *

#strong[Program 4: Stable priority queue.]

#strong[File:] `priority_queue.cpp`.

#strong[Chapter connection:] Linear, circular, and priority queues.

Keep the array ordered on insertion. Shift only strictly lower priorities so equal-priority arrivals remain in FIFO order. dequeue removes the first item and closes the gap. main uses six labelled arrivals to verify both rules.

#include "../visuals/program-priority_queue.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`priority_queue.cpp` --- lines 17--24.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 17, last: 24, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isEmpty, isFull, enqueue and helpers.]
]

`priority_queue.cpp` --- lines 25--55.

#include "../visuals/complete-priority.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 25, last: 55, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`priority_queue.cpp` --- lines 56--95.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 56, last: 95, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect priority\_queue.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra priority_queue.cpp -o priority_queue.exe

.\priority_queue.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/priority_queue.txt`.

#exercises[
  Add a third item with priority 5 after B and D. It must leave after B and D but before priority 3. Then test refusal when the fixed array is full.
]
