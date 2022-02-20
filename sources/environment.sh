#!/usr/bin/env sh

. "$DOTFILES/sources/get_active_shell.sh"
{
	eval "$("$DOTFILES/commands/setup-environment-commands" "$(get_active_shell)")"
} || {
	echo "Failed to setup environment, failed command was:"
	echo "$DOTFILES/commands/setup-environment-commands" "$(get_active_shell)"
	exit 1
} >/dev/stderr
