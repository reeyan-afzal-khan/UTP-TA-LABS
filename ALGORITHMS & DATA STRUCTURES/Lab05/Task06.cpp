// Lab 5, Task 6 --- Priority queue (lab-manual extension).
//
//   enqueue(value, priority); dequeue() always removes the item with the
//   highest priority, and equal-priority items keep their arrival order
//   (a "stable" priority queue --- the fairness rule from the manual).
//
// Implemented as an ordered linked list: enqueue walks past every node whose
// priority is >= the new one, so the head is always the next item to serve.
// enqueue is O(n); dequeue and peek are O(1). (A binary heap flips that
// trade to O(log n)/O(log n) and appears again in Lab 6 Task 3.)
//
// Convention used here: LARGER number = HIGHER priority. If your instructor
// uses "priority 1 is most urgent", flip the comparison marked below.
//
// Build: g++ -std=c++17 -Wall -Wextra Task06.cpp -o task06

#include <iostream>
#include <string>

using namespace std;

struct PNode {
    string value;
    int priority;
    PNode* next;
};

class PriorityQueue {
private:
    PNode* head;

public:
    PriorityQueue() : head(nullptr) {}

    ~PriorityQueue() {
        while (head != nullptr) {
            PNode* temp = head;
            head = head->next;
            delete temp;
        }
    }

    PriorityQueue(const PriorityQueue&)            = delete;
    PriorityQueue& operator=(const PriorityQueue&) = delete;

    bool isEmpty() const { return head == nullptr; }

    void enqueue(const string& value, int priority) {
        PNode* n = new PNode{value, priority, nullptr};

        // Walk past strictly-higher AND equal priorities: stopping only at a
        // strictly lower one is what keeps equal-priority items in FIFO order.
        // (Flip '>=' to '<=' for a "smaller number = more urgent" scheme.)
        if (head == nullptr || n->priority > head->priority) {
            n->next = head;
            head = n;
            return;
        }
        PNode* current = head;
        while (current->next != nullptr &&
               current->next->priority >= n->priority) {
            current = current->next;
        }
        n->next = current->next;
        current->next = n;
    }

    void dequeue() {
        if (isEmpty()) {
            cout << "Queue is empty, nothing to serve.\n";
            return;
        }
        PNode* temp = head;
        cout << "Serving " << temp->value
             << " (priority " << temp->priority << ")\n";
        head = head->next;
        delete temp;
    }

    void display() const {
        if (isEmpty()) { cout << "Queue is empty.\n"; return; }
        cout << "next to serve -> ";
        for (PNode* c = head; c != nullptr; c = c->next) {
            cout << c->value << '(' << c->priority << ')';
            if (c->next != nullptr) cout << ", ";
        }
        cout << '\n';
    }
};

int main() {
    PriorityQueue pq;

    cout << "-- Mixed priorities arrive out of order --\n";
    pq.enqueue("email",  1);
    pq.enqueue("page",   5);
    pq.enqueue("backup", 1);   // same priority as email, arrived later
    pq.enqueue("alarm",  5);   // same priority as page, arrived later
    pq.enqueue("report", 3);
    pq.display();

    cout << "\n-- Serve everything --\n";
    while (!pq.isEmpty()) pq.dequeue();
    // page before alarm, and email before backup: ties kept arrival order.

    cout << "\n-- Underflow is handled --\n";
    pq.dequeue();

    return 0;
}
