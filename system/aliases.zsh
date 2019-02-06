# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if ! [ -x "$(command -v gls)" ]; then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

if ! [ -x "$(command -v colorls)" ]; then
  alias lc="colorls -lA --sd"
fi

alias k9="killall -9"

alias iphone4s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-4s"
alias iphone5s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-5"
alias ipad="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPad-Air"
alias iphone6plus="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6-Plus"
alias iphone6="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6"
alias iphone6s="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6s"
alias iphone7="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-7"
alias iphoneSE="ios-sim start --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-SE"

# see https://github.com/fcambus/ansiweather for installation anc customization
alias we="ansiweather"

alias lt="localtunnel"