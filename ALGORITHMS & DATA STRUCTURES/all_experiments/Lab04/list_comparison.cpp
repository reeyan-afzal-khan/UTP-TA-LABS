// Lab 4 - Circular linked-list operations
// The "Try it yourself" comparison: feed the same input sequence to a singly,
// a doubly, and a circular linked list, then compare how each traversal stops
// and how many pointer fields each node carries.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra list_comparison.cpp -o list_comparison
//     ./list_comparison

#include <iomanip>
#include <iostream>
#include <vector>
using namespace std;

struct Node  { int data; Node* next; };                // singly and circular
struct DNode { int data; DNode* prev; DNode* next; };  // doubly

int main() {
    const vector<int> input = {10, 20, 30, 40};

    // Singly: head, append at the end, the last node points to nullptr.
    Node* sHead = nullptr;
    Node* sTail = nullptr;
    for (int v : input) {
        Node* n = new Node{v, nullptr};
        if (sHead == nullptr) sHead = sTail = n;
        else { sTail->next = n; sTail = n; }
    }

    // Doubly: head and tail, each node also points back.
    DNode* dHead = nullptr;
    DNode* dTail = nullptr;
    for (int v : input) {
        DNode* n = new DNode{v, dTail, nullptr};
        if (dTail == nullptr) dHead = dTail = n;
        else { dTail->next = n; dTail = n; }
    }

    // Circular: only `last` is kept; last->next is the head.
    Node* last = nullptr;
    for (int v : input) {
        Node* n = new Node{v, nullptr};
        if (last == nullptr) { n->next = n; last = n; }
        else { n->next = last->next; last->next = n; last = n; }
    }

    cout << "Input sequence: 10 20 30 40\n\n";

    cout << "Singly, head forward to nullptr:   ";
    for (Node* p = sHead; p != nullptr; p = p->next) cout << p->data << ' ';
    cout << "\nDoubly, head forward to nullptr:   ";
    for (DNode* p = dHead; p != nullptr; p = p->next) cout << p->data << ' ';
    cout << "\nDoubly, tail backward to nullptr:  ";
    for (DNode* p = dTail; p != nullptr; p = p->prev) cout << p->data << ' ';
    cout << "\nCircular, head round to head:      ";
    Node* head = last->next;
    Node* p = head;
    do { cout << p->data << ' '; p = p->next; } while (p != head);
    cout << "\nCircular, two laps, no stop test:  ";
    p = head;
    for (int i = 0; i < 2 * static_cast<int>(input.size()); ++i) { cout << p->data << ' '; p = p->next; }
    cout << "\n\n";

    cout << left << setw(26) << "" << setw(18) << "Singly" << setw(18) << "Doubly" << "Circular\n";
    cout << setw(26) << "pointer fields per node" << setw(18) << "1 (next)" << setw(18) << "2 (prev, next)" << "1 (next)\n";
    cout << setw(26) << "bytes per node here" << setw(18) << sizeof(Node) << setw(18) << sizeof(DNode) << sizeof(Node) << '\n';
    cout << setw(26) << "last node's next" << setw(18) << "nullptr" << setw(18) << "nullptr" << "the head\n";
    cout << setw(26) << "traversal stops when" << setw(18) << "p == nullptr" << setw(18) << "p == nullptr" << "p == head again\n";
    cout << setw(26) << "walk backwards?" << setw(18) << "no" << setw(18) << "yes, via prev" << "no\n";
    cout << setw(26) << "reach head from the end" << setw(18) << "no" << setw(18) << "via prev" << "one step: last->next\n";

    // Release everything.
    while (sHead != nullptr) { Node* old = sHead; sHead = sHead->next; delete old; }
    while (dHead != nullptr) { DNode* old = dHead; dHead = dHead->next; delete old; }
    Node* q = last->next;
    last->next = nullptr;                      // open the ring, then delete as a plain list
    while (q != nullptr) { Node* old = q; q = q->next; delete old; }
    return 0;
}
