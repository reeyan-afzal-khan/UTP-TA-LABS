// Lab 4 - Circular linked-list operations
// A singly circular linked list kept through its LAST node: insertion at the
// beginning and end, deletion from the beginning and end, deletion by value,
// and display. After every mutation the program checks that the last node
// still points to the head, so the ring is never broken.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra circular_linked_list.cpp -o circular_linked_list
//     ./circular_linked_list

#include <cstddef>
#include <iostream>
#include <string>
using namespace std;

struct Node {
    int data;
    Node* next;

    // Counts nodes that are allocated and not yet deleted.
    static int live;
    static void* operator new(size_t size) { ++live; return ::operator new(size); }
    static void operator delete(void* p) { --live; ::operator delete(p); }
};
int Node::live = 0;

void displayCircular(Node* last) {
    if (last == nullptr) return;
    Node* head = last->next;
    Node* p = head;
    do {
        cout << p->data << ' ';
        p = p->next;
    } while (p != head);
}

void insertBeginning(Node*& last, int value) {
    Node* n = new Node{value, nullptr};

    if (last == nullptr) {
        n->next = n;
        last = n;
        return;
    }

    n->next = last->next;
    last->next = n;
}

void insertEnd(Node*& last, int value) {
    Node* n = new Node{value, nullptr};

    if (last == nullptr) {
        n->next = n;
        last = n;
        return;
    }

    n->next = last->next;  // new node points to head
    last->next = n;        // old last points to new node
    last = n;              // new node becomes last
}

bool deleteBeginning(Node*& last) {
    if (last == nullptr) return false;

    Node* head = last->next;
    if (head == last) {
        delete head;
        last = nullptr;
        return true;
    }

    last->next = head->next;
    delete head;
    return true;
}

bool deleteEnd(Node*& last) {
    if (last == nullptr) return false;

    Node* head = last->next;
    if (head == last) {
        delete last;
        last = nullptr;
        return true;
    }

    Node* current = head;
    while (current->next != last) {
        current = current->next;
    }

    current->next = head;
    delete last;
    last = current;
    return true;
}

bool deleteValue(Node*& last, int value) {
    if (last == nullptr) return false;

    Node* prev = last;
    Node* current = last->next;  // head

    do {
        if (current->data == value) {
            if (current == prev) {      // one-node list
                delete current;
                last = nullptr;
            } else {
                prev->next = current->next;
                if (current == last) last = prev;
                delete current;
            }
            return true;
        }
        prev = current;
        current = current->next;
    } while (current != last->next);

    return false;
}

void destroy(Node*& last) {
    while (deleteBeginning(last)) {}
}

// The ring is intact when walking from the head returns to the head within
// as many steps as there are live nodes, and the node just before the head
// is `last`.
bool ringIntact(Node* last) {
    if (last == nullptr) return Node::live == 0;
    Node* head = last->next;
    Node* p = head;
    Node* before = last;
    for (int steps = 0; steps <= Node::live; ++steps) {
        before = p;
        p = p->next;
        if (p == head) return before == last;
    }
    return false;
}

string contents(Node* last) {
    if (last == nullptr) return "";
    string s;
    Node* p = last->next;
    do { s += to_string(p->data) + ' '; p = p->next; } while (p != last->next);
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void show(const string& step, Node* last) {
    cout << step << ": ";
    if (last == nullptr) cout << "(empty)";
    else displayCircular(last);
    cout << '\n';
    check("last node still points to the head", ringIntact(last));
}

int main() {
    Node* last = nullptr;

    cout << "== Empty and one-node lists ==\n";
    show("empty", last);
    check("deleting from an empty list is refused",
          !deleteBeginning(last) && !deleteEnd(last) && !deleteValue(last, 1));
    insertEnd(last, 1);
    show("insert 1 at the end", last);
    check("a single node points to itself", last->next == last);
    deleteEnd(last);
    show("delete from the end (one node)", last);

    cout << "\n== Insertions ==\n";
    insertEnd(last, 20);        show("insert 20 at the end", last);
    insertEnd(last, 30);        show("insert 30 at the end", last);
    insertBeginning(last, 10);  show("insert 10 at the beginning", last);
    insertEnd(last, 40);        show("insert 40 at the end", last);
    insertBeginning(last, 5);   show("insert 5 at the beginning", last);
    check("the ring holds 5 10 20 30 40", contents(last) == "5 10 20 30 40 ");

    cout << "\n== Deletions ==\n";
    deleteBeginning(last);      show("delete from the beginning", last);
    deleteEnd(last);            show("delete from the end", last);
    deleteValue(last, 10);      show("delete value 10 (the head)", last);
    insertEnd(last, 25);        show("insert 25 at the end", last);
    deleteValue(last, 30);      show("delete value 30 (a middle node)", last);
    deleteValue(last, 25);      show("delete value 25 (the last node)", last);
    check("last moved back to 20 when the last node was deleted", last->data == 20);
    check("deleting a missing value is refused", !deleteValue(last, 99));

    cout << "\nTraversal stops when it comes back to the head (do ... while p != head),\n"
         << "never at nullptr: a circular list has no null pointer to stop at.\n";

    destroy(last);
    check("destroying the list releases every node", Node::live == 0 && last == nullptr);
    return 0;
}
