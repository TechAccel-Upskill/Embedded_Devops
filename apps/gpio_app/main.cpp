#include <chrono>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

// gpio_app — Linux sysfs GPIO control daemon
//
// Demonstrates Linux GPIO via the sysfs interface — the standard way to
// control GPIO pins on embedded Linux boards from userspace without drivers.
//
// Real hardware usage:
//   GPIO pin 17 must be available and not claimed by another driver.
//   On Raspberry Pi: GPIO 17 = physical pin 11
//   On BeagleBone:   adjust GPIO_PIN to match your board's numbering
//
// Sysfs GPIO interface:
//   echo 17 > /sys/class/gpio/export          # claim pin
//   echo out > /sys/class/gpio/gpio17/direction
//   echo 1   > /sys/class/gpio/gpio17/value   # set HIGH
//   echo 0   > /sys/class/gpio/gpio17/value   # set LOW
//
// Gracefully falls back to simulation mode if sysfs GPIO is unavailable
// (running in Docker, on a VM, or non-GPIO hardware).

constexpr int GPIO_PIN = 17;

static const std::string GPIO_BASE   = "/sys/class/gpio/";
static const std::string GPIO_EXPORT = GPIO_BASE + "export";
static const std::string GPIO_UNEXPORT = GPIO_BASE + "unexport";
static const std::string GPIO_DIR    = GPIO_BASE + "gpio" + std::to_string(GPIO_PIN) + "/direction";
static const std::string GPIO_VAL    = GPIO_BASE + "gpio" + std::to_string(GPIO_PIN) + "/value";

static bool write_sysfs(const std::string& path, const std::string& value) {
    std::ofstream f(path);
    if (!f.is_open()) return false;
    f << value;
    return f.good();
}

static void simulation_mode() {
    std::cout << "[gpio_app] sysfs GPIO unavailable — simulation mode (pin " << GPIO_PIN << ")" << std::endl;
    int tick = 0;
    while (true) {
        int val = tick++ % 2;
        std::cout << "[gpio_app][sim] GPIO " << GPIO_PIN << " = " << val
                  << (val ? " HIGH" : " LOW") << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
    }
}

int main() {
    std::cout << "[gpio_app] GPIO control daemon starting (pin " << GPIO_PIN << ")..." << std::endl;

    // Export the GPIO pin to userspace via sysfs
    if (!write_sysfs(GPIO_EXPORT, std::to_string(GPIO_PIN))) {
        simulation_mode();
        return 0;
    }

    std::this_thread::sleep_for(std::chrono::milliseconds(100)); // wait for sysfs node creation

    // Set pin direction to output
    if (!write_sysfs(GPIO_DIR, "out")) {
        std::cerr << "[gpio_app] Failed to set GPIO " << GPIO_PIN << " direction to output" << std::endl;
        simulation_mode();
        return 0;
    }

    std::cout << "[gpio_app] GPIO " << GPIO_PIN << " configured as output — toggling at 1Hz" << std::endl;

    // Toggle pin at 1Hz (LED blink / PWM demonstration)
    int tick = 0;
    while (true) {
        int val = tick++ % 2;
        write_sysfs(GPIO_VAL, std::to_string(val));
        std::cout << "[gpio_app] GPIO " << GPIO_PIN << " = " << val
                  << (val ? " HIGH" : " LOW") << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
    }

    write_sysfs(GPIO_UNEXPORT, std::to_string(GPIO_PIN));
    return 0;
}
