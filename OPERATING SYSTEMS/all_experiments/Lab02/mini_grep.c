#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE 512

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s WORD FILE\n", argv[0]);
        return 2;
    }

    FILE *file = fopen(argv[2], "r");
    if (file == NULL) {
        perror(argv[2]);
        return 2;
    }

    char line[MAX_LINE];
    long line_number = 0;
    int matches = 0;

    while (fgets(line, sizeof line, file) != NULL) {
        line_number++;
        if (strstr(line, argv[1]) != NULL) {
            printf("%s:%ld: %s", argv[2], line_number, line);
            matches++;
        }
    }

    if (ferror(file)) {
        perror("read");
        fclose(file);
        return 2;
    }

    fclose(file);
    return (matches > 0) ? 0 : 1;
}
