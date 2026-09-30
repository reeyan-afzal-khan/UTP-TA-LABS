#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    const char *path = (argc == 2) ? argv[1] : ".";
    DIR *directory = opendir(path);

    if (directory == NULL) {
        perror(path);
        return EXIT_FAILURE;
    }

    printf("Directory entries in: %s\n", path);
    errno = 0;

    struct dirent *entry;
    while ((entry = readdir(directory)) != NULL) {
        printf("  %s\n", entry->d_name);
    }

    if (errno != 0) {
        perror("readdir");
        closedir(directory);
        return EXIT_FAILURE;
    }

    if (closedir(directory) == -1) {
        perror("closedir");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
