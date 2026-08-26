/*
Step 1: Inside the structure declare the variables.
Step 2: Declare the variable i,j as integer,totwtime and totttime is equal to zero. 
Step 3: Get the value of 'n' assign pid as I and get the value of p[i].btime.
Step 4: Assign p[0] wtime as zero and tot time as btime and inside the loop calculate wait time and turnaround time.
Step 5: Calculate total wait time and total turnaround time by dividing by total number of process.
Step 6: Print total wait time and total turnaround time. 
Step 7: Stop the program.
 */

#include <stdio.h>
#include <stdlib.h>

struct fcfs {
    int pid;    // Process ID
    int btime;  // Burst Time
    int wtime;  // Waiting Time
    int ttime;  // Turnaround Time
} p[10];

int main() {
    int i, n;
    int totwtime = 0, totttime = 0;

    printf("\nFCFS Scheduling...\n");
    printf("Enter the number of processes: ");
    scanf("%d", &n);

    for (i = 0; i < n; i++) {
        p[i].pid = i + 1;
        printf("Enter burst time for Process %d: ", p[i].pid);
        scanf("%d", &p[i].btime);
    }

    // Calculate waiting time and turnaround time
    p[0].wtime = 0;  // First process waits 0 time
    p[0].ttime = p[0].btime;
    totttime += p[0].ttime;

    for (i = 1; i < n; i++) {
        p[i].wtime = p[i - 1].wtime + p[i - 1].btime;
        p[i].ttime = p[i].wtime + p[i].btime;

        totwtime += p[i].wtime;
        totttime += p[i].ttime;
    }

    printf("\nProcess\tBurstTime\tWaitingTime\tTurnAroundTime\n");
    for (i = 0; i < n; i++) {
        printf("P%d\t\t%d\t\t%d\t\t%d\n",
               p[i].pid, p[i].btime, p[i].wtime, p[i].ttime);
    }

    printf("\nTotal Waiting Time: %d", totwtime);
    printf("\nAverage Waiting Time: %.2f", (float)totwtime / n);
    printf("\nTotal Turnaround Time: %d", totttime);
    printf("\nAverage Turnaround Time: %.2f\n", (float)totttime / n);

    return 0;
}
