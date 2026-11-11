#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-queues")


#heading(level: 1)[Queues]
<ch:queues>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Know the constrained-access idea from stacks and the array/linked-list implementation alternatives.

*By the end, you can:* explain FIFO, trace front/rear movement, implement enqueue/dequeue, explain why circular queues reuse array space, and distinguish linear, circular, and priority queues at the level covered by the slides.]

A #strong[queue] is a linear data structure that follows #strong[FIFO]: First In, First Out. Insertion occurs at the #strong[rear]; deletion occurs at the #strong[front].


#heading(level: 2)[Front and rear]


#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/502f919da6cdfea2.svg")], caption: [A queue has two active ends. Items join at the rear and leave from the front, so the order of departure matches the order of arrival --- the opposite discipline to a stack.]) <fig:queue-fifo>

The Week VI slides use the terms #strong[Create Q], #strong[Enqueue(Q,item)], and #strong[Dequeue(Q)]. The enqueue operation is stated as $O \( 1 \)$ in the slide implementation model.


#heading(level: 2)[Core queue operations]


/ Create Q: #block[
Create an empty queue.
]

/ enqueue(): #block[
Add an item at the rear.
]

/ dequeue(): #block[
Remove and return the oldest item at the front.
]

/ peek/front: #block[
Read the front item without removing it.
]

/ isEmpty(): #block[
Check whether the queue contains no items.
]

/ isFull(): #block[
Check capacity in a fixed array implementation.
]


#heading(level: 2)[A simple linear array queue]


A basic fixed array can use indexes for front and rear.

#code-block("class LinearQueue {\nprivate:\n    static const int CAP = 5;\n    int data[CAP];\n    int front = 0;\n    int rear = -1;\n\npublic:\n    bool isEmpty() const { return rear < front; }\n    bool isFull() const { return rear == CAP - 1; }\n\n    bool enqueue(int value) {\n        if (isFull()) return false;\n        data[++rear] = value;\n        return true;\n    }\n\n    bool dequeue(int& value) {\n        if (isEmpty()) return false;\n        value = data[front++];\n        return true;\n    }\n};", lang: "text")

This model exposes the limitation described by the slides: after repeated dequeues, unused positions may exist at the beginning even though `rear` has reached the end of the array.

#ref(label("fig:queue-falsefull"), supplement: [Figure]) shows the failure. Both `front` and `rear` only ever move right, so the queue drifts up the array and eventually reports itself full while sitting on empty slots. Shifting everything back down would fix it, but that costs $O \( n \)$ on every dequeue and throws away the whole point of the structure.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/704d057639110d8e.svg")], caption: [The "false full" problem in a linear array queue. After three enqueues and two dequeues, `rear` has reached the last index and further enqueues are rejected --- even though indices 0 and 1 are free. The array is not full; the queue has merely walked off the end of it.]) <fig:queue-falsefull>


#heading(level: 2)[Circular queue: reusing array space]


The circular queue addresses that limitation by connecting the logical last position back to the first. The slides call this a #strong[ring buffer] and state that modular arithmetic is used for enqueue and dequeue.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/4bb9eb5b20f10027.svg")], caption: [The same five slots viewed as a ring. Advancing with $\( upright("index") + 1 \) med mod med N$ sends `rear` from index 4 back to index 0, so the free space at the front of the array is reclaimed instead of stranded.]) <fig:queue-circular>

For capacity $N$, moving to the next slot uses $ upright("next") = \( upright("index") + 1 \) med mod med N . $

#callout("workedexample", title: [Worked example])[With capacity $5$, if the rear is at index $4$, then the next rear position is $ \( 4 + 1 \) med mod med 5 = 0 . $ The index wraps back to the beginning instead of moving outside the array.]


#heading(level: 2)[Circular queue implementation pattern]


One robust representation stores the number of active elements in addition to front and rear.

#code-block("class CircularQueue {\nprivate:\n    static const int CAP = 5;\n    int data[CAP];\n    int front = 0;\n    int rear = 0;\n    int count = 0;\n\npublic:\n    bool isEmpty() const { return count == 0; }\n    bool isFull() const { return count == CAP; }\n\n    bool enqueue(int value) {\n        if (isFull()) return false;\n        data[rear] = value;\n        rear = (rear + 1) \n        ++count;\n        return true;\n    }\n\n    bool dequeue(int& value) {\n        if (isEmpty()) return false;\n        value = data[front];\n        front = (front + 1) \n        --count;\n        return true;\n    }\n};", lang: "text")


#heading(level: 2)[Linked-list queue]


A linked queue normally keeps both a front pointer and a rear pointer so enqueue can add at the rear without traversing the list.

#code-block("struct QNode {\n    int data;\n    QNode* next;\n};\n\nclass LinkedQueue {\nprivate:\n    QNode* front = nullptr;\n    QNode* rear = nullptr;\n\npublic:\n    bool isEmpty() const { return front == nullptr; }\n\n    void enqueue(int value) {\n        QNode* n = new QNode{value, nullptr};\n        if (rear == nullptr) {\n            front = rear = n;\n        } else {\n            rear->next = n;\n            rear = n;\n        }\n    }\n\n    bool dequeue(int& value) {\n        if (isEmpty()) return false;\n        QNode* old = front;\n        value = old->data;\n        front = front->next;\n        if (front == nullptr) rear = nullptr;\n        delete old;\n        return true;\n    }\n};", lang: "text")


#heading(level: 2)[Linear, circular, and priority queues]


The lecture deck asks students to differentiate these queue types, and the official lab manual adds the processing rules for a #strong[priority queue].

#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Queue type], [Ordering rule], [Course role],),
    table.hline(),
    [Linear queue], [FIFO], [Front removes oldest; rear inserts newest.],
    [Circular queue], [FIFO with wrap-around array positions], [Reuses vacant positions with modulo arithmetic.],
    [Priority queue], [Higher priority is processed before lower priority; equal-priority items follow arrival order], [Models work where urgency matters more than pure arrival time.],
  )]
  , kind: table
  )

The lab manual states two priority rules:

+ an element of higher priority is processed before an element of lower priority;

+ when two elements have the same priority, they are processed in the order in which they were added.

It also states that priority queues can be implemented using arrays or linked lists.

#callout("sourcealignment", title: [Queue lab manual])[The manual supplies the priority-ordering rules and the array/linked-list implementation options, but it does not specify a particular insertion strategy, heap representation, or priority convention such as whether a numerically larger value means higher priority. Any implementation should document that design choice.]

#callout("quickcheck", title: [Check your understanding])[Why can a simple linear array queue appear full even when unused slots exist near index 0? How does modulo arithmetic fix that issue in a circular queue?]
