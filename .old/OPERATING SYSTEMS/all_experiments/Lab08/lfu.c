#include <stdio.h>

#define FRAME_COUNT 3

int main(void) {
    const int reference[] = {7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2};
    const int count = (int)(sizeof reference / sizeof reference[0]);
    int frames[FRAME_COUNT] = {-1, -1, -1};
    int frequency[FRAME_COUNT] = {0, 0, 0};
    int last_used[FRAME_COUNT] = {-1, -1, -1};
    int hits = 0;
    int faults = 0;

    puts("LFU page replacement (LRU breaks frequency ties)");
    puts("Ref  Frames       Result");

    for (int i = 0; i < count; i++) {
        int hit = -1;
        for (int f = 0; f < FRAME_COUNT; f++) {
            if (frames[f] == reference[i]) {
                hit = f;
                break;
            }
        }

        if (hit >= 0) {
            hits++;
            frequency[hit]++;
            last_used[hit] = i;
        } else {
            faults++;
            int victim = -1;
            for (int f = 0; f < FRAME_COUNT; f++) {
                if (frames[f] == -1) {
                    victim = f;
                    break;
                }
            }
            if (victim == -1) {
                victim = 0;
                for (int f = 1; f < FRAME_COUNT; f++) {
                    if (frequency[f] < frequency[victim] ||
                        (frequency[f] == frequency[victim] &&
                         last_used[f] < last_used[victim])) {
                        victim = f;
                    }
                }
            }
            frames[victim] = reference[i];
            frequency[victim] = 1;
            last_used[victim] = i;
        }

        printf("%-4d [%2d %2d %2d]  %s\n",
               reference[i], frames[0], frames[1], frames[2],
               hit >= 0 ? "hit" : "fault");
    }

    printf("Hits=%d Faults=%d\n", hits, faults);
    return 0;
}
