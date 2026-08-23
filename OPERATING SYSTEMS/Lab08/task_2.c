/*
Step 1: Start the program.
Step 2: Declare the necessary variables. 
Step 3: Enter the number of frames.
Step 4: Enter the reference string ending with zero.
Step 5: FIFO page replacement selects the page that has been in memory the longest time.
Step 6: When a page is brought into memory, it is inserted at the tail of the queue. 
Step 7: Initially all the frames are empty.
Step 8: The page fault count increases when allocated frames increase.
Step 9: Print total number of page faults.
Step 10: Stop the program.
*/

#include <stdio.h>

int main() 
{
    int i = 0, j, k = 0, i1 = 0;
    int m, n;
    int rs[30], p[30];
    int flag;

    printf("FIFO Page Replacement Algorithm\n");

    printf("Enter the number of frames: ");
    scanf("%d", &n);

    printf("Enter the reference string (end with 0): ");

    // Read reference string
    while (1) {
        scanf("%d", &rs[i]);
        if (rs[i] == 0)
            break;
        i++;
    }

    m = i;

    // Initialize frames
    for (j = 0; j < n; j++)
        p[j] = -1;

    printf("\nProcessing...\n\n");

    for (i = 0; i < m; i++) {
        flag = 1;

        // Check if page already exists
        for (j = 0; j < n; j++) {
            if (p[j] == rs[i]) {
                printf("Page %d already in frame.\n", rs[i]);
                flag = 0;
                break;
            }
        }

        // If not present -> page fault
        if (flag == 1) {
            p[i1] = rs[i];
            i1 = (i1 + 1) % n;
            k++;

            printf("Page fault → Loaded %d into frames:\n", rs[i]);
            for (j = 0; j < n; j++) {
                printf("Frame %d: %d", j + 1, p[j]);
                if (p[j] == rs[i])
                    printf("  <- inserted");
                printf("\n");
            }
            printf("\n");
        }
    }

    printf("Total number of page faults = %d\n", k);

    return 0;
}
