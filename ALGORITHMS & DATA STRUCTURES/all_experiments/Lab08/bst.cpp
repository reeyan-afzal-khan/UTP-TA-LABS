// Lab 8 - BSTs, heaps, and balancing structures
// A binary search tree: insertion, search, inorder output, and deletion of a
// leaf, a node with one child, and a node with two children - with the BST
// rule checked after every change. Then the same keys in two insertion
// orders, to show that search cost follows HEIGHT, not node count.
//
// Conventions (Chapters 7-8): height counts EDGES on the longest path down
// (a single node has height 0, an empty tree -1); duplicate keys are ignored.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra bst.cpp -o bst
//     ./bst

#include <algorithm>
#include <climits>
#include <cstddef>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

struct TreeNode {
    int data;
    TreeNode* left;
    TreeNode* right;

    static int live;   // nodes allocated and not yet deleted
    static void* operator new(size_t size) { ++live; return ::operator new(size); }
    static void operator delete(void* p) { --live; ::operator delete(p); }
};
int TreeNode::live = 0;

TreeNode* insertBST(TreeNode* root, int value) {
    if (root == nullptr) {
        return new TreeNode{value, nullptr, nullptr};
    }

    if (value < root->data)
        root->left = insertBST(root->left, value);
    else if (value > root->data)
        root->right = insertBST(root->right, value);

    return root;
}

bool contains(TreeNode* root, int target) {
    while (root != nullptr) {
        if (target == root->data) return true;
        if (target < root->data) root = root->left;
        else root = root->right;
    }
    return false;
}

TreeNode* deleteBST(TreeNode* root, int value) {
    if (root == nullptr) return nullptr;                       // not found
    if (value < root->data) { root->left = deleteBST(root->left, value); return root; }
    if (value > root->data) { root->right = deleteBST(root->right, value); return root; }

    if (root->left == nullptr || root->right == nullptr) {     // zero or one child:
        TreeNode* child = root->left != nullptr ? root->left : root->right;
        delete root;                                           // the child takes its place
        return child;
    }

    TreeNode* successor = root->right;                         // two children: copy the
    while (successor->left != nullptr) successor = successor->left;   // inorder successor,
    root->data = successor->data;                              // then delete it from the
    root->right = deleteBST(root->right, successor->data);     // right subtree
    return root;
}

void inorder(TreeNode* root, vector<int>& out) {
    if (root == nullptr) return;
    inorder(root->left, out);
    out.push_back(root->data);
    inorder(root->right, out);
}

int height(TreeNode* root) {
    if (root == nullptr) return -1;
    return 1 + max(height(root->left), height(root->right));
}

// Every node lies strictly between the bounds its ancestors impose.
bool isBST(TreeNode* root, long lo = LONG_MIN, long hi = LONG_MAX) {
    if (root == nullptr) return true;
    if (root->data <= lo || root->data >= hi) return false;
    return isBST(root->left, lo, root->data) && isBST(root->right, root->data, hi);
}

// Height-balanced: at every node the subtree heights differ by at most 1.
bool isHeightBalanced(TreeNode* root) {
    if (root == nullptr) return true;
    int diff = height(root->left) - height(root->right);
    return diff >= -1 && diff <= 1 && isHeightBalanced(root->left) && isHeightBalanced(root->right);
}

// Sideways drawing: the right subtree is printed above, the left below.
void draw(TreeNode* root, int depth = 0) {
    if (root == nullptr) return;
    draw(root->right, depth + 1);
    cout << "    " << string(4 * depth, ' ') << root->data << '\n';
    draw(root->left, depth + 1);
}

void destroy(TreeNode*& root) {
    if (root == nullptr) return;
    destroy(root->left);
    destroy(root->right);
    delete root;
    root = nullptr;
}

string join(const vector<int>& v) {
    string s;
    for (int x : v) s += to_string(x) + ' ';
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void report(const string& step, TreeNode* root) {
    vector<int> keys;
    inorder(root, keys);
    cout << step << "\n  inorder: " << join(keys) << "  height: " << height(root) << '\n';
    check("inorder output is sorted", is_sorted(keys.begin(), keys.end()));
    check("every node respects the BST rule", isBST(root));
}

int main() {
    TreeNode* root = nullptr;

    cout << "== Insert 50, 30, 70, 20, 40, 60, 80 ==\n";
    for (int key : {50, 30, 70, 20, 40, 60, 80}) root = insertBST(root, key);
    draw(root);
    report("after insertion", root);

    cout << "\n== Search ==\n";
    cout << "  contains(60): " << (contains(root, 60) ? "yes" : "no")
         << "   contains(65): " << (contains(root, 65) ? "yes" : "no") << '\n';
    check("a stored key is found and a missing key is not", contains(root, 60) && !contains(root, 65));
    root = insertBST(root, 40);
    check("inserting a duplicate (40) is ignored", TreeNode::live == 7);

    cout << "\n== Deletions ==\n";
    root = deleteBST(root, 20);  report("delete 20 (a leaf)", root);
    root = deleteBST(root, 30);  report("delete 30 (one child, 40, moves up)", root);
    root = deleteBST(root, 50);  report("delete 50 (two children; successor 60 replaces it)", root);
    draw(root);
    check("the root now holds the successor 60", root->data == 60);
    check("deleted nodes were released", TreeNode::live == 4);
    destroy(root);

    cout << "\n== Try it: the same five keys, two insertion orders ==\n";
    TreeNode* skewed = nullptr;
    for (int key : {10, 20, 30, 40, 50}) skewed = insertBST(skewed, key);
    cout << "inserted 10, 20, 30, 40, 50 (sorted):\n";
    draw(skewed);
    cout << "  height " << height(skewed) << ", height-balanced: "
         << (isHeightBalanced(skewed) ? "yes" : "no") << '\n';

    TreeNode* balanced = nullptr;
    for (int key : {30, 20, 40, 10, 50}) balanced = insertBST(balanced, key);
    cout << "inserted 30, 20, 40, 10, 50:\n";
    draw(balanced);
    cout << "  height " << height(balanced) << ", height-balanced: "
         << (isHeightBalanced(balanced) ? "yes" : "no") << '\n';

    check("sorted insertion degrades to a chain of height n-1 = 4", height(skewed) == 4);
    check("the other order keeps height 2 and is height-balanced",
          height(balanced) == 2 && isHeightBalanced(balanced));
    cout << "  A search walks at most height+1 nodes: 5 in the chain, 3 in the balanced tree.\n";

    destroy(skewed);
    destroy(balanced);
    check("every node was released", TreeNode::live == 0);
    return 0;
}
