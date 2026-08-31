/*
 * Lab 1, Task 1 --- List the entries of a directory.
 *
 * STEP 1: Read a directory path from the user.
 * STEP 2: Open the directory with opendir().
 * STEP 3: Read entries one at a time with readdir() until it returns NULL.
 * STEP 4: Print each entry name.
 * STEP 5: Close the directory with closedir().
 *
 * Build: gcc -Wall -Wextra Task01.c -o task01
 * Note:  POSIX only (dirent.h). Use Linux or WSL, not native Windows.
 */

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>

#define PATH_MAX_LEN 512

int main(void)
{
    char path[PATH_MAX_LEN];

    printf("Enter directory name: ");
    fflush(stdout);

    /* The width limit stops scanf writing past the end of path[].
     * Without "%511s" a long input silently overflows the buffer. */
    if (scanf("%511s", path) != 1) {
        fprintf(stderr, "No directory name supplied.\n");
        return EXIT_FAILURE;
    }

    DIR *dirp = opendir(path);
    if (dirp == NULL) {
        /* perror appends the reason: "No such file or directory",
         * "Permission denied", and so on. */
        perror(path);
        return EXIT_FAILURE;
    }

    /* readdir() returns NULL both at end-of-directory and on error.
     * The extra parentheses mark the assignment as deliberate, which
     * also silences -Wparentheses. */
    struct dirent *entry;
    while ((entry = readdir(dirp)) != NULL) {
        printf("%s\n", entry->d_name);
    }

    closedir(dirp);
    return EXIT_SUCCESS;
}
