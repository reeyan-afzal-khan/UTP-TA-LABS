#include <iostream>
#include <string>
using namespace std;

// binary tree is a domain 
// while binary search tree is more specific
class Tree {
public:
    int value;
    Tree* left  = nullptr;
    Tree* right = nullptr;

    //constructor
    Tree(int v) {
    value = v;   
    }

    // recursive function
    void insert(int v) { 
        if (v < value) {
            if (left == nullptr) left = new Tree(v);
            //here ehcking the left child
            // if there is no child, then can directly create a new node 
            else left->insert(v);
            //recursive function to check again with the branch 

        } else if (v > value) {
            if (right == nullptr) right = new Tree(v);
            else right->insert(v);
            //how to know it is checking the child
            //because when you recurves, it will check the current child node.right not the root.right
        }
    }

    bool search(int v) {
        if (v == value) return true;
        if (v < value)  return left  != nullptr && left->search(v);
        else            return right != nullptr && right->search(v);
    }

    void displayInOrder() {
        if (left)  left->displayInOrder(); //left
        cout << value << " "; // display the root value
        if (right) right->displayInOrder(); //right 
    }

    //display start from top
    void displayPreOrder() {
        cout << value << " "; //root value
        if (left)  left->displayPreOrder();
        // after finishing printing all the left subtree, only we can proceed to right subtree
        cout << " | " ; //use to seperate left and right
        if (right) right->displayPreOrder();
        // in preorder it is root, left, right 
    }
};

int main() {
    // insert 1 to 7
    int order[] = {4, 2, 6, 1, 3, 5, 7};

    Tree* root = new Tree(order[0]);
    // choose the right element in the array as the root
    // the value is passed through constructor
    for (int i = 1; i < 7; i++) {
        //only need to insert 6 numbers, because root alr eliminate one
        root->insert(order[i]);
        // meaning start from the root, left to check function, after everything done then right
        // but since the left is null, then you can directly insert
    }

    cout << "In-order (sorted): ";
    root->displayInOrder();
    cout << endl;

    cout << "Pre-order (shows structure): ";
    root->displayPreOrder();
    cout << endl;

    // just for validation
    cout << "Search 5: " << (root->search(5) ? "found" : "not found") << endl;
    cout << "Search 9: " << (root->search(9) ? "found" : "not found") << endl;
}