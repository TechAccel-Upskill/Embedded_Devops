# Embedded OS Kubernetes Orchestrator

A production-ready framework for orchestrating multiple embedded operating systems (FreeRTOS, Mbed OS, and RTOS) across Kubernetes clusters. This project supports multiple build systems (CMake, Make, Bazel) and includes complete Docker containerization and CI/CD automation.

## 📋 Project Overview

This repository demonstrates best practices for:
- Building embedded OS applications with multiple build systems
- Containerizing embedded applications with Docker
- Orchestrating embedded workloads on Kubernetes
- Automating builds and deployments with GitHub Actions

**Supported Applications:**
- **FreeRTOS**: Real-time operating system microkernel
- **Mbed OS**: IoT and embedded systems operating system  
- **Zephyr**: Scalable real-time operating system

## 📁 Project Structure

```
embedded-os-k8s-orchestrator/
├── apps/                          # Application source code
│   ├── freertos_app/              # FreeRTOS application
│   │   ├── main.c
│   │   ├── CMakeLists.txt         # CMake configuration
│   │   ├── Makefile               # Make configuration
│   │   └── BUILD.bazel            # Bazel configuration
│   ├── mbed_app/                  # Mbed OS application
│   │   ├── main.cpp
│   │   ├── CMakeLists.txt
│   │   ├── Makefile
│   │   └── BUILD.bazel
│   └── zephyr_app/                # Zephyr RTOS application
│       ├── main.c
│       ├── CMakeLists.txt
│       ├── Makefile
│       └── BUILD.bazel
├── docker/                        # Container definitions
│   ├── Dockerfile.freertos        # FreeRTOS container
│   ├── Dockerfile.mbed            # Mbed OS container
│   └── Dockerfile.zephyr          # Zephyr container
├── k8s/                           # Kubernetes manifests
│   ├── namespace.yaml             # Embedded OS namespace
│   ├── services.yaml              # Service definitions
│   ├── freertos-deployment.yaml   # FreeRTOS deployment
│   ├── mbed-deployment.yaml       # Mbed deployment
│   └── zephyr-deployment.yaml     # Zephyr deployment
├── build_all.sh                   # Universal build script
├── deploy_all.sh                  # Docker build & deploy script
└── README.md                      # Project documentation
```

## 🚀 Quick Start

### Prerequisites
- Docker (for containerization)
- Kubernetes cluster + kubectl (for orchestration)
- CMake and Make (for building applications)
- Bazel (optional, for Bazel builds)

### Build All Applications

```bash
# Build all apps with all configured build systems
./build_all.sh
```

This script automatically:
- Builds each application with CMake
- Builds each application with Make
- Optionally builds with Bazel (if installed)

### Build Individual Applications

**FreeRTOS:**
```bash
cd apps/freertos_app
mkdir -p build && cd build && cmake .. && make
# Or using Make directly:
make -C ..
```

**Mbed OS:**
```bash
cd apps/mbed_app
mkdir -p build && cd build && cmake .. && make
# Or using Make directly:
make
```

**Zephyr:**
```bash
cd apps/zephyr_app
mkdir -p build && cd build && cmake .. && make
# Or using Make directly:
make
```

## 🏗️ Build Systems

Each application supports multiple build systems for flexibility:

| Build System | Status | Use Case |
|---|---|---|
| **CMake** | ✅ Fully Working | Modern, cross-platform (recommended) |
| **Make** | ✅ Fully Working | Traditional Unix-style builds |
| **Bazel** | ✅ Configured | Large-scale, monorepo builds (optional) |

**Build Outputs:**
- FreeRTOS: `apps/freertos_app/freertos_app`
- Mbed: `apps/mbed_app/mbed_app`
- Zephyr: `apps/zephyr_app/zephyr_app`

## 🐳 Docker Support

### Build Docker Images

```bash
# Build FreeRTOS image
docker build -f docker/Dockerfile.freertos -t freertos-app:latest .

# Build Mbed image
docker build -f docker/Dockerfile.mbed -t mbed-app:latest .

# Build Zephyr image
docker build -f docker/Dockerfile.zephyr -t zephyr-app:latest .
```

### Or Use the Deployment Script

```bash
./deploy_all.sh
```

Requires Docker buildx for multi-platform builds.

### Docker Features

All Dockerfiles include:
- ✅ Correct build contexts and layer optimization
- ✅ Build dependency installation
- ✅ Comprehensive build and runtime commands
- ✅ Exposed ports for health checks and communication

## ☸️ Kubernetes Orchestration

### Prerequisites

- Kubernetes cluster up and running
- `kubectl` configured and authenticated

### Deploy All Applications

```bash
# Deploy everything at once
kubectl apply -f k8s/

# Or deploy step-by-step
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/freertos-deployment.yaml
kubectl apply -f k8s/mbed-deployment.yaml
kubectl apply -f k8s/zephyr-deployment.yaml
```

### Verify Deployments

```bash
# Check pod status
kubectl get pods -n embedded-os

# Check services
kubectl get services -n embedded-os

# View logs for a specific pod
kubectl logs -n embedded-os <pod-name>

# Port-forward to access a service locally
kubectl port-forward -n embedded-os svc/<service-name> 8080:8080
```

### Kubernetes Features

The manifests include:

| Feature | Details |
|---|---|
| **Namespace** | Dedicated `embedded-os` namespace for all applications |
| **Deployments** | 2-replica deployments for each application (FreeRTOS, Mbed, Zephyr) |
| **Services** | ClusterIP services for pod-to-pod communication |
| **Health Checks** | Liveness probes for automatic pod restart on failure |
| **Resource Management** | CPU and memory requests/limits for stable operations |
| **Environment Variables** | Configurable settings for each deployment |

### Remove All Deployments

```bash
kubectl delete namespace embedded-os
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

This project includes an automated CI/CD pipeline (`.github/workflows/ci.yml`) that runs on:
- Push to main or develop branches
- Pull requests to main or develop branches

### Workflow Jobs

1. **Build** - Compiles all applications using CMake and Make
2. **Docker Build** - Builds and validates container images
3. **Kubernetes Validation** - Validates K8s manifest syntax (kubeval)
4. **Lint** - Quality checks on shell scripts

### Triggering Deployments

Push changes to trigger the pipeline:
```bash
git push origin main
```

## 📦 Build Outputs

All successful builds produce executables in their respective build directories:

```
✅ FreeRTOS:  apps/freertos_app/freertos_app
✅ Mbed:      apps/mbed_app/mbed_app
✅ Zephyr:    apps/zephyr_app/zephyr_app
```

## 🛠️ Development Workflow

### Local Development

1. Clone the repository
2. Build with `./build_all.sh` or individual app build commands
3. Test locally before pushing
4. Push to main/develop to trigger CI/CD

### Common Tasks

**Rebuild everything:**
```bash
./build_all.sh
```

**Clean build artifacts:**
```bash
find . -type d -name build -exec rm -rf {} + 2>/dev/null
find . -type f -name "freertos_app" -o -name "mbed_app" -o -name "zephyr_app" | xargs rm -f
```

**Update Docker images:**
```bash
./deploy_all.sh
```

**Redeploy to Kubernetes:**
```bash
kubectl rollout restart deployment/freertos -n embedded-os
kubectl rollout restart deployment/mbed -n embedded-os
kubectl rollout restart deployment/zephyr -n embedded-os
```

## 📚 Configuration Files

### Build Configuration

- **CMakeLists.txt** - CMake build definitions (each app)
- **Makefile** - Direct Make build targets (each app)
- **BUILD.bazel** - Bazel build rules (each app)

### Kubernetes Configuration

- **namespace.yaml** - Kubernetes namespace definition
- **services.yaml** - Service routing and networking
- **Deployment YAMLs** - Pod specs, replicas, health checks

### Docker Configuration

- **Dockerfile.*** - Container image definitions
- Includes build and runtime stages

## 🔍 Troubleshooting

### Build Failures

1. Check build logs: `make` or `cmake . && make` for verbose output
2. Ensure dependencies are installed: check Dockerfile for requirements
3. Verify build system is available: `cmake --version`, `make --version`, `bazel --version`

### Kubernetes Issues

1. Check pod logs: `kubectl logs -n embedded-os <pod-name>`
2. Describe pod for events: `kubectl describe pod -n embedded-os <pod-name>`
3. Check resource availability: `kubectl top nodes` and `kubectl top pods -n embedded-os`

### Docker Build Problems

1. Ensure Dockerfile context is correct: Run from repo root
2. Check for build layer caching issues: Use `--no-cache` flag
3. Verify image availability: `docker images | grep app`

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:
- Test changes locally before pushing
- Build all applications to ensure nothing breaks
- Update documentation if you change functionality
- Push to develop branch for review before merging to main

## ℹ️ Additional Resources

- [FreeRTOS Documentation](https://www.freertos.org/)
- [Mbed OS Documentation](https://os.mbed.com/docs/)
- [Zephyr RTOS Documentation](https://docs.zephyrproject.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)