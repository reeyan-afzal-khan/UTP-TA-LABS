/*
 * Lab 2, Task 1 --- Count the space characters in a file.
 *
 * STEP 1: Take the filename from the command line.
 * STEP 2: Open it for reading.
 * STEP 3: Read one character at a time until fgetc() returns EOF.
 * STEP 4: Count how many of them are ' '.
 * STEP 5: Print the count and close the file.
 *
 * Build: gcc -Wall -Wextra Task01.c -o task01
 * Run:   ./task01 somefile.txt
 */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s FILE\n", argv[0]);
        return EXIT_FAILURE;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        perror(argv[1]);
        return EXIT_FAILURE;
    }

    /* ch must be int, not char. fgetc() returns 0..255 for a real byte and
     * the separate value EOF (usually -1) at end of file. Storing that in a
     * char collapses the two, so the loop either ends early or never ends. */
    int ch;
    long spaces = 0;

    /* Loop on the result of the read, not on feof().
     *
     * "while (!feof(fp))" is the classic bug: feof() only becomes true AFTER
     * a read has already failed, so the body runs one extra time with a stale
     * or EOF value and the count comes out wrong. */
    while ((ch = fgetc(fp)) != EOF) {
        if (ch == ' ') {
            spaces++;
        }
    }

    /* Distinguish a real read error from a clean end of file. */
    if (ferror(fp)) {
        perror(argv[1]);
        fclose(fp);
        return EXIT_FAILURE;
    }

    printf("number of spaces: %ld\n", spaces);
    fclose(fp);
    return EXIT_SUCCESS;
}
