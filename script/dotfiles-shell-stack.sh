#!/usr/bin/env bash

dotfiles_zsh_autocomplete_plugin_path() {
  local candidate

  if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    candidate="${HOMEBREW_PREFIX}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    [[ -r "$candidate" ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  fi

  if command -v brew >/dev/null 2>&1; then
    candidate="$(brew --prefix zsh-autocomplete 2>/dev/null)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    [[ -r "$candidate" ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  fi

  for candidate in \
    /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh \
    /usr/local/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
  do
    [[ -r "$candidate" ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
  done

  return 1
}

dotfiles_has_zsh_autocomplete() {
  local candidate

  candidate="$(dotfiles_zsh_autocomplete_plugin_path 2>/dev/null)" || return 1
  [[ -r "$candidate" ]]
}

dotfiles_shell_stack_manifest() {
  cat <<'EOF'
zsh-autosuggestions|required|plugin|zsh-users/zsh-autosuggestions|[[ -r "$DOTFILES_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
zsh-autocomplete|recommended|brew|zsh-autocomplete|dotfiles_has_zsh_autocomplete|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
fzf|recommended|brew|fzf|command -v fzf >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
direnv|recommended|brew|direnv|command -v direnv >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
mise|recommended|brew|mise|command -v mise >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
zoxide|recommended|brew|zoxide|command -v zoxide >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
atuin|recommended|brew|atuin|command -v atuin >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
starship|recommended|brew|starship|command -v starship >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
wtp|recommended|brew|satococoa/tap/wtp|command -v wtp >/dev/null 2>&1|Install Homebrew if needed, then run setup-dotfiles to install the curated shell stack.
EOF
}
