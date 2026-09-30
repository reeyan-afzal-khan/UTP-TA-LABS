#define _DEFAULT_SOURCE
#include <dirent.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

static void walk(const char *path, int depth) {
    DIR *directory = opendir(path);
    if (directory == NULL) {
        perror(path);
        return;
    }

    struct dirent *entry;
    while ((entry = readdir(directory)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        for (int i = 0; i < depth; i++) {
            printf("  ");
        }
        printf("- %s\n", entry->d_name);

        char child[PATH_MAX];
        if (snprintf(child, sizeof child, "%s/%s", path, entry->d_name) >= (int)sizeof child) {
            fprintf(stderr, "Path too long: %s/%s\n", path, entry->d_name);
            continue;
        }

        struct stat info;
        if (lstat(child, &info) == 0 && S_ISDIR(info.st_mode)) {
            walk(child, depth + 1);
        }
    }

    closedir(directory);
}

int main(int argc, char *argv[]) {
    const char *start = (argc == 2) ? argv[1] : ".";
    printf("%s\n", start);
    walk(start, 1);
    return EXIT_SUCCESS;
}
