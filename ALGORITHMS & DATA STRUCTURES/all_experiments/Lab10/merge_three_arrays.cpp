// Lab 10 - Searching and sorting experiments
// Manual problem 3: modify the merge step of merge sort so it merges THREE
// sorted arrays into one. Instead of comparing two front elements, compare
// three and take the smallest; when one array runs out, fall back to merging
// the remaining two, then copy whatever is left.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra merge_three_arrays.cpp -o merge_three_arrays
//     ./merge_three_arrays

#include <algorithm>
#include <climits>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

vector<int> mergeThree(const vector<int>& a, const vector<int>& b,
                       const vector<int>& c) {
    const vector<int>* runs[] = {&a, &b, &c};
    size_t pos[] = {0, 0, 0};
    vector<int> out;
    out.reserve(a.size() + b.size() + c.size());
    while (true) {
        int best = -1;
        for (int r = 0; r < 3; ++r) {
            if (pos[r] == runs[r]->size()) continue; // exhausted: skip it
            if (best == -1 || (*runs[r])[pos[r]] < (*runs[best])[pos[best]])
                best = r;
        }
        if (best == -1) break;                       // all three exhausted
        out.push_back((*runs[best])[pos[best]]);
        ++pos[best];                                // advance only the winner
    }
    return out;
}

// The usual two-way merge, to check the result a second way.
vector<int> mergeTwo(const vector<int>& a, const vector<int>& b) {
    vector<int> out;
    size_t i = 0, j = 0;
    while (i < a.size() && j < b.size()) out.push_back(a[i] <= b[j] ? a[i++] : b[j++]);
    while (i < a.size()) out.push_back(a[i++]);
    while (j < b.size()) out.push_back(b[j++]);
    return out;
}

string show(const vector<int>& v) {
    string s;
    for (size_t i = 0; i < v.size(); ++i) s += to_string(v[i]) + (i + 1 < v.size() ? " " : "");
    return s.empty() ? "(empty)" : s;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void run(const vector<int>& a, const vector<int>& b, const vector<int>& c) {
    vector<int> merged = mergeThree(a, b, c);
    cout << "  A: " << show(a) << "\n  B: " << show(b) << "\n  C: " << show(c)
         << "\n  merged: " << show(merged) << '\n';

    vector<int> all = a;
    all.insert(all.end(), b.begin(), b.end());
    all.insert(all.end(), c.begin(), c.end());
    vector<int> expected = all;
    sort(expected.begin(), expected.end());

    check("the result is sorted", is_sorted(merged.begin(), merged.end()));
    check("every input value appears exactly once (no loss, no duplication)", merged == expected);
    check("it equals two successive two-way merges", merged == mergeTwo(mergeTwo(a, b), c));
}

int main() {
    cout << "== Three sorted arrays ==\n";
    run({1, 4, 9}, {2, 4, 7, 10}, {3, 5});

    cout << "\n== With duplicates across arrays ==\n";
    run({2, 2, 8}, {2, 6}, {1, 2, 9});

    cout << "\n== One array empty ==\n";
    run({5, 15}, {}, {10, 20, 30});
    cout << "\n== Largest integer and exhausted inputs ==\n";
    run({}, {INT_MAX}, {});
    run({INT_MAX}, {INT_MAX}, {});
    run({}, {}, {});
    return 0;
}
