/*
 * Lab 10, Task 2 --- Employee records in a TEXT file.
 *
 * STEP 1: Read how many employee records to store.
 * STEP 2: Write each one with fprintf() as a line of text.
 * STEP 3: Reopen for reading; to fetch record number k, rewind and parse
 *         forward with fscanf() until record k has been read.
 * STEP 4: Keep asking for a record number until -1 is entered.
 *
 * Text records are human-readable, portable across machines, and easy to
 * diff or repair by hand. The cost: parsing on every read, larger files,
 * and no constant-time seek to record k --- notice this program must scan
 * from the start each time, while the binary version in Task01.c could
 * compute a byte offset directly.
 *
 * Build: gcc -Wall -Wextra Task02.c -o task02
 */

#include <stdio.h>
#include <stdlib.h>

struct record {
    char empname[20];
    int age;
    float salary;
};

typedef struct record person;

int main() {
    person employee;
    int i, n;

    FILE *fp;

    printf("How many records: ");
    scanf("%d", &n);

    /* WRITE TEXT FILE */
    fp = fopen("PEOPLE.txt", "w");
    if (!fp) {
        printf("Error opening file for writing!\n");
        return 1;
    }

    for (i = 0; i < n; i++) {
        printf("Enter employee %d (Name Age Salary): ", i + 1);
        scanf("%s %d %f", employee.empname, &employee.age, &employee.salary);

        /* Write in text format */
        fprintf(fp, "%s %d %.2f\n", employee.empname, employee.age, employee.salary);
    }

    fclose(fp);

    /* READ TEXT FILE */
    fp = fopen("PEOPLE.txt", "r");
    if (!fp) {
        printf("Error opening file for reading!\n");
        return 1;
    }

    int rec;
    printf("Which record do you want to read (0 to %d): ", n - 1);
    scanf("%d", &rec);

    while (rec >= 0 && rec < n) {

        rewind(fp);   // Go to the start of the file

        /* Read lines until reaching record number rec */
        for (i = 0; i <= rec; i++) {
            if (fscanf(fp, "%s %d %f",
                       employee.empname,
                       &employee.age,
                       &employee.salary) != 3) 
            {
                printf("Record %d not found!\n", rec);
                break;
            }
        }

        if (i == rec + 1) {
            printf("\nRECORD %d\n", rec);
            printf("Name  : %s\n", employee.empname);
            printf("Age   : %d\n", employee.age);
            printf("Salary: %.2f\n\n", employee.salary);
        }

        printf("Which record next (0 to %d, -1 to exit): ", n - 1);
        scanf("%d", &rec);
    }

    fclose(fp);
    return 0;
}
