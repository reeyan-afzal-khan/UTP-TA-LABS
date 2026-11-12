#import "/.shared/typst/utp.typ": *

#strong[Program 1: Student records from definition to update.]

#strong[File:] `student_records.cpp`.

#strong[Chapter connection:] C++ practical: structures; Putting records into an array.

Keep the Student fields from the chapter. Separate lookup from mutation: findById returns an index; updateStudent checks it before forming a pointer. main builds five records, searches, calculates an average, and verifies that only the selected record changes.

#include "../visuals/program-student_records.typ"

#utpsteps[
  1. #strong[Headers and initial definitions.]
]

`student_records.cpp` --- lines 10--19.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 10, last: 19, lang: "cpp")

#colbreak()

#utpsteps[
  2. #strong[Implement display, findById, updateStudent and helpers.]
]

`student_records.cpp` --- lines 20--54.

#include "../visuals/walk-update.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 20, last: 54, lang: "cpp")

#colbreak()

#utpsteps[
  3. #strong[Connect the test cases in main.]
]

`student_records.cpp` --- lines 55--88.

#strong[Trace checkpoint for the supplied main.] Before the update, save the five records exactly as main does. ID 1003 is at index 2; ID 9999 must return -1. Updating ID 1004 changes only the fourth record to age 23 and course CS. Trace the guard for a missing ID before forming a pointer: an index of -1 must never be used as an array offset. Compare every record with before, not only the updated one.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 55, last: 88, lang: "cpp")

#colbreak()

#utpsteps[
  4. #strong[Connect the test cases in main.]
]

`student_records.cpp` --- lines 89--113. Continue in the same file; do not add another header or opening brace.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 89, last: 113, lang: "cpp")

#colbreak()

#strong[Build, run, and inspect student\_records.]

From this program\'s folder, run these commands in PowerShell:

```terminal

g++ -std=c++17 -Wall -Wextra student_records.cpp -o student_records.exe

.\student_records.exe

```

#strong[Expected output excerpt.] Compare values, order, and pass/fail messages; spacing need not match.

```terminal

== All records (ID | name | age | course) ==
1001 | Amina | 20 | CS
1002 | Ben | 21 | IT
1003 | Chen | 20 | CS
1004 | Devi | 22 | IS
1005 | Ehsan | 21 | IT

== Search by ID ==
Search 1003: found at index 2 -> Chen
Search 9999: not found

== Average age (a 1D-array statistic) ==
Average age: 20.8

== Update record 1004 through a pointer ==

```

The complete captured run is in `labs/outputs/student_records.txt`.

#tryit[
  Change the target ID to 9999. Predict the failed search and update: both must leave every record unchanged. Then update ID 1004 and calculate the new average, 21.0, from the stored ages.
]
