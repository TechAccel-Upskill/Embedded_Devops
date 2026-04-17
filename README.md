# Embedded OS Kubernetes Orchestrator — Student Learning Guide

A comprehensive one-stop teaching repository for learning **Docker**, **Kubernetes**, **Build Systems**,
and **Cross-Compilation** through practical embedded Linux applications written in C++17.
This project demonstrates production-ready DevOps practices while remaining accessible to students.

## 🎓 What Students Will Learn

This repository covers:
- **Cross-Compilation**: Build C++ for ARM Cortex-A, AArch64, and RISC-V targets from an x86_64 host
- **Build Systems**: CMake (with Presets), Make, and Bazel for the same source code
- **Docker**: Multi-stage builds, shared base images, health checks, security hardening
- **Kubernetes**: Deployments, services, namespaces, resource management, per-arch scheduling
- **DevOps**: Variant-driven CI/CD pipeline, GHCR container registry, infrastructure as code
- **Embedded Systems**: Real Linux-native apps — sensor data, health watchdog, CAN bus, GPIO

## 📚 Learning Outcomes

By working through this project, students will understand:

| Concept | Where Learned | Files |
|---|---|---|
| **Build Systems** | CMake, Make, Bazel for same source | `apps/*/CMakeLists.txt`, `Makefile`, `BUILD.bazel` |
| **CMake Presets** | Select target arch via preset name | `apps/*/CMakePresets.json` |
| **Cross-Compilation** | GNU toolchain files, sysroot config | `cmake/toolchain-*.cmake` |
| **Variant Management** | Single source of truth for all builds | `variants.yaml` |
| **Multi-stage Builds** | Toolchain → compile → slim runtime | `docker/Dockerfile.*` |
| **Shared Base Images** | Build tools installed once, reused | `docker/Dockerfile.builder` |
| **K8s Deployments** | Deploy per-arch app images | `k8s/manifest.yaml` |
| **K8s Services** | Expose apps via network | `k8s/manifest.yaml` |
| **K8s Namespaces** | Organize and isolate resources | `k8s/manifest.yaml` |
| **Resource Quotas** | Limit cluster resource consumption | `k8s/manifest.yaml` |
| **Network Policies** | Control pod-to-pod communication | `k8s/manifest.yaml` |
| **Health Probes** | Liveness and readiness checks | `k8s/manifest.yaml` |
| **Rolling Updates** | Zero-downtime deployments | `k8s/manifest.yaml` strategy |
| **Per-arch Scheduling** | Node selection by CPU architecture | `nodeSelector` in manifest |
| **CI/CD Matrix** | Dynamic parallel jobs from config | `.github/workflows/ci.yml` |

## 📁 Project Structure & Learning Flow

```
Embedded_Devops/
│
├── variants.yaml                   # ← Master control file: ALL build variants live here
│                                   #   drives build_all.sh, deploy_all.sh, CI, k8s
│
├── apps/                           # Source code — same codebase, multiple build systems
│   ├── gcc_app/                    # Baseline app: "Hello from <arch>" — all 3 build systems
│   │   ├── main.cpp                # Application logic
│   │   ├── CMakeLists.txt          # Build with CMake ← Learn CMake basics
│   │   ├── CMakePresets.json       # Preset per target arch ← Learn preset-based builds
│   │   ├── Makefile                # Build with Make ← Learn Make fundamentals
│   │   └── BUILD.bazel             # Build with Bazel ← Learn Bazel build system
│   │
│   ├── sensor_app/                 # IoT: reads BME280-style sensor, publishes JSON to stdout
│   ├── watchdog_app/               # Embedded daemon: heartbeat counter + HTTP /health :8080
│   ├── canbus_app/                 # SocketCAN: sends/receives CAN frames on vcan0
│   └── gpio_app/                   # Linux sysfs: toggles GPIO17 at 1 Hz
│
├── cmake/                          # Cross-compilation toolchain files (used by CMakePresets)
│   ├── toolchain-arm-linux-gnueabihf.cmake   # ARMv7-A hard-float (Raspberry Pi 3/4 32-bit)
│   ├── toolchain-aarch64-linux-gnu.cmake     # 64-bit ARM Linux (Raspberry Pi 4 64-bit)
│   └── toolchain-riscv64-linux-gnu.cmake     # RISC-V 64-bit Linux (QEMU, SiFive boards)
│
├── docker/
│   ├── Dockerfile.builder          # Shared toolchain base (CMake, Make, Git, curl)
│   ├── Dockerfile.gcc_app          # 3-stage: toolchain → build → debian:slim runtime
│   ├── Dockerfile.sensor_app       # 3-stage: toolchain → build → debian:slim runtime
│   ├── Dockerfile.watchdog_app     # 3-stage + EXPOSE 8080 (HTTP health endpoint)
│   ├── Dockerfile.canbus_app       # 3-stage: toolchain → build → debian:slim runtime
│   └── Dockerfile.gpio_app         # 3-stage: toolchain → build → debian:slim runtime
│
├── k8s/
│   └── manifest.yaml               # GENERATED — do not edit by hand
│                                   # Re-generate: python3 scripts/generate_k8s.py
│
├── scripts/
│   ├── generate_k8s.py             # variants.yaml → k8s/manifest.yaml
│   └── generate_matrix.py          # variants.yaml → GitHub Actions CI matrix JSON
│
├── .github/workflows/
│   └── ci.yml                      # 4-job pipeline: builder → matrix → build+push → deploy
│
├── build_all.sh                    # Native cross-compile all variants (auto-installs tools)
├── deploy_all.sh                   # Docker build + push to GHCR + apply k8s manifest
└── README.md                       # This file
```

## 🎯 Supported Applications

### **GCC Baseline App** (`apps/gcc_app`)
- **Purpose**: Simplest possible application — prints "Hello from \<arch\>". Teaches all 3 build systems and all 4 target architectures.
- **What it demonstrates**: CMake, Make, and Bazel building the exact same code, cross-compilation from x86_64 to ARM/AArch64/RISC-V
- **Supported targets**: x86_64, ARMv7-A, AArch64, RISC-V 64

### **Sensor App** (`apps/sensor_app`)
- **Purpose**: Simulates a BME280 environmental sensor (temperature, humidity, pressure). Outputs JSON to stdout every 2 seconds.
- **What it demonstrates**: Real IoT data pipeline pattern, pthread-based periodic sampling, cross-compile safe C++17
- **Supported targets**: x86_64, ARMv7-A, AArch64, RISC-V 64

### **Watchdog App** (`apps/watchdog_app`)
- **Purpose**: Embedded health watchdog daemon. Increments a heartbeat counter on a background thread and serves `{"status":"ok","heartbeat":N,"uptime_s":N}` over raw HTTP on port 8080.
- **What it demonstrates**: POSIX socket programming, multi-threading, SIGTERM handling, Kubernetes HTTP liveness probes
- **Supported targets**: x86_64, ARMv7-A, AArch64

### **CAN Bus App** (`apps/canbus_app`)
- **Purpose**: Sends and receives CAN frames on `vcan0` using Linux SocketCAN (`linux/can.h`). Gracefully falls back to simulation when no CAN interface is available.
- **What it demonstrates**: Linux network socket programming, embedded industrial protocols, hardware abstraction
- **Supported targets**: x86_64, ARMv7-A, AArch64

### **GPIO App** (`apps/gpio_app`)
- **Purpose**: Toggles GPIO pin 17 at 1 Hz using the Linux sysfs interface (`/sys/class/gpio/`). Gracefully falls back to simulation in Docker.
- **What it demonstrates**: Linux hardware access from user space, sysfs GPIO, embedded daemon pattern
- **Supported targets**: x86_64, ARMv7-A, AArch64

## 🗂️ variants.yaml — The Master Control File

`variants.yaml` is the **single source of truth** for everything in this repo. Every build, Docker image,
CI job, and Kubernetes Deployment is derived from it automatically.

```yaml
- app: sensor_app          # which app to build (directory under apps/)
  arch: arm-cortex-a       # human-readable architecture label
  platform: arm-linux-gnueabihf  # GNU triple → selects the cross-compiler
  build_system: cmake      # cmake | make | bazel
  cmake_preset: release-arm      # which CMakePresets.json preset to use
```

**19 variants** are defined across 5 apps and 4 platforms:

| App | x86_64 | ARM Cortex-A | AArch64 | RISC-V 64 |
|---|---|---|---|---|
| `gcc_app` | cmake + bazel | cmake | cmake | make |
| `sensor_app` | cmake | cmake | cmake | make |
| `watchdog_app` | cmake | cmake | make | — |
| `canbus_app` | cmake | cmake | cmake | — |
| `gpio_app` | cmake | cmake | cmake | — |

**Student Exercise**: Add a new variant (e.g. `gpio_app` for `riscv64`) to `variants.yaml` and run `./build_all.sh`. Observe how everything updates automatically — build, CI, and k8s manifest.

## 🚀 Quick Start

### Prerequisites
- Docker with Buildx (for multi-stage cross-compilation image builds)
- Kubernetes cluster + kubectl (for orchestration)
- GHCR personal access token with `read:packages` + `write:packages` scopes
- CMake, Make, GCC, Bazel, python3 — **installed automatically** by `build_all.sh` if missing

> **Note**: You do NOT need to install build tools manually. `build_all.sh` detects and installs
> CMake, Make, GCC, cross-compilers, Bazel (via Bazelisk), and python3-yaml before building.

### Build All Variants Natively

```bash
./build_all.sh

# Remove prior outputs, then rebuild everything
./build_all.sh --clean

# Force a rebuild even when targets look up to date
./build_all.sh --force

# Combine both for the most aggressive rebuild path
./build_all.sh --clean --force
```

This script reads `variants.yaml` and dispatches:
- `cmake --preset <preset>` for cmake variants
- `make PLATFORM=<gnu-triple> ARCH=<arch>` for make variants
- `bazel build //... --config=<config>` for bazel variants

Build options:
- `--clean` removes existing outputs before each variant build.
- `--force` requests a rebuild from the underlying build tool.

### Build a Single Application Manually

```bash
# CMake — choose your preset
cd apps/sensor_app
cmake --preset release-arm           # cross-compile for ARMv7-A Cortex-A
cmake --build --preset release-arm

# Make — pass PLATFORM and ARCH
cd apps/gpio_app
make PLATFORM=aarch64-linux-gnu ARCH=aarch64
# shorthand targets also available:
make aarch64

# Bazel — native only
cd apps/gcc_app
bazel build //... --config=x86_64
```

### Build Docker Images & Push to GHCR

```bash
# Login to GHCR first
docker login ghcr.io -u <github-username> -p <github-pat>

# Build all (app × arch) images and push
./deploy_all.sh

# Skip rebuilding the shared builder base image
SKIP_BUILDER=1 ./deploy_all.sh

# Build and push only (no Kubernetes deployment)
SKIP_K8S=1 ./deploy_all.sh

# Local mode: build/load into local Docker engine (no registry push)
DEPLOY_MODE=local ./deploy_all.sh

# Local mode + build only (skip Kubernetes apply)
DEPLOY_MODE=local SKIP_K8S=1 ./deploy_all.sh
```

### Deploy to Kubernetes

```bash
# One-time: create the GHCR pull secret in your cluster
kubectl create secret docker-registry ghcr-pull-secret \
  --namespace embedded-os \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-pat-with-read:packages>

# Regenerate the manifest from variants.yaml and apply
python3 scripts/generate_k8s.py
kubectl apply -f k8s/manifest.yaml
```

## 🏗️ Build Systems — One Source, Three Ways

Each application supports **CMake**, **Make**, and **Bazel** from the exact same `main.cpp`. This teaches students to appreciate trade-offs between build systems.

| Build System | Variant selection | Complexity | Best for |
|---|---|---|---|
| **CMake** | `CMakePresets.json` preset name | 🟡 Medium | Cross-platform, IDE integration, Docker images |
| **Make** | `PLATFORM=` / `ARCH=` env vars | 🟢 Simple | Embedded projects, quick cross builds, RISC-V |
| **Bazel** | `--config=` flag in `.bazelrc` | 🔴 Complex | Native only here; enterprise monorepo pattern |

### CMake Presets

Every app has a `CMakePresets.json` with four presets. The preset name controls which toolchain file is loaded:

| Preset | Target | Toolchain file |
|---|---|---|
| `release-x86_64` | Host machine (native) | _(none — host compiler)_ |
| `release-arm` | ARMv7-A Cortex-A (hard-float) | `cmake/toolchain-arm-linux-gnueabihf.cmake` |
| `release-aarch64` | 64-bit ARM Linux | `cmake/toolchain-aarch64-linux-gnu.cmake` |
| `release-riscv64` | RISC-V 64-bit Linux | `cmake/toolchain-riscv64-linux-gnu.cmake` |

**Student Exercise**: Build the same app with all three build systems and compare build times, binary sizes, and flexibility. Which is fastest? When would you choose each?

## 🐳 Docker — Multi-Stage Cross-Compilation Images

### Learning Objectives
- ✅ Understand container layer caching
- ✅ Learn multi-stage builds to separate compile vs runtime
- ✅ Understand why build tools should NOT be in production images
- ✅ Use build arguments to parameterize Dockerfiles
- ✅ Security hardening with non-root users

### The 3-Stage Build Pattern

All app Dockerfiles follow the same structure:

```
Stage 1 — toolchain    FROM embedded-builder (shared base)
                         RUN apt install gcc-<platform>
                         # Only adds the cross-compiler for this variant's arch

Stage 2 — builder        COPY cmake/ apps/<app>/
                         RUN cmake --preset <preset>
                         RUN cmake --build --preset <preset>
                         # Compiles the binary using the cross-compiler

Stage 3 — runtime      FROM debian:bookworm-slim
                         COPY --from=builder /src/apps/<app>/build/<preset>/<binary> /app/
                         # Final image: binary only — no compilers, no build tools
```

**Why multi-stage?** Build tools (GCC, CMake, Bazel) are ~400MB+. The runtime image only needs the
compiled binary (~80 MB total instead of ~500 MB). This is production best practice.

### Build Arguments

Each Dockerfile accepts two build args:

| ARG | Example | What it does |
|---|---|---|
| `PLATFORM` | `arm-linux-gnueabihf` | Selects which cross-compiler to apt-install |
| `CMAKE_PRESET` | `release-arm` | Selects which CMakePresets.json preset to build |

```bash
# Manual single-image build
docker buildx build \
  --build-arg PLATFORM=arm-linux-gnueabihf \
  --build-arg CMAKE_PRESET=release-arm \
  -f docker/Dockerfile.sensor_app \
  -t ghcr.io/techaccel-upskill/sensor-app-arm-cortex-a:latest \
  .
```

### Shared Base Image

`docker/Dockerfile.builder` installs the common toolchain (CMake, Make, Git, curl) and is pushed to
GHCR **once**. All app Dockerfiles `FROM` this image so tools are never re-installed on every build.

**Student Exercise**: Modify a Dockerfile to add an extra dependency (e.g. `libssl-dev`). Observe how layer caching works — only affected layers rebuild.

## ☸️ Kubernetes — Orchestration & Per-Architecture Deployment

### Learning Objectives
- ✅ Namespace isolation and resource quotas
- ✅ Services and pod networking
- ✅ Deployments and replica management
- ✅ Health probes (liveness, readiness)
- ✅ Rolling updates and zero-downtime deployments
- ✅ Security contexts (non-root, dropped capabilities)
- ✅ Network policies
- ✅ Per-architecture node scheduling with `nodeSelector`

### What the Generated Manifest Contains

`k8s/manifest.yaml` is **generated** by `python3 scripts/generate_k8s.py` from `variants.yaml`.  
**Do not edit it by hand** — regenerate it when `variants.yaml` changes.

```
Namespace:          embedded-os           # Isolated environment for all apps
ResourceQuota:      limits CPU + memory   # Prevent resource exhaustion
NetworkPolicy:      controls traffic      # Security controls for pod communication

Per (app × arch) cmake variant:
  Service:          ClusterIP on port 8080     # Only watchdog_app (has HTTP /health)
  Deployment:       2 replicas                 # High availability
                    nodeSelector: arch         # Route to correct hardware
                    imagePullSecrets           # Pull from private GHCR
                    liveness probe             # Auto-restart failing pods
                    readiness probe            # Careful traffic routing
                    resource limits            # Fair CPU/memory allocation
                    non-root security context  # Container security hardening
```

### Per-Architecture Node Scheduling

Each Deployment has a `nodeSelector` that routes the image to the correct node type:

| `arch` in `variants.yaml` | `kubernetes.io/arch` on node |
|---|---|
| `x86_64` | `amd64` |
| `arm-cortex-a` | `arm` |
| `aarch64` | `arm64` |
| `riscv64` | `riscv64` |

This means a `sensor-app-arm-cortex-a` Deployment will **only** schedule on ARM 32-bit nodes.
A mixed cluster (x86 + ARM Raspberry Pis) will automatically run the right binary on the right node.

### Health Probes Per App

| App | Liveness probe | Why |
|---|---|---|
| `watchdog_app` | `httpGet /health :8080` | Has a real HTTP server — use it |
| All others | `exec: test -f /app/<binary>` | No HTTP — just prove the binary exists |

### K8s Resources Summary

14 Deployments + 2 Services are generated across 5 apps:

```
gcc-app          → x86_64, arm-cortex-a, aarch64          (Deployment only)
sensor-app       → x86_64, arm-cortex-a, aarch64          (Deployment only)
watchdog-app     → x86_64, arm-cortex-a     (Deployment + Service — HTTP /health)
canbus-app       → x86_64, arm-cortex-a, aarch64          (Deployment only)
gpio-app         → x86_64, arm-cortex-a, aarch64          (Deployment only)
```

### Verify Deployments

```bash
# Check pod status
kubectl get pods -n embedded-os

# Check services
kubectl get services -n embedded-os

# View logs for a specific pod
kubectl logs -n embedded-os <pod-name>

# Test the watchdog health endpoint
kubectl port-forward -n embedded-os svc/watchdog-app-x86-64 8080:8080
curl http://localhost:8080/health

# Describe a pod to see events and probe results
kubectl describe pod -n embedded-os <pod-name>

# Remove all resources
kubectl delete namespace embedded-os
```

**Student Exercise**: Manually delete a running pod (`kubectl delete pod -n embedded-os <name>`) and watch Kubernetes automatically restart it. What health probe detected the failure?

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The pipeline in `.github/workflows/ci.yml` triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`

### Workflow Jobs

| Job | Trigger | What it does |
|---|---|---|
| **build-builder-image** | Only when `docker/Dockerfile.builder` changes | Builds + pushes shared `embedded-builder:latest` to GHCR. Saves CI time — runs once, not every commit. |
| **generate-matrix** | Every push/PR | Runs `scripts/generate_matrix.py` to output a JSON matrix from `variants.yaml` |
| **build-and-push-apps** | Every push/PR (parallel matrix) | One parallel job per `(app, arch)` cmake variant — builds cross-compiled Docker image + pushes to GHCR |
| **deploy** | Push to `main` only | Regenerates `k8s/manifest.yaml`, validates with `--dry-run=server`, then applies to cluster |

### Dynamic CI Matrix

The CI matrix is generated **automatically** from `variants.yaml` — no hardcoded app lists in the pipeline:

```
14 parallel jobs (one per cmake variant):
  gcc_app     [x86_64]        gcc_app     [arm-cortex-a]    gcc_app     [aarch64]
  sensor_app  [x86_64]        sensor_app  [arm-cortex-a]    sensor_app  [aarch64]
  watchdog_app [x86_64]       watchdog_app [arm-cortex-a]
  canbus_app  [x86_64]        canbus_app  [arm-cortex-a]    canbus_app  [aarch64]
  gpio_app    [x86_64]        gpio_app    [arm-cortex-a]    gpio_app    [aarch64]
```

Adding a new app or architecture to `variants.yaml` **automatically adds a new CI job** — no workflow edits needed.

### Required Secrets

| Secret | Used by |
|---|---|
| `GITHUB_TOKEN` | GHCR push (automatic, no setup needed) |
| `KUBE_CONFIG` | Base64-encoded kubeconfig for cluster deployment |

### Triggering the Pipeline

```bash
git push origin main
```

**Student Exercise**: Add a new variant to `variants.yaml`, push to `develop`, and watch the CI matrix expand with a new job automatically.

## 📦 Build Outputs

After `./build_all.sh`, native binaries appear in each app's build directory:

```
apps/gcc_app/build/release-x86_64/gcc_app
apps/gcc_app/build/release-arm/gcc_app
apps/sensor_app/build/release-arm/sensor_app
apps/watchdog_app/build/release-aarch64/watchdog_app
... (one dir per cmake preset per app)
```

After `./deploy_all.sh`, Docker images are pushed to GHCR:

```
✅ ghcr.io/techaccel-upskill/embedded-builder:latest      (shared toolchain)

✅ ghcr.io/techaccel-upskill/gcc-app-x86-64:latest
✅ ghcr.io/techaccel-upskill/gcc-app-arm-cortex-a:latest
✅ ghcr.io/techaccel-upskill/gcc-app-aarch64:latest

✅ ghcr.io/techaccel-upskill/sensor-app-x86-64:latest
✅ ghcr.io/techaccel-upskill/sensor-app-arm-cortex-a:latest
✅ ghcr.io/techaccel-upskill/sensor-app-aarch64:latest

✅ ghcr.io/techaccel-upskill/watchdog-app-x86-64:latest
✅ ghcr.io/techaccel-upskill/watchdog-app-arm-cortex-a:latest

✅ ghcr.io/techaccel-upskill/canbus-app-x86-64:latest
✅ ghcr.io/techaccel-upskill/canbus-app-arm-cortex-a:latest
✅ ghcr.io/techaccel-upskill/canbus-app-aarch64:latest

✅ ghcr.io/techaccel-upskill/gpio-app-x86-64:latest
✅ ghcr.io/techaccel-upskill/gpio-app-arm-cortex-a:latest
✅ ghcr.io/techaccel-upskill/gpio-app-aarch64:latest
```

## 🎓 Student Learning Path

### **Week 1–2: Build Systems & Cross-Compilation**
1. Read `variants.yaml` — understand the variant model
2. Run `./build_all.sh` — observe cmake/make/bazel dispatch in the output
3. Manually build `gcc_app` with all three build systems
4. Manually build `sensor_app` for two different architectures using `cmake --preset`
5. Open `cmake/toolchain-arm-linux-gnueabihf.cmake` — understand `CMAKE_SYSROOT` and `FIND_ROOT_PATH`

**Exercise**: Add the `riscv64` variant for `gpio_app` in `variants.yaml` and run `build_all.sh`. Why does only the `make` build system work for RISC-V in this repo?

### **Week 3–4: Docker & Containerization**
1. Read `docker/Dockerfile.sensor_app` — identify all three stages
2. Build it manually with `--build-arg PLATFORM=native --build-arg CMAKE_PRESET=release-x86_64`
3. Run `docker history` on the final image — measure the size difference vs the builder stage
4. Read `docker/Dockerfile.watchdog_app` — find the `EXPOSE 8080` and health check
5. Modify a Dockerfile to add a `LABEL` — observe how cache invalidation works

**Exercise**: Change the runtime base image from `debian:bookworm-slim` to `alpine:3.19` and try to build. What breaks and why? What must you add to fix it?

### **Week 5–6: Kubernetes & Orchestration**
1. Run `python3 scripts/generate_k8s.py` and open `k8s/manifest.yaml` — read one full Deployment
2. Deploy: `kubectl apply -f k8s/manifest.yaml`
3. Find the `nodeSelector` in the manifest — explain how it routes ARM images to ARM nodes
4. Kill a pod and watch Kubernetes restart it — which probe detected the failure?
5. Port-forward the `watchdog-app-x86-64` service and curl `/health`
6. Read the `ResourceQuota` — calculate total CPU/memory reserved across all Deployments

**Exercise**: Edit `variants.yaml` to add a third replica for `sensor_app/x86_64`, regenerate the manifest, and apply it. Observe the rolling update in real time.

### **Week 7: CI/CD Integration**
1. Read `.github/workflows/ci.yml` — trace all 4 jobs and their dependencies
2. Run `python3 scripts/generate_matrix.py` locally — examine the JSON output
3. Add a new variant to `variants.yaml` and count how many CI jobs appear in the next run
4. Set the `KUBE_CONFIG` secret in your fork and push to `main` — watch the full pipeline
5. Break a build intentionally (syntax error in `main.cpp`) — observe how the matrix job fails without blocking others

**Exercise**: Modify `scripts/generate_matrix.py` to also include a `make_arch` field in the output. How would you add a separate CI job for Make-based cross builds?

## 🛠️ Development Workflow

### Common Tasks

**Rebuild everything natively:**
```bash
./build_all.sh
```

**Add a new app variant** (e.g. watchdog_app for riscv64):
```yaml
# append to variants.yaml
- app: watchdog_app
  arch: riscv64
  platform: riscv64-linux-gnu
  build_system: make
  make_arch: riscv64
```
Then run `./build_all.sh` and `python3 scripts/generate_k8s.py`.

**Regenerate Kubernetes manifest:**
```bash
python3 scripts/generate_k8s.py
kubectl apply -f k8s/manifest.yaml
```

**Rebuild and redeploy a single app:**
```bash
SKIP_BUILDER=1 SKIP_K8S=1 ./deploy_all.sh  # rebuild images only

kubectl rollout restart deployment/sensor-app-arm-cortex-a -n embedded-os
```

**Create GHCR pull secret (one-time per cluster):**
```bash
kubectl create secret docker-registry ghcr-pull-secret \
  --namespace embedded-os \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-pat-with-read:packages>
```

**Clean build artifacts:**
```bash
find apps -type d \( -name "build" -o -name "build-*" \) -exec rm -rf {} + 2>/dev/null || true
```

## 🔍 Troubleshooting

### Build Failures

```bash
# Verbose cmake output
cmake --preset release-arm -- -v

# Verify cross-compiler is installed
which arm-linux-gnueabihf-g++

# Install cross-compiler manually
sudo apt-get install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
```

### Docker Build Problems

```bash
# Build with no cache to force a clean rebuild
docker buildx build --no-cache \
  --build-arg PLATFORM=native \
  --build-arg CMAKE_PRESET=release-x86_64 \
  -f docker/Dockerfile.gcc_app .

# Inspect image layers and sizes
docker history ghcr.io/techaccel-upskill/gcc-app-x86-64:latest
```

### Kubernetes Issues

```bash
# See Events (most useful for debugging probe failures)
kubectl describe pod -n embedded-os <pod-name>

# Stream container logs
kubectl logs -f -n embedded-os <pod-name>

# Check resource usage
kubectl top pods -n embedded-os
kubectl get events -n embedded-os --sort-by=.lastTimestamp
```

## 📚 Key Files to Study

| Topic | File | What to look for |
|---|---|---|
| **Variant system** | `variants.yaml` | Schema: app, arch, platform, build_system |
| **Cross-compilation** | `cmake/toolchain-arm-linux-gnueabihf.cmake` | `CMAKE_C_COMPILER`, `FIND_ROOT_PATH_MODE_*` |
| **CMake Presets** | `apps/sensor_app/CMakePresets.json` | How `toolchainFile` links to `cmake/` |
| **Multi-stage Docker** | `docker/Dockerfile.watchdog_app` | `ARG PLATFORM`, `FROM` stages, `COPY --from=` |
| **K8s manifest** | `k8s/manifest.yaml` | `nodeSelector`, `imagePullSecrets`, probe types |
| **CI matrix** | `.github/workflows/ci.yml` | `generate-matrix` job → `fromJson(...)` |
| **Generator scripts** | `scripts/generate_matrix.py` | How variants.yaml becomes CI JSON |

## 📄 Additional Resources

- [CMake Presets Documentation](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
- [GNU Cross-Compilation Guide](https://gcc.gnu.org/onlinedocs/gcc/Cross-Compilation.html)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [SocketCAN Documentation](https://www.kernel.org/doc/html/latest/networking/can.html)
- [Linux GPIO Sysfs Interface](https://www.kernel.org/doc/Documentation/gpio/sysfs.txt)
- [Bazel Build Documentation](https://bazel.build/docs)
- [GHCR Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
