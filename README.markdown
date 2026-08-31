# Zenjoy's Dotfiles

## Requirements

### macOS

**TL;DR**: Get XCode + Command Line Tools

You can get Xcode from the [Mac App Store](https://itunes.apple.com/be/app/xcode/id497799835?l=nl&mt=12). You’ll need at least version 4.4 of Xcode for it to work with OS X Mountain Lion. After the installation, open up Xcode in your /Applications folder.
You’d want to go to Xcode -> Preferences -> Downloads tab then install the “Command Line Tools.” Or run `xcode-select --install` in the terminal. After you’re done, quit Xcode and fire up Terminal.

If you're on catalina or above, give the terminal program you're using 'Full Disk Access' before starting the installation.

We use [iTerm2](https://www.iterm2.com/) and [Visual Studio Code](https://code.visualstudio.com/).

### Linux

Supported distros: Ubuntu/Debian and Arch (including Omarchy), both verified in Docker.

Prerequisites: `curl`, `git`, and sudo access. Everything else is installed by the bootstrap.

Install with the same one-liner as macOS:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zenjoy/dotfiles/master/install.sh)"
```

On Linux the setup defaults to a lean core: shell config and CLI tools via Homebrew. GUI apps and macOS-only entries (setup-osx, VS Code extensions tied to macOS, etc.) are skipped automatically.

For an unattended install of that lean core, skip the dev and CLI-apps prompts:

```
DOTFILES_ASSUME_YES=1 DOTFILES_SETUP_DEV=n DOTFILES_SETUP_CLI=n \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/zenjoy/dotfiles/master/install.sh)"
```

`setup-dev` stays interactive even with `DOTFILES_ASSUME_YES` set: its ssh key and git identity prompts aren't covered by that flag. Run `script/setup-dev` afterwards in a terminal if you want dev tooling.

### Windows

**TL;DR**: Get [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (WSL) + [Ubuntu](https://www.microsoft.com/store/productId/9NBLGGH4MSV6) + [Visual Studio Code](https://code.visualstudio.com/)

WSL2 is detected automatically and supported the same way as native Linux.

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
The shell setup is self-managed; it no longer depends on a separate framework checkout.

The only file you'll want to change or create is `~/.localrc`, where you can put
personal changes, preferences or secrets.

If you want to ignore reminders for optional tools you do not use, add them to
`~/.localrc`, for example:

```sh
export DOTFILES_IGNORE_DEPS="direnv mise"
```

### mcporter secrets

The `mcporter` wrapper can load environment variables from macOS Keychain only
when `mcporter` runs. Keep the personal list of variables outside this repo in
`~/.config/mcporter/keychain-env`:

```sh
PERPLEXITY_API_KEY
FIRECRAWL_API_KEY=custom-keychain-service-name
```

Use `ENV_VAR` when the Keychain item service name matches the environment
variable. Use `ENV_VAR=KEYCHAIN_SERVICE` when it differs. Store values with
`keychain-set ENV_VAR` or `security add-generic-password`.

`keychain-set` also accepts one secret piped from 1Password. Normal invocation
still prompts interactively:

```sh
op read -n 'op://VAULT/FrontApp MCP/clientid' |
  keychain-set FRONT_MCP_CLIENT_ID
op read -n 'op://VAULT/FrontApp MCP/client_secret' |
  keychain-set FRONT_MCP_CLIENT_SECRET
```

Agents can inspect the wrapper without printing secret values:

```sh
mcporter --dotfiles-keychain-status
```

When `mcporter` fails and no local keychain env file exists, the wrapper prints
this status command as the next diagnostic step.

## Setup Scripts

There are multiple setup scripts, that can be run multiple times to check if you are running the latest version
or to install new additions to the dotfiles.

Run following commands from anywhere to install:

- **update-dotfiles**: update your local copy of this repository
- **update-all**: update your local copy of this repository AND check if everything is nicely installed
- **setup-dotfiles**: install the symlinks, managed shell plugins, and curated shell tool stack used by this repo
- **setup-osx**: setup macOS sane defaults and multiple useful apps
- **setup-dev**: setup all requirements to get started for (web|mobile|backend|k8s) development
- **setup-cli-apps**: install several useful, convenient or just fun command line tools
- **setup-git**: setup git and related utilities
- **setup-vscode**: setup Visual Studio Code, most useful extensions and several nice themes
- **dotfiles-doctor**: check required and recommended dependencies and print install hints

## Tips

- To disable the 'e.Go:Digital' popup upon starting VS Code, open the Command Pallette, search for 'Power Tools: Global Settings' and disable the 'Open Changelog on startup' in Notification.
- Use https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync to create (or restore from) a backup with all your VSCode user settings.

## Credits & Thanks

This repo is a fork: a huge thanks and all credit goes to @holman for his view on organizing dotfiles
