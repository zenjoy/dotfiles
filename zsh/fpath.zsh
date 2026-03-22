typeset -U fpath

fpath=(
  $DOTFILES/functions
  $fpath
)

if [[ -n "${HOMEBREW_PREFIX-}" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=(
    "$HOMEBREW_PREFIX/share/zsh/site-functions"
    $fpath
  )
fi
