// Lab 11 - Hashing and collision resolution
// The lab example H(x) = x mod 5 with keys 10, 12, 14 and then 15, whose home
// slot 0 collides with 10. The same collision is resolved three ways, and
// every probe index is recorded, not only the final slot:
//
//   linear probing     index_i = (h(k) + i)        mod m
//   quadratic probing  index_i = (h(k) + i*i)      mod m   (the slides' "quadratic hashing")
//   double hashing     index_i = (h1(k) + i*h2(k)) mod m,  h2(k) = 1 + (k mod (m-1))
//
// h2 is never 0, and with a prime table size m every step size is coprime to
// m, so a double-hash probe sequence can reach every slot. The formula for h2
// is Chapter 11's implementation example; the slides do not fix one.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra hashing_collisions.cpp -o hashing_collisions
//     ./hashing_collisions

#include <iomanip>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

const int EMPTY = -1;

enum class Method { Linear, Quadratic, Double };

string methodName(Method m) {
    switch (m) {
        case Method::Linear:    return "linear probing";
        case Method::Quadratic: return "quadratic probing";
        default:                return "double hashing";
    }
}

// The i-th slot to try for key in a table of size m.
int probeIndex(Method method, int key, int i, int m) {
    int h1 = key % m;
    switch (method) {
        case Method::Linear:    return (h1 + i) % m;
        case Method::Quadratic: return (h1 + i * i) % m;
        default: {
            int h2 = 1 + (key % (m - 1));
            return (h1 + i * h2) % m;
        }
    }
}

// Inserts key, recording every slot tried in probes. Returns the slot used,
// or -1 if m probes found no free slot.
int insertKey(vector<int>& table, Method method, int key, vector<int>& probes) {
    int m = static_cast<int>(table.size());
    probes.clear();
    for (int i = 0; i < m; ++i) {
        int idx = probeIndex(method, key, i, m);
        probes.push_back(idx);
        if (table[idx] == EMPTY) {
            table[idx] = key;
            return idx;
        }
    }
    return -1;
}

// Searching follows the SAME probe sequence as insertion and stops at the key
// or at an empty slot (where the key would have been placed).
int findKey(const vector<int>& table, Method method, int key) {
    int m = static_cast<int>(table.size());
    for (int i = 0; i < m; ++i) {
        int idx = probeIndex(method, key, i, m);
        if (table[idx] == key) return idx;
        if (table[idx] == EMPTY) return -1;
    }
    return -1;
}

string list(const vector<int>& v) {
    string s;
    for (size_t i = 0; i < v.size(); ++i) s += to_string(v[i]) + (i + 1 < v.size() ? " -> " : "");
    return s;
}

void printTable(const vector<int>& table) {
    cout << "  table: ";
    for (size_t i = 0; i < table.size(); ++i)
        cout << '[' << i << ':' << (table[i] == EMPTY ? string("-") : to_string(table[i])) << "] ";
    cout << '\n';
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    vector<int> keys = {10, 12, 14, 15};
    const int TABLE_SIZE = 5;
    const Method methods[] = {Method::Linear, Method::Quadratic, Method::Double};

    cout << "== H(x) = x mod " << TABLE_SIZE << ", keys 10 12 14 15 ==\n";
    for (Method method : methods) {
        cout << '\n' << methodName(method) << ":\n";
        vector<int> table(TABLE_SIZE, EMPTY);
        vector<int> probes;
        bool allFound = true, inRange = true;
        for (int key : keys) {
            int slot = insertKey(table, method, key, probes);
            cout << "  key " << setw(2) << key << "  home " << key % TABLE_SIZE
                 << "  probes " << left << setw(14) << list(probes) << right
                 << "  -> slot " << slot << '\n';
            for (int p : probes) inRange = inRange && p >= 0 && p < TABLE_SIZE;
        }
        printTable(table);
        for (int key : keys) allFound = allFound && findKey(table, method, key) != -1;
        check("every key is found again with the same probe rule", allFound);
        check("every probe index stayed inside the table", inRange);
    }

    cout << "\nThe collision: 15 mod 5 = 0, already holding 10. Linear probing steps\n"
         << "to slot 1; quadratic probing also tries 0 + 1*1 = 1; double hashing\n"
         << "steps by h2(15) = 1 + (15 mod 4) = 4, trying 0, then 4 (taken by 14),\n"
         << "then 3.\n";

    int smallestStep = TABLE_SIZE;
    for (int k = 0; k < 100; ++k) smallestStep = min(smallestStep, 1 + k % (TABLE_SIZE - 1));
    check("the double-hash step 1 + (k mod 4) is never 0", smallestStep >= 1);

    cout << "\n== Try it: a crowded table (m = 11) ==\n";
    const vector<int> more = {10, 12, 14, 15, 21, 32, 43, 54, 25, 36};
    cout << "  inserting " << more.size() << " keys that pile up on slots 10 and 3:";
    for (int k : more) cout << ' ' << k;
    cout << "\n\n  " << left << setw(20) << "method" << right;
    for (int k : more) cout << setw(4) << k;
    cout << "   total\n";
    for (Method method : methods) {
        vector<int> table(11, EMPTY);
        vector<int> probes;
        int total = 0;
        cout << "  " << left << setw(20) << methodName(method) << right;
        for (int key : more) {
            int slot = insertKey(table, method, key, probes);
            total += static_cast<int>(probes.size());
            cout << setw(4) << (slot == -1 ? string("x") : to_string(probes.size()));
        }
        cout << setw(8) << total << '\n';
    }
    cout << "  (probes needed per key; x = no free slot reached within m probes)\n\n"
         << "  Linear probing builds one long cluster, so later keys walk further.\n"
         << "  Quadratic probing jumps out of the cluster but only ever visits about\n"
         << "  half of the slots, so a crowded table can refuse a key with room left.\n"
         << "  Double hashing gives each key its own step and spreads the probes.\n";
    return 0;
}
