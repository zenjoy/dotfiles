#!/bin/sh

#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

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
  echo 'See /tmp/dotfiles-bootstrap for more information.'
  exit 1
}

successfully() {
  ($* >> /tmp/dotfiles-bootstrap 2>&1) || (fail $message 2>&1)
}


info "Installing Homebrew, the best OS X package manager ..."
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

info "Putting Homebrew location earlier in PATH ..."
  successfully echo "
# recommended by brew doctor
export PATH='/usr/local/bin:$PATH'" >> ~/.zshenv
  successfully source ~/.zshenv

info "Updating brew..."
  successfully brew update

info "Installing grc coreutils spark..."
  successfully brew install grc coreutils spark

info "Installing GNU Compiler Collection and dependencies ..."
  successfully brew tap homebrew/dupes
  successfully brew install autoconf automake apple-gcc42

info "Installing system libraries recommended for Ruby ..."
  successfully brew install gdbm libffi libksba libyaml readline

info "Installing Redis, a good key-value database ..."
  successfully brew install redis

info "Installing ImageMagick, for cropping and re-sizing images ..."
  successfully brew install imagemagick

info "Installing QT, used by Capybara Webkit for headless Javascript integration testing ..."
  successfully brew install qt

info "Installing watch, used to execute a program periodically and show the output ..."
  successfully brew install watch

info "Installing mongodb, our beloved database ..."
  successfully brew install mongodb

info "Installing dnsmasq, so we can use beautiful .dev domains for web development ..."
  successfully brew install dnsmasq
  successfully ln -s $HOME/.dotfiles/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf