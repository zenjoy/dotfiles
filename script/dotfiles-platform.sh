#!/usr/bin/env bash
# Platform detection helpers shared by setup scripts and dotfiles-doctor.
# Sourceable from bash and zsh; no side effects.

is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

# True on WSL1 and WSL2 (both put "microsoft" in /proc/version).
is_wsl() {
  [ -r /proc/version ] && grep -qi microsoft /proc/version
}

# Prints "apt" or "pacman" based on /etc/os-release; exit 1 when unsupported.
# DOTFILES_OS_RELEASE overrides the file path (for tests).
linux_pkg_manager() {
  local os_release ids
  os_release="${DOTFILES_OS_RELEASE:-/etc/os-release}"
  [ -r "$os_release" ] || return 1
  # shellcheck disable=SC1090
  ids="$(. "$os_release" 2>/dev/null; printf '%s %s' "${ID:-}" "${ID_LIKE:-}")"
  case " $ids " in
    *" debian "* | *" ubuntu "*) echo "apt" ;;
    *" arch "* | *" archlinux "*) echo "pacman" ;;
    *) return 1 ;;
  esac
}

# Prints the first Homebrew prefix that has an executable bin/brew.
dotfiles_detect_brew_prefix() {
  local prefix
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
    if [ -x "$prefix/bin/brew" ]; then
      echo "$prefix"
      return 0
    fi
  done
  return 1
}
