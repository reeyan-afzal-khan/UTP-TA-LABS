// Lab 10 - Searching and sorting experiments
// Manual problem 1: quick sort into DESCENDING order, always choosing the
// median element of the current subarray as the pivot.
//
// Interpretation: "median element" is taken as the element at the MIDDLE
// INDEX, (low + high) / 2, not the statistical median value. That pivot is
// swapped to the end of the range and the range is partitioned so that values
// >= pivot come first. Follow your instructor if they mean the median value.
//
// The program counts comparisons and swaps on the common dataset so they can
// be set against heap sort (heap_sort.cpp).
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra quick_sort_descending.cpp -o quick_sort_descending
//     ./quick_sort_descending

#include <algorithm>
#include <functional>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

long comparisons = 0, swaps = 0;
bool tracing = false;

string show(const vector<int>& a, int low = 0, int high = -1) {
    if (high < 0) high = static_cast<int>(a.size()) - 1;
    string s;
    for (int i = 0; i < static_cast<int>(a.size()); ++i) {
        if (i == low) s += "[";
        s += to_string(a[i]);
        if (i == high) s += "]";
        if (i + 1 < static_cast<int>(a.size())) s += " ";
    }
    return s;
}

void countedSwap(vector<int>& a, int i, int j) {
    if (i != j) { swap(a[i], a[j]); ++swaps; }
}

int partitionDescending(vector<int>& a, int low, int high) {
    int mid = low + (high - low) / 2;
    int pivot = a[mid];
    countedSwap(a, mid, high);                // park the pivot at the end

    int i = low - 1;                          // a[low..i] holds values >= pivot
    for (int j = low; j < high; ++j) {
        ++comparisons;
        if (a[j] >= pivot) {
            ++i;
            countedSwap(a, i, j);
        }
    }
    countedSwap(a, i + 1, high);              // drop the pivot into its final place
    if (tracing)
        cout << "  pivot " << pivot << " (middle of " << low << ".." << high << ") -> "
             << show(a, low, high) << "   pivot now at index " << i + 1 << '\n';
    return i + 1;
}

void quickSortDescending(vector<int>& a, int low, int high) {
    if (low >= high) return;
    int p = partitionDescending(a, low, high);
    quickSortDescending(a, low, p - 1);
    quickSortDescending(a, p + 1, high);
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

// Sorts a copy, then checks it is descending and holds exactly the same values.
bool sortsCorrectly(vector<int> a) {
    vector<int> original = a;
    quickSortDescending(a, 0, static_cast<int>(a.size()) - 1);
    sort(original.begin(), original.end(), greater<int>());
    return a == original;
}

int main() {
    vector<int> data = {29, 10, 14, 37, 13};
    cout << "== Trace on the common dataset ==\n";
    cout << "  start: " << show(data) << "   ([ ] marks the range being partitioned)\n";
    tracing = true;
    quickSortDescending(data, 0, static_cast<int>(data.size()) - 1);
    tracing = false;
    cout << "  result: " << show(data) << '\n';
    cout << "  comparisons: " << comparisons << ", swaps: " << swaps << '\n';
    check("the result is in descending order", is_sorted(data.begin(), data.end(), greater<int>()));

    cout << "\n== More inputs ==\n";
    check("duplicates: 5 3 5 1 5 9 3", sortsCorrectly({5, 3, 5, 1, 5, 9, 3}));
    check("already ascending: 1 2 3 4 5 6", sortsCorrectly({1, 2, 3, 4, 5, 6}));
    check("already descending: 6 5 4 3 2 1", sortsCorrectly({6, 5, 4, 3, 2, 1}));
    check("all equal: 7 7 7 7", sortsCorrectly({7, 7, 7, 7}));
    check("one element and empty input", sortsCorrectly({42}) && sortsCorrectly({}));

    cout << "\nThe middle-index pivot keeps already-sorted input from producing the\n"
         << "worst case that a last-element pivot gives: each partition still splits\n"
         << "the range near its centre.\n";
    return 0;
}
