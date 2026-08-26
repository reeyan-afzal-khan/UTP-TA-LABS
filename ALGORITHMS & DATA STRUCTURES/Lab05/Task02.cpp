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

class Queue {
public:
    Node* front; 
    Node* rear;


    Queue() {
        front = nullptr;
        rear = nullptr;
    }

    void enqueue(string name) {
        Node* newNode = new Node(name);
        if (rear == nullptr) {
            front = rear = newNode; //move both to one step out
            return;
        }
        rear->next = newNode; // link the next of rear to new node
        rear = newNode; //move the rear to the position of the new node
    }

    void dequeue() {
        if (front == nullptr) {
            cout << "This queue is empty";
            return;
        }
        Node* temp = front;
        front = front->next; // link the front to the next then only we delett the temp (front)
        cout << endl;
        cout << temp->name << " is popped" << endl;
        delete temp;
        //must display first before delete if not it is not accessed
        // it is undefined behavior (meaning in crash or garbage alr)

        //check if after delete the front, will t be empty? of empty, move the rear to nullptr if 
        //front alr link to nullptr which mean empty queue after linking to the front->next

        //you know why ? because default, you see the function above 
        // next = nullptr as declared
        // so if we don't assign it to another next, it will set it to nullptr by default, which meaning 
        // it is not pointing other node
        if(front == nullptr) {
            rear = nullptr; //single assign to == ok!
        } 
    }

    void display() {
        Node* current = front;
        if(current == nullptr) {
            cout << "The queue is empty" << endl;
            return;
        }
        while (current != nullptr) {
            cout << current->name << endl;
            current = current->next;
        }
    }
};

int main() {
   Queue q;

   q.enqueue("Aimar");
   q.enqueue("Ahmad");
   q.enqueue("Anjana");

   cout << "Display from front to rear (left to right):" << endl;
   q.display();

   q.dequeue();
   // print the lastest stack
   cout << "\nAfter dequeue the front:" << endl;
   q.display();
}

