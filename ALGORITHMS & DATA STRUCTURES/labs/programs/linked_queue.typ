#import "/.shared/typst/utp.typ": *

#strong[Program 2: Linked queue with two endpoints.]

#strong[File:] `linked_queue.cpp`.

#strong[Chapter connection:] Linked-list queue.

Insert through rear and remove through front. When the final node is removed, reset rear as well. The destructor releases any nodes left when the queue object goes out of scope.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-linked_queue.typ"


+ #strong[Headers and initial definitions.]

`linked_queue.cpp` --- lines 10--17.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 10, last: 17, lang: "text")

+ #strong[Implement isEmpty, enqueue, dequeue.]

`linked_queue.cpp` --- lines 18--51.

#strong[Read the chapter visual with the code.] The diagram illustrates the storage rule; the program tests the values and cases stated in `main`. 
#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/queue-fifo.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 18, last: 51, lang: "text")

+ #strong[Connect the test cases in main.]

`linked_queue.cpp` --- lines 52--91.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/linked_queue.cpp", first: 52, last: 91, lang: "text")

#strong[Build, run, and inspect linked\_queue.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra linked_queue.cpp -o linked_queue.exe\n\n.\\linked_queue.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Enqueue 10, 20, 30, 40, 50, 60 (no capacity limit) ==\nfront->10 rear->60  queue: 10 20 30 40 50 60 \n\n== Dequeue everything ==\ndequeued 10  front->20 rear->60  queue: 20 30 40 50 60 \ndequeued 20  front->30 rear->60  queue: 30 40 50 60 \ndequeued 30  front->40 rear->60  queue: 40 50 60 \ndequeued 40  front->50 rear->60  queue: 50 60 \ndequeued 50  front->60 rear->60  queue: 60 \ndequeued 60  front->null rear->null  queue: (empty)\n  [ok]   FIFO: values left in arrival order\n  [ok]   dequeuing the final node reset both front and rear to null\n  [ok]   dequeue on an empty queue is refused\n\n== The queue is usable again after emptying ==", lang: "text")

The complete captured run is in `labs/outputs/linked_queue.txt`.

#callout("tryit", title: [Try it yourself])[Drain the queue completely, enqueue 70, and dequeue again. Both endpoint pointers must reset after each final removal.]
