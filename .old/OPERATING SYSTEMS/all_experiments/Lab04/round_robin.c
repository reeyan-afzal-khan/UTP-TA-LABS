#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    const int burst[] = {8, 4, 2, 1};
    int remaining[] = {8, 4, 2, 1};
    const int count = (int)(sizeof burst / sizeof burst[0]);
    int quantum = (argc == 2) ? atoi(argv[1]) : 2;

    if (quantum <= 0) {
        fprintf(stderr, "Usage: %s [positive-quantum]\n", argv[0]);
        return 2;
    }

    int first_run[] = {-1, -1, -1, -1};
    int completion[] = {0, 0, 0, 0};
    int time = 0;
    int finished = 0;

    printf("Round Robin, quantum=%d\nGantt: ", quantum);
    while (finished < count) {
        for (int i = 0; i < count; i++) {
            if (remaining[i] == 0) {
                continue;
            }

            if (first_run[i] == -1) {
                first_run[i] = time;
            }

            int slice = remaining[i] < quantum ? remaining[i] : quantum;
            printf("| P%d %d-%d ", i + 1, time, time + slice);
            time += slice;
            remaining[i] -= slice;

            if (remaining[i] == 0) {
                completion[i] = time;
                finished++;
            }
        }
    }
    puts("|");

    puts("PID  Burst  Response  Wait  Turnaround");
    for (int i = 0; i < count; i++) {
        int turnaround = completion[i];
        int wait = turnaround - burst[i];
        printf("P%-3d %-6d %-9d %-5d %d\n",
               i + 1, burst[i], first_run[i], wait, turnaround);
    }

    return 0;
}
