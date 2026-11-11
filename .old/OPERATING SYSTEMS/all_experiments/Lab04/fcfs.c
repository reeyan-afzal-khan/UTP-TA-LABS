#include <stdio.h>

int main(void) {
    const int burst[] = {8, 4, 2, 1};
    const int count = (int)(sizeof burst / sizeof burst[0]);
    int time = 0;
    int total_wait = 0;
    int total_turnaround = 0;

    puts("FCFS - all processes arrive at time 0");
    puts("PID  Burst  Wait  Turnaround");

    for (int i = 0; i < count; i++) {
        int wait = time;
        time += burst[i];
        int turnaround = time;

        total_wait += wait;
        total_turnaround += turnaround;
        printf("P%-3d %-6d %-5d %d\n", i + 1, burst[i], wait, turnaround);
    }

    printf("Average waiting time    : %.2f\n", (double)total_wait / count);
    printf("Average turnaround time : %.2f\n", (double)total_turnaround / count);
    return 0;
}
