#include <iostream>
#include <chrono>
#include <thread>

/* This is a simplified Mbed application.
 * When building with the full Mbed SDK, replace this with actual Mbed API calls.
 */

int main() {
    std::cout << "Starting Mbed application..." << std::endl;
    
    int counter = 0;
    while (true) {
        std::cout << "Mbed application running - iteration: " << counter++ << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    }
    
    return 0;
}