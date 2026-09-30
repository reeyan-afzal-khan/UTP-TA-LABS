#include <stdio.h>
#include <string.h>

#define PROCESSES 5
#define RESOURCES 3

static void print_vector(const int vector[RESOURCES]) {
    printf("[%d %d %d]", vector[0], vector[1], vector[2]);
}

int main(int argc, char *argv[]) {
    const int allocation[PROCESSES][RESOURCES] = {
        {0, 1, 0}, {2, 0, 0}, {3, 0, 2}, {2, 1, 1}, {0, 0, 2}
    };
    const int maximum[PROCESSES][RESOURCES] = {
        {7, 5, 3}, {3, 2, 2}, {9, 0, 2}, {2, 2, 2}, {4, 3, 3}
    };

    int work[RESOURCES] = {3, 3, 2};
    if (argc == 2 && strcmp(argv[1], "--unsafe") == 0) {
        work[0] = 0;
        work[1] = 0;
        work[2] = 0;
    }

    int need[PROCESSES][RESOURCES];
    int finished[PROCESSES] = {0};
    int safe_sequence[PROCESSES];
    int safe_count = 0;

    for (int p = 0; p < PROCESSES; p++) {
        for (int r = 0; r < RESOURCES; r++) {
            need[p][r] = maximum[p][r] - allocation[p][r];
        }
    }

    printf("Initial Work = ");
    print_vector(work);
    puts("");
    puts("Process  Need       Work before  Work after");

    while (safe_count < PROCESSES) {
        int progress = 0;

        for (int p = 0; p < PROCESSES; p++) {
            if (finished[p]) {
                continue;
            }

            int can_finish = 1;
            for (int r = 0; r < RESOURCES; r++) {
                if (need[p][r] > work[r]) {
                    can_finish = 0;
                    break;
                }
            }

            if (can_finish) {
                printf("P%-7d ", p);
                print_vector(need[p]);
                printf("  ");
                print_vector(work);

                for (int r = 0; r < RESOURCES; r++) {
                    work[r] += allocation[p][r];
                }

                printf("      ");
                print_vector(work);
                puts("");

                finished[p] = 1;
                safe_sequence[safe_count++] = p;
                progress = 1;
            }
        }

        if (!progress) {
            break;
        }
    }

    if (safe_count == PROCESSES) {
        printf("SAFE sequence:");
        for (int i = 0; i < PROCESSES; i++) {
            printf(" P%d", safe_sequence[i]);
        }
        puts("");
    } else {
        puts("UNSAFE: no complete safe sequence can be found from this Work vector.");
    }

    return 0;
}
