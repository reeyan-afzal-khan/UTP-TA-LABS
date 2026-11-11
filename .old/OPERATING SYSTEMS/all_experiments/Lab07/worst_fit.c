#include <stdio.h>

#define HOLE_COUNT 5
#define REQUEST_COUNT 4

static void print_holes(const int holes[]) {
    printf("[");
    for (int i = 0; i < HOLE_COUNT; i++) {
        printf("%d%s", holes[i], (i + 1 == HOLE_COUNT) ? "" : ", ");
    }
    printf("]");
}

int main(void) {
    int holes[HOLE_COUNT] = {100, 500, 200, 300, 600};
    const int requests[REQUEST_COUNT] = {212, 417, 112, 426};

    puts("Worst Fit");
    for (int r = 0; r < REQUEST_COUNT; r++) {
        int choice = -1;

        for (int h = 0; h < HOLE_COUNT; h++) {
            if (holes[h] >= requests[r] &&
                (choice == -1 || holes[h] > holes[choice])) {
                choice = h;
            }
        }

        printf("Request %-3d -> ", requests[r]);
        if (choice == -1) {
            printf("not allocated; holes ");
        } else {
            holes[choice] -= requests[r];
            printf("hole %d; holes ", choice);
        }
        print_holes(holes);
        puts("");
    }

    return 0;
}
