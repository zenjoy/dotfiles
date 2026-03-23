#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REAL_HOME="${HOME}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" == *"$needle"* ]] || fail "expected to find '$needle' in output: $haystack"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" != *"$needle"* ]] || fail "did not expect to find '$needle' in output: $haystack"
}

setup_temp_home() {
  TEST_TMPDIR="$(mktemp -d)"
  export TEST_TMPDIR
  export HOME="$TEST_TMPDIR/home"
  mkdir -p "$HOME"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_CONFIG_HOME="$HOME/.config"
  export DOTFILES="$ROOT"
  export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
  export DISABLE_AUTO_UPDATE="true"
  unset HOMEBREW_PREFIX
  unset DOTFILES_DATA_DIR
  unset DOTFILES_STATE_DIR
  unset DOTFILES_PLUGIN_DIR
  unset DOTFILES_DEPENDENCY_STATUS_FILE
  unset DOTFILES_DEPENDENCY_REMINDER_FILE
  ln -s "$ROOT" "$HOME/.dotfiles"
}

cleanup_temp_home() {
  if [[ -n "${TEST_TMPDIR:-}" && -d "${TEST_TMPDIR:-}" ]]; then
    rm -rf "$TEST_TMPDIR"
  fi
}

run_doctor_and_capture_status() {
  local output

  output="$("$ROOT/bin/dotfiles-doctor" 2>&1)"
  echo "$output"
}

test_doctor_writes_status_file() {
  setup_temp_home
  trap cleanup_temp_home RETURN

  local output status_file
  output="$(run_doctor_and_capture_status)"
  status_file="$XDG_STATE_HOME/zenjoy-dotfiles/dependency-status.sh"

  [[ -f "$status_file" ]] || fail "expected dependency status file to be written"
  assert_contains "$output" "Missing required dependencies:"
  assert_contains "$output" "zsh-autosuggestions"
  assert_contains "$output" "setup-dotfiles"
  assert_contains "$output" "Missing recommended dependencies:"
  assert_contains "$output" "direnv"
}

test_only_active_plugin_is_managed() {
  local output

  output="$(sed -n '/dotfiles_shell_stack_manifest()/,/^}/p' "$ROOT/script/dotfiles-shell-stack.sh")"

  assert_contains "$output" "zsh-users/zsh-autosuggestions"
  assert_contains "$output" "marlonrichert/zsh-autocomplete"
  assert_not_contains "$output" "zsh-autocomplete|recommended|brew|zsh-autocomplete"
  assert_not_contains "$output" "zshmarks"
  assert_not_contains "$output" "fast-syntax-highlighting"
}

test_zsh_autocomplete_uses_managed_plugin_path_only() {
  setup_temp_home
  trap cleanup_temp_home RETURN

  local plugin_dir
  plugin_dir="$XDG_DATA_HOME/zenjoy-dotfiles/zsh/plugins"

  mkdir -p "$plugin_dir/zsh-autocomplete"
  touch "$plugin_dir/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

  local output
  output="$(ZDOTDIR="$HOME" zsh -fc '
    set -e
    export DOTFILES="'"$ROOT"'"
    source "$DOTFILES/script/dotfiles-env.sh"
    source "$DOTFILES/script/dotfiles-shell-stack.sh"
    dotfiles_init_env
    dotfiles_zsh_autocomplete_plugin_path
  ' 2>&1)"

  assert_contains "$output" "$plugin_dir/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
  assert_not_contains "$output" "/opt/homebrew/share/zsh-autocomplete"
}

test_hyper_setup_is_removed() {
  local output

  output="$(cd "$ROOT" && grep -REn "setup-hyper|Hyper Terminal|hyper\\.js\\.symlink" script/setup-dev bin script system 2>/dev/null || true)"

  [[ -z "$output" ]] || fail "expected Hyper setup references to be removed: $output"
}

test_eval_cache_refreshes_when_command_changes() {
  setup_temp_home
  trap cleanup_temp_home RETURN

  local output
  output="$(ZDOTDIR="$HOME" zsh -fc '
    set -e
    export DOTFILES="'"$ROOT"'"
    export ZSH_EVAL_CACHE_DIR="'"$HOME/.cache/test-eval-cache"'"
    mkdir -p "$ZSH_EVAL_CACHE_DIR"
    print "echo old" > "$ZSH_EVAL_CACHE_DIR/demo.zsh"
    source "$DOTFILES/system/eval-cache.zsh"
    cache_eval_init demo "printf '\''echo new\\n'\''"
    cat "$ZSH_EVAL_CACHE_DIR/demo.zsh"
  ' 2>&1)"

  assert_contains "$output" "new"
  assert_not_contains "$output" "old"
}

test_zsh_startup_uses_ignore_list_and_skips_missing_init_commands() {
  setup_temp_home
  trap cleanup_temp_home RETURN

  mkdir -p "$XDG_STATE_HOME/zenjoy-dotfiles"
  cat > "$XDG_STATE_HOME/zenjoy-dotfiles/dependency-status.sh" <<'EOF'
DOTFILES_MISSING_REQUIRED=""
DOTFILES_MISSING_RECOMMENDED="direnv mise"
EOF

  cat > "$HOME/.localrc" <<'EOF'
export DOTFILES_IGNORE_DEPS="direnv"
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
EOF

  cat > "$HOME/.zshrc" <<EOF
source "$ROOT/zsh/zshrc.symlink"
EOF

  local output
  output="$(script -q /dev/null zsh -i -c exit 2>&1 || true)"

  assert_contains "$output" "mise"
  assert_not_contains "$output" "direnv"
  assert_not_contains "$output" "command not found: starship"
  assert_not_contains "$output" "command not found: wtp"
}

test_zsh_tab_prefers_autosuggestion_accept_before_autocomplete_cycle() {
  setup_temp_home
  trap cleanup_temp_home RETURN

  mkdir -p "$XDG_DATA_HOME/zenjoy-dotfiles/zsh/plugins"
  ln -s "$REAL_HOME/.local/share/zenjoy-dotfiles/zsh/plugins/zsh-autosuggestions" \
    "$XDG_DATA_HOME/zenjoy-dotfiles/zsh/plugins/zsh-autosuggestions"
  ln -s "$REAL_HOME/.local/share/zenjoy-dotfiles/zsh/plugins/zsh-autocomplete" \
    "$XDG_DATA_HOME/zenjoy-dotfiles/zsh/plugins/zsh-autocomplete"

  cat > "$HOME/.zshrc" <<EOF
source "$ROOT/zsh/zshrc.symlink"
EOF

  local output
  output="$(ZDOTDIR="$HOME" zsh -ic '
    bindkey "^I"
    bindkey "$terminfo[kcbt]"
    zle -la | grep -x dotfiles-tab-accept-autosuggestion-or-menu-complete
  ' 2>&1)"

  assert_contains "$output" "\"^I\" dotfiles-tab-accept-autosuggestion-or-menu-complete"
  assert_contains "$output" "\"^[[Z\" reverse-menu-complete"
  assert_contains "$output" "dotfiles-tab-accept-autosuggestion-or-menu-complete"
}

test_doctor_writes_status_file
test_only_active_plugin_is_managed
test_zsh_autocomplete_uses_managed_plugin_path_only
test_hyper_setup_is_removed
test_eval_cache_refreshes_when_command_changes
test_zsh_startup_uses_ignore_list_and_skips_missing_init_commands
test_zsh_tab_prefers_autosuggestion_accept_before_autocomplete_cycle

echo "PASS: dotfiles dependency audit"
