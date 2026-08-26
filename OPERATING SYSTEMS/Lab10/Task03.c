/*
Step-1: Start the program.
Step-2: Get the number of records user want to store in the system.
Step-3: Using Standard Library function open the file to write the data into the file. 
Step-4: Store the entered information in the system.
Step-5: Using do..While statement and switch case to create the options such as 1-DISPLAY, 2.SEARCH, 3.EXIT.
Step-6: Close the file using fclose() function. 
Step-7: Process it and display the result.
Step-8: Stop the program.
*/

#include <stdio.h>
#include <stdlib.h>

int f[50], i, k, j, inde[50], n, c, p;

int main()
{
    for (i = 0; i < 50; i++)
        f[i] = 0;

START:
    printf("Enter index block: ");
    scanf("%d", &p);

    if (f[p] == 0) {
        f[p] = 1;
        printf("Enter number of blocks in the index: ");
        scanf("%d", &n);
    } else {
        printf("Block already allocated!\n");
        goto START;
    }

    printf("Enter %d block numbers:\n", n);
    for (i = 0; i < n; i++)
        scanf("%d", &inde[i]);

    for (i = 0; i < n; i++) {
        if (f[inde[i]] == 1) {
            printf("Block %d already allocated!\n", inde[i]);
            goto START;
        }
    }

    for (j = 0; j < n; j++)
        f[inde[j]] = 1;

    printf("\nAllocated Successfully!\n");
    printf("Indexed File Structure:\n");

    for (k = 0; k < n; k++)
        printf("%d -> %d : allocated\n", p, inde[k]);

    printf("\nEnter 1 to enter more files or 0 to exit: ");
    scanf("%d", &c);

    if (c == 1)
        goto START;
    else
        exit(0);

    return 0;
}
