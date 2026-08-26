#include <iostream>
#include <string>
#include <limits>
using namespace std;

// Structure to store student information
struct Student {
    int id;
    string name;
    string course;
    int age;
};

int main() {

    // Array of 5 Student records
    Student students[5];

    cout << "Input\n\n";

    // Input details for 5 students
    for (int i = 0; i < 5; i++) {

        cout << "Student " << i + 1 << "\n";

        // Input student ID (must be numeric)
        cout << "ID: ";
        while (!(cin >> students[i].id)) {
            cout << "Invalid ID. Enter numbers only: ";
            cin.clear(); // clear error flag
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
        }
        cin.ignore(numeric_limits<streamsize>::max(), '\n');

        // Input student name
        cout << "Name: ";
        getline(cin, students[i].name);

        // Input course name
        cout << "Course: ";
        getline(cin, students[i].course);

        // Input age (must be numeric)
        cout << "Age: ";
        while (!(cin >> students[i].age)) {
            cout << "Invalid Age. Enter numbers only: ";
            cin.clear();
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
        }
        cin.ignore(numeric_limits<streamsize>::max(), '\n');

        cout << "\n";
    }

    // Display all student records
    cout << "All Students\n\n";

    for (int i = 0; i < 5; i++) {
        cout << "ID: " << students[i].id << "\n";
        cout << "Name: " << students[i].name << "\n";
        cout << "Course: " << students[i].course << "\n";
        cout << "Age: " << students[i].age << "\n\n";
    }

    // Search student by ID
    int searchID;

    cout << "Enter ID to search: ";
    while (!(cin >> searchID)) {
        cout << "Invalid ID. Enter numbers only: ";
        cin.clear();
        cin.ignore(numeric_limits<streamsize>::max(), '\n');
    }

    bool searchFound = false;

    // Linear search through the array
    for (int i = 0; i < 5; i++) {
        if (students[i].id == searchID) {
            cout << "Found. Name: " << students[i].name << "\n";
            searchFound = true;
            break;
        }
    }

    if (!searchFound) {
        cout << "Student not found.\n";
    }

    // Update student records repeatedly until user quits
    string inputID;

    while (true) {

        cout << "\nEnter ID to update (or Q to quit): ";
        cin >> inputID;

        // Exit update mode
        if (inputID == "Q" || inputID == "q") {
            cout << "Exiting update mode.\n";
            break;
        }

        int updateID;

        // Convert string to integer safely
        try {
            updateID = stoi(inputID);
        }
        catch (...) {
            cout << "Invalid ID.\n";
            continue;
        }

        string change;

        // Ask user which field to update
        cout << "What do you want to change (id/name/course/age): ";
        cin >> change;

        bool updateFound = false;

        // Search for matching ID
        for (int i = 0; i < 5; i++) {

            if (students[i].id == updateID) {

                updateFound = true;

                // Update ID
                if (change == "id") {

                    int newID;

                    cout << "Enter new ID: ";
                    while (!(cin >> newID)) {
                        cout << "Invalid ID. Enter numbers only: ";
                        cin.clear();
                        cin.ignore(numeric_limits<streamsize>::max(), '\n');
                    }

                    students[i].id = newID;
                    cout << "Updated.\n";
                }

                // Update name
                else if (change == "name") {

                    cin.ignore(numeric_limits<streamsize>::max(), '\n');

                    cout << "Enter new name: ";
                    getline(cin, students[i].name);

                    cout << "Updated.\n";
                }

                // Update course
                else if (change == "course") {

                    cin.ignore(numeric_limits<streamsize>::max(), '\n');

                    cout << "Enter new course: ";
                    getline(cin, students[i].course);

                    cout << "Updated.\n";
                }

                // Update age
                else if (change == "age") {

                    int newAge;

                    cout << "Enter new age: ";
                    while (!(cin >> newAge)) {
                        cout << "Invalid Age. Enter numbers only: ";
                        cin.clear();
                        cin.ignore(numeric_limits<streamsize>::max(), '\n');
                    }

                    students[i].age = newAge;
                    cout << "Updated.\n";
                }

                // Invalid field entered
                else {
                    cout << "Invalid field. Use: id, name, course, or age.\n";
                }

                // Display updated record
                cout << "ID: " << students[i].id << "\n";
                cout << "Name: " << students[i].name << "\n";
                cout << "Course: " << students[i].course << "\n";
                cout << "Age: " << students[i].age << "\n";

                break;
            }
        }

        if (!updateFound) {
            cout << "Student not found.\n";
        }
    }

    return 0;
}