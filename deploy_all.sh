#!/bin/bash
# deploy_all.sh — Build Docker images and deploy to Kubernetes driven by variants.yaml
#
# FLOW:
#   1. (Optional) Build & push the shared embedded-builder base image to GHCR
#      Skip with: SKIP_BUILDER=1 ./deploy_all.sh
#   2. Read variants.yaml via Python — collect unique (app, arch, platform, cmake_preset) tuples
#   3. Build and push one Docker image per (app, arch) using the matching Dockerfile
#   4. Regenerate k8s/manifest.yaml and apply to Kubernetes cluster
#
# PREREQUISITES:
#   docker login ghcr.io -u <github-username> -p <github-pat>
#   kubectl must be connected to a cluster (kubectl cluster-info)
#
# ENV VARS:
#   REGISTRY     — Override registry (default: ghcr.io)
#   ORG          — Override org/owner  (default: techaccel-upskill)
#   SKIP_BUILDER — Set to 1 to skip rebuilding the builder base image
#   SKIP_K8S     — Set to 1 to skip Kubernetes deployment

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export DOCKER_BUILDKIT=1

REGISTRY="${REGISTRY:-ghcr.io}"
ORG="${ORG:-techaccel-upskill}"
BUILDER_IMAGE="${REGISTRY}/${ORG}/embedded-builder:latest"

if ! docker buildx version &>/dev/null; then
    echo "ERROR: Docker buildx not installed. See https://docs.docker.com/go/buildx/"
    exit 1
fi

if ! command -v python3 &>/dev/null; then
    echo "ERROR: python3 is required."
    exit 1
fi

# ── Step 1: Build & push shared builder base image ───────────────────────────
if [[ "${SKIP_BUILDER:-0}" == "1" ]]; then
    echo "SKIP_BUILDER=1 — using cached: $BUILDER_IMAGE"
else
    echo "=== Building shared toolchain base image ==="
    docker buildx build \
        --push \
        -f docker/Dockerfile.builder \
        -t "${BUILDER_IMAGE}" \
        .
    echo "Pushed: $BUILDER_IMAGE"
fi
echo ""

# ── Step 2 & 3: Build app images per (app, arch) from variants.yaml ──────────
echo "=== Building and pushing app images ==="

python3 - << PYEOF
import subprocess, sys, os

try:
    import yaml
except ImportError:
    print("ERROR: python3-yaml not installed. Run: sudo apt-get install python3-yaml")
    sys.exit(1)

REGISTRY = "${REGISTRY}"
ORG      = "${ORG}"
BUILDER_IMAGE = "${BUILDER_IMAGE}"

with open("variants.yaml") as f:
    config = yaml.safe_load(f)

# Collect unique (app, arch) from cmake variants (cmake drives Docker images)
seen = set()
targets = []
for v in config.get("variants", []):
    if v.get("build_system") != "cmake":
        continue
    key = (v["app"], v["arch"])
    if key in seen:
        continue
    seen.add(key)
    targets.append({
        "app":    v["app"],
        "arch":   v["arch"],
        "platform": v.get("platform", "native"),
        "cmake_preset": v["cmake_preset"],
    })

pushed, failed = [], []

for t in targets:
    app    = t["app"]
    arch   = t["arch"]
    platform     = t["platform"]
    cmake_preset = t["cmake_preset"]

    # e.g. sensor-app-arm-cortex-a
    image_name = f"{app.replace('_', '-')}-{arch}"
    image_tag  = f"{REGISTRY}/{ORG}/{image_name}:latest"
    dockerfile = f"docker/Dockerfile.{app}"

    if not os.path.isfile(dockerfile):
        print(f"  SKIP {image_name} — {dockerfile} not found")
        continue

    print(f"  Building {image_tag}")
    print(f"    PLATFORM={platform}  CMAKE_PRESET={cmake_preset}")

    cmd = [
        "docker", "buildx", "build",
        "--push",
        "--build-arg", f"PLATFORM={platform}",
        "--build-arg", f"CMAKE_PRESET={cmake_preset}",
        "-f", dockerfile,
        "-t", image_tag,
        ".",   # repo root as context
    ]
    result = subprocess.run(cmd)
    if result.returncode == 0:
        pushed.append(image_tag)
        print(f"  Pushed: {image_tag}")
    else:
        failed.append(image_tag)
        print(f"  FAILED: {image_tag}")

print("")
print("=" * 60)
print(f"Pushed {len(pushed)}, failed {len(failed)}")
if failed:
    print("Failed images:")
    for img in failed:
        print(f"  ✗ {img}")
    sys.exit(1)
PYEOF

echo ""

# ── Step 4: Regenerate k8s manifest and deploy ───────────────────────────────
if [[ "${SKIP_K8S:-0}" == "1" ]]; then
    echo "SKIP_K8S=1 — skipping Kubernetes deployment."
    exit 0
fi

echo "=== Regenerating k8s manifest ==="
python3 scripts/generate_k8s.py
echo "k8s/manifest.yaml updated."

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "Kubernetes cluster not reachable. Manifest is ready at k8s/manifest.yaml"
    echo "When connected, run: kubectl apply -f k8s/manifest.yaml"
    exit 0
fi

echo "=== Deploying to Kubernetes ==="
kubectl apply --dry-run=server -f k8s/manifest.yaml
kubectl apply -f k8s/manifest.yaml
echo ""
echo "Deployment complete. Check status:"
echo "  kubectl get pods     -n embedded-os"
echo "  kubectl get services -n embedded-os"
