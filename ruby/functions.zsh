update-rbenv() {
  pushd /usr/local/rbenv && git pull && pushd /usr/local/rbenv/plugins/ruby-build && git pull && popd && popd
}