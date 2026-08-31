alias reload!='. ~/.zshrc'
alias dotfiles="cd ~/.dotfiles"

if [[ "$OSTYPE" == darwin* ]]; then
  chrome-agent() {
    local profile_dir="$HOME/.agents/chrome/agent-profile"

    mkdir -p "$profile_dir"
    open -na "Google Chrome" --args \
      --remote-debugging-port=9222 \
      --user-data-dir="$profile_dir" \
      "$@"
  }

  if ! command -v tailscale >/dev/null 2>&1; then
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  fi
fi
