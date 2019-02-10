# Zenjoy's Dotfiles

## Requirements: Get XCode + Command Line Tools

You can get Xcode from the Mac App Store. You’ll need at least version 4.4 of Xcode for it to work with OS X Mountain Lion. After the installation, open up Xcode in your /Applications folder. 
You’d want to go to Xcode -> Preferences -> Downloads tab then install the “Command Line Tools.” After you’re done, quit Xcode and fire up Terminal.

## Install

To install, run:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zenjoy/dotfiles/master/install.sh)"
```

Or manually:

```sh
git clone https://github.com/zenjoy/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The only file you'll want to change or create is `~/.localrc`, where you can put
personal changes, preferences or secrets.

## Setup Scripts

There are multiple setup scripts, that can be run multiple times to check if you are running the latest version
or to install new additions to the dotfiles.

Run following commands from anywhere to install:

- **setup-osx**: setup macOS sane defaults and multiple useful apps
- **setup-dev**: setup all requirements to get started for (web|mobile|backend|k8s) development
- **setup-cli-apps**: install several useful, convenient or just fun command line tools

## Credits & Thanks

This repo is a fork: a huge thanks and all credit goes to @holman for his view on organizing dotfiles
