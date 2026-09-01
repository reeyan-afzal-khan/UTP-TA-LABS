/*
 * Lab 10, Task 1 --- Student records in a BINARY file.
 *
 * STEP 1: Read how many student records to store.
 * STEP 2: Open the file in binary write mode and write each struct with
 *         fwrite() --- the raw bytes of the structure go straight to disk.
 * STEP 3: Reopen for reading and offer a menu: 1 DISPLAY, 2 SEARCH, 3 EXIT.
 * STEP 4: To display, rewind and fread() until it returns fewer than one
 *         complete record --- that short read, not EOF alone, is the
 *         correct stopping condition.
 * STEP 5: Close the file.
 *
 * Binary records are compact and read back in one call, but the file is
 * not human-readable and is NOT portable: struct padding, field sizes, and
 * endianness all differ across machines. Compare with Task02.c, which
 * stores the same kind of data as text.
 *
 * Build: gcc -Wall -Wextra Task01.c -o task01
 */

#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int sno;
    char name[25];
    int m1, m2, m3;
} STD;

STD s;

void display(FILE *fp);
int search(FILE *fp, int sno_key, STD *result);

int main() {
    int i, n, sno_key, opn;
    FILE *fp;

    printf("How many records? ");
    scanf("%d", &n);

    fp = fopen("stud.dat", "wb");
    if (!fp) {
        printf("Error opening file.\n");
        return 1;
    }

    for (i = 0; i < n; i++) {
        printf("Enter student %d (sno name m1 m2 m3): ", i + 1);
        scanf("%d %s %d %d %d",
              &s.sno, s.name, &s.m1, &s.m2, &s.m3);
        fwrite(&s, sizeof(s), 1, fp);
    }

    fclose(fp);

    fp = fopen("stud.dat", "rb");
    if (!fp) {
        printf("Error opening file.\n");
        return 1;
    }

    while (1) {
        printf("\n1. DISPLAY\n2. SEARCH\n3. EXIT\nYour option: ");

        if (scanf("%d", &opn) != 1) {
            printf("Invalid input! Clearing buffer...\n");
            while (getchar() != '\n');  // clear input buffer
            continue;
        }

        switch (opn) {
        case 1:
            printf("\nStudent Records:\n");
            display(fp);
            break;

        case 2:
            printf("Enter student number (sno): ");
            scanf("%d", &sno_key);
            if (search(fp, sno_key, &s)) {
                printf("Record found:\n");
                printf("%d\t%s\t%d\t%d\t%d\n",
                       s.sno, s.name, s.m1, s.m2, s.m3);
            } else {
                printf("Record %d not found!\n", sno_key);
            }
            break;

        case 3:
            printf("Exiting program...\n");
            fclose(fp);
            return 0;

        default:
            printf("Invalid option! Try again.\n");
        }
    }
}

void display(FILE *fp) {
    rewind(fp);
    while (fread(&s, sizeof(s), 1, fp) == 1) {
        printf("%d\t%s\t%d\t%d\t%d\n",
               s.sno, s.name, s.m1, s.m2, s.m3);
    }
}

int search(FILE *fp, int sno_key, STD *result) {
    rewind(fp);
    while (fread(result, sizeof(*result), 1, fp) == 1) {
        if (result->sno == sno_key)
            return 1;
    }
    return 0;
}
