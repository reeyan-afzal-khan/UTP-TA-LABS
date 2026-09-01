// Lab 8, Task 2 --- Insertion sort.
//
// Keeps a sorted region at the front of the array and grows it by one
// element per pass. Each new element ("the key") is slid left past every
// larger element until it lands in place.
//
//   [56 | 72 30 15 ...]   sorted region is just 56
//   [56 72 | 30 15 ...]   72 already larger, no movement
//   [30 56 72 | 15 ...]   30 slides past 72 and 56
//
// Best case O(n) on already-sorted input --- the inner loop never runs.
// Worst case O(n^2) on reverse-sorted input. Stable, and sorts in place.
//
// Build: g++ -std=c++17 -Wall -Wextra Task02.cpp -o task02

#include <iostream>

using namespace std;

void insertionSort(int arr[], int n) {
    // Position 0 alone is trivially sorted, so the first key is at index 1.
    for (int i = 1; i < n; i++) {
        int key = arr[i];   // save it: the shifting below overwrites arr[i]
        int j = i - 1;      // rightmost element of the sorted region

        // Shift every element greater than the key one slot right. This
        // copies rather than swaps: a swap would do three assignments per
        // step to move a value we are going to move again next iteration.
        // The key is already saved, so its old slot is free to overwrite.
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }

        // The loop stopped either at the front of the array or at an element
        // not greater than the key, so j+1 is the gap the key belongs in.
        arr[j + 1] = key;
    }
}

void printArray(const int arr[], int n) {
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << "\n";
}

int main() {
    int arr[] = {56, 72, 30, 15, 78, 54, 90};
    int n = sizeof(arr) / sizeof(arr[0]);

    cout << "Original array: ";
    printArray(arr, n);

    insertionSort(arr, n);

    cout << "Sorted array (insertion sort): ";
    printArray(arr, n);

    return 0;
}
