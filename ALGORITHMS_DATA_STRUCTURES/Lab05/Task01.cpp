// Lab 5, Task 1 --- Queue implemented with a fixed-size circular array.
//
// A queue is FIFO: the first item enqueued is the first dequeued.
// enqueue() adds at the rear, dequeue() removes from the front.
//
// Why circular? A plain array queue walks front and rear forward forever,
// so after CAPACITY operations it runs off the end even when the array is
// mostly empty. Advancing the indices modulo CAPACITY lets them wrap around
// and reuse the space at the start.
//
// Build: g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01

#include <iostream>
#include <string>

using namespace std;

class Queue {
private:
    static const int CAPACITY = 5;  // small, so wrap-around is easy to observe

    string arr[CAPACITY];
    int front;  // index of the first item
    int count;  // how many items are stored

    // Deriving rear from front and count keeps a single source of truth.
    // Tracking front and rear as two independent indices is what makes the
    // "is it empty or is it full?" question ambiguous, because front == rear
    // is true in both cases.
    int rearIndex() const { return (front + count - 1) % CAPACITY; }

public:
    Queue() : front(0), count(0) {}

    bool isEmpty() const { return count == 0; }
    bool isFull()  const { return count == CAPACITY; }
    int  size()    const { return count; }

    void enqueue(const string& name) {
        // Check before writing, never after. Writing first and checking
        // afterwards has already corrupted memory by the time you notice.
        if (isFull()) {
            cout << "Queue is full, cannot enqueue " << name << ".\n";
            return;
        }

        int rear = (front + count) % CAPACITY;  // first free slot
        arr[rear] = name;
        count++;
    }

    void dequeue() {
        if (isEmpty()) {
            cout << "Queue is empty, nothing to dequeue.\n";
            return;
        }

        cout << arr[front] << " is dequeued.\n";

        // Advance front with wrap-around, then shrink the count.
        // Because emptiness is count == 0, draining the queue leaves it in
        // exactly the state the constructor produced --- so the next
        // enqueue() behaves identically to the very first one.
        front = (front + 1) % CAPACITY;
        count--;
    }

    // peek() reads the front without removing it.
    void peek() const {
        if (isEmpty()) {
            cout << "Queue is empty, nothing to peek.\n";
            return;
        }
        cout << "Front is " << arr[front] << ".\n";
    }

    void display() const {
        if (isEmpty()) {
            cout << "Queue is empty.\n";
            return;
        }

        cout << "front -> ";
        // Step i places forward from front, wrapping at the array end.
        for (int i = 0; i < count; i++) {
            cout << arr[(front + i) % CAPACITY];
            if (i < count - 1) cout << ", ";
        }
        cout << " <- rear   (front=" << front
             << ", rear=" << rearIndex()
             << ", count=" << count << ")\n";
    }
};

int main() {
    Queue q;

    cout << "-- Fill the queue --\n";
    q.enqueue("Aimar");
    q.enqueue("Ahmad");
    q.enqueue("Anjana");
    q.display();
    q.peek();

    cout << "\n-- Dequeue twice --\n";
    q.dequeue();
    q.dequeue();
    q.display();

    cout << "\n-- Enqueue past the end of the array to show wrap-around --\n";
    q.enqueue("Bala");
    q.enqueue("Chen");
    q.enqueue("Devi");
    q.enqueue("Eshan");
    q.display();   // rear has wrapped to a lower index than front

    cout << "\n-- Overflow: the queue is now full --\n";
    q.enqueue("Farid");

    cout << "\n-- Underflow: drain it completely, then dequeue once more --\n";
    while (!q.isEmpty()) {
        q.dequeue();
    }
    q.display();
    q.dequeue();

    cout << "\n-- Reuse after draining --\n";
    q.enqueue("Gita");
    q.display();

    return 0;
}
