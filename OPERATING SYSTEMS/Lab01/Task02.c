/*
 * Lab 1, Task 2 --- Create a child process and report both process IDs.
 *
 * STEP 1: Call fork() to duplicate the current process.
 * STEP 2: fork() returns -1 on failure, 0 in the child, and the child's
 *         PID in the parent. Handle all three cases.
 * STEP 3: Each process prints its own PID via getpid().
 * STEP 4: The parent waits for the child so the ordering is deterministic.
 *
 * Build: gcc -Wall -Wextra Task02.c -o task02
 * Note:  POSIX only (unistd.h, sys/wait.h). Use Linux or WSL.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void)
{
    /* pid_t, not int: the width of a process ID is platform-defined. */
    pid_t pid = fork();

    if (pid == -1) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        /* Child branch. getppid() is the parent that forked us. */
        printf("child : pid=%ld, parent=%ld\n",
               (long)getpid(), (long)getppid());
        return EXIT_SUCCESS;
    }

    /* Parent branch. */
    printf("parent: pid=%ld, child=%ld\n", (long)getpid(), (long)pid);

    /* Without wait() the two processes race and the output order varies
     * between runs. Comment this block out and run it ten times to see. */
    int status = 0;
    if (waitpid(pid, &status, 0) == -1) {
        perror("waitpid");
        return EXIT_FAILURE;
    }
    if (WIFEXITED(status)) {
        printf("parent: child exited with status %d\n", WEXITSTATUS(status));
    }

    return EXIT_SUCCESS;
}
