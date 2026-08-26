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

    int minDistance(int* dist, bool* visited) {
        int minVal = INT_MAX, minIndex = -1; 

        for (int i = 0; i < V; i++) {
            if (!visited[i] && dist[i] <= minVal) {
                minVal = dist[i];
                minIndex = i;
            }
        }
        return minIndex;
    }

    int* dijkstra(int src) {
        int* dist = new int[V];
        bool* visited = new bool[V];

        for (int i = 0; i < V; i++) {
            dist[i] = INT_MAX;
            visited[i] = false;
        }
        dist[src] = 0;
        // distance with itself is zero

        for (int count = 0; count < V - 1; count++) {
            int u = minDistance(dist, visited);
            // find the smallest inside dist,return its index into u
            visited[u] = true;

            for (EdgeNode* current = head[u]; current != nullptr; current = current->next) {
                int vtx = current->vtx;
                int weight = current->weight;

                if (!visited[vtx] && dist[u] != INT_MAX && dist[u] + weight < dist[vtx]) {
                    dist[vtx] = dist[u] + weight;
                }
            }
        }
        return dist;
    }

    // a desctructor is a special member function that is executed when an object of the class 
    //goes out of scope or is explicitly deleted.
    ~Graph() {
        // to prevent memory leak
        // without this C++ will forget about the head pointer 
        // and every EdgeNode that was created with new.
        // still refer " in use "
        for (int i = 0; i < V; i++) {
            EdgeNode* current = head[i];
            while (current != nullptr) {
                EdgeNode* temp = current;
                current = current->next;
                delete temp;
            }
        }
        delete[] head;
    }   
};

int main() {
    Graph g(5);
    g.addEdge(0, 1, 4);
    g.addEdge(0, 2, 8);
    g.addEdge(1, 4, 6);
    g.addEdge(1, 2, 3);
    g.addEdge(2, 3, 2);
    g.addEdge(3, 4, 10);

    int* result = g.dijkstra(0);

    for (int i = 0; i < 5; i++)
        cout << result[i] << " ";
    cout << "\n";

    delete[] result;
    return 0;
}
