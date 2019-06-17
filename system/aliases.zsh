# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`

if command -v gls >/dev/null 2>&1; then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

# Colorls alias
alias lc="colorls -A --group-directories-first"

# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"

alias k9="killall -9"

alias iphone5s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-5s"
alias ipad="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPad-Pro"
alias iphone6plus="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6-Plus"
alias iphone6="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6"
alias iphone6s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6s"
alias iphone7="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-7"
alias iphone8="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-8"
alias iphone8s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-8s"
alias iphoneSE="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-SE"
alias iphoneX="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-X"
alias iphoneXs="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-Xs"

# see https://github.com/fcambus/ansiweather for installation anc customization
alias we="ansiweather"

alias lt="localtunnel"

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Shortcuts
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"

# Get week number
alias week='date +%V'

# Get macOS Software Updates, and update installed Rubygem, Homebrew, and npm
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; npm install npm -g; npm update -g; gem update --system'

# Google Chrome
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias canary='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Merge PDF files
# Usage: `mergepdf -o output.pdf input{1,2,3}.pdf`
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "${method}"="lwp-request -m '${method}'"
done

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'