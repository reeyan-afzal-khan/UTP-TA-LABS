// Lab 4, Task 2 --- Doubly linked list (not circular).
//
//   nullptr <- [Aimar] <-> [Anjana] <-> [Jessy] -> nullptr
//
// Compare this with Task01.cpp. The difference is entirely in the ends:
// here the first node's prev and the last node's next are nullptr, so every
// traversal stops at nullptr, and every insert or delete has to ask
// "am I at an end?" before following a pointer.
//
// The circular version removes those special cases at the cost of one
// invariant to maintain. That trade-off is the point of the two tasks.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

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

class DoublyLinkedList {
private:
    Node* head;

    Node* find(const string& name) const {
        // Here nullptr really is the end, so a plain while loop terminates.
        for (Node* current = head; current != nullptr; current = current->next) {
            if (current->name == name) return current;
        }
        return nullptr;
    }

public:
    DoublyLinkedList() : head(nullptr) {}

    ~DoublyLinkedList() {
        Node* current = head;
        while (current != nullptr) {
            Node* temp = current;
            current = current->next;
            delete temp;
        }
        head = nullptr;
    }

    DoublyLinkedList(const DoublyLinkedList&)            = delete;
    DoublyLinkedList& operator=(const DoublyLinkedList&) = delete;

    bool isEmpty() const { return head == nullptr; }

    void insertEnd(const string& name) {
        Node* newNode = new Node(name);

        if (head == nullptr) {
            head = newNode;
            return;
        }

        // No tail shortcut in this version: finding the last node costs a
        // full walk, O(n). The circular list gets it in O(1) from head->prev.
        Node* current = head;
        while (current->next != nullptr) {
            current = current->next;
        }

        current->next = newNode;
        newNode->prev = current;
    }

    void insertAfter(const string& afterName, const string& newName) {
        Node* current = find(afterName);
        if (current == nullptr) {
            cout << afterName << " not found.\n";
            return;
        }

        Node* newNode = new Node(newName);
        newNode->next = current->next;
        newNode->prev = current;

        // Guard needed: current->next is nullptr when inserting after the
        // tail, and nullptr->prev would crash.
        if (current->next != nullptr) {
            current->next->prev = newNode;
        }
        current->next = newNode;
    }

    void deleteByName(const string& name) {
        Node* target = find(name);
        if (target == nullptr) {
            cout << name << " not found.\n";
            return;
        }

        // Detach from the left neighbour, or move head if there isn't one.
        if (target->prev != nullptr) {
            target->prev->next = target->next;
        } else {
            head = target->next;
        }

        // Detach from the right neighbour, if there is one.
        if (target->next != nullptr) {
            target->next->prev = target->prev;
        }

        delete target;
    }

    void display() const {
        if (head == nullptr) {
            cout << "The list is empty.\n";
            return;
        }
        for (Node* current = head; current != nullptr; current = current->next) {
            cout << current->name;
            if (current->next != nullptr) cout << " <-> ";
        }
        cout << "\n";
    }

    void displayReverse() const {
        if (head == nullptr) {
            cout << "The list is empty.\n";
            return;
        }

        // Walk to the tail, then follow prev back. Being able to do this at
        // all is the reason for the second pointer: a singly linked list
        // would have to reverse itself or recurse.
        Node* current = head;
        while (current->next != nullptr) {
            current = current->next;
        }
        for (; current != nullptr; current = current->prev) {
            cout << current->name;
            if (current->prev != nullptr) cout << " <-> ";
        }
        cout << "\n";
    }
};

int main() {
    DoublyLinkedList list;

    cout << "-- Build the list --\n";
    list.insertEnd("Aimar");
    list.insertEnd("Anjana");
    list.insertEnd("Jessy");
    list.display();

    cout << "\n-- Insert Ali after Anjana --\n";
    list.insertAfter("Anjana", "Ali");
    list.display();

    cout << "\n-- Insert after a name that is not present --\n";
    list.insertAfter("Nobody", "Ghost");

    cout << "\n-- Insert Jane at the end --\n";
    list.insertEnd("Jane");
    list.display();

    cout << "\n-- Delete Jessy (middle) --\n";
    list.deleteByName("Jessy");
    list.display();

    cout << "\n-- Delete Aimar (head) --\n";
    list.deleteByName("Aimar");
    list.display();

    cout << "\n-- Reverse traversal --\n";
    list.displayReverse();

    cout << "\n-- Delete everything --\n";
    list.deleteByName("Anjana");
    list.deleteByName("Ali");
    list.deleteByName("Jane");
    list.display();

    return 0;
}
