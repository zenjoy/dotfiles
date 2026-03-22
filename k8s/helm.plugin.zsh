# Autocompletion for helm.
if command -v helm >/dev/null 2>&1; then
  # Only define lazy-load wrappers in interactive shells.
  if [[ $- == *i* ]]; then
    function lazy_load_helm() {
      local cache_dir="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
      mkdir -p "$cache_dir"
      __HELM_COMPLETION_FILE="$cache_dir/helm_completion"

      if [[ ! -f $__HELM_COMPLETION_FILE ]]; then
        command helm completion zsh >! $__HELM_COMPLETION_FILE
      fi

      [[ -f $__HELM_COMPLETION_FILE ]] && source $__HELM_COMPLETION_FILE 2>/dev/null
      compdef _helm helm 2>/dev/null

      unset __HELM_COMPLETION_FILE
      return 0
    }

    function helm() {
      if ! type _helm >/dev/null 2>&1; then
        lazy_load_helm
      fi

      command helm "$@"
    }

    function _helm_lazy() {
      if ! type _helm >/dev/null 2>&1; then
        lazy_load_helm
      fi
      _helm "$@"
    }
    compdef _helm_lazy helm
  fi
fi
