/*
 * Lab 10, Task 3 --- Indexed file-allocation simulation.
 *
 *   index block p  ->  [ b1, b2, ..., bn ]     (n data blocks)
 *
 * A disk of 50 blocks is modelled by f[]: f[b] == 1 means block b is taken.
 * Each "file" claims one index block plus the data blocks that the index
 * points at.
 *
 * The allocation is TWO-PHASE, and that is the point of the exercise:
 *   Phase 1: validate the index block and EVERY data block while touching
 *            nothing.
 *   Phase 2: only if all of them are free, mark them allocated together.
 * The naive version marked the index block first and then bailed out when a
 * data block was taken, leaking the index block --- a request that failed
 * still changed the disk state. Validate-then-commit is the standard cure,
 * and the same pattern appears in databases as a transaction.
 *
 * Build: gcc -Wall -Wextra Task03.c -o task03
 */

#include <stdio.h>

#define DISK_BLOCKS 50

/* Read one int; returns 0 on EOF/bad input so menus can exit cleanly
 * instead of spinning forever on a failed scanf. */
static int readInt(const char *prompt, int *out)
{
    printf("%s", prompt);
    if (scanf("%d", out) == 1)
        return 1;
    printf("\n(no more input)\n");
    return 0;
}

static int validBlock(int b)
{
    if (b < 0 || b >= DISK_BLOCKS) {
        printf("Block %d does not exist (disk has blocks 0..%d).\n",
               b, DISK_BLOCKS - 1);
        return 0;
    }
    return 1;
}

int main(void)
{
    int f[DISK_BLOCKS] = {0};   /* 0 = free, 1 = allocated */
    int index[DISK_BLOCKS];

    for (;;) {
        int p, n, i, ok = 1;

        /* ---------- Phase 1: validate everything, allocate nothing ------- */
        if (!readInt("Enter index block: ", &p))
            break;
        if (!validBlock(p) || f[p]) {
            if (validBlock(p))
                printf("Block %d already allocated!\n", p);
            continue;               /* nothing was marked, nothing to undo */
        }

        if (!readInt("Enter number of blocks in the index: ", &n))
            break;
        if (n < 1 || n > DISK_BLOCKS) {
            printf("Invalid block count.\n");
            continue;
        }

        printf("Enter %d block numbers:\n", n);
        for (i = 0; i < n && ok; i++) {
            if (!readInt("", &index[i]))
                return 0;
            if (!validBlock(index[i]) || f[index[i]] || index[i] == p) {
                if (validBlock(index[i]))
                    printf("Block %d already allocated!\n", index[i]);
                ok = 0;             /* reject the whole request */
            }
        }
        if (!ok) {
            printf("Request rejected; disk state unchanged.\n\n");
            continue;
        }

        /* ---------- Phase 2: commit the whole request at once ------------ */
        f[p] = 1;
        for (i = 0; i < n; i++)
            f[index[i]] = 1;

        printf("\nAllocated Successfully!\n");
        printf("Indexed File Structure:\n");
        for (i = 0; i < n; i++)
            printf("%d -> %d : allocated\n", p, index[i]);

        int more;
        if (!readInt("\nEnter 1 to enter more files or 0 to exit: ", &more)
            || more != 1)
            break;
    }
    return 0;
}
