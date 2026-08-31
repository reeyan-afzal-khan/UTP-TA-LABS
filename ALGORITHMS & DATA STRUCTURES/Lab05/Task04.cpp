// Lab 5, Task 4 --- Stack implemented with a linked list.
//
// Pushing and popping both happen at the head of the list, which is the
// cheapest place to insert or remove: no traversal, no shifting.
// Unlike the array version there is no fixed capacity.
//
// Build: g++ -std=c++17 -Wall -Wextra Task04.cpp -o task04

#include <iostream>
#include <string>

using namespace std;

class Node {
public:
    string name;
    Node* next;

    explicit Node(const string& n) : name(n), next(nullptr) {}
};

class Stack {
private:
    Node* top;  // head of the list == top of the stack

public:
    Stack() : top(nullptr) {}

    ~Stack() {
        while (top != nullptr) {
            Node* temp = top;
            top = top->next;
            delete temp;
        }
    }

    Stack(const Stack&)            = delete;
    Stack& operator=(const Stack&) = delete;

    bool isEmpty() const { return top == nullptr; }

    void push(const string& name) {
        Node* newNode = new Node(name);
        newNode->next = top;  // the new node points at the old top
        top = newNode;        // and becomes the new top
    }

    void pop() {
        if (isEmpty()) {
            cout << "Stack underflow, nothing to pop.\n";
            // The return is essential, not decoration. Printing the message
            // and then falling through executes `top = top->next` on a null
            // pointer, which dereferences address 0 and crashes.
            return;
        }

        Node* temp = top;
        top = top->next;

        cout << temp->name << " is popped.\n";  // read before freeing
        delete temp;
    }

    void peek() const {
        if (isEmpty()) {
            cout << "Stack is empty, nothing to peek.\n";
            return;
        }
        cout << "Top is " << top->name << ".\n";
    }

    void display() const {
        if (isEmpty()) {
            cout << "Stack is empty.\n";
            return;
        }
        cout << "top -> ";
        for (Node* current = top; current != nullptr; current = current->next) {
            cout << current->name;
            if (current->next != nullptr) cout << ", ";
        }
        cout << " <- bottom\n";
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

    cout << "\n-- Drain completely, then pop once more --\n";
    while (!s.isEmpty()) {
        s.pop();
    }
    s.display();
    s.pop();   // previously crashed here; now reports underflow

    return 0;
}
