#!/usr/bin/env bash

dotfiles_init_env() {
  : "${DOTFILES:=$HOME/.dotfiles}"
  : "${DOTFILES_DATA_DIR:=${XDG_DATA_HOME:-$HOME/.local/share}/zenjoy-dotfiles}"
  : "${DOTFILES_STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/zenjoy-dotfiles}"
  : "${DOTFILES_PLUGIN_DIR:=$DOTFILES_DATA_DIR/zsh/plugins}"
  : "${DOTFILES_DEPENDENCY_STATUS_FILE:=$DOTFILES_STATE_DIR/dependency-status.sh}"
  : "${DOTFILES_DEPENDENCY_REMINDER_FILE:=$DOTFILES_STATE_DIR/dependency-reminder}"

  export DOTFILES
  export DOTFILES_DATA_DIR
  export DOTFILES_STATE_DIR
  export DOTFILES_PLUGIN_DIR
  export DOTFILES_DEPENDENCY_STATUS_FILE
  export DOTFILES_DEPENDENCY_REMINDER_FILE
}

dotfiles_write_dependency_status() {
  dotfiles_init_env

  mkdir -p "$DOTFILES_STATE_DIR"

  cat > "$DOTFILES_DEPENDENCY_STATUS_FILE" <<EOF
DOTFILES_MISSING_REQUIRED='${1:-}'
DOTFILES_MISSING_RECOMMENDED='${2:-}'
EOF
}
