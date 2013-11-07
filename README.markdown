# Zenjoy's Dotfiles

## Requirements

1) Get XCode + Command Line Tools

You can get Xcode from the Mac App Store. You’ll need at least version 4.4 of Xcode for it to work with OS X Mountain Lion. After the installation, open up Xcode in your /Applications folder. 
You’d want to go to Xcode -> Preferences -> Downloads tab then install the “Command Line Tools.” After you’re done, quit Xcode and fire up Terminal.

2) Set zsh as your default shell and install Oh-My-ZShell

Run `curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh`

3) Install XQuartz, a version of the X.Org X Window System that runs on OS X

http://xquartz.macosforge.org/landing/

## install

```sh
sh -c "`curl -fsSL https://raw.github.com/zenjoy/dotfiles/master/go.sh`"
```

Run this if you want to do this manually:

```sh
git clone https://github.com/zenjoy/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is a simple script that installs some dependencies, sets sane OS X
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

## Topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## What's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork it](https://github.com/zenjoy/dotfiles/fork), remove what you don't
use, and build on what you do use.

## Components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## Bugs

I want this to work for everyone; that means when you clone it down it should
work for you even though you may not have `rbenv` installed, for example. That
said, I do use this as *my* dotfiles, so there's a good chance I may break
something if I forget to make a check for a dependency.

If you're brand-new to the project and run into any blockers, please
[open an issue](https://github.com/zenjoy/dotfiles/issues) on this repository
and I'd love to get it fixed for you!

## Credits & Thanks

This repo is a fork: a huge thanks and all credit goes to @holman for his view on organizing dotfiles
