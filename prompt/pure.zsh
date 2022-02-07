# Pure
# by Sindre Sorhus
# https://github.com/sindresorhus/pure
# MIT License

# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)
# terminal codes:
# \e7   => save cursor position
# \e[2A => move cursor 2 lines up
# \e[1G => go to position 1 in terminal
# \e8   => restore cursor position
# \e[K  => clears everything after the cursor on the current line
# \e[2K => clear everything on the current line

# for possible color codes, see https://jonasjacek.github.io/colors/

PURE_PROMPT_BATTERY_SYMBOL_CHARGING="${PURE_PROMPT_BATTERY_SYMBOL_CHARGING="⇡"}"
PURE_PROMPT_BATTERY_SYMBOL_DISCHARGING="${PURE_PROMPT_BATTERY_SYMBOL_DISCHARGING="⇣"}"
PURE_PROMPT_BATTERY_SYMBOL_FULL="${PURE_PROMPT_BATTERY_SYMBOL_FULL="•"}"
PURE_PROMPT_BATTERY_WARNING_THRESHOLD="${PURE_PROMPT_BATTERY_WARNING_THRESHOLD=20}"
PURE_PROMPT_BATTERY_THRESHOLD="${PURE_PROMPT_BATTERY_THRESHOLD=10}"

PURE_PROMPT_KUBECONTEXT_SHOW="${PURE_PROMPT_KUBECONTEXT_SHOW=true}"
PURE_PROMPT_KUBECONTEXT_SYMBOL="${PURE_PROMPT_KUBECONTEXT_SYMBOL="\ue7b2 "}"
PURE_PROMPT_KUBECONTEXT_COLOR="${PURE_PROMPT_KUBECONTEXT_COLOR="208"}"
PURE_PROMPT_KUBECONTEXT_NAMESPACE_SHOW="${PURE_PROMPT_KUBECONTEXT_NAMESPACE_SHOW=true}"
PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS=(${PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS=})

PURE_PROMPT_TERRAFORM_SHOW="${PURE_PROMPT_TERRAFORM_SHOW=true}"
PURE_PROMPT_TERRAFORM_SYMBOL="${PURE_PROMPT_TERRAFORM_SYMBOL="\uf9fd"}"
PURE_PROMPT_TERRAFORM_COLOR="${PURE_PROMPT_TERRAFORM_COLOR="105"}"

PURE_PROMPT_RUBY_SHOW="${PURE_PROMPT_RUBY_SHOW=true}"
PURE_PROMPT_RUBY_SYMBOL="${PURE_PROMPT_RUBY_SYMBOL="\ue21e "}"
PURE_PROMPT_RUBY_COLOR="${PURE_PROMPT_RUBY_COLOR="196"}"

PURE_PROMPT_NODE_SHOW="${PURE_PROMPT_NODE_SHOW=true}"
PURE_PROMPT_NODE_SYMBOL="${PURE_PROMPT_NODE_SYMBOL="\uf898 "}"
PURE_PROMPT_NODE_COLOR="${PURE_PROMPT_NODE_COLOR="green"}"

PURE_PROMPT_GOLANG_SHOW="${PURE_PROMPT_GOLANG_SHOW=true}"
PURE_PROMPT_GOLANG_SYMBOL="${PURE_PROMPT_GOLANG_SYMBOL="\ue627 "}"
PURE_PROMPT_GOLANG_COLOR="${PURE_PROMPT_GOLANG_COLOR="cyan"}"

PURE_PROMPT_DOCKERCOMPOSE_SHOW="${PURE_PROMPT_DOCKERCOMPOSE_SHOW=true}"
PURE_PROMPT_DOCKERCOMPOSE_SYMBOL="${PURE_PROMPT_DOCKERCOMPOSE_SYMBOL="\uf308  "}"
PURE_PROMPT_DOCKERCOMPOSE_UP_COLOR="${PURE_PROMPT_DOCKERCOMPOSE_UP_COLOR="green"}"
PURE_PROMPT_DOCKERCOMPOSE_DOWN_COLOR="${PURE_PROMPT_DOCKERCOMPOSE_DOWN_COLOR="red"}"
PURE_PROMPT_DOCKERCOMPOSE_COLOR="${PURE_PROMPT_DOCKERCOMPOSE_COLOR="32"}"

+vi-git-stash() {
	local -a stashes
	stashes=$(git stash list 2>/dev/null | wc -l)
	if [[ $stashes -gt 0 ]]; then
		hook_com[misc]="stash=${stashes}"
	fi
}

prompt_pure_exists() {
  command -v $1 > /dev/null 2>&1
}

prompt_pure_defined() {
  typeset -f + "$1" &> /dev/null
}

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
# https://github.com/sindresorhus/pretty-time-zsh
prompt_pure_human_time_to_var() {
	local human total_seconds=$1 var=$2
	local days=$(( total_seconds / 60 / 60 / 24 ))
	local hours=$(( total_seconds / 60 / 60 % 24 ))
	local minutes=$(( total_seconds / 60 % 60 ))
	local seconds=$(( total_seconds % 60 ))
	(( days > 0 )) && human+="${days}d "
	(( hours > 0 )) && human+="${hours}h "
	(( minutes > 0 )) && human+="${minutes}m "
	human+="${seconds}s"

	# store human readable time in variable as specified by caller
	typeset -g "${var}"="${human}"
}

# stores (into prompt_pure_cmd_exec_time) the exec time of the last command if set threshold was exceeded
prompt_pure_check_cmd_exec_time() {
	integer elapsed
	(( elapsed = EPOCHSECONDS - ${prompt_pure_cmd_timestamp:-$EPOCHSECONDS} ))
	typeset -g prompt_pure_cmd_exec_time=
	(( elapsed > ${PURE_CMD_MAX_EXEC_TIME:-5} )) && {
		prompt_pure_human_time_to_var $elapsed "prompt_pure_cmd_exec_time"
	}
}

prompt_pure_set_title() {
	setopt localoptions noshwordsplit

	# emacs terminal does not support settings the title
	(( ${+EMACS} || ${+INSIDE_EMACS} )) && return

	case $TTY in
		# Don't set title over serial console.
		/dev/ttyS[0-9]*) return;;
	esac

	# Show hostname if connected via ssh.
	local hostname=
	if [[ -n $prompt_pure_state[username] ]]; then
		# Expand in-place in case ignore-escape is used.
		hostname="${(%):-(%m) }"
	fi

	local -a opts
	case $1 in
		expand-prompt) opts=(-P);;
		ignore-escape) opts=(-r);;
	esac

	# Set title atomically in one print statement so that it works
	# when XTRACE is enabled.
	print -n $opts $'\e]0;'${hostname}${2}$'\a'
}

prompt_pure_preexec() {
	if [[ -n $prompt_pure_git_fetch_pattern ]]; then
		# detect when git is performing pull/fetch (including git aliases).
		local -H MATCH MBEGIN MEND match mbegin mend
		if [[ $2 =~ (git|hub)\ (.*\ )?($prompt_pure_git_fetch_pattern)(\ .*)?$ ]]; then
			# we must flush the async jobs to cancel our git fetch in order
			# to avoid conflicts with the user issued pull / fetch.
			async_flush_jobs 'prompt_pure'
		fi
	fi

	typeset -g prompt_pure_cmd_timestamp=$EPOCHSECONDS

	# shows the current dir and executed command in the title while a process is active
	prompt_pure_set_title 'ignore-escape' "$PWD:t: $2"

	# Disallow python virtualenv from updating the prompt, set it to 12 if
	# untouched by the user to indicate that Pure modified it. Here we use
	# magic number 12, same as in psvar.
	export VIRTUAL_ENV_DISABLE_PROMPT=${VIRTUAL_ENV_DISABLE_PROMPT:-12}
}

# Change the colors if their value are different from the current ones.
prompt_pure_set_colors() {
	local color_temp key value
	for key value in ${(kv)prompt_pure_colors}; do
		zstyle -t ":prompt:pure:$key" color "$value"
		case $? in
			1) # The current style is different from the one from zstyle.
				zstyle -s ":prompt:pure:$key" color color_temp
				prompt_pure_colors[$key]=$color_temp ;;
			2) # No style is defined.
				prompt_pure_colors[$key]=$prompt_pure_colors_default[$key] ;;
		esac
	done
}

prompt_pure_preprompt_render() {
	setopt localoptions noshwordsplit

	# Set color for git branch/dirty status, change color if dirty checking has
	# been delayed.
	local git_color=$prompt_pure_colors[git:branch]
	[[ -n ${prompt_pure_git_last_dirty_check_timestamp+x} ]] && git_color=$prompt_pure_colors[git:branch:cached]

	# Initialize the preprompt array.
	local -a preprompt_parts

	if [[ -n $prompt_pure_battery_info ]]; then
		preprompt_parts+=('${prompt_pure_battery_info}%f')
	fi

	# Username and machine, if applicable.
	[[ -n $prompt_pure_state[username] ]] && preprompt_parts+=($prompt_pure_state[username])

	# Execution time.
	if [[ -n $prompt_pure_current_time ]]; then
		if [ ${#preprompt_parts[@]} -eq 0  ]; then
			preprompt_parts+=('%F{yellow}${prompt_pure_current_time}%f')
		else
			preprompt_parts+=('at %F{yellow}${prompt_pure_current_time}%f')
		fi
	fi

	typeset -gA prompt_pure_vcs_info
	local trunc_prefix

	# Set the path.
	if [[ -n $prompt_pure_vcs_info[top] ]]; then
		local git_root=$prompt_pure_vcs_info[top]

		# Check if the parent of the $git_root is "/"
    if [[ $git_root:h == / ]]; then
      trunc_prefix=/
    else
      trunc_prefix=$PURE_PROMPT_DIR_TRUNC_PREFIX
    fi

		prompt_pure_dir="$trunc_prefix$git_root:t${${PWD:A}#$~~git_root}"
	else
		trunc_prefix="%($((PURE_PROMPT_DIR_TRUNC + 1))~|$PURE_PROMPT_DIR_TRUNC_PREFIX|)"
		prompt_pure_dir="$trunc_prefix%${PURE_PROMPT_DIR_TRUNC}~"
	fi
	preprompt_parts+=('in %F{${prompt_pure_colors[path]}}${prompt_pure_dir}%f')

	# Add git branch and dirty status info.
	if [[ -n $prompt_pure_vcs_info[branch] ]]; then
		preprompt_parts+=("%F{$git_color}"'${prompt_pure_vcs_info[branch]}${prompt_pure_git_dirty}%f')
	fi
	# Git pull/push arrows.
	if [[ -n $prompt_pure_git_arrows ]]; then
		preprompt_parts+=('%F{$prompt_pure_colors[git:arrow]}${prompt_pure_git_arrows}%f')
	fi

	# Git stash symbol.
	if [[ -n $prompt_pure_vcs_info[stash] ]]; then
		preprompt_parts+=('%F{$prompt_pure_colors[git:stash]}${PURE_GIT_STASH_SYMBOL:-≡}%f')
	fi

	# Git stash symbol.
	local -a other_preprompt_info
	if [[ -n $prompt_pure_other_info[kubectl] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[kubectl]}')
	fi
	if [[ -n $prompt_pure_other_info[terraform] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[terraform]}')
	fi
	if [[ -n $prompt_pure_other_info[ruby] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[ruby]}')
	fi
	if [[ -n $prompt_pure_other_info[node] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[node]}')
	fi
	if [[ -n $prompt_pure_other_info[golang] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[golang]}')
	fi
	if [[ -n $prompt_pure_other_info[dco] ]]; then
		other_preprompt_info+=('${prompt_pure_other_info[dco]}')
	fi

	if [ ${#other_preprompt_info[@]} -ne 0  ]; then
		preprompt_parts+="${(j.%F{242\} ⁞ %f.)other_preprompt_info}"
	fi

	# Execution time.
	[[ -n $prompt_pure_cmd_exec_time ]] && preprompt_parts+=('%F{yellow}${prompt_pure_cmd_exec_time}%f')

	local cleaned_ps1=$PROMPT
	local -H MATCH MBEGIN MEND
	if [[ $PROMPT = *$prompt_newline* ]]; then
		# Remove everything from the prompt until the newline. This
		# removes the preprompt and only the original PROMPT remains.
		cleaned_ps1=${PROMPT##*${prompt_newline}}
	fi
	unset MATCH MBEGIN MEND

	# Construct the new prompt with a clean preprompt.
	local -ah ps1
	ps1=(
		${(j. .)preprompt_parts}  # Join parts, space separated.
		$prompt_newline           # Separate preprompt and prompt.
		$cleaned_ps1
	)

	PROMPT="${(j..)ps1}"

	# Expand the prompt for future comparision.
	local expanded_prompt
	expanded_prompt="${(S%%)PROMPT}"

	if [[ $1 == precmd ]]; then
		# Initial newline, for spaciousness.
		print
	elif [[ $prompt_pure_last_prompt != $expanded_prompt ]]; then
		# Redraw the prompt.
		prompt_pure_reset_prompt
	fi

	typeset -g prompt_pure_last_prompt=$expanded_prompt
}

prompt_pure_precmd() {
	# check exec time and store it in a variable
	prompt_pure_check_cmd_exec_time
	unset prompt_pure_cmd_timestamp

	# set current time
	prompt_pure_current_time=$(date +%T)

	# shows the full path in the title
	prompt_pure_set_title 'expand-prompt' '%~'

  # Modify the colors if some have changed
	prompt_pure_set_colors

	# preform async git dirty check and fetch
	prompt_pure_async_tasks

	# Check if we should display the virtual env, we use a sufficiently high
	# index of psvar (12) here to avoid collisions with user defined entries.
	psvar[12]=
	# Check if a conda environment is active and display it's name
	if [[ -n $CONDA_DEFAULT_ENV ]]; then
		psvar[12]="${CONDA_DEFAULT_ENV//[$'\t\r\n']}"
	fi
	# When VIRTUAL_ENV_DISABLE_PROMPT is empty, it was unset by the user and
	# Pure should take back control.
	if [[ -n $VIRTUAL_ENV ]] && [[ -z $VIRTUAL_ENV_DISABLE_PROMPT || $VIRTUAL_ENV_DISABLE_PROMPT = 12 ]]; then
		psvar[12]="${VIRTUAL_ENV:t}"
		export VIRTUAL_ENV_DISABLE_PROMPT=12
	fi

	# Make sure VIM prompt is reset.
	prompt_pure_reset_prompt_symbol

	# print the preprompt
	prompt_pure_preprompt_render "precmd"

	if [[ -n $ZSH_THEME ]]; then
		print "WARNING: Oh My Zsh themes are enabled (ZSH_THEME='${ZSH_THEME}'). Pure might not be working correctly."
		print "For more information, see: https://github.com/sindresorhus/pure#oh-my-zsh"
		unset ZSH_THEME  # Only show this warning once.
	fi
}

prompt_pure_async_battery_info() {
	setopt localoptions noshwordsplit

	local battery_data battery_percent battery_status battery_color battery_info

  if prompt_pure_exists pmset; then
    battery_data=$(pmset -g batt | grep "InternalBattery")

    # Return if no internal battery
    [[ -z "$battery_data" ]] && return

    battery_percent="$( echo $battery_data | grep -oE '[0-9]{1,3}%' )"
    battery_status="$( echo $battery_data | awk -F '; *' 'NR==1 { print $2 }' )"
  elif prompt_pure_exists acpi; then
    battery_data=$(acpi -b 2>/dev/null | head -1)

    # Return if no battery
    [[ -z $battery_data ]] && return

    battery_percent="$( echo $battery_data | awk '{print $4}' )"

	# If battery is 0% charge, battery likely doesn't exist.
    [[ $battery_percent == "0%," ]] && return

    battery_status="$( echo $battery_data | awk '{print tolower($3)}' )"
  elif prompt_pure_exists upower; then
    local battery=$(command upower -e | grep battery | head -1)

    # Return if no battery
    [[ -z $battery ]] && return

    battery_data=$(upower -i $battery)
    battery_percent="$( echo "$battery_data" | grep percentage | awk '{print $2}' )"
    battery_status="$( echo "$battery_data" | grep state | awk '{print $2}' )"
  else
    return
  fi

  # Remove trailing % and symbols for comparison
  battery_percent="$(echo $battery_percent | tr -d '%[,;]')"

	# Battery indicator based on current status of battery
  if [[ $battery_status == "charging" ]];then
    battery_symbol="${PURE_PROMPT_BATTERY_SYMBOL_CHARGING}"
  elif [[ $battery_status =~ "^[dD]ischarg.*" ]]; then
    battery_symbol="${PURE_PROMPT_BATTERY_SYMBOL_DISCHARGING}"
	elif [[ $battery_status =~ "AC attached" ]]; then
		battery_symbol=""
  else
    battery_symbol="${PURE_PROMPT_BATTERY_SYMBOL_FULL}"
  fi

  # Change color based on battery percentage
  if [[ $battery_percent == 100 || $battery_status =~ "(charged|full)" ]]; then
    battery_color="%F{green}"
  elif [[ $battery_percent -lt $PURE_PROMPT_BATTERY_THRESHOLD ]]; then
    battery_color="%F{red}"
  else
    battery_color="%F{214}"
  fi

  # Escape % for display since it's a special character in Zsh prompt expansion
  if [[ $PURE_PROMPT_BATTERY_SHOW == 'always' ||
				$battery_percent -lt $PURE_PROMPT_BATTERY_WARNING_THRESHOLD ||
        $battery_percent -lt $PURE_PROMPT_BATTERY_THRESHOLD ||
        $PURE_PROMPT_BATTERY_SHOW == 'charged' && $battery_status =~ "(charged|full)" ]]; then
    battery_info="${battery_color}${battery_symbol}${battery_percent}%%"
	else
		battery_info=""
  fi

	print -- "$battery_info"
}

prompt_pure_async_kubecontext() {
  prompt_pure_exists kubectl || return

  local kube_context=$(kubectl config current-context 2>/dev/null)
  [[ -z $kube_context ]] && return

  if [[ $PURE_PROMPT_KUBECONTEXT_NAMESPACE_SHOW == true ]]; then
    local kube_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    [[ -n $kube_namespace && "$kube_namespace" != "default" ]] && kube_context="$kube_context/$kube_namespace"
  fi

  # Apply custom color to section if $kube_context matches a pattern defined in PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS array.
  local len=${#PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS[@]}
  local it_to=$((len / 2))
  local 'section_color' 'i'
  for ((i = 1; i <= $it_to; i++)); do
    local idx=$(((i - 1) * 2))
    local color="${PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS[$idx + 1]}"
    local pattern="${PURE_PROMPT_KUBECONTEXT_COLOR_GROUPS[$idx + 2]}"
    if [[ "$kube_context" =~ "$pattern" ]]; then
      section_color=$color
      break
    fi
  done

  [[ -z "$section_color" ]] && section_color=$PURE_PROMPT_KUBECONTEXT_COLOR

  print -- "%F{${section_color}}${PURE_PROMPT_KUBECONTEXT_SYMBOL}${kube_context}"
}

prompt_pure_async_terraform() {
  prompt_pure_exists terraform || return

  # Show Terraform Workspaces when exists
  [[ -f .terraform/environment ]] || return

  local terraform_workspace=$(<.terraform/environment)
  [[ -z $terraform_workspace ]] && return

  print -- "%F{$PURE_PROMPT_TERRAFORM_COLOR}${PURE_PROMPT_TERRAFORM_SYMBOL}${terraform_workspace}"
}

# Show current version of Ruby
prompt_pure_async_ruby() {
	# Option EXTENDED_GLOB is set locally to force filename generation on
	# argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
	# See the description of filename generation in
	# http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
	setopt EXTENDED_GLOB LOCAL_OPTIONS

  # Show versions only for Ruby-specific folders
  [[ -f Gemfile || -f Rakefile || -n *.rb(#qN^/) ]] || return

  local 'ruby_version'

  if prompt_pure_exists rvm-prompt; then
    ruby_version=$(rvm-prompt i v g)
  elif prompt_pure_exists chruby; then
    ruby_version=$(chruby | sed -n -e 's/ \* //p')
  elif prompt_pure_exists rbenv; then
    ruby_version=$(rbenv version-name)
  elif prompt_pure_exists asdf; then
    # split output on space and return first element
    ruby_version=${$(asdf current ruby)[1]}
  else
    return
  fi

  [[ -z $ruby_version || "${ruby_version}" == "system" ]] && return

  # Add 'v' before ruby version that starts with a number
  [[ "${ruby_version}" =~ ^[0-9].+$ ]] && ruby_version="v${ruby_version}"

	print -- "%F{$PURE_PROMPT_RUBY_COLOR}${PURE_PROMPT_RUBY_SYMBOL}${ruby_version}"
}

# Show current version of node, exception system.
prompt_pure_async_node() {
	# Option EXTENDED_GLOB is set locally to force filename generation on
	# argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
	# See the description of filename generation in
	# http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
	setopt EXTENDED_GLOB LOCAL_OPTIONS

  # Show NODE status only for JS-specific folders
  [[ -f package.json || -d node_modules || -n *.js(#qN^/) ]] || return

  local 'node_version'

  if prompt_pure_exists nvm; then
    node_version=$(nvm current 2>/dev/null)
    [[ $node_version == "system" || $node_version == "node" ]] && return
  elif prompt_pure_exists nodenv; then
    node_version=$(nodenv version-name)
    [[ $node_version == "system" || $node_version == "node" ]] && return
  elif prompt_pure_exists node; then
    node_version=$(node -v 2>/dev/null)
  else
    return
  fi

  [[ $node_version == $PURE_PROMPT_DEFAULT_VERSION ]] && return

  print -- "%F{$PURE_PROMPT_NODE_COLOR}${PURE_PROMPT_NODE_SYMBOL}${node_version}"
}

prompt_pure_async_golang() {
	# Option EXTENDED_GLOB is set locally to force filename generation on
	# argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
	# See the description of filename generation in
	# http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
	setopt EXTENDED_GLOB LOCAL_OPTIONS

  # If there are Go-specific files in current directory, or current directory is under the GOPATH
  [[ -f go.mod || -d Godeps || -f glide.yaml || -n *.go(#qN^/) || -f Gopkg.yml || -f Gopkg.lock \
  || ( $GOPATH && "$PWD/" =~ "$GOPATH/" ) ]] || return

  prompt_pure_exists go || return

  # Go version is either the commit hash and date like "devel +5efe9a8f11 Web Jan 9 07:21:16 2019 +0000"
  # at the time of the build or a release tag like "go1.11.4".
  # https://github.com/denysdovhan/spaceship-prompt/issues/610
  local go_version=$(go version | awk '{ if ($3 ~ /^devel/) {print $3 ":" substr($4, 2)} else {print "v" substr($3, 3)} }')

  print -- "%F{$PURE_PROMPT_GOLANG_COLOR}${PURE_PROMPT_GOLANG_SYMBOL}${go_version}"
}

prompt_pure_async_docker_compose() {
	# Option EXTENDED_GLOB is set locally to force filename generation on
	# argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
	# See the description of filename generation in
	# http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
	setopt EXTENDED_GLOB LOCAL_OPTIONS

  prompt_pure_exists docker-compose || return

  # Show Docker-compose status when docker-compose file exists
  [[ -f docker-compose.yml ]] || return

  local dockercompose_status up down
	up=0
	down=0
  docker-compose ps 2>/dev/null | tail -n+3 | while read line
  do
    CONTAINER_LETTER_POSITION=$(echo $line | awk 'match($0,"_"){print RSTART}')
    CONTAINER_LETTER=$(echo ${line:$CONTAINER_LETTER_POSITION:1} | tr '[:lower:]' '[:upper:]')
    if [[ $line == *"Up"* ]]; then
      up=1
    else
      down=1
    fi
  done
	if [[ $up -eq 1 && $down -eq 0 ]]; then
		dockercompose_status="up"
	fi
	if [[ $up -eq 0 && $down -eq 1 ]]; then
		dockercompose_status="down"
	fi
	if [[ $up -eq 1 && $down -eq 1 ]]; then
		dockercompose_status="mixed"
	fi
	if [[ $up -eq 0 && $down -eq 0 ]]; then
		dockercompose_status="no containers"
	fi

  print -- "%F{$PURE_PROMPT_DOCKERCOMPOSE_COLOR}${PURE_PROMPT_DOCKERCOMPOSE_SYMBOL}${dockercompose_status}"
}

prompt_pure_async_git_aliases() {
	setopt localoptions noshwordsplit
	local -a gitalias pullalias

	# list all aliases and split on newline.
	gitalias=(${(@f)"$(command git config --get-regexp "^alias\.")"})
	for line in $gitalias; do
		parts=(${(@)=line})           # split line on spaces
		aliasname=${parts[1]#alias.}  # grab the name (alias.[name])
		shift parts                   # remove aliasname

		# check alias for pull or fetch (must be exact match).
		if [[ $parts =~ ^(.*\ )?(pull|fetch)(\ .*)?$ ]]; then
			pullalias+=($aliasname)
		fi
	done

	print -- ${(j:|:)pullalias}  # join on pipe (for use in regex).
}

prompt_pure_async_vcs_info() {
	setopt localoptions noshwordsplit

	# configure vcs_info inside async task, this frees up vcs_info
	# to be used or configured as the user pleases.
	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' use-simple true
	# only export three msg variables from vcs_info
	zstyle ':vcs_info:*' max-exports 3
	# export branch (%b), git toplevel (%R) and stash information via misc (%m)
	zstyle ':vcs_info:git*' formats '%b' '%R' '%m'
	zstyle ':vcs_info:git*' actionformats '%b|%K{red}%F{white}%a%f%k' '%R' '%m'
	zstyle ':vcs_info:git*+set-message:*' hooks git-stash

	vcs_info

	local -A info
	info[pwd]=$PWD
	info[stash]=$vcs_info_msg_2_
	info[top]=$vcs_info_msg_1_
	info[branch]=$vcs_info_msg_0_

	print -r - ${(@kvq)info}
}

# fastest possible way to check if repo is dirty
prompt_pure_async_git_dirty() {
	setopt localoptions noshwordsplit
	local untracked_dirty=$1

	if [[ $untracked_dirty = 0 ]]; then
		command git diff --no-ext-diff --quiet --exit-code
	else
		test -z "$(command git --no-optional-locks status --porcelain --ignore-submodules -unormal)"
	fi

	return $?
}

prompt_pure_async_git_fetch() {
	setopt localoptions noshwordsplit

	# set GIT_TERMINAL_PROMPT=0 to disable auth prompting for git fetch (git 2.3+)
	export GIT_TERMINAL_PROMPT=0
	# set ssh BachMode to disable all interactive ssh password prompting
	export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-"ssh"} -o BatchMode=yes"

	# Default return code, indicates Git fetch failure.
	local fail_code=99

	# Guard against all forms of password prompts. By setting the shell into
	# MONITOR mode we can notice when a child process prompts for user input
	# because it will be suspended. Since we are inside an async worker, we
	# have no way of transmitting the password and the only option is to
	# kill it. If we don't do it this way, the process will corrupt with the
	# async worker.
	setopt localtraps monitor

	# Make sure local HUP trap is unset to allow for signal propagation when
	# the async worker is flushed.
	trap - HUP

	trap '
		# Unset trap to prevent infinite loop
		trap - CHLD
		if [[ $jobstates = suspended* ]]; then
			# Set fail code to password prompt and kill the fetch.
			fail_code=98
			kill %%
		fi
	' CHLD

	command git -c gc.auto=0 fetch >/dev/null &
	wait $! || return $fail_code

	unsetopt monitor

	# check arrow status after a successful git fetch
	prompt_pure_async_git_arrows
}

prompt_pure_async_git_arrows() {
	setopt localoptions noshwordsplit
	command git rev-list --left-right --count HEAD...@'{u}'
}

prompt_pure_async_autojump() {
	if [[ $AUTOJUMP_SOURCED -eq 1 ]]; then
		if [[ -f "${AUTOJUMP_ERROR_PATH}" ]]; then
				autojump --add "$(pwd)" >/dev/null 2>>${AUTOJUMP_ERROR_PATH} &!
		else
				autojump --add "$(pwd)" >/dev/null &!
		fi
	fi

	echo ''
}

# Try to lower the priority of the worker so that disk heavy operations
# like `git status` has less impact on the system responsivity.
prompt_pure_async_renice() {
	setopt localoptions noshwordsplit

	if command -v renice >/dev/null; then
		command renice +15 -p $$
	fi

	if command -v ionice >/dev/null; then
		command ionice -c 3 -p $$
	fi
}

prompt_pure_async_tasks() {
	setopt localoptions noshwordsplit

	# initialize async worker
	((!${prompt_pure_async_init:-0})) && {
		async_start_worker "prompt_pure" -u -n
		async_register_callback "prompt_pure" prompt_pure_async_callback
		typeset -g prompt_pure_async_init=1
		async_job "prompt_pure" prompt_pure_async_renice
	}

	# Update the current working directory of the async worker.
	async_worker_eval "prompt_pure" builtin cd -q $PWD

	typeset -gA prompt_pure_vcs_info

	local -H MATCH MBEGIN MEND
	if [[ $PWD != ${prompt_pure_vcs_info[pwd]}* ]]; then
		# stop any running async jobs
		async_flush_jobs "prompt_pure"

		# reset git preprompt variables, switching working tree
		unset prompt_pure_git_dirty
		unset prompt_pure_git_last_dirty_check_timestamp
		unset prompt_pure_git_arrows
		unset prompt_pure_git_stash
		unset prompt_pure_git_fetch_pattern
		prompt_pure_vcs_info[branch]=
		prompt_pure_vcs_info[top]=
		prompt_pure_vcs_info[stash]=
		prompt_pure_other_info[terraform]=
		prompt_pure_other_info[ruby]=
		prompt_pure_other_info[node]=
		prompt_pure_other_info[golang]=
		prompt_pure_other_info[dco]=
	fi
	unset MATCH MBEGIN MEND

	async_job "prompt_pure" prompt_pure_async_vcs_info
	async_job "prompt_pure" prompt_pure_async_battery_info
	async_job "prompt_pure" prompt_pure_async_kubecontext
	async_job "prompt_pure" prompt_pure_async_terraform
	async_job "prompt_pure" prompt_pure_async_ruby
	async_job "prompt_pure" prompt_pure_async_node
	async_job "prompt_pure" prompt_pure_async_golang
	async_job "prompt_pure" prompt_pure_async_docker_compose

	# if autojump is loaded, add the current dir asynchronously
	if [[ $AUTOJUMP_SOURCED -eq 1 ]]; then
		async_job "prompt_pure" prompt_pure_async_autojump
	fi

	# # only perform tasks inside git working tree
	[[ -n $prompt_pure_vcs_info[top] ]] || return

	prompt_pure_async_refresh
}

prompt_pure_async_refresh() {
	setopt localoptions noshwordsplit

	if [[ -z $prompt_pure_git_fetch_pattern ]]; then
		# we set the pattern here to avoid redoing the pattern check until the
		# working three has changed. pull and fetch are always valid patterns.
		typeset -g prompt_pure_git_fetch_pattern="pull|fetch"
		async_job "prompt_pure" prompt_pure_async_git_aliases
	fi

	async_job "prompt_pure" prompt_pure_async_git_arrows

	# do not preform git fetch if it is disabled or in home folder.
	if (( ${PURE_GIT_PULL:-1} )) && [[ $prompt_pure_vcs_info[top] != $HOME ]]; then
		# tell worker to do a git fetch
		async_job "prompt_pure" prompt_pure_async_git_fetch
	fi

	# if dirty checking is sufficiently fast, tell worker to check it again, or wait for timeout
	integer time_since_last_dirty_check=$(( EPOCHSECONDS - ${prompt_pure_git_last_dirty_check_timestamp:-0} ))
	if (( time_since_last_dirty_check > ${PURE_GIT_DELAY_DIRTY_CHECK:-1800} )); then
		unset prompt_pure_git_last_dirty_check_timestamp
		# check check if there is anything to pull
		async_job "prompt_pure" prompt_pure_async_git_dirty ${PURE_GIT_UNTRACKED_DIRTY:-1}
	fi
}

prompt_pure_check_git_arrows() {
	setopt localoptions noshwordsplit
	local arrows left=${1:-0} right=${2:-0}

	(( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-⇣}
	(( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-⇡}

	[[ -n $arrows ]] || return
	typeset -g REPLY=$arrows
}

prompt_pure_async_callback() {
	setopt localoptions noshwordsplit
	local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6
	local do_render=0

	case $job in
		\[async])
			# Error codes from zsh-async:
			#     1 Corrupted worker output.
			#     2 ZLE watcher detected an error on the worker fd.
			#     3 Response from async_job when worker is missing.
			#   130 Async worker exited, this should never happen in
			#       Pure so the file descriptor is corrupted.
			if (( code == 2 )) || (( code == 3 )) || (( code == 130 )); then
				# Our worker died unexpectedly, recovery
				# will happen on next prompt.
				typeset -g prompt_pure_async_init=0
				async_stop_worker prompt_pure
			fi
			;;
		\[async/eval])
			if (( code )); then
				# Looks like async_worker_eval failed,
				# rerun async tasks just in case.
				prompt_pure_async_tasks
			fi
			;;
		prompt_pure_async_kubecontext|prompt_pure_async_terraform|prompt_pure_async_ruby|prompt_pure_async_node|prompt_pure_async_golang|prompt_pure_async_docker_compose)
			local -A info variable
			typeset -gA prompt_pure_other_info

			case $job in
				prompt_pure_async_kubecontext)
					variable="kubectl"
					show_variable=$PURE_PROMPT_KUBECONTEXT_SHOW
					;;
				prompt_pure_async_terraform)
					variable="terraform"
					show_variable=$PURE_PROMPT_TERRAFORM_SHOW
					;;
				prompt_pure_async_ruby)
					variable="ruby"
					show_variable=$PURE_PROMPT_RUBY_SHOW
					;;
				prompt_pure_async_node)
					variable="node"
					show_variable=$PURE_PROMPT_NODE_SHOW
					;;
				prompt_pure_async_golang)
					variable="golang"
					show_variable=$PURE_PROMPT_GOLANG_SHOW
					;;
				prompt_pure_async_docker_compose)
					variable="dco"
					show_variable=$PURE_PROMPT_DOCKERCOMPOSE_SHOW
					;;
			esac

			# parse output (z) and unquote as array (Q@)
			if [[ -n $output && $show_variable == true ]]; then
				prompt_pure_other_info[$variable]=$output
			else
				prompt_pure_other_info[$variable]=""
			fi

			do_render=1
			;;
		prompt_pure_async_battery_info)
			typeset -g prompt_pure_battery_info
			prompt_pure_battery_info=$output
			do_render=1
			;;
		prompt_pure_async_vcs_info)
			local -A info
			typeset -gA prompt_pure_vcs_info

			# parse output (z) and unquote as array (Q@)
			info=("${(Q@)${(z)output}}")
			local -H MATCH MBEGIN MEND
			if [[ $info[pwd] != $PWD ]]; then
				# The path has changed since the check started, abort.
				return
			fi
			# check if git toplevel has changed
			if [[ $info[top] = $prompt_pure_vcs_info[top] ]]; then
				# if stored pwd is part of $PWD, $PWD is shorter and likelier
				# to be toplevel, so we update pwd
				if [[ $prompt_pure_vcs_info[pwd] = ${PWD}* ]]; then
					prompt_pure_vcs_info[pwd]=$PWD
				fi
			else
				# store $PWD to detect if we (maybe) left the git path
				prompt_pure_vcs_info[pwd]=$PWD
			fi
			unset MATCH MBEGIN MEND

			# update has a git toplevel set which means we just entered a new
			# git directory, run the async refresh tasks
			[[ -n $info[top] ]] && [[ -z $prompt_pure_vcs_info[top] ]] && prompt_pure_async_refresh

			# always update branch, toplevel and stash
			prompt_pure_vcs_info[branch]=$info[branch]
			prompt_pure_vcs_info[top]=$info[top]
			prompt_pure_vcs_info[stash]=$info[stash]

			do_render=1
			;;
		prompt_pure_async_git_aliases)
			if [[ -n $output ]]; then
				# append custom git aliases to the predefined ones.
				prompt_pure_git_fetch_pattern+="|$output"
			fi
			;;
		prompt_pure_async_git_dirty)
			local prev_dirty=$prompt_pure_git_dirty
			if (( code == 0 )); then
				unset prompt_pure_git_dirty
			else
				typeset -g prompt_pure_git_dirty="*"
			fi

			[[ $prev_dirty != $prompt_pure_git_dirty ]] && do_render=1

			# When prompt_pure_git_last_dirty_check_timestamp is set, the git info is displayed in a different color.
			# To distinguish between a "fresh" and a "cached" result, the preprompt is rendered before setting this
			# variable. Thus, only upon next rendering of the preprompt will the result appear in a different color.
			(( $exec_time > 5 )) && prompt_pure_git_last_dirty_check_timestamp=$EPOCHSECONDS
			;;
		prompt_pure_async_git_fetch|prompt_pure_async_git_arrows)
			# prompt_pure_async_git_fetch executes prompt_pure_async_git_arrows
			# after a successful fetch.
			case $code in
				0)
					local REPLY
					prompt_pure_check_git_arrows ${(ps:\t:)output}
					if [[ $prompt_pure_git_arrows != $REPLY ]]; then
						typeset -g prompt_pure_git_arrows=$REPLY
						do_render=1
					fi
					;;
				99|98)
					# Git fetch failed.
					;;
				*)
					# Non-zero exit status from prompt_pure_async_git_arrows,
					# indicating that there is no upstream configured.
					if [[ -n $prompt_pure_git_arrows ]]; then
						unset prompt_pure_git_arrows
						do_render=1
					fi
					;;
			esac
			;;
		prompt_pure_async_renice)
			;;
	esac

	if (( next_pending )); then
		(( do_render )) && typeset -g prompt_pure_async_render_requested=1
		return
	fi

	[[ ${prompt_pure_async_render_requested:-$do_render} = 1 ]] && prompt_pure_preprompt_render
	unset prompt_pure_async_render_requested
}

prompt_pure_reset_prompt() {
	if [[ $CONTEXT == cont ]]; then
		# When the context is "cont", PS2 is active and calling
		# reset-prompt will have no effect on PS1, but it will
		# reset the execution context (%_) of PS2 which we don't
		# want. Unfortunately, we can't save the output of "%_"
		# either because it is only ever rendered as part of the
		# prompt, expanding in-place won't work.
		return
	fi

	zle && zle .reset-prompt
}

prompt_pure_reset_prompt_symbol() {
	prompt_pure_state[prompt]=${PURE_PROMPT_SYMBOL:-❯}
}

prompt_pure_update_vim_prompt_widget() {
	setopt localoptions noshwordsplit
	prompt_pure_state[prompt]=${${KEYMAP/vicmd/${PURE_PROMPT_VICMD_SYMBOL:-❮}}/(main|viins)/${PURE_PROMPT_SYMBOL:-❯}}
	prompt_pure_reset_prompt
}

prompt_pure_reset_vim_prompt_widget() {
	setopt localoptions noshwordsplit
	prompt_pure_reset_prompt_symbol

	# We can't perform a prompt reset at this point because it
	# removes the prompt marks inserted by macOS Terminal.
}

prompt_pure_state_setup() {
	setopt localoptions noshwordsplit

	# Check SSH_CONNECTION and the current state.
	local ssh_connection=${SSH_CONNECTION:-$PROMPT_PURE_SSH_CONNECTION}
	local username hostname
	if [[ -z $ssh_connection ]] && (( $+commands[who] )); then
		# When changing user on a remote system, the $SSH_CONNECTION
		# environment variable can be lost. Attempt detection via `who`.
		local who_out
		who_out=$(who -m 2>/dev/null)
		if (( $? )); then
			# Who am I not supported, fallback to plain who.
			local -a who_in
			who_in=( ${(f)"$(who 2>/dev/null)"} )
			who_out="${(M)who_in:#*[[:space:]]${TTY#/dev/}[[:space:]]*}"
		fi

		local reIPv6='(([0-9a-fA-F]+:)|:){2,}[0-9a-fA-F]+'  # Simplified, only checks partial pattern.
		local reIPv4='([0-9]{1,3}\.){3}[0-9]+'   # Simplified, allows invalid ranges.
		# Here we assume two non-consecutive periods represents a
		# hostname. This matches `foo.bar.baz`, but not `foo.bar`.
		local reHostname='([.][^. ]+){2}'

		# Usually the remote address is surrounded by parenthesis, but
		# not on all systems (e.g. busybox).
		local -H MATCH MBEGIN MEND
		if [[ $who_out =~ "\(?($reIPv4|$reIPv6|$reHostname)\)?\$" ]]; then
			ssh_connection=$MATCH

			# Export variable to allow detection propagation inside
			# shells spawned by this one (e.g. tmux does not always
			# inherit the same tty, which breaks detection).
			export PROMPT_PURE_SSH_CONNECTION=$ssh_connection
		fi
		unset MATCH MBEGIN MEND
	fi

	hostname='%F{$prompt_pure_colors[host]}@%m%f'
	# Show `username@host` if logged in through SSH.
	[[ -n $ssh_connection ]] && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname"

	# Show `username@host` if inside a container and not in GitHub Codespaces.
	[[ -z "${CODESPACES}" ]] && prompt_pure_is_inside_container && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname"

	# Show `username@host` if root, with username in default color.
	[[ $UID -eq 0 ]] && username='%F{$prompt_pure_colors[user:root]}%n%f'"$hostname"

	typeset -gA prompt_pure_state
	prompt_pure_state[version]="1.19.0"
	prompt_pure_state+=(
		username "$username"
		prompt	 "${PURE_PROMPT_SYMBOL:-❯}"
	)
}

# Return true if executing inside a Docker, LXC or systemd-nspawn container.
prompt_pure_is_inside_container() {
	local -r cgroup_file='/proc/1/cgroup'
	local -r nspawn_file='/run/host/container-manager'
	[[ -r "$cgroup_file" && "$(< $cgroup_file)" = *(lxc|docker)* ]] \
		|| [[ "$container" == "lxc" ]] \
		|| [[ -r "$nspawn_file" ]] \
    || [[ -f /.dockerenv ]]
}

prompt_pure_autojump_setup() {
	if [[ $AUTOJUMP_SOURCED -eq 1 ]]; then
		typeset -gaU chpwd_functions
		delete=(autojump_chpwd)
		new_chpwd_functions=()
		for value in "${chpwd_functions[@]}"
		do
				[[ $value != autojump_chpwd ]] && new_chpwd_functions+=($value)
		done
		chpwd_functions=("${new_chpwd_functions[@]}")
		unset new_chpwd_functions
	fi
}

prompt_pure_setup() {
	# Prevent percentage showing up if output doesn't end with a newline.
	export PROMPT_EOL_MARK=''

	prompt_opts=(subst percent)

	# borrowed from promptinit, sets the prompt options in case pure was not
	# initialized via promptinit.
	setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

	if [[ -z $prompt_newline ]]; then
		# This variable needs to be set, usually set by promptinit.
		typeset -g prompt_newline=$'\n%{\r%}'
	fi

	zmodload zsh/datetime
	zmodload zsh/zle
	zmodload zsh/parameter

	autoload -Uz add-zsh-hook
	autoload -Uz vcs_info
	autoload -Uz async && async

	# The add-zle-hook-widget function is not guaranteed
	# to be available, it was added in Zsh 5.3.
	autoload -Uz +X add-zle-hook-widget 2>/dev/null

  # Set the colors.
	typeset -gA prompt_pure_colors_default prompt_pure_colors
	prompt_pure_colors_default=(
		execution_time       yellow
		git:arrow            cyan
		git:stash            cyan
		git:branch           242
		git:branch:cached    red
		git:action           yellow
		git:dirty            218
		host                 242
		path                 blue
		prompt:error         red
		prompt:success       green
		prompt:continuation  242
		user                 242
		user:root            default
		virtualenv           242
	)
	prompt_pure_colors=("${(@kv)prompt_pure_colors_default}")

	add-zsh-hook precmd prompt_pure_precmd
	add-zsh-hook preexec prompt_pure_preexec

	prompt_pure_state_setup
	prompt_pure_autojump_setup

	zle -N prompt_pure_reset_prompt
	zle -N prompt_pure_update_vim_prompt_widget
	zle -N prompt_pure_reset_vim_prompt_widget
	if (( $+functions[add-zle-hook-widget] )); then
		add-zle-hook-widget zle-line-finish prompt_pure_reset_vim_prompt_widget
		add-zle-hook-widget zle-keymap-select prompt_pure_update_vim_prompt_widget
	fi

	# if a virtualenv is activated, display it in grey
	PROMPT='%(12V.%F{$prompt_pure_colors[virtualenv]}%12v%f .)'

	# prompt turns red if the previous command didn't exit with 0
	PROMPT+='%(?.%F{$prompt_pure_colors[prompt:success]}.%F{$prompt_pure_colors[prompt:error]})${prompt_pure_state[prompt]}%f '

	# Indicate continuation prompt by … and use a darker color for it.
	PROMPT2='%F{$prompt_pure_colors[prompt:continuation]}%_… %f%(?.%F{$prompt_pure_colors[prompt:success]}.%F{$prompt_pure_colors[prompt:error]})${prompt_pure_state[prompt]}%f '

	# Store prompt expansion symbols for in-place expansion via (%). For
	# some reason it does not work without storing them in a variable first.
	typeset -ga prompt_pure_debug_depth
	prompt_pure_debug_depth=('%e' '%N' '%x')

	# Compare is used to check if %N equals %x. When they differ, the main
	# prompt is used to allow displaying both file name and function. When
	# they match, we use the secondary prompt to avoid displaying duplicate
	# information.
	local -A ps4_parts
	ps4_parts=(
		depth 	  '%F{yellow}${(l:${(%)prompt_pure_debug_depth[1]}::+:)}%f'
		compare   '${${(%)prompt_pure_debug_depth[2]}:#${(%)prompt_pure_debug_depth[3]}}'
		main      '%F{blue}${${(%)prompt_pure_debug_depth[3]}:t}%f%F{242}:%I%f %F{242}@%f%F{blue}%N%f%F{242}:%i%f'
		secondary '%F{blue}%N%f%F{242}:%i'
		prompt 	  '%F{242}>%f '
	)
	# Combine the parts with conditional logic. First the `:+` operator is
	# used to replace `compare` either with `main` or an ampty string. Then
	# the `:-` operator is used so that if `compare` becomes an empty
	# string, it is replaced with `secondary`.
	local ps4_symbols='${${'${ps4_parts[compare]}':+"'${ps4_parts[main]}'"}:-"'${ps4_parts[secondary]}'"}'

	# Improve the debug prompt (PS4), show depth by repeating the +-sign and
	# add colors to highlight essential parts like file and function name.
	PROMPT4="${ps4_parts[depth]} ${ps4_symbols}${ps4_parts[prompt]}"
  
	# Guard against Oh My Zsh themes overriding Pure.
	unset ZSH_THEME

	# Guard against (ana)conda changing the PS1 prompt
	# (we manually insert the env when it's available).
	export CONDA_CHANGEPS1=no
}
