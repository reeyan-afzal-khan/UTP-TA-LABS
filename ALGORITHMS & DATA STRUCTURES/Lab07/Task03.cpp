// Lab 7, Task 3 --- Minimum spanning tree with Prim's algorithm.
//
// (The lab sheet asks for "a greedy approach" without naming one; this file
// uses PRIM'S: grow one tree from a start vertex, always adding the cheapest
// edge that connects a new vertex. Kruskal's --- sort all edges, add unless a
// cycle forms --- is the other standard greedy answer.)
//
//            2       3
//        0 ----- 1 ----- 2
//        |      /|       |
//      6 |   8 / | 5     | 7
//        |    /  |       |
//        3 --    4 ------
//              9
//
// An MST touches every vertex, contains no cycle, and among all such trees
// has minimum total weight. For V vertices it always has exactly V-1 edges.
//
// Build: g++ -std=c++17 -Wall -Wextra Task03.cpp -o task03

#include <iostream>
#include <vector>
#include <climits>

using namespace std;

struct Edge {
    int to;
    int weight;
};

int main() {
    const int V = 5;
    vector<vector<Edge>> adj(V);
    auto addEdge = [&](int u, int v, int w) {
        adj[u].push_back({v, w});
        adj[v].push_back({u, w});
    };
    addEdge(0, 1, 2);
    addEdge(0, 3, 6);
    addEdge(1, 2, 3);
    addEdge(1, 3, 8);
    addEdge(1, 4, 5);
    addEdge(2, 4, 7);
    addEdge(3, 4, 9);

    // key[v]    = cheapest edge weight seen that could attach v to the tree
    // parent[v] = the tree end of that cheapest edge
    // inTree[v] = v is already connected
    vector<int>  key(V, INT_MAX);
    vector<int>  parent(V, -1);
    vector<bool> inTree(V, false);
    key[0] = 0;   // start growing from vertex 0

    for (int step = 0; step < V; ++step) {
        // Greedy choice: the cheapest not-yet-connected vertex.
        // (A priority queue would find it in O(log V); the linear scan keeps
        // the algorithm's shape visible and is fine for small V.)
        int u = -1;
        for (int v = 0; v < V; ++v)
            if (!inTree[v] && (u == -1 || key[v] < key[u])) u = v;

        inTree[u] = true;

        // Every edge out of u may now offer some vertex a cheaper attachment.
        for (const Edge& e : adj[u]) {
            if (!inTree[e.to] && e.weight < key[e.to]) {
                key[e.to] = e.weight;
                parent[e.to] = u;
            }
        }
    }

    cout << "MST edges chosen by Prim's algorithm (started at vertex 0):\n";
    int total = 0;
    for (int v = 1; v < V; ++v) {
        cout << "  " << parent[v] << " -- " << v
             << "   (weight " << key[v] << ")\n";
        total += key[v];
    }
    cout << "Total weight: " << total << '\n';
    cout << "Edge count  : " << V - 1 << " = V-1, as an MST must have\n";

    return 0;
}
