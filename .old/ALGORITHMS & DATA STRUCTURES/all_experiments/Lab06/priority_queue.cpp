// Lab 6 - Linear, linked, circular, and priority queues
// Extension: a priority queue on an array of (value, priority) items that
// follows the lab manual's two rules:
//   1. an element of higher priority is processed before one of lower priority;
//   2. elements of equal priority are processed in the order they were added.
//
// Design choices the manual leaves open, stated here:
//   - a LARGER number means a HIGHER priority;
//   - the array is kept sorted on insertion, so dequeue simply takes the front.
//     A new item is placed after every item whose priority is >= its own,
//     which is exactly what keeps equal priorities in arrival order (rule 2).
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra priority_queue.cpp -o priority_queue
//     ./priority_queue

#include <iostream>
#include <string>
using namespace std;

struct Item {
    string value;
    int priority;
};

class PriorityQueue {
private:
    static const int CAP = 10;
    Item items[CAP];
    int count = 0;

public:
    bool isEmpty() const { return count == 0; }
    bool isFull() const { return count == CAP; }

    bool enqueue(const string& value, int priority) {
        if (isFull()) return false;
        int pos = count;
        while (pos > 0 && items[pos - 1].priority < priority) {   // strictly lower moves back
            items[pos] = items[pos - 1];
            --pos;
        }
        items[pos] = {value, priority};
        ++count;
        return true;
    }

    bool dequeue(Item& out) {
        if (isEmpty()) return false;
        out = items[0];
        for (int i = 1; i < count; ++i) items[i - 1] = items[i];
        --count;
        return true;
    }

    void display() const {
        cout << "  queue (front first): ";
        if (isEmpty()) cout << "(empty)";
        for (int i = 0; i < count; ++i)
            cout << items[i].value << "/p" << items[i].priority << ' ';
        cout << '\n';
    }
};

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    PriorityQueue pq;

    cout << "== Arrivals (value, priority) ==\n";
    const Item arrivals[] = {{"A", 2}, {"B", 5}, {"C", 2}, {"D", 5}, {"E", 1}, {"F", 3}};
    for (const Item& it : arrivals) {
        pq.enqueue(it.value, it.priority);
        cout << "enqueue " << it.value << " (priority " << it.priority << ")\n";
        pq.display();
    }

    cout << "\n== Processing order ==\n";
    string order;
    Item out;
    while (pq.dequeue(out)) {
        cout << "  process " << out.value << " (priority " << out.priority << ")\n";
        order += out.value;
    }
    cout << "order: " << order << '\n';

    check("rule 1: higher priorities first (B, D at 5 before F at 3 before A, C at 2 before E)",
          order == "BDFACE");
    check("rule 2: equal priorities keep arrival order (B before D, A before C)",
          order.find('B') < order.find('D') && order.find('A') < order.find('C'));
    check("dequeue from an empty priority queue is refused", !pq.dequeue(out));
    return 0;
}
