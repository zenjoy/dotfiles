#!/bin/sh

if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing Zenjoy Dotfiles for the first time"
    git clone https://github.com/zenjoy/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
    script/bootstrap
else
    echo "The Zenjoy Dotfiles are already installed"
fi