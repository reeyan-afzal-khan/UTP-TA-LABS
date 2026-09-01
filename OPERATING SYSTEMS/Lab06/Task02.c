/*
 * Lab 6, Task 2 --- Deadlock detection via the same matrix machinery.
 *
 * STEP 1: Read processes, resource types, MAX, ALLOCATION, and AVAILABLE.
 * STEP 2: Derive Need = Max - Allocation.
 * STEP 3: Run the Work/Finish reduction: any process whose Need <= Work is
 *         assumed able to finish and returns its allocation to Work.
 * STEP 4: Every process left unfinished at the end is reported as
 *         potentially deadlocked.
 *
 * Note the conceptual difference from Task01.c: true deadlock DETECTION
 * reasons about outstanding REQUESTS that already exist, while a Banker's
 * safety test reasons about worst-case future claims (Max). This program
 * derives Need from Max, so strictly it performs a safety-style test and
 * labels the pessimistic result "deadlock" --- compare and discuss.
 *
 * Build: gcc -Wall -Wextra Task02.c -o task02
 */

#include <stdio.h>

// Global declarations
int max[100][100];
int alloc[100][100];
int need[100][100];
int avail[100];
int n, r;

// Function prototypes
void input();
void show();
void detectDeadlock();

int main() {
    printf("********** Deadlock Detection Algorithm ************\n\n");
    input();
    show();
    detectDeadlock();
    return 0;
}

//-------------------- INPUT FUNCTION --------------------
void input() {
    int i, j;
    printf("Enter the number of processes: ");
    scanf("%d", &n);
    printf("Enter the number of resource types: ");
    scanf("%d", &r);

    printf("\n--- Enter MAX matrix values ---\n");
    for (i = 0; i < n; i++) {
        printf("Process P%d:\n", i + 1);
        for (j = 0; j < r; j++) {
            printf("  Maximum need of Resource R%d: ", j + 1);
            scanf("%d", &max[i][j]);
        }
    }

    printf("\n--- Enter ALLOCATION matrix values ---\n");
    for (i = 0; i < n; i++) {
        printf("Process P%d:\n", i + 1);
        for (j = 0; j < r; j++) {
            printf("  Resources of type R%d currently allocated: ", j + 1);
            scanf("%d", &alloc[i][j]);
        }
    }

    printf("\n--- Enter AVAILABLE resources ---\n");
    for (j = 0; j < r; j++) {
        printf("Available instances of Resource R%d: ", j + 1);
        scanf("%d", &avail[j]);
    }
}

//-------------------- DISPLAY FUNCTION --------------------
void show() {
    int i, j;
    printf("\n-------------------------------------------------------------\n");
    printf("Process\t\tAllocation\t\tMax\t\tAvailable\n");
    printf("-------------------------------------------------------------\n");
    for (i = 0; i < n; i++) {
        printf("P%d\t\t", i + 1);
        for (j = 0; j < r; j++)
            printf("%d ", alloc[i][j]);
        printf("\t\t");
        for (j = 0; j < r; j++)
            printf("%d ", max[i][j]);
        printf("\t\t");
        if (i == 0) {
            for (j = 0; j < r; j++)
                printf("%d ", avail[j]);
        }
        printf("\n");
    }
    printf("-------------------------------------------------------------\n");
}

//-------------------- DEADLOCK DETECTION FUNCTION --------------------
void detectDeadlock() {
    int finish[100] = {0}, dead[100];
    int work[100];
    int i, j, k, deadCount = 0;

    // Step 1: Calculate NEED matrix
    for (i = 0; i < n; i++) {
        for (j = 0; j < r; j++) {
            need[i][j] = max[i][j] - alloc[i][j];
        }
    }

    printf("\n--- NEED MATRIX ---\n");
    for (i = 0; i < n; i++) {
        printf("P%d\t", i + 1);
        for (j = 0; j < r; j++) {
            printf("%d ", need[i][j]);
        }
        printf("\n");
    }

    // Step 2: Initialize work = avail
    for (j = 0; j < r; j++)
        work[j] = avail[j];

    // Step 3: Try to find a process that can finish
    int doneSomething;
    do {
        doneSomething = 0;
        for (i = 0; i < n; i++) {
            if (finish[i] == 0) {
                int canRun = 1;
                for (j = 0; j < r; j++) {
                    if (need[i][j] > work[j]) {
                        canRun = 0;
                        break;
                    }
                }

                if (canRun) {
                    // Process can finish; release its resources
                    for (k = 0; k < r; k++)
                        work[k] += alloc[i][k];
                    finish[i] = 1;
                    doneSomething = 1;
                }
            }
        }
    } while (doneSomething);

    // Step 4: Detect unfinished (deadlocked) processes
    for (i = 0; i < n; i++) {
        if (finish[i] == 0) {
            dead[deadCount++] = i;
        }
    }

    // Step 5: Display result
    if (deadCount > 0) {
        printf("\n⚠️  System is in DEADLOCK state.\n");
        printf("Deadlocked processes are: ");
        for (i = 0; i < deadCount; i++) {
            printf("P%d ", dead[i] + 1);
        }
        printf("\n");
    } else {
        printf("\n✅ No Deadlock detected. System is in SAFE state.\n");
    }
}
