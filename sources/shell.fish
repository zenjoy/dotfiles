#!/usr/bin/env fish

# export the active shell as the active login shell
set --export ACTIVE_LOGIN_SHELL fish

# additional extras for an interactive shell
source "$DOTFILES/sources/config.fish"
# load each filename
# passes if one or more were loaded
# fails if none were loaded (all were missing)
load_dotfiles_config 'shell.fish' 'shell.sh'
source "$DOTFILES/sources/edit.fish"
source "$DOTFILES/sources/history.fish"
source "$DOTFILES/sources/theme.fish"
source "$DOTFILES/sources/ssh.fish"
