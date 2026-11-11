// Lab 5 - Stack ADT and expression processing
// The same stack ADT on a linked list. Push and pop work at the head, so
// both are O(1) and the stack has no predetermined capacity.
//
// isFull() design choice: this stack imposes NO maximum node count, so
// isFull() always returns false and only a failed allocation (std::bad_alloc)
// could stop it growing. A course that wants a bounded linked stack would add
// a MAX_NODES limit and test it in push().
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra linked_stack.cpp -o linked_stack
//     ./linked_stack

#include <iostream>
#include <string>
using namespace std;

struct StackNode {
    int data;
    StackNode* next;
};

class LinkedStack {
private:
    StackNode* top = nullptr;
    int count = 0;

public:
    ~LinkedStack() {
        int discarded;
        while (pop(discarded)) {}
    }

    bool isEmpty() const { return top == nullptr; }
    bool isFull() const { return false; }   // no fixed capacity; see the note above
    int size() const { return count; }

    void push(int value) {
        top = new StackNode{value, top};
        ++count;
    }

    bool pop(int& removed) {
        if (isEmpty()) return false;
        StackNode* old = top;
        removed = old->data;
        top = top->next;
        delete old;
        --count;
        return true;
    }

    bool peek(int& value) const {
        if (isEmpty()) return false;
        value = top->data;
        return true;
    }

    void display() const {                   // top to bottom
        if (isEmpty()) { cout << "(empty)\n"; return; }
        for (StackNode* p = top; p != nullptr; p = p->next) cout << p->data << ' ';
        cout << '\n';
    }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    LinkedStack s;
    int value = 0;

    cout << "== Suggested trace ==\n";
    s.push(10);
    s.push(20);
    s.push(30);
    s.peek(value);   cout << "peek()    -> " << value << '\n';
    s.pop(value);    cout << "pop()     -> removes " << value << '\n';
    cout << "display() -> "; s.display();
    check("LIFO: the last value pushed (30) was the first removed", value == 30);

    cout << "\n== Growth past the array version's capacity of 5 ==\n";
    for (int v = 40; v <= 90; v += 10) s.push(v);
    cout << "display() -> "; s.display();
    check("eight values stored with no overflow (isFull() is always false)",
          s.size() == 8 && !s.isFull());

    cout << "\n== Underflow ==\n";
    while (s.pop(value)) cout << value << ' ';
    cout << "\npop() on an empty stack -> refused: stack is empty\n";
    check("pop on an empty stack is refused before reading the top", s.isEmpty() && !s.pop(value));
    check("peek on an empty stack is refused", !s.peek(value));
    return 0;
}
