#include <cerrno>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <chrono>
#include <thread>

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <unistd.h>
#include <linux/can.h>
#include <linux/can/raw.h>

// canbus_app — SocketCAN message handler
//
// Demonstrates Linux SocketCAN — the standard kernel CAN interface used on
// embedded Linux boards with CAN transceivers (MCP2515, TCAN4550, SJA1000).
//
// Real hardware setup:
//   ip link set can0 up type can bitrate 500000
//   candump can0     # observe frames
//
// Virtual CAN setup (for testing without hardware):
//   modprobe vcan
//   ip link add vcan0 type vcan && ip link set vcan0 up
//
// Gracefully falls back to simulation mode if no CAN interface is found.

constexpr uint32_t CAN_ID_SENSOR  = 0x101; // Temperature/pressure frame
constexpr uint32_t CAN_ID_STATUS  = 0x200; // System status frame
constexpr const char* CAN_IFACE   = "vcan0";

static bool send_frame(int sock, uint32_t id, const uint8_t* data, uint8_t len) {
    struct can_frame frame{};
    frame.can_id  = id;
    frame.can_dlc = len;
    std::memcpy(frame.data, data, len);
    return write(sock, &frame, sizeof(frame)) == sizeof(frame);
}

static void simulation_mode() {
    std::cout << "[canbus_app] No CAN interface — simulation mode" << std::endl;
    int tick = 0;
    while (true) {
        std::cout << "[canbus_app][sim] id=0x" << std::hex << CAN_ID_SENSOR
                  << " data=[temp=" << std::dec << (20 + tick % 10) << "C]"
                  << std::endl;
        ++tick;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

int main() {
    std::cout << "[canbus_app] SocketCAN message handler starting..." << std::endl;

    int sock = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (sock < 0) {
        std::cerr << "[canbus_app] socket(PF_CAN) failed: " << std::strerror(errno) << std::endl;
        simulation_mode();
        return 0;
    }

    struct ifreq ifr{};
    std::strncpy(ifr.ifr_name, CAN_IFACE, IFNAMSIZ - 1);
    if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0) {
        std::cerr << "[canbus_app] Interface " << CAN_IFACE
                  << " not found: " << std::strerror(errno) << std::endl;
        close(sock);
        simulation_mode();
        return 0;
    }

    struct sockaddr_can addr{};
    addr.can_family  = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (bind(sock, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) < 0) {
        std::cerr << "[canbus_app] bind() failed: " << std::strerror(errno) << std::endl;
        close(sock);
        return 1;
    }

    std::cout << "[canbus_app] Bound to " << CAN_IFACE << " — sending CAN frames..." << std::endl;

    int tick = 0;
    while (true) {
        // Sensor frame: 2 bytes [temp_raw_hi, temp_raw_lo]
        uint8_t sensor_data[2] = {
            static_cast<uint8_t>(0x18 + (tick % 5)),
            static_cast<uint8_t>(tick & 0xFF)
        };
        if (send_frame(sock, CAN_ID_SENSOR, sensor_data, 2)) {
            std::cout << "[canbus_app] TX id=0x" << std::hex << CAN_ID_SENSOR
                      << " tick=" << std::dec << tick << std::endl;
        }
        ++tick;
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }

    close(sock);
    return 0;
}
