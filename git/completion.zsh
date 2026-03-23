# Lazy-load Git's native zsh completion on first Git completion request.
# This keeps startup fast while still letting Git-config aliases such as
# `co=checkout` resolve to the right completion behavior.

if [[ $- != *i* ]]; then
  return
fi

if (( ! ${+functions[compdef]} )); then
  return
fi

typeset -gi _DOTFILES_GIT_COMPLETION_LOADED=0

lazy_load_git_completion() {
  (( _DOTFILES_GIT_COMPLETION_LOADED )) && return 0

  local completion_file
  local -a candidates

  candidates=(
    "${HOMEBREW_PREFIX:-}/share/zsh/site-functions/_git"
    "/opt/homebrew/share/zsh/site-functions/_git"
    "/usr/local/share/zsh/site-functions/_git"
  )

  for completion_file in "${candidates[@]}"; do
    [[ -r "$completion_file" ]] || continue

    _DOTFILES_GIT_COMPLETION_LOADED=1
    source "$completion_file" || {
      _DOTFILES_GIT_COMPLETION_LOADED=0
      return 1
    }
    return 0
  done

  return 1
}

_git_lazy() {
  if (( !_DOTFILES_GIT_COMPLETION_LOADED )); then
    lazy_load_git_completion
    return $?
  fi

  _git "$@"
}

compdef _git_lazy git
