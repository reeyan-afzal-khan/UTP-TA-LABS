/*
 * Lab 8, Task 4 --- LFU page replacement.
 *
 * STEP 1: Read the frame count, the page count, and the reference string.
 * STEP 2: Keep a reference COUNT for every resident page.
 * STEP 3: On a hit, increment that page's count.
 *         On a fault with no free frame, evict the page with the SMALLEST
 *         count; this code breaks ties using recency information.
 * STEP 4: Report page hits and page faults.
 *
 * State the tie-breaker explicitly in your report: "least frequently used"
 * alone does not define a unique victim when several pages share the lowest
 * count. LFU's other weakness is stale history --- a page referenced heavily
 * early on keeps a high count long after it stops being needed.
 *
 * Build: gcc -Wall -Wextra Task04.c -o task04
 */

#include <stdio.h>

int main()
{
    int f, p;
    int pages[50], frame[10], hit = 0, count[50], time[50];
    int i, j, page, flag, least, minTime, temp = 0;

    printf("Enter no of frames : ");
    scanf("%d", &f);

    printf("Enter no of pages : ");
    scanf("%d", &p);

    // Initialize frames
    for(i = 0; i < f; i++)
        frame[i] = -1;

    // Initialize frequency
    for(i = 0; i < 50; i++) {
        count[i] = 0;
        time[i] = -1;
    }

    printf("Enter page numbers:\n");
    for(i = 0; i < p; i++)
        scanf("%d", &pages[i]);

    printf("\n");

    for(i = 0; i < p; i++)
    {
        page = pages[i];
        count[page]++;         // Increase frequency
        time[page] = i;        // Update last used time
        flag = 1;

        least = frame[0];      // First frame as initial least

        // Check for hit or empty frame
        for(j = 0; j < f; j++)
        {
            if(frame[j] == -1 || frame[j] == page)
            {
                // Page found → hit
                if(frame[j] == page)
                    hit++;

                frame[j] = page;
                flag = 0;
                break;
            }

            // Track least frequently used
            if(count[least] > count[frame[j]])
                least = frame[j];
        }

        // If page fault → replace by LFU logic
        if(flag)
        {
            minTime = 999;

            // Find victim frame using LFU + LRU tie-breaker
            for(j = 0; j < f; j++)
            {
                if(count[frame[j]] == count[least] && time[frame[j]] < minTime)
                {
                    temp = j;
                    minTime = time[frame[j]];
                }
            }

            // Reset count for replaced page
            count[frame[temp]] = 0;

            // Replace victim
            frame[temp] = page;
        }

        // Print frames
        for(j = 0; j < f; j++)
            printf("%d ", frame[j]);

        printf("\n");
    }

    printf("Page hit = %d\n", hit);
    printf("Page faults = %d\n", p - hit);

    return 0;
}
