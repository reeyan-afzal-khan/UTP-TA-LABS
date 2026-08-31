// Lab 5, Task 2 --- Queue implemented with a linked list.
//
// Same FIFO behaviour as the array version, but nodes are allocated on
// demand, so there is no fixed capacity: the queue grows until memory
// runs out. That is the trade-off --- no overflow limit, but every node
// costs an allocation and an extra pointer.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

#include <iostream>
#include <string>

using namespace std;

class Node {
public:
    string name;
    Node* next;  // address of the following node, or nullptr at the end

    explicit Node(const string& n) : name(n), next(nullptr) {}
};

class Queue {
private:
    Node* front;  // remove from here
    Node* rear;   // add here

public:
    Queue() : front(nullptr), rear(nullptr) {}

    // Every node reached by `new` must be released exactly once. Without
    // this destructor the queue leaks one node per item still held at exit.
    ~Queue() {
        while (front != nullptr) {
            Node* temp = front;
            front = front->next;
            delete temp;
        }
        rear = nullptr;
    }

    // Copying would duplicate the raw pointers, and both copies would then
    // delete the same nodes. Deleting these two members makes the compiler
    // reject the mistake instead of letting it crash at run time.
    Queue(const Queue&)            = delete;
    Queue& operator=(const Queue&) = delete;

    bool isEmpty() const { return front == nullptr; }

    void enqueue(const string& name) {
        Node* newNode = new Node(name);

        if (rear == nullptr) {
            // Empty queue: the single node is simultaneously front and rear.
            front = rear = newNode;
            return;
        }

        rear->next = newNode;  // link the old rear to the new node
        rear = newNode;        // the new node becomes the rear
    }

    void dequeue() {
        if (isEmpty()) {
            cout << "Queue is empty, nothing to dequeue.\n";
            return;
        }

        Node* temp = front;
        front = front->next;

        // Read the name BEFORE delete. Touching temp->name afterwards is
        // a use-after-free: the memory may hold anything, or the program
        // may crash outright.
        cout << temp->name << " is dequeued.\n";
        delete temp;

        // Removing the last item leaves front == nullptr, but rear is still
        // pointing at the node we just freed. Reset it, or the next
        // enqueue() writes through a dangling pointer.
        if (front == nullptr) {
            rear = nullptr;
        }
    }

    void peek() const {
        if (isEmpty()) {
            cout << "Queue is empty, nothing to peek.\n";
            return;
        }
        cout << "Front is " << front->name << ".\n";
    }

    void display() const {
        if (isEmpty()) {
            cout << "Queue is empty.\n";
            return;
        }
        cout << "front -> ";
        for (Node* current = front; current != nullptr; current = current->next) {
            cout << current->name;
            if (current->next != nullptr) cout << ", ";
        }
        cout << " <- rear\n";
    }
};

int main() {
    Queue q;

    cout << "-- Enqueue three --\n";
    q.enqueue("Aimar");
    q.enqueue("Ahmad");
    q.enqueue("Anjana");
    q.display();
    q.peek();

    cout << "\n-- Dequeue one --\n";
    q.dequeue();
    q.display();

    cout << "\n-- Drain completely, then dequeue once more --\n";
    while (!q.isEmpty()) {
        q.dequeue();
    }
    q.display();
    q.dequeue();

    cout << "\n-- Reuse after draining (rear was reset correctly) --\n";
    q.enqueue("Bala");
    q.enqueue("Chen");
    q.display();

    return 0;
}
