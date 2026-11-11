// Lab 10 - Searching and sorting experiments
// Manual problem 4: heap sort. Build a max-heap in the array, then repeatedly
// swap the root (the largest value) to the end of the unsorted region and
// restore the heap in what remains. The array is printed after every
// extraction, and the heap property of the remaining region is checked.
//
// Comparisons and swaps are counted on the common dataset so they can be set
// against quick sort (quick_sort_descending.cpp).
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra heap_sort.cpp -o heap_sort
//     ./heap_sort

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

long comparisons = 0, swaps = 0;

void heapify(vector<int>& a, int n, int i) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < n)  { ++comparisons; if (a[left] > a[largest]) largest = left; }
    if (right < n) { ++comparisons; if (a[right] > a[largest]) largest = right; }

    if (largest != i) {
        swap(a[i], a[largest]);
        ++swaps;
        heapify(a, n, largest);
    }
}

bool isMaxHeap(const vector<int>& a, int n) {
    for (int i = 1; i < n; ++i)
        if (a[(i - 1) / 2] < a[i]) return false;
    return true;
}

string show(const vector<int>& a, int heapSize) {
    string s;
    for (int i = 0; i < static_cast<int>(a.size()); ++i) {
        if (i == heapSize) s += "| ";
        s += to_string(a[i]) + ' ';
    }
    return s;
}

// Returns false if the heap property ever fails during extraction.
bool heapSort(vector<int>& a, bool trace) {
    int n = static_cast<int>(a.size());
    for (int i = n / 2 - 1; i >= 0; --i)
        heapify(a, n, i);
    if (trace) cout << "  after building the max-heap: " << show(a, n) << '\n';

    bool heapHeld = isMaxHeap(a, n);
    for (int end = n - 1; end > 0; --end) {
        swap(a[0], a[end]);
        ++swaps;
        heapify(a, end, 0);
        heapHeld = heapHeld && isMaxHeap(a, end);
        if (trace) cout << "  extract " << a[end] << " -> " << show(a, end) << '\n';
    }
    return heapHeld;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

bool sortsCorrectly(vector<int> a) {
    vector<int> expected = a;
    sort(expected.begin(), expected.end());
    bool held = heapSort(a, false);
    return held && a == expected;
}

int main() {
    vector<int> data = {29, 10, 14, 37, 13};
    cout << "== Heap sort on the common dataset (heap | sorted tail) ==\n";
    cout << "  start: " << show(data, static_cast<int>(data.size())) << '\n';
    bool held = heapSort(data, true);
    cout << "  result: " << show(data, static_cast<int>(data.size())) << '\n';
    cout << "  comparisons: " << comparisons << ", swaps: " << swaps << '\n';
    check("the result is in ascending order", is_sorted(data.begin(), data.end()));
    check("the heap property held in the unsorted region after every extraction", held);

    cout << "\n== More inputs ==\n";
    check("duplicates: 5 3 5 1 5 9 3", sortsCorrectly({5, 3, 5, 1, 5, 9, 3}));
    check("already sorted: 1 2 3 4 5 6", sortsCorrectly({1, 2, 3, 4, 5, 6}));
    check("reverse sorted: 6 5 4 3 2 1", sortsCorrectly({6, 5, 4, 3, 2, 1}));
    check("one element and empty input", sortsCorrectly({42}) && sortsCorrectly({}));
    return 0;
}
