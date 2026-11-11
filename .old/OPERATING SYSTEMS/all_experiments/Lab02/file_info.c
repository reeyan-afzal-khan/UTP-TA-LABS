#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s PATH\n", argv[0]);
        return 2;
    }

    struct stat info;
    if (stat(argv[1], &info) == -1) {
        perror(argv[1]);
        return 2;
    }

    printf("Path       : %s\n", argv[1]);
    printf("Size       : %lld bytes\n", (long long)info.st_size);
    printf("Inode      : %llu\n", (unsigned long long)info.st_ino);
    printf("Hard links : %llu\n", (unsigned long long)info.st_nlink);
    printf("Permissions: %03o\n", (unsigned int)(info.st_mode & 0777));

    if (S_ISREG(info.st_mode)) {
        puts("Type       : regular file");
    } else if (S_ISDIR(info.st_mode)) {
        puts("Type       : directory");
    } else {
        puts("Type       : other");
    }

    return 0;
}
