#!/usr/bin/env bash
# Build-run the Linux bootstrap verification images.
# Usage: tests/docker/run.sh [ubuntu|arch|all]
#
# Builds run on the host's native architecture by design.
#
# Do not "fix" this by forcing --platform=linux/amd64 on Apple Silicon: an
# emulated x86_64 container still sees the host's arm64 /proc/cpuinfo, so
# Homebrew aborts with "Homebrew's x86_64 support on Linux requires a CPU with
# SSSE3 support!". Homebrew supports Linux aarch64 natively, so the arm64 build
# is the one that works here. Set DOCKER_PLATFORM to override on other hosts.
#
# Expect a slow first run: formulae without an arm64_linux bottle build from
# source. Be patient rather than killing a build that is still making progress.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORM="${DOCKER_PLATFORM:-}"
target="${1:-all}"

# The official archlinux image is published for x86_64 only, so on an arm64 host
# fall back to Arch Linux ARM (ID=archarm, ID_LIKE=arch — same pacman code path).
# Override with ARCH_BASE_IMAGE.
arch_base_image() {
  if [[ -n "${ARCH_BASE_IMAGE:-}" ]]; then
    echo "$ARCH_BASE_IMAGE"
  elif [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]] && [[ -z "$PLATFORM" ]]; then
    echo "menci/archlinuxarm:base-devel"
  else
    echo "archlinux:latest"
  fi
}

build() {
  local flavor="$1"
  local -a build_args=()
  [[ -n "$PLATFORM" ]] && build_args+=(--platform="$PLATFORM")
  [[ "$flavor" == "arch" ]] && build_args+=(--build-arg "ARCH_BASE_IMAGE=$(arch_base_image)")
  echo "==> Verifying bootstrap on $flavor ${PLATFORM:+($PLATFORM)}"
  docker build --progress=plain "${build_args[@]}" \
    -f "$ROOT/tests/docker/Dockerfile.$flavor" \
    -t "dotfiles-test-$flavor" "$ROOT"
  echo "==> $flavor OK"
}

case "$target" in
  ubuntu | arch) build "$target" ;;
  all) build ubuntu; build arch ;;
  *) echo "Usage: $0 [ubuntu|arch|all]" >&2; exit 1 ;;
esac
