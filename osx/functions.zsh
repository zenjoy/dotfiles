#!/usr/bin/env zsh

if [[ "`uname -s`" != "Darwin" ]]; then
  return
fi

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

function macos-clear-dns-cache() {
  sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
}

function show-local-ip() {
  ipconfig getifaddr en0
}

function convert-clipboard-to-plain-text() {
  pbpaste | textutil -convert txt -stdin -stdout -encoding 30 | pbcopy
}

function dock-wipe-all() {
  # Wipe all (default) app icons from the Dock
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array
}

function dock-show-open-apps-only() {
  # Show only open applications in the Dock
  defaults write com.apple.dock static-only -bool true
}

function dock-show-all-apps() {
  # Show only open applications in the Dock
  defaults write com.apple.dock static-only -bool false
}

code () {
  if [ ! -f "/usr/local/bin/code" ]; then
    if ! open -R -g -a 'Visual Studio Code' > /dev/null; then
      echo "Visual Studio Code is not installed."
    else
      sudo ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "/usr/local/bin/code"
      /usr/local/bin/code $*
    fi
  fi

  /usr/local/bin/code $*
}


# Change working directory to the top-most Finder window location
function grapfinder { osascript -e 'tell application "Finder"'\
 -e "if (${1-1} <= (count Finder windows)) then"\
 -e "get POSIX path of (target of window ${1-1} as alias)"\
 -e 'else' -e 'get POSIX path of (desktop as alias)'\
 -e 'end if' -e 'end tell'; };\

function cdff { cd "`grapfinder $@`"; };

function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}
