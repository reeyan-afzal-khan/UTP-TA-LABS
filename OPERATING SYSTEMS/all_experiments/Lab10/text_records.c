#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int id;
    char name[32];
    double salary;
} Employee;

int main(void) {
    const Employee employees[] = {
        {201, "Ravi", 3100.00},
        {202, "Sara", 3450.50},
        {203, "Noor", 2990.00}
    };
    const int count = (int)(sizeof employees / sizeof employees[0]);

    FILE *file = fopen("employees.txt", "w");
    if (file == NULL) {
        perror("employees.txt");
        return EXIT_FAILURE;
    }

    for (int i = 0; i < count; i++) {
        fprintf(file, "%d,%s,%.2f\n",
                employees[i].id, employees[i].name, employees[i].salary);
    }
    fclose(file);

    int target = 202;
    int id;
    char name[32];
    double salary;
    int found = 0;

    file = fopen("employees.txt", "r");
    if (file == NULL) {
        perror("employees.txt");
        return EXIT_FAILURE;
    }

    while (fscanf(file, "%d,%31[^,],%lf\n", &id, name, &salary) == 3) {
        if (id == target) {
            printf("Found: id=%d name=%s salary=%.2f\n", id, name, salary);
            found = 1;
            break;
        }
    }

    fclose(file);
    if (!found) {
        printf("Employee %d not found.\n", target);
    }
    return 0;
}
