/*
 * Lab 5, Task 1 --- Producer-consumer counters (menu-driven simulation).
 *
 * STEP 1: Model a buffer of capacity 3 with three integers:
 *           empty = free slots, full = filled slots, mutex = 1 when free.
 * STEP 2: Offer a menu: 1 produce, 2 consume, 3 exit.
 * STEP 3: Produce only while empty != 0; consume only while full != 0.
 * STEP 4: Each action moves one unit between empty and full, so the
 *         invariant  empty + full = 3  holds after every valid action.
 *         Check it after each step --- that is the deliverable.
 *
 * IMPORTANT: wait() and signal() here are ordinary integer decrements and
 * increments in a single-threaded menu loop. They illustrate the counting
 * bookkeeping only --- they are NOT atomic and provide no real mutual
 * exclusion. A genuine semaphore needs kernel or atomic support.
 *
 * Build: gcc -Wall -Wextra Task01.c -o task01
 */

#include <stdio.h>
#include <stdlib.h>

// Global semaphores and item count
int mutex = 1, full = 0, empty = 3, x = 0;

// Function declarations
int wait(int s);
int signal(int s);
void producer();
void consumer();

int main() {
    int n;

    printf("\n1. PRODUCER\n2. CONSUMER\n3. EXIT\n");

    while (1) {
        printf("\nENTER YOUR CHOICE: ");
        scanf("%d", &n);

        switch (n) {
            case 1:
                if ((mutex == 1) && (empty != 0))
                    producer();
                else
                    printf("\nBUFFER IS FULL!");
                break;

            case 2:
                if ((mutex == 1) && (full != 0))
                    consumer();
                else
                    printf("\nBUFFER IS EMPTY!");
                break;

            case 3:
                printf("\nExiting program...\n");
                exit(0);

            default:
                printf("\nInvalid choice! Please enter 1, 2, or 3.\n");
                break;
        }
    }
}

// Wait operation
int wait(int s) {
    return (--s);
}

// Signal operation
int signal(int s) {
    return (++s);
}

// Producer function
void producer() {
    mutex = wait(mutex);
    empty = wait(empty);
    full = signal(full);
    x++;
    printf("\nProducer produces item %d", x);
    mutex = signal(mutex);
}

// Consumer function
void consumer() {
    mutex = wait(mutex);
    full = wait(full);
    empty = signal(empty);
    printf("\nConsumer consumes item %d", x);
    x--;
    mutex = signal(mutex);
}
