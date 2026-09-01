// Lab 6, Task 2 --- The same binary tree in two representations.
/*
                 8
               /   \
              4     12
             / \
            2   6
*/
//
//   Linked:  each node stores value + left/right pointers.
//   Array :  index the levels top-to-bottom, left-to-right (0-based here):
//
//        index :   0    1    2    3    4    5    6
//        value :   8    4   12    2    6    .    .
//
//        parent(i) = (i - 1) / 2      left(i) = 2i + 1     right(i) = 2i + 2
//
// The array form needs no pointers at all --- the index arithmetic IS the
// structure --- but it reserves a slot for every possible position, so a
// sparse or deep tree wastes space. That trade is why heaps (always complete)
// live in arrays while ordinary binary trees usually live in linked nodes.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

#include <iostream>
#include <vector>

using namespace std;

// ---------- Linked representation ----------

struct TreeNode {
    int value;
    TreeNode* left;
    TreeNode* right;
};

void inorderLinked(const TreeNode* n) {
    if (n == nullptr) return;
    inorderLinked(n->left);
    cout << n->value << ' ';
    inorderLinked(n->right);
}

void preorderLinked(const TreeNode* n) {
    if (n == nullptr) return;
    cout << n->value << ' ';
    preorderLinked(n->left);
    preorderLinked(n->right);
}

void postorderLinked(const TreeNode* n) {
    if (n == nullptr) return;
    postorderLinked(n->left);
    postorderLinked(n->right);
    cout << n->value << ' ';
}

void freeTree(TreeNode* n) {
    if (n == nullptr) return;
    freeTree(n->left);
    freeTree(n->right);
    delete n;
}

// ---------- Array representation ----------
// EMPTY marks absent children so the two representations can describe
// exactly the same (possibly incomplete) shape.

const int EMPTY = -1;

void inorderArray(const vector<int>& t, size_t i) {
    if (i >= t.size() || t[i] == EMPTY) return;
    inorderArray(t, 2 * i + 1);
    cout << t[i] << ' ';
    inorderArray(t, 2 * i + 2);
}

void preorderArray(const vector<int>& t, size_t i) {
    if (i >= t.size() || t[i] == EMPTY) return;
    cout << t[i] << ' ';
    preorderArray(t, 2 * i + 1);
    preorderArray(t, 2 * i + 2);
}

void postorderArray(const vector<int>& t, size_t i) {
    if (i >= t.size() || t[i] == EMPTY) return;
    postorderArray(t, 2 * i + 1);
    postorderArray(t, 2 * i + 2);
    cout << t[i] << ' ';
}

int main() {
    // Linked build of the tree in the header diagram.
    TreeNode* root = new TreeNode{8, nullptr, nullptr};
    root->left = new TreeNode{4, nullptr, nullptr};
    root->right = new TreeNode{12, nullptr, nullptr};
    root->left->left = new TreeNode{2, nullptr, nullptr};
    root->left->right = new TreeNode{6, nullptr, nullptr};

    // The identical shape as an array (0-based indexing convention).
    // Index 5 and 6 are the absent children of 12.
    vector<int> arr = {8, 4, 12, 2, 6, EMPTY, EMPTY};

    cout << "Convention: 0-based; parent(i)=(i-1)/2, left=2i+1, right=2i+2\n\n";

    cout << "Array slots:\n";
    for (size_t i = 0; i < arr.size(); ++i) {
        cout << "  index " << i << " : ";
        if (arr[i] == EMPTY) { cout << "(empty)\n"; continue; }
        cout << arr[i];
        if (i > 0) cout << "   parent=" << arr[(i - 1) / 2];
        cout << '\n';
    }

    cout << "\nTraversals (linked | array) --- must match pairwise:\n";
    cout << "  In-order   : ";
    inorderLinked(root);
    cout << " | ";
    inorderArray(arr, 0);
    cout << "\n  Pre-order  : ";
    preorderLinked(root);
    cout << " | ";
    preorderArray(arr, 0);
    cout << "\n  Post-order : ";
    postorderLinked(root);
    cout << " | ";
    postorderArray(arr, 0);
    cout << '\n';

    // Update exercise: change 6 to 7 in both representations.
    cout << "\n-- Update 6 -> 7 in both forms --\n";
    root->left->right->value = 7;   // linked: follow pointers
    arr[4] = 7;                     // array : index 4 = right child of index 1
    cout << "  In-order   : ";
    inorderLinked(root);
    cout << " | ";
    inorderArray(arr, 0);
    cout << '\n';

    freeTree(root);
    return 0;
}
