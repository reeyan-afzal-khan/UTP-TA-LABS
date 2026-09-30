#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void) {
    int pipe_fd[2];
    if (pipe(pipe_fd) == -1) {
        perror("pipe");
        return EXIT_FAILURE;
    }

    pid_t child = fork();
    if (child == -1) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (child == 0) {
        close(pipe_fd[1]);
        char buffer[128] = {0};
        ssize_t count = read(pipe_fd[0], buffer, sizeof buffer - 1);
        if (count == -1) {
            perror("read");
            return EXIT_FAILURE;
        }
        printf("Child received %zd bytes: %s\n", count, buffer);
        close(pipe_fd[0]);
        return EXIT_SUCCESS;
    }

    close(pipe_fd[0]);
    const char message[] = "message from parent through a pipe";
    if (write(pipe_fd[1], message, strlen(message) + 1) == -1) {
        perror("write");
        return EXIT_FAILURE;
    }
    close(pipe_fd[1]);
    waitpid(child, NULL, 0);
    return EXIT_SUCCESS;
}
