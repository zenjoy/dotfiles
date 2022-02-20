#!/usr/bin/env fish

if test -n "$DOTFILES_THEME" -a "$DOTFILES_THEME" != 'system'
	if test -f "$DOTFILES/user/themes/$DOTFILES_THEME.fish"
		source "$DOTFILES/user/themes/$DOTFILES_THEME.fish"
	else if test -f "$DOTFILES/themes/$DOTFILES_THEME.fish"
		source "$DOTFILES/themes/$DOTFILES_THEME.fish"
	else
		echo-style --notice="Dorothy theme [$DOTFILES_THEME] is not supported by this shell [fish]" >/dev/stderr
	end
end
