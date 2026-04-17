#!/usr/bin/env python3
"""
scripts/generate_k8s.py — Generate k8s/manifest.yaml from variants.yaml

Reads variants.yaml and writes a complete Kubernetes manifest with:
  - Namespace, ResourceQuota, NetworkPolicy (static header)
  - Service + Deployment for each unique (app, arch) cmake variant

Usage:
    python3 scripts/generate_k8s.py
    # Writes: k8s/manifest.yaml

Re-run whenever variants.yaml changes to keep the manifest in sync.
"""

import os
import sys

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT   = os.path.dirname(SCRIPT_DIR)
VARIANTS_FILE = os.path.join(REPO_ROOT, "variants.yaml")
OUTPUT_FILE   = os.path.join(REPO_ROOT, "k8s", "manifest.yaml")

REGISTRY  = "ghcr.io/techaccel-upskill"
NAMESPACE = "embedded-os"

# Map arch identifier → Kubernetes node label (kubernetes.io/arch)
ARCH_TO_K8S_ARCH = {
    "x86_64":      "amd64",
    "arm-cortex-a":"arm",
    "aarch64":     "arm64",
    "riscv64":     "riscv64",
}

# Only watchdog_app has an HTTP endpoint — use httpGet probe for it
HTTP_APPS = {"watchdog_app"}


def parse_variants_yaml(path):
    """Minimal YAML parser for the fixed variants.yaml structure."""
    variants = []
    current = {}
    with open(path) as f:
        for line in f:
            stripped = line.strip()
            if stripped.startswith("#") or not stripped:
                continue
            if stripped.startswith("- app:"):
                if current:
                    variants.append(current)
                current = {"app": stripped.split(":", 1)[1].strip()}
            elif ":" in stripped and current:
                key, _, val = stripped.partition(":")
                current[key.strip()] = val.strip()
        if current:
            variants.append(current)
    return variants


def k8s_name(app, arch):
    """Convert app + arch to a DNS-safe k8s resource name."""
    return f"{app}-{arch}".replace("_", "-")


def image_name(app, arch):
    """GHCR image tag for this app+arch combination."""
    return f"{REGISTRY}/{k8s_name(app, arch)}:latest"


def generate_service(app, arch):
    """Only watchdog_app exposes HTTP — other apps are pure daemons."""
    if app not in HTTP_APPS:
        return ""
    name = k8s_name(app, arch)
    return f"""\
---
# Service — {name}
apiVersion: v1
kind: Service
metadata:
  name: {name}
  namespace: {NAMESPACE}
  labels:
    app: {app.replace('_', '-')}
    arch: {arch}
spec:
  type: ClusterIP
  selector:
    app: {app.replace('_', '-')}
    arch: {arch}
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      protocol: TCP
"""


def generate_deployment(app, arch, cmake_preset):
    name      = k8s_name(app, arch)
    app_label = app.replace("_", "-")
    image     = image_name(app, arch)
    k8s_arch  = ARCH_TO_K8S_ARCH.get(arch, arch)
    binary    = f"/app/{app}"

    if app in HTTP_APPS:
        liveness_probe = f"""\
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 2"""
    else:
        liveness_probe = f"""\
        livenessProbe:
          exec:
            command: ["sh", "-c", "test -f {binary}"]
          initialDelaySeconds: 10
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command: ["sh", "-c", "test -f {binary}"]
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 2"""

    return f"""\
---
# Deployment — {name}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {name}
  namespace: {NAMESPACE}
  labels:
    app: {app_label}
    arch: {arch}
    variant: {cmake_preset}
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: {app_label}
      arch: {arch}
  template:
    metadata:
      labels:
        app: {app_label}
        arch: {arch}
        variant: {cmake_preset}
{('      annotations:\n        prometheus.io/scrape: "true"\n        prometheus.io/port: "8080"\n') if app in HTTP_APPS else ''}    spec:
      terminationGracePeriodSeconds: 30
      nodeSelector:
        kubernetes.io/arch: {k8s_arch}
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      imagePullSecrets:
        - name: ghcr-pull-secret
      containers:
        - name: {name}
          image: {image}
          imagePullPolicy: Always
          env:
            - name: APP_NAME
              value: "{name}"
            - name: TARGET_ARCH
              value: "{arch}"
          resources:
            requests:
              memory: "32Mi"
              cpu: "50m"
            limits:
              memory: "128Mi"
              cpu: "250m"
{liveness_probe}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: false
            capabilities:
              drop: [ALL]
"""


STATIC_HEADER = f"""\
# ============================================================================
# k8s/manifest.yaml — GENERATED FILE
# Source: variants.yaml  |  Generator: scripts/generate_k8s.py
#
# DO NOT EDIT BY HAND. Re-generate with:
#   python3 scripts/generate_k8s.py
#
# Contains: Namespace, ResourceQuota, NetworkPolicy, and one Service +
# Deployment per unique (app, arch) cmake variant in variants.yaml.
#
# PREREQUISITE — create the GHCR pull secret once per cluster:
#   kubectl create secret docker-registry ghcr-pull-secret \\
#     --namespace {NAMESPACE} \\
#     --docker-server=ghcr.io \\
#     --docker-username=<github-username> \\
#     --docker-password=<github-pat-with-read:packages>
# ============================================================================

---
apiVersion: v1
kind: Namespace
metadata:
  name: {NAMESPACE}
  labels:
    name: {NAMESPACE}

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: embedded-os-quota
  namespace: {NAMESPACE}
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "2Gi"
    limits.cpu: "8"
    limits.memory: "4Gi"
    pods: "50"

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: embedded-os-network-policy
  namespace: {NAMESPACE}
spec:
  podSelector: {{}}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {{}}
  egress:
    - to:
        - podSelector: {{}}
    - to:
        - namespaceSelector: {{}}
      ports:
        - protocol: TCP
          port: 53
        - protocol: UDP
          port: 53
"""


def main():
    if not os.path.exists(VARIANTS_FILE):
        print(f"ERROR: {VARIANTS_FILE} not found", file=sys.stderr)
        sys.exit(1)

    variants = parse_variants_yaml(VARIANTS_FILE)

    # Collect unique (app, arch) combinations from cmake variants only
    # (cmake is used for Docker image builds; make/bazel are native-only)
    seen = set()
    cmake_variants = []
    for v in variants:
        if v.get("build_system") == "cmake":
            key = (v["app"], v["arch"])
            if key not in seen:
                seen.add(key)
                cmake_variants.append(v)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w") as out:
        out.write(STATIC_HEADER)
        for v in cmake_variants:
            app    = v["app"]
            arch   = v["arch"]
            preset = v.get("cmake_preset", "release-x86_64")
            out.write(generate_service(app, arch))
            out.write(generate_deployment(app, arch, preset))

    count = len(cmake_variants)
    print(f"Generated {OUTPUT_FILE}")
    print(f"  {count} deployments: " + ", ".join(
        f"{v['app']}/{v['arch']}" for v in cmake_variants))


if __name__ == "__main__":
    main()
