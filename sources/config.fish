#!/usr/bin/env fish

# for scripts and sources to load a configuration file
# <filename...>
function dotfiles_config
	set --local dotfiles_config_loaded 'no'

	# for each filename, load a single config file
	for filename in $argv
		if test -f "$DOTFILES/user/config.local/$filename"
			# load user/config.local/*
			source "$DOTFILES/user/config.local/$filename"
			set dotfiles_config_loaded 'yes'
		else if test -f "$DOTFILES/user/config/$filename"
			# otherwise load user/config/*
			source "$DOTFILES/user/config/$filename"
			set dotfiles_config_loaded 'yes'
		else if test -f "$DOTFILES/config/$filename"
			# otherwise load default configuration
			source "$DOTFILES/config/$filename"
			set dotfiles_config_loaded 'yes'
		end
		# otherwise try next filename
	end

	# if nothing was loaded, then fail
	if test "$dotfiles_config_loaded" = 'no'
		echo-style --error="Missing the configuration file: $argv" >/dev/stderr
		return 2  # No such file or directory
	end
end
