# Autocompletion for helm.
if command -v helm >/dev/null 2>&1; then
  function lazy_load_helm() {
    __HELM_COMPLETION_FILE="${ZSH_CACHE_DIR}/helm_completion"

    if [[ ! -f $__HELM_COMPLETION_FILE ]]; then
      helm completion zsh >! $__HELM_COMPLETION_FILE
    fi

    [[ -f $__HELM_COMPLETION_FILE ]] && source $__HELM_COMPLETION_FILE

    unset __helm_COMPLETION_FILE
  }

  function helm() {
    if ! type __start_helm >/dev/null 2>&1; then
      lazy_load_helm
    fi

    command helm "$@"
  }
fi