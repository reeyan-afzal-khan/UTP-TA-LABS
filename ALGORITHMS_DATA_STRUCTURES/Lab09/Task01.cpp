// Lab 9, Task 1 --- One collision, three resolutions.
//
//   H(x) = x mod 5, table size 5, keys 10, 12, 14, then 15.
//
//   10 -> slot 0, 12 -> slot 2, 14 -> slot 4 ... then 15 -> slot 0: COLLISION.
//
// The three open-addressing strategies differ only in the probe sequence
// they try after the home slot is taken (i = attempt number 1, 2, 3, ...):
//
//   linear      : (home + i)            mod size   -- adjacent slots; clusters
//   quadratic   : (home + i*i)          mod size   -- spreads probes out
//   double hash : (home + i * h2(key))  mod size   -- step depends on the key
//
// with h2(key) = 1 + (key mod (size-1)), which can never be zero.
// Search must replay the SAME probe rule used at insertion --- that is why
// the strategy is a property of the whole table, not of one operation.
//
// Build: g++ -std=c++17 -Wall -Wextra Task01.cpp -o task01

#include <iostream>
#include <string>
#include <vector>

using namespace std;

const int EMPTY = -1;

class HashTable {
public:
    enum class Probe { Linear, Quadratic, DoubleHash };

private:
    vector<int> slots;
    Probe strategy;

    int home(int key) const { return key % static_cast<int>(slots.size()); }

    // Secondary hash for double hashing. Adding 1 keeps the step nonzero;
    // mod (size-1) keeps it inside the table.
    int h2(int key) const { return 1 + key % (static_cast<int>(slots.size()) - 1); }

    int step(int key, int i) const {
        switch (strategy) {
            case Probe::Linear:     return i;
            case Probe::Quadratic:  return i * i;
            default:                return i * h2(key);
        }
    }

public:
    HashTable(size_t size, Probe p) : slots(size, EMPTY), strategy(p) {}

    // Prints the full probe sequence, e.g. "15: probes 0, 1 -> slot 1".
    bool insert(int key) {
        int size = static_cast<int>(slots.size());
        cout << "  insert " << key << ": probes ";
        for (int i = 0; i < size; ++i) {
            int idx = (home(key) + step(key, i)) % size;
            cout << idx << (slots[idx] == EMPTY ? "" : "*");
            if (slots[idx] == EMPTY) {
                slots[idx] = key;
                cout << "  -> stored in slot " << idx << '\n';
                return true;
            }
            cout << ", ";
        }
        cout << " -> FAILED (no free slot reachable)\n";
        return false;
        // Note: quadratic probing is not guaranteed to visit every slot of an
        // arbitrary-size table, so it can fail even when a slot is free.
    }

    bool search(int key) const {
        int size = static_cast<int>(slots.size());
        for (int i = 0; i < size; ++i) {
            int idx = (home(key) + step(key, i)) % size;
            if (slots[idx] == key) return true;
            if (slots[idx] == EMPTY) return false;   // hole ends the sequence
        }
        return false;
    }

    void display() const {
        cout << "  table: [";
        for (size_t i = 0; i < slots.size(); ++i) {
            if (slots[i] == EMPTY) cout << " .";
            else cout << ' ' << slots[i];
        }
        cout << " ]\n";
    }
};

void runDemo(const string& name, HashTable::Probe p) {
    cout << "== " << name << " ==\n";
    HashTable t(5, p);

    // 10, 12, 14 land in empty home slots; 15 collides with 10 at slot 0.
    for (int key : {10, 12, 14, 15}) t.insert(key);
    t.display();

    // Crowd the table further: 20 also has home slot 0.
    t.insert(20);
    t.display();

    // Search must find every stored key by replaying the same probe rule.
    for (int key : {10, 15, 20, 99}) {
        cout << "  search " << key << ": "
             << (t.search(key) ? "found" : "not found") << '\n';
    }
    cout << '\n';
}

int main() {
    cout << "H(x) = x mod 5, table size 5, '*' marks an occupied probe\n\n";
    runDemo("Linear probing",   HashTable::Probe::Linear);
    runDemo("Quadratic probing (the source's 'quadratic hashing')",
            HashTable::Probe::Quadratic);
    runDemo("Double hashing, h2(x) = 1 + x mod 4", HashTable::Probe::DoubleHash);
    return 0;
}
