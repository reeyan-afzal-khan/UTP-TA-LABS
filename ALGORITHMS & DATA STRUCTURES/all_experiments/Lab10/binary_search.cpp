// Lab 10 - Searching and sorting experiments
// Manual problem 2: binary search, and a test of whether an element is present.
// Binary search is only valid on sorted input, so the program sorts the common
// dataset first and refuses to search data that is not sorted. Each probe is
// traced so the halving is visible.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra binary_search.cpp -o binary_search
//     ./binary_search

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

int binarySearch(const vector<int>& a, int target) {
    int left = 0;
    int right = static_cast<int>(a.size()) - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (a[mid] == target) return mid;
        if (target < a[mid]) right = mid - 1;
        else left = mid + 1;
    }
    return -1;
}

// The same search with every probe printed.
int tracedBinarySearch(const vector<int>& a, int target) {
    int left = 0;
    int right = static_cast<int>(a.size()) - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        cout << "    left=" << left << " right=" << right << " mid=" << mid
             << " a[mid]=" << a[mid];
        if (a[mid] == target) { cout << "  found\n"; return mid; }
        if (target < a[mid]) { cout << "  target smaller: discard the right half\n"; right = mid - 1; }
        else { cout << "  target larger: discard the left half\n"; left = mid + 1; }
    }
    cout << "    left > right: the range is empty, not found\n";
    return -1;
}

// With duplicates, binary search finds AN occurrence. Keeping on to the left
// after a match finds the FIRST one.
int firstOccurrence(const vector<int>& a, int target) {
    int left = 0, right = static_cast<int>(a.size()) - 1, found = -1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (a[mid] == target) { found = mid; right = mid - 1; }
        else if (target < a[mid]) right = mid - 1;
        else left = mid + 1;
    }
    return found;
}

// Refuses (returns -2) when the input is not sorted, so a wrong answer is
// never produced silently.
int searchSorted(const vector<int>& a, int target) {
    if (!is_sorted(a.begin(), a.end())) return -2;
    return binarySearch(a, target);
}

string show(const vector<int>& a) {
    string s;
    for (size_t i = 0; i < a.size(); ++i) s += to_string(a[i]) + (i + 1 < a.size() ? " " : "");
    return s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    vector<int> data = {29, 10, 14, 37, 13};
    cout << "common dataset: " << show(data) << '\n';
    check("searching the unsorted dataset is refused", searchSorted(data, 29) == -2);

    sort(data.begin(), data.end());
    cout << "sorted:         " << show(data) << "   (indexes 0..4)\n";

    cout << "\n== Search for 29 (present) ==\n";
    int at = tracedBinarySearch(data, 29);
    cout << "  result: index " << at << '\n';
    check("29 is found at index 3", at == 3 && searchSorted(data, 29) == 3);

    cout << "\n== Search for 15 (missing) ==\n";
    int miss = tracedBinarySearch(data, 15);
    cout << "  result: " << miss << '\n';
    check("a missing target returns -1", miss == -1);

    cout << "\n== Duplicates ==\n";
    vector<int> dup = {3, 5, 5, 5, 9};
    cout << "data: " << show(dup) << '\n';
    int any = binarySearch(dup, 5);
    int first = firstOccurrence(dup, 5);
    cout << "  binarySearch(5) -> index " << any << ",  firstOccurrence(5) -> index " << first << '\n';
    check("binary search finds an occurrence of a duplicated value", any != -1 && dup[any] == 5);
    check("the first-occurrence variant returns index 1", first == 1);
    check("a missing value between duplicates is still not found", binarySearch(dup, 4) == -1);
    return 0;
}
