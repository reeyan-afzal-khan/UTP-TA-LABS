#include <stdio.h>

typedef struct {
    int pid;
    int burst;
    int priority;
} Process;

int main(void) {
    Process process[] = {
        {1, 8, 3},
        {2, 4, 1},
        {3, 2, 4},
        {4, 1, 2}
    };
    const int count = (int)(sizeof process / sizeof process[0]);

    for (int i = 0; i < count - 1; i++) {
        for (int j = i + 1; j < count; j++) {
            int higher = process[j].priority < process[i].priority;
            int tied_earlier = process[j].priority == process[i].priority &&
                               process[j].pid < process[i].pid;
            if (higher || tied_earlier) {
                Process temporary = process[i];
                process[i] = process[j];
                process[j] = temporary;
            }
        }
    }

    int time = 0;
    int total_wait = 0;
    puts("Priority scheduling - smaller number means higher priority");
    puts("PID  Priority  Burst  Wait  Turnaround");

    for (int i = 0; i < count; i++) {
        int wait = time;
        time += process[i].burst;
        int turnaround = time;
        total_wait += wait;

        printf("P%-3d %-9d %-6d %-5d %d\n",
               process[i].pid, process[i].priority,
               process[i].burst, wait, turnaround);
    }

    printf("Average waiting time: %.2f\n", (double)total_wait / count);
    return 0;
}
