// Lab 1 - Programming foundations and structured records
// Revision exercise: a union and a 1D array, the two prerequisites the lab
// manual names beside structures and pointers.
//
// A structure gives every member its own storage. A union gives all members
// the SAME storage, so it is as large as its largest member and only the
// member written last holds a meaningful value.
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra union_review.cpp -o union_review
//     ./union_review

#include <iostream>
using namespace std;

struct MeasurementStruct {   // separate storage for each member
    int count;
    double reading;
    char grade;
};

union MeasurementUnion {     // one storage area shared by all members
    int count;
    double reading;
    char grade;
};

int main() {
    cout << "== Structure versus union ==\n";
    cout << "sizeof(MeasurementStruct) = " << sizeof(MeasurementStruct) << " bytes\n";
    cout << "sizeof(MeasurementUnion)  = " << sizeof(MeasurementUnion)
         << " bytes (the size of its largest member, double = " << sizeof(double) << ")\n";

    MeasurementUnion u;
    u.count = 42;
    cout << "\nAfter u.count = 42:     u.count   = " << u.count << '\n';
    u.reading = 3.75;
    cout << "After u.reading = 3.75: u.reading = " << u.reading
         << "  (count was overwritten; read only the member written last)\n";

    cout << "\n== A 1D array: daily temperatures ==\n";
    const int DAYS = 7;
    int temperature[DAYS] = {31, 33, 30, 29, 34, 32, 31};

    int highest = temperature[0];
    int total = 0;
    for (int i = 0; i < DAYS; ++i) {
        cout << "day " << i + 1 << ": " << temperature[i] << '\n';
        total += temperature[i];
        if (temperature[i] > highest) highest = temperature[i];
    }
    cout << "highest: " << highest << ", average: "
         << static_cast<double>(total) / DAYS << '\n';
    return 0;
}
