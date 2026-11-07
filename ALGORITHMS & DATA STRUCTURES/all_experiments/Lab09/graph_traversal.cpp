// Lab 9 - Graph representation, traversal, and spanning trees
// An undirected graph stored as an adjacency list, traversed with BFS (a
// queue) and DFS (recursion, and an explicit stack), and the lab manual's
// path test: does a path of a given length exist between two vertices?
//
// The graph is Chapter 9's example: A=0, B=1, C=2, D=3, E=4 with edges
// A-B, A-C, A-D, B-D, B-E, C-D, D-E.
//
// "A path of length k" is taken here as a SIMPLE path - no vertex repeated -
// with exactly k edges. Follow your instructor if they mean a walk instead.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra graph_traversal.cpp -o graph_traversal
//     ./graph_traversal

#include <algorithm>
#include <iostream>
#include <queue>
#include <stack>
#include <string>
#include <vector>
using namespace std;

const string NAME = "ABCDE";

void addUndirectedEdge(vector<vector<int>>& adj, int u, int v) {
    adj[u].push_back(v);
    adj[v].push_back(u);
}

vector<int> bfs(const vector<vector<int>>& adj, int start) {
    vector<bool> visited(adj.size(), false);
    vector<int> order;
    queue<int> q;

    visited[start] = true;
    q.push(start);

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        order.push_back(u);

        for (int v : adj[u]) {
            if (!visited[v]) {
                visited[v] = true;
                q.push(v);
            }
        }
    }
    return order;
}

void dfs(const vector<vector<int>>& adj,
         int u, vector<bool>& visited, vector<int>& order) {
    visited[u] = true;
    order.push_back(u);

    for (int v : adj[u]) {
        if (!visited[v]) dfs(adj, v, visited, order);
    }
}

// The same depth-first order with an explicit stack instead of recursion.
// Neighbours are pushed in reverse so the first one is explored first.
vector<int> dfsStack(const vector<vector<int>>& adj, int start) {
    vector<bool> visited(adj.size(), false);
    vector<int> order;
    stack<int> st;
    st.push(start);
    while (!st.empty()) {
        int u = st.top();
        st.pop();
        if (visited[u]) continue;
        visited[u] = true;
        order.push_back(u);
        for (auto it = adj[u].rbegin(); it != adj[u].rend(); ++it)
            if (!visited[*it]) st.push(*it);
    }
    return order;
}

// Backtracking search for a simple path from u to target with exactly
// remaining more edges. path holds the vertices chosen so far.
bool pathOfLength(const vector<vector<int>>& adj, int u, int target, int remaining,
                  vector<bool>& onPath, vector<int>& path) {
    if (remaining == 0) return u == target;
    for (int v : adj[u]) {
        if (onPath[v]) continue;                    // simple path: no vertex twice
        onPath[v] = true;
        path.push_back(v);
        if (pathOfLength(adj, v, target, remaining - 1, onPath, path)) return true;
        path.pop_back();                            // undo and try the next neighbour
        onPath[v] = false;
    }
    return false;
}

string names(const vector<int>& vs) {
    string s;
    for (int v : vs) s += string(1, NAME[v]) + ' ';
    return s;
}

void printAdjacency(const vector<vector<int>>& adj) {
    for (size_t u = 0; u < adj.size(); ++u)
        cout << "  " << NAME[u] << ": " << names(adj[u]) << '\n';
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

int main() {
    const int V = 5;
    const vector<pair<int, int>> edges = {{0,1}, {0,2}, {0,3}, {1,3}, {1,4}, {2,3}, {3,4}};

    vector<vector<int>> adj(V);
    for (auto [u, v] : edges) addUndirectedEdge(adj, u, v);

    cout << "== Adjacency list (" << V << " vertices, " << edges.size() << " edges) ==\n";
    printAdjacency(adj);

    bool symmetric = true;
    size_t degreeSum = 0;
    for (int u = 0; u < V; ++u) {
        degreeSum += adj[u].size();
        for (int v : adj[u])
            if (count(adj[v].begin(), adj[v].end(), u) != 1) symmetric = false;
    }
    check("every edge is stored in both endpoints' lists exactly once (undirected)", symmetric);
    check("the degree sum is twice the edge count", degreeSum == 2 * edges.size());

    cout << "\n== Traversals from A ==\n";
    vector<int> b = bfs(adj, 0);
    vector<bool> seen(V, false);
    vector<int> d;
    dfs(adj, 0, seen, d);
    vector<int> ds = dfsStack(adj, 0);
    cout << "  BFS (queue):          " << names(b) << '\n';
    cout << "  DFS (recursion):      " << names(d) << '\n';
    cout << "  DFS (explicit stack): " << names(ds) << '\n';
    check("BFS gives A B C D E: all of A's neighbours before E", names(b) == "A B C D E ");
    check("DFS gives A B D C E: it follows one branch as deep as it can", names(d) == "A B D C E ");
    check("recursive and explicit-stack DFS agree", d == ds);
    check("each vertex is visited exactly once although the graph has cycles",
          b.size() == V && d.size() == V);

    cout << "\n== Try it: reverse every adjacency list and traverse again ==\n";
    vector<vector<int>> rev = adj;
    for (auto& list : rev) reverse(list.begin(), list.end());
    printAdjacency(rev);
    vector<int> b2 = bfs(rev, 0);
    vector<bool> seen2(V, false);
    vector<int> d2;
    dfs(rev, 0, seen2, d2);
    cout << "  BFS: " << names(b2) << "   DFS: " << names(d2) << '\n';
    check("the visiting ORDER changes with the list order", b2 != b && d2 != d);
    vector<int> sb = b, sb2 = b2;
    sort(sb.begin(), sb.end());
    sort(sb2.begin(), sb2.end());
    check("the SET of vertices reached does not", sb == sb2);

    cout << "\n== Path of a given length from A to E ==\n";
    for (int k = 1; k <= 5; ++k) {
        vector<bool> onPath(V, false);
        vector<int> path = {0};
        onPath[0] = true;
        bool found = pathOfLength(adj, 0, 4, k, onPath, path);
        cout << "  length " << k << ": " << (found ? "yes, " + names(path) : string("no")) << '\n';
    }
    vector<bool> on(V, false);
    vector<int> p = {0};
    on[0] = true;
    check("no path of length 1 (A and E are not adjacent)", !pathOfLength(adj, 0, 4, 1, on, p));
    p = {0}; on.assign(V, false); on[0] = true;
    check("a path of length 4 visits all five vertices", pathOfLength(adj, 0, 4, 4, on, p) && p.size() == 5);
    p = {0}; on.assign(V, false); on[0] = true;
    check("no simple path of length 5 exists in a 5-vertex graph", !pathOfLength(adj, 0, 4, 5, on, p));
    return 0;
}
