// Lab 3, Task 1 --- Singly linked list.
//
//   head -> [Aimar] -> [Anjana] -> [Jessy] -> nullptr
//
// Each node stores a value and the address of the next node. The list owns
// no contiguous block of memory: nodes sit wherever `new` puts them, and the
// next pointers are what impose an order on them.
//
// That is the trade against an array. Inserting in the middle costs no
// shifting --- just two pointer assignments --- but reaching position i costs
// a walk from the head, because there is no arithmetic that jumps to it.
//
// Build: g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01

#include <iostream>
#include <string>

using namespace std;

class Node {
public:
    string name;
    Node* next;

    // The constructor sets next to nullptr so a fresh node is always a
    // valid one-element list rather than holding an uninitialised pointer.
    explicit Node(const string& n) : name(n), next(nullptr) {}
};

class LinkedList {
private:
    Node* head;  // address of the first node; nullptr when the list is empty

public:
    LinkedList() : head(nullptr) {}

    // Every node came from `new`, so every node needs a `delete`. Letting the
    // list go out of scope without this leaks all of them.
    ~LinkedList() {
        Node* current = head;
        while (current != nullptr) {
            // Save the next pointer BEFORE deleting, otherwise you are
            // reading a field out of freed memory to find where to go next.
            Node* temp = current;
            current = current->next;
            delete temp;
        }
        head = nullptr;
    }

    // A default copy would duplicate the head pointer, and both objects
    // would delete the same nodes. Deleting these makes that a compile error.
    LinkedList(const LinkedList&)            = delete;
    LinkedList& operator=(const LinkedList&) = delete;

    bool isEmpty() const { return head == nullptr; }

    void insertEnd(const string& name) {
        Node* newNode = new Node(name);

        if (head == nullptr) {
            head = newNode;
            return;
        }

        // Stop at the last node --- the one whose next is nullptr --- not at
        // nullptr itself, because we need to write into that node.
        Node* current = head;
        while (current->next != nullptr) {
            current = current->next;
        }
        current->next = newNode;
    }

    void insertAfter(const string& afterName, const string& newName) {
        Node* current = head;
        while (current != nullptr && current->name != afterName) {
            current = current->next;
        }

        if (current == nullptr) {
            cout << afterName << " not found.\n";
            return;
        }

        Node* newNode = new Node(newName);

        // Order matters. Point the new node at the rest of the list first;
        // if you overwrite current->next first, the tail is unreachable.
        newNode->next = current->next;
        current->next = newNode;
    }

    void deleteByName(const string& name) {
        if (head == nullptr) {
            cout << name << " not found.\n";
            return;
        }

        // Deleting the head is the special case: there is no previous node
        // to redirect, so the head pointer itself has to move.
        if (head->name == name) {
            Node* temp = head;
            head = head->next;
            delete temp;
            return;
        }

        // Otherwise look one step ahead, so that when we find the match we
        // are still holding the node that points at it.
        Node* current = head;
        while (current->next != nullptr) {
            if (current->next->name == name) {
                Node* temp = current->next;
                current->next = temp->next;  // route around the doomed node
                delete temp;
                return;
            }
            current = current->next;
        }

        cout << name << " not found.\n";
    }

    void display() const {
        if (head == nullptr) {
            cout << "The list is empty.\n";
            return;
        }
        for (Node* current = head; current != nullptr; current = current->next) {
            cout << current->name;
            if (current->next != nullptr) cout << " -> ";
        }
        cout << "\n";
    }
};

int main() {
    LinkedList list;

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

    cout << "\n-- Delete a name that is not present --\n";
    list.deleteByName("Jessy");

    cout << "\n-- Delete the rest --\n";
    list.deleteByName("Anjana");
    list.deleteByName("Ali");
    list.deleteByName("Jane");
    list.display();

    return 0;
}
