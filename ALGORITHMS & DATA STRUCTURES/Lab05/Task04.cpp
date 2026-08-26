#include <iostream>
#include <string>

using namespace std;

class Node {
public: //by default it is private
    string name;
    Node* next; //memory address of the next node
    //own next pointer
    
    // a constructor for setting up when new node is created
    Node(string n) {
        name = n; //the string will pass here to declare first
        // where to refer? see upper part, it alr declare it, so default is the value
        next = nullptr;
        // so this is the Node* by default 
    }
};

class Stack {
public:
    Node* top; //memory address of the first node
    //this belongs to linkedlist, store the first node address
    // head -----> [Aimar | next] -----> [Ahmad | next] -----> [Anjana | nullptr]
    //visualize it 

    Stack() {
        top = nullptr;
    }

    void push(string name) {
        Node* newNode = new Node(name);
        newNode->next = top;
        top = newNode;
    }

    void pop() {
        if (top == nullptr) {
            cout << "This stack is empty";
        }
        Node* temp = top;
        top = top->next;
        cout << endl;
        cout << temp->name << " is popped" << endl;
        delete temp;
    }

    void display() {
        Node* current = top;
        if(current == nullptr) {
            cout << "The stack is empty" << endl;
            return;
        }
        while (current != nullptr) {
            cout << current->name << endl;
            current = current->next;
        }
    }
};

int main() {
   Stack s;

   s.push("Aimar");
   s.push("Ahmad");
   s.push("Anjana");

   cout << "Display from top to bottom:" << endl;
   s.display();

   s.pop();
   // print the lastest stack
   cout << "\nAfter pop:" << endl;
   s.display();
}

