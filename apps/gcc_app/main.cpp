#include <iostream>
#include <chrono>
#include <thread>

int main() {
    std::cout << "Starting gcc_app..." << std::endl;
    
    int counter = 0;
    while (true) {
        std::cout << "gcc_app running - iteration: " << counter++ << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
    }
    
    return 0;
}