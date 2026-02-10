#!/bin/zsh
#NOTE: Profiling startup
# zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git docker aws zsh-syntax-highlighting zsh-autosuggestions fzf-tab)

# -- Oh my zsh
# source $ZSH/oh-my-zsh.sh
# manually manage plugins
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

ZSH_PLUGIN_HOME=$XDG_DATA_HOME/zsh/plugins
repos=(
  qoomon/zsh-lazyload #https://ellie.wtf/notes/profiling-zsh
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  Aloxaf/fzf-tab
)

for plugin in $repos; do
  if ! [[ -d $ZSH_PLUGIN_HOME/$plugin ]]; then
    git clone https://github.com/$plugin $ZSH_PLUGIN_HOME/$plugin
  fi
  source $ZSH_PLUGIN_HOME/$plugin/${plugin:t}.plugin.zsh
done




# ---- THEME ----
autoload -U promptinit; promptinit
prompt pure
zstyle :prompt:pure:path color '#a6e3a1'
zstyle :prompt:pure:git:arrow color '#f9e2af'
zstyle :prompt:pure:virtualenv color '#74c7ec'

# ---- CONDA ----
#
# TODO check this and configure conda properly
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('lazyload' '/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ---- NVM ----
# export NVM_DIR="$HOME/.nvm"

export NVM_DIR="$XDG_CONFIG_HOME/nvm"
export PATH="$NVM_DIR/versions/node/$(node -v 2>/dev/null || cat $NVM_DIR/alias/default)/bin:$PATH"

# This loads nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then 
   lazyload nvm -- "source $NVM_DIR/nvm.sh" 
fi 

# This loads nvm bash_completion
if [ -s "$NVM_DIR/bash_completion" ]; then 
    lazyload nvm -- "source $NVM_DIR/bash_completion"  
fi


# ---- PNPM ----
export PNPM_HOME="/Users/julibnk/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ---- FZF -----
eval "$(fzf --zsh)"

# --- FZF TAB inside tmux popups ---
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup


FZF_EXCLUDED="--exclude .git --exclude Library --exclude Applications --exclude node_modules --exclude .Trash"
# Use fd instead fdf for search
export FZF_DEFAULT_COMMAND="fd --hidden $FZF_EXCLUDED"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden $FZF_EXCLUDED"

FZF_PREVIEW="
if [ -d {} ]; 
    then eza -a --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions {}; 
    else bat -n --color=always {}; 
fi"

export FZF_DEFAULT_OPTS="
    --tmux 95% 
    --padding 1 
    --layout reverse 
    --style minimal 
    --preview '$FZF_PREVIEW'"
    

export FZF_CTRL_T_OPTS="--preview '$FZF_PREVIEW'"

export FZF_ALT_C_OPTS="--preview ''"

export FZF_CTRL_R_OPTS="
  --preview ''
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"


# function fzf-open-file-widget() {
#     fzf-file-widget | open
# }
#
# zle -N fzf-open-file-widget

#TODO: This breaks fzf plugin for some reason
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
zle -N y

export FPATH="$XDG_CONFIG_HOME/tmux-sessionizer":$FPATH
autoload -U tmux-sessionizer; 
zle -N tmux-sessionizer

# find-in-file - usage: fif <SEARCH_TERM>
fif() {
  if [ ! "$#" -gt 0 ]; then
    echo "Need a string to search for!";
    return 1;
  fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}"
}
zle -N fif


# FZF git plugin
# TODO check this
# source $XDG_CONFIG_HOME/fzf-git/fzf-git.sh
# j 
#
# TODO Try configure someday
# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
# _fzf_comprun() {
#   local command=$1
#   shift
#
#   case "$command" in
#     cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
#     export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
#     ssh)          fzf --preview 'dig {}'                   "$@" ;;
#     *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
#   esac
# }


# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
# bindkey '^D' fzf-cd-widget
# bindkey '^f' fzf-file-widget
#_fzf_compgen_path() {
#  fd --hidden --exclude .git . "$1"
#}

# Use fd to generate the list for directory completion
#_fzf_compgen_dir() {
#  fd --type=d --hidden --exclude .git . "$1"
#}


# ---- ALIASES ----

alias ..='cd ..'
alias -- -='cd -'
alias vim='nvim'
alias v='nvim'
alias t='tmux a'
alias cat='bat'
alias cd='z'
alias rm='trash'
alias l='eza -a --color=always --long --no-filesize --icons=always --no-time --no-user'
alias ls='eza'
alias cl='clear'
# alias fd='fzf'
alias lg='lazygit'
alias ldc='lazydocker'
alias grep='rg --hidden'
alias g='grep'
alias air='~/go/bin/air'


# Init zoxide
eval "$(zoxide init zsh)"

#Activate vim mode
bindkey -v
export KEYTIMEOUT=1
cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode
zmodload zsh/complist

# ---- BINDNGS ----
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char


# Rebind ALT C to Cntrl g for cd
bindkey '^f' fzf-cd-widget
# bindkey '^h' fzf-file-widget
# bindkey '^y' y
# bindkey '^t' tmux-sessionizer

# ---- ENV variables ----



# To customize prompt, run `p10k configure` or edit ~/.dotfiles/zsh/.p10k.zsh.
# TODO: Unistall p10k
# [[ ! -f ~/.dotfiles/zsh/.p10k.zsh ]] || source ~/.dotfiles/zsh/.p10k.zsh


# NOTE: Increase keyboard spped
# defaults write -g InitialKeyRepeat -int 10
# defaults write -g KeyRepeat -int 1
# defaults write -g ApplePressAndHoldEnabled -bool false
export JAVA_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"

export HISTFILE="$ZDOTDIR/.zsh_history"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
setopt append_history
#NOTE: Profiling startup
# zprof
