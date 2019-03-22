export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

fpath=($DOTFILES/functions $fpath)

autoload -U $DOTFILES/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt no_bg_nice               # don't nice background tasks
setopt no_hup                   # no hup signal at shell exit
setopt no_beep                  # no annoying beep when a completion is ambiguous
setopt no_list_beep             # beeping is only turned off for ambiguous completions
setopt local_options            # allow functions to have local options
setopt local_traps              # allow functions to have local traps
setopt share_history            # share history between sessions ???
setopt extended_history         # add timestamps to history
setopt prompt_subst             # parameter expansion, command substitution and arithmetic expansion are performed in prompts
setopt correct                  # try to correct the spelling of commands
setopt complete_in_word         # allow completion from within a word/phrase
setopt hash_list_all            # hash everything before completion
setopt complete_aliases         # don't expand aliases _before_ completion has finished
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.
setopt ignore_eof               # do not exit on end-of-file
setopt append_history           # adds history
setopt inc_append_history       # adds history incrementally and share it across sessions
setopt share_history            # share hist between sessions
setopt hist_ignore_all_dups     # don't record dupes in history
setopt hist_reduce_blanks       # trim blanks
setopt bang_hist                # !keyword
setopt hist_verify              # show before executing history commands
unsetopt hist_ignore_space      # ignore space prefixed commands
setopt auto_cd                  # if command is a path, cd into it
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt extended_glob            # activate complex pattern globbing
setopt glob_dots                # include dotfiles in globbing
setopt auto_pushd               # make cd push old dir in dir stack
setopt pushd_ignore_dups        # no duplicates in dir stack
setopt pushd_silent             # no dir stack after pushd or popd
setopt pushd_to_home            # `pushd` = `pushd $HOME`
unsetopt correct_all            # do not try to spelling correct commands
unsetopt correct                # do not try to spelling correct commands
unsetopt rm_star_silent         # ask for confirmation for `rm *' or `rm path/*'
unsetopt bg_nice                # no lower prio for background jobs
unsetopt hist_beep              # no bell on error in history

zle -N newtab

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[^N' newtab
bindkey '^?' backward-delete-char
