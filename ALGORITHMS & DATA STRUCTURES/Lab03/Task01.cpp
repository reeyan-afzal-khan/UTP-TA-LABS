#include <iostream>
#include <string>

using namespace std;

//Aimar
//Ahmad
//Anjana (delete this)

//Ali (insert Ali here)

//Jessy

// and then last display all 

//make class instead of struct 

class Node {
public: 
    string name;
    Node* next; //memory address of the next node
    //own next pointer
    // 

    // a constructor for setting up when new node is created
    Node(string n) {
        name = n; //the string will pass here to declare first
        // where to refer? see upper part, it alr declare it, so default is the value
        next = nullptr;
        // so this is the Node* by default 
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
            return;
        }

        // if not walk to the last node
        Node* current = head;
        while (current->next != nullptr) {
            current = current->next;
        }
        current->next = newNode;
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
        current->next = newNode; 
        //Anjana now points to Ali 
    }

    //delete a node by the name 
    void deleteByName (string name) {
        if (head == nullptr) {
            return; //empty list
        }
        if (head->name == name) {
            Node* temp = head;
            head = head->next;
            delete temp; // if the deleted one should be head
            return;
        }
        // search the rest of the list 
        Node* current = head;
        while (current->next != nullptr) {
            if (current->next->name == name) {
                Node* temp = current->next; //using this mean assigned the address to temp
                current->next = temp->next; 
                // the address of the next node of current address if the next node of "will be deleted" address
                // meaning the next of the current node (which is the before being deleted)
                // is the the next of being deleted one 
                // so skip the linking directly from the being deleted one
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
        while (current != nullptr) {
            cout << current->name << endl;
            current = current->next;
        }
    }
};

int main() {
    LinkedList list;

    list.insertEnd("Aimar");
    list.insertEnd("Anjana");
    list.insertEnd("Jessy");

     cout << "Initial list:" << endl;
    list.display();

    list.insertAfter("Anjana","Ali");

    // insert Jessy at the end
    list.insertEnd("Jane");

    // delete Anjana
    list.deleteByName("Jessy");

    cout << "\nFinal list:" << endl;
    list.display();
    // Node node1, node2, node3; //cannot use this because this is sharing the same address
    // Node* node1 = new Node(); //Node() is new node address, not the node itself
    // Node* node2 = new Node();
    // Node* node3 = new Node();

    // node1->name = "Ali";
    // node1->next = node2; //memory address of node2
    // node2->name = "Ahmet";
    // node2->next = node3; //memory address of node3
    // node3->name = "Ayse";
    // node3->next = nullptr; //end of the list

    // //traverse 
    // Node* current = node1;
    // while (current != nullptr) {
    //     cout << current->name << endl;
    //     current = current->next;
    // }

    // //pick by number 
    // Node* arr[] = {node1, node2, node3};
    // int choice;
    // cout << "Enter 1-3 to print the name:" << endl;
    // cin >> choice;
    // cout << arr[choice - 1]->name << endl; 
    // because arr[3-1] = arr[2] = &node3.

    // Node nodes[] = {node1, node2, node3};

    // int current = 0;
    // while (current != -1) {
    //     cout << current->name << endl;
    //     current = current->next;
    // }
    //insert 

    //delete 

    //display linkedlist

    
}

