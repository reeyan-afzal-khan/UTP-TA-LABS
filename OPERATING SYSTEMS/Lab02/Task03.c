/*
 * Lab 2, Task 3 --- A miniature grep: print every line containing a word.
 *
 * STEP 1: Require exactly two arguments: a filename and a search word.
 * STEP 2: Open the file for reading.
 * STEP 3: Read it line by line with fgets(), counting lines as we go.
 * STEP 4: Strip the trailing newline so printed output lines up.
 * STEP 5: Use strstr() to test whether the line contains the word.
 * STEP 6: Print "file:line: text" for each match and tally the matches.
 * STEP 7: Report the total and close the file.
 *
 * Build: gcc -Wall -Wextra Task03.c -o task03
 * Run:   ./task03 somefile.txt hello
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 1024

static void usage(const char *program)
{
    fprintf(stderr, "usage: %s FILE WORD\n", program);
}

int main(int argc, char *argv[])
{
    if (argc != 3) {
        usage(argv[0]);
        return EXIT_FAILURE;
    }

    const char *filename = argv[1];
    const char *word     = argv[2];

    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        perror(filename);
        return EXIT_FAILURE;
    }

    char line[MAX_LINE];
    long line_number = 0;
    long matches     = 0;

    while (fgets(line, (int)sizeof line, fp) != NULL) {
        line_number++;

        /* fgets() keeps the '\n' when the line fits. Replace it with '\0'
         * so our own formatting controls where the line break goes.
         * A line longer than MAX_LINE-1 arrives without a newline and is
         * simply continued on the next fgets() call. */
        char *newline = strchr(line, '\n');
        if (newline != NULL) {
            *newline = '\0';
        }

        /* strstr() returns a pointer to the first occurrence, or NULL. */
        if (strstr(line, word) != NULL) {
            printf("%s:%ld: %s\n", filename, line_number, line);
            matches++;
        }
    }

    if (ferror(fp)) {
        perror(filename);
        fclose(fp);
        return EXIT_FAILURE;
    }

    printf("\n%ld matching line(s) out of %ld.\n", matches, line_number);
    fclose(fp);

    /* Like the real grep: 0 when something matched, 1 when nothing did. */
    return matches > 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
