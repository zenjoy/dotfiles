# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Store a secret in macOS Keychain
# Usage: keychain-set MY_API_KEY
function keychain-set() {
  if [[ -z "$1" ]]; then
    echo "Usage: keychain-set <KEY_NAME>"
    return 1
  fi
  security add-generic-password -U -a "$USER" -s "$1" -w
}

# Load a secret from macOS Keychain into an env variable
# Usage: keychain-get MY_API_KEY
function keychain-get() {
  if [[ -z "$1" ]]; then
    echo "Usage: keychain-get <KEY_NAME>"
    return 1
  fi
  export "$1"="$(security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null)"
}
