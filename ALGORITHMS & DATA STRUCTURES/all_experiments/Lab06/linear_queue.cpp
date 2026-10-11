// Lab 6 - Linear, linked, circular, and priority queues
// A linear queue on a fixed-size array: enqueue at rear, dequeue at front.
// It preserves FIFO order, but front only ever moves right, so slots freed by
// dequeue are never reused - the reason the circular queue exists.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra linear_queue.cpp -o linear_queue
//     ./linear_queue

#include <iostream>
#include <string>
using namespace std;

class LinearQueue {
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

    void display() const {
        cout << "front=" << front << " rear=" << rear << "  queue: ";
        if (isEmpty()) cout << "(empty)";
        for (int i = front; i <= rear; ++i) cout << data[i] << ' ';
        cout << '\n';
    }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    LinearQueue q;
    int value = 0;
    string order;

    cout << "== Enqueue 10, 20, 30 ==\n";
    for (int v : {10, 20, 30}) { q.enqueue(v); q.display(); }

    cout << "\n== Dequeue twice ==\n";
    q.dequeue(value); order += to_string(value) + ' '; cout << "dequeued " << value << "  "; q.display();
    q.dequeue(value); order += to_string(value) + ' '; cout << "dequeued " << value << "  "; q.display();
    check("FIFO: values leave in the order they arrived (10 then 20)", order == "10 20 ");

    cout << "\n== Enqueue 40, 50, 60 ==\n";
    for (int v : {40, 50, 60}) {
        bool ok = q.enqueue(v);
        cout << "enqueue " << v << (ok ? " -> ok      " : " -> refused ");
        q.display();
    }
    check("the queue reports full with only three items: slots 0 and 1 are wasted",
          q.isFull() && !q.enqueue(70));

    cout << "\n== Dequeue until empty ==\n";
    while (q.dequeue(value)) order += to_string(value) + ' ';
    q.display();
    check("every value left in arrival order", order == "10 20 30 40 50 ");
    check("dequeue on an empty queue is refused", !q.dequeue(value));
    return 0;
}
