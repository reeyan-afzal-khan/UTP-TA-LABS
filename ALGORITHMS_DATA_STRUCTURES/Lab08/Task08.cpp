// Lab 8, Task 8 --- Heap sort (lab-manual problem 4).
//
// Two phases, both in-place inside the one array:
//
//   1. BUILD a max-heap: sift down every non-leaf, starting from the last
//      one (index n/2 - 1) back to the root. After this, a[0] is the max.
//   2. EXTRACT repeatedly: swap a[0] (current max) with the last unsorted
//      slot, shrink the heap by one, sift the new root down. The sorted
//      region grows from the RIGHT end while the heap shrinks on the left.
//
// Every extraction costs O(log n), so the whole sort is O(n log n) in every
// case --- heap sort has no bad input, unlike quick sort.
//
// Build: g++ -std=c++17 -Wall -Wextra Task08.cpp -o task08

#include <iostream>
#include <utility>   // std::swap
#include <vector>

using namespace std;

// Restore the max-heap rule at index i, treating only a[0..size-1] as heap.
void siftDown(vector<int>& a, int size, int i) {
    while (true) {
        int largest = i, l = 2 * i + 1, r = 2 * i + 2;
        if (l < size && a[l] > a[largest]) largest = l;
        if (r < size && a[r] > a[largest]) largest = r;
        if (largest == i) return;
        swap(a[i], a[largest]);
        i = largest;
    }
}

void show(const string& label, const vector<int>& a) {
    cout << label;
    for (int v : a) cout << v << ' ';
    cout << '\n';
}

void heapSort(vector<int>& a) {
    int n = static_cast<int>(a.size());

    // Phase 1: leaves are already valid one-element heaps, so start at the
    // last parent and walk back to the root.
    for (int i = n / 2 - 1; i >= 0; --i) siftDown(a, n, i);
    show("After build-heap : ", a);

    // Phase 2: peel the maximum off into the sorted tail.
    for (int end = n - 1; end > 0; --end) {
        swap(a[0], a[end]);      // move current max to its final slot
        siftDown(a, end, 0);     // heap is now a[0..end-1]; repair the root
    }
}

int main() {
    vector<int> a = {56, 72, 30, 15, 78, 54, 90};
    show("Original array   : ", a);
    heapSort(a);
    show("Heap-sorted      : ", a);

    cout << '\n';

    vector<int> b = {5, 1, 5, 2, 5, 0};
    show("With duplicates  : ", b);
    heapSort(b);
    show("Heap-sorted      : ", b);

    return 0;
}
