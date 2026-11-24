#import "/.shared/typst/utp.typ": *

#keepspace(10 * skips.normal)
#element-head([Program 1: Student records from definition to update])

#strong[File:] `student_records.cpp`.

#strong[Chapter connection:] C++ practical: structures; Putting records into an array.

Keep the Student fields from the chapter. Separate lookup from mutation: findById returns an index; updateStudent checks it before forming a pointer. main builds five records, searches, calculates an average, and verifies that only the selected record changes.

#include "../visuals/program-student_records.typ"

#block(sticky: true)[
  #utpsteps[
    1. #strong[Headers and initial definitions.]
  ]

  `student_records.cpp` --- lines 10--19.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 10, last: 19, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    2. #strong[Implement display, findById, updateStudent and helpers.]
  ]

  `student_records.cpp` --- lines 20--54.
]

#include "../visuals/walk-update.typ"

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 20, last: 54, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    3. #strong[Connect the test cases in main.]
  ]

  `student_records.cpp` --- lines 55--88.
]

#strong[Trace checkpoint for the supplied main.] Before the update, save the five records exactly as main does. ID 1003 is at index 2; ID 9999 must return -1. Updating ID 1004 changes only the fourth record to age 23 and course CS. Trace the guard for a missing ID before forming a pointer: an index of -1 must never be used as an array offset. Compare every record with before, not only the updated one.

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 55, last: 88, lang: "cpp")

#block(sticky: true)[
  #utpsteps[
    4. #strong[Connect the test cases in main.]
  ]

  `student_records.cpp` --- lines 89--113. Continue in the same file; do not add another header or opening brace.
]

#lstinput("/ALGORITHMS & DATA STRUCTURES/all_experiments/Lab01/student_records.cpp", first: 89, last: 113, lang: "cpp")

#strong[Before and after the update.] Run the program and set its two record tables side by side. Only the row for 1004 may differ between them.

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
1001 | Amina | 20 | CS
1002 | Ben | 21 | IT
1003 | Chen | 20 | CS
1004 | Devi | 23 | CS
1005 | Ehsan | 21 | IT
== Verification ==
  [ok]   at least five records are stored and displayed
  [ok]   a valid ID is found
  [ok]   an invalid ID returns -1 (not found)
  [ok]   update of an existing ID succeeds
  [ok]   update of a missing ID is refused
  [ok]   updating one record changes only the intended record
Array bounds: every loop runs i = 0 .. n-1, so no index reaches students[N].
Pointer versus index: students[3] names the fourth element by position;
students + 3 is its address, so (students + 3)->age reaches the same field.
```

`findById` returns where a record sits in the array, counted from 0, so ID 1003 is found at index 2. ID 9999 returns -1, and the update that uses it is refused before any pointer is formed, which the fifth check confirms. The average, 20.8, is 104~/~5, taken before the update changes Devi's age.

#strong[Break the update on purpose.] In `main`, change the ID in the first `updateStudent` call from 1004 to 9999 and predict the run before you start it. The two tables should now be identical, and exactly two checks should fail: the update of an existing ID no longer succeeds, and the record that was meant to change did not. Put 1004 back and print the average again after the update. Work it out first from the stored ages: (20~+~21~+~20~+~23~+~21)~/~5~=~21, which is what the program must print.
