#include <bits/stdc++.h>
// include almost all standard C++ libraries
using namespace std;

// to rotate the matrix represented by a vector of vectors
void rotateMatrix(vector<vector<int>>& mat){
    // mat here is just a variable , and & mean reference to
    // vector is data type in type of integer for the value in matrix

    int m = mat.size();
    // return the number of rows (size of matrix)
    int n = mat[0].size();
    // get the number of columns from the first row (size of index 0 row in matrix)

    int row = 0, col = 0;
    int prev, curr;

    // rotate the matrix in layers
    while (row < m && col < n){
        if (row + 1 == m || col + 1 == n){
            break;
            // the last column or row always cannot move first
        }

        // Store the first element of the next row
        prev = mat[row + 1][col];
        // 4

        // Move the elements of the first row
        for (int i = col; i < n; i++) {
            curr = mat[row][i];
            mat[row][i] = prev;
            prev = curr;
        }
        // end of this loop prev = 3
        row++;

        // Move elements of the last column
        for (int i = row; i < m; i++) {
            // row = 1, 1 < 3
            curr = mat[i][n-1];
            //  3-1 = 2, save this current
            mat[i][n-1] = prev; // the previous last prev we saved from upper loop,
            //  prev = curr (the prev here)
            prev = curr;
        }
        // end of this loop the prev = 9
        n--;

        // Move elements of the last row 
        if (row < m) {
            for ( int i = n-1; i >= col; i--) {
                // i = 2, i >= 0; i++
                curr = mat[m-1][i];
                // [2][2]
                // [2][1]
                // [2][0]
                mat[m-1][i] = prev;
                prev = curr;
                // last prev = 7
            }
        }
        m--;

        // Move elements of the first column
        if (col <n) {
            for (int i = m -1; i >= row; i--) {
                //  i = 2-1 = 1
                // from bottom to up, at the column 0
                // start from row 1
                curr = mat[i][col];
                mat[i][col] = prev;
                prev = curr;
                // 4
            }
        }
        col++;
    }

}

int main() {
    vector<vector<int>> mat = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };
    rotateMatrix(mat);

    // print the rotated matrix in the format
    for (auto&r : mat) {
        // equivalent to for (vector<int>& r : mat)
        // for evert row inside mat, put that row into r
        //  r = {1,2,3} (iteration 1)
        //  r = {4,5,6} (iteration 2)
        //  r = {7,8,9} (iteration 3)
        for (int val : r) {
            cout << val << " ";
        }
        cout << endl;
    }
    return 0;
}