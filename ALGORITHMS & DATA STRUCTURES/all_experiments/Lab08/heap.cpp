// Lab 8 - BSTs, heaps, and balancing structures
// Binary heaps stored in an array: a max-heap built from 30, 10, 50, 20, 40
// with the array printed after every insertion, deletion of the root with the
// heap property restored, and a min-heap built from the same keys.
//
// In the array, the children of index i are at 2i+1 and 2i+2 and its parent
// is at (i-1)/2. Insertion sifts the new value UP; deleting the root moves the
// last value to the root and sifts it DOWN.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra heap.cpp -o heap
//     ./heap

#include <iostream>
#include <string>
#include <utility>
#include <vector>
using namespace std;

void pushMaxHeap(vector<int>& heap, int value) {
    heap.push_back(value);
    int i = static_cast<int>(heap.size()) - 1;

    while (i > 0) {
        int p = (i - 1) / 2;
        if (heap[p] >= heap[i]) break;
        swap(heap[p], heap[i]);
        i = p;
    }
}

bool popMaxHeap(vector<int>& heap, int& removed) {
    if (heap.empty()) return false;
    removed = heap[0];
    heap[0] = heap.back();
    heap.pop_back();

    int n = static_cast<int>(heap.size());
    int i = 0;
    while (true) {
        int largest = i, left = 2 * i + 1, right = 2 * i + 2;
        if (left < n && heap[left] > heap[largest]) largest = left;
        if (right < n && heap[right] > heap[largest]) largest = right;
        if (largest == i) break;
        swap(heap[i], heap[largest]);
        i = largest;
    }
    return true;
}

void pushMinHeap(vector<int>& heap, int value) {
    heap.push_back(value);
    int i = static_cast<int>(heap.size()) - 1;

    while (i > 0) {
        int p = (i - 1) / 2;
        if (heap[p] <= heap[i]) break;
        swap(heap[p], heap[i]);
        i = p;
    }
}

bool popMinHeap(vector<int>& heap, int& removed) {
    if (heap.empty()) return false;
    removed = heap[0];
    heap[0] = heap.back();
    heap.pop_back();

    int n = static_cast<int>(heap.size());
    int i = 0;
    while (true) {
        int smallest = i, left = 2 * i + 1, right = 2 * i + 2;
        if (left < n && heap[left] < heap[smallest]) smallest = left;
        if (right < n && heap[right] < heap[smallest]) smallest = right;
        if (smallest == i) break;
        swap(heap[i], heap[smallest]);
        i = smallest;
    }
    return true;
}

bool isMaxHeap(const vector<int>& h) {
    for (size_t i = 1; i < h.size(); ++i)
        if (h[(i - 1) / 2] < h[i]) return false;    // a parent smaller than a child
    return true;
}

bool isMinHeap(const vector<int>& h) {
    for (size_t i = 1; i < h.size(); ++i)
        if (h[(i - 1) / 2] > h[i]) return false;    // a parent larger than a child
    return true;
}

string show(const vector<int>& h) {
    string s = "[";
    for (size_t i = 0; i < h.size(); ++i) s += (i ? " " : "") + to_string(h[i]);
    return s + "]";
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    const vector<int> keys = {30, 10, 50, 20, 40};
    int removed = 0;

    cout << "== Max-heap: insert 30, 10, 50, 20, 40 ==\n";
    vector<int> maxHeap;
    bool alwaysMax = true;
    for (int k : keys) {
        pushMaxHeap(maxHeap, k);
        cout << "  insert " << k << " -> " << show(maxHeap) << '\n';
        alwaysMax = alwaysMax && isMaxHeap(maxHeap);
    }
    check("after every insertion no parent is smaller than a child", alwaysMax);
    check("final max-heap is [50 40 30 10 20]", show(maxHeap) == "[50 40 30 10 20]");

    cout << "\n== Max-heap: delete the root twice ==\n";
    for (int r = 0; r < 2; ++r) {
        popMaxHeap(maxHeap, removed);
        cout << "  removed " << removed << " -> " << show(maxHeap) << '\n';
        check("heap property restored after deletion", isMaxHeap(maxHeap));
    }

    cout << "\n== Min-heap from the same keys ==\n";
    vector<int> minHeap;
    bool alwaysMin = true;
    for (int k : keys) {
        pushMinHeap(minHeap, k);
        cout << "  insert " << k << " -> " << show(minHeap) << '\n';
        alwaysMin = alwaysMin && isMinHeap(minHeap);
    }
    check("after every insertion no parent is larger than a child", alwaysMin);

    cout << "\n== Min-heap: delete the root until empty ==\n  removed in order:";
    string order;
    while (popMinHeap(minHeap, removed)) order += " " + to_string(removed);
    cout << order << '\n';
    check("roots come out in ascending order: 10 20 30 40 50", order == " 10 20 30 40 50");
    check("deleting from an empty heap is refused", !popMinHeap(minHeap, removed));

    cout << "\nThe same keys give different arrays: a max-heap puts the largest key at\n"
         << "index 0, a min-heap the smallest. Neither array is sorted; only each parent\n"
         << "is ordered against its own children. Insertion and deletion each move a\n"
         << "value along one root-to-leaf path, so they cost O(height) = O(log n).\n";
    return 0;
}
