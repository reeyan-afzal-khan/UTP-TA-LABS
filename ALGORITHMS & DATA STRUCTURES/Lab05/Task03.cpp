#include <iostream>
#include <string>

using namespace std;

class Stack {
public:
    string arr[100];
    int top;

    Stack() {
        top = -1;
    }

    void push(string name) {
        //if it is full until 99 meaning it is alr the limit 0-99 usable
        if(top == 99) {
            cout << "The stack is full. " << endl;
            return;
        }

        // if it is not full 
        top++;
        arr[top] = name;
    }

    void pop() {
        //check if the array is underflow, like it is empty 
        if (top == -1) {
            cout << "The Stack is empty. " << endl;
            return;
        }
        cout << endl;
        cout << arr[top] << " is popped" << endl;
        top--;
        //directly delete the top, no need to delete the temp, which is the node
    }

    void display() {
        //check if the array is underflow, like it is empty 
        if (top == -1) {
            cout << "The Stack is empty. " << endl;
            return;
        }
        for(int i = top; i >= 0; i--) {
            cout << arr[i] << endl;       
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

