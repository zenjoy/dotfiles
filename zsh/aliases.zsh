alias reload!='. ~/.zshrc'
alias dotfiles="cd ~/.dotfiles"

if ! command -v tailscale >/dev/null 2>&1; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
