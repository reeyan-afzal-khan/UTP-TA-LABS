#include <iostream>
#include <utility>   // std::swap
using namespace std;

int partition(int arr[], int low, int high) {
    int pivot = arr[low];  // choose first element as pivot
    int i = low + 1;       // start scanning from the element right after pivot
    int j = high;

    while (i <= j) { //  make sure they arr not crossed
        // move i forward while elements are smaller than pivot
        while (i <= high && arr[i] < pivot) i++;

        // move j backward while elements are bigger than pivot
        while (j >= low + 1 && arr[j] > pivot) j--;

        if (i < j) { // if not crossed
            swap(arr[i], arr[j]); 
            i++;
            j--;
        }
    }

    // other wise if i > j meaning i crossed j
    swap(arr[low], arr[j]); // swap the pivot with the j
    return j;               // return j which is now the pivot's index
}

void quickSort(int arr[], int low, int high) {
    if (low < high) {
        int pivotIndex = partition(arr, low, high);

        quickSort(arr, low, pivotIndex - 1);  // sort left part // exclude the pivot index
        // meaning from low to the one element before pivot 
        quickSort(arr, pivotIndex + 1, high); // sort right part
        // one element after pivot to the high index
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

    quickSort(arr, 0, n - 1); // n - 1 = high index based on the lengtj of the array

    cout << "Sorted array (quick sort): ";
    printArray(arr, n);

    return 0;
}
