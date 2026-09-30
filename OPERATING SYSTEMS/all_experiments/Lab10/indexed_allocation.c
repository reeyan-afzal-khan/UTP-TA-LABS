#include <stdio.h>

#define BLOCKS 20

static int used[BLOCKS] = {0};

static void print_map(void) {
    printf("Allocated blocks:");
    int any = 0;
    for (int block = 0; block < BLOCKS; block++) {
        if (used[block]) {
            printf(" %d", block);
            any = 1;
        }
    }
    puts(any ? "" : " none");
}

static int request_is_valid(int index_block, const int data_blocks[], int count) {
    if (index_block < 0 || index_block >= BLOCKS || used[index_block]) {
        return 0;
    }

    for (int i = 0; i < count; i++) {
        int block = data_blocks[i];
        if (block < 0 || block >= BLOCKS || block == index_block || used[block]) {
            return 0;
        }

        for (int j = 0; j < i; j++) {
            if (data_blocks[j] == block) {
                return 0;
            }
        }
    }
    return 1;
}

static int allocate_file(int index_block, const int data_blocks[], int count) {
    if (!request_is_valid(index_block, data_blocks, count)) {
        return 0;
    }

    used[index_block] = 1;
    for (int i = 0; i < count; i++) {
        used[data_blocks[i]] = 1;
    }
    return 1;
}

int main(void) {
    const int file_a[] = {3, 8, 12};
    const int file_b[] = {5, 8, 14};
    const int file_c[] = {5, 9, 14};

    printf("File A: %s\n", allocate_file(2, file_a, 3) ? "allocated" : "rejected");
    print_map();

    printf("File B (overlaps block 8): %s\n",
           allocate_file(4, file_b, 3) ? "allocated" : "rejected");
    print_map();

    printf("File C: %s\n", allocate_file(4, file_c, 3) ? "allocated" : "rejected");
    print_map();

    return 0;
}
