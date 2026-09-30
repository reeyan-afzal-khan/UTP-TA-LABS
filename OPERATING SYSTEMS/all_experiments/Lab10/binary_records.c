#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int id;
    char name[32];
    float gpa;
} Student;

int main(void) {
    const Student students[] = {
        {101, "Amina", 3.6f},
        {102, "Daniel", 3.2f},
        {103, "Mei", 3.8f}
    };
    const int count = (int)(sizeof students / sizeof students[0]);

    FILE *file = fopen("students.bin", "wb");
    if (file == NULL) {
        perror("students.bin");
        return EXIT_FAILURE;
    }

    if (fwrite(students, sizeof students[0], count, file) != (size_t)count) {
        perror("fwrite");
        fclose(file);
        return EXIT_FAILURE;
    }
    fclose(file);

    int target = 102;
    file = fopen("students.bin", "rb");
    if (file == NULL) {
        perror("students.bin");
        return EXIT_FAILURE;
    }

    Student current;
    int found = 0;
    while (fread(&current, sizeof current, 1, file) == 1) {
        if (current.id == target) {
            printf("Found: id=%d name=%s gpa=%.1f\n",
                   current.id, current.name, current.gpa);
            found = 1;
            break;
        }
    }

    fclose(file);
    if (!found) {
        printf("Student %d not found.\n", target);
    }
    return 0;
}
