#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ITERATIONS 200000
#define THREADS 2

static long counter = 0;
static int use_mutex = 1;
static pthread_mutex_t counter_mutex = PTHREAD_MUTEX_INITIALIZER;

static void *worker(void *argument) {
    long id = *(long *)argument;

    for (int i = 0; i < ITERATIONS; i++) {
        if (use_mutex) {
            pthread_mutex_lock(&counter_mutex);
        }

        long temporary = counter;
        temporary++;
        counter = temporary;

        if (use_mutex) {
            pthread_mutex_unlock(&counter_mutex);
        }
    }

    printf("Thread %ld finished\n", id);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc == 2 && strcmp(argv[1], "--no-lock") == 0) {
        use_mutex = 0;
    }

    pthread_t thread[THREADS];
    long id[THREADS] = {1, 2};

    for (int i = 0; i < THREADS; i++) {
        int result = pthread_create(&thread[i], NULL, worker, &id[i]);
        if (result != 0) {
            fprintf(stderr, "pthread_create failed with code %d\n", result);
            return EXIT_FAILURE;
        }
    }

    for (int i = 0; i < THREADS; i++) {
        pthread_join(thread[i], NULL);
    }

    printf("Mutex   : %s\n", use_mutex ? "enabled" : "disabled");
    printf("Expected: %d\n", THREADS * ITERATIONS);
    printf("Actual  : %ld\n", counter);
    return 0;
}
