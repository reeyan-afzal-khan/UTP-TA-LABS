// Lab 6, Task 1 --- Binary search tree.
//
// A binary TREE is any node with up to two children. A binary SEARCH tree
// adds one rule, and every useful property follows from it:
//
//     everything in the left subtree  <  this node  <  everything in the right
//
// Inserting {4, 2, 6, 1, 3, 5, 7} in that order gives:
/*
              4
            /   \
           2     6
          / \   / \
         1   3 5   7
*/
//
// Because the rule holds at every node, a search can discard half the
// remaining tree at each step --- O(log n) when the tree is balanced.
// It degrades to O(n) when it is not: insert 1,2,3,4,5 in order and the
// tree becomes a linked list leaning right. Try it below.
//
// Build: g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01

#include <iostream>

using namespace std;

class Tree {
public:
    int value;
    Tree* left;
    Tree* right;

    explicit Tree(int v) : value(v), left(nullptr), right(nullptr) {}

    // Recursively frees both subtrees. Deleting a child calls that child's
    // destructor, which frees its children, all the way down.
    ~Tree() {
        delete left;   // deleting nullptr is defined and does nothing,
        delete right;  // so a leaf needs no special case
    }

    Tree(const Tree&)            = delete;
    Tree& operator=(const Tree&) = delete;

    void insert(int v) {
        if (v < value) {
            // No left child means we have found the empty slot this value
            // belongs in. Otherwise hand the problem to the left subtree,
            // which asks exactly the same question one level down.
            if (left == nullptr) left = new Tree(v);
            else                 left->insert(v);
        } else if (v > value) {
            if (right == nullptr) right = new Tree(v);
            else                  right->insert(v);
        }
        // v == value: already present. A BST holds no duplicates, so
        // this does nothing rather than growing a second copy.
    }

    bool search(int v) const {
        if (v == value) return true;

        // Only one side is ever worth looking at --- that is the whole
        // benefit of the ordering rule.
        if (v < value) return left  != nullptr && left->search(v);
        else           return right != nullptr && right->search(v);
    }

    // Left, node, right --- visits values in ascending order.
    void displayInOrder() const {
        if (left) left->displayInOrder();
        cout << value << " ";
        if (right) right->displayInOrder();
    }

    // Node, left, right --- shows the tree's shape: the first value printed
    // is the root, and the order is what you would replay to rebuild it.
    void displayPreOrder() const {
        cout << value << " ";
        if (left)  left->displayPreOrder();
        if (right) right->displayPreOrder();
        // The original printed a " | " separator between the two recursive
        // calls unconditionally, so nodes with no right child emitted a
        // stray bar and the output no longer read as a traversal.
    }

    // Left, right, node --- children before parents. This is the order a
    // destructor has to use: you cannot free a node before its children.
    void displayPostOrder() const {
        if (left)  left->displayPostOrder();
        if (right) right->displayPostOrder();
        cout << value << " ";
    }

    // Longest path from here down to a leaf, counted in nodes.
    int height() const {
        int leftHeight  = (left  != nullptr) ? left->height()  : 0;
        int rightHeight = (right != nullptr) ? right->height() : 0;
        return 1 + (leftHeight > rightHeight ? leftHeight : rightHeight);
    }
};

int main() {
    int order[] = {4, 2, 6, 1, 3, 5, 7};
    int n = sizeof(order) / sizeof(order[0]);

    // The first value becomes the root; the rest are placed relative to it.
    Tree* root = new Tree(order[0]);
    for (int i = 1; i < n; i++) {
        root->insert(order[i]);
    }

    cout << "In-order   (sorted)      : ";
    root->displayInOrder();
    cout << "\n";

    cout << "Pre-order  (shape)       : ";
    root->displayPreOrder();
    cout << "\n";

    cout << "Post-order (children 1st): ";
    root->displayPostOrder();
    cout << "\n";

    cout << "Height: " << root->height() << " (balanced)\n";

    cout << "\nSearch 5: " << (root->search(5) ? "found" : "not found") << "\n";
    cout << "Search 9: " << (root->search(9) ? "found" : "not found") << "\n";

    // Inserting a duplicate must not change anything.
    root->insert(5);
    cout << "\nAfter inserting a duplicate 5, in-order is unchanged: ";
    root->displayInOrder();
    cout << "\n";

    delete root;   // frees the whole tree recursively

    // The degenerate case: already-sorted input gives a tree of height n.
    cout << "\n-- Same values inserted in sorted order --\n";
    Tree* skewed = new Tree(1);
    for (int v = 2; v <= 7; v++) {
        skewed->insert(v);
    }
    cout << "In-order: ";
    skewed->displayInOrder();
    cout << "\nHeight: " << skewed->height()
         << " (degenerate --- every node has only a right child,\n"
         << "   so search is O(n) and the tree is really a linked list)\n";
    delete skewed;

    return 0;
}
