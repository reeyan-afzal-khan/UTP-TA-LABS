/*
 * Lab 6, Task 3 --- POSIX thread creation, identity, and joining.
 *
 * STEP 1: Create two threads with pthread_create(), both running the same
 *         function.
 * STEP 2: Inside the function, each thread finds its own identity with
 *         pthread_self() and matches it against the stored ids using
 *         pthread_equal() (thread ids are opaque --- never compare with ==).
 * STEP 3: Each thread simulates work, then reports completion.
 * STEP 4: main() joins both threads so the process cannot exit while they
 *         are still running.
 *
 * Build: gcc -Wall -Wextra -pthread Task03.c -o task03
 */

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

pthread_t tid[2];  // Global thread IDs

// Thread function
void* doSomeThing(void *arg)
{
    (void)arg;   // required by the pthread signature; unused here
    unsigned long i = 0;
    pthread_t id = pthread_self();

    if (pthread_equal(id, tid[0])) {
        printf("\nFirst thread processing\n");
    } 
    else if (pthread_equal(id, tid[1])) {
        printf("\nSecond thread processing\n");
    } 
    else {
        printf("\nUnknown thread\n");
    }

    // Simulate some work
    for (i = 0; i < 0xFFFFFFF; i++);

    printf("Thread %lu finished execution\n", id);
    return NULL;
}

int main(void)
{
    int i, err;

    printf("Creating threads...\n");

    // Create two threads
    for (i = 0; i < 2; i++) {
        err = pthread_create(&(tid[i]), NULL, &doSomeThing, NULL);
        if (err != 0)
            printf("\nCan't create thread %d: [%s]\n", i + 1, strerror(err));
        else
            printf("Thread %d created successfully\n", i + 1);
    }

    // Wait for threads to finish
    for (i = 0; i < 2; i++) {
        pthread_join(tid[i], NULL);
    }

    printf("\nBoth threads finished execution.\n");
    return 0;
}
