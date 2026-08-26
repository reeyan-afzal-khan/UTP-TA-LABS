/*
Step-1: Start the program.
Step-2: Get the number of records user want to store in the system.
Step-3: Using Standard Library function open the file to write the data into the file. 
Step-4: Store the entered information in the system.
Step-5: Using do..While statement and switch case to create the options such as 1-DISPLAY, 2.SEARCH, 3.EXIT.
Step-6: Close the file using fclose() function. 
Step-7: Process it and display the result.
Step-8: Stop the program.
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
