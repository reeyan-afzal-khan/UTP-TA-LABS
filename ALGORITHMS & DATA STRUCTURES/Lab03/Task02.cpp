// Lab 3, Task 2 --- Doubly linked list.
//
//   nullptr <- [Aimar] <-> [Anjana] <-> [Jessy] -> nullptr
//
// Each node now carries TWO pointers, so the list can be walked in either
// direction and a node can reach its predecessor without a second traversal.
// The price is bookkeeping: every insertion or deletion must fix up to four
// pointers instead of two, and forgetting one of them is the classic bug ---
// the invariant to protect is  x->next->prev == x  wherever both nodes exist.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

#include <iostream>
#include <string>

using namespace std;

class DNode {
public:
    string name;
    DNode* prev;
    DNode* next;

    explicit DNode(const string& n) : name(n), prev(nullptr), next(nullptr) {}
};

class DoublyLinkedList {
private:
    DNode* head;
    DNode* tail;   // kept so append and backward traversal are O(1) to start

public:
    DoublyLinkedList() : head(nullptr), tail(nullptr) {}

    ~DoublyLinkedList() {
        DNode* current = head;
        while (current != nullptr) {
            DNode* temp = current;
            current = current->next;
            delete temp;
        }
        head = tail = nullptr;
    }

    DoublyLinkedList(const DoublyLinkedList&)            = delete;
    DoublyLinkedList& operator=(const DoublyLinkedList&) = delete;

    bool isEmpty() const { return head == nullptr; }

    void insertFront(const string& name) {
        DNode* n = new DNode(name);
        n->next = head;
        if (head != nullptr) head->prev = n;
        else tail = n;                    // first node is also the tail
        head = n;
    }

    void insertEnd(const string& name) {
        DNode* n = new DNode(name);
        n->prev = tail;
        if (tail != nullptr) tail->next = n;
        else head = n;                    // first node is also the head
        tail = n;
    }

    // Insert newName immediately after the node holding afterName.
    void insertAfter(const string& afterName, const string& newName) {
        DNode* current = head;
        while (current != nullptr && current->name != afterName) {
            current = current->next;
        }
        if (current == nullptr) {
            cout << afterName << " not found.\n";
            return;
        }

        DNode* n = new DNode(newName);
        n->prev = current;
        n->next = current->next;
        if (current->next != nullptr) current->next->prev = n;
        else tail = n;                    // inserted after the old tail
        current->next = n;
    }

    // Search returns the position (1-based) so "found" and "where" come
    // from a single traversal.
    int find(const string& name) const {
        int pos = 1;
        for (DNode* c = head; c != nullptr; c = c->next, ++pos)
            if (c->name == name) return pos;
        return -1;
    }

    void deleteByName(const string& name) {
        DNode* current = head;
        while (current != nullptr && current->name != name) {
            current = current->next;
        }
        if (current == nullptr) {
            cout << name << " not found.\n";
            return;
        }

        // Route around the node in both directions. Whichever neighbour is
        // missing means the head or tail pointer itself must move.
        if (current->prev != nullptr) current->prev->next = current->next;
        else head = current->next;

        if (current->next != nullptr) current->next->prev = current->prev;
        else tail = current->prev;

        delete current;
    }

    void displayForward() const {
        if (isEmpty()) { cout << "The list is empty.\n"; return; }
        for (DNode* c = head; c != nullptr; c = c->next) {
            cout << c->name;
            if (c->next != nullptr) cout << " <-> ";
        }
        cout << '\n';
    }

    void displayBackward() const {
        if (isEmpty()) { cout << "The list is empty.\n"; return; }
        for (DNode* c = tail; c != nullptr; c = c->prev) {
            cout << c->name;
            if (c->prev != nullptr) cout << " <-> ";
        }
        cout << "   (reversed)\n";
    }

    // Verifies the invariant x->next->prev == x across the whole list.
    bool linksConsistent() const {
        for (DNode* c = head; c != nullptr && c->next != nullptr; c = c->next)
            if (c->next->prev != c) return false;
        return true;
    }
};

int main() {
    DoublyLinkedList list;

    cout << "-- Build the list (front + end insertions) --\n";
    list.insertEnd("Anjana");
    list.insertFront("Aimar");     // head insertion
    list.insertEnd("Jessy");       // tail insertion
    list.displayForward();
    list.displayBackward();

    cout << "\n-- Insert Ali after Anjana (middle insertion) --\n";
    list.insertAfter("Anjana", "Ali");
    list.displayForward();

    cout << "\n-- Search --\n";
    int pos = list.find("Ali");
    cout << "Ali is at position " << pos << ".\n";
    if (list.find("Nobody") == -1) cout << "Nobody not found.\n";

    cout << "\n-- Delete Jessy (tail), then Aimar (head) --\n";
    list.deleteByName("Jessy");
    list.deleteByName("Aimar");
    list.displayForward();
    list.displayBackward();
    cout << "prev/next links consistent: "
         << (list.linksConsistent() ? "yes" : "NO") << '\n';

    cout << "\n-- Delete the rest, then one more --\n";
    list.deleteByName("Anjana");
    list.deleteByName("Ali");
    list.displayForward();
    list.deleteByName("Ali");

    return 0;
}
