// Lab 8, Task 7 --- Merge THREE sorted arrays into one (lab-manual problem 3).
/*
   A: 2  9 34       \
   B: 5 11 12 40     >  merged: 1 2 5 8 9 11 12 34 40 77
   C: 1  8 77       /
*/
//
// Ordinary merge sort merges two runs; the only change here is that each
// step compares up to THREE front elements and takes the smallest. Every
// element is copied exactly once, so the cost is O(nA + nB + nC).
//
// Build: g++ -std=c++17 -Wall -Wextra Task07.cpp -o task07

#include <iostream>
#include <vector>

using namespace std;

vector<int> mergeThree(const vector<int>& a,
                       const vector<int>& b,
                       const vector<int>& c) {
    vector<int> out;
    out.reserve(a.size() + b.size() + c.size());
    size_t i = 0, j = 0, k = 0;

    while (i < a.size() || j < b.size() || k < c.size()) {
        // For each exhausted array, pretend its front is "infinity" so it
        // never wins the comparison; then take the smallest live front.
        bool aLive = i < a.size();
        bool bLive = j < b.size();
        bool cLive = k < c.size();

        // Start with any live candidate, then let the others challenge it.
        int which = aLive ? 0 : (bLive ? 1 : 2);
        if (bLive && (which != 1) && (!aLive || b[j] < a[i])) which = 1;
        if (cLive && ((which == 0 && c[k] < a[i]) ||
                      (which == 1 && c[k] < b[j]))) which = 2;

        if (which == 0)      out.push_back(a[i++]);
        else if (which == 1) out.push_back(b[j++]);
        else                 out.push_back(c[k++]);
    }
    return out;
}

void show(const string& label, const vector<int>& v) {
    cout << label;
    for (int x : v) cout << x << ' ';
    cout << '\n';
}

int main() {
    vector<int> a = {2, 9, 34};
    vector<int> b = {5, 11, 12, 40};
    vector<int> c = {1, 8, 77};

    show("A      : ", a);
    show("B      : ", b);
    show("C      : ", c);
    vector<int> merged = mergeThree(a, b, c);
    show("Merged : ", merged);

    // Verify: sorted, and the element count matches the inputs.
    bool sorted = true;
    for (size_t i = 1; i < merged.size(); ++i)
        if (merged[i - 1] > merged[i]) sorted = false;
    cout << "sorted: " << (sorted ? "yes" : "NO")
         << ", size " << merged.size() << " = "
         << a.size() + b.size() + c.size() << " inputs\n\n";

    // Edge cases: one empty array, and duplicated values across arrays.
    show("Merged with empty C   : ", mergeThree(a, b, {}));
    show("Merged with duplicates: ", mergeThree({1, 3, 3}, {3, 4}, {2, 3}));

    return 0;
}
