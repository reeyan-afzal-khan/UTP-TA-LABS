#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define SEGMENT_SIZE 256

int main(void) {
    key_t key = ftok(".", 'O');
    if (key == -1) {
        perror("ftok");
        return EXIT_FAILURE;
    }

    int segment_id = shmget(key, SEGMENT_SIZE, 0660);
    if (segment_id == -1) {
        perror("shmget (run shm_writer first)");
        return EXIT_FAILURE;
    }

    char *memory = shmat(segment_id, NULL, 0);
    if (memory == (void *)-1) {
        perror("shmat");
        return EXIT_FAILURE;
    }

    printf("Attached to segment ID %d\n", segment_id);
    printf("Read message: %s\n", memory);

    if (shmdt(memory) == -1) {
        perror("shmdt");
        return EXIT_FAILURE;
    }

    if (shmctl(segment_id, IPC_RMID, NULL) == -1) {
        perror("shmctl");
        return EXIT_FAILURE;
    }

    puts("Reader detached and marked the segment for removal.");
    return EXIT_SUCCESS;
}
