// Lab 5 - Stack ADT and expression processing
// The stack ADT on a fixed-size array: push, pop, peek, isFull, isEmpty and
// display, followed by the suggested trace and a deliberate overflow and
// underflow.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra array_stack.cpp -o array_stack
//     ./array_stack

#include <iostream>
#include <string>
using namespace std;

class ArrayStack {
private:
    static const int CAPACITY = 5;
    int data[CAPACITY];
    int topIndex = -1;

public:
    bool isEmpty() const { return topIndex == -1; }
    bool isFull()  const { return topIndex == CAPACITY - 1; }

    bool push(int value) {
        if (isFull()) return false;          // overflow: refuse before writing
        data[++topIndex] = value;
        return true;
    }

    bool pop(int& removed) {
        if (isEmpty()) return false;         // underflow: refuse before reading
        removed = data[topIndex--];
        return true;
    }

    bool peek(int& value) const {
        if (isEmpty()) return false;
        value = data[topIndex];
        return true;
    }

    void display() const {                   // top to bottom
        if (isEmpty()) { cout << "(empty)\n"; return; }
        for (int i = topIndex; i >= 0; --i) cout << data[i] << ' ';
        cout << '\n';
    }

    int capacity() const { return CAPACITY; }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    ArrayStack s;
    int value = 0;

    cout << "== Suggested trace ==\n";
    s.push(10);
    s.push(20);
    s.push(30);
    s.peek(value);   cout << "peek()    -> " << value << '\n';
    s.pop(value);    cout << "pop()     -> removes " << value << '\n';
    cout << "display() -> "; s.display();
    check("LIFO: the last value pushed (30) was the first removed", value == 30);

    cout << "\n== Overflow (capacity " << s.capacity() << ") ==\n";
    for (int v = 40; v <= 70; v += 10) {
        bool pushed = s.push(v);
        cout << "push(" << v << ") -> " << (pushed ? "ok" : "refused: stack is full") << '\n';
    }
    cout << "display() -> "; s.display();
    check("the push after the stack is full is refused", s.isFull() && !s.push(99));

    cout << "\n== Underflow ==\n";
    while (s.pop(value)) cout << "pop() -> " << value << '\n';
    cout << "pop() on an empty stack -> refused: stack is empty\n";
    check("pop on an empty stack is refused before reading the top", s.isEmpty() && !s.pop(value));
    check("peek on an empty stack is refused", !s.peek(value));
    return 0;
}
