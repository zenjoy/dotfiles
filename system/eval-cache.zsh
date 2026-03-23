# Cache generated shell init scripts so startup can source a local file instead
# of spawning the generator command on every shell launch.

typeset -gA _EVAL_CACHE_COMMANDS

if [[ -z "${ZSH_EVAL_CACHE_DIR-}" ]]; then
  export ZSH_EVAL_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/eval-init"
fi

_eval_cache_file() {
  print -r -- "$ZSH_EVAL_CACHE_DIR/$1.zsh"
}

_eval_cache_meta_file() {
  print -r -- "$ZSH_EVAL_CACHE_DIR/$1.cmd"
}

_eval_cache_refresh() {
  emulate -L zsh

  local key="$1"
  local cmd="$2"
  local cache_file meta_file tmp_file tmp_meta_file

  cache_file="$(_eval_cache_file "$key")"
  meta_file="$(_eval_cache_meta_file "$key")"
  tmp_file="${cache_file}.tmp.$$"
  tmp_meta_file="${meta_file}.tmp.$$"

  mkdir -p "$ZSH_EVAL_CACHE_DIR" || return 1

  if eval "$cmd" >| "$tmp_file"; then
    print -r -- "$cmd" >| "$tmp_meta_file"
    mv -f "$tmp_file" "$cache_file"
    mv -f "$tmp_meta_file" "$meta_file"
    return 0
  fi

  rm -f "$tmp_file"
  rm -f "$tmp_meta_file"
  return 1
}

cache_eval_init() {
  local key="$1"
  local cmd="$2"
  local cache_file meta_file cached_cmd

  _EVAL_CACHE_COMMANDS["$key"]="$cmd"
  cache_file="$(_eval_cache_file "$key")"
  meta_file="$(_eval_cache_meta_file "$key")"
  cached_cmd=""

  if [[ ! -r "$cache_file" ]]; then
    if ! _eval_cache_refresh "$key" "$cmd"; then
      eval "$cmd"
      return $?
    fi
  elif [[ -r "$meta_file" ]]; then
    cached_cmd="$(<"$meta_file")"
    if [[ "$cached_cmd" != "$cmd" ]]; then
      if ! _eval_cache_refresh "$key" "$cmd"; then
        eval "$cmd"
        return $?
      fi
    fi
  else
    if ! _eval_cache_refresh "$key" "$cmd"; then
      eval "$cmd"
      return $?
    fi
  fi

  if ! source "$cache_file"; then
    rm -f "$cache_file"
    rm -f "$meta_file"
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
