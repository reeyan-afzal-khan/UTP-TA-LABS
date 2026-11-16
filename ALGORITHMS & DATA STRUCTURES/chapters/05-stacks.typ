#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-stacks")

= Stacks <ch:stacks>

#chapterguide[Linked lists can be used to build other abstract data types; arrays provide a fixed contiguous alternative.][explain a stack as a LIFO ADT, trace push/pop/peek operations, identify overflow and underflow, and implement array-based and linked-list stacks in C++.]

A #term[stack] is an abstract data type in which access occurs at one end called the #term[top]. The defining rule is #term[LIFO]: Last In, First Out.

== The LIFO principle

If 10 is inserted first, then 20, then 30, the top is 30. Removing an item removes 30 before 20 or 10.

#utpfig([A stack under a sequence of operations. Only the top ever changes, and `pop` always returns the most recent survivor --- 30 leaves before 20, which leaves before 10.], label: <fig:stack-trace>)[
  #canvas({
    let cw = 1.5
    node((0, -0.35), [empty], font: font("small"), ..utplabel, anchor: "north", align: center)
    connect((-0.75, 0.34), (-0.75, -0.05), (0.75, -0.05), (0.75, 0.34), draw: mix(muted, 45%))
    node((0, 0.75), [top $=-1$], font: font("small"), ..utplabel, text: muted)
    draw.scope({
      draw.translate((2.3, 0))
      node((0, -0.35), [`push(10)`], font: font("small"), ..utplabel, anchor: "north", align: center)
      for (k, vv) in (10,).enumerate() {
        node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
      }
    })
    node((3.15, 0), [top], font: font("small"), ..utptag, anchor: "west")
    draw.scope({
      draw.translate((5.2, 0))
      node((0, -0.35), [`push(20)`], font: font("small"), ..utplabel, anchor: "north", align: center)
      for (k, vv) in (10, 20).enumerate() {
        node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
      }
    })
    node((6.05, 0.66), [top], font: font("small"), ..utptag, anchor: "west")
    draw.scope({
      draw.translate((8.1, 0))
      node((0, -0.35), [`push(30)`], font: font("small"), ..utplabel, anchor: "north", align: center)
      for (k, vv) in range(10, 31, step: 10).enumerate() {
        node((0, 0.66 * k), [#vv], name: "q" + str(k), font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
      }
    })
    node((8.95, 1.32), [top], font: font("small"), ..utptag, anchor: "west")
    draw.scope({
      draw.translate((11, 0))
      node((0, -0.35), [`pop()` $arrow.r 30$], font: font("small"), ..utplabel, anchor: "north", align: center)
      node((0, 0), [10], font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
      node((0, 0.66), [20], font: font("small"), ..utpcell, min-width: cw, min-height: 0.62)
      node((0, 1.32), [30], font: font("small"), ..utpdim, min-width: cw, min-height: 0.62)
      connect((-0.42, 1.05), (0.42, 1.59), draw: red, line-width: 0.6974pt)
      node((0.85, 0.66), [top], font: font("small"), ..utptag, anchor: "west")
    })
  })
]

The slide deck names the main operations:

#describe-nextline(1.2in)[
  / push(): Insert a new item at the top.
  / pop(): Remove the top item.
  / peek(): Read the top item without removing it.
  / isEmpty(): Check whether there is no item to access.
  / isFull(): Check capacity for a fixed-size representation.
  / display(): Show the stored items.
]

== Stack states: overflow and underflow

The learning outcomes explicitly ask students to identify both conditions.

#describe-nextline(1.35in)[
  / Overflow: A push is attempted on a fixed-size stack that has no free slot.
  / Underflow: A pop or peek is attempted on an empty stack.
]

#warning[
  Always test the relevant state before changing the top index or dereferencing the top node. Underflow bugs often become invalid memory access.
]

== Array-based stack

The slides specifically frame the array implementation as fixed-size.

```cpp
private:
    static const int CAPACITY = 5;
    int data[CAPACITY];
    int topIndex = -1;

public:
    bool isEmpty() const { return topIndex == -1; }
    bool isFull()  const { return topIndex == CAPACITY - 1; }

    bool push(int value) {
        if (isFull()) return false;
        data[++topIndex] = value;
        return true;
    }

    bool pop(int& removed) {
        if (isEmpty()) return false;
        removed = data[topIndex--];
        return true;
    }

    bool peek(int& value) const {
        if (isEmpty()) return false;
        value = data[topIndex];
        return true;
    }
};
```

The top index is enough to identify the active end of the structure. In the normal implementation above, push, pop, and peek do not scan the existing elements.

== Linked-list stack

A linked-list stack uses the head node as the top. Pushing inserts at the head; popping removes the head.

```cpp
    int data;
    StackNode* next;
};

class LinkedStack {
private:
    StackNode* top = nullptr;

public:
    bool isEmpty() const { return top == nullptr; }

    void push(int value) {
        top = new StackNode{value, top};
    }

    bool pop(int& removed) {
        if (isEmpty()) return false;
        StackNode* old = top;
        removed = old->data;
        top = top->next;
        delete old;
        return true;
    }

    bool peek(int& value) const {
        if (isEmpty()) return false;
        value = top->data;
        return true;
    }
};
```

#note[
  The Week V lab lists `isFull()` for both array and linked-list stacks. A linked-list stack normally has no predetermined fixed capacity; it is “full” only if an external capacity rule is imposed or memory allocation fails. This distinction is not stated on the slide, so the notes preserve the lab operation while making the implementation assumption explicit.
]

== Array vs linked-list stack

#utptable[
  #tabularx(
    columns: (22%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([Feature], [Array-based], [Linked-list]),
    [Capacity in course implementation], [Fixed], [Dynamic unless a limit is imposed],
    [Top representation], [Integer index], [Pointer to first node],
    [Push/pop location], [End at `topIndex`], [Head node],
    [Overflow], [When capacity is exhausted], [Not a fixed-size condition by default],
    [Pointer memory], [No per-element pointer], [One pointer per node],
  )
]

#note[
  A physical stack of plates behaves like the ADT: adding a plate changes only the top, and removing a plate takes the most recently added plate first.
]

The same discipline runs underneath every C++ program. Each function call pushes a frame
holding that call’s parameters and local variables; each `return` pops one
(#figref(<fig:call-stack>)). This is why a runaway recursion produces a #emph[stack overflow],
and why the recursive tree traversals in #chapref(<ch:trees-i>) return to the correct parent
without storing one explicitly.

#utpfig([The call stack during `factorial(3)`. Calls pile up until the base case is reached, then unwind in reverse order, each frame resuming exactly where it paused. The stack is what remembers the half-finished multiplications.], label: <fig:call-stack>)[
  #canvas({
    let cw = 2.75
    for (k, lbl) in ("factorial(3)", "factorial(2)", "factorial(1)").enumerate() {
      node((0, 0.64 * k), [#lbl], ..utpcell, min-width: cw, min-height: 0.6, font: font("script", fill: navy, family: "mono"))
    }
    node((0, -0.42), [calls pile up], font: font("small"), ..utplabel, anchor: "north", align: center)
    node((1.5, 1.28), [top], font: font("small"), ..utptag, anchor: "west")
    connect((0, -0.95), (0, -1.55), ..utparrow)
    node((0.15, -1.25), [base case reached], font: font("small"), ..utplabel, anchor: "west")
    draw.scope({
      draw.translate((5.4, 0))
      node((0, 1.28), [returns 1], ..utpdone, min-width: cw, min-height: 0.6, font: font("script", fill: navy, family: "mono"))
      node((0, 0.64), [2 \* 1 = 2], ..utpdone, min-width: cw, min-height: 0.6, font: font("script", fill: navy, family: "mono"))
      node((0, 0), [3 \* 2 = 6], ..utpdone, min-width: cw, min-height: 0.6, font: font("script", fill: navy, family: "mono"))
      node((0, -0.42), [frames pop, results flow down], font: font("small"), ..utplabel, anchor: "north", align: center)
      connect((1.55, 1.28), (1.55, 0.15), line-width: widths.thick, draw: green, end: arrow-tip("Stealth", length: 2.2mm, line: widths.thick))
    })
    node((2.85, 0.64), [then], font: font("small"), ..utplabel, anchor: "west", align: center, text: muted)
  })
]

== Lab-manual application: infix to postfix

The official lab manual adds one stack problem that is not spelled out in the Week V slide deck: #term[conversion of an infix expression to postfix using a stack]. The stack temporarily stores operators while operands are sent directly to the output.

For example, the infix expression

$ A + B * C $

becomes

$ A med B med C med * med +. $

Multiplication is emitted before addition because it has higher precedence.

#utpsteps[
  + Read the expression from left to right.
  + Send operands directly to the postfix output.
  + Push an opening parenthesis onto the operator stack.
  + For an operator, pop operators of higher precedence (and, for left-associative operators, equal precedence) before pushing the new operator.
  + On a closing parenthesis, pop until the matching opening parenthesis is removed.
  + At the end, pop all remaining operators.
]

#note[
  The lab manual names infix-to-postfix conversion as practice but does not provide the precedence/associativity algorithm in the supplied material. The procedure above is standard supporting context so the named lab task can be implemented.
]

#figref(<fig:infix-trace>) traces the whole conversion for a slightly larger expression. Read
it as a table of states: the stack column is the operator stack from bottom to top, and the
output column only ever grows.

#utpfig([Converting `A + B * C - D` to postfix. When `-` arrives, the stack holds `+` and `*`; both have precedence at least as high as `-`, so both are emitted before `-` is pushed. That single rule is what encodes operator precedence.], label: <fig:infix-trace>)[
  #canvas({
    node((0, 0), [#tabularx(
    columns: (auto, 3.9cm, auto, auto),
    align: (center, left, left, left),
    styles: (navy-bold, none, (fill: blue, font: "Source Code Pro", size: 0.88em), (fill: mix(green, 70%, other: black), font: "Source Code Pro", size: 0.88em)),
    header: ([Read], [Action], [Stack], [Output]),
    [A], [operand: emit], [#hide[x]], [A],
    [\+], [stack empty: push], [\+], [A],
    [B], [operand: emit], [\+], [A B],
    [\*], [higher than +: push], [\+ \*], [A B],
    [C], [operand: emit], [\+ \*], [A B C],
    [\-], [pop \* then +, push -], [\-], [A B C \* +],
    [D], [operand: emit], [\-], [A B C \* + D],
    table.hline(stroke: 0.55pt + rule-color),
    [#emph[end]], [pop remaining], [#hide[x]], [A B C \* + D -],
  )], font: font("small"), anchor: "north-west", inner-sep: 0pt)
  })
]

#questions[
  After `push(10)`, `push(20)`, `push(30)`, `pop()`, and `peek()`, what value is returned by `peek()`? What condition causes underflow?
]
