// Lab 9 - Graph representation, traversal, and spanning trees
// A minimum spanning tree of a weighted undirected graph by a greedy method.
//
// Algorithm used: KRUSKAL'S. Sort the edges by weight, then take each edge in
// turn unless it would close a cycle. A union-find structure answers "are
// these two vertices already connected?" in near-constant time. (The course
// leaves the choice open; Prim's algorithm is the other standard greedy MST.)
//
// The graph is Chapter 9's A-E example with weights added.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra minimum_spanning_tree.cpp -o minimum_spanning_tree
//     ./minimum_spanning_tree

#include <algorithm>
#include <iostream>
#include <numeric>
#include <string>
#include <vector>
using namespace std;

const string NAME = "ABCDE";

struct Edge {
    int u, v, weight;
};

// Union-find: each vertex points towards a representative of its component.
struct DisjointSet {
    vector<int> parent;
    explicit DisjointSet(int n) : parent(n) { iota(parent.begin(), parent.end(), 0); }
    int find(int x) { return parent[x] == x ? x : parent[x] = find(parent[x]); }
    bool unite(int a, int b) {             // false if already in one component
        a = find(a);
        b = find(b);
        if (a == b) return false;
        parent[a] = b;
        return true;
    }
};

string label(const Edge& e) {
    return string(1, NAME[e.u]) + "-" + NAME[e.v] + " (" + to_string(e.weight) + ")";
}

vector<Edge> kruskal(int V, vector<Edge> edges, bool trace) {
    sort(edges.begin(), edges.end(),
         [](const Edge& a, const Edge& b) { return a.weight < b.weight; });
    DisjointSet components(V);
    vector<Edge> tree;
    for (const Edge& e : edges) {
        bool joins = components.unite(e.u, e.v);
        if (trace)
            cout << "  " << label(e) << (joins ? "  accept" : "  reject: would close a cycle") << '\n';
        if (joins) tree.push_back(e);
        if (static_cast<int>(tree.size()) == V - 1) break;   // the tree is complete
    }
    return tree;
}

int totalWeight(const vector<Edge>& edges) {
    int sum = 0;
    for (const Edge& e : edges) sum += e.weight;
    return sum;
}

// A set of V-1 edges is a spanning tree when it joins every vertex without a cycle.
bool isSpanningTree(int V, const vector<Edge>& edges) {
    if (static_cast<int>(edges.size()) != V - 1) return false;
    DisjointSet ds(V);
    for (const Edge& e : edges)
        if (!ds.unite(e.u, e.v)) return false;                // a cycle
    for (int v = 1; v < V; ++v)
        if (ds.find(v) != ds.find(0)) return false;           // a vertex left out
    return true;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    const int V = 5;
    const vector<Edge> edges = {
        {0, 1, 4}, {0, 2, 2}, {0, 3, 5}, {1, 3, 3}, {1, 4, 6}, {2, 3, 1}, {3, 4, 7}
    };

    cout << "== Weighted undirected graph ==\n";
    for (const Edge& e : edges) cout << "  " << label(e) << '\n';

    cout << "\n== Kruskal: edges in increasing weight ==\n";
    vector<Edge> mst = kruskal(V, edges, true);

    cout << "\n== Minimum spanning tree ==\n";
    for (const Edge& e : mst) cout << "  " << label(e) << '\n';
    cout << "  total weight: " << totalWeight(mst) << '\n';

    check("the tree has |V| - 1 = 4 edges", mst.size() == V - 1);
    check("it includes every vertex and contains no cycle", isSpanningTree(V, mst));

    // Confirm the greedy answer is minimal by checking every 4-edge subset.
    int best = -1, spanningTrees = 0;
    const int E = static_cast<int>(edges.size());
    for (int mask = 0; mask < (1 << E); ++mask) {
        vector<Edge> pick;
        for (int i = 0; i < E; ++i) if (mask & (1 << i)) pick.push_back(edges[i]);
        if (!isSpanningTree(V, pick)) continue;
        ++spanningTrees;
        int w = totalWeight(pick);
        if (best == -1 || w < best) best = w;
    }
    cout << "  brute force: " << spanningTrees << " spanning trees, the lightest weighs " << best << '\n';
    check("no spanning tree is lighter than the greedy one", totalWeight(mst) == best);
    return 0;
}
