# Embedded OS Kubernetes Orchestrator - Student Learning Guide

A comprehensive one-stop teaching repository for learning **Docker**, **Kubernetes**, and **Build Systems** through practical embedded OS applications. This project demonstrates production-ready practices while remaining accessible for students.

## 🎓 What Students Will Learn

This repository covers:
- **Docker**: Containerization, multi-stage builds, health checks, security hardening
- **Kubernetes**: Deployments, services, namespaces, resource management, networking
- **Build Systems**: CMake, Make, and Bazel for the same source code
- **Embedded Systems**: Working with FreeRTOS, Zephyr RTOS, and standard C/C++ with GCC
- **DevOps**: CI/CD pipeline, container orchestration, infrastructure patterns

## 📚 Learning Outcomes

By working through this project, students will understand:

| Concept | Where Learned | Files |
|---------|---------------|-------|
| **Docker Basics** | Build container images | `docker/Dockerfile.*` |
| **Multi-stage Builds** | Optimize image size | `docker/Dockerfile.freertos` |
| **Health Checks** | Monitor container health | Docker HEALTHCHECK + K8s probes |
| **Non-root Security** | Container security best practices | All Dockerfiles |
| **Build Systems** | CMake, Make, Bazel for same source | `apps/*/CMakeLists.txt`, `Makefile`, `BUILD.bazel` |
| **K8s Deployments** | Deploy apps to cluster | `k8s/manifest.yaml` |
| **K8s Services** | Expose apps via network | `k8s/manifest.yaml` |
| **K8s Namespaces** | Organize and isolate resources | `k8s/manifest.yaml` |
| **Resource Quotas** | Limit cluster resource usage | `k8s/manifest.yaml` |
| **Network Policies** | Control pod communication | `k8s/manifest.yaml` |
| **Health Probes** | Liveness and readiness checks | `k8s/manifest.yaml` |
| **Rolling Updates** | Zero-downtime deployments | `k8s/manifest.yaml` strategy |
| **Embedded Systems** | FreeRTOS, Zephyr, and standard C/C++ | `apps/freertos_app`, `apps/gcc_app`, `apps/zephyr_app` |
| **CI/CD** | GitHub Actions automation | `.github/workflows/`

## 📁 Project Structure & Learning Flow

```
embedded-os-k8s-orchestrator/
├── apps/                          # Source code - same codebase, different build systems
│   ├── freertos_app/              # FreeRTOS application
│   │   ├── main.c                 # Application logic
│   │   ├── CMakeLists.txt         # Build with CMake ← Learn CMake basics
│   │   ├── Makefile               # Build with Make ← Learn Make fundamentals
│   │   └── BUILD.bazel            # Build with Bazel ← Learn Bazel build system
│   ├── gcc_app/                   # Standard C/C++ application
│   │   ├── main.cpp               # Application logic
│   │   ├── CMakeLists.txt         # Build with CMake
│   │   ├── Makefile               # Build with Make
│   │   └── BUILD.bazel            # Build with Bazel
│   └── zephyr_app/                # Zephyr RTOS application
│       ├── main.c                 # Application logic
│       ├── CMakeLists.txt         # CMake build
│       ├── Makefile               # Make build
│       └── BUILD.bazel            # Bazel build
├── docker/                        # Docker learning
│   ├── Dockerfile.freertos        # Single-stage + security ← Learn Docker basics
│   ├── Dockerfile.gcc             # GCC C++ application ← Learn Docker with GCC
│   └── Dockerfile.zephyr          # Pre-built base images ← Learn Docker best practices
├── k8s/                           # Kubernetes learning
│   └── manifest.yaml              # ← All K8s resources in one file (namespace, services, deployments)
├── build_all.sh                   # Build automation
├── deploy_all.sh                  # Docker + deployment automation
└── README.md                      # This file
```

## 🎯 Supported Applications

### **FreeRTOS** (`apps/freertos_app`)
- **Purpose**: Teaches embedded RTOS basics
- **Base Image**: `livius147/freertos:latest`
- **Learning**: Bare-metal embedded development
- **Deploy**: `k8s/manifest.yaml`

### **Zephyr RTOS** (`apps/zephyr_app`)
- **Purpose**: Modern scalable RTOS
- **Base Image**: `sjmay/zephyr:latest`
- **Learning**: Zephyr ecosystem and tooling
- **Deploy**: `k8s/manifest.yaml`

### **GCC C/C++ Application** (`apps/gcc_app`)
- **Purpose**: Standard C/C++ applications using GCC compiler
- **Base Image**: `gcc:14-bookworm`
- **Learning**: Non-RTOS embedded development, standard compiler toolchain
- **Deploy**: `k8s/manifest.yaml`

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

**GCC C/C++:**
```bash
cd apps/gcc_app
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

## 🏗️ Build Systems - One Source, Three Ways

Each application can be built with **CMake**, **Make**, and **Bazel**. This teaches students:
- How different build systems work
- Pros and cons of each approach
- How to support multiple build systems for same codebase

| Build System | Complexity | Use Case | Learning |
|---|---|---|---|
| **Make** | 🟢 Simple | Small embedded projects | Unix build fundamentals |
| **CMake** | 🟡 Medium | Cross-platform builds | Modern build generation |
| **Bazel** | 🔴 Complex | Large monorepos | Enterprise-scale builds |

**Student Exercise**: Build same app with all 3 systems and compare build times, binary sizes, and flexibility.

## 🐳 Docker - Containerization & Security

### Learning Objectives
- ✅ Understand container layering
- ✅ Learn health checks (HEALTHCHECK)
- ✅ Security hardening (non-root users)
- ✅ Using pre-built base images
- ✅ Container networking

### Dockerfiles Analyzed
```
Dockerfile.freertos  → livius147/freertos:latest + build + health checks
Dockerfile.gcc       → gcc:14-bookworm + build + health checks
Dockerfile.zephyr    → sjmay/zephyr:latest + build + health checks
```

**Student Exercise**: Modify Dockerfiles to add logging, change ports, or add new dependencies.

## ☸️ Kubernetes - Orchestration & Deployment

### Learning Objectives
- ✅ Namespace isolation and resource quotas
- ✅ Services and networking
- ✅ Deployments and replica management
- ✅ Health checks (liveness and readiness)
- ✅ Rolling updates and zero-downtime deployments
- ✅ Security contexts and RBAC
- ✅ Network policies

### K8s Components Explained

The `manifest.yaml` file contains:

#### **Namespace** - Isolation & Resource Management
```yaml
Namespace:        embedded-os          # Isolated environment
ResourceQuota:    limits resource usage # Prevent exhaustion (3 cores req, 6 cores limit)
NetworkPolicy:    controls traffic     # Security controls for pod communication
```
**Students Learn**: How to organize K8s resources, prevent resource hogging, and implement network security.

#### **Services** - Networking
```yaml
freertos-service  → Port 8080 (ClusterIP)
gcc-service       → Port 8080 (ClusterIP)
zephyr-service    → Port 8080 (ClusterIP)
SessionAffinity:  ClientIP             # Sticky sessions (300s timeout)
```
**Students Learn**: How to expose pods, manage endpoints, and enable service discovery.

#### **Deployments** - Pod Management
```yaml
freertos-app      → 2 replicas
gcc-app           → 2 replicas
zephyr-app        → 2 replicas
```

**Key Learning Points**:
- ✅ RollingUpdate strategy → Zero-downtime deployments
- ✅ Replicas → High availability (2 pods each)
- ✅ Resource requests/limits → Fair resource allocation
- ✅ Liveness probes → Automatic pod recovery
- ✅ Readiness probes → Careful traffic routing
- ✅ Security contexts → Run as non-root user

### Deploy All Applications

```bash
# Deploy all resources (namespace, services, deployments) with one command
kubectl apply -f k8s/manifest.yaml
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
kubectl port-forward -n embedded-os svc/freertos-service 8080:8080
# Also try: svc/gcc-service or svc/zephyr-service
```

### Kubernetes Features

The `manifest.yaml` includes:

| Feature | Details | Learning |
|---|---|---|
| **Namespace** | Isolated `embedded-os` namespace | Resource organization |
| **Deployments** | 2-replica deployments (FreeRTOS, Zephyr) | High availability |
| **Services** | ClusterIP services for networking | Service discovery |
| **Health Checks** | Liveness + Readiness probes | Reliability & availability |
| **Resource Limits** | CPU and memory constraints | Resource management |
| **Rolling Updates** | Zero-downtime deployments | Deployment strategies |
| **Security** | Non-root users, dropped capabilities | Security hardening |

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

---

## 🎓 Student Learning Path

### **Week 1-2: Build Systems**
1. Build FreeRTOS with Make
2. Build FreeRTOS with CMake
3. Build FreeRTOS with Bazel
4. Compare build outputs and times
5. Modify the source and rebuild with all three

**Exercise**: Which build system is fastest? Why? When would you use each?

### **Week 3-4: Docker & Containerization**
1. Examine `Dockerfile.freertos`
2. Build the Docker image locally
3. Run the container and check health checks
4. Modify Dockerfile to add logging
5. Build and test the modified image

**Exercise**: Re-implement the Dockerfiles to use different base images.

### **Week 5-6: Kubernetes & Orchestration**
1. Deploy all manifests: `kubectl apply -f k8s/manifest.yaml`
2. Check pods: `kubectl get pods -n embedded-os`
3. Check services: `kubectl get services -n embedded-os`
4. Monitor health probes and pod restart behavior
5. Manually terminate a pod and watch Kubernetes restart it
6. Check ResourceQuota and NetworkPolicy constraints

**Exercise**: Modify the manifest to scale FreeRTOS to 4 replicas, then re-apply and observe rolling update.

### **Week 7: Integration & DevOps**
1. Modify source code in `apps/freertos_app/main.c`
2. Rebuild with all build systems
3. Build new Docker image
4. Re-deploy to Kubernetes and monitor rolling update
5. Observe how health probes detect the new deployment

**Exercise**: Create a broken build and observe how health checks detect it and fail gracefully.

---

## 📚 Teaching Resources

### Key Files to Study
- **Docker**: `docker/Dockerfile.freertos`, `docker/Dockerfile.gcc`, `docker/Dockerfile.zephyr`
- **Build Systems**: `apps/*/CMakeLists.txt`, `Makefile`, `BUILD.bazel` (FreeRTOS, GCC, Zephyr)
- **Kubernetes**: `k8s/manifest.yaml` (single source of truth for all K8s resources)
- **Automation**: `build_all.sh`, `deploy_all.sh`

### Concepts to Explain
1. **Why namespaces?** → Resource isolation and organization
2. **Why probes?** → Automatic failure detection and recovery
3. **Why rolling updates?** → Zero-downtime deployments
4. **Why three build systems?** → Different use cases (simple, cross-platform, enterprise)
5. **Why health checks?** → Container and pod reliability

---

## 📦 Build Outputs

All successful builds produce executables in their respective build directories:

```
✅ FreeRTOS:  apps/freertos_app/build/freertos_app
✅ Zephyr:    apps/zephyr_app/build/zephyr_app
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
find . -type f \( -name "freertos_app" -o -name "zephyr_app" \) | xargs rm -f
```

**Update Docker images:**
```bash
./deploy_all.sh
```

**Redeploy to Kubernetes:**
```bash
kubectl rollout restart deployment/freertos-app -n embedded-os
kubectl rollout restart deployment/zephyr-app -n embedded-os
```

## 📚 Configuration Files

### Build Configuration

- **CMakeLists.txt** - CMake build definitions (each app)
- **Makefile** - Direct Make build targets (each app)
- **BUILD.bazel** - Bazel build rules (each app)

### Kubernetes Configuration

- **manifest.yaml** - Complete Kubernetes configuration (namespace, ResourceQuota, NetworkPolicy, services, deployments)
  - Single source of truth for all K8s resources
  - Includes: namespace `embedded-os`, resource quotas, network policies, 3 services, 3 deployments

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
- [Zephyr RTOS Documentation](https://docs.zephyrproject.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [CMake Documentation](https://cmake.org/documentation/)
- [Bazel Documentation](https://bazel.build/docs)