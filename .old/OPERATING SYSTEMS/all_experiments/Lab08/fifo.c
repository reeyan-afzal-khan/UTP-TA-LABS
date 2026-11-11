#include <stdio.h>

#define FRAME_COUNT 3

int main(void) {
    const int reference[] = {7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2};
    const int count = (int)(sizeof reference / sizeof reference[0]);
    int frames[FRAME_COUNT] = {-1, -1, -1};
    int next = 0;
    int hits = 0;
    int faults = 0;

    puts("FIFO page replacement");
    puts("Ref  Frames       Result");

    for (int i = 0; i < count; i++) {
        int hit = 0;
        for (int f = 0; f < FRAME_COUNT; f++) {
            if (frames[f] == reference[i]) {
                hit = 1;
                break;
            }
        }

        if (hit) {
            hits++;
        } else {
            faults++;
            frames[next] = reference[i];
            next = (next + 1) % FRAME_COUNT;
        }

        printf("%-4d [%2d %2d %2d]  %s\n",
               reference[i], frames[0], frames[1], frames[2],
               hit ? "hit" : "fault");
    }

    printf("Hits=%d Faults=%d\n", hits, faults);
    return 0;
}
