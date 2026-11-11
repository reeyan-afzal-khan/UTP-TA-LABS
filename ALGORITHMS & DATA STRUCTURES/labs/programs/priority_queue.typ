#import "/.shared/typst/utp.typ": *

#strong[Program 4: Stable priority queue.]

#strong[File:] `priority_queue.cpp`.

#strong[Chapter connection:] Linear, circular, and priority queues.

Keep the array ordered on insertion. Shift only strictly lower priorities so equal-priority arrivals remain in FIFO order. dequeue removes the first item and closes the gap. main uses six labelled arrivals to verify both rules.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/program-priority_queue.typ"


+ #strong[Headers and initial definitions.]

`priority_queue.cpp` --- lines 17--24.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 17, last: 24, lang: "text")

+ #strong[Implement isEmpty, isFull, enqueue and helpers.]

`priority_queue.cpp` --- lines 25--55.


#include "/ALGORITHMS & DATA STRUCTURES/labs/visuals/complete-priority.typ"


#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 25, last: 55, lang: "text")

+ #strong[Connect the test cases in main.]

`priority_queue.cpp` --- lines 56--95.

#source-code("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab06/priority_queue.cpp", first: 56, last: 95, lang: "text")

#strong[Build, run, and inspect priority\_queue.]

From this program\'s folder, run these commands in PowerShell:

#code-block("g++ -std=c++17 -Wall -Wextra priority_queue.cpp -o priority_queue.exe\n\n.\\priority_queue.exe", lang: "text")

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

#code-block("== Arrivals (value, priority) ==\nenqueue A (priority 2)\n  queue (front first): A/p2 \nenqueue B (priority 5)\n  queue (front first): B/p5 A/p2 \nenqueue C (priority 2)\n  queue (front first): B/p5 A/p2 C/p2 \nenqueue D (priority 5)\n  queue (front first): B/p5 D/p5 A/p2 C/p2 \nenqueue E (priority 1)\n  queue (front first): B/p5 D/p5 A/p2 C/p2 E/p1 \nenqueue F (priority 3)\n  queue (front first): B/p5 D/p5 F/p3 A/p2 C/p2 E/p1 \n\n== Processing order ==", lang: "text")

The complete captured run is in `labs/outputs/priority_queue.txt`.

#callout("tryit", title: [Try it yourself])[Add a third item with priority 5 after B and D. It must leave after B and D but before priority 3. Then test refusal when the fixed array is full.]
