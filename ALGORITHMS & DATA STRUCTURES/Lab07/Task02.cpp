// Lab 7, Task 2 --- Adjacency list, BFS, DFS, and a path-length check.
//
//        0 --- 1     4
//        |   / |     |
//        |  /  |     |
//        | /   |     |
//        2 --- 3 --- 5
//
// The adjacency list stores, for each vertex, only the vertices it actually
// touches --- O(V + E) space, against O(V^2) for an adjacency matrix. That is
// the right trade for sparse graphs, which most real graphs are.
//
//   BFS uses a queue  -> visits by distance rings -> finds fewest-edge paths.
//   DFS uses a stack  -> (here: recursion, the call stack) -> dives deep first.
// Both need a visited[] array; on a graph with cycles, traversal without it
// never terminates.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

void addUndirectedEdge(vector<vector<int>>& adj, int u, int v) {
    adj[u].push_back(v);
    adj[v].push_back(u);
}

void bfs(const vector<vector<int>>& adj, int start) {
    vector<bool> visited(adj.size(), false);
    queue<int> q;
    visited[start] = true;
    q.push(start);

    cout << "BFS from " << start << ": ";
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        cout << u << ' ';
        for (int v : adj[u]) {
            if (!visited[v]) {
                visited[v] = true;   // mark when ENQUEUED, not when dequeued,
                q.push(v);           // or a vertex can enter the queue twice
            }
        }
    }
    cout << '\n';
}

void dfsVisit(const vector<vector<int>>& adj, int u, vector<bool>& visited) {
    visited[u] = true;
    cout << u << ' ';
    for (int v : adj[u])
        if (!visited[v]) dfsVisit(adj, v, visited);
}

void dfs(const vector<vector<int>>& adj, int start) {
    vector<bool> visited(adj.size(), false);
    cout << "DFS from " << start << ": ";
    dfsVisit(adj, start, visited);
    cout << '\n';
}

// Manual problem: does a path (walk) of exactly length k exist from u to v?
// Vertices may repeat --- an edge can be walked back and forth --- so this is
// a reachability-in-k-steps question, answered by trying every neighbour.
bool pathOfLength(const vector<vector<int>>& adj, int u, int v, int k) {
    if (k == 0) return u == v;
    for (int w : adj[u])
        if (pathOfLength(adj, w, v, k - 1)) return true;
    return false;
}

int main() {
    const int V = 6;
    vector<vector<int>> adj(V);
    addUndirectedEdge(adj, 0, 1);
    addUndirectedEdge(adj, 0, 2);
    addUndirectedEdge(adj, 1, 2);
    addUndirectedEdge(adj, 1, 3);
    addUndirectedEdge(adj, 2, 3);
    addUndirectedEdge(adj, 3, 5);
    addUndirectedEdge(adj, 4, 5);

    cout << "Adjacency list:\n";
    for (int u = 0; u < V; ++u) {
        cout << "  " << u << " : ";
        for (int v : adj[u]) cout << v << ' ';
        cout << '\n';
    }
    cout << '\n';

    bfs(adj, 0);
    dfs(adj, 0);
    // Same vertices, different order: BFS finishes ring by ring, DFS follows
    // one branch to the bottom before backtracking.

    cout << "\n-- Path-length checks --\n";
    struct Query { int u, v, k; } queries[] = {
        {0, 5, 3},   // 0-1-3-5 exists
        {0, 4, 4},   // 0-1-3-5-4 exists
        {0, 4, 2},   // too short: no
        {0, 0, 2},   // 0-1-0 walks back: yes
    };
    for (const auto& q : queries) {
        cout << "  walk of length " << q.k << " from " << q.u << " to " << q.v
             << " : " << (pathOfLength(adj, q.u, q.v, q.k) ? "yes" : "no") << '\n';
    }

    return 0;
}
