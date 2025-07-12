#!/bin/bash
open_and_move() {
    open -a "$1" && yabai -m window --focus "$(yabai -m query --windows | jq "[.[] | select(.app==\"$1\")][0].id")"
}

switch_yabai_layout() {
    current_layout=$(yabai -m query --spaces --space | jq -r '.type')

    if [ "$current_layout" = "bsp" ]; then
        yabai -m space --layout stack
    elif [ "$current_layout" = "stack" ]; then
        yabai -m space --layout bsp
    else
        yabai -m space --layout bsp
    fi
}

hook_back() {
    current_app=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true).app')
    space=5
    if [[ $current_app == "Ghostty" ]]; then
        space="code"
    elif [[ $current_app == "Zen" ]]; then
        space="browser"
    elif [[ $current_app == "Brave Browser" ]]; then
        space="browser"
    elif [[ $current_app == "Microsoft Teams" ]]; then
        space="chat"
    elif [[ $current_app == "Obsidian" ]]; then
        space="notes"
    elif [[ $current_app == "Notion" ]]; then
        space="other"
    elif [[ $current_app == "Spotify" ]]; then
        space="music"
    elif [[ $current_app == "Postman" ]]; then
        space="other"
    elif [[ $current_app == "pgAdmin 4" ]]; then
        space="other"
    elif [[ $current_app == "Microsoft Outlook" ]]; then
        space="other"
    fi
    yabai -m window --space "$space"; yabai -m space --focus "$space";
 }

#FIX:doesnt work 
focus_prev() {
    current_stack=$(yabai -m query --windows --space | jq '.[0].["stack-index"]')
    win_total=$(yabai -m query --windows --space | jq '. | length')

    # if [[ "$current_stack" == "1" ]]; then 
        # yabai -m window --focus "stack.${win_total}"
    # else
        yabai -m window --focus stack.next
    # fi

}
