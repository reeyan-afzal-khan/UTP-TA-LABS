// Lab 6 - Linear, linked, circular, and priority queues
// A queue on a linked list: enqueue at the rear node, dequeue at the front
// node, both in O(1) with no fixed capacity. Dequeuing the final node must
// reset BOTH front and rear to nullptr.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra linked_queue.cpp -o linked_queue
//     ./linked_queue

#include <iostream>
#include <string>
using namespace std;

struct QNode {
    int data;
    QNode* next;
};

class LinkedQueue {
private:
    QNode* front = nullptr;
    QNode* rear = nullptr;

public:
    ~LinkedQueue() {
        int discarded;
        while (dequeue(discarded)) {}
    }

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

    void display() const {
        cout << "front->" << (front ? to_string(front->data) : "null")
             << " rear->" << (rear ? to_string(rear->data) : "null") << "  queue: ";
        if (isEmpty()) cout << "(empty)";
        for (QNode* p = front; p != nullptr; p = p->next) cout << p->data << ' ';
        cout << '\n';
    }

    bool bothEndsNull() const { return front == nullptr && rear == nullptr; }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    LinkedQueue q;
    int value = 0;
    string order;

    cout << "== Enqueue 10, 20, 30, 40, 50, 60 (no capacity limit) ==\n";
    for (int v : {10, 20, 30, 40, 50, 60}) q.enqueue(v);
    q.display();

    cout << "\n== Dequeue everything ==\n";
    while (q.dequeue(value)) {
        order += to_string(value) + ' ';
        cout << "dequeued " << value << "  ";
        q.display();
    }
    check("FIFO: values left in arrival order", order == "10 20 30 40 50 60 ");
    check("dequeuing the final node reset both front and rear to null", q.bothEndsNull());
    check("dequeue on an empty queue is refused", !q.dequeue(value));

    cout << "\n== The queue is usable again after emptying ==\n";
    q.enqueue(70);
    q.display();
    check("a new node becomes both front and rear", !q.isEmpty());
    return 0;
}
