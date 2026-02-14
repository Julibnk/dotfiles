#!/bin/bash
kpid=$(tmux show-env KITTY_PID 2>/dev/null | cut -d= -f2)
[ -z "$kpid" ] && exit 0

windows=$(yabai -m query --windows | jq -r \
  "[.[] | select(.app==\"kitty\") | select(.\"is-floating\"==false and .\"can-move\"==true)] | sort_by(.id)")
letters=("A" "S" "D" "F")
index=$(echo "$windows" | jq --arg pid "$kpid" \
  'to_entries[] | select(.value.pid == ($pid | tonumber)) | .key')

[ -n "$index" ] && tmux set @kitty_letter "${letters[$index]}" || tmux set @kitty_letter ""
