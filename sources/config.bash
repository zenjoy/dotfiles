#!/usr/bin/env sh
source "$DOTFILES/sources/config.sh"

# todo
# if test \"\$(get-hostname)\" = '$(get-hostname)'; then

# for scripts to prune custom installers from packages
# USAGE:
# ``` bash
# mapfile -t GEM_INSTALL < <(prepare_packages 'GEM_INSTALL' -- "${GEM_INSTALL[@]}" "${RUBY_INSTALL[@]}")
# ````
prepare_packages() {
	local reconfigure='no' name="$1" packages=("${@:3}")

	# SETUP_UTILS should have already been loaded, but let's create it if not
	# we need to do it this way, otherwise we would wipe pre-existing custom configuration
	if test -z "${SETUP_UTILS-}"; then
		SETUP_UTILS=()
	fi

	# remove packages with dedicated installers
	for item in "${packages[@]}"; do
		installer="$(get-installer "$item" || :)"
		if test -n "$installer"; then
			if [[ "$installer" = 'setup-util-'* ]]; then
				util="${installer:11}"
				echo-style --notice="Moved [$item] from [$name] to [SETUP_UTILS] as [$util]." >/dev/tty
				SETUP_UTILS+=("$util")
				reconfigure='yes'
			else
				echo-style --notice="Skipping [$item] from [$name], as it should be installed via [$installer]." >/dev/tty
			fi
			continue
		else
			echo "$item"
		fi
	done

	# update configuration if necessary
	if test "$reconfigure" = 'yes'; then
		update_dotfiles_user_config 'setup.bash' -- \
			--field='SETUP_UTILS' --array="$(echo-lines -- "${SETUP_UTILS[@]}" | sort --ignore-case | uniq)"
	fi
}

# for scripts to update the correct configuration file
update_dotfiles_user_config_help() {
	cat <<-EOF >/dev/stderr
		USAGE:
		update_dotfiles_user_config [--flags]... <filename> -- [arguments for \`config-helper\`]...

		OPTIONS:
		<filename>                       The filename of the configuratio file to find or create, then update.

		[--prefer=local]                 If we need to create a file, make it inside user/config.local/
		[--no-prefer] / [--prefer=]      DEFAULT: If we need to create a file, make it inside user/config/

		[--template=default]             DEFAULT: If we have to create a file, copy the default config.
		[--no-template] / [--template=]  If we have to create a file, only copy the headers from the default config.

		[--source=default]               DEFAULT: If we have to create a file, copy the default config.
		[--no-source] / [--source=]      If we have to create a file, only copy the headers from the default config.

		All arguments after -- are passed to \`config-helper\`.

		QUIRKS:
		If there are multiple config files, prompt the user which one to use.
	EOF
	if test "$#" -ne 0; then
		echo-style $'\n' --error="ERROR:" $'\n' --red="$(echo-lines -- "$@")" >/dev/stderr
	fi
	return 22 # Invalid argument
}
update_dotfiles_user_config() {
	local item
	local dotfiles_config_filename=''
	local config_helper_args=()
	local dotfiles_config_prefer=''
	local dotfiles_config_template='default'
	local dotfiles_config_source='default'
	while test "$#" -ne 0; do
		item="$1"
		shift
		case "$item" in
		'help' | '--help' | '-h') update_dotfiles_user_config_help ;;
		'--file='*) dotfiles_config_filename="${item:7}" ;;
		'--prefer=local') dotfiles_config_prefer='local' ;;
		'--no-prefer' | '--prefer=') dotfiles_config_prefer='' ;;
		'--template=default') dotfiles_config_template='default' ;;
		'--no-template' | '--template=') dotfiles_config_template='' ;;
		'--source=default') dotfiles_config_source='default' ;;
		'--no-source' | '--source=') dotfiles_config_source='' ;;
		'--')
			config_helper_args+=("$@")
			shift $#
			break
			;;
		'--'*) help "An unrecognised flag was provided: $item" ;;
		*)
			if test -z "$dotfiles_config_filename"; then
				dotfiles_config_filename="$item"
			else
				update_dotfiles_user_config_help "An unrecognised argument was provided: $item"
			fi
			;;
		esac
	done

	# check extension
	local dotfiles_config_extension # this is used later too
	dotfiles_config_extension="$(fs-extension "$dotfiles_config_filename")"
	if ! [[ "$dotfiles_config_extension" =~ bash|zsh|sh|fish ]]; then
		help "The file extension of [$dotfiles_config_filename] is not yet supported."
	fi

	# check for existing
	local dotfiles_config_filepaths=()
	if test -f "$DOTFILES/user/config.local/$dotfiles_config_filename"; then
		dotfiles_config_filepaths+=("$DOTFILES/user/config.local/$dotfiles_config_filename")
	fi
	if test -f "$DOTFILES/user/config/$dotfiles_config_filename"; then
		dotfiles_config_filepaths+=("$DOTFILES/user/config/$dotfiles_config_filename")
	fi

	# no user config exists, we got to make it
	local dotfiles_config_filepath
	if test "${#dotfiles_config_filepaths[@]}" -eq 0; then
		# what location do we prefer?
		if test "$dotfiles_config_prefer" = 'local'; then
			dotfiles_config_filepath="$DOTFILES/user/config.local/$dotfiles_config_filename"
		else
			dotfiles_config_filepath="$DOTFILES/user/config/$dotfiles_config_filename"
		fi

		# are we okay with using a template, if so, does a default config file exist?
		local dotfiles_config_default="$DOTFILES/config/$dotfiles_config_filename"
		if test -f "$dotfiles_config_default"; then
			if test "$dotfiles_config_template" = 'default'; then
				#  copy the entire template
				cp "$dotfiles_config_default" "$dotfiles_config_filepath"
			else
				# copy only the header
				echo-before-blank --append=$'\n' "$dotfiles_config_default" >"$dotfiles_config_filepath"
			fi
		else
			# default missing, make it with the typical header
			cat <<-EOF >"$dotfiles_config_filepath"
				#!/usr/bin/env $dotfiles_config_extension
				# shellcheck disable=SC2034
				# do not use \`export\` keyword in this file

			EOF
		fi

		# add the source of the default file
		if test "$dotfiles_config_source" = 'default'; then
			# use `.` over `source` as must be posix, in case we are saving a .sh file
			cat <<-EOF >>"$dotfiles_config_filepath"
				# Load the default configuration file
				. "\$DOTFILES/config/${dotfiles_config_filename}"

			EOF
		fi

		# add the new file to the paths
		dotfiles_config_filepaths+=("$dotfiles_config_filepath")
	fi

	# prompt the user which file to use
	dotfiles_config_filepath="$(
		choose-option --required \
			--question="The [$dotfiles_config_filename] configuration file is pending updates, which one do you wish to update?" \
			-- "${dotfiles_config_filepaths[@]}"
	)"

	# now that the file exists, update it if we have values to update it
	if test "${#config_helper_args[@]}" -ne 0; then
		config-helper --file="$dotfiles_config_filepath" \
			-- "${config_helper_args[@]}"
	fi
}
