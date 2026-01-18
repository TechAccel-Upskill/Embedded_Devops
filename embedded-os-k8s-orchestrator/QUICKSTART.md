# Quick Start Guide

Your Embedded OS Kubernetes Orchestrator repository is now fully functional! Here's how to get started:

## Building Applications

All three applications (FreeRTOS, Mbed, and Zephyr) are configured to build with multiple build systems:

### Build Everything
```bash
./build_all.sh
```

This script will:
- Build each application with CMake
- Build each application with Make
- Skip Bazel builds if not installed (it's optional)

### Build Individual Apps

**FreeRTOS:**
```bash
cd apps/freertos_app
mkdir -p build && cd build && cmake .. && make
# or
make -C ..
```

**Mbed:**
```bash
cd apps/mbed_app
mkdir -p build && cd build && cmake .. && make
# or
make
```

**Zephyr:**
```bash
cd apps/zephyr_app
mkdir -p build && cd build && cmake .. && make
# or
make
```

## Docker Images

All applications have Dockerfiles configured to build container images:

```bash
# Build FreeRTOS image
docker build -f docker/Dockerfile.freertos -t freertos-app:latest .

# Build Mbed image
docker build -f docker/Dockerfile.mbed -t mbed-app:latest .

# Build Zephyr image
docker build -f docker/Dockerfile.zephyr -t zephyr-app:latest .
```

Or use the deploy script (requires Docker buildx):
```bash
./deploy_all.sh
```

## Kubernetes Deployment

First, ensure you have kubectl configured and a Kubernetes cluster running.

### Deploy Everything
```bash
# Create namespace and deploy all applications
kubectl apply -f k8s/

# Or deploy individually
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/freertos-deployment.yaml
kubectl apply -f k8s/mbed-deployment.yaml
kubectl apply -f k8s/zephyr-deployment.yaml
```

### Verify Deployments
```bash
# Check pods
kubectl get pods -n embedded-os

# Check services
kubectl get services -n embedded-os

# View logs
kubectl logs -n embedded-os <pod-name>
```

## Project Structure

```
embedded-os-k8s-orchestrator/
├── apps/
│   ├── freertos_app/      # FreeRTOS application
│   ├── mbed_app/          # Mbed OS application
│   └── zephyr_app/        # Zephyr RTOS application
├── docker/                # Container configurations
├── k8s/                   # Kubernetes manifests
├── .github/workflows/     # GitHub Actions CI/CD
├── build_all.sh          # Build script (CMake, Make, Bazel)
├── deploy_all.sh         # Docker build and push script
└── README.md             # Project documentation
```

## Build Systems

All applications support multiple build systems:

- **CMake**: Modern, cross-platform build system
- **Make**: Traditional Unix build system
- **Bazel**: Google's build system (optional, skipped if not installed)

## CI/CD

GitHub Actions workflows automatically:
- Build all applications with CMake and Make
- Build Docker images
- Validate Kubernetes manifests
- Lint shell scripts

See `.github/workflows/ci.yml` for details.

## Notes

- **FreeRTOS, Mbed, Zephyr**: The applications are built as standalone versions since the full SDKs are not installed. For production use, install the respective SDKs and update the source files accordingly.
- **Bazel**: Optional build system. Install with: `apt-get install bazel`
- **Docker**: Ensure Docker daemon is running for image building
- **Kubernetes**: Set up a cluster (minikube, docker desktop, or cloud provider)

## Troubleshooting

**CMake not found**
```bash
apt-get install cmake
```

**Docker build fails**
```bash
docker buildx create --name mybuilder --use
```

**Kubernetes connection error**
```bash
kubectl config view  # Check configuration
```

For more information, see individual README files in each directory.
