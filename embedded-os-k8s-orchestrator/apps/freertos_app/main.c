#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

/* This is a simplified FreeRTOS application.
 * When building with the full FreeRTOS SDK, replace this with actual FreeRTOS API calls.
 */

void *task_function(void *arg) {
    while (1) {
        printf("Hello from FreeRTOS task!\n");
        sleep(1);
    }
    return NULL;
}

int main(void) {
    pthread_t thread;
    
    printf("Starting FreeRTOS application...\n");
    
    // Create a simple thread to simulate FreeRTOS task
    pthread_create(&thread, NULL, task_function, NULL);
    
    // Wait for the thread
    pthread_join(thread, NULL);
    
    return 0;
}