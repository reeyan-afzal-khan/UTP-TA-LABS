#include <stdio.h>

typedef struct {
    int pid;
    int burst;
} Process;

int main(void) {
    Process process[] = {{1, 8}, {2, 4}, {3, 2}, {4, 1}};
    const int count = (int)(sizeof process / sizeof process[0]);

    for (int i = 0; i < count - 1; i++) {
        for (int j = i + 1; j < count; j++) {
            if (process[j].burst < process[i].burst) {
                Process temporary = process[i];
                process[i] = process[j];
                process[j] = temporary;
            }
        }
    }

    int time = 0;
    int total_wait = 0;
    int total_turnaround = 0;

    puts("SJF (non-preemptive) - all processes arrive at time 0");
    puts("PID  Burst  Wait  Turnaround");

    for (int i = 0; i < count; i++) {
        int wait = time;
        time += process[i].burst;
        int turnaround = time;

        total_wait += wait;
        total_turnaround += turnaround;
        printf("P%-3d %-6d %-5d %d\n",
               process[i].pid, process[i].burst, wait, turnaround);
    }

    printf("Average waiting time    : %.2f\n", (double)total_wait / count);
    printf("Average turnaround time : %.2f\n", (double)total_turnaround / count);
    return 0;
}
