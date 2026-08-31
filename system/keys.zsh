if [[ "$OSTYPE" != darwin* ]]; then
  alias pubkey="cat ~/.ssh/id_rsa.pub"
  keychain-set() { echo "keychain-set is macOS-only (uses the macOS Keychain)" >&2; return 1 }
  keychain-get() { echo "keychain-get is macOS-only (uses the macOS Keychain)" >&2; return 1 }
  return
fi

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

# Store a secret in macOS Keychain
# Usage: keychain-set MY_API_KEY
function keychain-set() {
  if [[ -z "$1" ]]; then
    echo "Usage: keychain-set <KEY_NAME>"
    return 1
  fi

  local key_name="$1"
  if [[ "$key_name" != [[:alpha:]_]* || "$key_name" == *[^[:alnum:]_] ]]; then
    echo "keychain-set: KEY_NAME must contain only letters, digits, and underscores" >&2
    return 1
  fi

  if [[ -t 0 ]]; then
    security add-generic-password -U -a "$USER" -s "$key_name" -w
    return $?
  fi

  local secret encoded remainder
  IFS= read -r secret || :
  if [[ -z "$secret" ]]; then
    echo "keychain-set: piped input must contain one non-empty line" >&2
    return 1
  fi
  if IFS= read -r remainder; then
    echo "keychain-set: piped input must contain one line" >&2
    return 1
  fi

  encoded="$(printf '%s' "$secret" | xxd -p -c 0)" || {
    echo "keychain-set: failed to encode piped input" >&2
    return 1
  }
  if [[ -z "$encoded" ]]; then
    echo "keychain-set: failed to encode piped input" >&2
    return 1
  fi

  printf 'add-generic-password -U -a "%s" -s "%s" -X "%s"\n' \
    "$USER" "$key_name" "$encoded" | security -i
  local security_status=$?
  unset secret encoded remainder
  return $security_status
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
