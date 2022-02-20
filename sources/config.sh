#!/usr/bin/env sh

# for scripts and sources to load a configuration file
# load_dotfiles_config <filename>...
load_dotfiles_config() {
	dotfiles_config_loaded='no'

	# for each filename, load a single config file
	for dotfiles_config_filename in "$@"; do
		if test -f "$DOTFILES/user/config.local/$dotfiles_config_filename"; then
			# load user/config.local/*
			. "$DOTFILES/user/config.local/$dotfiles_config_filename"
			dotfiles_config_loaded='yes'
		elif test -f "$DOTFILES/user/config/$dotfiles_config_filename"; then
			# otherwise load user/config/*
			. "$DOTFILES/user/config/$dotfiles_config_filename"
			dotfiles_config_loaded='yes'
		elif test -f "$DOTFILES/config/$dotfiles_config_filename"; then
			# otherwise load default configuration
			. "$DOTFILES/config/$dotfiles_config_filename"
			dotfiles_config_loaded='yes'
		fi
	done

	# if nothing was loaded, then fail
	if test "$dotfiles_config_loaded" = 'no'; then
		echo-style --error="Missing the configuration file: $*" >/dev/stderr
		return 2 # No such file or directory
	fi
}
