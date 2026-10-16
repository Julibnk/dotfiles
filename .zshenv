#!/bin/zsh
# Environment for every zsh shell.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export VISUAL=nvim
export EDITOR="$VISUAL"
export MANPAGER="nvim +Man!"
export PAGER="bat"
source "$XDG_CONFIG_HOME/skhd/functions.sh"

[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"
