#!/bin/bash

export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
export VISUAL=nvim
export EDITOR="$VISUAL"
export MANPAGER="nvim +Man!"

source "$XDG_CONFIG_HOME/skhd/functions.sh"

