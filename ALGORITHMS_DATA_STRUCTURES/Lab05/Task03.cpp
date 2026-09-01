// Lab 5, Task 3 --- Stack implemented with a fixed-size array.
//
// A stack is LIFO: the last item pushed is the first popped.
// All the action happens at one end, tracked by the index `top`.
//
// Build: g++ -std=c++17 -Wall -Wextra Task03.cpp -o task03

#include <iostream>
#include <string>

using namespace std;

class Stack {
private:
    static const int CAPACITY = 5;

    string arr[CAPACITY];
    int top;  // index of the topmost item; -1 when the stack is empty

public:
    // -1 is the natural "nothing here yet" marker: the first push
    // increments it to 0, which is the first valid array index.
    Stack() : top(-1) {}

    bool isEmpty() const { return top == -1; }

    // The last usable index is CAPACITY - 1, so that is what full means.
    // Comparing against CAPACITY instead is an off-by-one that lets push()
    // write one element past the end of the array.
    bool isFull() const { return top == CAPACITY - 1; }

    int size() const { return top + 1; }

    void push(const string& name) {
        if (isFull()) {
            cout << "Stack overflow, cannot push " << name << ".\n";
            return;
        }
        top++;
        arr[top] = name;
    }

    void pop() {
        if (isEmpty()) {
            cout << "Stack underflow, nothing to pop.\n";
            return;
        }
        cout << arr[top] << " is popped.\n";

        // Decrementing top is the whole removal. The string stays in the
        // array, but it is now above the top and therefore unreachable;
        // the next push() overwrites it.
        top--;
    }

    void peek() const {
        if (isEmpty()) {
            cout << "Stack is empty, nothing to peek.\n";
            return;
        }
        cout << "Top is " << arr[top] << ".\n";
    }

    void display() const {
        if (isEmpty()) {
            cout << "Stack is empty.\n";
            return;
        }
        cout << "top -> ";
        // Walk downwards from top so the output reads top-to-bottom.
        for (int i = top; i >= 0; i--) {
            cout << arr[i];
            if (i > 0) cout << ", ";
        }
        cout << " <- bottom   (top=" << top << ")\n";
    }
};

int main() {
    Stack s;

    cout << "-- Push three --\n";
    s.push("Aimar");
    s.push("Ahmad");
    s.push("Anjana");
    s.display();
    s.peek();

    cout << "\n-- Pop one --\n";
    s.pop();
    s.display();

    cout << "\n-- Overflow: push past capacity " << 5 << " --\n";
    s.push("Bala");
    s.push("Chen");
    s.push("Devi");
    s.display();
    s.push("Eshan");   // rejected

    cout << "\n-- Underflow: drain, then pop once more --\n";
    while (!s.isEmpty()) {
        s.pop();
    }
    s.display();
    s.pop();

    return 0;
}
