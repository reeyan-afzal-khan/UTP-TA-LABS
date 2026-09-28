#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FRAME_COUNT 3
#define REFERENCE_COUNT 13

static void print_frames(const int frames[]) {
    printf("[");
    for (int i = 0; i < FRAME_COUNT; i++) {
        if (frames[i] == -1) {
            printf(" - ");
        } else {
            printf(" %d ", frames[i]);
        }
    }
    printf("]");
}

int main(int argc, char *argv[]) {
    if (argc != 2 ||
        (strcmp(argv[1], "fifo") != 0 &&
         strcmp(argv[1], "lru") != 0 &&
         strcmp(argv[1], "lfu") != 0)) {
        fprintf(stderr, "Usage: %s fifo|lru|lfu\n", argv[0]);
        return 2;
    }

    const int reference[REFERENCE_COUNT] = {7, 0, 1, 2, 0, 3, 0, 4, 2, 3, 0, 3, 2};
    int frames[FRAME_COUNT] = {-1, -1, -1};
    int last_used[FRAME_COUNT] = {-1, -1, -1};
    int frequency[FRAME_COUNT] = {0, 0, 0};
    int fifo_next = 0;
    int hits = 0;
    int faults = 0;

    printf("Policy: %s, frames=%d\n", argv[1], FRAME_COUNT);
    puts("Step  Ref  Frames       Result");

    for (int step = 0; step < REFERENCE_COUNT; step++) {
        int page = reference[step];
        int hit_index = -1;

        for (int f = 0; f < FRAME_COUNT; f++) {
            if (frames[f] == page) {
                hit_index = f;
                break;
            }
        }

        if (hit_index != -1) {
            hits++;
            last_used[hit_index] = step;
            frequency[hit_index]++;
        } else {
            faults++;
            int victim = -1;

            for (int f = 0; f < FRAME_COUNT; f++) {
                if (frames[f] == -1) {
                    victim = f;
                    break;
                }
            }

            if (victim == -1 && strcmp(argv[1], "fifo") == 0) {
                victim = fifo_next;
                fifo_next = (fifo_next + 1) % FRAME_COUNT;
            } else if (victim == -1 && strcmp(argv[1], "lru") == 0) {
                victim = 0;
                for (int f = 1; f < FRAME_COUNT; f++) {
                    if (last_used[f] < last_used[victim]) {
                        victim = f;
                    }
                }
            } else if (victim == -1) {
                victim = 0;
                for (int f = 1; f < FRAME_COUNT; f++) {
                    if (frequency[f] < frequency[victim] ||
                        (frequency[f] == frequency[victim] &&
                         last_used[f] < last_used[victim])) {
                        victim = f;
                    }
                }
            }

            frames[victim] = page;
            last_used[victim] = step;
            frequency[victim] = 1;

            if (strcmp(argv[1], "fifo") == 0) {
                fifo_next = (victim + 1) % FRAME_COUNT;
            }
        }

        printf("%-5d %-4d ", step + 1, page);
        print_frames(frames);
        printf("  %s\n", hit_index == -1 ? "fault" : "hit");
    }

    printf("Hits=%d  Faults=%d  Total=%d\n", hits, faults, REFERENCE_COUNT);
    return 0;
}
