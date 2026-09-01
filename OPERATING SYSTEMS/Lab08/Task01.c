/*
 * Lab 8, Task 1 --- Two threads serialized by a pthread mutex.
 *
 * STEP 1: Initialize one mutex.
 * STEP 2: Create two threads running the same job function.
 * STEP 3: Each thread locks the mutex, does its whole simulated job
 *         (start message, delay loop, finish message), then unlocks.
 * STEP 4: Join both threads and destroy the mutex.
 *
 * Because the lock is held around the ENTIRE job, the two jobs cannot
 * interleave: "Job 1 started / Job 1 finished / Job 2 started / Job 2
 * finished" appears in strict sequence even though two threads exist.
 * The mutex trades away the concurrency to guarantee the critical section
 * is never entered twice at once.
 *
 * Build: gcc -Wall -Wextra -pthread Task01.c -o task01
 */

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

pthread_t tid[2];
int counter = 0;
pthread_mutex_t lock;

void* doSomeThing(void *arg)
{
    (void)arg;   // required by the pthread signature; unused here

    pthread_mutex_lock(&lock);

    counter++;
    printf("\nJob %d started\n", counter);

    volatile unsigned long i;
    for(i = 0; i < 0xFFFFFFFF; i++);   // delay loop

    printf("\nJob %d finished\n", counter);

    pthread_mutex_unlock(&lock);
    return NULL;
}

int main(void)
{
    int i, err;

    if (pthread_mutex_init(&lock, NULL) != 0) {
        printf("Mutex init failed\n");
        return 1;
    }

    for(i = 0; i < 2; i++) {
        err = pthread_create(&(tid[i]), NULL, &doSomeThing, NULL);
        if (err != 0) {
            printf("Can't create thread: [%s]\n", strerror(err));
        }
    }

    pthread_join(tid[0], NULL);
    pthread_join(tid[1], NULL);

    pthread_mutex_destroy(&lock);

    return 0;
}
