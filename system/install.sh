set -e

echo ''

message=""

success () {
  printf "\r\033[2K [ \033[00;32mok\033[0m ] $1\n"
}

info () {
  if [[ -n $message ]]; then
    success $message
  fi
  printf " [ \033[00;34m..\033[0m ] $1"
  message=$1
}

user () {
  printf "\r\033[2K [ \033[00;33m?\033[0m ] $1"
}

fail () {
  printf "\r\033[2K [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  echo 'See /tmp/laptop-bootstrap for more information.'
  exit 1
}

successfully() {
  ($* >> /tmp/laptop-bootstrap 2>&1) || (fail $message 2>&1)
}

info "Fix OSX zsh environment bug"
  if [[ -f /etc/{zshenv} ]]; then
    successfully sudo mv /etc/{zshenv,zprofile}
  fi

info "Checking for SSH key, generating one if it doesn't exist ..."
  [[ -f ~/.ssh/id_rsa.pub ]] || ssh-keygen -t rsa

info "Copying public key to clipboard. Paste it into your Github account ..."
  [[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy
  successfully open https://github.com/account/ssh

info "Fixing permissions ..."
  successfully sudo mkdir -p /usr/local
  successfully sudo chown -R `whoami` /usr/local