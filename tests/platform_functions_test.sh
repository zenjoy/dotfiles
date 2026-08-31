#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

assert_eq() {
  local expected="$1" actual="$2" label="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "ok - $label"
  else
    echo "FAIL - $label (expected '$expected', got '$actual')"
    failures=$((failures + 1))
  fi
}

. "$ROOT/script/dotfiles-platform.sh"

test_exactly_one_of_is_macos_is_linux() {
  local count=0
  is_macos && count=$((count + 1))
  is_linux && count=$((count + 1))
  assert_eq "1" "$count" "exactly one of is_macos/is_linux is true"
}

test_linux_pkg_manager_detects_ubuntu() {
  local f
  f="$(mktemp)"
  printf 'ID=ubuntu\nID_LIKE=debian\n' > "$f"
  assert_eq "apt" "$(DOTFILES_OS_RELEASE=$f linux_pkg_manager)" "ubuntu -> apt"
  rm -f "$f"
}

test_linux_pkg_manager_detects_debian_like() {
  local f
  f="$(mktemp)"
  printf 'ID=raspbian\nID_LIKE=debian\n' > "$f"
  assert_eq "apt" "$(DOTFILES_OS_RELEASE=$f linux_pkg_manager)" "debian-like -> apt"
  rm -f "$f"
}

test_linux_pkg_manager_detects_arch() {
  local f
  f="$(mktemp)"
  printf 'ID=arch\n' > "$f"
  assert_eq "pacman" "$(DOTFILES_OS_RELEASE=$f linux_pkg_manager)" "arch -> pacman"
  rm -f "$f"
}

test_linux_pkg_manager_detects_omarchy() {
  local f
  f="$(mktemp)"
  printf 'ID=omarchy\nID_LIKE=arch\n' > "$f"
  assert_eq "pacman" "$(DOTFILES_OS_RELEASE=$f linux_pkg_manager)" "omarchy (ID_LIKE=arch) -> pacman"
  rm -f "$f"
}

test_linux_pkg_manager_rejects_unknown() {
  local f rc
  f="$(mktemp)"
  printf 'ID=gentoo\n' > "$f"
  DOTFILES_OS_RELEASE=$f linux_pkg_manager >/dev/null 2>&1
  rc=$?
  assert_eq "1" "$rc" "unknown distro -> exit 1"
  rm -f "$f"
}

test_detect_brew_prefix_finds_something_or_fails_cleanly() {
  # On this dev Mac it must find /opt/homebrew or /usr/local.
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local p
    p="$(dotfiles_detect_brew_prefix)"
    assert_eq "0" "$?" "brew prefix detected on macOS"
    [[ -x "$p/bin/brew" ]] && echo "ok - detected prefix has bin/brew" || { echo "FAIL - $p/bin/brew not executable"; failures=$((failures + 1)); }
  fi
}

test_exactly_one_of_is_macos_is_linux
test_linux_pkg_manager_detects_ubuntu
test_linux_pkg_manager_detects_debian_like
test_linux_pkg_manager_detects_arch
test_linux_pkg_manager_detects_omarchy
test_linux_pkg_manager_rejects_unknown
test_detect_brew_prefix_finds_something_or_fails_cleanly

if (( failures > 0 )); then
  echo "$failures failure(s)"
  exit 1
fi
echo "all platform tests passed"
