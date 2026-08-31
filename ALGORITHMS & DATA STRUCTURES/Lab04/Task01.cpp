// Lab 4, Task 1 --- Circular doubly linked list.
//
// Every node points both ways, and the two ends are joined:
//
//     +-----------------------------------------------+
//     v                                               |
//   [Aimar] <-> [Anjana] <-> [Jessy] <-> [Jane] <------+
//     ^                                        |
//     +----------------------------------------+
//
// Two invariants make everything else simple:
//   * head->prev is ALWAYS the tail, so the last node is O(1) away.
//   * No pointer in the list is ever nullptr. An empty list is head == nullptr,
//     and that is the only place nullptr appears.
//
// The second invariant is what makes traversal different from a normal list.
// You cannot stop at nullptr because you will never reach one --- you stop
// when you arrive back at head. Every loop below is written that way.
//
// Build: g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01

#include <iostream>
#include <string>

using namespace std;

class Node {
public:
    string name;
    Node* next;
    Node* prev;

    explicit Node(const string& n) : name(n), next(nullptr), prev(nullptr) {}
};

class CircularList {
private:
    Node* head;

    // Find a node by name, or nullptr. Written once so no caller has to
    // re-derive the "stop when you get back to head" condition.
    Node* find(const string& name) const {
        if (head == nullptr) return nullptr;

        Node* current = head;
        do {
            if (current->name == name) return current;
            current = current->next;
        } while (current != head);

        return nullptr;
    }

public:
    CircularList() : head(nullptr) {}

    ~CircularList() {
        if (head == nullptr) return;

        // Break the ring first. Deleting round a still-circular list means
        // the loop condition compares against a node that has already been
        // freed, which is undefined behaviour.
        Node* tail = head->prev;
        tail->next = nullptr;

        Node* current = head;
        while (current != nullptr) {
            Node* temp = current;
            current = current->next;
            delete temp;
        }
        head = nullptr;
    }

    CircularList(const CircularList&)            = delete;
    CircularList& operator=(const CircularList&) = delete;

    bool isEmpty() const { return head == nullptr; }

    void insertEnd(const string& name) {
        Node* newNode = new Node(name);

        if (head == nullptr) {
            // A one-node ring points at itself in both directions.
            head = newNode;
            newNode->next = newNode;
            newNode->prev = newNode;
            return;
        }

        Node* tail = head->prev;   // O(1), thanks to the invariant

        newNode->prev = tail;
        newNode->next = head;
        tail->next    = newNode;
        head->prev    = newNode;   // the new node is the tail now
    }

    void insertAfter(const string& afterName, const string& newName) {
        Node* current = find(afterName);

        // The original code looked for the target with
        //     while (current != nullptr && current->name != afterName)
        // which never terminates on a circular list when the name is absent:
        // current cycles forever and never becomes nullptr. find() stops
        // after one full lap instead.
        if (current == nullptr) {
            cout << afterName << " not found.\n";
            return;
        }

        Node* newNode = new Node(newName);
        Node* after   = current->next;   // never nullptr in a ring

        // Set the new node's links first, then redirect its neighbours.
        // Doing it the other way round overwrites the pointer you still
        // need to read.
        newNode->prev = current;
        newNode->next = after;
        current->next = newNode;
        after->prev   = newNode;
    }

    void deleteByName(const string& name) {
        Node* target = find(name);
        if (target == nullptr) {
            cout << name << " not found.\n";
            return;
        }

        // Only one node left: the list becomes empty.
        if (target->next == target) {
            delete target;
            head = nullptr;
            return;
        }

        // Unlink by joining the two neighbours to each other. Because the
        // list is circular this single pair of assignments is correct even
        // when the target is the head or the tail --- there is no end of
        // the list to special-case.
        target->prev->next = target->next;
        target->next->prev = target->prev;

        // The one thing that DOES need care: if we removed the head, the
        // head pointer itself must move. The original code instead set
        // head->prev = nullptr here, which cut the ring open and broke
        // every later insertEnd() and displayReverse().
        if (target == head) {
            head = target->next;
        }

        delete target;
    }

    void display() const {
        if (head == nullptr) {
            cout << "The list is empty.\n";
            return;
        }

        // do-while, not while: the condition is "back at head", which is
        // true before the first node has been printed.
        Node* current = head;
        do {
            cout << current->name;
            current = current->next;
            if (current != head) cout << " <-> ";
        } while (current != head);
        cout << "  (circular)\n";
    }

    void displayReverse() const {
        if (head == nullptr) {
            cout << "The list is empty.\n";
            return;
        }

        Node* tail = head->prev;
        Node* current = tail;
        do {
            cout << current->name;
            current = current->prev;
            if (current != tail) cout << " <-> ";
        } while (current != tail);
        cout << "  (circular, reversed)\n";
    }
};

int main() {
    CircularList list;

    cout << "-- Build the list --\n";
    list.insertEnd("Aimar");
    list.insertEnd("Anjana");
    list.insertEnd("Jessy");
    list.display();

    cout << "\n-- Insert Ali after Anjana --\n";
    list.insertAfter("Anjana", "Ali");
    list.display();

    cout << "\n-- Insert after a name that is not present (used to hang) --\n";
    list.insertAfter("Nobody", "Ghost");

    cout << "\n-- Insert Jane at the end --\n";
    list.insertEnd("Jane");
    list.display();

    cout << "\n-- Delete Jessy (a middle node) --\n";
    list.deleteByName("Jessy");
    list.display();

    cout << "\n-- Delete Aimar (the head) --\n";
    list.deleteByName("Aimar");
    list.display();
    cout << "still traversable backwards, so the ring is intact:\n";
    list.displayReverse();

    cout << "\n-- Append after deleting the head --\n";
    list.insertEnd("Zara");
    list.display();

    cout << "\n-- Delete everything --\n";
    list.deleteByName("Anjana");
    list.deleteByName("Ali");
    list.deleteByName("Jane");
    list.deleteByName("Zara");
    list.display();
    list.deleteByName("Zara");   // already gone

    return 0;
}
