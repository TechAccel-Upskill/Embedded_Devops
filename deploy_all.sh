#!/bin/bash
# deploy_all.sh - Build all Docker images with BuildKit and deploy Kubernetes manifests
set -e

# Always run relative to the repository root (script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Enable BuildKit
export DOCKER_BUILDKIT=1

# Check for buildx installation
if ! docker buildx version &>/dev/null; then
  echo "Docker buildx is not installed. Please follow https://docs.docker.com/go/buildx/ to install buildx."
  exit 1
fi

DOCKERFILES=(Dockerfile.freertos Dockerfile.gcc Dockerfile.zephyr)
IMAGES=(freertos-app gcc-app zephyr-app)

# Build Docker images with buildx
for i in "${!DOCKERFILES[@]}"; do
  docker buildx build --load -f "docker/${DOCKERFILES[$i]}" -t "${IMAGES[$i]}" .
done

echo "Docker images built: ${IMAGES[*]}"

# Optionally skip Kubernetes deployment (useful for local image-only builds)
if [[ "${SKIP_K8S:-0}" == "1" ]]; then
  echo "SKIP_K8S=1 detected. Skipping Kubernetes deployment."
  exit 0
fi

# Deploy to Kubernetes if a cluster is reachable
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "Kubernetes cluster is not reachable. Docker images were built successfully."
  echo "Start/connect a cluster, then run: kubectl apply -f k8s/manifest.yaml"
  exit 0
fi

kubectl apply -f k8s/manifest.yaml
echo "Kubernetes resources applied from k8s/manifest.yaml."
