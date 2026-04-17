#!/bin/bash
# deploy_local.sh — local Docker engine deployment helper
#
# Runs deploy_all.sh in local mode:
#   - docker buildx build --load (no GHCR push)
#   - local image names in generated k8s manifest
#
# Optional env vars:
#   SKIP_BUILDER=1   Skip rebuilding embedded-builder image
#   SKIP_K8S=1       Build images only, do not apply to Kubernetes

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DEPLOY_MODE=local ./deploy_all.sh "$@"
