# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# ASCII Art generated with https://ascii.today/
printf "${BLUE}%s${NORMAL}\n" "Updating your ~/.dotfiles ..."
cd "$DOTFILES"
if git pull --rebase --stat origin master && bootstrapping=1 $HOME/.dotfiles/script/setup-dotfiles
then
  printf '%s' "$GREEN"
  printf '%s\n' '               _                   _       _    __ _ _    '
  printf '%s\n' '              (_)                 | |     | |  / _(_) |    '
  printf '%s\n' ' _______ _ __  _  ___  _   _    __| | ___ | |_| |_ _| | ___  ___ '
  printf '%s\n' "|_  / _ \ '_ \| |/ _ \| | | |  / _\` |/ _ \\| __|  _| | |/ _ \\/ __|"
  printf '%s\n' ' / /  __/ | | | | (_) | |_| | | (_| | (_) | |_| | | | |  __/\__ \'
  printf '%s\n' '/___\___|_| |_| |\___/ \__, |  \__,_|\___/ \__|_| |_|_|\___||___/'
  printf '%s\n' '             _/ |       __/ |                                    '
  printf '%s\n' '            |__/       |___/'
  printf "${BLUE}\n%s\n" "Hooray! Your ~/.dotfiles have been updated and/or is at the current version."
  printf "${BLUE}\n%s ${BOLD}%s${NORMAL}.\n" "Want to check if everything is nicely installed? Run" "update-all"
else
  printf "${RED}%s${NORMAL}\n" 'There was an error updating. Try again later?'
fi