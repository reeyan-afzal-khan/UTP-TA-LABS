#include <stdio.h>

#define CAPACITY 3

int main(void) {
    const char actions[] = {'C', 'P', 'P', 'P', 'P', 'C', 'C', 'C', 'C'};
    const int action_count = (int)(sizeof actions / sizeof actions[0]);
    int empty = CAPACITY;
    int full = 0;

    puts("P = produce, C = consume");
    puts("Step  Action  Empty  Full  Result");

    for (int i = 0; i < action_count; i++) {
        const char action = actions[i];
        const char *result = "allowed";

        if (action == 'P') {
            if (empty == 0) {
                result = "blocked: buffer full";
            } else {
                empty--;
                full++;
            }
        } else {
            if (full == 0) {
                result = "blocked: buffer empty";
            } else {
                full--;
                empty++;
            }
        }

        printf("%-5d %-7c %-6d %-5d %s\n",
               i + 1, action, empty, full, result);
    }

    return 0;
}
