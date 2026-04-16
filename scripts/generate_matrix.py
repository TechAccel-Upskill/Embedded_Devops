#!/usr/bin/env python3
"""
scripts/generate_matrix.py — Generate GitHub Actions matrix JSON from variants.yaml

Reads variants.yaml and prints a JSON matrix that can be consumed by the
GitHub Actions strategy.matrix.include mechanism.

Usage:
    python3 scripts/generate_matrix.py
    # Prints JSON array to stdout

In CI (ci.yml):
    matrix=$(python3 scripts/generate_matrix.py)
    echo "matrix=$matrix" >> $GITHUB_OUTPUT
"""

import json
import os
import sys

SCRIPT_DIR    = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT     = os.path.dirname(SCRIPT_DIR)
VARIANTS_FILE = os.path.join(REPO_ROOT, "variants.yaml")
REGISTRY      = "ghcr.io/techaccel-upskill"


def parse_variants_yaml(path):
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
    return f"{app}-{arch}".replace("_", "-")


def main():
    if not os.path.exists(VARIANTS_FILE):
        print(f"ERROR: {VARIANTS_FILE} not found", file=sys.stderr)
        sys.exit(1)

    variants = parse_variants_yaml(VARIANTS_FILE)
    matrix = []

    # One Docker CI job per unique (app, arch) cmake variant
    seen = set()
    for v in variants:
        if v.get("build_system") != "cmake":
            continue
        key = (v["app"], v["arch"])
        if key in seen:
            continue
        seen.add(key)

        app    = v["app"]
        arch   = v["arch"]
        preset = v.get("cmake_preset", "release-x86_64")
        image  = f"{REGISTRY}/{k8s_name(app, arch)}"
        dockerfile = f"docker/Dockerfile.{app}"

        matrix.append({
            "app":        app,
            "arch":       arch,
            "platform":   v.get("platform", "native"),
            "cmake_preset": preset,
            "image":      image,
            "dockerfile": dockerfile,
        })

    print(json.dumps(matrix))


if __name__ == "__main__":
    main()
