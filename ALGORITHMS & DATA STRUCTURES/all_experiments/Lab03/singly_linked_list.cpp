// Lab 3 - Singly and doubly linked lists
// Part A: a singly linked list from scratch - create, append and insert at a
// position, display, search, and delete by value - tested at the head, the
// tail, a middle position, and on empty and one-node lists.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra singly_linked_list.cpp -o singly_linked_list
//     ./singly_linked_list

#include <cstddef>
#include <iostream>
#include <string>
using namespace std;

struct Node {
    int data;
    Node* next;

    // Counts nodes that are allocated and not yet deleted, so the program can
    // show that every deleted node is really released.
    static int live;
    static void* operator new(size_t size) { ++live; return ::operator new(size); }
    static void operator delete(void* p) { --live; ::operator delete(p); }
};
int Node::live = 0;

void display(Node* head) {
    if (head == nullptr) { cout << "(empty)\n"; return; }
    Node* current = head;
    while (current != nullptr) {
        cout << current->data << ' ';
        current = current->next;
    }
    cout << '\n';
}

void pushFront(Node*& head, int value) {
    Node* n = new Node{value, head};
    head = n;
}

void append(Node*& head, int value) {
    Node* n = new Node{value, nullptr};
    if (head == nullptr) { head = n; return; }
    Node* current = head;
    while (current->next != nullptr) current = current->next;
    current->next = n;
}

// Insert so the new value ends up at 0-based position. Position 0 is the
// head; position == size appends. Anything beyond the end is refused.
bool insertAt(Node*& head, int position, int value) {
    if (position < 0) return false;
    if (position == 0) { pushFront(head, value); return true; }

    Node* before = head;                      // the node that will precede it
    for (int i = 0; i < position - 1 && before != nullptr; ++i) before = before->next;
    if (before == nullptr) return false;

    before->next = new Node{value, before->next};
    return true;
}

// 0-based position of the first node holding value, or -1.
int search(Node* head, int value) {
    int position = 0;
    for (Node* current = head; current != nullptr; current = current->next, ++position)
        if (current->data == value) return position;
    return -1;
}

bool deleteValue(Node*& head, int value) {
    if (head == nullptr) return false;

    if (head->data == value) {
        Node* old = head;
        head = head->next;
        delete old;
        return true;
    }

    Node* current = head;
    while (current->next != nullptr &&
           current->next->data != value) {
        current = current->next;
    }

    if (current->next == nullptr) return false;

    Node* old = current->next;
    current->next = old->next;
    delete old;
    return true;
}

void destroy(Node*& head) {
    while (head != nullptr) {
        Node* old = head;
        head = head->next;
        delete old;
    }
}

string contents(Node* head) {
    string s;
    for (Node* p = head; p != nullptr; p = p->next) s += to_string(p->data) + ' ';
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    Node* head = nullptr;

    cout << "== Empty list ==\n";
    display(head);
    check("search on an empty list reports not found", search(head, 10) == -1);
    check("delete on an empty list is refused without touching a null pointer",
          !deleteValue(head, 10) && head == nullptr);

    cout << "\n== One-node list ==\n";
    append(head, 10);
    display(head);
    check("deleting the only node leaves an empty list",
          deleteValue(head, 10) && head == nullptr);

    cout << "\n== Build 10 15 20 30 40 ==\n";
    append(head, 20);                 // 20
    append(head, 30);                 // 20 30
    pushFront(head, 10);              // 10 20 30          (insert at the head)
    insertAt(head, 1, 15);            // 10 15 20 30       (insert in the middle)
    insertAt(head, 4, 40);            // 10 15 20 30 40    (insert at the tail)
    display(head);
    check("insertion at head, middle and tail gives 10 15 20 30 40",
          contents(head) == "10 15 20 30 40 ");
    check("insert beyond the end is refused", !insertAt(head, 9, 99));

    cout << "\n== Search ==\n";
    cout << "search(30) -> position " << search(head, 30) << '\n';
    cout << "search(99) -> " << search(head, 99) << " (not found)\n";
    check("a stored value is found at its position", search(head, 30) == 3);
    check("a missing value reports not found", search(head, 99) == -1);

    cout << "\n== Delete by value ==\n";
    deleteValue(head, 10);  cout << "delete 10 (head):   "; display(head);
    check("deleting the head moves head to the next node", head != nullptr && head->data == 15);
    deleteValue(head, 20);  cout << "delete 20 (middle): "; display(head);
    deleteValue(head, 40);  cout << "delete 40 (tail):   "; display(head);
    check("after head, middle and tail deletions the list is 15 30",
          contents(head) == "15 30 ");
    check("deleting a missing value is refused", !deleteValue(head, 99));
    check("live nodes equal list length (deleted nodes were released)", Node::live == 2);

    destroy(head);
    check("destroying the list releases every node", Node::live == 0 && head == nullptr);
    return 0;
}
