# Lazy SDKMAN loader for the small set of sessions that need it.
load_sdkman() {
  if (( ${+functions[sdk]} )); then
    return 0
  fi

  export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

  local init_script="$SDKMAN_DIR/bin/sdkman-init.sh"
  if [[ ! -s "$init_script" ]]; then
    print -u2 -- "SDKMAN init script not found at $init_script"
    return 1
  fi

  source "$init_script"
}
