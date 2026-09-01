// Lab 8, Task 6 --- Quick sort, DESCENDING, median-element pivot
// (lab-manual problem 1).
//
// Two deliberate differences from the ascending quick sort in Task 3:
//
//   1. Direction: the partition keeps elements GREATER than the pivot on the
//      left, so the array ends up in descending order.
//   2. Pivot rule: the manual says "always select the median element of the
//      current array/subarray". This program reads that as the element at the
//      MIDDLE INDEX of the current range (the common classroom reading; the
//      statistical median would itself need a selection algorithm first).
//
// Build: g++ -std=c++17 -Wall -Wextra Task06.cpp -o task06

#include <iostream>
#include <utility>   // std::swap
#include <vector>

using namespace std;

// Partitions a[low..high] around the middle-index pivot so that everything
// >= pivot sits left of everything <= pivot. Returns the split point.
// (Hoare-style scan from both ends; robust when the pivot value repeats.)
int partitionDesc(vector<int>& a, int low, int high) {
    int pivot = a[low + (high - low) / 2];   // middle element of this range
    int i = low - 1, j = high + 1;

    while (true) {
        do { ++i; } while (a[i] > pivot);    // '>' keeps big values left
        do { --j; } while (a[j] < pivot);    // '<' keeps small values right
        if (i >= j) return j;
        swap(a[i], a[j]);
    }
}

void quickSortDesc(vector<int>& a, int low, int high) {
    if (low >= high) return;                 // 0 or 1 element: already sorted
    int split = partitionDesc(a, low, high);
    quickSortDesc(a, low, split);            // Hoare split: pivot may sit in
    quickSortDesc(a, split + 1, high);       // either side, ranges as shown
}

void show(const string& label, const vector<int>& a) {
    cout << label;
    for (int v : a) cout << v << ' ';
    cout << '\n';
}

int main() {
    vector<int> a = {56, 72, 30, 15, 78, 54, 90};
    show("Original array : ", a);
    quickSortDesc(a, 0, static_cast<int>(a.size()) - 1);
    show("Descending sort: ", a);

    cout << '\n';

    // Duplicates and an already-descending array are the classic traps.
    vector<int> b = {40, 10, 40, 25, 10, 40};
    show("With duplicates: ", b);
    quickSortDesc(b, 0, static_cast<int>(b.size()) - 1);
    show("Descending sort: ", b);

    cout << '\n';

    vector<int> c = {90, 78, 72, 56, 54, 30, 15};
    show("Already sorted : ", c);
    quickSortDesc(c, 0, static_cast<int>(c.size()) - 1);
    show("Still correct  : ", c);
    // The middle-index pivot splits a sorted array evenly, so this input is
    // the BEST case here --- the same input that ruins a first-element pivot.

    return 0;
}
