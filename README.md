# Embedded OS Kubernetes Orchestrator

This project orchestrates a Kubernetes cluster with multiple Docker containers, each running a popular embedded OS SDK and separate C/C++ applications. The supported build systems include CMake, Make, and Bazel. This README provides an overview of the project structure, setup instructions, and usage guidelines.

## Project Structure

```
embedded-os-k8s-orchestrator
├── apps
│   ├── freertos_app        # FreeRTOS application source code and build configurations
│   ├── mbed_app            # Mbed application source code and build configurations
│   └── zephyr_app          # Zephyr application source code and build configurations
├── docker                   # Dockerfiles for each application
├── k8s                      # Kubernetes manifests for deployment
├── .github                  # CI/CD workflows for GitHub Actions
├── build_all.sh            # Universal build script for all applications
└── README.md                # Project documentation
```

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/microsoft/vscode-remote-try-cpp.git
   cd embedded-os-k8s-orchestrator
   ```

2. **Build Applications**
   You can build each application using the provided build systems. For example, to build the FreeRTOS application using CMake:
   ```bash
   cd apps/freertos_app
   mkdir build && cd build
   cmake ..
   make
   ```

   Alternatively, you can use the universal build script to build all applications:
   ```bash
   ./build_all.sh
   ```

3. **Build Docker Images**
   Each application has a corresponding Dockerfile. To build the Docker image for FreeRTOS:
   ```bash
   cd docker
   docker build -f Dockerfile.freertos -t freertos_app .
   ```

4. **Deploy to Kubernetes**
   Use the Kubernetes manifests located in the `k8s` directory to deploy the applications. For example, to deploy the FreeRTOS application:
   ```bash
   kubectl apply -f k8s/freertos-deployment.yaml
   ```

## CI/CD Integration

The project includes a CI/CD workflow defined in `.github/workflows/ci.yml`. This workflow automates the build, test, and deployment processes using GitHub Actions. Ensure that your repository is configured to use GitHub Actions to take advantage of this feature.

## Supported Build Systems

- **CMake**: Used for building applications with CMake configuration files.
- **Make**: Traditional build system supported through Makefiles.
- **Bazel**: Modern build system supported through Bazel build files.

## Applications

- **FreeRTOS Application**: Located in `apps/freertos_app`
- **Mbed Application**: Located in `apps/mbed_app`
- **Zephyr Application**: Located in `apps/zephyr_app`

## Documentation

For detailed information about each application, including specific build instructions and usage examples, refer to the respective directories and their README files (if available).

## License

This project is licensed under the MIT License. See the LICENSE file for more details.