# Zenjoy's Dotfiles

## Requirements

### macOS

**TL;DR**: Get XCode + Command Line Tools

You can get Xcode from the [Mac App Store](https://itunes.apple.com/be/app/xcode/id497799835?l=nl&mt=12). You’ll need at least version 4.4 of Xcode for it to work with OS X Mountain Lion. After the installation, open up Xcode in your /Applications folder.
You’d want to go to Xcode -> Preferences -> Downloads tab then install the “Command Line Tools.” Or run `xcode-select --install` in the terminal. After you’re done, quit Xcode and fire up Terminal.

We use [iTerm2](https://www.iterm2.com/) and [Visual Studio Code](https://code.visualstudio.com/).

### Windows

**TL;DR**: Get [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (WSL) + [Ubuntu](https://www.microsoft.com/store/productId/9NBLGGH4MSV6) + [Visual Studio Code](https://code.visualstudio.com/)

The steps to get started on Windows are following:

1. Open PowerShell as Administrator and run:

   ```
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   ```

2. Restart your computer when prompted.
3. Install [Ubuntu](https://www.microsoft.com/store/productId/9NBLGGH4MSV6) from the Windows Store. Run it once and choose a username and password different from 'root'. Choose the password wisely and remember it.
4. Install [Visual Studio Code](https://code.visualstudio.com/) _before_ proceeding with the dotfiles installation.
5. Install the [FiraCode Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip) from https://nerdfonts.com/
6. Install [WSLTTY](https://github.com/mintty/wsltty/releases) and set it up as default shell in VS Code (CTRL+shift+P » Terminal: Select Default Shell). For best esthetics, open it and use following settings (Click on Menu Icon » Options):
   - Under `looks` use the Theme: `dracula`
   - Under `Text` choose FuraCode NF as font, choose the font size as desired
   - Under `Terminal`, change Type `xterm` to `xterm-256color`
7. Open WSLTTY and proceed with the installation.

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

## Tips

To disable the 'e.Go:Digital' popup upon starting VS Code, open the Command Pallette, search for 'Power Tools: Global Settings' and disable the 'Open Changelog on startup' in Notification.

## Credits & Thanks

This repo is a fork: a huge thanks and all credit goes to @holman for his view on organizing dotfiles
