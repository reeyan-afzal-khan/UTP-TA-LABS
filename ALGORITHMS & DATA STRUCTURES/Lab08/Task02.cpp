#include <iostream>
using namespace std;

void insertionSort(int arr[], int n) {
    for (int i = 1; i < n; i++) {
        int key = arr[i];   // actually the second element 
        int j = i - 1; // the first element in the array is the first being compared with others

        // shift elements of the sorted part that are greater than key
        // one position to the right, to leave space for the key
        while (j >= 0 && arr[j] > key) { //if the front element is greater than the back element, then swap them
            swap(arr[j + 1], arr[j]);
            j--;
        }

        // place key in its correct position
        arr[j + 1] = key;
    }
}

void printArray(int arr[], int n) {
    for (int i = 0; i < n; i++)
        cout << arr[i] << " ";
    cout << endl;
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