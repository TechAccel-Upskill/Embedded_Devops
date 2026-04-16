# ============================================================================
# Dockerfile.builder — Shared Embedded Build Toolchain Image
#
# SUMMARY:
#   A single "builder base" image that installs ALL build tools once.
#   App Dockerfiles (Dockerfile.gcc, .freertos, .zephyr) inherit FROM this
#   image so tools are never reinstalled per-build — only this image is
#   rebuilt when tooling changes (triggered by path filter in CI).
#
# TOOLS INSTALLED:
#   - GCC / G++        (C/C++ compiler)
#   - CMake            (meta build system)
#   - Make             (classic build tool)
#   - Bazel (Bazelisk) (Google build system — downloaded as /usr/local/bin/bazel)
#
# USAGE:
#   Build & push (done by CI, once):
#     docker build -f docker/Dockerfile.builder -t ghcr.io/ORG/embedded-builder:latest .
#     docker push ghcr.io/ORG/embedded-builder:latest
#
#   Then app Dockerfiles reference:
#     FROM ghcr.io/ORG/embedded-builder:latest AS builder
# ============================================================================
FROM debian:bookworm-slim

ARG BAZELISK_VERSION=v1.20.0
ARG TARGETARCH=amd64

# Install all build toolchain dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    cmake \
    make \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Bazel via Bazelisk (the official Bazel launcher/version manager)
RUN curl -fsSL \
    "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-${TARGETARCH}" \
    -o /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel

# Verify all tools are present
RUN gcc --version && g++ --version && cmake --version && make --version && bazel version

WORKDIR /app
