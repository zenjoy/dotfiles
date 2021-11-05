update-rbenv() {
  pushd $HOMEBREW_PREFIX/rbenv && git pull && pushd $HOMEBREW_PREFIX/rbenv/plugins/ruby-build && git pull && popd && popd
}
