#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

#define SEGMENT_SIZE 256

int main(void) {
    key_t key = ftok(".", 'O');
    if (key == -1) {
        perror("ftok");
        return EXIT_FAILURE;
    }

    int segment_id = shmget(key, SEGMENT_SIZE, IPC_CREAT | 0660);
    if (segment_id == -1) {
        perror("shmget");
        return EXIT_FAILURE;
    }

    char *memory = shmat(segment_id, NULL, 0);
    if (memory == (void *)-1) {
        perror("shmat");
        return EXIT_FAILURE;
    }

    snprintf(memory, SEGMENT_SIZE,
             "Hello from shared memory (writer PID=%ld)", (long)getpid());
    printf("Created/used segment ID %d\n", segment_id);
    printf("Stored message: %s\n", memory);

    if (shmdt(memory) == -1) {
        perror("shmdt");
        return EXIT_FAILURE;
    }

    puts("Writer detached. The segment remains for the reader.");
    return EXIT_SUCCESS;
}
