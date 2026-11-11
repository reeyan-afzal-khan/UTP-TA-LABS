// Lab 1 - Programming foundations and structured records
// A small database-style application: at least five student records held in
// an array of structures, with display, search by ID, update through a
// pointer, and one 1D-array statistic (the average age).
//
// Build and run from this folder:
//     g++ -std=c++17 -Wall -Wextra student_records.cpp -o student_records
//     ./student_records

#include <iostream>
#include <string>
using namespace std;

struct Student {
    int id;
    string name;
    int age;
    string course;
};

void display(const Student students[], int n) {
    for (int i = 0; i < n; ++i) {
        cout << students[i].id << " | "
             << students[i].name << " | "
             << students[i].age << " | "
             << students[i].course << '\n';
    }
}

int findById(const Student students[], int n, int id) {
    for (int i = 0; i < n; ++i)
        if (students[i].id == id) return i;
    return -1;
}

// Once the index is known, the record is changed through a pointer to it.
// The array name gives the address of element 0; adding the index moves the
// pointer to the chosen record, and -> reaches its fields.
bool updateStudent(Student students[], int n, int id, int newAge, const string& newCourse) {
    int index = findById(students, n, id);
    if (index == -1) return false;

    Student* selected = students + index;   // same as &students[index]
    selected->age = newAge;
    selected->course = newCourse;
    return true;
}

double averageAge(const Student students[], int n) {
    if (n == 0) return 0.0;
    int total = 0;
    for (int i = 0; i < n; ++i) total += students[i].age;
    return static_cast<double>(total) / n;
}

void check(const string& what, bool ok) {
    cout << (ok ? "  [ok]   " : "  [FAIL] ") << what << '\n';
}

void searchAndReport(const Student students[], int n, int id) {
    int index = findById(students, n, id);
    if (index == -1)
        cout << "Search " << id << ": not found\n";
    else
        cout << "Search " << id << ": found at index " << index
             << " -> " << students[index].name << '\n';
}

int main() {
    const int N = 5;
    Student students[N] = {
        {1001, "Amina", 20, "CS"},
        {1002, "Ben",   21, "IT"},
        {1003, "Chen",  20, "CS"},
        {1004, "Devi",  22, "IS"},
        {1005, "Ehsan", 21, "IT"}
    };

    cout << "== All records (ID | name | age | course) ==\n";
    display(students, N);

    cout << "\n== Search by ID ==\n";
    searchAndReport(students, N, 1003);   // a valid ID
    searchAndReport(students, N, 9999);   // an ID that does not exist

    cout << "\n== Average age (a 1D-array statistic) ==\n";
    cout << "Average age: " << averageAge(students, N) << '\n';

    cout << "\n== Update record 1004 through a pointer ==\n";
    Student before[N];
    for (int i = 0; i < N; ++i) before[i] = students[i];
    bool updated = updateStudent(students, N, 1004, 23, "CS");
    bool missing = updateStudent(students, N, 9999, 30, "IT");
    display(students, N);

    cout << "\n== Verification ==\n";
    check("at least five records are stored and displayed", N >= 5);
    check("a valid ID is found", findById(students, N, 1003) == 2);
    check("an invalid ID returns -1 (not found)", findById(students, N, 9999) == -1);
    check("update of an existing ID succeeds", updated);
    check("update of a missing ID is refused", !missing);
    bool onlyOneChanged = true;
    for (int i = 0; i < N; ++i) {
        bool changed = students[i].age != before[i].age || students[i].course != before[i].course;
        if (changed != (students[i].id == 1004)) onlyOneChanged = false;
    }
    check("updating one record changes only the intended record", onlyOneChanged);

    cout << "\nArray bounds: every loop runs i = 0 .. n-1, so no index reaches students[N].\n"
         << "Pointer versus index: students[3] names the fourth element by position;\n"
         << "students + 3 is its address, so (students + 3)->age reaches the same field.\n";
    return 0;
}
