#import "/.shared/typst/utp.typ": *
#unit("chapters", "06-queues")

= Queues <ch:queues>

#chapterguide[Know the constrained-access idea from stacks and the array/linked-list implementation alternatives.][explain FIFO, trace front/rear movement, implement enqueue/dequeue, explain why circular queues reuse array space, and distinguish linear, circular, and priority queues at the level covered by the slides.]

A #term[queue] is a linear data structure that follows #term[FIFO]: First In, First Out. Insertion occurs at the #term[rear]; deletion occurs at the #term[front].

== Front and rear

#utpfig([A queue has two active ends. Items join at the rear and leave from the front, so the order of departure matches the order of arrival --- the opposite discipline to a stack.], label: <fig:queue-fifo>)[
  #canvas({
    let queueout = (draw: teal, fill: pale-teal, rounded: 1mm, align: center, font: font("script", fill: navy), inner-xsep: 2mm, inner-ysep: 1.2mm)
    let queuein = (draw: orange, fill: pale-orange, rounded: 1mm, align: center, font: font("script", fill: navy), inner-xsep: 2mm, inner-ysep: 1.2mm)
    for (i, vv) in ("A", "B", "C", "D").enumerate() {
      node((1.5 * i, 0), [#vv], name: "c" + str(i), ..utpcell, min-width: 1.5, min-height: 0.82)
    }
    node((0, -0.6), [FRONT], ..utptag, anchor: "north")
    node((4.5, -0.6), [REAR], ..utptag, anchor: "north")
    node((-1.2, 0), [#strong[dequeue] \ #v(-0.15em)
  #fsize("tiny")[oldest leaves]], name: "deq", ..queueout, anchor: "east")
    connect("c0.west", "deq.east", ..utparrow)
    node((5.7, 0), [#strong[enqueue] \ #v(-0.15em)
  #fsize("tiny")[newest joins]], name: "enq", ..queuein, anchor: "west")
    connect("enq.west", "c3.east", ..utparrow)
  })
]

The Week VI slides use the terms #term[Create Q], #term[Enqueue(Q,item)], and #term[Dequeue(Q)]. The enqueue operation is stated as $O(1)$ in the slide implementation model.

== Core queue operations

#describe-nextline(1.3in)[
  / Create Q: Create an empty queue.
  / enqueue(): Add an item at the rear.
  / dequeue(): Remove and return the oldest item at the front.
  / peek/front: Read the front item without removing it.
  / isEmpty(): Check whether the queue contains no items.
  / isFull(): Check capacity in a fixed array implementation.
]

== A simple linear array queue

A basic fixed array can use indexes for front and rear.

```cpp
private:
    static const int CAP = 5;
    int data[CAP];
    int front = 0;
    int rear = -1;

public:
    bool isEmpty() const { return rear < front; }
    bool isFull() const { return rear == CAP - 1; }

    bool enqueue(int value) {
        if (isFull()) return false;
        data[++rear] = value;
        return true;
    }

    bool dequeue(int& value) {
        if (isEmpty()) return false;
        value = data[front++];
        return true;
    }
};
```

This model exposes the limitation described by the slides: after repeated dequeues, unused positions may exist at the beginning even though `rear` has reached the end of the array.

#figref(<fig:queue-falsefull>) shows the failure. Both `front` and `rear` only
ever move right, so the queue drifts up the array and eventually reports itself full while
sitting on empty slots. Shifting everything back down would fix it, but that costs
#cxr[$O(n)$] on every dequeue and throws away the whole point of the structure.

#utpfig([The “false full” problem in a linear array queue. After three enqueues and two dequeues, `rear` has reached the last index and further enqueues are rejected --- even though indices 0 and 1 are free. The array is not full; the queue has merely walked off the end of it.], label: <fig:queue-falsefull>)[
  #canvas({
    for (i, vv) in (none, none, "C", "D", "E").enumerate() {
      if vv == none or vv == "" {
        node((1.2 * i, 0), [], name: "z" + str(i), font: font("small"), ..utpdim, min-width: 1.15, min-height: 0.85)
      } else {
        node((1.2 * i, 0), [#vv], name: "z" + str(i), font: font("small"), ..utpcell, min-width: 1.15, min-height: 0.85)
      }
      node((1.2 * i, -0.68), [#i], font: font("small"), ..utplabel)
    }
    node((2.4, 1.15), [FRONT], name: "fronttag", draw: orange, fill: pale-orange, rounded: 1mm, font: font("script", weight: "bold", fill: mix(orange, 70%, other: black)), inner-xsep: 2.2mm, inner-ysep: 1mm)
    connect("fronttag.south", (rel: (0, 0.07), to: "z2.north"), line-width: 0.8966pt, draw: orange, end: tip("Stealth", length: 2.1mm, width: 1.45mm, line: 0.8966pt))
    node((4.8, 1.15), [REAR], name: "reartag", draw: orange, fill: pale-orange, rounded: 1mm, font: font("script", weight: "bold", fill: mix(orange, 70%, other: black)), inner-xsep: 2.2mm, inner-ysep: 1mm)
    connect("reartag.south", (rel: (0, 0.07), to: "z4.north"), line-width: 0.8966pt, draw: orange, end: tip("Stealth", length: 2.1mm, width: 1.45mm, line: 0.8966pt))
    brace((-0.62, -0.9), (0.62, -0.9), mirror: true, amplitude: 3.9851pt, raise: 2.9888pt, draw: green, line-width: widths.semithick)
    node((0, -1.3), [free, but \
  unreachable], font: font("small"), ..utplabel, anchor: "north", align: center, text: green)
    node((5.7, 0), [`enqueue(F)` fails: \
  `rear` is at the last index], font: font("small"), ..utplabel, anchor: "west", align: left, text: red)
  })
]

== Circular queue: reusing array space

The circular queue addresses that limitation by connecting the logical last position back to the first. The slides call this a #term[ring buffer] and state that modular arithmetic is used for enqueue and dequeue.

#utpfig([The same five slots viewed as a ring. Advancing with $("index"+1) mod N$ sends `rear` from index 4 back to index 0, so the free space at the front of the array is reclaimed instead of stranded.], label: <fig:queue-circular>)[
  #canvas({
    for (idx, ang) in ((0, 90), (1, 18), (2, -54), (3, -126), (4, 162)) {
      if idx < 2 {
        node((angle: (ang) * 1deg, radius: 1.7), [#idx], name: "k" + str(idx), font: font("small"), ..utpdim, shape: "circle", min-size: 0.95)
      } else {
        node((angle: (ang) * 1deg, radius: 1.7), [#idx], name: "k" + str(idx), font: font("small"), ..utpnode, min-size: 0.95)
      }
    }
    connect("k0", "k1", bend: 20deg, ..utparrow, name: "curve-1")
    connect("k1", "k2", bend: 20deg, ..utparrow, name: "curve-2")
    connect("k2", "k3", bend: 20deg, ..utparrow, name: "curve-3")
    connect("k3", "k4", bend: 20deg, ..utparrow, name: "curve-4")
    connect("k4", "k0", bend: 20deg, line-width: 0.9963pt, draw: orange, end: tip("Stealth", length: 2.4mm, line: 0.9963pt), name: "curve-5")
    node((0, 0), [$(4+1) mod 5$ \
  $=0$], font: font("small"), ..utplabel, align: center, text: orange)
    node((angle: (162) * 1deg, radius: 2.5), [rear], font: font("small"), ..utptag, anchor: "east")
    node((angle: (-54) * 1deg, radius: 2.35), [front], font: font("small"), ..utptag, anchor: "north-west")
    draw.scope({
      draw.translate((6.4, 0))
      draw.translate((0, 0.15))
      for (i, vv) in ("F", none, "C", "D", "E").enumerate() {
        if vv == none or vv == "" {
          node((1.05 * i, 0), [], name: "w" + str(i), font: font("small"), ..utpdim, min-width: 1, min-height: 0.8)
        } else {
          if i == 0 {
            node((1.05 * i, 0), [#vv], name: "w" + str(i), font: font("small"), ..utphot, min-width: 1, min-height: 0.8)
          } else {
            node((1.05 * i, 0), [#vv], name: "w" + str(i), font: font("small"), ..utpcell, min-width: 1, min-height: 0.8)
          }
        }
        node((1.05 * i, -0.62), [#i], font: font("small"), ..utplabel)
      }
      connect("w4.east", (4.98, 0), (4.98, -1.3), (-0.98, -1.3), (-0.98, 0), "w0.west", line-width: 0.9963pt, draw: orange, end: tip("Stealth", length: 2.2mm, line: 0.9963pt))
      node((2.1, -1.42), [`enqueue(F)` now succeeds: `rear` wraps to index 0], font: font("small"), ..utplabel, anchor: "north", align: center)
    })
  })
]

For capacity $N$, moving to the next slot uses

$ "next" = ("index"+1) mod N. $

#workedexample[
  With capacity $5$, if the rear is at index $4$, then the next rear position is

  $ (4+1) mod 5 = 0. $

  The index wraps back to the beginning instead of moving outside the array.
]

== Circular queue implementation pattern

One robust representation stores the number of active elements in addition to front and rear.

```cpp
private:
    static const int CAP = 5;
    int data[CAP];
    int front = 0;
    int rear = 0;
    int count = 0;

public:
    bool isEmpty() const { return count == 0; }
    bool isFull() const { return count == CAP; }

    bool enqueue(int value) {
        if (isFull()) return false;
        data[rear] = value;
        rear = (rear + 1) % CAP;
        ++count;
        return true;
    }

    bool dequeue(int& value) {
        if (isEmpty()) return false;
        value = data[front];
        front = (front + 1) % CAP;
        --count;
        return true;
    }
};
```

== Linked-list queue

A linked queue normally keeps both a front pointer and a rear pointer so enqueue can add at the rear without traversing the list.

```cpp
    int data;
    QNode* next;
};

class LinkedQueue {
private:
    QNode* front = nullptr;
    QNode* rear = nullptr;

public:
    bool isEmpty() const { return front == nullptr; }

    void enqueue(int value) {
        QNode* n = new QNode{value, nullptr};
        if (rear == nullptr) {
            front = rear = n;
        } else {
            rear->next = n;
            rear = n;
        }
    }

    bool dequeue(int& value) {
        if (isEmpty()) return false;
        QNode* old = front;
        value = old->data;
        front = front->next;
        if (front == nullptr) rear = nullptr;
        delete old;
        return true;
    }
};
```

== Linear, circular, and priority queues

The lecture deck asks students to differentiate these queue types, and the official lab manual adds the processing rules for a #term[priority queue].

#utptable[
  #tabularx(
    columns: (19%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Queue type], [Ordering rule], [Course role]),
    [Linear queue], [FIFO], [Front removes oldest; rear inserts newest.],
    [Circular queue], [FIFO with wrap-around array positions], [Reuses vacant positions with modulo arithmetic.],
    [Priority queue], [Higher priority is processed before lower priority; equal-priority items follow arrival order], [Models work where urgency matters more than pure arrival time.],
  )
]

The lab manual states two priority rules:

+ an element of higher priority is processed before an element of lower priority;
+ when two elements have the same priority, they are processed in the order in which they were added.

It also states that priority queues can be implemented using arrays or linked lists.

#sourcealignment[Queue lab manual][
  The manual supplies the priority-ordering rules and the array/linked-list implementation options, but it does not specify a particular insertion strategy, heap representation, or priority convention such as whether a numerically larger value means higher priority. Any implementation should document that design choice.
]

#quickcheck[
  Why can a simple linear array queue appear full even when unused slots exist near index 0? How does modulo arithmetic fix that issue in a circular queue?
]
