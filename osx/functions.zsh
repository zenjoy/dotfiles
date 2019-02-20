#!/usr/bin/env zsh

function enable-safari-dev-menu() {
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true && \
    defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
    defaults write -g WebKitDeveloperExtras -bool true
}

function macos-show-file-extensions() {
  defaults write -g AppleShowAllExtensions -bool true
}

function macos-hide-file-extensions() {
  defaults write -g AppleShowAllExtensions -bool false
}

function macos-show-hidden-files() {
  defaults write com.apple.finder AppleShowAllFiles true
}

function macos-hide-hidden-files() {
  defaults write com.apple.finder AppleShowAllFiles false
}

function macos-show-desktop-icons() {
  defaults write com.apple.finder CreateDesktop -bool true && killall Finder
}

function macos-hide-desktop-icons() {
  defaults write com.apple.finder CreateDesktop -bool false && killall Finder
}

function macos-show-finder-statusbar() {
  defaults write com.apple.finder ShowStatusBar -bool true
}

function macos-hide-finder-statusbar() {
  defaults write com.apple.finder ShowStatusBar -bool false
}

function macos-disable-autocorrection() {
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
}

function macos-enable-autocorrection() {
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool true
}

function macos-force-trim() {
  forcetrim
}

function enable-touchid-sudo() {
  file=/etc/pam.d/sudo

  if grep -q "pam_tid.so" "$file"; then
    echo "Touch ID is already enabled for the sudo command. Enjoy!"
  else
    echo "Touch ID not enabled for sudo.. Please provide your password:"
    sudo bash -eu <<'EOF'
    # A backup file will be created with the pattern /etc/pam.d/sudo.backup.1
    # (where 1 is the number of backups, so that rerunning this doesn't make you lose your original)
    file=/etc/pam.d/sudo
    # suppress file not found errors
    exec 2>/dev/null
    bak=$(dirname $file)/$(basename $file).backup.$(echo $(ls $(dirname $file)/$(basename $file).backup* | wc -l))
    cp $file $bak
    awk -v is_done='pam_tid' -v rule='auth       sufficient     pam_tid.so' '
    {
      # $1 is the first field
      # !~ means "does not match pattern"
      if($1 !~ /^#.*/){
        line_number_not_counting_comments++
      }
      # $0 is the whole line
      if(line_number_not_counting_comments==1 && $0 !~ is_done){
        print rule
      }
      print
    }' > $file < $bak
EOF
    echo "All done. Enjoy!"
  fi
}

function macos-clear-dns-cache() {
  sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
}

function show-local-ip() {
  ipconfig getifaddr en0
}

function convert-clipboard-to-plain-text() {
  pbpaste | textutil -convert txt -stdin -stdout -encoding 30 | pbcopy
}