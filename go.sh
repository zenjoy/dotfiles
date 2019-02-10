#!/bin/sh

export DOTFILES=$HOME/.dotfiles

if [ ! -d $DOTFILES ]; then
  echo "Installing Zenjoy Dotfiles for the first time:"
  git clone https://github.com/zenjoy/dotfiles.git "$HOME/.dotfiles"
  cd $DOTFILES
else
  echo "The Zenjoy Dotfiles are already installed. Let's make sure it's up to date."
  cd $DOTFILES
  git pull --rebase --stat origin master
fi

$DOTFILES/script/bootstrap