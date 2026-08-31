/*
 * Lab 2, Task 2 --- Print the contents of a directory.
 *
 * STEP 1: Take the directory path from the command line.
 * STEP 2: Open it with opendir(), checking for failure.
 * STEP 3: Read every entry with readdir() and print it.
 * STEP 4: Close the directory ONCE, after the loop has finished.
 *
 * Build: gcc -Wall -Wextra Task02.c -o task02
 * Run:   ./task02 /etc
 * Note:  POSIX only (dirent.h). Use Linux or WSL.
 */

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s DIRECTORY\n", argv[0]);
        return EXIT_FAILURE;
    }

    DIR *dp = opendir(argv[1]);
    if (dp == NULL) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    printf("Contents of %s:\n", argv[1]);

    struct dirent *entry;
    long count = 0;
    while ((entry = readdir(dp)) != NULL) {
        /* One name per line. Printing without '\n' runs every entry
         * together into a single unreadable string. */
        printf("  %s\n", entry->d_name);
        count++;
    }

    /* closedir() belongs HERE, outside the loop.
     *
     * Closing inside the loop releases the directory handle on the first
     * iteration, and every readdir() after that reads through a dangling
     * pointer. That is undefined behaviour: it may print garbage, loop
     * forever, or crash. Acquire, use, then release --- in that order, once. */
    closedir(dp);

    printf("%ld entries (including . and ..)\n", count);
    return EXIT_SUCCESS;
}
