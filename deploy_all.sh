#!/bin/bash
# deploy_all.sh - Build all Docker images with BuildKit and deploy Kubernetes manifests
set -e

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
for i in ${!DOCKERFILES[@]}; do
  docker buildx build --load -f docker/${DOCKERFILES[$i]} -t ${IMAGES[$i]} .
done

echo "Docker images built: ${IMAGES[*]}"

# Deploy to Kubernetes
kubectl apply -f k8s/manifest.yaml

echo "Kubernetes cluster deployed."
