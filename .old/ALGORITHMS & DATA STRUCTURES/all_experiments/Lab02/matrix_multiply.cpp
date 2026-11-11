// Lab 2 - Arrays, multidimensional storage, and matrices
// Multiply two matrices with three nested loops, after checking that the
// shapes are compatible, and trace one output cell by hand.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra matrix_multiply.cpp -o matrix_multiply
//     ./matrix_multiply

#include <iostream>
#include <iomanip>
using namespace std;

const int MAXN = 10;

void check(const char* what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void printMatrix(const char* name, const int M[][MAXN], int rows, int cols) {
    cout << name << " (" << rows << " x " << cols << ")\n";
    for (int r = 0; r < rows; ++r) {
        cout << "  row " << r << ":";
        for (int c = 0; c < cols; ++c) cout << setw(5) << M[r][c];
        cout << '\n';
    }
}

// A (rows x shared) times B (shared x cols). Returns false, and leaves P
// untouched, when the columns of A do not match the rows of B.
bool multiply(const int A[][MAXN], int aRows, int aCols,
              const int B[][MAXN], int bRows, int bCols,
              int P[][MAXN]) {
    if (aCols != bRows) return false;
    const int R = aRows, K = aCols, C = bCols;

    for (int i = 0; i < R; ++i)
        for (int j = 0; j < C; ++j) {
            P[i][j] = 0;
            for (int t = 0; t < K; ++t)
                P[i][j] += A[i][t] * B[t][j];
        }
    return true;
}

int main() {
    // The lab example: A is 2 x 3, B is 3 x 2, so P is 2 x 2.
    const int R = 2, K = 3, C = 2;
    int A[MAXN][MAXN] = {{1,2,3}, {4,5,6}};
    int B[MAXN][MAXN] = {{7,8}, {9,10}, {11,12}};
    int P[MAXN][MAXN] = {};

    printMatrix("A", A, R, K);
    printMatrix("B", B, K, C);

    if (multiply(A, R, K, B, K, C, P)) printMatrix("P = A x B", P, R, C);

    cout << "\n== Trace of one output cell ==\n";
    cout << "P[1][0] = A[1][0]*B[0][0] + A[1][1]*B[1][0] + A[1][2]*B[2][0]\n";
    cout << "        = " << A[1][0] << "*" << B[0][0] << " + "
         << A[1][1] << "*" << B[1][0] << " + "
         << A[1][2] << "*" << B[2][0] << '\n';
    int byHand = 4 * 7 + 5 * 9 + 6 * 11;
    cout << "        = " << 4 * 7 << " + " << 5 * 9 << " + " << 6 * 11 << " = " << byHand << '\n';
    cout << "Program P[1][0] = " << P[1][0]
         << (P[1][0] == byHand ? "  (matches the hand calculation)\n" : "  (MISMATCH)\n");

    cout << "\n== Shape validation ==\n";
    int Q[MAXN][MAXN] = {};
    bool accepted = multiply(A, R, K, A, R, K, Q);   // 2x3 times 2x3: 3 != 2
    cout << "A (2 x 3) times A (2 x 3): "
         << (accepted ? "multiplied" : "refused, columns of A (3) != rows of A (2)") << '\n';

    cout << "\nWhat each loop controls:\n"
         << "  i chooses the row of A and the row of P being filled;\n"
         << "  j chooses the column of B and the column of P being filled;\n"
         << "  t walks along row i of A and down column j of B, adding one product per step.\n";

    cout << "\n== Verification ==\n";
    check("incompatible shapes are refused before any multiplication", !accepted);
    check("the hand-traced cell P[1][0] matches the program", P[1][0] == byHand);
    check("the whole product matches the expected [[58, 64], [139, 154]]",
          P[0][0] == 58 && P[0][1] == 64 && P[1][0] == 139 && P[1][1] == 154);
    return 0;
}
