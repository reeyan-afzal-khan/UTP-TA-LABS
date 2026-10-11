// Lab 2 - Arrays, multidimensional storage, and matrices
// The "Try it yourself" operations on a square matrix: row sums, column sums,
// transpose, largest element, diagonal sum, and a symmetry check. Every one is
// a nested loop over the same two-dimensional array; what changes is which
// index the inner loop varies.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra matrix_operations.cpp -o matrix_operations
//     ./matrix_operations

#include <iostream>
#include <iomanip>
using namespace std;

const int N = 3;

void printMatrix(const char* name, const int M[N][N]) {
    cout << name << '\n';
    for (int r = 0; r < N; ++r) {
        for (int c = 0; c < N; ++c) cout << setw(5) << M[r][c];
        cout << '\n';
    }
}

void rowSums(const int M[N][N]) {
    for (int r = 0; r < N; ++r) {
        int sum = 0;
        for (int c = 0; c < N; ++c) sum += M[r][c];      // column varies inside a row
        cout << "  row " << r << " sum = " << sum << '\n';
    }
}

void columnSums(const int M[N][N]) {
    for (int c = 0; c < N; ++c) {
        int sum = 0;
        for (int r = 0; r < N; ++r) sum += M[r][c];      // row varies inside a column
        cout << "  column " << c << " sum = " << sum << '\n';
    }
}

void transpose(const int M[N][N], int T[N][N]) {
    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c)
            T[c][r] = M[r][c];
}

int largest(const int M[N][N]) {
    int best = M[0][0];
    for (int r = 0; r < N; ++r)
        for (int c = 0; c < N; ++c)
            if (M[r][c] > best) best = M[r][c];
    return best;
}

int diagonalSum(const int M[N][N]) {
    int sum = 0;
    for (int i = 0; i < N; ++i) sum += M[i][i];          // one loop: row == column
    return sum;
}

bool isSymmetric(const int M[N][N]) {
    for (int r = 0; r < N; ++r)
        for (int c = r + 1; c < N; ++c)                  // the upper triangle is enough
            if (M[r][c] != M[c][r]) return false;
    return true;
}

int main() {
    int M[N][N] = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };
    int S[N][N] = {
        {2, 7, 1},
        {7, 4, 5},
        {1, 5, 9}
    };

    printMatrix("M", M);
    cout << "\nRow sums:\n";    rowSums(M);
    cout << "Column sums:\n";   columnSums(M);

    int T[N][N];
    transpose(M, T);
    cout << '\n';
    printMatrix("Transpose of M", T);

    cout << "\nLargest element of M: " << largest(M) << '\n';
    cout << "Diagonal sum of M:    " << diagonalSum(M) << "  (1 + 5 + 9)\n";

    cout << '\n';
    printMatrix("S", S);
    cout << "\nIs M symmetric? " << (isSymmetric(M) ? "yes" : "no")
         << "   (M[0][1] = 2 but M[1][0] = 4)\n";
    cout << "Is S symmetric? " << (isSymmetric(S) ? "yes" : "no")
         << "  (S[r][c] == S[c][r] everywhere)\n";
    return 0;
}
