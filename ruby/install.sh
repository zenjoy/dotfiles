#!/bin/sh

set -e

echo ''

message=""

success () {
  printf "\r\033[2K [ \033[00;32mok\033[0m ] $1\n"
}

info () {
  if [[ -n $message ]]; then
    success $message
  fi
  printf " [ \033[00;34m..\033[0m ] $1"
  message=$1
}

user () {
  printf "\r\033[2K [ \033[00;33m?\033[0m ] $1"
}

fail () {
  printf "\r\033[2K [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  echo 'See /tmp/laptop-bootstrap for more information.'
  exit 1
}

successfully() {
  ($* >> /tmp/laptop-bootstrap 2>&1) || (fail $message 2>&1)
}

info "Installing rbenv for changing Ruby versions ..."
  successfully git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
  successfully chgrp -R staff /usr/local/rbenv
  successfully chmod -R g+rwxXs /usr/local/rbenv
  successfully echo 'export RBENV_ROOT=/usr/local/rbenv' >> ~/.zlogin
  successfully echo 'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' >> ~/.zlogin
  successfully echo 'eval "$(rbenv init -)"' >> ~/.zlogin
  successfully source ~/.zlogin

info "Installing ruby-build for installing Rubies ..."
  successfully mkdir /usr/local/rbenv/plugins
  successfully git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
  successfully chgrp -R staff /usr/local/rbenv/plugins/ruby-build
  successfully chmod -R g+rwxs /usr/local/rbenv/plugins/ruby-build

info "Installing rbenv-sudo for running Ruby as root ..."
  successfully git clone git://github.com/dcarley/rbenv-sudo.git /usr/local/rbenv/plugins/rbenv-sudo
  successfully chgrp -R staff /usr/local/rbenv/plugins/rbenv-sudo
  successfully chmod -R g+rwxs /usr/local/rbenv/plugins/rbenv-sudo

info "Installing rbenv-binstubs ..."
  successfully git clone git://github.com/ianheggie/rbenv-binstubs.git /usr/local/rbenv/plugins/rbenv-binstubs
  successfully chgrp -R staff /usr/local/rbenv/plugins/rbenv-binstubs
  successfully chmod -R g+rwxs /usr/local/rbenv/plugins/rbenv-binstubs

info "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
  successfully git clone https://github.com/sstephenson/rbenv-gem-rehash.git /usr/local/rbenv/plugins/rbenv-gem-rehash
  successfully chgrp -R staff /usr/local/rbenv/plugins/rbenv-gem-rehash
  successfully chmod -R g+rwxs /usr/local/rbenv/plugins/rbenv-gem-rehash

info "Installing Ruby 2.0.0-p247 ..."
  CC=gcc-4.2 successfully rbenv install 2.0.0-p247

info "Setting Ruby 1.9.3-p392 as global default Ruby ..."
  successfully rbenv global 2.0.0-p247
  successfully rbenv shell 2.0.0-p247

info "Update to latest Rubygems version ..."
  successfully gem update --system

info "Installing necessary Ruby gems for Rails & Web development ..."
  successfully gem install bundler foreman rails thin compass sass haml --no-document

info "Installing Ghost gem for easy hosts management ..."
  successfully gem install ghost --pre --no-document

info "Installing Nimbu CLI client ..."
  successfully gem install nimbu --no-document

info "Installing GitHub CLI client ..."
  successfully gem install hub --no-document

info "Installing Git-Smart gem ..."
  successfully gem install git-smart --no-document