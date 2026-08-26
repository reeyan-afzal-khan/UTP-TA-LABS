#include <iostream>
#include <string>

using namespace std;

class Node {
public: 
    string name;
    Node* next = NULL; //memory address of the next node
    Node* prev = NULL;
    //own next pointer
    // 

    // a constructor for setting up when new node is created
    Node(string n) {
        name = n; //the string will pass here to declare first
        // where to refer? see upper part, it alr declare it, so default is the value
        next = nullptr;
        // so this is the Node* by default 
        prev = nullptr;
    }
};

class LinkedList {
public:
    Node* head; //memory address of the first node
    //this belongs to linkedlist, store the first node address
    // head -----> [Aimar | next] -----> [Ahmad | next] -----> [Anjana | nullptr]
    //visualize it 

    LinkedList() {
        head = nullptr; //empty list
    }

    void insertEnd(string name) { //insert at the end
        Node* newNode = new Node(name);

        if (head == nullptr) {
            //meaning that the list is empty 
            head = newNode;
            newNode->next = head;  // points to itself
            newNode->prev = head;
            return;
        }

        // // if not walk to the last node
        // Node* current = head;
        // while (current->next != nullptr) {
        //     current = current->next;
        // }
        // current->next = newNode;
        // newNode->prev = current;
        Node* tail = head->prev;  // in circular, head->prev IS the tail

        tail->next = newNode;     // old tail → new node
        newNode->prev = tail;     // new node ← old tail
        newNode->next = head;     // new node → head (circular)
        head->prev = newNode;
    }

    void insertAfter(string afterName, string newName) {
        Node* current = head;
        
        while (current != nullptr && current->name != afterName) {
            current = current->next;
            //find the postition to be inserted
        }

        if (current == nullptr) {
            cout << afterName << "not found." << endl;
            return;
        }

        Node* newNode = new Node(newName);
        newNode->next = current->next;
        //Ali points to what Anjana is pointing
        newNode->prev = current;

        if (current->next != head) {
            current->next->prev = newNode;
            // the node after must point back to the new node if 
            // after the new node, there is still node there
            //use head instead of nullptr in circular, because the tail is pointing always to head
        }
        current->next = newNode;
        // four connection new to next, new to prev, prev to new, next to new
        // right down, left down, right up, left up 
        // The order must always be, set the new node's links first, then update the existing nodes.
    }

    //delete a node by the name 
    void deleteByName (string name) {
        if (head == nullptr) {
            return; //empty list
        }
        if (head->name == name) {
            Node* temp = head;
            head = head->next;
            if (head != nullptr) {
                head->prev = nullptr;
            }
            // new head has no previous node
            delete temp; // if the deleted one should be head
            return;
        }
        // search the rest of the list 
        Node* current = head;
        while (current->next != head) {
            if (current->next->name == name) {
                Node* temp = current->next; //using this mean assigned the address to temp
                current->next = temp->next; 
                // the address of the next node of current address if the next node of "will be deleted" address
                // meaning the next of the current node (which is the before being deleted)
                // is the the next of being deleted one 
                // so skip the linking directly from the being deleted one
                if (temp->next != head) {
                    temp->next->prev = current;
                    // it is not the last node, need to connect the next node (alr skipped deleted node)
                    //back to the current, which is the 
                    // previous of temp (deleted node)
                }
                else {
                    head->prev = current;  // NEW: update head's prev if tail was deleted
                }
                delete temp; 
                return;
            }
            current = current->next; //keep looping to find the matching name
        }
    }
    
    //display the linked list
    void display() {
        Node* current = head;
        if (current == nullptr) {
            cout << "The list is empty." << endl;
            return;
        }
        do {                           // use do-while so head is printed too
            cout << current->name << endl;
            current = current->next;
        } while (current != head);     // stop when back at head
    }

    void displayReverse() {
        if (head == nullptr) {
            cout << "The list is empty." << endl;
            return;
        }

        // can directly go to the last node
        Node* current = head->prev;
        do {
            cout << current->name << endl;
            current = current->prev;
        } while (current != head->prev); // stop when back at tail
    }
};

int main() {
    LinkedList list;

    list.insertEnd("Aimar");
    list.insertEnd("Anjana");
    list.insertEnd("Jessy");

    cout << "\nInitial list:" << endl;
    list.display();

    cout << "\nAfter inserting Ali after Anjana:" << endl;
    list.insertAfter("Anjana","Ali");
    list.display();

    // insert Jane at the end
    cout << "\nAfter inserting Jane at the end:" << endl;
    list.insertEnd("Jane");
    list.display();    

    // delete Jessy
    cout << "\nAfter deleting Jessy:" << endl;
    list.deleteByName("Jessy");
    list.display();

    cout << "\nReverse linkedlist:" << endl;
    list.displayReverse();

    cout << "\nFinal list (in order):" << endl;
    list.display();
}

