// Lab 6, Task 3 --- Max-heap and min-heap in an array.
//
// A heap is a COMPLETE binary tree (every level full except possibly the
// last, which fills left to right), so the array representation from Task 2
// wastes nothing: parent(i)=(i-1)/2, children at 2i+1 and 2i+2.
//
//   Max-heap rule: parent >= both children  ->  the maximum sits at index 0.
//   Min-heap rule: parent <= both children  ->  the minimum sits at index 0.
//
// Insert: append at the end (keeps completeness), then "bubble up" while the
// rule is violated. Delete-root: move the last element to index 0, shrink,
// then "sift down" toward the larger (max) / smaller (min) child.
// Both repairs follow one root-to-leaf path, so they cost O(log n).
//
// Build: g++ -std=c++17 -Wall -Wextra Task03.cpp -o task03

#include <iostream>
#include <vector>

using namespace std;

class Heap {
private:
    vector<int> a;
    bool isMax;   // one implementation serves both rules via compare()

    // "true when x should sit above y" --- the only line that differs
    // between a max-heap and a min-heap.
    bool compare(int x, int y) const { return isMax ? x > y : x < y; }

    void bubbleUp(size_t i) {
        while (i > 0) {
            size_t parent = (i - 1) / 2;
            if (!compare(a[i], a[parent])) break;   // rule satisfied
            swap(a[i], a[parent]);
            i = parent;
        }
    }

    void siftDown(size_t i) {
        while (true) {
            size_t best = i, l = 2 * i + 1, r = 2 * i + 2;
            if (l < a.size() && compare(a[l], a[best])) best = l;
            if (r < a.size() && compare(a[r], a[best])) best = r;
            if (best == i) break;                   // rule satisfied
            swap(a[i], a[best]);
            i = best;
        }
    }

public:
    explicit Heap(bool maxHeap) : isMax(maxHeap) {}

    void insert(int value) {
        a.push_back(value);
        bubbleUp(a.size() - 1);
        cout << "insert " << value << "  ->  ";
        display();
    }

    void deleteRoot() {
        if (a.empty()) {
            cout << "Heap is empty, nothing to delete.\n";
            return;
        }
        cout << "delete root " << a[0] << "  ->  ";
        a[0] = a.back();   // last element fills the hole, completeness kept
        a.pop_back();
        if (!a.empty()) siftDown(0);
        display();
    }

    void display() const {
        cout << "[ ";
        for (int v : a) cout << v << ' ';
        cout << "]\n";
    }

    bool empty() const { return a.empty(); }

    // Checks the heap rule at every parent --- used to verify after changes.
    bool valid() const {
        for (size_t i = 0; i < a.size(); ++i) {
            size_t l = 2 * i + 1, r = 2 * i + 2;
            if (l < a.size() && compare(a[l], a[i])) return false;
            if (r < a.size() && compare(a[r], a[i])) return false;
        }
        return true;
    }
};

int main() {
    // Insertion order from the lab sheet: 30, 10, 50, 20, 40
    cout << "-- Max-heap: array printed after every insertion --\n";
    Heap maxHeap(true);
    for (int v : {30, 10, 50, 20, 40}) maxHeap.insert(v);
    cout << "heap property holds: " << (maxHeap.valid() ? "yes" : "NO") << "\n\n";

    cout << "-- Min-heap built from the same keys --\n";
    Heap minHeap(false);
    for (int v : {30, 10, 50, 20, 40}) minHeap.insert(v);
    cout << "heap property holds: " << (minHeap.valid() ? "yes" : "NO") << "\n\n";

    cout << "-- Deleting from the max-heap drains keys in sorted order --\n";
    while (!maxHeap.empty()) maxHeap.deleteRoot();
    maxHeap.deleteRoot();   // underflow case

    return 0;
}
