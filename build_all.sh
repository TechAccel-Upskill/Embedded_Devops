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

usage() {
    cat <<'EOF'
Usage: ./build_all.sh [--clean] [--force] [--help]

Options:
  --clean   Remove existing build outputs before building.
  --force   Force a rebuild even if outputs appear up to date.
  --help    Show this help text and exit.

Notes:
  - For CMake, --clean removes apps/<app>/build/<preset> before configure.
  - For CMake, --force adds --clean-first to the build step.
  - For Make, --clean runs make clean and --force runs make -B.
  - For Bazel, --clean runs bazel clean and --force also falls back to bazel clean
    because Bazel does not provide a direct make-style force rebuild flag.
EOF
}

CLEAN_BUILD=0
FORCE_BUILD=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)
            CLEAN_BUILD=1
            ;;
        --force)
            FORCE_BUILD=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

export CLEAN_BUILD FORCE_BUILD

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

    # Cross-compilers for all supported target platforms
    local cross_pkgs=(
        gcc-arm-linux-gnueabihf   g++-arm-linux-gnueabihf
        gcc-aarch64-linux-gnu     g++-aarch64-linux-gnu
        gcc-riscv64-linux-gnu     g++-riscv64-linux-gnu
    )
    local missing=()
    for pkg in "${cross_pkgs[@]}"; do
        dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "  Installing cross-compilers: ${missing[*]}"
        sudo apt-get install -y -q "${missing[@]}"
    fi

    echo "=== Prerequisites ready ==="
    echo ""
}

install_prerequisites

# ── Build loop (driven by variants.yaml via Python) ───────────────────────────
python3 - << 'PYEOF'
import os
import shutil
import subprocess
import sys

os.chdir(os.path.dirname(os.path.realpath('/workspaces/Embedded_Devops/build_all.sh')))

clean_build = os.environ.get("CLEAN_BUILD") == "1"
force_build = os.environ.get("FORCE_BUILD") == "1"

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
            build_dir = os.path.join(app_dir, "build", preset)

            if clean_build and os.path.isdir(build_dir):
                print(f"  Cleaning CMake build directory: {build_dir}")
                shutil.rmtree(build_dir)

            subprocess.run(["cmake", "--preset", preset], cwd=app_dir, check=True)

            build_cmd = ["cmake", "--build", "--preset", preset]
            if force_build:
                build_cmd.append("--clean-first")
            subprocess.run(build_cmd, cwd=app_dir, check=True)

        elif build_system == "make":
            make_arch = v.get("make_arch", arch)
            make_vars = [f"PLATFORM={platform}", f"ARCH={make_arch}"]

            if clean_build:
                subprocess.run(
                    ["make", *make_vars, "clean"],
                    cwd=app_dir, check=True
                )

            make_cmd = ["make"]
            if force_build:
                make_cmd.append("-B")
            make_cmd.extend(make_vars)
            subprocess.run(make_cmd, cwd=app_dir, check=True)

        elif build_system == "bazel":
            bazel_config = v.get("bazel_config", "x86_64")
            if clean_build or force_build:
                subprocess.run(["bazel", "clean"], cwd=app_dir, check=True)

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
