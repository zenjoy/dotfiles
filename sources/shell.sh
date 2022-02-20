#!/usr/bin/env sh

# scripts in here are especially unnecessary for commands, and are often slow
# they are generally only useful for user interactive environments
# if a command does need one of these, then the command can source it directly

# export the active shell as the active login shell
export ACTIVE_LOGIN_SHELL
ACTIVE_LOGIN_SHELL="$(get_active_shell)"

# additional extras for an interactive shell
. "$DOTFILES/sources/config.sh"
if test "$ACTIVE_LOGIN_SHELL" = 'sh'; then
	load_dotfiles_config 'shell.sh'
else
	# load each filename
	# passes if one or more were loaded
	# fails if none were loaded (all were missing)
	load_dotfiles_config "shell.$ACTIVE_LOGIN_SHELL" 'shell.sh'
fi

# dorothy theme override, which is used for trial mode
if test -n "${DOTFILES_THEME_OVERRIDE-}"; then
	# shellcheck disable=SC2034
	DOTFILES_THEME="$DOTFILES_THEME_OVERRIDE"
fi

# continue with the shell extras
. "$DOTFILES/sources/nvm.sh"
. "$DOTFILES/sources/edit.sh"
. "$DOTFILES/sources/history.sh"
. "$DOTFILES/sources/ssh.sh"
