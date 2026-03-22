# Cache generated shell init scripts so startup can source a local file instead
# of spawning the generator command on every shell launch.

typeset -gA _EVAL_CACHE_COMMANDS

if [[ -z "${ZSH_EVAL_CACHE_DIR-}" ]]; then
  export ZSH_EVAL_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/eval-init"
fi

_eval_cache_file() {
  print -r -- "$ZSH_EVAL_CACHE_DIR/$1.zsh"
}

_eval_cache_refresh() {
  emulate -L zsh

  local key="$1"
  local cmd="$2"
  local cache_file tmp_file

  cache_file="$(_eval_cache_file "$key")"
  tmp_file="${cache_file}.tmp.$$"

  mkdir -p "$ZSH_EVAL_CACHE_DIR" || return 1

  if eval "$cmd" >| "$tmp_file"; then
    mv -f "$tmp_file" "$cache_file"
    return 0
  fi

  rm -f "$tmp_file"
  return 1
}

cache_eval_init() {
  local key="$1"
  local cmd="$2"
  local cache_file

  _EVAL_CACHE_COMMANDS["$key"]="$cmd"
  cache_file="$(_eval_cache_file "$key")"

  if [[ ! -r "$cache_file" ]]; then
    if ! _eval_cache_refresh "$key" "$cmd"; then
      eval "$cmd"
      return $?
    fi
  fi

  if ! source "$cache_file"; then
    rm -f "$cache_file"
    if _eval_cache_refresh "$key" "$cmd"; then
      source "$cache_file"
    else
      eval "$cmd"
    fi
  fi
}

recache_eval_init() {
  emulate -L zsh

  local key
  local -a keys

  if (( $# == 0 )); then
    keys=( ${(k)_EVAL_CACHE_COMMANDS} )
  else
    keys=( "$@" )
  fi

  for key in "${keys[@]}"; do
    [[ -n "${_EVAL_CACHE_COMMANDS[$key]-}" ]] || continue
    _eval_cache_refresh "$key" "${_EVAL_CACHE_COMMANDS[$key]}" || return $?
  done
}
