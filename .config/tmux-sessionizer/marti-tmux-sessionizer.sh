#!/bin/sh

directories="
$HOME/Projects
$HOME/Nextcloud
$HOME/.config
$HOME
"

if [ $# -eq 1 ]; then
    dir=$1
else
    dir=$(find $directories -mindepth 1 -maxdepth 1 -follow -type d | fzf)
fi
if [ -z "$dir" ]; then
    exit 0
fi

session=$(basename "$dir" | tr . _)
tmux_running=$(pgrep tmux)
inside_tmux=$(if [ "$TERM_PROGRAM" = 'tmux' ]; then echo 'true'; else echo 'false'; fi)

if tmux has-session -t="$session" 2>/dev/null; then
    if [ "$inside_tmux" = 'true' ]; then
        tmux switch-client -t "$session"
        exit 0
    fi
    tmux attach-session -t "$session"
    exit 0
fi

tmux new-session -d -s "$session" -c "$dir"

if [ "$inside_tmux" = 'true' ]; then
    tmux switch-client -t "$session"
else
    tmux attach-session -t "$session"
fi
 
