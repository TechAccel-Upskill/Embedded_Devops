#!/bin/bash
# build_all.sh — Native cross-compilation builds driven by variants.yaml
#
# Reads variants.yaml and runs the appropriate build command for each variant:
#   cmake  → cmake --preset <cmake_preset>  &&  cmake --build --preset <cmake_preset>
#   make   → make PLATFORM=<platform> ARCH=<arch>
#   bazel  → bazel build //... --config=<bazel_config>
#
# Cross-compilers are installed automatically if missing.
# Run from the repository root.

set -e
cd "$(dirname "$0")"

# ── Prerequisites ─────────────────────────────────────────────────────────────
install_prerequisites() {
    echo "=== Installing prerequisites ==="
    sudo apt-get update -y -q

    for pkg in cmake make gcc g++ curl python3 python3-yaml; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            echo "  Installing $pkg..."
            sudo apt-get install -y -q "$pkg"
        fi
    done

    if ! command -v bazel &>/dev/null; then
        echo "  Installing Bazel (via Bazelisk)..."
        sudo curl -fsSL \
            "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64" \
            -o /usr/local/bin/bazel
        sudo chmod +x /usr/local/bin/bazel
    fi

    echo "=== Prerequisites ready ==="
    echo ""
}

install_prerequisites

# ── Build loop (driven by variants.yaml via Python) ───────────────────────────
python3 - << 'PYEOF'
import subprocess, sys, os

os.chdir(os.path.dirname(os.path.realpath('/workspaces/Embedded_Devops/build_all.sh')))

try:
    import yaml
except ImportError:
    print("ERROR: python3-yaml not installed. Run: sudo apt-get install python3-yaml")
    sys.exit(1)

with open("variants.yaml") as f:
    config = yaml.safe_load(f)

variants = config.get("variants", [])
passed, failed = [], []

for v in variants:
    app          = v["app"]
    arch         = v["arch"]
    platform     = v.get("platform", "native")
    build_system = v.get("build_system", "cmake")
    app_dir      = f"apps/{app}"
    label        = f"{app} [{arch}] via {build_system}"

    if not os.path.isdir(app_dir):
        print(f"  SKIP {label} — {app_dir} not found")
        continue

    print(f"\n── Building: {label}")

    try:
        if build_system == "cmake":
            preset = v["cmake_preset"]
            subprocess.run(["cmake", "--preset", preset], cwd=app_dir, check=True)
            subprocess.run(["cmake", "--build", "--preset", preset], cwd=app_dir, check=True)

        elif build_system == "make":
            make_arch = v.get("make_arch", arch)
            subprocess.run(
                ["make", f"PLATFORM={platform}", f"ARCH={make_arch}"],
                cwd=app_dir, check=True
            )

        elif build_system == "bazel":
            bazel_config = v.get("bazel_config", "x86_64")
            subprocess.run(
                ["bazel", "build", "//...", f"--config={bazel_config}"],
                cwd=app_dir, check=True
            )

        passed.append(label)

    except subprocess.CalledProcessError as e:
        print(f"  FAILED: {label} — {e}")
        failed.append(label)

print("\n" + "=" * 60)
print(f"Results: {len(passed)} passed, {len(failed)} failed")
if failed:
    print("FAILED builds:")
    for item in failed:
        print(f"  ✗ {item}")
    sys.exit(1)
else:
    print("All builds passed ✓")
PYEOF
