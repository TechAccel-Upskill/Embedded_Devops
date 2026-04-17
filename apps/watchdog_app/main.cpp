#include <atomic>
#include <chrono>
#include <csignal>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>

#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

// watchdog_app — Embedded health watchdog daemon
//
// Models a software watchdog — a fundamental embedded systems pattern.
// On real embedded Linux devices (routers, PLCs, industrial controllers)
// a watchdog daemon periodically "kicks" the hardware watchdog timer
// and exposes a health endpoint for external monitoring.
//
// This implementation:
//   - Runs a heartbeat loop (increments counter every 5s)
//   - Serves an HTTP /health endpoint on port 8080 (raw POSIX sockets)
//   - Kubernetes liveness probe hits /health → response = 200 OK + JSON
//   - Handles SIGTERM for graceful shutdown

static std::atomic<long long> heartbeat_count{0};
static std::atomic<bool>      running{true};
static const auto             start_time = std::chrono::steady_clock::now();

static long long uptime_seconds() {
    return std::chrono::duration_cast<std::chrono::seconds>(
               std::chrono::steady_clock::now() - start_time)
        .count();
}

static bool write_all(int fd, const std::string& data) {
    size_t total_written = 0;
    while (total_written < data.size()) {
        const ssize_t bytes_written = write(
            fd,
            data.data() + total_written,
            data.size() - total_written);
        if (bytes_written <= 0) {
            return false;
        }
        total_written += static_cast<size_t>(bytes_written);
    }
    return true;
}

// Heartbeat loop — simulates kicking a hardware watchdog timer
static void heartbeat_loop() {
    while (running) {
        ++heartbeat_count;
        std::cout << "[watchdog] heartbeat=" << heartbeat_count.load()
                  << " uptime=" << uptime_seconds() << "s" << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(5));
    }
}

// Minimal HTTP/1.0 server — serves /health on port 8080
static void http_server() {
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        std::cerr << "[watchdog] socket() failed — health endpoint unavailable" << std::endl;
        return;
    }

    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    sockaddr_in addr{};
    addr.sin_family      = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port        = htons(8080);

    if (bind(server_fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) < 0) {
        std::cerr << "[watchdog] bind() failed — health endpoint unavailable" << std::endl;
        close(server_fd);
        return;
    }

    listen(server_fd, 5);
    std::cout << "[watchdog] Health endpoint: http://0.0.0.0:8080/health" << std::endl;

    while (running) {
        int client_fd = accept(server_fd, nullptr, nullptr);
        if (client_fd < 0) continue;

        char buf[512] = {};
        const ssize_t bytes_read = read(client_fd, buf, sizeof(buf) - 1);
        if (bytes_read < 0) {
            std::cerr << "[watchdog] read() failed while handling request" << std::endl;
            close(client_fd);
            continue;
        }

        std::ostringstream body;
        body << R"({"status":"ok")"
             << R"(,"heartbeat":)" << heartbeat_count.load()
             << R"(,"uptime_s":)"  << uptime_seconds()
             << "}";
        const std::string body_str = body.str();

        std::ostringstream resp;
        resp << "HTTP/1.0 200 OK\r\n"
             << "Content-Type: application/json\r\n"
             << "Content-Length: " << body_str.size() << "\r\n"
             << "\r\n"
             << body_str;
        const std::string resp_str = resp.str();
        if (!write_all(client_fd, resp_str)) {
            std::cerr << "[watchdog] write() failed while sending response" << std::endl;
        }
        close(client_fd);
    }
    close(server_fd);
}

static void signal_handler(int) {
    running = false;
}

int main() {
    std::signal(SIGINT,  signal_handler);
    std::signal(SIGTERM, signal_handler);

    std::cout << "[watchdog_app] Embedded watchdog daemon starting..." << std::endl;

    std::thread hb(heartbeat_loop);
    std::thread hs(http_server);
    hb.join();
    hs.join();
    return 0;
}
