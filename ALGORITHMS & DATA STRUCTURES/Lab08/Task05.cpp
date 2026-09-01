// Lab 8, Task 5 --- Binary search (lab-manual problem 2).
//
//   sorted: 15 30 54 56 72 78 90
//   target 56?   low..high halves:  [15..90] -> [56..90] -> [56] found
//
// Binary search only works on SORTED input: comparing the target with the
// middle element tells you which half can be discarded, so each step halves
// the search space --- O(log n) against O(n) for a linear scan.
//
// Build: g++ -std=c++17 -Wall -Wextra Task05.cpp -o task05

#include <iostream>
#include <vector>

using namespace std;

// Returns the index of target, or -1. Prints each probe so the halving is
// visible in the output.
int binarySearch(const vector<int>& a, int target) {
    int low = 0, high = static_cast<int>(a.size()) - 1;

    while (low <= high) {
        int mid = low + (high - low) / 2;   // avoids overflow of (low+high)/2
        cout << "  probe index " << mid << " (value " << a[mid] << ")\n";

        if (a[mid] == target) return mid;
        if (a[mid] < target) low = mid + 1;   // discard the left half
        else high = mid - 1;                  // discard the right half
    }
    return -1;
}

void demo(const vector<int>& a, int target) {
    cout << "Searching for " << target << ":\n";
    int idx = binarySearch(a, target);
    if (idx >= 0) cout << "  -> found at index " << idx << "\n\n";
    else          cout << "  -> not present\n\n";
}

int main() {
    // The Lab 8 dataset after sorting (binary search requires sorted input).
    vector<int> a = {15, 30, 54, 56, 72, 78, 90};

    cout << "Sorted array: ";
    for (int v : a) cout << v << ' ';
    cout << "\n\n";

    demo(a, 56);   // present, middle-ish
    demo(a, 15);   // present, first element
    demo(a, 90);   // present, last element
    demo(a, 55);   // absent, inside the range
    demo(a, 99);   // absent, beyond the range

    // With duplicates, binary search returns A matching index --- not
    // necessarily the first one.
    vector<int> dup = {10, 20, 20, 20, 30};
    cout << "Array with duplicates: 10 20 20 20 30\n";
    demo(dup, 20);

    return 0;
}
