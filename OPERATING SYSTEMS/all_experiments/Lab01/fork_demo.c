#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    int pause_seconds = 0;
    if (argc == 2) {
        pause_seconds = atoi(argv[1]);
        if (pause_seconds < 0 || pause_seconds > 30) {
            fprintf(stderr, "Usage: %s [pause-seconds 0..30]\n", argv[0]);
            return EXIT_FAILURE;
        }
    }

    printf("Before fork: one process, PID=%ld\n", (long)getpid());
    fflush(stdout);

    pid_t child_pid = fork();
    if (child_pid == -1) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (child_pid == 0) {
        printf("Child : PID=%ld, PPID=%ld, fork returned 0\n",
               (long)getpid(), (long)getppid());
        if (pause_seconds > 0) {
            sleep((unsigned int)pause_seconds);
        }
        return EXIT_SUCCESS;
    }

    printf("Parent: PID=%ld, child PID=%ld, fork returned %ld\n",
           (long)getpid(), (long)child_pid, (long)child_pid);

    int status = 0;
    if (waitpid(child_pid, &status, 0) == -1) {
        perror("waitpid");
        return EXIT_FAILURE;
    }

    if (WIFEXITED(status)) {
        printf("Parent: child exited with status %d\n", WEXITSTATUS(status));
    } else {
        printf("Parent: child ended abnormally\n");
    }

    return EXIT_SUCCESS;
}
