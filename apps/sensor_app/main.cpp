#include <iostream>
#include <chrono>
#include <thread>
#include <cmath>
#include <iomanip>
#include <sstream>

// sensor_app — Embedded IoT sensor node simulator
//
// Simulates a BME280-style temperature/humidity/pressure sensor connected
// to an embedded Linux board (RPi, BeagleBone, Jetson, etc.).
// On real hardware this would read from /dev/i2c-* or SPI device.
//
// Outputs newline-delimited JSON to stdout at a configurable sample rate.
// Compatible with vector/prometheus log scrapers in Kubernetes.

struct SensorReading {
    double temperature_c;   // Celsius
    double humidity_pct;    // Relative humidity 0-100%
    double pressure_hpa;    // Hectopascals
    long long timestamp_ms; // Unix epoch milliseconds
};

// Simulates ADC noise + sinusoidal drift around baseline sensor values
SensorReading read_sensors(int tick) {
    SensorReading r{};
    r.temperature_c  = 22.5 + 2.0 * std::sin(tick * 0.10);
    r.humidity_pct   = 55.0 + 5.0 * std::cos(tick * 0.07);
    r.pressure_hpa   = 1013.25 + 1.5 * std::sin(tick * 0.05);
    r.timestamp_ms   = std::chrono::duration_cast<std::chrono::milliseconds>(
                           std::chrono::system_clock::now().time_since_epoch())
                           .count();
    return r;
}

std::string to_json(const SensorReading& r) {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(2)
        << R"({"timestamp_ms":)" << r.timestamp_ms
        << R"(,"temperature_c":)" << r.temperature_c
        << R"(,"humidity_pct":)"  << r.humidity_pct
        << R"(,"pressure_hpa":)"  << r.pressure_hpa
        << "}";
    return oss.str();
}

int main() {
    std::cout << "[sensor_app] Embedded IoT sensor node starting..." << std::endl;

    int tick = 0;
    while (true) {
        SensorReading r = read_sensors(tick++);
        std::cout << to_json(r) << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
    return 0;
}
