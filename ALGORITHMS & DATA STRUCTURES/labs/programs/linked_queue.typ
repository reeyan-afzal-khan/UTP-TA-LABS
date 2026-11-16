#import "/.shared/typst/utp.typ": *

#strong[Program 2: Linked queue with two endpoints.]

#strong[File:] `linked_queue.cpp`.

#strong[Chapter connection:] Linked-list queue.

Insert through rear and remove through front. When the final node is removed, reset rear as well. The destructor releases any nodes left when the queue object goes out of scope.

#include "../visuals/program-linked_queue.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`linked_queue.cpp` --- lines 10--17.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 10, last: 17, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement isEmpty, enqueue, dequeue.]
]

`linked_queue.cpp` --- lines 18--51.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`.

#include "../visuals/queue-fifo.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 18, last: 51, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`linked_queue.cpp` --- lines 52--91.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 52, last: 91, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect linked\_queue.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra linked_queue.cpp -o linked_queue.exe

.\linked_queue.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

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

```

The complete captured run is in `labs/outputs/linked_queue.txt`.

#exercises[
  Drain the queue completely, enqueue 70, and dequeue again. Both endpoint pointers must reset after each final removal.
]
