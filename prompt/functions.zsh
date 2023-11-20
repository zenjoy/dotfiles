function show-kubecontext () {
  if [[ "$TERM_PROGRAM" = "WarpTerminal" ]]; then
    if (( ${+POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND} )); then
      unset POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND
    else
      POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent|kubecolor|cmctl|sparkctl'
    fi
    p10k reload
    if zle; then
      zle push-input
      zle accept-line
      zle -N kube-toggle
      bindkey '^]' kube-toggle 
    fi
  else
    export PURE_PROMPT_KUBECONTEXT_SHOW=true
  fi
}

function hide-kubecontext () {
  export PURE_PROMPT_KUBECONTEXT_SHOW=false
}

function show-terraform-workspace () {
  export PURE_PROMPT_TERRAFORM_SHOW=true
}

function hide-terraform-workspace () {
  export PURE_PROMPT_TERRAFORM_SHOW=false
}

function show-ruby-version () {
  export PURE_PROMPT_RUBY_SHOW=true
}

function hide-ruby-version () {
  export PURE_PROMPT_RUBY_SHOW=false
}

function show-node-version () {
  export PURE_PROMPT_NODE_SHOW=true
}

function hide-node-version () {
  export PURE_PROMPT_NODE_SHOW=false
}

function show-go-version () {
  export PURE_PROMPT_GOLANG_SHOW=true
}

function hide-go-version () {
  export PURE_PROMPT_GOLANG_SHOW=false
}
