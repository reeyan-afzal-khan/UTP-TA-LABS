// Lab 2, Task 4 --- Matrix multiplication (the lab manual's core problem).
//
//   A (R x K)  *  B (K x C)  =  P (R x C)
//
//   P[i][j] = sum over t of A[i][t] * B[t][j]
//
// The multiplication is only defined when the number of columns of A equals
// the number of rows of B, so the program validates that before any loop.
//
// Each output cell walks one row of A and one column of B in lock-step and
// accumulates the products --- three nested loops in total:
//   i picks the output row, j picks the output column, t walks the shared
//   dimension K.
//
// Build: g++ -std=c++17 -Wall -Wextra Task04.cpp -o task04

#include <iostream>
#include <vector>

using namespace std;

using Matrix = vector<vector<int>>;

void printMatrix(const string& label, const Matrix& m) {
    cout << label << " (" << m.size() << " x " << m[0].size() << "):\n";
    for (const auto& row : m) {
        for (int val : row) cout << '\t' << val;
        cout << '\n';
    }
    cout << '\n';
}

// Returns an empty matrix when the dimensions are incompatible.
Matrix multiply(const Matrix& a, const Matrix& b) {
    size_t rows = a.size();
    size_t shared = a[0].size();   // columns of A must equal rows of B
    size_t cols = b[0].size();

    if (shared != b.size()) {
        cout << "Cannot multiply: A has " << shared
             << " columns but B has " << b.size() << " rows.\n";
        return {};
    }

    Matrix p(rows, vector<int>(cols, 0));
    for (size_t i = 0; i < rows; ++i)
        for (size_t j = 0; j < cols; ++j)
            for (size_t t = 0; t < shared; ++t)
                p[i][j] += a[i][t] * b[t][j];
    return p;
}

Matrix transpose(const Matrix& m) {
    Matrix t(m[0].size(), vector<int>(m.size()));
    for (size_t i = 0; i < m.size(); ++i)
        for (size_t j = 0; j < m[0].size(); ++j)
            t[j][i] = m[i][j];
    return t;
}

void rowAndColumnSums(const Matrix& m) {
    for (size_t i = 0; i < m.size(); ++i) {
        int sum = 0;
        for (int val : m[i]) sum += val;
        cout << "Row " << i << " sum: " << sum << '\n';
    }
    for (size_t j = 0; j < m[0].size(); ++j) {
        int sum = 0;
        for (size_t i = 0; i < m.size(); ++i) sum += m[i][j];
        cout << "Column " << j << " sum: " << sum << '\n';
    }
}

int main() {
    // 2x3 times 3x2 --- the shared dimension K = 3 disappears in the result.
    Matrix a = {{1, 2, 3},
                {4, 5, 6}};
    Matrix b = {{ 7,  8},
                { 9, 10},
                {11, 12}};

    printMatrix("A", a);
    printMatrix("B", b);

    Matrix p = multiply(a, b);
    if (!p.empty()) printMatrix("A * B", p);

    // Hand check of one cell, matching the innermost loop:
    //   P[0][0] = 1*7 + 2*9 + 3*11 = 7 + 18 + 33 = 58
    cout << "Hand-worked cell P[0][0] = 1*7 + 2*9 + 3*11 = 58"
         << "  (program says " << p[0][0] << ")\n\n";

    // Deliberately incompatible pair: 2x3 times 2x2 must be rejected.
    cout << "-- Incompatible dimensions --\n";
    Matrix bad = {{1, 2}, {3, 4}};
    multiply(a, bad);
    cout << '\n';

    // Two extras from the lab sheet: transpose and row/column sums.
    printMatrix("Transpose of A", transpose(a));
    cout << "Sums of A:\n";
    rowAndColumnSums(a);

    return 0;
}
