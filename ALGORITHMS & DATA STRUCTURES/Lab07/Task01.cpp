#include <iostream>
#include <vector>
#include <queue>
#include <climits>
using namespace std;

// each edge inidicates a node in a linkedlist 
struct EdgeNode {
    int vtx;
    int weight;
    EdgeNode* next;
    // constructor                      //initializer list    // initialize the variable delared upside to null
    EdgeNode(int vtx, int weight) : vtx(vtx), weight(weight), next(nullptr) {}
    // {} empty body because everything is included in the initializer list

    // EdgeNode(int vtx, int weight) {
    // this->vtx = vtx;
    // this->weight = weight;
    // this->next = nullptr; same thing 
    // }
};

class Graph {
    int V;
    EdgeNode** head;
    // static array 
    // EdgeNode — a struct type.
    // EdgeNode* — a pointer to one EdgeNode (e.g., the head of one vertex's linked list).
    // EdgeNode** — a pointer to an EdgeNode*. 
    // Since one EdgeNode* is a list head, 
    // a pointer to a bunch of those is effectively pointing at the start of an array of list heads.

public:
    Graph(int V) {
        this->V = V;
        head = new EdgeNode*[V];
        for (int i = 0; i < V; i++) {
            head[i] = nullptr;
        }
    }

    void addEdge(int u, int vtx, int weight) {
        EdgeNode* n1 = new EdgeNode (vtx, weight);
        n1->next = head[u];
        // n1's "next" = whatever was previously the head of u's list
        head[u] = n1;

        EdgeNode* n2 = new EdgeNode (u, weight);
        n2->next = head[vtx];
        head[vtx] = n2;
        // Both nodes represent the same edge, 
        // just recorded from each endpoint's point of view
    }

    // Pick the unvisited vertex with the smallest tentative distance.
    // Returns -1 when every remaining vertex is unreachable.
    int minDistance(const int* dist, const bool* visited) const {
        int minVal = INT_MAX, minIndex = -1;

        for (int i = 0; i < V; i++) {
            // Strictly less-than, and INT_MAX never qualifies: a vertex we
            // have found no route to must not be selected as the next one
            // to expand, because dist[u] + weight would then overflow.
            if (!visited[i] && dist[i] < minVal) {
                minVal = dist[i];
                minIndex = i;
            }
        }
        return minIndex;
    }

    // Caller owns the returned array and must delete[] it.
    int* dijkstra(int src) const {
        int* dist = new int[V];
        bool* visited = new bool[V];

        for (int i = 0; i < V; i++) {
            dist[i] = INT_MAX;   // no route found yet
            visited[i] = false;
        }
        dist[src] = 0;           // the distance from a vertex to itself

        for (int count = 0; count < V - 1; count++) {
            int u = minDistance(dist, visited);

            // Everything still unvisited is unreachable from src, so there
            // is nothing left to relax. Stopping here is what lets the
            // algorithm handle a disconnected graph.
            if (u == -1) break;

            visited[u] = true;

            // Relax every edge leaving u: if going through u reaches vtx
            // more cheaply than the best route known so far, record it.
            for (EdgeNode* current = head[u]; current != nullptr; current = current->next) {
                int vtx = current->vtx;
                int weight = current->weight;

                if (!visited[vtx] && dist[u] + weight < dist[vtx]) {
                    dist[vtx] = dist[u] + weight;
                }
            }
        }

        // visited was scratch space for this call only. The original code
        // returned dist and left this array allocated, leaking V bools on
        // every call.
        delete[] visited;
        return dist;
    }

    // The graph owns every EdgeNode it allocated, plus the array of list
    // heads. Without this destructor all of it leaks when the Graph goes
    // out of scope --- the pointers vanish but the memory stays reserved.
    ~Graph() {
        for (int i = 0; i < V; i++) {
            EdgeNode* current = head[i];
            while (current != nullptr) {
                EdgeNode* temp = current;
                current = current->next;   // step forward before freeing
                delete temp;
            }
        }
        delete[] head;
    }   

    // A copied Graph would share the same EdgeNode pointers, and both
    // copies would free them --- a double delete. Forbid copying outright.
    Graph(const Graph&)            = delete;
    Graph& operator=(const Graph&) = delete;
};

int main() {
    // 6 vertices, but vertex 5 is deliberately left unconnected so the
    // unreachable case is visible in the output.
    const int V = 6;
    Graph g(V);
    g.addEdge(0, 1, 4);
    g.addEdge(0, 2, 8);
    g.addEdge(1, 4, 6);
    g.addEdge(1, 2, 3);
    g.addEdge(2, 3, 2);
    g.addEdge(3, 4, 10);

    const int source = 0;
    int* dist = g.dijkstra(source);

    cout << "Shortest distance from vertex " << source << ":\n";
    for (int i = 0; i < V; i++) {
        cout << "  " << source << " -> " << i << " : ";

        // dist[i] is still INT_MAX for any vertex no path reaches. Printing
        // the raw number would show 2147483647, which reads like a real
        // distance rather than "no route exists".
        if (dist[i] == INT_MAX) cout << "unreachable\n";
        else                    cout << dist[i] << "\n";
    }

    delete[] dist;
    return 0;
}
