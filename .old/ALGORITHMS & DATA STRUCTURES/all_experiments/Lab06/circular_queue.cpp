// Lab 6 - Linear, linked, circular, and priority queues
// A circular queue on an array of 5: front and rear move with modulo
// arithmetic, so slots freed by dequeue are reused. The state - front, rear,
// count, and every slot - is printed after each operation.
//
// Full versus empty: front == rear happens BOTH when the queue is empty and
// when it is full, so this queue keeps a separate count to tell them apart.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra circular_queue.cpp -o circular_queue
//     ./circular_queue

#include <iostream>
#include <string>
using namespace std;

class CircularQueue {
private:
    static const int CAP = 5;
    int data[CAP];
    bool used[CAP] = {};      // only for printing which slots hold a value
    int front = 0;
    int rear = 0;
    int count = 0;

public:
    bool isEmpty() const { return count == 0; }
    bool isFull() const { return count == CAP; }
    int frontIndex() const { return front; }
    int rearIndex() const { return rear; }

    bool enqueue(int value) {
        if (isFull()) return false;
        data[rear] = value;
        used[rear] = true;
        rear = (rear + 1) % CAP;
        ++count;
        return true;
    }

    bool dequeue(int& value) {
        if (isEmpty()) return false;
        value = data[front];
        used[front] = false;
        front = (front + 1) % CAP;
        --count;
        return true;
    }

    void state(const string& step) const {
        cout << step;
        for (size_t i = step.size(); i < 16; ++i) cout << ' ';
        cout << "front=" << front << " rear=" << rear << " count=" << count << "   slots: [";
        for (int i = 0; i < CAP; ++i) {
            if (used[i]) cout << data[i];
            else cout << '-';
            if (i < CAP - 1) cout << ' ';
        }
        cout << "]" << (isFull() ? "  FULL" : isEmpty() ? "  EMPTY" : "") << '\n';
    }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    CircularQueue q;
    int value = 0;
    string order;

    cout << "== The lab trace (capacity 5) ==\n";
    q.state("start");
    for (int v : {10, 20, 30, 40}) { q.enqueue(v); q.state("enqueue " + to_string(v)); }
    for (int i = 0; i < 2; ++i) {
        q.dequeue(value); order += to_string(value) + ' ';
        q.state("dequeue -> " + to_string(value));
    }
    q.enqueue(50); q.state("enqueue 50");
    check("rear wrapped from index 4 back to index 0", q.rearIndex() == 0);
    q.enqueue(60); q.state("enqueue 60");
    check("60 was stored in slot 0, a slot freed by an earlier dequeue", q.rearIndex() == 1);

    cout << "\n== Fill to capacity, then empty it ==\n";
    q.enqueue(70); q.state("enqueue 70");
    check("full: count == 5 even though front == rear", q.isFull() && q.frontIndex() == q.rearIndex());
    check("an enqueue into a full queue is refused", !q.enqueue(80));
    while (q.dequeue(value)) {
        order += to_string(value) + ' ';
        q.state("dequeue -> " + to_string(value));
    }
    check("empty: count == 0 with front == rear again, so count separates the two",
          q.isEmpty() && q.frontIndex() == q.rearIndex());
    check("FIFO order kept across the wrap: 10 20 30 40 50 60 70",
          order == "10 20 30 40 50 60 70 ");
    check("a dequeue from an empty queue is refused", !q.dequeue(value));
    return 0;
}
