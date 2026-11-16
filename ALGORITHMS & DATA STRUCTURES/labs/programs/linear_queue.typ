#import "/.shared/typst/utp.typ": *

#strong[Program 1: Linear array queue.]

#strong[File:] `linear_queue.cpp`.

#strong[Chapter connection:] A simple linear array queue.

front advances on removal and rear advances on insertion. This deliberately simple version does not wrap. main shows why free slots at the beginning cannot be reused when rear reaches the final index.

#include "../visuals/program-linear_queue.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`linear_queue.cpp` --- lines 10--24.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 10, last: 24, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Connect the test cases in main.]
]

`linear_queue.cpp` --- lines 25--61.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/queue-falsefull.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 25, last: 61, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`linear_queue.cpp` --- lines 62--77. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linear_queue.cpp", first: 62, last: 77, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect linear\_queue.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra linear_queue.cpp -o linear_queue.exe

.\linear_queue.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/linear_queue.txt`.

#exercises[
  Fill all five positions and dequeue twice. Predict why another enqueue is refused even though two physical slots are free. Compare the same sequence with the circular program.
]
