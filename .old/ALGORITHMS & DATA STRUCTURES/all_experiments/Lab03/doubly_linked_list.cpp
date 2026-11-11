// Lab 3 - Singly and doubly linked lists
// Part B: a doubly linked list from scratch - create, display forward and
// backward, search, insert at several positions, and delete by value - with
// both pointer directions checked after every change.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra doubly_linked_list.cpp -o doubly_linked_list
//     ./doubly_linked_list

#include <cstddef>
#include <iostream>
#include <string>
using namespace std;

struct DNode {
    int data;
    DNode* prev;
    DNode* next;

    // Counts nodes that are allocated and not yet deleted.
    static int live;
    static void* operator new(size_t size) { ++live; return ::operator new(size); }
    static void operator delete(void* p) { --live; ::operator delete(p); }
};
int DNode::live = 0;

void append(DNode*& head, DNode*& tail, int value) {
    DNode* n = new DNode{value, tail, nullptr};
    if (tail == nullptr) head = tail = n;
    else {
        tail->next = n;
        tail = n;
    }
}

void pushFront(DNode*& head, DNode*& tail, int value) {
    DNode* n = new DNode{value, nullptr, head};
    if (head == nullptr) head = tail = n;
    else {
        head->prev = n;
        head = n;
    }
}

// Insert so the new value ends up at 0-based `position`.
bool insertAt(DNode*& head, DNode*& tail, int position, int value) {
    if (position < 0) return false;
    if (position == 0) { pushFront(head, tail, value); return true; }

    DNode* before = head;
    for (int i = 0; i < position - 1 && before != nullptr; ++i) before = before->next;
    if (before == nullptr) return false;
    if (before == tail) { append(head, tail, value); return true; }

    DNode* after = before->next;
    DNode* n = new DNode{value, before, after};
    before->next = n;                  // forward link into the new node
    after->prev = n;                   // backward link into the new node
    return true;
}

void displayForward(DNode* head) {
    if (head == nullptr) { cout << "(empty)\n"; return; }
    for (DNode* p = head; p != nullptr; p = p->next) cout << p->data << ' ';
    cout << '\n';
}

void displayBackward(DNode* tail) {
    if (tail == nullptr) { cout << "(empty)\n"; return; }
    for (DNode* p = tail; p != nullptr; p = p->prev) cout << p->data << ' ';
    cout << '\n';
}

int search(DNode* head, int value) {
    int position = 0;
    for (DNode* p = head; p != nullptr; p = p->next, ++position)
        if (p->data == value) return position;
    return -1;
}

bool deleteValue(DNode*& head, DNode*& tail, int value) {
    DNode* target = head;
    while (target != nullptr && target->data != value) target = target->next;
    if (target == nullptr) return false;

    if (target->prev != nullptr) target->prev->next = target->next;
    else head = target->next;                       // deleting the head

    if (target->next != nullptr) target->next->prev = target->prev;
    else tail = target->prev;                       // deleting the tail

    delete target;
    return true;
}

void destroy(DNode*& head, DNode*& tail) {
    while (head != nullptr) {
        DNode* old = head;
        head = head->next;
        delete old;
    }
    tail = nullptr;
}

// The invariants the lab asks you to verify after every insertion and deletion.
bool invariantsHold(DNode* head, DNode* tail) {
    if (head == nullptr || tail == nullptr) return head == nullptr && tail == nullptr;
    if (head->prev != nullptr || tail->next != nullptr) return false;

    int forward = 0;
    DNode* last = nullptr;
    for (DNode* x = head; x != nullptr; x = x->next) {
        if (x->next != nullptr && x->next->prev != x) return false;   // x->next->prev == x
        last = x;
        ++forward;
    }
    int backward = 0;
    for (DNode* x = tail; x != nullptr; x = x->prev) ++backward;
    return last == tail && forward == backward;
}

string forwardContents(DNode* head) {
    string s;
    for (DNode* p = head; p != nullptr; p = p->next) s += to_string(p->data) + ' ';
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void show(const string& step, DNode* head, DNode* tail) {
    cout << step << "\n  forward:  "; displayForward(head);
    cout << "  backward: "; displayBackward(tail);
    check("next/prev invariants hold", invariantsHold(head, tail));
}

int main() {
    DNode* head = nullptr;
    DNode* tail = nullptr;

    cout << "== Empty and one-node lists ==\n";
    show("empty list", head, tail);
    check("search on an empty list reports not found", search(head, 5) == -1);
    check("delete on an empty list is refused", !deleteValue(head, tail, 5));
    append(head, tail, 5);
    show("append 5", head, tail);
    deleteValue(head, tail, 5);
    show("delete 5 (the only node)", head, tail);

    cout << "\n== Insertions at several positions ==\n";
    append(head, tail, 20);           show("append 20", head, tail);
    append(head, tail, 40);           show("append 40", head, tail);
    pushFront(head, tail, 10);        show("insert 10 at the head", head, tail);
    insertAt(head, tail, 2, 30);      show("insert 30 at position 2 (middle)", head, tail);
    insertAt(head, tail, 4, 50);      show("insert 50 at position 4 (tail)", head, tail);
    check("the list is 10 20 30 40 50", forwardContents(head) == "10 20 30 40 50 ");

    cout << "\n== Search ==\n";
    cout << "search(40) -> position " << search(head, 40) << '\n';
    cout << "search(99) -> " << search(head, 99) << " (not found)\n";
    check("found and not-found cases are both reported",
          search(head, 40) == 3 && search(head, 99) == -1);

    cout << "\n== Deletions ==\n";
    deleteValue(head, tail, 10);      show("delete 10 (head)", head, tail);
    check("deleting the head updates head", head->data == 20 && head->prev == nullptr);
    deleteValue(head, tail, 50);      show("delete 50 (tail)", head, tail);
    check("deleting the tail updates tail", tail->data == 40 && tail->next == nullptr);
    deleteValue(head, tail, 30);      show("delete 30 (middle)", head, tail);
    check("deleting a missing value is refused", !deleteValue(head, tail, 99));
    check("live nodes equal list length (deleted nodes were released)", DNode::live == 2);

    destroy(head, tail);
    check("destroying the list releases every node", DNode::live == 0);
    return 0;
}
