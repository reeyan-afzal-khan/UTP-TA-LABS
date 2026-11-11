// Lab 7 - Tree representation and traversal
// One binary tree held two ways - linked nodes and an array - with inorder,
// preorder and postorder traversals of each, an index table for the array,
// an update, a structural insertion, and a deletion applied to both.
//
// Indexing convention: the array is 0-based, so the children of index i are
// at 2i+1 and 2i+2 and its parent is at (i-1)/2. The slide's formulas 2I and
// 2I+1 are the same tree numbered from 1; the table prints both.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra binary_tree.cpp -o binary_tree
//     ./binary_tree

#include <cstddef>
#include <cstdio>
#include <iostream>
#include <queue>
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

const int EMPTY = -1;          // an unused slot in the array representation

// ---- linked representation ------------------------------------------------

void inorder(TreeNode* root, vector<int>& out) {
    if (root == nullptr) return;          // an empty subtree ends the recursion
    inorder(root->left, out);
    out.push_back(root->data);
    inorder(root->right, out);
}

void preorder(TreeNode* root, vector<int>& out) {
    if (root == nullptr) return;
    out.push_back(root->data);
    preorder(root->left, out);
    preorder(root->right, out);
}

void postorder(TreeNode* root, vector<int>& out) {
    if (root == nullptr) return;
    postorder(root->left, out);
    postorder(root->right, out);
    out.push_back(root->data);
}

TreeNode* find(TreeNode* root, int value) {
    if (root == nullptr || root->data == value) return root;
    TreeNode* inLeft = find(root->left, value);
    return inLeft != nullptr ? inLeft : find(root->right, value);
}

// Binary-tree deletion (no ordering rule to keep): copy the deepest,
// rightmost node's value into the node being deleted, then remove that leaf.
bool deleteValue(TreeNode*& root, int value) {
    TreeNode* target = find(root, value);
    if (target == nullptr) return false;

    TreeNode* deepest = nullptr;
    TreeNode* parentOfDeepest = nullptr;
    queue<pair<TreeNode*, TreeNode*>> q;         // (node, its parent), level order
    q.push({root, nullptr});
    while (!q.empty()) {
        auto [node, parent] = q.front();
        q.pop();
        deepest = node;
        parentOfDeepest = parent;
        if (node->left)  q.push({node->left, node});
        if (node->right) q.push({node->right, node});
    }

    target->data = deepest->data;
    if (parentOfDeepest == nullptr) root = nullptr;            // the tree had one node
    else if (parentOfDeepest->right == deepest) parentOfDeepest->right = nullptr;
    else parentOfDeepest->left = nullptr;
    delete deepest;
    return true;
}

void destroy(TreeNode*& root) {
    if (root == nullptr) return;
    destroy(root->left);
    destroy(root->right);
    delete root;
    root = nullptr;
}

// ---- array representation (0-based) ---------------------------------------

bool present(const vector<int>& tree, int i) {
    return i < static_cast<int>(tree.size()) && tree[i] != EMPTY;
}

void arrayInorder(const vector<int>& tree, int i, vector<int>& out) {
    if (!present(tree, i)) return;
    arrayInorder(tree, 2 * i + 1, out);
    out.push_back(tree[i]);
    arrayInorder(tree, 2 * i + 2, out);
}

void arrayPreorder(const vector<int>& tree, int i, vector<int>& out) {
    if (!present(tree, i)) return;
    out.push_back(tree[i]);
    arrayPreorder(tree, 2 * i + 1, out);
    arrayPreorder(tree, 2 * i + 2, out);
}

void arrayPostorder(const vector<int>& tree, int i, vector<int>& out) {
    if (!present(tree, i)) return;
    arrayPostorder(tree, 2 * i + 1, out);
    arrayPostorder(tree, 2 * i + 2, out);
    out.push_back(tree[i]);
}

// The same deletion rule on the array: the deepest, rightmost node is simply
// the last occupied slot in level order.
bool arrayDeleteValue(vector<int>& tree, int value) {
    int target = -1, last = -1;
    for (int i = 0; i < static_cast<int>(tree.size()); ++i) {
        if (tree[i] == EMPTY) continue;
        if (target == -1 && tree[i] == value) target = i;
        last = i;
    }
    if (target == -1) return false;
    tree[target] = tree[last];
    tree[last] = EMPTY;
    while (!tree.empty() && tree.back() == EMPTY) tree.pop_back();
    return true;
}

void printIndexTable(const vector<int>& tree) {
    // An occupied child slot as a 0-based index, or the same slot numbered
    // from 1 (the slide's 2I and 2I+1); "-" where there is no child.
    auto slot = [&](int i, int base) { return present(tree, i) ? to_string(i + base) : string("-"); };
    cout << "  0-based: index  left  right  parent   1-based: I  2I  2I+1    value\n";
    for (int i = 0; i < static_cast<int>(tree.size()); ++i) {
        if (tree[i] == EMPTY) continue;
        string parent = i == 0 ? "-" : to_string((i - 1) / 2);
        printf("           %5d  %4s  %5s  %6s            %2d  %2s  %4s    %5d\n",
               i, slot(2 * i + 1, 0).c_str(), slot(2 * i + 2, 0).c_str(), parent.c_str(),
               i + 1, slot(2 * i + 1, 1).c_str(), slot(2 * i + 2, 1).c_str(), tree[i]);
    }
}

// ---- comparing the two ------------------------------------------------------

bool sameShape(TreeNode* node, const vector<int>& tree, int i) {
    if (node == nullptr) return !present(tree, i);
    if (!present(tree, i) || tree[i] != node->data) return false;
    return sameShape(node->left, tree, 2 * i + 1) && sameShape(node->right, tree, 2 * i + 2);
}

string join(const vector<int>& v) {
    string s;
    for (int x : v) s += to_string(x) + ' ';
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void compareTraversals(TreeNode* root, const vector<int>& tree) {
    vector<int> a, b, c, d, e, f;
    inorder(root, a);   arrayInorder(tree, 0, b);
    preorder(root, c);  arrayPreorder(tree, 0, d);
    postorder(root, e); arrayPostorder(tree, 0, f);
    cout << "  inorder   linked: " << join(a) << "  array: " << join(b) << '\n';
    cout << "  preorder  linked: " << join(c) << "  array: " << join(d) << '\n';
    cout << "  postorder linked: " << join(e) << "  array: " << join(f) << '\n';
    check("both representations describe the same shape", sameShape(root, tree, 0));
    check("all three traversals agree between the representations", a == b && c == d && e == f);
}

int main() {
    // Linked representation, built as in the lab sheet.
    TreeNode* root = new TreeNode{8, nullptr, nullptr};
    root->left = new TreeNode{4, nullptr, nullptr};
    root->right = new TreeNode{12, nullptr, nullptr};
    root->left->left = new TreeNode{2, nullptr, nullptr};
    root->left->right = new TreeNode{6, nullptr, nullptr};

    // The same shape in an array: level by level, left to right.
    vector<int> tree = {8, 4, 12, 2, 6};

    cout << "== Predicted before running (write these down first) ==\n"
         << "  inorder   2 4 6 8 12\n  preorder  8 4 2 6 12\n  postorder 2 6 4 12 8\n";

    cout << "\n== Traversals ==\n";
    compareTraversals(root, tree);
    vector<int> in, pre, post;
    inorder(root, in); preorder(root, pre); postorder(root, post);
    check("the predictions match",
          join(in) == "2 4 6 8 12 " && join(pre) == "8 4 2 6 12 " && join(post) == "2 6 4 12 8 ");
    check("each traversal visits every stored node exactly once",
          in.size() == 5 && pre.size() == 5 && post.size() == 5);

    cout << "\n== Array index table ==\n";
    printIndexTable(tree);

    cout << "\n== Update: change 6 to 7 ==\n";
    find(root, 6)->data = 7;
    for (int& x : tree) if (x == 6) x = 7;
    compareTraversals(root, tree);

    cout << "\n== Structural insertion: 10 becomes the left child of 12 ==\n";
    root->right->left = new TreeNode{10, nullptr, nullptr};
    tree.resize(6, EMPTY);
    tree[2 * 2 + 1] = 10;              // 12 is at index 2, its left child at 2*2+1 = 5
    printIndexTable(tree);
    compareTraversals(root, tree);

    cout << "\n== Deletion: remove 4 (replaced by the deepest, rightmost node, 10) ==\n";
    deleteValue(root, 4);
    arrayDeleteValue(tree, 4);
    printIndexTable(tree);
    compareTraversals(root, tree);
    check("deleting a value that is not in the tree is refused",
          !deleteValue(root, 99) && !arrayDeleteValue(tree, 99));

    cout << "\n== Empty tree ==\n";
    vector<int> none;
    inorder(nullptr, none);
    check("traversing an empty tree terminates and visits nothing", none.empty());

    destroy(root);
    check("every node was released", TreeNode::live == 0);
    return 0;
}
