#include <stdio.h>
#include <unistd.h>

/* This is a simplified version of the Zephyr application.
 * When building with the full Zephyr SDK, replace includes and functions
 * with actual Zephyr API calls.
 */

int main(void) {
    printf("Hello from Zephyr!\n");

    while (1) {
        printf("Zephyr application running...\n");
        sleep(1);
    }
    return 0;
}