#import "/.shared/typst/utp.typ": *
#unit("chapters", "05-stacks")


#heading(level: 1)[Stacks]
<ch:stacks>

#callout("chapterguide", title: [Chapter at a glance])[*Before you start:* Linked lists can be used to build other abstract data types; arrays provide a fixed contiguous alternative.

*By the end, you can:* explain a stack as a LIFO ADT, trace push/pop/peek operations, identify overflow and underflow, and implement array-based and linked-list stacks in C++.]

A #strong[stack] is an abstract data type in which access occurs at one end called the #strong[top]. The defining rule is #strong[LIFO]: Last In, First Out.


#heading(level: 2)[The LIFO principle]


If 10 is inserted first, then 20, then 30, the top is 30. Removing an item removes 30 before 20 or 10.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/9a75a8719f9b1ea8.svg")], caption: [A stack under a sequence of operations. Only the top ever changes, and `pop` always returns the most recent survivor --- 30 leaves before 20, which leaves before 10.]) <fig:stack-trace>

The slide deck names the main operations:

/ push(): #block[
Insert a new item at the top.
]

/ pop(): #block[
Remove the top item.
]

/ peek(): #block[
Read the top item without removing it.
]

/ isEmpty(): #block[
Check whether there is no item to access.
]

/ isFull(): #block[
Check capacity for a fixed-size representation.
]

/ display(): #block[
Show the stored items.
]


#heading(level: 2)[Stack states: overflow and underflow]


The learning outcomes explicitly ask students to identify both conditions.

/ Overflow: #block[
A push is attempted on a fixed-size stack that has no free slot.
]

/ Underflow: #block[
A pop or peek is attempted on an empty stack.
]

#callout("pitfall", title: [Common mistake])[Always test the relevant state before changing the top index or dereferencing the top node. Underflow bugs often become invalid memory access.]


#heading(level: 2)[Array-based stack]


The slides specifically frame the array implementation as fixed-size.

#code-block("class ArrayStack {\nprivate:\n    static const int CAPACITY = 5;\n    int data[CAPACITY];\n    int topIndex = -1;\n\npublic:\n    bool isEmpty() const { return topIndex == -1; }\n    bool isFull()  const { return topIndex == CAPACITY - 1; }\n\n    bool push(int value) {\n        if (isFull()) return false;\n        data[++topIndex] = value;\n        return true;\n    }\n\n    bool pop(int& removed) {\n        if (isEmpty()) return false;\n        removed = data[topIndex--];\n        return true;\n    }\n\n    bool peek(int& value) const {\n        if (isEmpty()) return false;\n        value = data[topIndex];\n        return true;\n    }\n};", lang: "text")

The top index is enough to identify the active end of the structure. In the normal implementation above, push, pop, and peek do not scan the existing elements.


#heading(level: 2)[Linked-list stack]


A linked-list stack uses the head node as the top. Pushing inserts at the head; popping removes the head.

#code-block("struct StackNode {\n    int data;\n    StackNode* next;\n};\n\nclass LinkedStack {\nprivate:\n    StackNode* top = nullptr;\n\npublic:\n    bool isEmpty() const { return top == nullptr; }\n\n    void push(int value) {\n        top = new StackNode{value, top};\n    }\n\n    bool pop(int& removed) {\n        if (isEmpty()) return false;\n        StackNode* old = top;\n        removed = old->data;\n        top = top->next;\n        delete old;\n        return true;\n    }\n\n    bool peek(int& value) const {\n        if (isEmpty()) return false;\n        value = top->data;\n        return true;\n    }\n};", lang: "text")

#callout("clarification", title: [Clarification])[The Week V lab lists `isFull()` for both array and linked-list stacks. A linked-list stack normally has no predetermined fixed capacity; it is "full" only if an external capacity rule is imposed or memory allocation fails. This distinction is not stated on the slide, so the notes preserve the lab operation while making the implementation assumption explicit.]


#heading(level: 2)[Array vs linked-list stack]


#figure(
  align(center)[#table(
    columns: 3,
    align: (left,left,left,),
    table.header([Feature], [Array-based], [Linked-list],),
    table.hline(),
    [Capacity in course implementation], [Fixed], [Dynamic unless a limit is imposed],
    [Top representation], [Integer index], [Pointer to first node],
    [Push/pop location], [End at `topIndex`], [Head node],
    [Overflow], [When capacity is exhausted], [Not a fixed-size condition by default],
    [Pointer memory], [No per-element pointer], [One pointer per node],
  )]
  , kind: table
  )

#callout("intuition", title: [Plain idea])[A physical stack of plates behaves like the ADT: adding a plate changes only the top, and removing a plate takes the most recently added plate first.]

The same discipline runs underneath every C++ program. Each function call pushes a frame holding that call's parameters and local variables; each `return` pops one (#ref(label("fig:call-stack"), supplement: [Figure])). This is why a runaway recursion produces a #emph[stack overflow], and why the recursive tree traversals in #ref(label("ch:trees-i"), supplement: [Chapter]) return to the correct parent without storing one explicitly.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/f702f0ad05dc5808.svg")], caption: [The call stack during `factorial(3)`. Calls pile up until the base case is reached, then unwind in reverse order, each frame resuming exactly where it paused. The stack is what remembers the half-finished multiplications.]) <fig:call-stack>


#heading(level: 2)[Lab-manual application: infix to postfix]


The official lab manual adds one stack problem that is not spelled out in the Week V slide deck: #strong[conversion of an infix expression to postfix using a stack]. The stack temporarily stores operators while operands are sent directly to the output.

For example, the infix expression $ A + B * C $ becomes $ A #h(0em) B #h(0em) C #h(0em) * #h(0em) + . $ Multiplication is emitted before addition because it has higher precedence.

+ Read the expression from left to right.

+ Send operands directly to the postfix output.

+ Push an opening parenthesis onto the operator stack.

+ For an operator, pop operators of higher precedence (and, for left-associative operators, equal precedence) before pushing the new operator.

+ On a closing parenthesis, pop until the matching opening parenthesis is removed.

+ At the end, pop all remaining operators.

#callout("clarification", title: [Clarification])[The lab manual names infix-to-postfix conversion as practice but does not provide the precedence/associativity algorithm in the supplied material. The procedure above is standard supporting context so the named lab task can be implemented.]

#ref(label("fig:infix-trace"), supplement: [Figure]) traces the whole conversion for a slightly larger expression. Read it as a table of states: the stack column is the operator stack from bottom to top, and the output column only ever grows.

#figure(block(width: 100%, inset: 7pt, stroke: blue.lighten(70%), radius: 2mm)[#diagram-image("/ALGORITHMS & DATA STRUCTURES/figures/diagrams/e956ea0aabb372b2.svg")], caption: [Converting `A + B * C - D` to postfix. When `-` arrives, the stack holds `+` and `*`; both have precedence at least as high as `-`, so both are emitted before `-` is pushed. That single rule is what encodes operator precedence.]) <fig:infix-trace>

#callout("quickcheck", title: [Check your understanding])[After `push(10)`, `push(20)`, `push(30)`, `pop()`, and `peek()`, what value is returned by `peek()`? What condition causes underflow?]
