#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HOLE_COUNT 5
#define REQUEST_COUNT 4

static int choose_hole(const int holes[], int request, const char *policy) {
    int choice = -1;

    for (int i = 0; i < HOLE_COUNT; i++) {
        if (holes[i] < request) {
            continue;
        }

        if (strcmp(policy, "first") == 0) {
            return i;
        }

        if (choice == -1 ||
            (strcmp(policy, "best") == 0 && holes[i] < holes[choice]) ||
            (strcmp(policy, "worst") == 0 && holes[i] > holes[choice])) {
            choice = i;
        }
    }

    return choice;
}

static void print_holes(const int holes[]) {
    printf("[");
    for (int i = 0; i < HOLE_COUNT; i++) {
        printf("%d%s", holes[i], (i + 1 == HOLE_COUNT) ? "" : ", ");
    }
    printf("]");
}

int main(int argc, char *argv[]) {
    if (argc != 2 ||
        (strcmp(argv[1], "first") != 0 &&
         strcmp(argv[1], "best") != 0 &&
         strcmp(argv[1], "worst") != 0)) {
        fprintf(stderr, "Usage: %s first|best|worst\n", argv[0]);
        return 2;
    }

    int holes[HOLE_COUNT] = {100, 500, 200, 300, 600};
    const int requests[REQUEST_COUNT] = {212, 417, 112, 426};

    printf("Policy: %s fit\n", argv[1]);
    printf("Initial holes: ");
    print_holes(holes);
    puts("");

    for (int i = 0; i < REQUEST_COUNT; i++) {
        int choice = choose_hole(holes, requests[i], argv[1]);
        printf("Request %-3d -> ", requests[i]);

        if (choice == -1) {
            printf("not allocated; holes remain ");
        } else {
            int before = holes[choice];
            holes[choice] -= requests[i];
            printf("hole %d (%d -> %d); holes now ",
                   choice, before, holes[choice]);
        }

        print_holes(holes);
        puts("");
    }

    return 0;
}
