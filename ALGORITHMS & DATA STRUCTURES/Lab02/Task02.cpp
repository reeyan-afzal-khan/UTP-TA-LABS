#include <algorithm>
// provide useful algo like sort(), max(), min()
#include <iostream>
#include <climits>
// to provide integer limits
#include <vector>
using namespace std;

int median(vector<vector<int>> &mat) {
    int n = mat.size(); //3
    int m = mat[0].size(); // 3

    int minVal = INT_MAX, maxVal = INT_MIN;
    // default INT_MAX and INT_MIN from <climits>

    //finding the min and max elements 
    for (int i = 0; i < n ; i++) {
        if (mat[i][0] < minVal) {
            minVal = mat[i][0];
        }
        if (mat[i][m - 1] > maxVal) {
            maxVal = mat[i][m - 1];
        }
    }
    //look at the first element and find the smallest among them
    // because every row is sorted, nothing can be smaller then its first element
    // check only the first and last column

    int desired = (n * m + 1) / 2; 
    // 3 * 3  = 9+ 1 / 2 = 5
    int lo = minVal, hi = maxVal;
    while (lo < hi) {
        int mid = lo + (hi - lo) / 2;
        // 5
        int count = 0;

        //count elements smaller then or equal to mid
        for (int i = 0; i < n; i++) {
            count += upper_bound(mat[i].begin(), mat[i].end(), mid) - mat[i].begin();
            //  only 3 elements that is greater then 5 , meaning upperbound find > 5,
            // lowerbound find <= 5
        }
        // upper_bound returns an iterator pointing to the first element in the range [first, last) that is greater than value
        // so we can calculate how many elements are less than or equal to mid by subtracting the beginning of the row from the position returned by upper_bound

        if (count < desired) {
            lo = mid + 1;
        } else {
            hi = mid;
            // hi = 5
        }
    }
    return lo;
}


int main() {
    vector<vector<int>> mat = {
        {1, 3, 5},
        {2, 6, 9},
        {3, 6, 9}
    };
    cout << "Median: " << median(mat) << endl;
    return 0;
}
