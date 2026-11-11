#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUFFER_SIZE 256

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s SOURCE DESTINATION\n", argv[0]);
        return 2;
    }

    int source = open(argv[1], O_RDONLY);
    if (source == -1) {
        perror(argv[1]);
        return 2;
    }

    int destination = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (destination == -1) {
        perror(argv[2]);
        close(source);
        return 2;
    }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    long total = 0;

    while ((bytes_read = read(source, buffer, sizeof buffer)) > 0) {
        ssize_t written = 0;
        while (written < bytes_read) {
            ssize_t result = write(destination,
                                   buffer + written,
                                   (size_t)(bytes_read - written));
            if (result == -1) {
                perror("write");
                close(source);
                close(destination);
                return 2;
            }
            written += result;
        }
        total += bytes_read;
    }

    if (bytes_read == -1) {
        perror("read");
        close(source);
        close(destination);
        return 2;
    }

    if (close(source) == -1 || close(destination) == -1) {
        perror("close");
        return 2;
    }

    printf("Copied %ld bytes from %s to %s\n", total, argv[1], argv[2]);
    return 0;
}
